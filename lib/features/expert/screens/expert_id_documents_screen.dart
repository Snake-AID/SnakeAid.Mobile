import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/expert_certificate.dart';
import '../models/expert_profile.dart';
import '../repository/expert_certificate_repository.dart';
import '../repository/expert_profile_repository.dart';
import '../../auth/providers/auth_provider.dart';

/// Expert ID Documents Screen - Manage certificates and credentials for experts
/// Màn hình chứng chỉ & bằng cấp của Chuyên gia
class ExpertIdDocumentsScreen extends ConsumerStatefulWidget {
  const ExpertIdDocumentsScreen({super.key});

  @override
  ConsumerState<ExpertIdDocumentsScreen> createState() =>
      _ExpertIdDocumentsScreenState();
}

class _ExpertIdDocumentsScreenState
    extends ConsumerState<ExpertIdDocumentsScreen> {
  bool _isLoading = true;
  String? _error;
  ExpertProfile? _profile;
  List<ExpertCertificate> _certificates = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final certificateRepo = ref.read(expertCertificateRepositoryProvider);
      final profileRepo = ref.read(expertProfileRepositoryProvider);
      final profile = await profileRepo.getMyProfile();
      final certificates = await certificateRepo.getMyCertificates();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _certificates = certificates;
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

  Future<void> _openCreate() async {
    final result = await context.pushNamed('expert_certificate_create');
    if (result == true && mounted) {
      await _loadData();
    }
  }

  Future<void> _openDetail(String certificateId) async {
    final result = await context.pushNamed(
      'expert_certificate_detail',
      pathParameters: {'certificateId': certificateId},
    );
    if (result == true && mounted) {
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasVerifiedCert = _certificates.any((c) => c.isVerified) || _profile?.isVerified == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F8),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildStatusBanner(),
                      const SizedBox(height: 24),
                      _buildCertificateSection(),
                      const SizedBox(height: 24),
                      _buildInfoBox(),
                      const SizedBox(height: 24),
                      if (hasVerifiedCert) ...[
                          SizedBox(
                            height: 56,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                await ref.read(authProvider.notifier).markUserAsVerified();
                                if (mounted) context.go('/expert-home');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C47C2),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Vào Trang Chủ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final verified = _profile?.isVerified == true;
    return AppBar(
      backgroundColor: const Color(0xFFF7F6F8),
      elevation: 0,
      centerTitle: true,
      leading: verified
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF131018)),
              onPressed: () => context.pop(),
            )
          : null,
      title: const Text(
        'Chứng Chỉ & Bằng Cấp',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF131018),
        ),
      ),
      actions: verified
          ? [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C47C2).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF6C47C2)),
                  onPressed: _openCreate,
                ),
              ),
            ]
          : null,
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
              style: const TextStyle(color: Color(0xFF333333)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
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

  Widget _buildStatusBanner() {
    final total = _certificates.length;
    final verifiedCount = _certificates.where((c) => c.isVerified).length;
    final rejectedCount = _certificates
        .where((c) => !c.isVerified && (c.rejectionReason?.isNotEmpty ?? false))
        .length;
    final pendingCount = total - verifiedCount - rejectedCount;

    final isFullyVerified = _profile?.isVerified == true;
    final banner = _statusBannerConfig(
      isFullyVerified: isFullyVerified,
      total: total,
      verifiedCount: verifiedCount,
      rejectedCount: rejectedCount,
      pendingCount: pendingCount,
    );

    return Container(
      decoration: BoxDecoration(
        color: banner.backgroundColor,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border(
          left: BorderSide(color: banner.accentColor, width: 4),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: banner.accentColor,
              shape: BoxShape.circle,
            ),
            child: Icon(banner.icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      banner.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: banner.textColor,
                      ),
                    ),
                    if (total > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$verifiedCount/$total đã xác minh',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: banner.textColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  banner.subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: banner.textColor,
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

  _StatusBannerConfig _statusBannerConfig({
    required bool isFullyVerified,
    required int total,
    required int verifiedCount,
    required int rejectedCount,
    required int pendingCount,
  }) {
    if (isFullyVerified && total > 0) {
      return const _StatusBannerConfig(
        title: 'Hồ sơ đã xác minh',
        subtitle: 'Tất cả chứng chỉ đã được hệ thống xác thực.',
        backgroundColor: Color(0xFFD4EDDA),
        accentColor: Color(0xFF28A745),
        textColor: Color(0xFF155724),
        icon: Icons.check,
      );
    }
    if (rejectedCount > 0) {
      return const _StatusBannerConfig(
        title: 'Có chứng chỉ bị từ chối',
        subtitle: 'Vui lòng cập nhật hoặc nộp lại chứng chỉ bị từ chối.',
        backgroundColor: Color(0xFFF8D7DA),
        accentColor: Color(0xFFDC3545),
        textColor: Color(0xFF721C24),
        icon: Icons.cancel,
      );
    }
    if (pendingCount > 0) {
      return const _StatusBannerConfig(
        title: 'Đang chờ duyệt',
        subtitle: 'Chứng chỉ sẽ được kiểm tra trong vòng 24 giờ làm việc.',
        backgroundColor: Color(0xFFFFF3CD),
        accentColor: Color(0xFFFFC107),
        textColor: Color(0xFF856404),
        icon: Icons.hourglass_top,
      );
    }
    return const _StatusBannerConfig(
      title: 'Chưa có chứng chỉ',
      subtitle: 'Hãy thêm chứng chỉ để hoàn tất hồ sơ chuyên gia.',
      backgroundColor: Color(0xFFE9ECEF),
      accentColor: Color(0xFF6C757D),
      textColor: Color(0xFF495057),
      icon: Icons.info_outline,
    );
  }

  Widget _buildCertificateSection() {
    if (_certificates.isEmpty) {
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
          _buildEmptyState(),
          const SizedBox(height: 16),
          _buildAddNewPlaceholder(),
        ],
      );
    }

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
        ..._certificates.map(
          (certificate) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildDocumentCard(
              certificate: certificate,
            ),
          ),
        ),
        _buildAddNewPlaceholder(),
      ],
    );
  }

  Widget _buildDocumentCard({
    required ExpertCertificate certificate,
  }) {
    final status = _statusFromCertificate(certificate);
    final subtitle = certificate.issuingOrganization.isNotEmpty
        ? certificate.issuingOrganization
        : 'Chưa cập nhật đơn vị cấp';
    final expiry = certificate.expiryDateLabel != null
        ? 'Hết hạn: ${certificate.expiryDateLabel}'
        : null;
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Thumbnail or Icon
          _buildThumbnail(certificate.primaryMediaUrl),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certificate.certificateName,
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
            onPressed: () => _openDetail(certificate.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C47C2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
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

  Widget _buildThumbnail(String? mediaUrl) {
    return Container(
      width: 80,
      height: 96,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: mediaUrl == null
          ? const Icon(Icons.image_outlined, color: Colors.grey, size: 32)
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                mediaUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.image, color: Colors.grey),
                  );
                },
              ),
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
      onTap: _openCreate,
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
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        children: const [
          Icon(Icons.folder_open, size: 56, color: Color(0xFFB0B0B0)),
          SizedBox(height: 12),
          Text(
            'Chưa có chứng chỉ nào',
            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
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

class _StatusBannerConfig {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color accentColor;
  final Color textColor;
  final IconData icon;

  const _StatusBannerConfig({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.accentColor,
    required this.textColor,
    required this.icon,
  });
}
