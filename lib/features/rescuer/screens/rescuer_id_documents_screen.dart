import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Rescuer ID Documents Screen - Manage personal documents for rescuers
/// Màn hình giấy tờ tùy thân cho Rescuer
class RescuerIdDocumentsScreen extends StatefulWidget {
  const RescuerIdDocumentsScreen({super.key});

  @override
  State<RescuerIdDocumentsScreen> createState() => _RescuerIdDocumentsScreenState();
}

class _RescuerIdDocumentsScreenState extends State<RescuerIdDocumentsScreen> {
  final List<DocumentItem> _documents = [
    DocumentItem(
      type: 'CMND/CCCD',
      number: '001234567890',
      issueDate: '15/03/2020',
      expiryDate: 'Vô thời hạn',
      status: DocumentStatus.verified,
      frontImageUrl: 'https://via.placeholder.com/400x250/FF8800/FFFFFF?text=CCCD+Front',
      backImageUrl: 'https://via.placeholder.com/400x250/FF8800/FFFFFF?text=CCCD+Back',
    ),
    DocumentItem(
      type: 'BHYT',
      number: 'VN0123456789',
      issueDate: '01/01/2026',
      expiryDate: '31/12/2026',
      status: DocumentStatus.verified,
      frontImageUrl: 'https://via.placeholder.com/400x250/1E88E5/FFFFFF?text=BHYT',
    ),
    DocumentItem(
      type: 'Bằng lái xe',
      number: 'B2-123456',
      issueDate: '10/05/2022',
      expiryDate: '10/05/2032',
      status: DocumentStatus.pending,
      frontImageUrl: 'https://via.placeholder.com/400x250/FFA726/FFFFFF?text=Driving+License',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F5),
        elevation: 0,
        centerTitle: true,
        leading: canPop ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1D150C)),
          onPressed: () => context.pop(),
        ) : null,
        automaticallyImplyLeading: canPop,
        title: const Text(
          'Chứng Chỉ & Giấy Tờ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D150C),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFFF8800)),
            onPressed: _addDocument,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Info Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFF8800).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: const Color(0xFFFF8800),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: const Text(
                        'Giấy tờ của bạn được mã hóa và bảo mật. Admin sẽ xác minh trong vòng 24h.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1D150C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Documents List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: _documents
                    .map(
                      (doc) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _DocumentCard(
                          document: doc,
                          onTap: () => _viewDocument(doc),
                          onEdit: () => _editDocument(doc),
                          onDelete: () => _deleteDocument(doc),
                          onUpload: () => _uploadDocument(doc),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
      // Bottom Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
                Text(
                  '${_documents.length} giấy tờ đã lưu',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addDocument,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8800),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Thêm Giấy Tờ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addDocument() {
    showDialog(
      context: context,
      builder: (context) => _AddDocumentDialog(
        onSave: (document) {
          setState(() {
            _documents.add(document);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã thêm ${document.type}')),
          );
        },
      ),
    );
  }

  void _viewDocument(DocumentItem document) {
    showDialog(
      context: context,
      builder: (context) => _DocumentDetailDialog(document: document),
    );
  }

  void _editDocument(DocumentItem document) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chỉnh sửa ${document.type} - Đang phát triển')),
    );
  }

  void _deleteDocument(DocumentItem document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Xóa giấy tờ'),
        content: Text('Bạn có chắc muốn xóa ${document.type}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Hủy',
              style: TextStyle(color: Color(0xFF666666)),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _documents.remove(document);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa ${document.type}')),
              );
            },
            child: const Text(
              'Xóa',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }

  void _uploadDocument(DocumentItem document) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Upload ${document.type} - Đang phát triển')),
    );
  }
}

enum DocumentStatus {
  verified,
  pending,
  rejected,
}

class DocumentItem {
  final String type;
  final String number;
  final String issueDate;
  final String expiryDate;
  final DocumentStatus status;
  final String? frontImageUrl;
  final String? backImageUrl;
  final String? rejectionReason;

  DocumentItem({
    required this.type,
    required this.number,
    required this.issueDate,
    required this.expiryDate,
    required this.status,
    this.frontImageUrl,
    this.backImageUrl,
    this.rejectionReason,
  });
}

class _DocumentCard extends StatelessWidget {
  final DocumentItem document;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onUpload;

