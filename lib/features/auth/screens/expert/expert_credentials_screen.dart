import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../expert/repository/expert_certificate_repository.dart';
import '../../providers/auth_provider.dart';

class ExpertCredentialsScreen extends ConsumerStatefulWidget {
  final Map<String, String> registrationData;

  const ExpertCredentialsScreen({
    super.key,
    required this.registrationData,
  });

  @override
  ConsumerState<ExpertCredentialsScreen> createState() =>
      _ExpertCredentialsScreenState();
}

class _ExpertCredentialsScreenState extends ConsumerState<ExpertCredentialsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _certNameController = TextEditingController();
  final _orgController = TextEditingController();
  DateTime? _issueDate;
  DateTime? _expiryDate;
  
  final List<Map<String, dynamic>> _selectedFiles = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _certNameController.dispose();
    _orgController.dispose();
    super.dispose();
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
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'], // API only accepts image for ReportMedia
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            // Check file size (max 5MB)
            if (file.size > 5 * 1024 * 1024) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('File ${file.name} vượt quá dung lượng 5MB'),
                  backgroundColor: Colors.red,
                ),
              );
              continue;
            }
            
            // Format file size
            String sizeStr;
            if (file.size < 1024 * 1024) {
              sizeStr = '${(file.size / 1024).toStringAsFixed(1)} KB';
            } else {
              sizeStr = '${(file.size / (1024 * 1024)).toStringAsFixed(1)} MB';
            }

            _selectedFiles.add({
              'name': file.name,
              'size': sizeStr,
              'type': file.extension?.toUpperCase() ?? 'FILE',
              'path': file.path,
            });
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chứng chỉ đã được thêm'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text('Lỗi khi chọn file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_issueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày cấp chứng chỉ')),
      );
      return;
    }

    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 file hình ảnh chứng chỉ')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repo = ref.read(expertCertificateRepositoryProvider);
      List<String> mediaIds = [];
      
      // Upload từng file ảnh
      for (var f in _selectedFiles) {
        if (f['path'] != null) {
          final res = await repo.uploadCertificateImage(File(f['path']));
          mediaIds.add(res.id);
        }
      }

      // Tạo chứng chỉ
      await repo.createCertificate(
        certificateName: _certNameController.text.trim(),
        issuingOrganization: _orgController.text.trim(),
        issueDate: _issueDate,
        expiryDate: _expiryDate,
        reportMediaIds: mediaIds,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        final fromLogin = widget.registrationData['fromLogin'] == 'true';
        if (fromLogin) {
          // Nếu đến từ màn hình đăng nhập, nghĩa là account đã có, không cần OTP nữa
          // Chuyển tới màn hình pending luôn vì certificate mới tạo sẽ có status Pending
          context.goNamed('registration_pending', extra: widget.registrationData['email'] ?? '');
        } else {
          // Navigate to OTP verification first
          final result = await context.pushNamed(
            'otp_verification',
            extra: {
              'email': widget.registrationData['email']!,
              'roleRoute': 'expert_login',
              'themeColor': const Color(0xFF9333EA),
            },
          );

          // After OTP verification, navigate to pending screen
          if (mounted && result == null) {
            context.goNamed(
              'registration_pending',
              extra: widget.registrationData['email']!,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () async {
            final fromLogin = widget.registrationData['fromLogin'] == 'true';
            if (fromLogin) {
              // Bắt buộc hủy phiên đăng nhập nếu quay lại từ màn hình yêu cầu nộp chứng chỉ lúc đăng nhập
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.goNamed('role_selection');
              }
            } else if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('expert_registration');
            }
          },
        ),
        title: const Text(
          'Nộp Chứng Chỉ',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      size: 48,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Thông Tin Chứng Chỉ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vui lòng nhập thông tin và tải lên hình ảnh chứng chỉ chuyên môn của bạn.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Certificate Name
                      TextFormField(
                        controller: _certNameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên chứng chỉ *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập tên chứng chỉ' : null,
                      ),
                      const SizedBox(height: 16),

                      // Issuing Organization
                      TextFormField(
                        controller: _orgController,
                        decoration: const InputDecoration(
                          labelText: 'Tổ chức cấp *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập tổ chức cấp' : null,
                      ),
                      const SizedBox(height: 16),

                      // Issue Date
                      InkWell(
                        onTap: _pickIssueDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Ngày cấp *',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _issueDate != null ? DateFormat('dd/MM/yyyy').format(_issueDate!) : 'Chọn ngày',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Expiry Date
                      InkWell(
                        onTap: _pickExpiryDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Ngày hết hạn (không bắt buộc)',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _expiryDate != null ? DateFormat('dd/MM/yyyy').format(_expiryDate!) : 'Chọn ngày (nếu có)',
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Accepted file types
                      Container(
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
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Upload area
                      InkWell(
                        onTap: _pickFiles,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 48,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Nhấn để chọn hình ảnh chứng chỉ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Hỗ trợ tải lên nhiều ảnh',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Files list preview
                      if (_selectedFiles.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Hình ảnh đã chọn:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '${_selectedFiles.length} ảnh',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
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
                                  // Image Preview
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(11),
                                    child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      color: Colors.grey.shade100, // Background for contain
                                      child: file['path'] != null 
                                          ? Image.file(
                                              File(file['path']),
                                              fit: BoxFit.contain,
                                            )
                                          : Container(
                                              color: Colors.grey.shade200,
                                              child: Icon(Icons.image, color: Colors.grey.shade400, size: 40),
                                            ),
                                    ),
                                  ),
                                  // Gradient Overlay at bottom for text readability
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.8),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                      padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            file['name'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            file['size'],
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.8),
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Remove Button
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeFile(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Continue button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Hoàn Thành Nộp Chứng Chỉ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
