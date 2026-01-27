import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Password Reset Success Screen
/// Màn hình thông báo đặt lại mật khẩu thành công
class PasswordResetSuccessScreen extends StatelessWidget {
  final Color themeColor;
  final String roleRoute;

  const PasswordResetSuccessScreen({
    super.key,
    required this.themeColor,
    required this.roleRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon with Animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: themeColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 72,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // Success Title
              const Text(
                'Đặt Lại Mật Khẩu Thành Công!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),

              // Success Message
              const Text(
                'Mật khẩu của bạn đã được thay đổi thành công.\nBây giờ bạn có thể đăng nhập bằng mật khẩu mới.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 48),

              // Back to Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to login screen based on role
                    context.goNamed(roleRoute);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Quay về Đăng Nhập',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Optional: Auto redirect text
              const Text(
                'Bạn sẽ được chuyển đến trang đăng nhập...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFAAAAAA),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
