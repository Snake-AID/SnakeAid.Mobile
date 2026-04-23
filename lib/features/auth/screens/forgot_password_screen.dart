import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../repository/auth_repository.dart';

/// Forgot Password Screen - Enter Email
/// Màn hình quên mật khẩu - nhập email
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final Color themeColor;
  final String roleRoute; // For back navigation

  const ForgotPasswordScreen({
    super.key,
    required this.themeColor,
    required this.roleRoute,
  });

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String _normalizeException(Object error) {
    return error.toString().replaceAll('Exception: ', '').trim();
  }

  void _handleSendOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.sendOtp(email);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mã OTP đã được gửi tới email của bạn'),
          backgroundColor: widget.themeColor,
        ),
      );

      context.goNamed(
        'forgot_password_otp',
        extra: {
          'email': email,
          'themeColor': widget.themeColor,
          'roleRoute': widget.roleRoute,
        },
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_normalizeException(error)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(widget.roleRoute);
            }
          },
        ),
        title: const Text(
          'Quên Mật Khẩu',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Visual Section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.lock, size: 100, color: widget.themeColor),
                      Positioned(
                        right: 20,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF6F8F6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.help,
                            size: 36,
                            color: widget.themeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Instructional Section
                const Text(
                  'Quên Mật Khẩu?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Nhập email đã đăng ký. Chúng tôi sẽ gửi mã xác thực để bạn đặt lại mật khẩu mới.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Email Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Nhập email',
                        hintStyle: const TextStyle(
                          color: Color(0xFFBDBDBD),
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFDDDDDD),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFDDDDDD),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: widget.themeColor,
                            width: 1,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        final isValidEmail = RegExp(
                          r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                        ).hasMatch(email);
                        if (!isValidEmail) {
                          return 'Email không đúng định dạng';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Send OTP Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSendOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Gửi Mã Xác Thực',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const Spacer(),

                // Back to Login Link
                GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed(widget.roleRoute);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 16,
                        color: widget.themeColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Quay lại đăng nhập',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: widget.themeColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
