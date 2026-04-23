import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../expert/repository/expert_certificate_repository.dart';

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
      setState(() => _issueDate = picked);
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
      setState(() => _expiryDate = picked);
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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              final fromLogin = widget.registrationData['fromLogin'] == 'true';
              if (fromLogin) {
                context.goNamed('expert_login');
              } else {
                context.goNamed('expert_registration');
              }
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

                      // Upload button
                      OutlinedButton.icon(
                        onPressed: _pickFiles,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Chọn Hình Ảnh Chứng Chỉ'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Files list
                      if (_selectedFiles.isNotEmpty) ...[
                        const Text(
                          'Hình ảnh đã chọn:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _selectedFiles.length,
                          itemBuilder: (context, index) {
                            final file = _selectedFiles[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                  child: Icon(
                                    Icons.image,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                title: Text(
                                  file['name'],
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text('${file['type']} • ${file['size']}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () => _removeFile(index),
                                ),
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
