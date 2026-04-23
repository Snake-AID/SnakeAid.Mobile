import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snakeaid_mobile/features/emergency/models/rescue_mission_response.dart';
import 'package:snakeaid_mobile/features/emergency/models/snake_identification_response.dart';
import '../../models/detailed_incident_response.dart';
import '../../providers/mission_detail_provider.dart';
import '../../widgets/snake_risk_badges.dart';

class RescuerMissionHistoryDetailScreen extends ConsumerStatefulWidget {
  final String missionId;
  const RescuerMissionHistoryDetailScreen({super.key, required this.missionId});

  @override
  ConsumerState<RescuerMissionHistoryDetailScreen> createState() =>
      _RescuerMissionHistoryDetailScreenState();
}

class _RescuerMissionHistoryDetailScreenState
    extends ConsumerState<RescuerMissionHistoryDetailScreen> {
  bool _isInitializing = true;

  // ── Design tokens (giống hệt RescuerMissionDetailScreen) ──────────────────
  static const _accent = Color(0xFFE65100);
  static const _surface = Color(0xFFF5F5F5);
  static const _cardBg = Colors.white;
  static const _danger = Color(0xFFC62828);
  static const _textPrimary = Color(0xFF1A1A1A);
  static const _textSecondary = Color(0xFF757575);
  static const _divider = Color(0xFFEEEEEE);
  static const _green = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await ref
        .read(missionDetailProvider.notifier)
        .loadMissionDetail(missionId: widget.missionId);
    if (mounted) setState(() => _isInitializing = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(missionDetailProvider);

    if (state.isLoading || _isInitializing) {
      return const Scaffold(
        backgroundColor: _surface,
        body: Center(child: CircularProgressIndicator(color: _accent)),
      );
    }

    if (state.error != null && state.error!.isNotEmpty) {
      return Scaffold(
        backgroundColor: _surface,
        appBar: _simpleAppBar('Chi tiết lịch sử'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: _danger),
                const SizedBox(height: 16),
                Text(
                  state.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: _textPrimary),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _load,
                  style: FilledButton.styleFrom(backgroundColor: _accent),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final mission = state.mission;
    if (mission == null) {
      return Scaffold(
        backgroundColor: _surface,
        appBar: _simpleAppBar('Chi tiết lịch sử'),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off_rounded, size: 48, color: _textSecondary),
                SizedBox(height: 16),
                Text(
                  'Không tìm thấy nhiệm vụ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  'Nhiệm vụ có thể đã bị hủy hoặc không còn tồn tại',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: _textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _surface,
      body: Column(
        children: [
          _buildHeader(mission),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(mission),
                  const SizedBox(height: 12),
                  _buildPriceCard(mission),
                  const SizedBox(height: 12),
                  if (mission.incident.identifiedSnakeSpecies != null) ...[
                    _buildSnakeCard(
                      mission.incident.identifiedSnakeSpecies!,
                      mission.incident.identificationContext,
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildVictimCard(mission),
                  const SizedBox(height: 12),
                  _buildEmergencyContactsCard(mission),
                  const SizedBox(height: 12),
                  _buildLocationCard(mission),
                  const SizedBox(height: 12),
                  _buildSymptomsCard(mission),
                  const SizedBox(height: 12),
                  _buildMediaCard(mission),
                  const SizedBox(height: 12),
                  _buildIncidentTimeCard(mission),
                  if (mission.notes != null && mission.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildNotesCard(mission.notes!),
                  ],
                  if (mission.cancellationReason != null &&
                      mission.cancellationReason!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildCancellationCard(mission.cancellationReason!),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar (fallback khi không có mission) ────────────────────────────────
  AppBar _simpleAppBar(String title) => AppBar(
    backgroundColor: _cardBg,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: _textPrimary),
      onPressed: () => context.pop(),
    ),
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      ),
    ),
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, color: _divider),
    ),
  );

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(DetailRescueMissionResponse mission) {
    final (statusLabel, statusColor) = _statusInfo(mission.missionStatus);

    return SafeArea(
      bottom: false,
      child: Container(
        decoration: const BoxDecoration(
          color: _cardBg,
          border: Border(bottom: BorderSide(color: _divider)),
        ),
        padding: const EdgeInsets.fromLTRB(4, 8, 8, 12),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: _textPrimary),
                  onPressed: () => context.pop(),
                ),
                const Expanded(
                  child: Text(
                    'LỊCH SỬ NHIỆM VỤ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // History badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _textSecondary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 13,
                          color: _textSecondary,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Đã kết thúc',
                          style: TextStyle(
                            fontSize: 12,
                            color: _textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Summary Card ───────────────────────────────────────────────────────────
  Widget _buildSummaryCard(DetailRescueMissionResponse mission) {
    final rows =
        <({IconData icon, Color iconColor, String label, String value})>[];

    rows.add((
      icon: Icons.tag_rounded,
      iconColor: _textSecondary,
      label: 'Mã nhiệm vụ',
      value: mission.formattedMissionId,
    ));

    if (mission.createdAt != null) {
      rows.add((
        icon: Icons.add_circle_outline_rounded,
        iconColor: _textSecondary,
        label: 'Tạo lúc',
        value: _formatDateTime(mission.createdAt!),
      ));
    }

    if (mission.startedAt != null) {
      rows.add((
        icon: Icons.play_circle_outline_rounded,
        iconColor: _green,
        label: 'Bắt đầu',
        value: _formatDateTime(mission.startedAt!),
      ));
    }

    if (mission.arrivedAt != null) {
      rows.add((
        icon: Icons.location_on_outlined,
        iconColor: const Color(0xFF1565C0),
        label: 'Đến nơi',
        value: _formatDateTime(mission.arrivedAt!),
      ));
    }

    if (mission.completedAt != null) {
      rows.add((
        icon: Icons.check_circle_outline_rounded,
        iconColor: _green,
        label: 'Kết thúc',
        value: _formatDateTime(mission.completedAt!),
      ));
    }

    if (mission.startedAt != null && mission.completedAt != null) {
      final duration = mission.completedAt!.difference(mission.startedAt!);
      rows.add((
        icon: Icons.timer_outlined,
        iconColor: const Color(0xFF1565C0),
        label: 'Thời lượng',
        value: _formatDuration(duration),
      ));
    }

    if (mission.distanceFromCenterKm != null) {
      rows.add((
        icon: Icons.straighten_rounded,
        iconColor: _textSecondary,
        label: 'Khoảng cách',
        value: '${mission.distanceFromCenterKm!.toStringAsFixed(1)} km',
      ));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabelWithIcon(
            Icons.summarize_outlined,
            const Color(0xFF1565C0),
            'Tóm tắt nhiệm vụ',
          ),
          const SizedBox(height: 12),
          ...rows.asMap().entries.map((e) {
            final i = e.key;
            final row = e.value;
            return Column(
              children: [
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1, color: _divider),
                  ),
                _infoRow(
                  row.icon,
                  row.label,
                  row.value,
                  iconColorOverride: row.iconColor,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ── Price Card ─────────────────────────────────────────────────────────────
  Widget _buildPriceCard(DetailRescueMissionResponse mission) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabelWithIcon(Icons.payments_outlined, _green, 'Chi phí'),
          const SizedBox(height: 16),

          // Dòng 1 – Thực tế (to nhất)
          if (mission.formattedActualCost.isNotEmpty) ...[
            const Text(
              'Thực tế',
              style: TextStyle(fontSize: 12, color: _textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              mission.formattedActualCost,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: _green,
              ),
            ),
            const SizedBox(height: 14),
            const Divider(color: _divider),
            const SizedBox(height: 14),
          ],

          // Dòng 2 – Phí dịch vụ (dự kiến)
          _priceRow(
            icon: Icons.payments_outlined,
            iconColor: _green,
            label: 'Phí dịch vụ',
            value: mission.formattedPrice,
            valueFontSize: 15,
            valueColor: _textPrimary,
          ),

          // Dòng 3 – Phí từ trung tâm
          if (mission.costFromCenter != null) ...[
            const SizedBox(height: 12),
            const Divider(color: _divider),
            const SizedBox(height: 12),
            _priceRow(
              icon: Icons.business_outlined,
              iconColor: _textSecondary,
              label: 'Phí di chuyển từ trung tâm',
              value: mission.formattedCostFromCenter,
              valueFontSize: 15,
              valueColor: _textPrimary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _priceRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required double valueFontSize,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: _textSecondary),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: valueFontSize,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // ── Snake Card ─────────────────────────────────────────────────────────────
  Widget _buildSnakeCard(
    DetectedSnakeSpecies species,
    SnakeIdentificationContext? ctx,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, size: 15, color: _green),
                const SizedBox(width: 6),
                const Text(
                  'Loài rắn xác định',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _green,
                  ),
                ),
                const Spacer(),
                if (ctx != null)
                  _MethodBadge(
                    isAI: ctx.method == SnakeIdentificationMethod.ai,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (species.imageUrl != null)
            Image.network(
              species.imageUrl!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: const Color(0xFFF5F5F5),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 40,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  species.commonName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  species.scientificName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: _textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    SnakeRiskBadges.buildRiskLevelBadge(
                      species.riskLevel,
                      compact: true,
                    ),
                    SnakeRiskBadges.buildVenomTypeBadge(
                      species.primaryVenomType,
                      compact: true,
                    ),
                  ],
                ),
                if (ctx?.aiConfidence != null) ...[
                  const SizedBox(height: 10),
                  const Divider(color: _divider),
                  const SizedBox(height: 8),
                  _infoRow(
                    Icons.analytics_outlined,
                    'Độ tin cậy',
                    '${(ctx!.aiConfidence! * 100).toStringAsFixed(0)}%',
                  ),
                ],
                if (species.identificationSummary != null &&
                    species.identificationSummary!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Divider(color: _divider),
                  const SizedBox(height: 8),
                  Text(
                    species.identificationSummary!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Victim Card ────────────────────────────────────────────────────────────
  Widget _buildVictimCard(DetailRescueMissionResponse mission) {
    final user = mission.user;
    final account = user.account;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabelWithIcon(
            Icons.person_outline,
            const Color(0xFF1565C0),
            'Thông tin nạn nhân',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: _accent.withOpacity(0.1),
                backgroundImage: account?.avatarUrl != null
                    ? NetworkImage(account!.avatarUrl!)
                    : null,
                child: account?.avatarUrl == null
                    ? Text(
                        account?.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _accent,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account?.fullName ?? user.userName ?? 'Không rõ',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    if (user.phoneNumber != null &&
                        user.phoneNumber!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        user.phoneNumber!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                    if (user.ratingCount > 0) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${user.rating.toStringAsFixed(1)} (${user.ratingCount})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (user.hasUnderlyingDisease) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _accent.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16, color: _accent),
                  SizedBox(width: 8),
                  Text(
                    'Bệnh nhân có bệnh nền',
                    style: TextStyle(
                      fontSize: 13,
                      color: _accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Emergency Contacts ─────────────────────────────────────────────────────
  Widget _buildEmergencyContactsCard(DetailRescueMissionResponse mission) {
    final contacts = mission.user.emergencyContacts
        .where((c) => c.trim().isNotEmpty)
        .toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabelWithIcon(
            Icons.phone_in_talk_outlined,
            const Color(0xFFFF6B35),
            'Liên hệ khẩn cấp',
          ),
          const SizedBox(height: 12),
          if (contacts.isEmpty)
            const Text(
              'Chưa có số liên hệ khẩn cấp',
              style: TextStyle(
                fontSize: 14,
                color: _textSecondary,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...contacts.asMap().entries.map((e) {
              final i = e.key;
              final phone = e.value;
              return Column(
                children: [
                  if (i > 0) const Divider(height: 16, color: _divider),
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          phone,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }

  // ── Location Card ──────────────────────────────────────────────────────────
  Widget _buildLocationCard(DetailRescueMissionResponse mission) {
    final lat = mission.incident.locationCoordinates.latitude;
    final lon = mission.incident.locationCoordinates.longitude;
    final address = mission.incident.address;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabelWithIcon(
            Icons.place_outlined,
            const Color(0xFF4CAF50),
            'Địa điểm sự cố',
          ),
          const SizedBox(height: 12),
          _infoRow(
            Icons.my_location_outlined,
            'Tọa độ',
            '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}',
          ),
          if (address != null && address.isNotEmpty) ...[
            const SizedBox(height: 8),
            _infoRow(Icons.place_outlined, 'Địa chỉ', address),
          ],
          if (mission.incident.severityLevel != null &&
              mission.incident.severityLevel! > 0) ...[
            const SizedBox(height: 8),
            _infoRow(
              Icons.monitor_heart_outlined,
              'Mức độ',
              mission.incident.getSeverityText(),
            ),
          ],
        ],
      ),
    );
  }

  // ── Symptoms Card ──────────────────────────────────────────────────────────
  Widget _buildSymptomsCard(DetailRescueMissionResponse mission) {
    final symptoms = mission.incident.symptomsReport ?? [];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabelWithIcon(
            Icons.medical_information_outlined,
            const Color(0xFFE65100),
            'Triệu chứng',
          ),
          const SizedBox(height: 12),
          if (symptoms.isEmpty)
            const Text(
              'Chưa có thông tin triệu chứng',
              style: TextStyle(
                fontSize: 14,
                color: _textSecondary,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Column(
              children: symptoms.asMap().entries.map((e) {
                final i = e.key;
                final s = e.value;
                return Padding(
                  padding: EdgeInsets.only(top: i == 0 ? 0 : 6),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBE9E7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFCCBC)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFBF360C),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s.symptomName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFBF360C),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ── Media Card ─────────────────────────────────────────────────────────────
  Widget _buildMediaCard(DetailRescueMissionResponse mission) {
    final media = mission.incident.media;
    if (media.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabelWithIcon(
              Icons.image_search_outlined,
              const Color(0xFF4CAF50),
              'Hình ảnh & Nhận diện',
            ),
            const SizedBox(height: 12),
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Chưa có hình ảnh',
                  style: TextStyle(fontSize: 13, color: _textSecondary),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionLabelWithIcon(
                Icons.image_search_outlined,
                const Color(0xFF4CAF50),
                'Hình ảnh & Nhận diện',
              ),
              const Spacer(),
              if (media.length > 1)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${media.length} ảnh',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _green,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 380,
            child: PageView.builder(
              itemCount: media.length,
              itemBuilder: (context, index) {
                final m = media[index];
                final hasAI = m.detectedSpecies.isNotEmpty;
                final species = hasAI ? m.detectedSpecies.first : null;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          m.mediaUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 200,
                            color: const Color(0xFFF5F5F5),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (media.length > 1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            media.length,
                            (i) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: i == index ? 16 : 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: i == index
                                    ? _green
                                    : const Color(0xFFDDDDDD),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      if (hasAI && species != null) ...[
                        Text(
                          species.commonName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          species.scientificName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: _textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            SnakeRiskBadges.buildRiskLevelBadge(
                              species.riskLevel,
                            ),
                            SnakeRiskBadges.buildVenomTypeBadge(
                              species.primaryVenomType,
                            ),
                          ],
                        ),
                      ] else if (m.isProcessed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Không nhận diện được loài rắn',
                            style: TextStyle(
                              fontSize: 13,
                              color: _textSecondary,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _accent.withOpacity(0.3)),
                          ),
                          child: const Text(
                            'Chưa có kết quả nhận diện',
                            style: TextStyle(fontSize: 13, color: _accent),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Incident Time Card ─────────────────────────────────────────────────────
  Widget _buildIncidentTimeCard(DetailRescueMissionResponse mission) {
    final occurredAt = mission.incident.incidentOccurredAt;
    if (occurredAt == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: _textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thời gian xảy ra',
                style: TextStyle(fontSize: 12, color: _textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDateTime(occurredAt),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Notes Card ─────────────────────────────────────────────────────────────
  Widget _buildNotesCard(String notes) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabelWithIcon(
            Icons.notes_rounded,
            const Color(0xFF1565C0),
            'Ghi chú của cứu hộ viên',
          ),
          const SizedBox(height: 10),
          Text(
            notes,
            style: const TextStyle(
              fontSize: 13,
              color: _textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Cancellation Card ──────────────────────────────────────────────────────
  Widget _buildCancellationCard(String reason) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _danger.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _danger.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabelWithIcon(Icons.cancel_outlined, _danger, 'Lý do hủy'),
          const SizedBox(height: 10),
          Text(
            reason,
            style: const TextStyle(
              fontSize: 13,
              color: _textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  (String, Color) _statusInfo(MissionStatus status) => switch (status) {
    MissionStatus.preparing => ('Đang chuẩn bị', const Color(0xFFE65100)),
    MissionStatus.enRoute => ('Đang di chuyển', const Color(0xFF1565C0)),
    MissionStatus.rescuerArrived => ('Đã đến nơi', _green),
    MissionStatus.missionCompleted => ('Hoàn thành', _green),
    MissionStatus.missionUncompleted => ('Chưa hoàn thành', _accent),
    MissionStatus.missionAborted => ('Đã hủy bỏ', _danger),
    MissionStatus.cancelled => ('Đã hủy', _textSecondary),
  };

  String _formatDateTime(DateTime dt) {
    final d = dt.toLocal();
    final pad = (int n) => n.toString().padLeft(2, '0');
    return '${pad(d.hour)}:${pad(d.minute)} – ${pad(d.day)}/${pad(d.month)}/${d.year}';
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0) return '$h giờ $m phút';
    return '$m phút';
  }

  Widget _sectionLabelWithIcon(IconData icon, Color iconColor, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 7),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    Color? iconColorOverride,
  }) {
    Color defaultIconColor(IconData i) {
      if (i == Icons.my_location_outlined) return const Color(0xFF4CAF50);
      if (i == Icons.place_outlined) return const Color(0xFF4CAF50);
      if (i == Icons.monitor_heart_outlined) return const Color(0xFFE65100);
      if (i == Icons.business_outlined) return _textSecondary;
      if (i == Icons.analytics_outlined) return const Color(0xFF1565C0);
      return _textSecondary;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColorOverride ?? defaultIconColor(icon),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: _textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: _textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Method Badge ───────────────────────────────────────────────────────────
class _MethodBadge extends StatelessWidget {
  final bool isAI;
  const _MethodBadge({required this.isAI});

  @override
  Widget build(BuildContext context) {
    final color = isAI ? const Color(0xFF1565C0) : const Color(0xFF6A1B9A);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAI ? Icons.smart_toy_outlined : Icons.person_outline,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isAI ? 'AI' : 'Chuyên gia',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
