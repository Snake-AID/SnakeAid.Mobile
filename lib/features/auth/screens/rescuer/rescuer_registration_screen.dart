import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Rescuer Registration Screen
/// Màn hình đăng ký tài khoản người cứu hộ
class RescuerRegistrationScreen extends StatefulWidget {
  const RescuerRegistrationScreen({super.key});

  @override
  State<RescuerRegistrationScreen> createState() => _RescuerRegistrationScreenState();
}

class _RescuerRegistrationScreenState extends State<RescuerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _organizationController = TextEditingController();
  final _yearsOfExperienceController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  
  double _passwordStrength = 0.0;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _organizationController.dispose();
    _yearsOfExperienceController.dispose();
    super.dispose();
  }

  void _calculatePasswordStrength(String password) {
    double strength = 0.0;
    
    if (password.isEmpty) {
      strength = 0.0;
    } else {
      bool hasLetters = password.contains(RegExp(r'[a-zA-Z]'));
      bool hasDigits = password.contains(RegExp(r'[0-9]'));
      bool hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/~`]'));
      
      if (hasLetters && hasDigits && hasSpecialCharacters) {
        strength = 1.0;
      } else if (hasLetters && hasDigits) {
        strength = 0.66;
      } else if (hasLetters) {
        strength = 0.33;
      } else {
        strength = 0.0;
      }
    }
    
    setState(() {
      _passwordStrength = strength;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('rescuer_login');
            }
          },
        ),
        title: const Text(
          'Đăng Ký Người Cứu Hộ',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Info Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFF6B35).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFFFF6B35),
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tài khoản cứu hộ cần được phê duyệt bởi quản trị viên',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFFF6B35),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Full Name Field
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Họ và tên *',
                  hint: 'Nhập họ và tên đầy đủ',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập họ và tên';
                    }
                    if (value.length < 3) {
                      return 'Họ tên phải có ít nhất 3 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone Field
                _buildTextField(
                  controller: _phoneController,
                  label: 'Số điện thoại *',
                  hint: '+84 xxx xxx xxx',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    final phoneRegex = RegExp(r'^0[0-9]{9}$');
                    if (!phoneRegex.hasMatch(value)) {
                      return 'Số điện thoại không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field
                _buildTextField(
                  controller: _emailController,
                  label: 'Email *',
                  hint: 'example@email.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Organization Field
                _buildTextField(
                  controller: _organizationController,
                  label: 'Tổ chức/Đơn vị (nếu có)',
                  hint: 'Tên tổ chức cứu hộ',
                ),
                const SizedBox(height: 16),

                // Years of Experience
                _buildTextField(
                  controller: _yearsOfExperienceController,
                  label: 'Số năm kinh nghiệm cứu hộ',
                  hint: 'VD: 5',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final years = int.tryParse(value);
                      if (years == null || years < 0) {
                        return 'Vui lòng nhập số hợp lệ';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field with Strength Indicator
                _buildPasswordField(
                  controller: _passwordController,
                  label: 'Mật khẩu *',
                  hint: 'Tối thiểu 8 ký tự',
                  isPasswordVisible: _isPasswordVisible,
                  onTogglePassword: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  onChanged: (value) => _calculatePasswordStrength(value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 8) {
                      return 'Mật khẩu phải có ít nhất 8 ký tự';
                    }
                    if (!value.contains(RegExp(r'[a-zA-Z]'))) {
                      return 'Mật khẩu phải có ít nhất 1 chữ cái';
                    }
                    if (!value.contains(RegExp(r'[0-9]'))) {
                      return 'Mật khẩu phải có ít nhất 1 chữ số';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Xác nhận mật khẩu *',
                  hint: 'Nhập lại mật khẩu',
                  isPasswordVisible: _isConfirmPasswordVisible,
                  showStrengthIndicator: false,
                  onTogglePassword: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng xác nhận mật khẩu';
                    }
                    if (value != _passwordController.text) {
                      return 'Mật khẩu không khớp';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: const Color(0xFFFF6B35).withOpacity(0.5),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Tiếp Tục',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Login Link
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                      children: [
                        const TextSpan(text: 'Đã có tài khoản? '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              context.pop();
                            },
                            child: const Text(
                              'Đăng nhập ngay',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFF6B35),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
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
              borderSide: const BorderSide(
                color: Color(0xFFFF6B35),
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
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isPasswordVisible,
    required VoidCallback onTogglePassword,
    bool showStrengthIndicator = true,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !isPasswordVisible,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFFBDBDBD),
              fontSize: 14,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF666666),
                size: 20,
              ),
              onPressed: onTogglePassword,
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
              borderSide: const BorderSide(
                color: Color(0xFFFF6B35),
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
        ),
        if (showStrengthIndicator) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: _passwordStrength >= 0.33
                        ? const Color(0xFFFF4136)
                        : const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: _passwordStrength >= 0.66
                        ? const Color(0xFFFFDC00)
                        : const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: _passwordStrength >= 1.0
                        ? const Color(0xFF2ECC40)
                        : _passwordStrength >= 0.66
                            ? const Color(0xFF2ECC40).withOpacity(0.3)
                            : const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _handleContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Implement registration API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Navigate to terms screen
      context.goNamed(
        'rescuer_terms',
        extra: {
          'email': _emailController.text,
          'fullName': _fullNameController.text,
          'phone': _phoneController.text,
          'organization': _organizationController.text,
          'experience': _yearsOfExperienceController.text,
        },
      );
    }
  }
}
