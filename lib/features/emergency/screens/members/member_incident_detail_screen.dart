import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/detailed_incident_response.dart';
import '../../models/snake_identification_response.dart';
import '../../providers/detailed_incident_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/snake_risk_badges.dart';

/// Member Incident Detail Screen
///
/// Comprehensive detail screen showing all incident information including:
/// - Incident overview (time, location, status)
/// - Snake identification results (if available)
/// - Severity assessment
/// - Symptoms report
/// - Emergency contacts
/// - Mission information (when rescuer accepts)
///
/// This screen is OPTIONAL - member can stay on tracking screen entire time.
/// Acts as a "spoke" from the tracking hub for users who want detailed info.
class MemberIncidentDetailScreen extends ConsumerStatefulWidget {
  final String incidentId;

  const MemberIncidentDetailScreen({super.key, required this.incidentId});

  @override
  ConsumerState<MemberIncidentDetailScreen> createState() =>
      _MemberIncidentDetailScreenState();
}

class _MemberIncidentDetailScreenState
    extends ConsumerState<MemberIncidentDetailScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('📋 [IncidentDetail] Opened for incident: ${widget.incidentId}');

    // Load detailed incident via provider (uses smart caching)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get incident ID - prefer from active incident provider if widget.incidentId is empty
      final activeIncidentId = ref
          .read(activeIncidentProvider)
          .activeIncidentId;
      final incidentId = widget.incidentId.isNotEmpty
          ? widget.incidentId
          : (activeIncidentId ?? '');

      debugPrint('🔍 Using incident ID: $incidentId');

      if (incidentId.isEmpty) {
        debugPrint('❌ No incident ID available!');
        return;
      }

      // Check if we already have cached data
      final detailedIncidentState = ref.read(detailedIncidentProvider);
      final hasValidCache =
          detailedIncidentState.incident?.id == incidentId &&
          detailedIncidentState.isCacheFresh;

      if (hasValidCache) {
        debugPrint('✅ Using cached incident data (fresh)');
        return; // Use cached data, no need to fetch
      }

      // Otherwise, load from API (will use smart caching)
      ref.read(detailedIncidentProvider.notifier).loadIfStale(incidentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final detailedIncidentState = ref.watch(detailedIncidentProvider);
    final incident = detailedIncidentState.incident;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.map, color: Color(0xFF228B22)),
          onPressed: () => context.pop(),
          tooltip: 'Quay về bản đồ',
        ),
        title: const Text(
          'Chi tiết sự cố',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191910),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF666666)),
            onPressed: () {
              ref
                  .read(detailedIncidentProvider.notifier)
                  .refreshDetailedIncident();
            },
            tooltip: 'Làm mới',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.map),
        label: const Text(
          'Về bản đồ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF228B22),
      ),
      body: detailedIncidentState.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF228B22)),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải thông tin sự cố...',
                    style: TextStyle(color: Color(0xFF666666)),
                  ),
                ],
              ),
            )
          : detailedIncidentState.error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Color(0xFFE53935),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Không thể tải thông tin sự cố',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      detailedIncidentState.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF666666)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(detailedIncidentProvider.notifier)
                            .loadDetailedIncident(
                              widget.incidentId,
                              forceRefresh: true,
                            );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : incident == null
          ? const Center(child: Text('Không tìm thấy thông tin sự cố'))
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(detailedIncidentProvider.notifier)
                    .refreshDetailedIncident();
              },
              color: const Color(0xFF228B22),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SECTION 1: Status Overview
                    _buildStatusOverview(incident),
                    const SizedBox(height: 16),

                    // SECTION 2: Identified Snake Species (QUAN TRỌNG)
                    incident.identifiedSnakeSpecies != null
                        ? _buildIdentifiedSnakeCard(
                            incident.identifiedSnakeSpecies!,
                            incident.identificationContext,
                          )
                        : _buildWaitingForIdentificationCard(),
                    const SizedBox(height: 16),

                    // SECTION 2.5: Severity Assessment (if available)
                    if (incident.severityLevel > 0)
                      _buildSeverityScoreCard(incident),
                    if (incident.severityLevel > 0) const SizedBox(height: 16),

                    // SECTION 3: Incident Information
                    _buildLocationCard(incident),
                    const SizedBox(height: 16),

                    _buildSymptomsCard(incident),
                    const SizedBox(height: 16),

                    // SECTION 4: User Info
                    _buildUserInfoCard(incident.user),
                    const SizedBox(height: 16),

                    // SECTION 5: Mission Info (if rescuer accepted)
                    if (incident.activeMission != null &&
                        incident.assignedRescuer != null)
                      _buildMissionSection(
                        incident.activeMission!,
                        incident.assignedRescuer!,
                      )
                    else
                      _buildWaitingForRescuerCard(),

                    const SizedBox(height: 16),

                    // ═══════════════════════════════════════════════════
                    // SECTION 6: Media & AI Detection (Reference)
                    // Shows uploaded photos with AI analysis results
                    // ═══════════════════════════════════════════════════
                    if (incident.media.isNotEmpty) ...[
                      _buildMediaDetectionCard(incident.media),
                    ],

                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusOverview(DetailedIncidentData incident) {
    final occurredAt = incident.incidentOccurredAt ?? incident.assignedAt;
    final elapsed = occurredAt != null
        ? DateTime.now().difference(occurredAt)
        : Duration.zero;
    final minutes = elapsed.inMinutes;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF228B22).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF228B22),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emergency,
                  color: Colors.white,
                  size: 24,
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF191910),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$minutes phút trước',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: incident.activeMission != null
                      ? Colors.blue
                      : Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  incident.activeMission != null ? 'Đang cứu hộ' : 'Đang tìm',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          if (occurredAt != null) ...[
            _buildInfoRow(
              Icons.access_time,
              'Thời gian',
              _formatDateTime(occurredAt),
            ),
            const SizedBox(height: 8),
          ],
          _buildInfoRow(
            Icons.location_on,
            'Vị trí',
            '${incident.locationCoordinates.latitude.toStringAsFixed(4)}, ${incident.locationCoordinates.longitude.toStringAsFixed(4)}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF228B22)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Color(0xFF191910)),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(DetailedIncidentData incident) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on, color: Color(0xFFDC3545), size: 20),
              SizedBox(width: 8),
              Text(
                'Vị trí sự cố',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191910),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Tọa độ: ${incident.locationCoordinates.latitude.toStringAsFixed(6)}, ${incident.locationCoordinates.longitude.toStringAsFixed(6)}',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.map, size: 18),
              label: const Text('Xem trên bản đồ'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF228B22),
                side: const BorderSide(color: Color(0xFF228B22)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsCard(DetailedIncidentData incident) {
    final hasSymptoms = incident.symptomsReport?.isNotEmpty ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasSymptoms ? const Color(0xFFFFF3E0) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasSymptoms
              ? const Color(0xFFFF9800).withOpacity(0.3)
              : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_services,
                color: hasSymptoms
                    ? const Color.fromARGB(255, 218, 2, 2)
                    : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Triệu chứng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191910),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasSymptoms)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: incident.symptomsReport!
                  .map(
                    (symptom) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• ${symptom.symptomName}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),
                  )
                  .toList(),
            )
          else
            Text(
              'Chưa có triệu chứng nào được ghi nhận',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
        ],
      ),
    );
  }

  Widget _buildSeverityScoreCard(DetailedIncidentData incident) {
    final severity = incident.severityLevel;

    Color getSeverityColor() {
      if (severity >= 70) {
        return const Color(0xFFDC3545); // Critical red
      } else if (severity >= 40) {
        return const Color(0xFFF59E0B); // Warning amber
      } else {
        return const Color(0xFF228B22); // Safe green
      }
    }

    String getSeverityLabel() {
      if (severity >= 70) {
        return 'Nghiêm trọng';
      } else if (severity >= 40) {
        return 'Trung bình';
      } else {
        return 'Nhẹ';
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: severity >= 70
              ? [const Color(0xFFFFEBEE), const Color(0xFFFFCDD2)]
              : severity >= 40
              ? [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)]
              : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Score circle (compact version)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(blurRadius: 4, color: Colors.black.withOpacity(0.1)),
              ],
            ),
            child: Center(
              child: Text(
                '$severity',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: getSeverityColor(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.medical_services,
                      size: 16,
                      color: getSeverityColor(),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Mức độ nghiêm trọng',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  getSeverityLabel(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: getSeverityColor(),
                  ),
                ),
              ],
            ),
          ),
          // View full assessment button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.pushNamed(
                'severity_assessment',
                extra: {
                  'incidentId': incident.id,
                  'recognitionResultId':
                      incident.identificationContext?.recognitionResultId,
                },
              ),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Chi tiết',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: getSeverityColor(),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: getSeverityColor(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionSection(
    RescueMission mission,
    BriefRescuerProfile rescuer,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person, color: Color(0xFF2196F3), size: 20),
              SizedBox(width: 8),
              Text(
                'Nhiệm vụ cứu hộ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191910),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (rescuer.account != null) ...[
            _buildInfoRow(
              Icons.badge,
              'Rescuer',
              rescuer.account!.fullName ?? 'N/A',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.phone,
              'Điện thoại',
              rescuer.phoneNumber ?? 'N/A',
            ),
          ],
          if (mission.startedAt != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.timer,
              'Bắt đầu',
              _formatDateTime(mission.startedAt!),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.check_circle, size: 18, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                'Trạng thái: ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                mission.status.displayText,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build identified snake card (official confirmed species for this incident)
  Widget _buildIdentifiedSnakeCard(
    DetectedSnakeSpecies species,
    SnakeIdentificationContext? context,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF228B22), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF228B22).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with badge
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF228B22),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Loài rắn của sự cố này',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF191910),
                      ),
                    ),
                  ],
                ),
              ),
              if (context != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.method == SnakeIdentificationMethod.ai
                        ? const Color(0xFF2196F3).withOpacity(0.1)
                        : const Color(0xFF9C27B0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        context.method == SnakeIdentificationMethod.ai
                            ? Icons.smart_toy
                            : Icons.person,
                        size: 12,
                        color: context.method == SnakeIdentificationMethod.ai
                            ? const Color(0xFF2196F3)
                            : const Color(0xFF9C27B0),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.method == SnakeIdentificationMethod.ai
                            ? 'AI'
                            : 'Chuyên gia',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.method == SnakeIdentificationMethod.ai
                              ? const Color(0xFF2196F3)
                              : const Color(0xFF9C27B0),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildConfirmedSpeciesCard(species),
        ],
      ),
    );
  }

  /// Build media detection card (AI analysis from photos)
  Widget _buildMediaDetectionCard(List<SnakeAIDetectMedia> mediaList) {
    // Filter to only show media with detected species
    final mediaWithDetection = mediaList
        .where((m) => m.hasDetectedSpecies)
        .toList();

    if (mediaWithDetection.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.photo_camera,
                color: const Color(0xFF2196F3),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Ảnh chụp và nhận diện',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191910),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Kết quả phân tích AI từ ảnh bạn gửi',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          _buildDetectedSpeciesCarousel(mediaWithDetection),
        ],
      ),
    );
  }

  /// Build confirmed species card
  Widget _buildConfirmedSpeciesCard(DetectedSnakeSpecies species) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Snake image
        if (species.imageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              species.imageUrl!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 160,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.pets, size: 48, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 12),

        // Species info card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: SnakeRiskBadges.getRiskGradient(species.riskLevel),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: SnakeRiskBadges.getRiskColor(species.riskLevel),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: SnakeRiskBadges.getRiskColor(species.riskLevel),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      SnakeRiskBadges.getRiskIcon(species.riskLevel),
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          species.commonName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: SnakeRiskBadges.getRiskColor(
                              species.riskLevel,
                            ),
                          ),
                        ),
                        Text(
                          species.scientificName,
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: SnakeRiskBadges.getRiskColor(
                              species.riskLevel,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
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
            ],
          ),
        ),
      ],
    );
  }

  /// Build detected species carousel (before confirmation)
  Widget _buildDetectedSpeciesCarousel(
    List<SnakeAIDetectMedia> mediaWithDetection,
  ) {
    return SizedBox(
      height: 380,
      child: PageView.builder(
        itemCount: mediaWithDetection.length,
        itemBuilder: (context, index) {
          final media = mediaWithDetection[index];
          final species = media.detectedSpecies.first;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Snake image
                if (species.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      species.imageUrl!,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 140,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.error, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                // Page indicator
                if (mediaWithDetection.length > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      mediaWithDetection.length,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == index ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == index
                              ? const Color(0xFF43A047)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                if (mediaWithDetection.length > 1) const SizedBox(height: 12),
                // Species info card - more prominent
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: SnakeRiskBadges.getRiskGradient(
                        species.riskLevel,
                      ),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: SnakeRiskBadges.getRiskColor(species.riskLevel),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: SnakeRiskBadges.getRiskColor(
                          species.riskLevel,
                        ).withOpacity(0.2),
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
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: SnakeRiskBadges.getRiskColor(
                                species.riskLevel,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              SnakeRiskBadges.getRiskIcon(species.riskLevel),
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  species.commonName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: SnakeRiskBadges.getRiskColor(
                                      species.riskLevel,
                                    ).withOpacity(0.9),
                                  ),
                                ),
                                Text(
                                  species.scientificName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          SnakeRiskBadges.buildRiskLevelBadge(
                            species.riskLevel,
                          ),
                          SnakeRiskBadges.buildVenomTypeBadge(
                            species.primaryVenomType,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Badge components moved to SnakeRiskBadges widget for reuse

  Widget _buildUserInfoCard(BriefMemberProfile user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person, color: Color(0xFF228B22), size: 20),
              SizedBox(width: 8),
              Text(
                'Thông tin nạn nhân',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191910),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (user.account != null) ...[
            _buildInfoRow(
              Icons.badge,
              'Họ tên',
              user.account!.fullName ?? 'N/A',
            ),
            if (user.phoneNumber != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.phone, 'Điện thoại', user.phoneNumber!),
            ],
            if (user.account!.email != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.email, 'Email', user.account!.email!),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildWaitingForRescuerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.person_search, color: Color(0xFFFFC107), size: 48),
          const SizedBox(height: 12),
          const Text(
            'Đang tìm kiếm người cứu hộ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF191910),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hệ thống đang tìm đội cứu hộ gần bạn nhất',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingForIdentificationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFB300).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB300).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search, color: Color(0xFFFFB300), size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'Đang xác định loài rắn',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF191910),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hệ thống đang phân tích để xác định loài rắn trong sự cố này',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFFFFB300),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Đang xử lý...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}, ${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  // Risk color helpers moved to SnakeRiskBadges widget for reuse
}
