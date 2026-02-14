import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:snakeaid_mobile/features/auth/repository/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Splash Screen with loading animation
/// Màn hình khởi động với thanh loading
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  double _progress = 0.0;
  Timer? _timer;
  String? _targetRoute; // Route để navigate sau khi loading xong
  bool _sessionChecked = false; // Flag để biết đã check session xong chưa

  @override
  void initState() {
    super.initState();
    _checkSessionAndStartLoading();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Check session trước, sau đó mới bắt đầu animation
  Future<void> _checkSessionAndStartLoading() async {
    // Check session ngay khi init
    await _checkSession();
    
    // Sau đó mới bắt đầu loading animation
    _startLoading();
  }

  /// Kiểm tra session và xác định route cần navigate
  Future<void> _checkSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final refreshToken = prefs.getString('refresh_token');
      final userId = prefs.getString('user_id');
      
      debugPrint('🔍 Checking saved session...');
      debugPrint('Access Token: ${accessToken != null ? "exists" : "null"}');
      debugPrint('Refresh Token: ${refreshToken != null ? "exists" : "null"}');
      debugPrint('User ID: $userId');
      
      // Nếu có access token và refresh token, verify token còn valid không
      if (accessToken != null && refreshToken != null && userId != null) {
        debugPrint('✅ Found saved session, verifying token...');
        
        try {
          // Gọi API để verify token
          // HttpService sẽ tự động refresh token nếu hết hạn
          final authRepository = ref.read(authRepositoryProvider);
          final user = await authRepository.getCurrentUser();
          
          if (user != null) {
            debugPrint('✅ Session valid (or refreshed), will navigate to home based on role: ${user.role.name}');
            
            // Xác định route dựa vào role (case-insensitive)
            final roleName = user.role.name.toUpperCase();
            switch (roleName) {
              case 'MEMBER':
                _targetRoute = '/member-home';
                break;
              case 'RESCUER':
                _targetRoute = '/rescuer-home';
                break;
              case 'EXPERT':
                _targetRoute = '/expert-home';
                break;
              default:
                _targetRoute = '/role-selection';
            }
            _sessionChecked = true;
            return;
          } else {
            // getCurrentUser trả về null - có thể do refresh token hết hạn
            debugPrint('⚠️ Cannot get user info - session may have expired');
            // Không clear session ở đây vì HttpService đã xử lý
            // Nếu refresh token hết hạn, HttpService đã clear session rồi
          }
        } catch (e) {
          debugPrint('⚠️ Error verifying session: $e');
          // Không clear session ở đây
          // HttpService đã tự động refresh và clear nếu cần
        }
      }
      
      // Nếu không có session hoặc token invalid, navigate về role selection
      debugPrint('ℹ️ No valid session, will navigate to role selection');
      _targetRoute = '/role-selection';
      _sessionChecked = true;
    } catch (e) {
      debugPrint('❌ Error checking session: $e');
      // Có lỗi, navigate về role selection cho an toàn
      _targetRoute = '/role-selection';
      _sessionChecked = true;
    }
  }

  void _startLoading() {
    // Simulate loading progress
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _progress += 0.02; // Increment 2% every 50ms
        
        if (_progress >= 1.0) {
          timer.cancel();
          
          // Navigate sau khi loading animation xong
          if (_sessionChecked && _targetRoute != null && mounted) {
            debugPrint('🚀 Navigating to: $_targetRoute');
            context.go(_targetRoute!);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFCCCCCC),
                      ),
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
