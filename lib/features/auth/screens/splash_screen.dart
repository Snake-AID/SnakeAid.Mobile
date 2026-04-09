import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../providers/auth_provider.dart';

/// Splash screen — pure UI concern only.
///
/// All session validation and token refresh logic lives in [AuthNotifier].
/// This screen just plays the progress animation, then routes based on the
/// final auth state once [AuthState.isLoading] becomes false.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  double _progress = 0.0;
  Timer? _progressTimer;
  Timer? _fallbackTimer;
  bool _progressDone = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _startProgress();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _fallbackTimer?.cancel();
    super.dispose();
  }

  void _startProgress() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _progress = (_progress + 0.02).clamp(0.0, 1.0);
        if (_progress >= 1.0) {
          timer.cancel();
          _progressDone = true;
          _tryNavigate();
          // Safety fallback: if auth is still loading after 4s, go to role-selection
          _fallbackTimer = Timer(const Duration(seconds: 4), () {
            if (!_hasNavigated && mounted) {
              debugPrint('⚠️ Splash fallback: auth still loading after timeout, forcing role-selection');
              _hasNavigated = true;
              context.go('/role-selection');
            }
          });
        }
      });
    });
  }

  void _tryNavigate() {
    if (_hasNavigated || !mounted) return;

    final authState = ref.read(authProvider);
    if (!_progressDone || authState.isLoading) return;

    _hasNavigated = true;

    if (!authState.isAuthenticated || authState.user == null) {
      context.go('/role-selection');
      return;
    }

    switch (authState.user!.role.name.toUpperCase()) {
      case 'MEMBER':
        context.go('/member-home');
        break;
      case 'RESCUER':
        context.go('/rescuer-home');
        break;
      case 'EXPERT':
        context.go('/expert-home');
        break;
      default:
        context.go('/role-selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state — when isLoading flips to false, attempt navigation
    ref.listen<AuthState>(authProvider, (_, next) {
      if (!next.isLoading) _tryNavigate();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Logo + branding
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFF228B22).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(80),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(80),
                          child: Image.asset(
                            'assets/images/logo/snakeaid_logo.png',
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.health_and_safety,
                              size: 80,
                              color: Color(0xFF228B22),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
                      const Text(
                        'Cứu hộ rắn cắn thông minh',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Progress bar + status
              Column(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Column(
                      children: [
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
                        Text(
                          ref.watch(authProvider).isLoading
                              ? 'Đang xác thực phiên...'
                              : 'Đang khởi động...',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'v1.0.0',
                    style: TextStyle(fontSize: 12, color: Color(0xFFCCCCCC)),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
