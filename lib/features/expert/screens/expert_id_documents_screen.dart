import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Expert ID Documents Screen - Manage certificates and credentials for experts
/// Màn hình chứng chỉ & bằng cấp của Chuyên gia
class ExpertIdDocumentsScreen extends StatefulWidget {
  const ExpertIdDocumentsScreen({super.key});

  @override
  State<ExpertIdDocumentsScreen> createState() =>
      _ExpertIdDocumentsScreenState();
}

class _ExpertIdDocumentsScreenState extends State<ExpertIdDocumentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F8),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusBanner(),
            const SizedBox(height: 24),
            _buildIdentitySection(),
            const SizedBox(height: 24),
            _buildMedicalDegreesSection(),
            const SizedBox(height: 24),
            _buildSpecializedCertificatesSection(),
            const SizedBox(height: 24),
            _buildInfoBox(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF7F6F8),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF131018)),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Chứng Chỉ & Bằng Cấp',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF131018),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF6C47C2).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF6C47C2)),
            onPressed: _addNewDocument,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD4EDDA),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: const Border(
          left: BorderSide(color: Color(0xFF28A745), width: 4),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFF28A745),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Xác minh hồ sơ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF155724),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '4/6 đã xác minh',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF155724),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tất cả chứng chỉ quan trọng đã được hệ thống xác thực.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF155724),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Giấy Tờ Tùy Thân',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF131018),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Chi tiết',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6C47C2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDocumentCard(
          title: 'CCCD / Hộ Chiếu',
          subtitle: 'Số: 0791****8821',
          expiry: 'Hết hạn: 20/10/2025',
          status: DocumentStatus.verified,
          imageUrl: 'https://via.placeholder.com/80x100',
        ),
      ],
    );
  }

  Widget _buildMedicalDegreesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bằng Cấp Y Khoa',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF131018),
          ),
        ),
        const SizedBox(height: 12),
        _buildDocumentCard(
          title: 'Bằng Bác Sĩ Đa Khoa',
          subtitle: 'ĐH Y Dược TP.HCM',
          status: DocumentStatus.verified,
          imageUrl: 'https://via.placeholder.com/80x100',
          isSecondary: true,
        ),
      ],
    );
  }

  Widget _buildSpecializedCertificatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chứng Chỉ Chuyên Môn',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF131018),
          ),
        ),
        const SizedBox(height: 12),
        _buildDocumentCard(
          title: 'Giấy Phép Xử Lý Rắn',
          subtitle: 'Cục Kiểm Lâm',
          status: DocumentStatus.pending,
          icon: Icons.pets,
          hasBorderHighlight: true,
        ),
        const SizedBox(height: 16),
        _buildAddNewPlaceholder(),
      ],
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String subtitle,
    String? expiry,
    required DocumentStatus status,
    String? imageUrl,
    IconData? icon,
    bool isSecondary = false,
    bool hasBorderHighlight = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: hasBorderHighlight
            ? const Border(left: BorderSide(color: Color(0xFF6C47C2), width: 4))
            : Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Thumbnail or Icon
          Container(
            width: 80,
            height: 96,
            decoration: BoxDecoration(
              color: icon != null
                  ? const Color(0xFF6C47C2).withOpacity(0.05)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: icon != null
                    ? const Color(0xFF6C47C2).withOpacity(0.1)
                    : const Color(0xFFE0E0E0),
              ),
            ),
            child: icon != null
                ? Icon(icon, color: const Color(0xFF6C47C2), size: 40)
                : imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.image, color: Colors.grey),
                        );
                      },
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF131018),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
                if (expiry != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    expiry,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _buildStatusBadge(status),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Action button
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: isSecondary
                  ? const Color(0xFFF5F5F5)
                  : const Color(0xFF6C47C2),
              foregroundColor: isSecondary
                  ? const Color(0xFF131018)
                  : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: isSecondary ? 0 : 2,
              shadowColor: const Color(0xFF6C47C2).withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Xem',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewPlaceholder() {
    return InkWell(
      onTap: _addNewDocument,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF6C47C2).withOpacity(0.05),
          border: Border.all(
            color: const Color(0xFF6C47C2).withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF6C47C2).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate,
                color: Color(0xFF6C47C2),
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Thêm chứng chỉ mới',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF131018),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Hỗ trợ định dạng PDF, JPG, PNG',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5F5F5), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_user, color: Color(0xFF6C47C2), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Tại sao cần xác minh?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF131018),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Việc xác minh giúp tăng độ tin cậy với người cần cứu hộ và đảm bảo an toàn pháp lý khi xử lý các loài bò sát nguy hiểm.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addNewDocument() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thêm chứng chỉ mới - Đang phát triển')),
    );
  }
}

enum DocumentStatus { verified, pending, rejected }
