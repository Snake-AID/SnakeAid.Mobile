import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/providers/http_provider.dart';
import '../../../../core/services/emergency_consultation_signalr_service.dart';
import '../../models/expert_detail_model.dart';
import '../../providers/expert_detail_provider.dart';

// Primary color constant
const Color _primaryColor = Color(0xFF228B22);
const Color _backgroundColor = Color(0xFFF6F8F6);

String _formatFee(double fee) {
  if (fee <= 0) return 'Miễn phí';
  return '${fee.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} VNĐ';
}

/// Service Selection Screen
/// Allows users to choose between instant consultation or scheduled appointment
class ServiceSelectionScreen extends ConsumerStatefulWidget {
  final String expertId;

  const ServiceSelectionScreen({super.key, required this.expertId});

  @override
  ConsumerState<ServiceSelectionScreen> createState() =>
      _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState
    extends ConsumerState<ServiceSelectionScreen> {
  EmergencyConsultationSignalRService? _presenceService;
  StreamSubscription<Set<String>>? _snapshotSub;
  StreamSubscription<ExpertPresenceChangedEvent>? _presenceChangedSub;
  bool? _isExpertOnlineRealtime;

  String get _expertIdNormalized => widget.expertId.toLowerCase();

  bool _isMatchExpertId(String id) => id.toLowerCase() == _expertIdNormalized;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPresenceRealtime();
    });
  }

  Future<void> _initPresenceRealtime() async {
    try {
      final baseUrl = ref.read(httpServiceProvider).baseUrl;
      _presenceService = EmergencyConsultationSignalRService(baseUrl: baseUrl);

      _snapshotSub = _presenceService!.onlineExpertsSnapshotStream.listen((
        ids,
      ) {
        if (!mounted) return;
        final isOnline = ids.any(_isMatchExpertId);
        setState(() => _isExpertOnlineRealtime = isOnline);
      });

      _presenceChangedSub = _presenceService!.expertPresenceChangedStream
          .listen((event) {
            if (!mounted) return;
            if (!_isMatchExpertId(event.expertId)) return;
            setState(() => _isExpertOnlineRealtime = event.isOnline);
          });

      await _presenceService!.connectAsMember();
    } catch (e) {
      debugPrint('Khong the ket noi presence SignalR cho member: $e');
    }
  }

  @override
  void dispose() {
    _snapshotSub?.cancel();
    _presenceChangedSub?.cancel();
    _presenceService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expertDetailProvider(widget.expertId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Chọn Loại Tư Vấn',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.expert == null
          ? const Center(child: Text('Không tìm thấy chuyên gia'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Expert Profile Card
                  _buildExpertProfile(context, state.expert!, theme),
                  const SizedBox(height: 16),

                  // Instant Consultation Card
                  _buildInstantConsultationCard(
                    context,
                    state.expert!,
                    theme,
                    _isExpertOnlineRealtime ?? state.expert!.isOnline,
                  ),
                  const SizedBox(height: 16),

                  // Scheduled Consultation Card
                  _buildScheduledConsultationCard(
                    context,
                    state.expert!,
                    state.expert!.availability.isNotEmpty,
                    theme,
                  ),
                  const SizedBox(height: 16),

                  // Info Box
                  _buildInfoBox(theme),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  /// Build expert profile summary card
  Widget _buildExpertProfile(BuildContext context, expert, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: expert.avatarUrl != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(expert.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: expert.avatarUrl == null ? Colors.grey[300] : null,
            ),
            child: expert.avatarUrl == null
                ? Icon(Icons.person, size: 24, color: Colors.grey[600])
                : null,
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expert.displayName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Chuyên gia ${expert.primarySpecialty}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build instant consultation card
  Widget _buildInstantConsultationCard(
    BuildContext context,
    ExpertDetailModel expert,
    ThemeData theme,
    bool isOnline,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.bolt, color: Colors.amber[500], size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isOnline
                      ? _primaryColor.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isOnline ? 'Đang Online' : 'Ngoại Tuyến',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isOnline ? _primaryColor : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title & Description
          Text(
            'Tư Vấn Ngay',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chuyên gia sẽ phản hồi trong 2 phút',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),

          // Price
          Text(
            _formatFee(expert.emergencyConsultationFee),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Divider
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 16),

          // Benefits
          _buildBenefit(Icons.check_circle, 'Phản hồi tức thì', theme),
          const SizedBox(height: 12),
          _buildBenefit(Icons.check_circle, 'Chat hoặc video call', theme),
          const SizedBox(height: 12),
          _buildBenefit(Icons.check_circle, 'Không cần đặt trước', theme),
          const SizedBox(height: 20),

          // Action Button
          if (!isOnline)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Chuyên gia hiện không trực tuyến',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: isOnline
                  ? () {
                      context.push(
                        '/consultation-documents/${expert.userId}',
                        extra: {
                          'consultationType': 'instant',
                          'price': _formatFee(expert.emergencyConsultationFee),
                        },
                      );
                    }
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: isOnline
                    ? _primaryColor
                    : Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Chọn Tư Vấn Ngay',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build scheduled consultation card
  Widget _buildScheduledConsultationCard(
    BuildContext context,
    ExpertDetailModel expert,
    bool hasAvailability,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_month,
              color: Colors.blue[500],
              size: 20,
            ),
          ),
          const SizedBox(height: 16),

          // Title & Description
          Text(
            'Đặt Lịch Tư Vấn',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chọn thời gian phù hợp với bạn',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),

          // Price
          Text(
            _formatFee(expert.scheduledConsultationFee),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Divider
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 16),

          // Benefits
          _buildBenefit(Icons.check_circle, 'Linh hoạt thời gian', theme),
          const SizedBox(height: 12),
          _buildBenefit(Icons.check_circle, 'Chuẩn bị trước câu hỏi', theme),
          const SizedBox(height: 12),
          _buildBenefit(Icons.check_circle, 'Nhắc nhở trước 30 phút', theme),
          const SizedBox(height: 20),

          // Action Button
          if (!hasAvailability)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Chuyên gia chưa có lịch trống',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: hasAvailability
                  ? () {
                      context.push(
                        '/consultation-time-selection/${expert.userId}',
                      );
                    }
                  : null,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: hasAvailability ? _primaryColor : Colors.grey.shade400,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Chọn Đặt Lịch',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: hasAvailability ? _primaryColor : Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build benefit item
  Widget _buildBenefit(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, color: _primaryColor, size: 20),
        const SizedBox(width: 12),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  /// Build info box
  Widget _buildInfoBox(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: Colors.amber, width: 4)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bạn chỉ thanh toán sau khi hoàn thành tư vấn.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
