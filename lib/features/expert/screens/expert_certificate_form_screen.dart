import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/expert_certificate.dart';
import '../repository/expert_certificate_repository.dart';

class ExpertCertificateFormScreen extends ConsumerStatefulWidget {
  final String? certificateId;

  const ExpertCertificateFormScreen({
    super.key,
    this.certificateId,
  });

  @override
  ConsumerState<ExpertCertificateFormScreen> createState() =>
      _ExpertCertificateFormScreenState();
}

class _ExpertCertificateFormScreenState
    extends ConsumerState<ExpertCertificateFormScreen> {
  final _nameController = TextEditingController();
  final _orgController = TextEditingController();
  final _picker = ImagePicker();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  DateTime? _issueDate;
  DateTime? _expiryDate;
  File? _localImage;
  ExpertCertificate? _certificate;

  bool get _isEdit => widget.certificateId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetail());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orgController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = ref.read(expertCertificateRepositoryProvider);
      final certificate = await repo.getCertificate(widget.certificateId!);
      if (!mounted) return;
      setState(() {
        _certificate = certificate;
        _nameController.text = certificate.certificateName;
        _orgController.text = certificate.issuingOrganization;
        _issueDate = certificate.issueDate;
        _expiryDate = certificate.expiryDate;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (file == null) return;
      if (!mounted) return;
      setState(() {
        _localImage = File(file.path);
      });
    } catch (_) {
      // Ignore picker errors (permissions or unavailable source)
    }
  }

  void _showAttachMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAttachOption(
                icon: Icons.photo_library_outlined,
                label: 'Thư viện',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              _buildAttachOption(
                icon: Icons.camera_alt_outlined,
                label: 'Chụp ảnh',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF6C47C2), size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate({required bool isIssueDate}) async {
    final initialDate = (isIssueDate ? _issueDate : _expiryDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1990),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    setState(() {
      if (isIssueDate) {
        _issueDate = picked;
      } else {
        _expiryDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final org = _orgController.text.trim();

    if (name.isEmpty || org.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ thông tin bắt buộc')),
      );
      return;
    }

    if (_localImage == null && (_certificate?.reportMediaFiles.isEmpty ?? true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng tải lên ảnh chứng chỉ')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(expertCertificateRepositoryProvider);
      List<String> mediaIds = [];

      if (_localImage != null) {
        final media = await repo.uploadCertificateImage(_localImage!);
        mediaIds = [media.id];
      } else {
        mediaIds = _certificate?.reportMediaFiles
                .map((item) => item.id)
                .where((id) => id.isNotEmpty)
                .toList() ??
            [];
      }

      if (_isEdit) {
        await repo.updateCertificate(
          certificateId: widget.certificateId!,
          certificateName: name,
          issuingOrganization: org,
          issueDate: _issueDate,
          expiryDate: _expiryDate,
          reportMediaIds: mediaIds,
        );
      } else {
        await repo.createCertificate(
          certificateName: name,
          issuingOrganization: org,
          issueDate: _issueDate,
          expiryDate: _expiryDate,
          reportMediaIds: mediaIds,
        );
      }

      if (!mounted) return;
      context.pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Đã cập nhật chứng chỉ' : 'Đã tạo chứng chỉ'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6F8),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF131018)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEdit ? 'Cập Nhật Chứng Chỉ' : 'Thêm Chứng Chỉ',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF131018),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildInputCard(),
                    const SizedBox(height: 16),
                    _buildImagePicker(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                  ],
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Không thể tải chứng chỉ',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C47C2),
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin chứng chỉ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF131018),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Tên chứng chỉ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _orgController,
            decoration: const InputDecoration(
              labelText: 'Đơn vị cấp',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          _buildDateField(
            label: 'Ngày cấp',
            value: _issueDate,
            onTap: () => _selectDate(isIssueDate: true),
          ),
          const SizedBox(height: 12),
          _buildDateField(
            label: 'Ngày hết hạn (không bắt buộc)',
            value: _expiryDate,
            onTap: () => _selectDate(isIssueDate: false),
            allowClear: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    bool allowClear = false,
  }) {
    final text = value == null ? 'Chọn ngày' : DateFormat('dd/MM/yyyy').format(value);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: allowClear && value != null
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _expiryDate = null),
                )
              : const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildImagePicker() {
    final previewUrl = _certificate?.primaryMediaUrl;
    final hasImage = _localImage != null || previewUrl != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ảnh chứng chỉ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF131018),
            ),
          ),
          const SizedBox(height: 12),
          if (hasImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _localImage != null
                  ? Image.file(
                      _localImage!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      previewUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: const Color(0xFFF2F2F2),
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
            )
          else
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: const Center(
                child: Text(
                  'Chưa có ảnh chứng chỉ',
                  style: TextStyle(color: Color(0xFF888888)),
                ),
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _showAttachMenu,
            icon: const Icon(Icons.upload_file),
            label: Text(_localImage != null || previewUrl != null
                ? 'Thay ảnh chứng chỉ'
                : 'Tải ảnh chứng chỉ'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6C47C2),
              side: const BorderSide(color: Color(0xFF6C47C2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C47C2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(_isEdit ? 'Cập nhật' : 'Tạo chứng chỉ'),
      ),
    );
  }
}
