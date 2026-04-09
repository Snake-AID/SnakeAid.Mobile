import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../models/rescuer_profile.dart';
import '../repository/rescuer_profile_repository.dart';

/// Rescuer Edit Profile Screen - Edit rescuer personal and professional information
/// Màn hình chỉnh sửa hồ sơ của Rescuer
class RescuerEditProfileScreen extends ConsumerStatefulWidget {
  const RescuerEditProfileScreen({super.key});

  @override
  ConsumerState<RescuerEditProfileScreen> createState() => _RescuerEditProfileScreenState();
}

class _RescuerEditProfileScreenState extends ConsumerState<RescuerEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Profile state
  RescuerProfile? _loadedProfile;
  bool _isLoading = true;
  bool _isSaving = false;

  // Avatar state
  File? _pickedImageFile;
  String? _newAvatarUrl;
  bool _isUploadingAvatar = false;

  // Text Controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ref.read(rescuerProfileRepositoryProvider).getMyProfile();
      if (mounted && profile != null) {
        setState(() {
          _loadedProfile = profile;
          _fullNameController.text = profile.fullName;
          _phoneController.text = profile.phoneNumber ?? '';
          _emailController.text = profile.email ?? '';
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
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
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (xFile == null || !mounted) return;
    setState(() {
      _pickedImageFile = File(xFile.path);
      _isUploadingAvatar = true;
    });
    try {
      final url = await ref.read(rescuerProfileRepositoryProvider).uploadAvatar(_pickedImageFile!);
      if (mounted) setState(() => _newAvatarUrl = url);
    } catch (e) {
      if (mounted) {
        setState(() => _pickedImageFile = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tải ảnh thất bại: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(rescuerProfileRepositoryProvider).updateMyProfile(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        avatarUrl: _newAvatarUrl ?? _loadedProfile?.avatarUrl,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu thay đổi thành công')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F7F5),
        body: Center(child: CircularProgressIndicator()),
      );
    }
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
            onPressed: _isSaving ? null : _saveChanges,
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
      onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
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
            ),
            child: ClipOval(
              child: _pickedImageFile != null
                  ? Image.file(_pickedImageFile!, fit: BoxFit.cover)
                  : (_newAvatarUrl ?? _loadedProfile?.avatarUrl)?.isNotEmpty == true
                      ? Image.network(
                          _newAvatarUrl ?? _loadedProfile!.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFFF8800).withOpacity(0.1),
                            child: const Icon(Icons.person, size: 60, color: Color(0xFFFF8800)),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFFF8800).withOpacity(0.1),
                          child: const Icon(Icons.person, size: 60, color: Color(0xFFFF8800)),
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
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ),
                  ),
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
          
          // Email (read-only — not in PUT body)
          _buildDisabledField(
            label: 'Email',
            value: _emailController.text,
          ),
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
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8800),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
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
