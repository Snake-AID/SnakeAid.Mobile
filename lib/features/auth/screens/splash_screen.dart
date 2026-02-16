import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../providers/auth_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _navigateBasedOnAuthState(AuthState authState) {
    if (_hasNavigated || !mounted) return;

    _hasNavigated = true;

    String targetRoute;

    if (authState.isAuthenticated && authState.user != null) {
      // User is authenticated, navigate to home based on role
      debugPrint(
        '✅ User authenticated: ${authState.user!.email} (${authState.user!.role.name})',
      );

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
      debugPrint('ℹ️ No valid session, navigating to role selection');
      targetRoute = '/role-selection';
    }

    debugPrint('🚀 Navigating to: $targetRoute');
    context.go(targetRoute);
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

          // Check if auth provider has finished loading
          final authState = ref.read(authProvider);
          if (!authState.isLoading && !_hasNavigated) {
            _navigateBasedOnAuthState(authState);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      // When auth provider finishes loading and progress is complete
      if (!next.isLoading && _progress >= 1.0 && !_hasNavigated) {
        _navigateBasedOnAuthState(next);
      }
    });

    // Also check immediately if auth already finished loading
    // (in case listener was setup after loading completed)
    final authState = ref.watch(authProvider);
    if (!authState.isLoading && _progress >= 1.0 && !_hasNavigated) {
      // Use post-frame callback to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_hasNavigated) {
          _navigateBasedOnAuthState(authState);
        }
      });
    }

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
                          const Text(
                            'Đang khởi động...',
                            style: TextStyle(
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
