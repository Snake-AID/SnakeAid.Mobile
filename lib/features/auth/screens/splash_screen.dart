import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../repository/auth_repository.dart';
import '../models/refresh_token_request.dart';

/// Splash Screen with loading animation
/// Màn hình khởi động với thanh loading và auto session restoration
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  double _progress = 0.0;
  Timer? _timer;
  bool _hasNavigated = false;
  bool _isValidatingSession = false;
  bool _validationCompleted = false; // Track validation completion
  bool _progressCompleted = false; // Track progress bar completion

  @override
  void initState() {
    super.initState();
    _startLoading();
    _startValidation(); // Start validation immediately (parallel with progress)
  }

  /// Start validation immediately on app launch (parallel with progress bar)
  Future<void> _startValidation() async {
    // Wait for auth provider to finish loading cached session first
    while (ref.read(authProvider).isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }

    // Now perform validation with current auth state
    final authState = ref.read(authProvider);
    await _performValidation(authState);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Perform session validation (called early, parallel with progress bar)
  Future<void> _performValidation(AuthState authState) async {
    if (!mounted) return;

    if (authState.isAuthenticated && authState.user != null) {
      setState(() {
        _isValidatingSession = true;
      });
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📱 SPLASH: User has cached session');
      debugPrint('   User: ${authState.user!.email}');
      debugPrint('   Role: ${authState.user!.role.name}');

      // Check network availability
      final hasNetwork = await _checkNetworkAvailability();

      if (hasNetwork) {
        debugPrint('📶 Network available - Refreshing token...');

        // Proactively refresh token để lấy access token mới
        final refreshSuccess = await _refreshTokenProactively(
          authState.user!.id,
        );

        if (!refreshSuccess) {
          debugPrint('🚨 Token refresh failed - Session expired');
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

          if (!mounted) return;

          // Logout and show friendly message
          await ref.read(authProvider.notifier).logout();

          _hasNavigated = true;
          _showSessionExpiredDialog();
          return;
        }

        debugPrint('✅ Token refreshed successfully - Continuing to home');
      } else {
        debugPrint('📵 Offline mode - Using cached token');
        debugPrint('   → User can browse cached content');
        debugPrint('   → Will refresh token on next API call');
      }

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }

    // Mark validation as completed
    if (!mounted) return;
    setState(() {
      _isValidatingSession = false;
      _validationCompleted = true;
    });

    debugPrint('✅ Validation completed, checking if ready to navigate...');
    _checkAndNavigate();
  }

  /// Check if both progress and validation are done, then navigate
  void _checkAndNavigate() {
    if (_hasNavigated || !mounted) return;

    if (_progressCompleted && _validationCompleted) {
      debugPrint('✅ Both progress and validation complete - Navigating now');
      _navigateToTargetRoute();
    } else {
      debugPrint(
        '⏳ Waiting... Progress: $_progressCompleted, Validation: $_validationCompleted',
      );
    }
  }

  /// Navigate to target route based on auth state
  void _navigateToTargetRoute() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    final authState = ref.read(authProvider);

    String targetRoute;

    if (authState.isAuthenticated && authState.user != null) {
      // User is authenticated, navigate to home based on role
      final roleName = authState.user!.role.name.toUpperCase();
      switch (roleName) {
        case 'MEMBER':
          targetRoute = '/member-home';
          break;
        case 'RESCUER':
          targetRoute = '/rescuer-home';
          break;
        case 'EXPERT':
          targetRoute = '/expert-home';
          break;
        default:
          targetRoute = '/role-selection';
      }
    } else {
      // No valid session, go to role selection
      debugPrint('ℹ️ SPLASH: No valid session, navigating to role selection');
      targetRoute = '/role-selection';
    }

    debugPrint('🚀 SPLASH: Navigating to: $targetRoute');
    context.go(targetRoute);
  }

  /// Check network availability (like Facebook does)
  Future<bool> _checkNetworkAvailability() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      final isOffline =
          connectivityResults.isEmpty ||
          connectivityResults.every(
            (result) => result == ConnectivityResult.none,
          );
      return !isOffline;
    } catch (e) {
      debugPrint('⚠️ Connectivity check failed: $e');
      return false; // Assume offline if check fails
    }
  }

  /// Refresh token proactively when online
  /// Returns true if refresh successful, false if logout needed
  Future<bool> _refreshTokenProactively(String userId) async {
    if (_isValidatingSession) return true; // Avoid duplicate calls

    _isValidatingSession = true;

    try {
      // Get current refresh token
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null) {
        debugPrint('   ⚠️ No refresh token found');
        _isValidatingSession = false;
        return false;
      }

      // Call refresh token API
      final authRepository = ref.read(authRepositoryProvider);
      final request = RefreshTokenRequest(
        userId: userId,
        refreshToken: refreshToken,
      );
      final response = await authRepository.refreshToken(request);

      if (response.data != null) {
        debugPrint('   ✅ Token refreshed successfully');
        debugPrint('   → New access token received');
        _isValidatingSession = false;
        return true;
      }

      // Refresh failed → Check force_logout flag
      final forceLogout = prefs.getBool('force_logout_required') ?? false;

      if (forceLogout) {
        debugPrint('   🚨 Force logout flag detected - Refresh token expired');
        await prefs.remove('force_logout_required');
        _isValidatingSession = false;
        return false;
      }

      debugPrint('   ⚠️ Could not refresh token, but no force logout');
      _isValidatingSession = false;
      return true; // Uncertain, allow navigation
    } catch (e) {
      debugPrint('   ⚠️ Token refresh error: $e');

      // Check force_logout flag (may have been set by interceptor)
      try {
        final prefs = await SharedPreferences.getInstance();
        final forceLogout = prefs.getBool('force_logout_required') ?? false;

        if (forceLogout) {
          debugPrint('   🚨 Force logout flag detected after error');
          await prefs.remove('force_logout_required');
          _isValidatingSession = false;
          return false;
        }
      } catch (_) {}

      // Check if error is 401/Unauthorized (refresh token expired)
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('401') ||
          errorString.contains('unauthorized') ||
          errorString.contains('phiên đăng nhập hết hạn')) {
        debugPrint('   🚨 Refresh token expired (401/Unauthorized detected)');
        debugPrint('   → Forcing logout to require re-authentication');
        _isValidatingSession = false;
        return false;
      }

      _isValidatingSession = false;
      return true; // On network error, allow navigation (offline-first)
    }
  }

  /// Show friendly session expired dialog (like Facebook)
  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF228B22)),
            SizedBox(width: 12),
            Text('Phiên đăng nhập đã hết hạn'),
          ],
        ),
        content: const Text(
          'Phiên đăng nhập của bạn đã hết hạn. '
          'Vui lòng đăng nhập lại để tiếp tục sử dụng ứng dụng.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/role-selection');
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF228B22),
            ),
            child: const Text(
              'Đăng nhập lại',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _startLoading() {
    // Simulate loading progress (runs independently)
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _progress += 0.02; // Increment 2% every 50ms

        if (_progress >= 1.0) {
          timer.cancel();
          _progressCompleted = true;

          debugPrint('✅ Progress bar completed');
          // Check if we can navigate now
          _checkAndNavigate();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Just watch auth state (validation is handled in _startValidation)
    ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Main Content Area - Logo and Text
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Container
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFF228B22).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(80),
                        ),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(80),
                            child: Image.asset(
                              'assets/images/logo/snakeaid_logo.png',
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback icon if image not found
                                return const Icon(
                                  Icons.health_and_safety,
                                  size: 80,
                                  color: Color(0xFF228B22),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // App Name
                      const Text(
                        'SnakeAid',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF228B22),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Tagline
                      const Text(
                        'Cứu hộ rắn cắn thông minh',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer Area - Progress Bar and Status
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    // Progress Bar
                    Container(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Column(
                        children: [
                          // Progress bar track
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0E0E0),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF228B22),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Loading Status Text
                          Text(
                            _isValidatingSession
                                ? 'Đang làm mới phiên...'
                                : 'Đang khởi động...',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF999999),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Version Number
                    const Text(
                      'v1.0.0',
                      style: TextStyle(fontSize: 12, color: Color(0xFFCCCCCC)),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
