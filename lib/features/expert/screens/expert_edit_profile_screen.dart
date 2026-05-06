import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../models/expert_profile.dart';
import '../repository/expert_profile_repository.dart';

/// Expert Edit Profile Screen - Update expert profile information
/// Màn hình chỉnh sửa hồ sơ Chuyên gia
class ExpertEditProfileScreen extends ConsumerStatefulWidget {
  const ExpertEditProfileScreen({super.key});

  @override
  ConsumerState<ExpertEditProfileScreen> createState() =>
      _ExpertEditProfileScreenState();
}

class _ExpertEditProfileScreenState
    extends ConsumerState<ExpertEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Profile state
  ExpertProfile? _loadedProfile;
  bool _isLoading = true;
  bool _isSaving = false;

  // Avatar state
  File? _pickedImageFile;
  String? _newAvatarUrl;
  bool _isUploadingAvatar = false;

  // Fee controllers
  final _scheduledFeeController = TextEditingController();
  final _emergencyFeeController = TextEditingController();

  // Controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ref
          .read(expertProfileRepositoryProvider)
          .getMyProfile();
      if (mounted) {
        setState(() {
          _loadedProfile = profile;
          _fullNameController.text = profile.fullName;
          _phoneController.text = profile.phoneNumber ?? '';
          _emailController.text = profile.email ?? '';
          _bioController.text = profile.biography ?? '';
          _scheduledFeeController.text =
              profile.scheduledConsultationFee?.toStringAsFixed(0) ?? '';
          _emergencyFeeController.text =
              profile.emergencyConsultationFee?.toStringAsFixed(0) ?? '';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _scheduledFeeController.dispose();
    _emergencyFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F6F8),
        body: Center(child: CircularProgressIndicator()),
      );
    }
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
          GestureDetector(
            onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
            child: Stack(
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
                  ),
                  child: ClipOval(
                    child: _pickedImageFile != null
                        ? Image.file(_pickedImageFile!, fit: BoxFit.cover)
                        : (_newAvatarUrl ?? _loadedProfile?.avatarUrl)
                                  ?.isNotEmpty ==
                              true
                        ? Image.network(
                            _newAvatarUrl ?? _loadedProfile!.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFF6C47C2).withOpacity(0.1),
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: Color(0xFF6C47C2),
                              ),
                            ),
                          )
                        : Container(
                            color: const Color(0xFF6C47C2).withOpacity(0.1),
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Color(0xFF6C47C2),
                            ),
                          ),
                  ),
                ),
                if (_isUploadingAvatar)
                  Positioned.fill(
                    child: ClipOval(
                      child: ColoredBox(
                        color: const Color(0x80000000),
                        child: Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
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
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isUploadingAvatar ? null : _pickAndUploadAvatar,
            child: _isUploadingAvatar
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF6C47C2),
                    ),
                  )
                : const Text(
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
          const SizedBox(height: 16),
          // Consultation Fees
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Phí tư vấn (VNĐ)',
                  controller: _scheduledFeeController,
                  placeholder: 'Ví dụ: 250000',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: 'Phí khẩn cấp (VNĐ)',
                  controller: _emergencyFeeController,
                  placeholder: 'Để trống = giống phí tư vấn',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
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
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C47C2),
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: const Color(0xFF6C47C2).withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
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

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (xFile == null || !mounted) return;
    setState(() {
      _pickedImageFile = File(xFile.path);
      _isUploadingAvatar = true;
    });
    try {
      final url = await ref
          .read(expertProfileRepositoryProvider)
          .uploadAvatar(_pickedImageFile!);
      if (mounted) setState(() => _newAvatarUrl = url);
    } catch (e) {
      if (mounted) {
        setState(() => _pickedImageFile = null);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Tải ảnh thất bại: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final scheduled =
            double.tryParse(
              _scheduledFeeController.text.replaceAll(',', '').trim(),
            ) ??
            0;
        final emergency = _emergencyFeeController.text.trim().isEmpty
            ? null
            : double.tryParse(
                _emergencyFeeController.text.replaceAll(',', '').trim(),
              );
        await ref
            .read(expertProfileRepositoryProvider)
            .updateMyProfile(
              fullName: _fullNameController.text.trim(),
              phoneNumber: _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
              avatarUrl: _newAvatarUrl ?? _loadedProfile?.avatarUrl,
              biography: _bioController.text.trim(),
              scheduledConsultationFee: scheduled,
              emergencyConsultationFee: emergency,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã lưu thay đổi thành công!')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lưu thất bại: $e')));
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }
}
