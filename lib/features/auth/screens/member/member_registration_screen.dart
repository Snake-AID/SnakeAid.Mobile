import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Member Registration Screen
/// Màn hình đăng ký tài khoản người dùng
class MemberRegistrationScreen extends StatefulWidget {
  const MemberRegistrationScreen({super.key});

  @override
  State<MemberRegistrationScreen> createState() => _MemberRegistrationScreenState();
}

class _MemberRegistrationScreenState extends State<MemberRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _birthDateController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreedToTerms = false;
  String _selectedGender = '';
  
  double _passwordStrength = 0.0; // 0.0 to 1.0

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _calculatePasswordStrength(String password) {
    double strength = 0.0;
    
    if (password.isEmpty) {
      strength = 0.0;
    } else {
      // Check password criteria
      bool hasLetters = password.contains(RegExp(r'[a-zA-Z]'));
      bool hasDigits = password.contains(RegExp(r'[0-9]'));
      bool hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/~`]'));
      
      // Barem độ mạnh mật khẩu:
      // Đỏ (Weak - 0.33): Chỉ có chữ cái
      // Vàng (Medium - 0.66): Có chữ cái + số
      // Xanh (Strong - 1.0): Có chữ cái + số + ký tự đặc biệt
      
      if (hasLetters && hasDigits && hasSpecialCharacters) {
        // Có đủ: chữ + số + ký tự đặc biệt -> Xanh (Strong)
        strength = 1.0;
      } else if (hasLetters && hasDigits) {
        // Có chữ + số -> Vàng (Medium)
        strength = 0.66;
      } else if (hasLetters) {
        // Chỉ có chữ -> Đỏ (Weak)
        strength = 0.33;
      } else {
        // Không có chữ (chỉ số hoặc ký tự đặc biệt) -> Không hợp lệ
        strength = 0.0;
      }
    }
    
    setState(() {
      _passwordStrength = strength;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF228B22),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
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
              context.goNamed('member_login');
            }
          },
        ),
        title: const Text(
          'Đăng Ký Tài Khoản',
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
                    // Check for letters
                    if (!value.contains(RegExp(r'[a-zA-Z]'))) {
                      return 'Mật khẩu phải có ít nhất 1 chữ cái';
                    }
                    // Check for digits
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
                const SizedBox(height: 16),

                // Birth Date Field
                _buildTextField(
                  controller: _birthDateController,
                  label: 'Ngày sinh',
                  hint: 'DD/MM/YYYY',
                  readOnly: true,
                  suffixIcon: Icons.calendar_today,
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 16),

                // Gender Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Giới tính',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildGenderOption('Nam', 'male'),
                        const SizedBox(width: 20),
                        _buildGenderOption('Nữ', 'female'),
                        const SizedBox(width: 20),
                        _buildGenderOption('Khác', 'other'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Terms Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreedToTerms = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF228B22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _agreedToTerms = !_agreedToTerms;
                          });
                        },
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF666666),
                            ),
                            children: [
                              TextSpan(text: 'Tôi đồng ý với '),
                              TextSpan(
                                text: 'Điều khoản sử dụng',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF228B22),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: ' và '),
                              TextSpan(
                                text: 'Chính sách bảo mật',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF228B22),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF228B22),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: const Color(0xFF228B22).withOpacity(0.5),
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
                            'Đăng Ký',
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
                              // TODO: Navigate to login screen
                              context.pop();
                            },
                            child: const Text(
                              'Đăng nhập ngay',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF228B22),
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

  Widget _buildGenderOption(String label, String value) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
      },
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _selectedGender == value
                    ? const Color(0xFF228B22)
                    : const Color(0xFFDDDDDD),
                width: 2,
              ),
            ),
            child: _selectedGender == value
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF228B22),
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    bool readOnly = false,
    IconData? suffixIcon,
    VoidCallback? onTap,
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
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFFBDBDBD),
              fontSize: 14,
            ),
            suffixIcon: suffixIcon != null
                ? Icon(
                    suffixIcon,
                    color: const Color(0xFF666666),
                    size: 20,
                  )
                : null,
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
                color: Color(0xFF228B22),
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
                color: Color(0xFF228B22),
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

  void _handleRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đồng ý với điều khoản sử dụng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Implement registration API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Navigate to OTP verification screen
      context.goNamed(
        'otp_verification',
        extra: {
          'email': _emailController.text,
          'roleRoute': 'member_login',
          'themeColor': const Color(0xFF228B22),
        },
      );
    }
  }
}
