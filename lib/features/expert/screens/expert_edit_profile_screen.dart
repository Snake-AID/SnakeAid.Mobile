import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Expert Edit Profile Screen - Update expert profile information
/// Màn hình chỉnh sửa hồ sơ Chuyên gia
class ExpertEditProfileScreen extends StatefulWidget {
  const ExpertEditProfileScreen({super.key});

  @override
  State<ExpertEditProfileScreen> createState() => _ExpertEditProfileScreenState();
}

class _ExpertEditProfileScreenState extends State<ExpertEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _fullNameController = TextEditingController(text: 'Nguyễn Văn A');
  final _phoneController = TextEditingController(text: '0912 345 678');
  final _emailController = TextEditingController(text: 'bacsia@snakeaid.com');
  final _dobController = TextEditingController(text: '01/01/1980');
  final _addressController = TextEditingController(text: '123 Đường Nguyễn Huệ, Quận 1, TP.HCM');
  final _idCardController = TextEditingController(text: '079080000123');
  final _jobTitleController = TextEditingController(text: 'Bác sĩ Chuyên khoa I');
  final _experienceController = TextEditingController(text: '15');
  final _bioController = TextEditingController(
    text: 'Chuyên gia hàng đầu về sơ cứu rắn cắn với 15 năm kinh nghiệm tại bệnh viện Chợ Rẫy. Đam mê bảo tồn động vật hoang dã.',
  );

  String _selectedGender = 'Nam';
  
  // Expertise tags
  final List<String> _allExpertise = ['Rắn độc', 'Y khoa', 'Huyết thanh', 'Cấp cứu', 'Nghiên cứu'];
  final Set<String> _selectedExpertise = {'Rắn độc', 'Y khoa'};
  
  // Languages
  final Map<String, bool> _languages = {
    'Tiếng Việt': true,
    'English': true,
    'Français': false,
  };

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _idCardController.dispose();
    _jobTitleController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F8),
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildAvatarSection(),
              _buildPersonalInfoSection(),
              _buildProfessionalInfoSection(),
              _buildAdditionalInfoSection(),
              _buildBottomButtons(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF131018)),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Chỉnh Sửa Hồ Sơ',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF131018),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saveProfile,
          child: const Text(
            'Lưu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6C47C2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      color: Colors.white,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: const DecorationImage(
                    image: NetworkImage('https://via.placeholder.com/100'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C47C2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thay đổi ảnh - Đang phát triển')),
              );
            },
            child: const Text(
              'Thay Đổi Ảnh Đại Diện',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C47C2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông Tin Cá Nhân',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF131018),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Họ và tên',
            controller: _fullNameController,
            placeholder: 'Nhập họ và tên đầy đủ',
          ),
          const SizedBox(height: 16),
          _buildVerifiedTextField(
            label: 'Số điện thoại',
            controller: _phoneController,
          ),
          const SizedBox(height: 16),
          _buildVerifiedTextField(
            label: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Ngày sinh',
                  controller: _dobController,
                  suffixIcon: Icons.calendar_today,
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime(1980, 1, 1),
                      firstDate: DateTime(1920),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      _dobController.text = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Giới tính',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF131018),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFD8D4E2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedGender,
                          isExpanded: true,
                          icon: const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.arrow_drop_down, color: Color(0xFF999999)),
                          ),
                          items: ['Nam', 'Nữ', 'Khác'].map((gender) {
                            return DropdownMenuItem(
                              value: gender,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Text(gender),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextArea(
            label: 'Địa chỉ',
            controller: _addressController,
            placeholder: 'Nhập địa chỉ của bạn',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildVerifiedTextField(
            label: 'CMND/CCCD',
            controller: _idCardController,
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông Tin Chuyên Môn',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF131018),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Chức danh',
            controller: _jobTitleController,
            placeholder: 'Ví dụ: Tiến sĩ, Bác sĩ, Chuyên gia',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Năm kinh nghiệm',
            controller: _experienceController,
            placeholder: 'Số năm làm việc trong lĩnh vực',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          const Text(
            'Lĩnh vực chuyên môn',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF131018),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allExpertise.map((expertise) {
              final isSelected = _selectedExpertise.contains(expertise);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedExpertise.remove(expertise);
                    } else {
                      _selectedExpertise.add(expertise);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF6C47C2) : Colors.white,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF6C47C2) : const Color(0xFFD8D4E2),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        expertise,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF666666),
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Giới thiệu bản thân',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF131018),
                ),
              ),
              const SizedBox(height: 6),
              Stack(
                children: [
                  TextField(
                    controller: _bioController,
                    maxLines: 5,
                    maxLength: 200,
                    decoration: InputDecoration(
                      hintText: 'Chia sẻ kinh nghiệm và đam mê của bạn...',
                      hintStyle: const TextStyle(color: Color(0xFF999999)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFD8D4E2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFD8D4E2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6C47C2)),
                      ),
                      counterText: '',
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Text(
                      '${_bioController.text.length}/200',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông Tin Bổ Sung',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF131018),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ngôn ngữ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF131018),
            ),
          ),
          const SizedBox(height: 12),
          ..._languages.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _languages[entry.key] = !entry.value;
                  });
                },
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: entry.value ? const Color(0xFF6C47C2) : Colors.white,
                        border: Border.all(
                          color: entry.value ? const Color(0xFF6C47C2) : const Color(0xFFD8D4E2),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: entry.value
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF131018),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C47C2),
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: const Color(0xFF6C47C2).withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Lưu Thay Đổi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              'Hủy',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? placeholder,
    TextInputType? keyboardType,
    IconData? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF131018),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Color(0xFF999999)),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: const Color(0xFF999999), size: 20)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD8D4E2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD8D4E2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6C47C2)),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifiedTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF131018),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            suffixIcon: const Icon(
              Icons.verified,
              color: Color(0xFF10B981),
              size: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD8D4E2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD8D4E2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6C47C2)),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea({
    required String label,
    required TextEditingController controller,
    String? placeholder,
    int maxLines = 3,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF131018),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Color(0xFF999999)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD8D4E2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD8D4E2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6C47C2)),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu thay đổi thành công!')),
      );
      context.pop();
    }
  }
}
