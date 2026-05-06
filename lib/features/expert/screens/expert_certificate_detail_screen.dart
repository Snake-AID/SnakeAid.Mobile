import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/expert_certificate.dart';
import '../repository/expert_certificate_repository.dart';

class ExpertCertificateDetailScreen extends ConsumerStatefulWidget {
  final String certificateId;

  const ExpertCertificateDetailScreen({super.key, required this.certificateId});

  @override
  ConsumerState<ExpertCertificateDetailScreen> createState() =>
      _ExpertCertificateDetailScreenState();
}

class _ExpertCertificateDetailScreenState
    extends ConsumerState<ExpertCertificateDetailScreen> {
  bool _isLoading = true;
  String? _error;
  ExpertCertificate? _certificate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetail());
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = ref.read(expertCertificateRepositoryProvider);
      final certificate = await repo.getCertificate(widget.certificateId);
      if (!mounted) return;
      setState(() {
        _certificate = certificate;
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

  Future<void> _openEdit() async {
    final result = await context.pushNamed(
      'expert_certificate_edit',
      pathParameters: {'certificateId': widget.certificateId},
    );
    if (result == true && mounted) {
      await _loadDetail();
    }
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa chứng chỉ?'),
        content: const Text('Chứng chỉ sẽ bị xóa vĩnh viễn khỏi hồ sơ.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC3545),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await ref
          .read(expertCertificateRepositoryProvider)
          .deleteCertificate(widget.certificateId);
      if (!mounted) return;
      context.pop(true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa chứng chỉ')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
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
        title: const Text(
          'Chi Tiết Chứng Chỉ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF131018),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF6C47C2)),
            onPressed: _openEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFDC3545)),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorState()
          : _certificate == null
          ? const Center(child: Text('Không tìm thấy chứng chỉ'))
          : _buildContent(_certificate!),
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

  Widget _buildContent(ExpertCertificate certificate) {
    final status = _statusFromCertificate(certificate);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatusBadge(status),
        const SizedBox(height: 16),
        _buildDetailCard(certificate),
        if (certificate.rejectionReason?.isNotEmpty ?? false) ...[
          const SizedBox(height: 16),
          _buildRejectReason(certificate.rejectionReason!),
        ],
        const SizedBox(height: 16),
        _buildMediaPreview(certificate),
      ],
    );
  }

  Widget _buildDetailCard(ExpertCertificate certificate) {
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
          Text(
            certificate.certificateName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF131018),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            certificate.issuingOrganization,
            style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
          if (certificate.issueDateLabel != null) ...[
            const SizedBox(height: 8),
            Text(
              'Ngày cấp: ${certificate.issueDateLabel}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
            ),
          ],
          if (certificate.expiryDateLabel != null) ...[
            const SizedBox(height: 6),
            Text(
              'Hết hạn: ${certificate.expiryDateLabel}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRejectReason(String reason) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8D7DA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF5C2C7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.report_gmailerrorred, color: Color(0xFFB02A37)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              reason,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF842029),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(ExpertCertificate certificate) {
    if (certificate.reportMediaFiles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: const Text(
          'Không có ảnh chứng chỉ đính kèm',
          style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ảnh chứng chỉ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF131018),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: certificate.reportMediaFiles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final media = certificate.reportMediaFiles[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    media.mediaUrl,
                    width: 180,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 180,
                      height: 160,
                      color: const Color(0xFFF2F2F2),
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(DocumentStatus status) {
    Color bgColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case DocumentStatus.verified:
        bgColor = const Color(0xFFD4EDDA);
        textColor = const Color(0xFF155724);
        text = 'Đã xác minh';
        icon = Icons.verified;
        break;
      case DocumentStatus.pending:
        bgColor = const Color(0xFFFFF3CD);
        textColor = const Color(0xFF856404);
        text = 'Đang chờ duyệt';
        icon = Icons.hourglass_top;
        break;
      case DocumentStatus.rejected:
        bgColor = const Color(0xFFF8D7DA);
        textColor = const Color(0xFF721C24);
        text = 'Bị từ chối';
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  DocumentStatus _statusFromCertificate(ExpertCertificate certificate) {
    if (certificate.isVerified) return DocumentStatus.verified;
    if (certificate.rejectionReason?.isNotEmpty ?? false) {
      return DocumentStatus.rejected;
    }
    return DocumentStatus.pending;
  }
}

enum DocumentStatus { verified, pending, rejected }
