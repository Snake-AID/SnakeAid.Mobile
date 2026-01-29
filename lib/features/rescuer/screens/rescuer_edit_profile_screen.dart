import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Rescuer Edit Profile Screen - Edit rescuer personal and professional information
/// Màn hình chỉnh sửa hồ sơ của Rescuer
class RescuerEditProfileScreen extends StatefulWidget {
  const RescuerEditProfileScreen({super.key});

  @override
  State<RescuerEditProfileScreen> createState() => _RescuerEditProfileScreenState();
}

class _RescuerEditProfileScreenState extends State<RescuerEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Text Controllers
  final _fullNameController = TextEditingController(text: 'Nguyễn Văn A');
  final _phoneController = TextEditingController(text: '0901234567');
  final _emailController = TextEditingController();
  final _birthDateController = TextEditingController(text: '20/05/1990');
  final _addressController = TextEditingController(text: '123 Đường ABC, Phường XYZ, Quận 1, TP. Hồ Chí Minh');
  final _idNumberController = TextEditingController(text: '0123456789');
  final _bioController = TextEditingController();

  // State Variables
  String _selectedGender = 'Nam';
  String _selectedExperience = '3-5 năm';
  String _selectedProvince = 'TP. Hồ Chí Minh';
  double _activityRadius = 20.0;
  
  final List<String> _selectedSpecialties = ['Rắn độc', 'Rắn cỡ lớn', 'Rắn nước', 'Tất cả các loài'];
  final List<String> _selectedDistricts = ['Quận 1', 'Quận 3', 'Quận 5', 'Quận 10'];
  
  // Schedule: [Morning, Afternoon, Evening, Night] for each day [Mon-Sun]
  final List<List<bool>> _schedule = [
    [true, true, false, true],  // Monday
    [false, true, true, false], // Tuesday
    [true, true, false, true],  // Wednesday
    [false, true, true, false], // Thursday
    [true, false, true, false], // Friday
    [false, true, false, true], // Saturday
    [false, true, true, true],  // Sunday
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _idNumberController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 5, 20),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF8800),
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // Handle image upload
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ảnh đã được chọn')),
      );
    }
  }

  Future<void> _uploadIdDocument() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // Handle ID document upload
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã tải lên ảnh CMND/CCCD')),
      );
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // Save profile changes
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu thay đổi thành công')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 32),
              _buildAvatarSection(),
              const SizedBox(height: 4),
              const Text(
                'Chạm để thay đổi ảnh',
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              _buildPersonalInfoSection(),
              _buildProfessionalInfoSection(),
              _buildWorkingAreaSection(),
              _buildScheduleSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F7F5).withOpacity(0.8),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF231A0F)),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Chỉnh Sửa Hồ Sơ',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF231A0F),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextButton(
            onPressed: _saveChanges,
            child: const Text(
              'Lưu',
              style: TextStyle(
                color: Color(0xFFFF8800),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFF8800),
                width: 2,
              ),
              image: const DecorationImage(
                image: NetworkImage('https://via.placeholder.com/128'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF666666),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_camera,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFFFF8800),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông Tin Cá Nhân',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF231A0F),
            ),
          ),
          const SizedBox(height: 16),
          
          // Full Name
          _buildTextField(
            label: 'Họ và Tên',
            controller: _fullNameController,
            required: true,
          ),
          const SizedBox(height: 16),
          
          // Phone (Disabled)
          _buildDisabledField(
            label: 'Số Điện Thoại',
            value: _phoneController.text,
            verified: true,
          ),
          const SizedBox(height: 16),
          
          // Email
          _buildTextField(
            label: 'Email',
            controller: _emailController,
            hintText: 'nguyenvana@email.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          
          // Birth Date
          _buildDateField(),
          const SizedBox(height: 16),
          
          // Gender
          _buildGenderField(),
          const SizedBox(height: 16),
          
          // Address
          _buildTextAreaField(
            label: 'Địa Chỉ',
            controller: _addressController,
            hintText: 'Nhập địa chỉ của bạn',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          
          // ID Number
          _buildIdNumberField(),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông Tin Chuyên Môn',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF231A0F),
            ),
          ),
          const SizedBox(height: 16),
          
          // Experience
          _buildDropdownField(
            label: 'Kinh Nghiệm',
            value: _selectedExperience,
            items: ['Dưới 1 năm', '1-3 năm', '3-5 năm', 'Trên 5 năm'],
            onChanged: (value) {
              setState(() {
                _selectedExperience = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Specialties
          _buildSpecialtiesField(),
          const SizedBox(height: 16),
          
          // Bio
          _buildTextAreaField(
            label: 'Mô Tả Bản Thân',
            controller: _bioController,
            hintText: 'Giới thiệu ngắn về kinh nghiệm và kỹ năng của bạn...',
            maxLines: 3,
            maxLength: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingAreaSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Khu Vực Hoạt Động',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF231A0F),
            ),
          ),
          const SizedBox(height: 16),
          
          // Province
          _buildDropdownField(
            label: 'Tỉnh/Thành Phố',
            value: _selectedProvince,
            items: ['TP. Hồ Chí Minh', 'Hà Nội', 'Đà Nẵng'],
            onChanged: (value) {
              setState(() {
                _selectedProvince = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Districts
          _buildDistrictsField(),
          const SizedBox(height: 16),
          
          // Activity Radius
          _buildRadiusSlider(),
          const SizedBox(height: 16),
          
          // Map Preview
          _buildMapPreview(),
        ],
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lịch Làm Việc',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF231A0F),
            ),
          ),
          const SizedBox(height: 16),
          _buildScheduleGrid(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF231A0F),
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF999999)),
            filled: true,
            fillColor: const Color(0xFFF8F7F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(color: Color(0xFFFF8800), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập $label';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDisabledField({
    required String label,
    required String value,
    bool verified = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF231A0F),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E5E5),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFCCCCCC)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                ),
              ),
              if (verified)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ngày Sinh',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF231A0F),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _birthDateController,
          readOnly: true,
          onTap: () => _selectDate(context),
          decoration: InputDecoration(
            hintText: 'DD/MM/YYYY',
            hintStyle: const TextStyle(color: Color(0xFF999999)),
            filled: true,
            fillColor: const Color(0xFFF8F7F5),
            suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFFFF8800)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(color: Color(0xFFFF8800), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giới Tính',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF231A0F),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildRadioOption('Nam'),
            const SizedBox(width: 16),
            _buildRadioOption('Nữ'),
            const SizedBox(width: 16),
            _buildRadioOption('Khác'),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioOption(String value) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedGender = value;
          });
        },
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedGender,
              onChanged: (val) {
                setState(() {
                  _selectedGender = val!;
                });
              },
              activeColor: const Color(0xFFFF8800),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF231A0F),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextAreaField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    int maxLines = 3,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF231A0F),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF999999)),
            filled: true,
            fillColor: const Color(0xFFF8F7F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF8800), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildIdNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CMND/CCCD',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF231A0F),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _idNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Nhập số CMND/CCCD',
                  hintStyle: const TextStyle(color: Color(0xFF999999)),
                  filled: true,
                  fillColor: const Color(0xFFF8F7F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: Color(0xFFFF8800), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _uploadIdDocument,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8800).withOpacity(0.2),
                foregroundColor: const Color(0xFFFF8800),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Upload ảnh',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF231A0F),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F7F5),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFDDDDDD)),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            icon: const Icon(Icons.expand_more, color: Color(0xFF666666)),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialtiesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chuyên Môn',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF231A0F),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedSpecialties.map((specialty) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8800).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                specialty,
                style: const TextStyle(
                  color: Color(0xFFFF8800),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDistrictsField() {
    final allDistricts = [
      'Quận 1', 'Quận 3', 'Quận 4', 'Quận 5', 'Quận 10', 'Quận Tân Bình'
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quận/Huyện',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF231A0F),
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 16,
          children: allDistricts.map((district) {
            final isSelected = _selectedDistricts.contains(district);
            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedDistricts.remove(district);
                  } else {
                    _selectedDistricts.add(district);
                  }
                });
              },
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedDistricts.add(district);
                        } else {
                          _selectedDistricts.remove(district);
                        }
                      });
                    },
                    activeColor: const Color(0xFFFF8800),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      district,
                      style: const TextStyle(
                        color: Color(0xFF231A0F),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRadiusSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bán Kính Hoạt Động',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF231A0F),
              ),
            ),
            Text(
              '${_activityRadius.round()}km',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF8800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFFFF8800),
            inactiveTrackColor: const Color(0xFFDDDDDD),
            thumbColor: const Color(0xFFFF8800),
            overlayColor: const Color(0xFFFF8800).withOpacity(0.2),
            trackHeight: 8,
          ),
          child: Slider(
            value: _activityRadius,
            min: 5,
            max: 50,
            divisions: 45,
            onChanged: (value) {
              setState(() {
                _activityRadius = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMapPreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Placeholder for map
            Container(
              color: const Color(0xFFE5E5E5),
              child: const Center(
                child: Icon(
                  Icons.map,
                  size: 64,
                  color: Color(0xFF999999),
                ),
              ),
            ),
            // You can integrate Google Maps here
            // Example: GoogleMap(...)
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleGrid() {
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final timeSlots = ['Sáng', 'Chiều', 'Tối', 'Đêm'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Header Row
          Row(
            children: [
              const SizedBox(width: 60), // Space for time slot labels
              ...days.map((day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 8),
          
          // Schedule Grid
          ...List.generate(timeSlots.length, (timeIndex) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  // Time Slot Label
                  SizedBox(
                    width: 60,
                    child: Text(
                      timeSlots[timeIndex],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF666666),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 4),
                  
                  // Day Cells
                  ...List.generate(7, (dayIndex) {
                    final isSelected = _schedule[dayIndex][timeIndex];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _schedule[dayIndex][timeIndex] = !isSelected;
                          });
                        },
                        child: Container(
                          height: 44,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFF8800)
                                : const Color(0xFFE5E5E5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F5),
        border: const Border(
          top: BorderSide(color: Color(0xFFDDDDDD)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8800),
                    foregroundColor: Colors.white,
                    elevation: 0,
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
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text(
                  'Hủy',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
