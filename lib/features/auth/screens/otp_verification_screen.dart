import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/verify_account_request.dart';
import '../repository/auth_repository.dart';

/// OTP Verification Screen
/// Màn hình xác thực mã OTP
class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  final String roleRoute;
  final Color themeColor;
  
  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.roleRoute,
    required this.themeColor,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  int _secondsRemaining = 59;
  Timer? _timer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 59;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    
    // Auto-submit when all 6 digits are entered
    if (value.length == 1 && index == 5) {
      // Check if all fields are filled
      final otpCode = _getOtpCode();
      if (otpCode.length == 6) {
        // Unfocus current field
        _focusNodes[index].unfocus();
        // Auto verify after short delay for better UX
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _verifyOtp();
          }
        });
      }
    }
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _getOtpCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  void _verifyOtp() async {
    final otpCode = _getOtpCode();
    
    if (otpCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đủ 6 số'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      // Tạo verify request
      final verifyRequest = VerifyAccountRequest(
        email: widget.email,
        otp: otpCode,
      );

      // Gọi API verify account
      final authRepository = ref.read(authRepositoryProvider);
      final response = await authRepository.verifyAccount(verifyRequest);

      if (mounted) {
        setState(() {
          _isVerifying = false;
        });

        if (response.isSuccess) {
          // Hiển thị thông báo thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Xác thực thành công! Chào mừng ${response.authData?.user.fullName ?? "bạn"}'),
              backgroundColor: widget.themeColor,
            ),
          );

          // Navigate to success screen
          context.goNamed(
            'registration_success',
            extra: {
              'email': widget.email,
              'roleRoute': widget.roleRoute,
              'themeColor': widget.themeColor,
            },
          );
        } else {
          // Xử lý trường hợp verify không thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });

        // Hiển thị lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _resendOtp() async {
    if (_secondsRemaining > 0) {
      return;
    }

    try {
      // Gọi API gửi lại OTP
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.sendOtp(widget.email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Mã OTP mới đã được gửi đến email của bạn!'),
            backgroundColor: widget.themeColor,
          ),
        );

        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gửi OTP thất bại: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getMaskedEmail() {
    final email = widget.email;
    final atIndex = email.indexOf('@');
    if (atIndex <= 0) return email;
    
    final username = email.substring(0, atIndex);
    final domain = email.substring(atIndex);
    
    if (username.length <= 4) {
      return '${username[0]}***$domain';
    }
    
    return '${username.substring(0, 4)}***$domain';
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
              // Fallback to role_selection if can't determine role
              context.goNamed('role_selection');
            }
          },
        ),
        title: const Text(
          'Xác Thực OTP',
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon Section
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: widget.themeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Icon(
                        Icons.mail_outline,
                        size: 48,
                        color: widget.themeColor,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    const Text(
                      'Nhập Mã Xác Thực',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Description
                    const Text(
                      'Mã xác thực đã được gửi đến',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getMaskedEmail(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // OTP Input Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        return Container(
                          margin: EdgeInsets.only(
                            left: index == 0 ? 0 : 4,
                            right: index == 5 ? 0 : 4,
                          ),
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: KeyboardListener(
                              focusNode: FocusNode(),
                              onKeyEvent: (event) => _onKeyEvent(event, index),
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
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
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) => _onChanged(value, index),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // Timer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: Color(0xFF666666),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Gửi lại mã sau ${_secondsRemaining.toString().padLeft(2, '0')}s',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bottom Section
              Column(
                children: [
                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.themeColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isVerifying
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Xác Nhận',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Resend Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Không nhận được mã? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                      GestureDetector(
                        onTap: _resendOtp,
                        child: Text(
                          'Gửi lại',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _secondsRemaining > 0
                                ? const Color(0xFF666666)
                                : widget.themeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