  const _DocumentCard({
    required this.document,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getDocumentIcon(),
                    color: _getStatusColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Document Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              document.type,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D150C),
                              ),
                            ),
                          ),
                          _StatusBadge(status: document.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Số: ${document.number}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFE5E5E5)),
            const SizedBox(height: 12),
            // Document Details
            Row(
              children: [
                Expanded(
                  child: _DetailItem(
                    label: 'Ngày cấp',
                    value: document.issueDate,
                    icon: Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _DetailItem(
                    label: 'Hết hạn',
                    value: document.expiryDate,
                    icon: Icons.event_available,
                  ),
                ),
              ],
            ),
            // Rejection Reason (if rejected)
            if (document.status == DocumentStatus.rejected && document.rejectionReason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lý do từ chối: ${document.rejectionReason}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.remove_red_eye, size: 16),
                    label: const Text('Xem'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF8800),
                      side: const BorderSide(color: Color(0xFFFF8800)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (document.status == DocumentStatus.rejected ||
                    document.frontImageUrl == null) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onUpload,
                      icon: const Icon(Icons.upload, size: 16),
                      label: Text(document.frontImageUrl == null ? 'Upload' : 'Re-upload'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8800),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Sửa'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF666666),
                      side: const BorderSide(color: Color(0xFFE5E5E5)),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(40, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.delete, size: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (document.status) {
      case DocumentStatus.verified:
        return const Color(0xFF10B981);
      case DocumentStatus.pending:
        return const Color(0xFFF59E0B);
      case DocumentStatus.rejected:
        return const Color(0xFFEF4444);
    }
  }

  IconData _getDocumentIcon() {
    if (document.type.contains('CMND') || document.type.contains('CCCD')) {
      return Icons.badge;
    } else if (document.type.contains('BHYT')) {
      return Icons.medical_information;
    } else if (document.type.contains('lái xe')) {
      return Icons.directions_car;
    }
    return Icons.description;
  }
}

class _StatusBadge extends StatelessWidget {
  final DocumentStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;
    IconData? icon;

    switch (status) {
      case DocumentStatus.verified:
        text = 'Đã xác minh';
        color = const Color(0xFF10B981);
        icon = Icons.verified;
        break;
      case DocumentStatus.pending:
        text = 'Chờ xác minh';
        color = const Color(0xFFF59E0B);
        icon = Icons.schedule;
        break;
      case DocumentStatus.rejected:
        text = 'Bị từ chối';
        color = const Color(0xFFEF4444);
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF666666)),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF666666),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D150C),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddDocumentDialog extends StatefulWidget {
  final Function(DocumentItem) onSave;

  const _AddDocumentDialog({required this.onSave});

  @override
  State<_AddDocumentDialog> createState() => _AddDocumentDialogState();
}

class _AddDocumentDialogState extends State<_AddDocumentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _issueDateController = TextEditingController();
  final _expiryDateController = TextEditingController();
  
  String _selectedType = 'CMND/CCCD';
  
  final List<String> _documentTypes = [
    'CMND/CCCD',
    'BHYT',
    'Hộ chiếu',
    'Giấy khai sinh',
    'Bằng lái xe',
    'Chứng chỉ nghề nghiệp',
    'Giấy phép kinh doanh',
  ];

  @override
  void dispose() {
    _numberController.dispose();
    _issueDateController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thêm Giấy Tờ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D150C),
                  ),
                ),
                const SizedBox(height: 24),
                // Document Type Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Loại giấy tờ',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF8800)),
                    ),
                  ),
                  items: _documentTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Number Field
                TextFormField(
                  controller: _numberController,
                  decoration: InputDecoration(
                    labelText: 'Số giấy tờ',
                    hintText: '001234567890',
                    prefixIcon: const Icon(Icons.numbers),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF8800)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số giấy tờ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Issue Date Field
                TextFormField(
                  controller: _issueDateController,
                  decoration: InputDecoration(
                    labelText: 'Ngày cấp',
                    hintText: 'DD/MM/YYYY',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF8800)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập ngày cấp';
                    }
                    return null;
                  },
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      _issueDateController.text = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                    }
                  },
                  readOnly: true,
                ),
                const SizedBox(height: 16),
                // Expiry Date Field
                TextFormField(
                  controller: _expiryDateController,
                  decoration: InputDecoration(
                    labelText: 'Ngày hết hạn',
                    hintText: 'DD/MM/YYYY hoặc "Vô thời hạn"',
                    prefixIcon: const Icon(Icons.event_available),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF8800)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập ngày hết hạn';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    _expiryDateController.text = 'Vô thời hạn';
                  },
                  child: const Text(
                    'Đặt vô thời hạn',
                    style: TextStyle(color: Color(0xFFFF8800)),
                  ),
                ),
                const SizedBox(height: 16),
                // Upload Images Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFF8800).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: Color(0xFFFF8800)),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Upload ảnh giấy tờ sau khi lưu. Admin sẽ xác minh trong 24h.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _saveDocument,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8800),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Lưu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveDocument() {
    if (_formKey.currentState!.validate()) {
      final document = DocumentItem(
        type: _selectedType,
        number: _numberController.text.trim(),
        issueDate: _issueDateController.text.trim(),
        expiryDate: _expiryDateController.text.trim(),
        status: DocumentStatus.pending,
        frontImageUrl: null,
        backImageUrl: null,
      );
      widget.onSave(document);
      Navigator.of(context).pop();
    }
  }
}

class _DocumentDetailDialog extends StatelessWidget {
  final DocumentItem document;

  const _DocumentDetailDialog({required this.document});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      document.type,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D150C),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: const Color(0xFF666666),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Front Image
              if (document.frontImageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    document.frontImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F7F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(Icons.image, size: 48, color: Color(0xFFE5E5E5)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
              // Back Image
              if (document.backImageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    document.backImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F7F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(Icons.image, size: 48, color: Color(0xFFE5E5E5)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Details
              _InfoRowDetail(label: 'Số giấy tờ', value: document.number),
              const Divider(height: 24, color: Color(0xFFE5E5E5)),
              _InfoRowDetail(label: 'Ngày cấp', value: document.issueDate),
              const Divider(height: 24, color: Color(0xFFE5E5E5)),
              _InfoRowDetail(label: 'Ngày hết hạn', value: document.expiryDate),
              const SizedBox(height: 24),
              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8800),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

class _InfoRowDetail extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRowDetail({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D150C),
          ),
        ),
      ],
    );
  }
}
