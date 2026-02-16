import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../models/user_role.dart';
import '../repository/auth_repository.dart'
    show AuthRepository, authRepositoryProvider;
import '../models/login_request.dart';
import '../models/register_request.dart';

// ==================== AUTH STATE ====================

/// Authentication state
/// Manages user session, tokens, and loading states
class AuthState {
  /// Currently logged in user (null if not logged in)
  final User? user;

  /// Whether user is authenticated
  final bool isAuthenticated;

  /// Whether an auth operation is in progress
  final bool isLoading;

  /// Error message if operation failed
  final String? error;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  /// Creates a copy with modified fields
  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Reset to initial state (for logout)
  factory AuthState.initial() => const AuthState();

  @override
  String toString() =>
      'AuthState(user: ${user?.email}, isAuth: $isAuthenticated, loading: $isLoading)';
}

// ==================== AUTH NOTIFIER ====================

/// Manages authentication state and operations
/// Handles login, logout, session restoration, and user state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthNotifier({required AuthRepository authRepository, required Ref ref})
    : _authRepository = authRepository,
      _ref = ref,
      super(const AuthState(isLoading: true)) {
    // Load saved session on initialization
    _loadSavedSession().then((_) {
      // Set isLoading to false after session check completes
      // (if still in loading state and not authenticated)
      if (state.isLoading && !state.isAuthenticated) {
        state = state.copyWith(isLoading: false);
      }
    });
  }

  /// 🔴 Check if force logout is required (called on-demand, NO polling)
  ///
  /// Flow when token expires:
  /// 1. User makes API call → Token expired → 401
  /// 2. TokenRefreshInterceptor tries refresh → Refresh fails
  /// 3. Interceptor calls _forceLogout() → Clears session + Sets 'force_logout_required' flag
  /// 4. This method detects flag and logs out user
  ///
  /// Trigger points (on-demand, not continuous polling):
  /// - ✅ App init (_loadSavedSession) - Catches flag from previous session
  /// - ✅ After any API 401 error - Can be called from error handlers
  /// - ✅ App resume from background - Optional, can be added to lifecycle
  ///
  /// Alternative: After interceptor clears tokens, next navigation will
  /// naturally redirect to login when isAuthenticated check fails.
  Future<void> checkAndHandleForceLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final forceLogout = prefs.getBool('force_logout_required') ?? false;

      if (forceLogout && state.isAuthenticated) {
        debugPrint('🚨 Force logout flag detected, logging out...');
        await prefs.remove('force_logout_required');

        // Clear state without calling logout API (already failed)
        _cleanupRoleBasedServices();
        await _clearUserCache();
        state = AuthState.initial();

        debugPrint('✅ Forced logout completed');
      }
    } catch (e) {
      debugPrint('⚠️ Force logout check error: $e');
    }
  }

  /// Load saved user session from storage
  /// Called automatically on provider initialization
  /// 🔥 OFFLINE SUPPORT: Load cached user first, then verify with API
  Future<void> _loadSavedSession() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📱 Loading saved session...');

      // 🔴 Check if interceptor flagged force logout (e.g., token refresh failed)
      await checkAndHandleForceLogout();
      if (!state.isAuthenticated) {
        debugPrint('⚠️ Force logout was triggered, skipping session load');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final userId = prefs.getString('user_id');

      if (accessToken != null && userId != null) {
        debugPrint('✅ Found saved session for user: $userId');

        // 🔥 STEP 1: Load cached user data first (works offline)
        final cachedUser = await _loadUserFromCache();

        if (cachedUser != null) {
          // Restore session from cache immediately
          state = state.copyWith(
            user: cachedUser,
            isAuthenticated: true,
            isLoading: false, // Done loading from cache
          );
          debugPrint('✅ Session restored from cache (OFFLINE CAPABLE)');
          debugPrint('📱 User: ${cachedUser.email} (${cachedUser.role.name})');

          // Trigger role-based services (will fail gracefully if offline)
          _initializeRoleBasedServices(cachedUser);
        }

        // 🔥 STEP 2: Verify token with API in background (needs online)
        try {
          final user = await _authRepository.getCurrentUser();

          if (user != null) {
            // Update with fresh data from API
            state = state.copyWith(user: user);

            // Update cache with fresh data
            await _saveUserToCache(user);

            debugPrint('✅ User data refreshed from API');

            // Re-trigger services in case role changed
            _initializeRoleBasedServices(user);
          }
        } catch (e) {
          debugPrint('⚠️ Failed to verify token with API (offline mode)');
          debugPrint('📱 Continuing with cached user data');
          // Don't throw - keep using cached data
        }
      } else {
        debugPrint('ℹ️ No saved session found');
      }
    } catch (e) {
      debugPrint('❌ Failed to load session: $e');
      // Don't throw, just start with empty state
    }
  }

  /// Login with email and password
  ///
  /// Returns true if login successful, false otherwise
  /// Sets user state and triggers role-based initializations (e.g., SignalR for rescuer)
  Future<bool> login({required String email, required String password}) async {
    // Set loading state and clear previous errors
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔐 Logging in: $email');

      final loginRequest = LoginRequest(email: email, password: password);

      final response = await _authRepository.login(loginRequest);

      if (response.isSuccess && response.data != null) {
        final userData = response.data!.user;

        // Convert UserData to User model
        final user = User(
          id: userData.id,
          email: userData.email,
          fullName: userData.fullName,
          phoneNumber: null,
          role: _parseUserRole(userData.role),
          createdAt: DateTime.now(),
        );

        // Update state with user data
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );

        // 💾 Cache user for offline access
        await _saveUserToCache(user);

        debugPrint('✅ Login successful: ${user.email}');
        debugPrint('👤 User role: ${userData.role}');
        debugPrint('📱 User ID: ${user.id}');

        // Trigger role-based initialization
        _initializeRoleBasedServices(user);

        return true;
      } else {
        // Login failed
        state = state.copyWith(isLoading: false, error: response.message);
        debugPrint('❌ Login failed: ${response.message}');
        return false;
      }
    } catch (e) {
      // Set error state
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      debugPrint('❌ Login error: $e');
      return false;
    }
  }

  /// Register new user
  ///
  /// Returns true if registration successful, false otherwise
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String role,
    String? type,
    String? biography,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📝 Registering new user: $email');

      final registerRequest = RegisterRequest(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        role: role,
        type: type,
        biography: biography,
      );

      final response = await _authRepository.register(registerRequest);

      // Check if registration successful (assumes 2xx status code or specific flag)
      final message = response.message ?? '';
      final isSuccess =
          message.toLowerCase().contains('success') ||
          message.toLowerCase().contains('thành công');

      if (isSuccess) {
        state = state.copyWith(isLoading: false);
        debugPrint('✅ Registration successful: ${response.message}');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Đăng ký thất bại',
        );
        debugPrint('❌ Registration failed: ${response.message}');
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      debugPrint('❌ Registration error: $e');
      return false;
    }
  }

  /// Logout current user
  /// Clears session and disconnects all services (SignalR, etc.)
  Future<void> logout() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🚪 Logging out...');

      // Cleanup role-based services before logout
      _cleanupRoleBasedServices();

      // Call logout API
      await _authRepository.logout();

      // Clear user cache
      await _clearUserCache();

      // Clear local state
      state = AuthState.initial();

      debugPrint('✅ Logged out successfully');
    } catch (e) {
      debugPrint('⚠️ Logout error (clearing local state anyway): $e');
      // Clear state even if API fails
      await _clearUserCache();
      state = AuthState.initial();
    }
  }

  /// Refresh current user data from API
  /// Updates cache after successful refresh
  Future<void> refreshUserData() async {
    if (!state.isAuthenticated) return;

    try {
      debugPrint('🔄 Refreshing user data...');

      final user = await _authRepository.getCurrentUser();

      if (user != null) {
        state = state.copyWith(user: user);

        // Update cache
        await _saveUserToCache(user);

        debugPrint('✅ User data refreshed');
      }
    } catch (e) {
      debugPrint('❌ Failed to refresh user data: $e');
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Parse user role string to UserRole enum
  UserRole _parseUserRole(String roleString) {
    switch (roleString.toUpperCase()) {
      case 'MEMBER':
        return UserRole.member;
      case 'RESCUER':
        return UserRole.rescuer;
      case 'EXPERT':
        return UserRole.expert;
      default:
        return UserRole.member;
    }
  }

  /// Initialize role-based services after login
  /// - Rescuer: Auto-connect to SignalR hub
  /// - Expert: Initialize availability tracking
  /// - Member: No special initialization needed
  void _initializeRoleBasedServices(User user) {
    debugPrint('🔧 Initializing role-based services for: ${user.role.name}');

    switch (user.role) {
      case UserRole.rescuer:
        debugPrint('🚑 User is RESCUER - will initialize SignalR connection');
        // SignalR connection will be managed by rescuer_signalr_provider
        // which listens to authProvider changes
        break;

      case UserRole.expert:
        debugPrint('👨‍⚕️ User is EXPERT - no special initialization needed');
        // Could initialize expert-specific services here
        break;

      case UserRole.member:
        debugPrint('👤 User is MEMBER - no special initialization needed');
        break;
    }
  }

  // ==================== CACHE HELPERS ====================

  /// Save user to SharedPreferences cache for offline access
  /// Called after successful login and API refresh
  Future<void> _saveUserToCache(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString('cached_user', userJson);
      debugPrint('💾 User cached for offline use');
    } catch (e) {
      debugPrint('⚠️ Failed to cache user: $e');
      // Don't throw - caching is optional feature
    }
  }

  /// Load user from SharedPreferences cache
  /// Returns null if no cache found or cache is invalid
  Future<User?> _loadUserFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('cached_user');

      if (userJson == null) {
        debugPrint('ℹ️ No cached user found');
        return null;
      }

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      final user = User.fromJson(userMap);

      debugPrint('📦 Loaded user from cache: ${user.email}');
      return user;
    } catch (e) {
      debugPrint('⚠️ Failed to load cached user: $e');
      return null;
    }
  }

  /// Clear cached user data from SharedPreferences
  /// Called on logout
  Future<void> _clearUserCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_user');
      debugPrint('🗑️ User cache cleared');
    } catch (e) {
      debugPrint('⚠️ Failed to clear user cache: $e');
    }
  }

  /// Cleanup role-based services before logout
  void _cleanupRoleBasedServices() {
    if (state.user == null) return;

    debugPrint(
      '🧹 Cleaning up role-based services for: ${state.user!.role.name}',
    );

    switch (state.user!.role) {
      case UserRole.rescuer:
        debugPrint('🚑 Disconnecting SignalR for RESCUER');
        // Will be handled by rescuer_signalr_provider listener
        break;

      default:
        break;
    }
  }
}

// ==================== PROVIDERS ====================

/// Main authentication provider
/// Manages user session and auth operations
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository: authRepository, ref: ref);
});

/// Computed: Is user authenticated?
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
});

/// Computed: Current logged-in user
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

/// Computed: Current user role
final currentUserRoleProvider = Provider<UserRole?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role;
});

/// Computed: Is user a rescuer?
final isRescuerProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return role == UserRole.rescuer;
});

/// Computed: Is user an expert?
final isExpertProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return role == UserRole.expert;
});

/// Computed: Is user a member?
final isMemberProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return role == UserRole.member;
});

// ==================== USAGE NOTES ====================
// 
// To manually trigger force logout check (optional, usually not needed):
// 
// In a widget or error handler:
//   final authNotifier = ref.read(authProvider.notifier);
//   await authNotifier.checkAndHandleForceLogout();
// 
// This is useful for:
//   - Global error boundaries catching 401 errors
//   - App lifecycle events (app resume)
//   - Manual retry after network errors
// 
// However, in most cases this is automatic:
//   - Checked on app init
//   - Token cleared → next navigation redirects to login
// 
// =====================================================
