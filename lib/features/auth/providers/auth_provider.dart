import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import '../models/user.dart';
import '../models/user_role.dart';
import '../repository/auth_repository.dart'
    show AuthRepository, authRepositoryProvider;
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/refresh_token_request.dart';
import '../../../core/services/fcm_service.dart';

// ==================== AUTH STATE ====================

class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final bool sessionExpired;
  final UserRole? sessionExpiredRole;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.sessionExpired = false,
    this.sessionExpiredRole,
  });

  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
    bool? sessionExpired,
    UserRole? sessionExpiredRole,
    bool clearSessionExpired = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      sessionExpired: clearSessionExpired
          ? false
          : (sessionExpired ?? this.sessionExpired),
      sessionExpiredRole: clearSessionExpired
          ? null
          : (sessionExpiredRole ?? this.sessionExpiredRole),
    );
  }

  factory AuthState.initial() => const AuthState();
}

// ==================== AUTH NOTIFIER ====================

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final FCMService _fcmService = FCMService();
  bool _fcmInitialized = false;
  bool _isForcingLogout = false;

  AuthNotifier({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState(isLoading: true)) {
    _initializeFcm();
    _loadSavedSession();
  }

  Future<void> _initializeFcm() async {
    if (_fcmInitialized) return;
    try {
      await _fcmService.initialize(
        onTokenRefresh: (newToken) async {
          if (!state.isAuthenticated) return;
          await _syncDeviceTokenToBackend(force: true, tokenOverride: newToken);
        },
      );
      _fcmInitialized = true;
    } catch (e) {
      debugPrint('⚠️ FCM init failed: $e');
    }
  }

  Future<void> _syncDeviceTokenToBackend({
    bool force = false,
    String? tokenOverride,
  }) async {
    if (!state.isAuthenticated) return;

    try {
      final token = (tokenOverride ?? await _fcmService.getToken())?.trim();
      if (token == null || token.isEmpty) return;

      await _fcmService.saveToken(token);

      if (!force) {
        final lastSentToken = await _fcmService.getLastSentToken();
        if (lastSentToken == token) {
          return;
        }
      }

      await _authRepository.updateDeviceToken(token);
      await _fcmService.saveLastSentToken(token);
    } catch (e) {
      debugPrint('⚠️ Device token sync skipped: $e');
    }
  }

  /// Startup session validation.
  ///
  /// Flow:
  /// 1. Load tokens from storage. No tokens → unauthenticated.
  /// 2. Load cached user → set authenticated immediately (enables offline browse).
  /// 3. No network → done (use cached user).
  /// 4. Network available → call GET /auth/me
  ///    - 200 → update user + cache. Done.
  ///    - 401 → call POST /auth/refresh
  ///      - 200 → retry GET /auth/me. Done.
  ///      - 401 → refresh token expired → full logout.
  ///    - Other network error → keep cached user (offline-first).
  Future<void> _loadSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final refreshToken = prefs.getString('refresh_token');
      final userId = prefs.getString('user_id');

      // No session stored → go to login
      if (accessToken == null || refreshToken == null || userId == null) {
        debugPrint('ℹ️ No saved session found');
        state = AuthState.initial();
        return;
      }

      // Step 1: Restore from cache immediately so user can browse offline
      final cachedUser = await _loadUserFromCache();
      if (cachedUser == null) {
        // Tokens exist but no cached user → treat as no session
        debugPrint('⚠️ Tokens exist but no cached user, clearing session');
        await _clearSession();
        state = AuthState.initial();
        return;
      }

      state = state.copyWith(
        user: cachedUser,
        isAuthenticated: true,
        isLoading: true, // Keep true until server validation finishes
      );
      debugPrint(
        '✅ Session restored from cache: ${cachedUser.email} (${cachedUser.role.name})',
      );
      _initializeRoleBasedServices(cachedUser);
      await _syncDeviceTokenToBackend();

      // Step 2: If offline, unlock navigation with cached data
      if (!await _isNetworkAvailable()) {
        debugPrint('📵 Offline — using cached session');
        state = state.copyWith(isLoading: false);
        return;
      }

      // Step 3: Online — validate. isLoading=false is set inside
      // _validateAndRefreshSession once the flow fully resolves.
      debugPrint('📶 Online — validating session with server...');
      // If interceptor already called forceLogout during startup, skip validation
      if (!state.isAuthenticated) {
        debugPrint(
          'ℹ️ Session cleared during startup — skipping server validation',
        );
        return;
      }
      await _validateAndRefreshSession(
        userId: userId,
        refreshToken: refreshToken,
      );
    } catch (e) {
      debugPrint('❌ _loadSavedSession error: $e');
      // Don't clear state — cached user (if any) is still usable offline
      state = state.copyWith(isLoading: false);
    }
  }

  /// Call GET /auth/me. On 401, try refresh then retry.
  /// On refresh 401 → full logout.
  Future<void> _validateAndRefreshSession({
    required String userId,
    required String refreshToken,
  }) async {
    // Try to get fresh user data
    final freshUser = await _authRepository.getCurrentUser();

    if (freshUser != null) {
      // /auth/me succeeded — validation complete, allow navigation
      state = state.copyWith(user: freshUser, isLoading: false);
      await _saveUserToCache(freshUser);
      debugPrint('✅ User data refreshed from server');
      _initializeRoleBasedServices(freshUser);
      await _syncDeviceTokenToBackend();
      return;
    }

    // Guard: interceptor may have already called forceLogout() while
    // getCurrentUser() was in-flight. If state is no longer authenticated,
    // don't attempt refresh — that would cause a second refresh cycle.
    if (!state.isAuthenticated) {
      debugPrint('ℹ️ Already logged out by interceptor — skipping refresh');
      return;
    }

    // freshUser == null means 401 from /auth/me → try refresh
    debugPrint('⚠️ /auth/me returned 401, attempting token refresh...');

    final refreshSuccess = await _tryRefreshToken(
      userId: userId,
      refreshToken: refreshToken,
    );

    if (!refreshSuccess) {
      // Refresh token also expired → must re-login
      debugPrint('🚨 Refresh token expired — forcing logout');
      await logout();
      return;
    }

    // Refresh succeeded → retry /auth/me with new token
    final retryUser = await _authRepository.getCurrentUser();
    if (retryUser != null) {
      state = state.copyWith(user: retryUser, isLoading: false);
      await _saveUserToCache(retryUser);
      debugPrint('✅ User data refreshed after token renewal');
      _initializeRoleBasedServices(retryUser);
      await _syncDeviceTokenToBackend();
    } else {
      // /auth/me still failing after refresh — keep cached user, allow navigation
      debugPrint('⚠️ /auth/me failed after refresh — keeping cached user');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Returns true if refresh succeeded, false if refresh token is invalid (401/403).
  /// Throws on network errors so caller can distinguish.
  Future<bool> _tryRefreshToken({
    required String userId,
    required String refreshToken,
  }) async {
    try {
      final response = await _authRepository.refreshToken(
        RefreshTokenRequest(userId: userId, refreshToken: refreshToken),
      );
      return response.isSuccess && response.data != null;
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('401') ||
          msg.contains('unauthorized') ||
          msg.contains('403') ||
          msg.contains('phiên đăng nhập hết hạn')) {
        return false; // Refresh token truly expired
      }
      // Network/server error — don't logout, let cached session stand
      debugPrint(
        '⚠️ Refresh call failed (network?): $e — keeping cached session',
      );
      return true; // Optimistic: keep user logged in
    }
  }

  // ==================== PUBLIC METHODS ====================

  /// Called by TokenRefreshInterceptor when mid-session refresh token is rejected.
  Future<void> forceLogout() async {
    if (_isForcingLogout) {
      debugPrint('ℹ️ forceLogout already in progress — skipping re-entry');
      return;
    }
    _isForcingLogout = true;
    debugPrint('🚨 forceLogout called by interceptor');
    final role = state.user?.role;
    await logout();
    _isForcingLogout = false;
    // Signal the UI to show session-expired dialog
    state = state.copyWith(sessionExpired: true, sessionExpiredRole: role);
  }

  /// Called after the session-expired dialog is dismissed.
  void clearSessionExpired() {
    state = state.copyWith(clearSessionExpired: true);
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _authRepository.login(
        LoginRequest(email: email, password: password),
      );

      if (response.isSuccess && response.data != null) {
        final userData = response.data!.user;
        final user = User(
          id: userData.id,
          email: userData.email,
          fullName: userData.fullName,
          phoneNumber: null,
          role: _parseUserRole(userData.role),
          createdAt: DateTime.now(),
        );

        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
        await _saveUserToCache(user);
        _initializeRoleBasedServices(user);
        await _syncDeviceTokenToBackend(force: true);
        debugPrint('✅ Login successful: ${user.email}');
        return true;
      }

      state = state.copyWith(isLoading: false, error: response.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

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
      final response = await _authRepository.register(
        RegisterRequest(
          email: email,
          password: password,
          fullName: fullName,
          phoneNumber: phoneNumber,
          role: role,
          type: type,
          biography: biography,
        ),
      );
      final success =
          (response.message ?? '').toLowerCase().contains('success') ||
          (response.message ?? '').toLowerCase().contains('thành công');

      state = state.copyWith(
        isLoading: false,
        error: success ? null : (response.message ?? 'Đăng ký thất bại'),
      );
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout({bool showMessage = false}) async {
    try {
      _cleanupRoleBasedServices();

      // Clear local auth first so any interceptor-triggered retries stop
      // immediately, even if a network cleanup call fails.
      await _clearSession();

      try {
        await _fcmService.clearLastSentToken();
      } catch (_) {}

      try {
        await _authRepository.logout(); // Best-effort API call
      } catch (_) {}

      state = AuthState(
        isLoading: false,
        error: showMessage
            ? 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'
            : null,
      );
      debugPrint('✅ Logged out');
    } finally {
      _isForcingLogout = false;
    }
  }

  Future<void> refreshUserData() async {
    if (!state.isAuthenticated) return;
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(user: user);
        await _saveUserToCache(user);
      }
    } catch (e) {
      debugPrint('⚠️ refreshUserData failed: $e');
    }
  }

  void clearError() => state = state.copyWith(clearError: true);

  // ==================== PRIVATE HELPERS ====================

  Future<bool> _isNetworkAvailable() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return results.isNotEmpty &&
          results.any((r) => r != ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  Future<User?> _loadUserFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('cached_user');
      if (json == null) return null;
      return User.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('⚠️ _loadUserFromCache error: $e');
      return null;
    }
  }

  Future<void> _saveUserToCache(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_user', jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('⚠️ _saveUserToCache error: $e');
    }
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove('access_token'),
      prefs.remove('refresh_token'),
      prefs.remove('auth_token'),
      prefs.remove('user_id'),
      prefs.remove('token_expiry'),
      prefs.remove('cached_user'),
      prefs.remove('fcm_token_sent'),
    ]);
    debugPrint('🗑️ Session cleared');
  }

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

  void _initializeRoleBasedServices(User user) {
    debugPrint('🔧 Initializing services for: ${user.role.name}');
    // SignalR and other role-specific providers react to authProvider changes automatically
  }

  void _cleanupRoleBasedServices() {
    debugPrint('🧹 Cleaning up role-based services');
  }
}

// ==================== PROVIDERS ====================

final StateNotifierProvider<AuthNotifier, AuthState> authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
      final authRepository = ref.watch(authRepositoryProvider);
      return AuthNotifier(authRepository: authRepository);
    });

final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(authProvider).isAuthenticated,
);

final currentUserProvider = Provider<User?>(
  (ref) => ref.watch(authProvider).user,
);

final currentUserRoleProvider = Provider<UserRole?>(
  (ref) => ref.watch(currentUserProvider)?.role,
);

final isRescuerProvider = Provider<bool>(
  (ref) => ref.watch(currentUserRoleProvider) == UserRole.rescuer,
);

final isExpertProvider = Provider<bool>(
  (ref) => ref.watch(currentUserRoleProvider) == UserRole.expert,
);

final isMemberProvider = Provider<bool>(
  (ref) => ref.watch(currentUserRoleProvider) == UserRole.member,
);
