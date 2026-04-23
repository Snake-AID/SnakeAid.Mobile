import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _orgController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  DateTime? _issueDate;
  DateTime? _expiryDate;
  ExpertCertificate? _certificate;
  
  final List<Map<String, dynamic>> _selectedFiles = [];

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
        
        _selectedFiles.clear();
        for (var media in certificate.reportMediaFiles) {
          if (media.id.isNotEmpty) {
            _selectedFiles.add({
              'id': media.id,
              'url': media.mediaUrl,
              'name': 'Ảnh đính kèm',
              'size': '',
              'type': 'IMAGE',
            });
          }
        }
        
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

  void _pickIssueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _issueDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      // Ép về múi giờ UTC để tránh bị lùi ngày do chênh lệch +7 khi gửi lên server
      setState(() => _issueDate = DateTime.utc(picked.year, picked.month, picked.day));
    }
  }

  void _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      // Ép về múi giờ UTC để tránh bị lùi ngày
      setState(() => _expiryDate = DateTime.utc(picked.year, picked.month, picked.day));
    }
  }

  void _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            if (file.size > 5 * 1024 * 1024) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('File ${file.name} vượt quá 5MB'),
                  backgroundColor: Colors.red,
                ),
              );
              continue;
            }
            
            String sizeStr = file.size < 1024 * 1024
                ? '${(file.size / 1024).toStringAsFixed(1)} KB'
                : '${(file.size / (1024 * 1024)).toStringAsFixed(1)} MB';

            _selectedFiles.add({
              'name': file.name,
              'size': sizeStr,
              'type': file.extension?.toUpperCase() ?? 'FILE',
              'path': file.path,
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi chọn file: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() => _selectedFiles.removeAt(index));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_issueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày cấp')),
      );
      return;
    }

    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 ảnh chứng chỉ')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(expertCertificateRepositoryProvider);
      List<String> mediaIds = [];

      for (var f in _selectedFiles) {
        if (f['path'] != null) {
          final media = await repo.uploadCertificateImage(File(f['path']));
          mediaIds.add(media.id);
        } else if (f['id'] != null) {
          mediaIds.add(f['id']);
        }
      }

      if (_isEdit) {
        await repo.updateCertificate(
          certificateId: widget.certificateId!,
          certificateName: _nameController.text.trim(),
          issuingOrganization: _orgController.text.trim(),
          issueDate: _issueDate,
          expiryDate: _expiryDate,
          reportMediaIds: mediaIds,
        );
      } else {
        await repo.createCertificate(
          certificateName: _nameController.text.trim(),
          issuingOrganization: _orgController.text.trim(),
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
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEdit ? 'Cập Nhật Chứng Chỉ' : 'Thêm Chứng Chỉ',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInfoBanner(),
                        const SizedBox(height: 24),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildTextField(
                                  controller: _nameController,
                                  label: 'Tên chứng chỉ *',
                                  errorMsg: 'Vui lòng nhập tên chứng chỉ',
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _orgController,
                                  label: 'Tổ chức cấp *',
                                  errorMsg: 'Vui lòng nhập tổ chức cấp',
                                ),
                                const SizedBox(height: 16),
                                _buildDatePicker(
                                  label: 'Ngày cấp *',
                                  date: _issueDate,
                                  onTap: _pickIssueDate,
                                ),
                                const SizedBox(height: 16),
                                _buildDatePicker(
                                  label: 'Ngày hết hạn (không bắt buộc)',
                                  date: _expiryDate,
                                  onTap: _pickExpiryDate,
                                  isOptional: true,
                                ),
                                const SizedBox(height: 24),
                                _buildFileRulesBanner(),
                                const SizedBox(height: 16),
                                _buildUploadArea(),
                                const SizedBox(height: 24),
                                if (_selectedFiles.isNotEmpty) _buildImageGrid(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
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
            Text(_error ?? 'Lỗi', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDetail,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C47C2)),
              child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.verified_outlined, size: 48, color: Theme.of(context).primaryColor),
          const SizedBox(height: 16),
          const Text(
            'Thông Tin Chứng Chỉ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng nhập thông tin và tải lên hình ảnh chứng chỉ chuyên môn của bạn.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required String errorMsg}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (v) => v == null || v.isEmpty ? errorMsg : null,
    );
  }

  Widget _buildDatePicker({required String label, required DateTime? date, required VoidCallback onTap, bool isOptional = false}) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: isOptional && date != null
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => setState(() => _expiryDate = null),
              )
            : const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(date != null ? DateFormat('dd/MM/yyyy').format(date) : (isOptional ? 'Chọn ngày (nếu có)' : 'Chọn ngày')),
      ),
    );
  }

  Widget _buildFileRulesBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Chấp nhận hình ảnh: JPG, PNG, GIF, WEBP (tối đa 5MB)',
              style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea() {
    return InkWell(
      onTap: _pickFiles,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3), width: 2),
        ),
        child: Column(
          children: [
            Icon(Icons.cloud_upload_outlined, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 12),
            Text(
              'Nhấn để chọn hình ảnh chứng chỉ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 4),
            Text(
              'Hỗ trợ tải lên nhiều ảnh',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Hình ảnh đã chọn:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            Text(
              '${_selectedFiles.length} ảnh',
              style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: _selectedFiles.length,
          itemBuilder: (context, index) {
            final file = _selectedFiles[index];
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.grey.shade100,
                      child: file['path'] != null 
                          ? Image.file(File(file['path']), fit: BoxFit.contain)
                          : file['url'] != null
                              ? Image.network(file['url'], fit: BoxFit.contain)
                              : Container(
                                  color: Colors.grey.shade200,
                                  child: Icon(Icons.image, color: Colors.grey.shade400, size: 40),
                                ),
                    ),
                  ),
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file['name'],
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          if (file['size'] != '') ...[
                            const SizedBox(height: 2),
                            Text(
                              file['size'],
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4, right: 4,
                    child: GestureDetector(
                      onTap: () => _removeFile(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20, width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              )
            : Text(
                _isEdit ? 'Cập Nhật Chứng Chỉ' : 'Hoàn Thành Nộp Chứng Chỉ',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }
}

