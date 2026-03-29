import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/nominatim_service.dart';
import '../../models/detailed_incident_response.dart';
import '../../models/snake_identification_response.dart';
import '../../providers/detailed_incident_provider.dart';
import '../../providers/incident_provider.dart';
import '../../providers/active_mission_provider.dart';
import '../../providers/mission_hub_provider.dart' as mission_hub;
import '../../widgets/snake_risk_badges.dart';

class MemberIncidentDetailScreen extends ConsumerStatefulWidget {
  final String incidentId;
  const MemberIncidentDetailScreen({super.key, required this.incidentId});

  @override
  ConsumerState<MemberIncidentDetailScreen> createState() =>
      _MemberIncidentDetailScreenState();
}

class _MemberIncidentDetailScreenState
    extends ConsumerState<MemberIncidentDetailScreen> {
  final _nominatimService = NominatimService();
  String? _memberIncidentAddress;
  bool _isLoadingMemberAddress = false;
  bool _memberIncidentAddressResolved = false;

  // Design tokens
  static const _primary = Color(0xFF1B5E20);
  static const _surface = Color(0xFFEEF2EE); // subtle green-tinted surface
  static const _cardBg = Colors.white;
  static const _danger = Color(0xFFC62828);
  static const _warning = Color(0xFFE65100);
  static const _textPrimary = Color(0xFF1A1A1A);
  static const _textSecondary = Color(0xFF5C5C5C);
  static const _divider = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeIncidentId = ref
          .read(activeIncidentProvider)
          .activeIncidentId;
      final incidentId = widget.incidentId.isNotEmpty
          ? widget.incidentId
          : (activeIncidentId ?? '');
      if (incidentId.isEmpty) return;
      final state = ref.read(detailedIncidentProvider);
      if (state.incident?.id == incidentId && state.isCacheFresh) return;
      ref.read(detailedIncidentProvider.notifier).loadIfStale(incidentId);
    });
  }

  bool _canCancelIncident(IncidentStatus status, {RescueMission? mission}) {
    final ms = ref.watch(mission_hub.missionStatusProvider);
    if (ms.missionStarted ||
        ms.rescuerArrived ||
        ms.missionCompleted ||
        ms.missionCancelled ||
        ms.sessionExpired)
      return false;
    if (status == IncidentStatus.pending || status == IncidentStatus.verified)
      return true;
    if (status == IncidentStatus.assigned) {
      if (mission != null) return mission.status == MissionStatus.preparing;
      final m = ref.watch(activeMissionProvider).mission;
      if (m == null) return true;
      return m.status.toLowerCase().trim() == 'preparing';
    }
    return false;
  }

  Future<void> _cancelIncident() async {
    final incident = ref.read(activeIncidentProvider).incident;
    if (incident == null) return;
    final reason = await _showCancelReasonDialog(context);
    if (reason == null || reason.isEmpty) return;
    try {
      await ref
          .read(activeIncidentProvider.notifier)
          .cancelActiveIncident(reason);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Yêu cầu SOS đã được hủy.')));
      context.goNamed('member_home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hủy SOS thất bại: ${e.toString()}')),
      );
    }
  }

  Future<String?> _showCancelReasonDialog(BuildContext context) async {
    String? selectedReason;
    final reasons = <Map<String, String>>[
      {'value': 'location_unreachable', 'label': 'Không thể đến vị trí'},
      {'value': 'resolved_by_self', 'label': 'Đã tự xử lý xong'},
      {'value': 'not_needed', 'label': 'Không cần cứu hộ nữa'},
      {'value': 'wrong_location', 'label': 'Nhập sai địa điểm'},
      {'value': 'other', 'label': 'Lý do khác'},
    ];
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Lý do hủy SOS',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Vui lòng chọn lý do để cải thiện dịch vụ.',
                style: TextStyle(fontSize: 14, color: _textSecondary),
              ),
              const SizedBox(height: 12),
              ...reasons.map(
                (r) => _buildReasonOption(
                  r['label']!,
                  r['value']!,
                  selectedReason,
                  (v) => setState(() => selectedReason = v),
                ),
              ),
              if (selectedReason == 'other') ...[
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) =>
                      selectedReason = v.trim().isEmpty ? 'other' : v.trim(),
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: Text('Đóng', style: TextStyle(color: _textSecondary)),
            ),
            FilledButton(
              onPressed: () {
                if (selectedReason == null || selectedReason!.isEmpty) return;
                Navigator.of(ctx).pop(selectedReason);
              },
              style: FilledButton.styleFrom(backgroundColor: _danger),
              child: const Text('Xác nhận hủy'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonOption(
    String label,
    String value,
    String? selected,
    Function(String) onSelect,
  ) {
    final isSelected = selected == value;
    return InkWell(
      onTap: () => onSelect(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _primary.withOpacity(0.06) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? _primary : _divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _primary : _textSecondary,
                  width: 2,
                ),
                color: isSelected ? _primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? _textPrimary : _textSecondary,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resolveMemberIncidentAddress(double lat, double lon) async {
    if (_isLoadingMemberAddress) return;
    setState(() => _isLoadingMemberAddress = true);
    final address = await _nominatimService.reverseGeocode(lat, lon);
    if (!mounted) return;
    setState(() {
      _memberIncidentAddress = address;
      _isLoadingMemberAddress = false;
      _memberIncidentAddressResolved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(detailedIncidentProvider);
    final incident = state.incident;

    if (incident != null &&
        (incident.address == null || incident.address!.isEmpty) &&
        !_isLoadingMemberAddress &&
        !_memberIncidentAddressResolved) {
      _resolveMemberIncidentAddress(
        incident.locationCoordinates.latitude,
        incident.locationCoordinates.longitude,
      );
    }

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _cardBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Chi tiết sự cố',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _textSecondary),
            onPressed: () => ref
                .read(detailedIncidentProvider.notifier)
                .refreshDetailedIncident(),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _divider),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : state.error != null
          ? _buildErrorState(state.error!)
          : incident == null
          ? const Center(child: Text('Không tìm thấy thông tin sự cố'))
          : RefreshIndicator(
              onRefresh: () async => ref
                  .read(detailedIncidentProvider.notifier)
                  .refreshDetailedIncident(),
              color: _primary,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusBanner(incident),
                    const SizedBox(height: 12),
                    _buildSnakeSection(incident),
                    const SizedBox(height: 12),
                    if (incident.severityLevel > 0) ...[
                      _buildSeverityCard(incident),
                      const SizedBox(height: 12),
                    ],
                    _buildInfoCard(incident),
                    const SizedBox(height: 12),
                    _buildSymptomsCard(incident),
                    const SizedBox(height: 12),
                    _buildVictimCard(incident.user),
                    const SizedBox(height: 12),
                    incident.activeMission != null &&
                            incident.assignedRescuer != null
                        ? _buildMissionCard(
                            incident.activeMission!,
                            incident.assignedRescuer!,
                          )
                        : _buildSearchingCard(),
                    if (incident.media.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildMediaCard(incident.media),
                    ],
                    const SizedBox(height: 16),
                    _buildCancelButton(incident),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => context.pop(),
        backgroundColor: _primary,
        child: const Icon(Icons.map_outlined, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: _danger),
            const SizedBox(height: 16),
            const Text(
              'Không thể tải thông tin',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref
                  .read(detailedIncidentProvider.notifier)
                  .loadDetailedIncident(widget.incidentId, forceRefresh: true),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Thử lại'),
              style: FilledButton.styleFrom(backgroundColor: _primary),
            ),
          ],
        ),
      ),
    );
  }

  // ── Status Banner ──────────────────────────────────────────────────────────
  Widget _buildStatusBanner(DetailedIncidentData incident) {
    final occurredAt = incident.incidentOccurredAt ?? incident.assignedAt;
    final elapsed = occurredAt != null
        ? DateTime.now().difference(occurredAt)
        : Duration.zero;
    final minutes = elapsed.inMinutes;
    final hasMission = incident.activeMission != null;

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
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.emergency_rounded,
              color: _primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yêu cầu SOS',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  occurredAt != null
                      ? '$minutes phút trước · ${_formatDateTime(occurredAt)}'
                      : 'Vừa gửi',
                  style: const TextStyle(fontSize: 12, color: _textSecondary),
                ),
              ],
            ),
          ),
          _StatusChip(
            label: hasMission ? 'Đang cứu hộ' : 'Đang tìm',
            color: hasMission ? const Color(0xFF1565C0) : _warning,
          ),
        ],
      ),
    );
  }

  // ── Snake Section ──────────────────────────────────────────────────────────
  Widget _buildSnakeSection(DetailedIncidentData incident) {
    if (incident.identifiedSnakeSpecies != null) {
      return _buildIdentifiedSnakeCard(
        incident.identifiedSnakeSpecies!,
        incident.identificationContext,
      );
    }
    return _buildPendingIdentificationCard();
  }

  Widget _buildIdentifiedSnakeCard(
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
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, size: 16, color: _primary),
                const SizedBox(width: 6),
                const Text(
                  'Loài rắn xác định',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _primary,
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
          const SizedBox(height: 4),
          Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: Color(0xFF155724),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 12),
          // Snake image
          if (species.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.zero),
              child: Image.network(
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

  Widget _buildPendingIdentificationCard() {
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
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.search_rounded, color: _warning, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đang xác định loài rắn',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Hệ thống đang phân tích ảnh bạn gửi',
                  style: TextStyle(fontSize: 12, color: _textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: _warning),
          ),
        ],
      ),
    );
  }

  // ── Severity Card ──────────────────────────────────────────────────────────
  Widget _buildSeverityCard(DetailedIncidentData incident) {
    final s = incident.severityLevel;
    final color = s >= 70
        ? _danger
        : s >= 40
        ? _warning
        : _primary;
    final label = s >= 70
        ? 'Nghiêm trọng'
        : s >= 40
        ? 'Trung bình'
        : 'Nhẹ';

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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$s',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mức độ nghiêm trọng',
                  style: TextStyle(fontSize: 12, color: _textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.pushNamed(
              'severity_assessment',
              extra: {
                'incidentId': incident.id,
                'recognitionResultId':
                    incident.identificationContext?.recognitionResultId,
              },
            ),
            child: const Text('Chi tiết', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ── Info Card (location + time) ────────────────────────────────────────────
  Widget _buildInfoCard(DetailedIncidentData incident) {
    final address = incident.address ?? _memberIncidentAddress;
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
            'Thông tin sự cố',
          ),
          const SizedBox(height: 12),
          _infoRow(
            Icons.my_location_outlined,
            'Tọa độ',
            '${incident.locationCoordinates.latitude.toStringAsFixed(5)}, ${incident.locationCoordinates.longitude.toStringAsFixed(5)}',
          ),
          if (_isLoadingMemberAddress) ...[
            const SizedBox(height: 8),
            _infoRow(Icons.place, 'Địa chỉ', 'Đang tải...'),
          ] else if (address != null && address.isNotEmpty) ...[
            const SizedBox(height: 8),
            _infoRow(Icons.place, 'Địa chỉ', address),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.map_outlined, size: 16),
              label: const Text(
                'Xem trên bản đồ',
                style: TextStyle(fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: _surface,
                backgroundColor: _primary,
                side: const BorderSide(color: _primary),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Symptoms Card ──────────────────────────────────────────────────────────
  Widget _buildSymptomsCard(DetailedIncidentData incident) {
    final symptoms = incident.symptomsReport ?? [];
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
              'Chưa có triệu chứng nào được ghi nhận',
              style: TextStyle(fontSize: 14, color: _textSecondary),
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

  // ── Victim Card ────────────────────────────────────────────────────────────
  Widget _buildVictimCard(BriefMemberProfile user) {
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
          if (user.account != null) ...[
            _infoRow(
              Icons.person_outline,
              'Họ tên',
              user.account!.fullName ?? 'N/A',
            ),
            if (user.phoneNumber != null) ...[
              const SizedBox(height: 8),
              _infoRow(Icons.phone_outlined, 'Điện thoại', user.phoneNumber!),
            ],
            if (user.account!.email != null) ...[
              const SizedBox(height: 8),
              _infoRow(Icons.email_outlined, 'Email', user.account!.email!),
            ],
          ],
          if (user.hasUnderlyingDisease) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: _warning,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Bệnh nhân có bệnh nền',
                    style: TextStyle(
                      fontSize: 13,
                      color: _warning,
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

  // ── Mission Card ───────────────────────────────────────────────────────────
  Widget _buildMissionCard(RescueMission mission, BriefRescuerProfile rescuer) {
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
                Icons.person_pin_outlined,
                const Color(0xFF1565C0),
                'Người cứu hộ',
              ),
              const Spacer(),
              _StatusChip(
                label: mission.status.displayText,
                color: const Color(0xFF1565C0),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (rescuer.account != null) ...[
            _infoRow(
              Icons.badge_outlined,
              'Họ tên',
              rescuer.account!.fullName ?? 'N/A',
            ),
            if (rescuer.phoneNumber != null) ...[
              const SizedBox(height: 8),
              _infoRow(
                Icons.phone_outlined,
                'Điện thoại',
                rescuer.phoneNumber!,
              ),
            ],
          ],
          if (rescuer.ratingCount > 0) ...[
            const SizedBox(height: 8),
            _infoRow(
              Icons.star_outline_rounded,
              'Đánh giá',
              '${rescuer.rating.toStringAsFixed(1)} (${rescuer.ratingCount} lần)',
            ),
          ],
          if (mission.startedAt != null) ...[
            const SizedBox(height: 8),
            _infoRow(
              Icons.schedule_outlined,
              'Bắt đầu',
              _formatDateTime(mission.startedAt!),
            ),
          ],
          if (mission.price > 0) ...[
            const SizedBox(height: 8),
            _infoRow(
              Icons.payments_outlined,
              'Phí dịch vụ',
              mission.formattedPrice,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchingCard() {
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
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_search_rounded,
              color: _warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đang tìm người cứu hộ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Hệ thống đang tìm đội cứu hộ gần nhất',
                  style: TextStyle(fontSize: 12, color: _textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: _warning),
          ),
        ],
      ),
    );
  }

  // ── Media Card ─────────────────────────────────────────────────────────────
  // Member view: show uploaded photos only — snake species is already shown
  // in the dedicated snake section above, no need to repeat AI results here.
  Widget _buildMediaCard(List<SnakeAIDetectMedia> mediaList) {
    if (mediaList.isEmpty) return const SizedBox.shrink();

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
                Icons.photo_library_outlined,
                const Color(0xFF4CAF50),
                'Ảnh đã gửi',
              ),
              const Spacer(),
              if (mediaList.length > 1)
                Text(
                  '${mediaList.length} ảnh',
                  style: const TextStyle(fontSize: 12, color: _textSecondary),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: PageView.builder(
              itemCount: mediaList.length,
              itemBuilder: (context, index) {
                final media = mediaList[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          media.mediaUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 200,
                            color: const Color(0xFFF0F0F0),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (mediaList.length > 1)
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              mediaList.length,
                              (i) => Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: i == index ? 16 : 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: i == index
                                      ? Colors.white
                                      : Colors.white54,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
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

  // ── Cancel Button ──────────────────────────────────────────────────────────
  Widget _buildCancelButton(DetailedIncidentData incident) {
    final canCancel = _canCancelIncident(
      incident.status,
      mission: incident.activeMission,
    );
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: canCancel ? _cancelIncident : null,
        style: ElevatedButton.styleFrom(
          foregroundColor: canCancel ? _surface : _textSecondary,
          backgroundColor: canCancel ? _danger : _divider,
          side: BorderSide(color: canCancel ? _danger : _divider),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          canCancel ? 'Hủy yêu cầu SOS' : 'Không thể hủy lúc này',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
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

  Widget _infoRow(IconData icon, String label, String value) {
    // Icon color map matching rescue_request_modal pattern
    Color _iconColor(IconData icon) {
      if (icon == Icons.person_outline || icon == Icons.badge_outlined)
        return const Color(0xFF1565C0);
      if (icon == Icons.phone_outlined) return const Color(0xFFFF6B35);
      if (icon == Icons.email_outlined) return const Color(0xFF1565C0);
      if (icon == Icons.place || icon == Icons.my_location_outlined)
        return const Color(0xFF4CAF50);
      if (icon == Icons.location_on_outlined) return const Color(0xFF4CAF50);
      if (icon == Icons.schedule_outlined || icon == Icons.access_time)
        return const Color(0xFFFF9800);
      if (icon == Icons.payments_outlined) return const Color(0xFF2E7D32);
      if (icon == Icons.star_outline_rounded) return Colors.amber;
      return _textSecondary;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: _iconColor(icon)),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
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

  String _formatDateTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}  ${dt.day}/${dt.month}/${dt.year}';
}

// ── Shared small widgets ───────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

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
