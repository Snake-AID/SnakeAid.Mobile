import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:snakeaid_mobile/features/emergency/models/snake_identification_response.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/rescue_mission_response.dart';
import '../../models/detailed_incident_response.dart';
import '../../models/route_navigation_data.dart';
import '../../providers/mission_detail_provider.dart';
import '../../providers/active_mission_provider.dart';
import '../../providers/rescuer_emergency_provider.dart';
import '../../widgets/snake_risk_badges.dart';
import '../../../../core/utils/distance_utils.dart';
import '../../../../core/providers/openroute_provider.dart';
import '../../../../core/services/nominatim_service.dart';
import '../../../../core/services/openroute_service.dart';
import '../../providers/mission_hub_provider.dart' hide MissionStatus;
import '../../../rescuer/providers/tracking_provider.dart';

/// Rescuer Mission Detail Screen
/// Main screen for rescuer to view mission details and manage status
class RescuerMissionDetailScreen extends ConsumerStatefulWidget {
  final String missionId;

  const RescuerMissionDetailScreen({super.key, required this.missionId});

  @override
  ConsumerState<RescuerMissionDetailScreen> createState() =>
      _RescuerMissionDetailScreenState();
}

class _RescuerMissionDetailScreenState
    extends ConsumerState<RescuerMissionDetailScreen> {
  Timer? _elapsedTimer;
  Duration _elapsedTime = Duration.zero;
  StreamSubscription<Position>? _locationSubscription;
  RouteNavigationData? _routeData; // Route data from OpenRouteService
  String? _routeError;
  final List<StreamSubscription> _missionHubSubscriptions = [];

  // Address fallback support
  final _nominatimService = NominatimService();
  String? _incidentAddress;
  bool _isLoadingIncidentAddress = false;

  @override
  void initState() {
    super.initState();
    _loadMissionAndStartTracking();
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _locationSubscription?.cancel();
    for (final s in _missionHubSubscriptions) {
      s.cancel();
    }

    // NOTE: We do NOT stop LocationManager or disconnect MissionHub here because:
    // 1. User may navigate to Navigation screen → still need GPS broadcast
    // 2. LocationManager and MissionHub must persist across screen transitions
    // 3. They will be stopped only when mission truly ends (completed/cancelled)
    // 4. This matches member-side architecture where connections persist globally

    super.dispose();
  }

  Future<void> _loadMissionAndStartTracking() async {
    // Get current location
    try {
      final position = await Geolocator.getCurrentPosition();

      // Load mission with location
      await ref
          .read(missionDetailProvider.notifier)
          .loadMissionDetail(
            missionId: widget.missionId,
            rescuerLocation: position,
          );

      // Resolve incident address (from API or fallback OSM reverse geocode)
      await _resolveIncidentAddress();

      // Connect to MissionHub for real-time bidirectional GPS
      final mission = ref.read(missionDetailProvider).mission;
      if (mission != null) {
        try {
          await ref
              .read(missionHubConnectionProvider.notifier)
              .connectForIncident(mission.incident.id);
          debugPrint(
            '✅ Rescuer connected to MissionHub for incident: ${mission.incident.id}',
          );

          // Setup listener for member location updates
          _setupMissionHubListeners();

          try {
            final prefs = await SharedPreferences.getInstance();
            final rescuerId = prefs.getString('user_id');
            if (rescuerId != null) {
              final missionHubService = ref.read(missionHubServiceProvider);
              await ref
                  .read(locationManagerProvider)
                  .startMissionTracking(
                    rescuerId,
                    mission.incident.id,
                    missionHubService,
                  );
              debugPrint(
                '✅ [MissionDetail] Started GPS broadcast to MissionHub',
              );
            } else {
              debugPrint('⚠️ [MissionDetail] No rescuer ID found');
            }
          } catch (e) {
            debugPrint('❌ [MissionDetail] Failed to start GPS broadcast: $e');
          }
        } catch (e) {
          debugPrint('⚠️ Failed to connect to MissionHub: $e');
        }
      }

      // Start location tracking
      _startLocationTracking();

      // Start elapsed timer
      _startElapsedTimer();
    } catch (e) {
      debugPrint('❌ Error loading mission: $e');

      // Load mission without location
      await ref
          .read(missionDetailProvider.notifier)
          .loadMissionDetail(missionId: widget.missionId);
    }
  }

  void _startLocationTracking() {
    // This stream is ONLY for local provider updates (distance/ETA display)
    _locationSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 15, // Match LocationManager for consistency
          ),
        ).listen((position) {
          // Update local provider for distance/ETA calculations
          ref
              .read(missionDetailProvider.notifier)
              .updateRescuerLocation(position);
        });
  }

  Future<void> _resolveIncidentAddress() async {
    final mission = ref.read(missionDetailProvider).mission;
    if (mission == null) return;

    final addressFromApi = mission.incident.address;
    if (addressFromApi != null && addressFromApi.isNotEmpty) {
      setState(() {
        _incidentAddress = addressFromApi;
      });
      return;
    }

    setState(() {
      _isLoadingIncidentAddress = true;
    });

    final lat = mission.incident.locationCoordinates.latitude;
    final lon = mission.incident.locationCoordinates.longitude;
    final address = await _nominatimService.reverseGeocode(lat, lon);

    setState(() {
      _incidentAddress = address ?? 'Không xác định';
      _isLoadingIncidentAddress = false;
    });
  }

  void _setupMissionHubListeners() {
    final svc = ref.read(missionHubServiceProvider);

    // Listen for member live location updates
    _missionHubSubscriptions.add(
      svc.memberLocationUpdatedStream.listen((data) {
        debugPrint(
          '📍 [RescuerDetail] Member location updated: ${data.latitude}, ${data.longitude}',
        );
        // Could update a state variable here if you want to show member location on preview map
      }),
    );
  }

  void _startElapsedTimer() {
    final mission = ref.read(missionDetailProvider).mission;
    if (mission == null) return;

    // Calculate initial elapsed time
    if (mission.startedAt != null) {
      _elapsedTime = DateTime.now().difference(mission.startedAt!);
    }

    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime += const Duration(seconds: 1);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(missionDetailProvider);

    if (state.isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F7F5),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF8800)),
        ),
      );
    }

    if (state.error != null && state.error!.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F7F5),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Nhiệm vụ cứu hộ'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  state.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.read(missionDetailProvider.notifier).refresh();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8800),
                  ),
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
        backgroundColor: const Color(0xFFF8F7F5),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Nhiệm vụ cứu hộ'),
        ),
        body: const Center(child: Text('Không tìm thấy nhiệm vụ')),
      );
    }

    // Allow user to view details in any status
    // No auto-redirect - let user choose to navigate
    final status = mission.missionStatus;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      body: Column(
        children: [
          _buildHeader(mission),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Small preview map - show for active missions
                  if (status == MissionStatus.preparing ||
                      status == MissionStatus.enRoute ||
                      status == MissionStatus.rescuerArrived)
                    _buildPreviewMapSection(mission, state),
                  _buildActionButton(mission, state),
                  const SizedBox(height: 16),
                  _buildContent(mission, state),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(DetailRescueMissionResponse mission) {
    final status = mission.missionStatus;
    Color statusColor;
    String statusText;

    switch (status) {
      case MissionStatus.preparing:
        statusColor = const Color(0xFFFF9800);
        statusText = 'ĐANG CHUẨN BỊ';
        break;
      case MissionStatus.enRoute:
        statusColor = const Color(0xFF2196F3);
        statusText = 'ĐANG DI CHUYỂN';
        break;
      case MissionStatus.rescuerArrived:
        statusColor = const Color(0xFF4CAF50);
        statusText = 'ĐÃ ĐẾN NƠI';
        break;
      case MissionStatus.missionCompleted:
        statusColor = const Color(0xFF10B981);
        statusText = 'HOÀN THÀNH';
        break;
      case MissionStatus.missionUncompleted:
        statusColor = const Color(0xFFF59E0B);
        statusText = 'CHƯA HOÀN THÀNH';
        break;
      case MissionStatus.missionAborted:
        statusColor = const Color(0xFFEF4444);
        statusText = 'ĐÃ HỦY BỎ';
        break;
      case MissionStatus.cancelled:
        statusColor = const Color(0xFF9E9E9E);
        statusText = 'ĐÃ HỦY';
        break;
    }

    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'NHIỆM VỤ CỨU HỘ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.phone),
                  onPressed: () =>
                      _makePhoneCall(mission.user.phoneNumber ?? ''),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8800).withOpacity(0.1),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showOptionsMenu(mission),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (_elapsedTime.inSeconds > 0) ...[
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _formatElapsedTime(_elapsedTime),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatElapsedTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Small preview map for Preparing state (200px height)
  Widget _buildPreviewMapSection(
    DetailRescueMissionResponse mission,
    MissionDetailState state,
  ) {
    final incidentLat = mission.incident.locationCoordinates.latitude;
    final incidentLon = mission.incident.locationCoordinates.longitude;
    final incidentLatLng = LatLng(incidentLat, incidentLon);

    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: incidentLatLng,
              initialZoom: 13.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none, // Disable interaction
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.snakeaid.mobile',
              ),
              MarkerLayer(
                markers: [
                  // Victim location (red pin)
                  Marker(
                    point: incidentLatLng,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                  // Rescuer location (blue dot) if available
                  if (state.rescuerLocation != null)
                    Marker(
                      point: LatLng(
                        state.rescuerLocation!.latitude,
                        state.rescuerLocation!.longitude,
                      ),
                      width: 30,
                      height: 30,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          // Preview label overlay
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    'Vị trí nạn nhân',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Distance info if available
          if (state.distanceKm != null)
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  DistanceUtils.formatDistance(state.distanceKm!),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    DetailRescueMissionResponse mission,
    MissionDetailState state,
  ) {
    final status = mission.missionStatus;

    // Special handling for EnRoute: show only navigation button
    // "Đã đến nơi" should only be pressed in Navigation Screen to avoid conflict
    if (status == MissionStatus.enRoute) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _navigateToNavigation(mission, state),
            icon: const Icon(Icons.navigation, color: Colors.white),
            label: const Text(
              'QUAY LẠI ĐIỀU HƯỚNG',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8800),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    }

    // Standard single button for other statuses
    String buttonText;
    Color buttonColor;
    IconData buttonIcon;
    VoidCallback? onPressed;

    switch (status) {
      case MissionStatus.preparing:
        buttonText = 'BẮT ĐẦU DI CHUYỂN';
        buttonColor = const Color(0xFFFF8800);
        buttonIcon = Icons.directions_car;
        onPressed = state.isUpdatingStatus ? null : () => _startMission();
        break;
      case MissionStatus.rescuerArrived:
        buttonText = 'BẮT ĐẦU XỬ LÝ';
        buttonColor = const Color(0xFFFF6B35);
        buttonIcon = Icons.local_hospital;
        onPressed = () => _navigateToSupport(mission);
        break;
      default:
        return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: state.isUpdatingStatus
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(buttonIcon, color: Colors.white),
          label: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    DetailRescueMissionResponse mission,
    MissionDetailState state,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMissionPriceCard(mission),
          const SizedBox(height: 16),
          // Identified Snake Section (Official confirmed species)
          if (mission.incident.identifiedSnakeSpecies != null) ...[
            _buildIdentifiedSnakeCard(
              mission.incident.identifiedSnakeSpecies!,
              mission.incident.identificationContext,
            ),
            const SizedBox(height: 16),
          ],
          _buildVictimInfoCard(mission),
          const SizedBox(height: 16),
          _buildEmergencyContactsCard(mission),
          const SizedBox(height: 16),
          _buildLocationCard(mission),
          const SizedBox(height: 16),
          _buildMissionDetailsCard(mission),
          const SizedBox(height: 16),
          _buildSymptomsCard(mission),
          const SizedBox(height: 16),
          _buildSnakeDetectionCard(mission),
          const SizedBox(height: 16),
          _buildIncidentTimeCard(mission),
        ],
      ),
    );
  }

  // Helper method definitions continued in part 2...
  // (The file is getting long, I'll create the helper methods)

  Widget _buildMissionPriceCard(DetailRescueMissionResponse mission) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.attach_money,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phí dịch vụ',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  mission.formattedPrice,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVictimInfoCard(DetailRescueMissionResponse mission) {
    final user = mission.user;
    final account = user.account;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '👤 Thông tin nạn nhân',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFFFF8800).withOpacity(0.1),
                backgroundImage: account?.avatarUrl != null
                    ? NetworkImage(account!.avatarUrl!)
                    : null,
                child: account?.avatarUrl == null
                    ? Text(
                        account?.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF8800),
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
                      account?.fullName ?? 'Không rõ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (user.ratingCount > 0)
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${user.rating.toStringAsFixed(1)} (${user.ratingCount})',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.phone, color: Color(0xFFFF8800)),
                onPressed: () => _makePhoneCall(user.phoneNumber ?? ''),
              ),
            ],
          ),
          if (user.hasUnderlyingDisease) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '⚠️ Bệnh nhân có bệnh nền',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildEmergencyContactsCard(DetailRescueMissionResponse mission) {
    final contacts = mission.user.emergencyContacts
        .where((c) => c.trim().isNotEmpty)
        .toList();

    final hasContacts = contacts.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasContacts ? const Color(0xFFFFF3E0) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasContacts
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
                Icons.phone_in_talk,
                color: hasContacts ? const Color(0xFFFF6B35) : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Liên hệ khẩn cấp',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: hasContacts ? Colors.black87 : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasContacts)
            ...contacts.asMap().entries.map((entry) {
              final index = entry.key;
              final phone = entry.value;
              return Column(
                children: [
                  if (index > 0) const Divider(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(
                          0xFFFF9800,
                        ).withOpacity(0.2),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF6B35),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          phone,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone),
                        onPressed: () => _makePhoneCall(phone),
                        color: const Color(0xFFFF6B35),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }).toList()
          else
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Người dùng chưa cung cấp số liên hệ khẩn cấp',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Continued in next message...
  // Due to length limits, I'll split the file into parts

  Widget _buildLocationCard(DetailRescueMissionResponse mission) {
    final lat = mission.incident.locationCoordinates.latitude;
    final lon = mission.incident.locationCoordinates.longitude;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.place,
                  color: Color(0xFF4CAF50),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Địa điểm',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Tọa độ: ${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            _isLoadingIncidentAddress
                ? 'Đang tải địa chỉ...'
                : (_incidentAddress ??
                      mission.incident.address ??
                      'Không xác định'),
            style: const TextStyle(fontSize: 14, color: Color(0xFF444444)),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionDetailsCard(DetailRescueMissionResponse mission) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💼 Chi tiết nhiệm vụ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (mission.incident.address != null &&
              mission.incident.address!.isNotEmpty) ...[
            _buildDetailRow('Địa chỉ', mission.incident.address!),
            const Divider(height: 20),
          ],
          _buildDetailRow(
            'Mức độ nghiêm trọng',
            mission.incident.getSeverityText(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSymptomsCard(DetailRescueMissionResponse mission) {
    final hasSymptoms =
        mission.incident.symptomsReport != null &&
        mission.incident.symptomsReport!.isNotEmpty;

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
                  color: hasSymptoms ? Colors.black87 : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          hasSymptoms
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: mission.incident.symptomsReport!
                      .map(
                        (symptom) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '• ${symptom.symptomName}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                )
              : Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Người dùng chưa cung cấp thông tin',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildSnakeDetectionCard(DetailRescueMissionResponse mission) {
    final media = mission.incident.media;
    final hasMedia = media.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.image, color: Color(0xFF4CAF50), size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Hình ảnh & nhận diện',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              if (hasMedia && media.length > 1)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${media.length} ảnh',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasMedia)
            SizedBox(
              height: 400,
              child: PageView.builder(
                itemCount: media.length,
                itemBuilder: (context, index) {
                  final currentMedia = media[index];
                  final hasAI = currentMedia.detectedSpecies.isNotEmpty;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            currentMedia.mediaUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
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
                        if (media.length > 1)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              media.length,
                              (i) => Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: i == index ? 20 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: i == index
                                      ? const Color(0xFF4CAF50)
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        if (media.length > 1) const SizedBox(height: 12),
                        // AI Detection Result
                        if (hasAI)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: SnakeRiskBadges.getRiskGradient(
                                  currentMedia.detectedSpecies.first.riskLevel,
                                ),
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: SnakeRiskBadges.getRiskColor(
                                  currentMedia.detectedSpecies.first.riskLevel,
                                ),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: SnakeRiskBadges.getRiskColor(
                                    currentMedia
                                        .detectedSpecies
                                        .first
                                        .riskLevel,
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
                                          currentMedia
                                              .detectedSpecies
                                              .first
                                              .riskLevel,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        SnakeRiskBadges.getRiskIcon(
                                          currentMedia
                                              .detectedSpecies
                                              .first
                                              .riskLevel,
                                        ),
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currentMedia
                                                .detectedSpecies
                                                .first
                                                .commonName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                255,
                                                5,
                                                30,
                                                58,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            currentMedia
                                                .detectedSpecies
                                                .first
                                                .scientificName,
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SnakeRiskBadges.buildRiskLevelBadge(
                                      currentMedia
                                          .detectedSpecies
                                          .first
                                          .riskLevel,
                                    ),
                                    const SizedBox(height: 8),
                                    SnakeRiskBadges.buildVenomTypeBadge(
                                      currentMedia
                                          .detectedSpecies
                                          .first
                                          .primaryVenomType,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        else if (currentMedia.isProcessed)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[400]!,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 20,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Không nhận diện được loài rắn',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFF9800),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Icon(
                                    Icons.hourglass_top,
                                    size: 20,
                                    color: Color(0xFFFF9800),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Chưa có kết quả nhận diện.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange[900],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Người dùng chưa cung cấp hình ảnh',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIncidentTimeCard(DetailRescueMissionResponse mission) {
    final occurredAt = mission.incident.incidentOccurredAt;

    if (occurredAt != null) {
      final elapsed = DateTime.now().difference(occurredAt);
      final minutes = elapsed.inMinutes;

      String timeText;
      Color timeColor;

      if (minutes < 60) {
        timeText = '$minutes phút trước';
        timeColor = minutes > 30
            ? const Color(0xFFD32F2F)
            : const Color(0xFFFF9800);
      } else {
        final hours = minutes ~/ 60;
        final remainingMinutes = minutes % 60;
        timeText = '$hours giờ $remainingMinutes phút trước';
        timeColor = const Color(0xFFD32F2F);
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: timeColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: timeColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: timeColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.access_time, color: timeColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thời gian xảy ra',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.access_time_outlined,
                color: Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thời gian xảy ra',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Không xác định',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  // Helper widgets

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
                        color: Color(0xFF1C100D),
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
      ),
    );
  }

  // Action methods

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanedPhone = phoneNumber.trim().replaceAll(RegExp(r'[^0-9+]'), '');

    if (cleanedPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Số điện thoại không hợp lệ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: cleanedPhone);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (e) {
      debugPrint('❌ Failed to make call: $e');
    }
  }

  Future<void> _startMission() async {
    // First, fetch route from OpenRouteService
    await _fetchRoute();

    // If route fetch failed, show error and don't proceed
    if (_routeError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $_routeError'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Then start the mission (update status to EnRoute)
    final success = await ref
        .read(missionDetailProvider.notifier)
        .startMission();

    if (!mounted) return;

    if (success) {
      // Update active mission status to EnRoute
      await ref
          .read(activeMissionProvider.notifier)
          .updateMissionStatus('EnRoute');
      debugPrint('💾 Active mission status updated: EnRoute');

      final mission = ref.read(missionDetailProvider).mission;
      final routeData = ref.read(missionDetailProvider).routeData;

      // Navigate to full-screen Navigation Screen
      debugPrint('🗺️ Navigating to Navigation Screen');
      debugPrint('   Route points: ${routeData?.points.length ?? 0}');
      debugPrint('   Distance: ${routeData?.formattedDistance}');
      debugPrint('   Duration: ${routeData?.formattedDuration}');

      context.push(
        '/rescuer/navigation',
        extra: {
          'missionId': mission!.id,
          'mission': mission,
          'routeData': routeData,
        },
      );

      // Show success message briefly before navigation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Đã bắt đầu di chuyển'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      final error = ref.read(missionDetailProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Lỗi khi bắt đầu nhiệm vụ'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchRoute() async {
    final state = ref.read(missionDetailProvider);
    final mission = state.mission;
    final rescuerLocation = state.rescuerLocation;

    if (mission == null || rescuerLocation == null) {
      debugPrint('⚠️ Cannot fetch route: missing mission or location');
      return;
    }

    setState(() {
      _routeError = null;
    });

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🗺️ Fetching Route from OpenRouteService...');
    debugPrint(
      '   Start: ${rescuerLocation.latitude}, ${rescuerLocation.longitude}',
    );
    debugPrint(
      '   End: ${mission.incident.locationCoordinates.latitude}, ${mission.incident.locationCoordinates.longitude}',
    );

    try {
      final openRoute = ref.read(openRouteServiceProvider);
      final route = await openRoute.getRoute(
        start: LatLng(rescuerLocation.latitude, rescuerLocation.longitude),
        end: LatLng(
          mission.incident.locationCoordinates.latitude,
          mission.incident.locationCoordinates.longitude,
        ),
      );

      if (mounted) {
        setState(() {
          _routeData = RouteNavigationData(
            points: route.points,
            distanceKm: route.distanceKm,
            durationMinutes: route.durationMinutes,
            steps: route.steps.isNotEmpty
                ? route
                      .steps // Use parsed steps from OpenRoute API
                : [
                    // Fallback if no steps parsed
                    RouteStep(
                      instruction: 'Đi theo đường màu cam đến vị trí nạn nhân',
                      distanceMeters: route.distanceKm * 1000,
                      durationSeconds: route.durationMinutes * 60,
                      type: 7, // Continue straight
                      roadName: null,
                    ),
                  ],
          );
        });

        // Save routeData to provider
        ref.read(missionDetailProvider.notifier).setRouteData(_routeData!);

        debugPrint('✅ Route fetched successfully!');
        debugPrint('   📍 Points: ${route.points.length}');
        debugPrint('   📏 Distance: ${route.formattedDistance}');
        debugPrint('   ⏱️ Duration: ${route.formattedDuration}');
        debugPrint('   🧭 Instructions: ${route.steps.length} steps');
        if (route.steps.isNotEmpty) {
          debugPrint('   → First: ${route.steps.first.instruction}');
          if (route.steps.length > 1) {
            debugPrint('   → Second: ${route.steps[1].instruction}');
          }
        }
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      }
    } on OpenRouteException catch (e) {
      if (mounted) {
        setState(() {
          _routeError = e.message;
        });
        debugPrint('❌ OpenRoute API Error: ${e.message}');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _routeError = 'Lỗi không xác định: $e';
        });
        debugPrint('❌ Route fetch error: $e');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      }
    }
  }

  void _navigateToSupport(DetailRescueMissionResponse mission) {
    context.push(
      '/rescuer/support',
      extra: {'missionId': mission.id, 'incidentId': mission.incidentId},
    );
  }

  void _showOptionsMenu(DetailRescueMissionResponse mission) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Làm mới'),
              onTap: () {
                Navigator.pop(context);
                ref.read(missionDetailProvider.notifier).refresh();
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem, color: Colors.red),
              title: const Text('Báo cáo sự cố'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show report issue dialog
              },
            ),
            if (mission.missionStatus == MissionStatus.preparing ||
                mission.missionStatus == MissionStatus.enRoute)
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Hủy nhiệm vụ'),
                onTap: () {
                  Navigator.pop(context);
                  _showAbortDialog(mission);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToNavigation(
    DetailRescueMissionResponse mission,
    MissionDetailState state,
  ) {
    // Route data is already in provider, no need to fetch again
    debugPrint('🗺️ Navigating to Navigation Screen from Detail');
    debugPrint('   Route data available: ${state.routeData != null}');

    context.push(
      '/rescuer/navigation',
      extra: {
        'missionId': mission.id,
        'mission': mission,
        'routeData': state.routeData, // Get from provider
      },
    );
  }

  void _showAbortDialog(DetailRescueMissionResponse mission) {
    // Only allow abort for Preparing and EnRoute statuses
    if (mission.missionStatus != MissionStatus.preparing &&
        mission.missionStatus != MissionStatus.enRoute) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Chỉ có thể hủy nhiệm vụ khi đang chuẩn bị hoặc đang di chuyển',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String? selectedReason;
    final customReasonController = TextEditingController();
    bool showCustomField = false;

    final abortReasons = [
      'Phương tiện gặp sự cố',
      'Có việc khẩn cấp',
      'Không thể tiếp cận địa điểm',
      'Bệnh nhân hủy yêu cầu',
      'Điều kiện thời tiết nguy hiểm',
      'Lý do khác',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Hủy nhiệm vụ?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vui lòng chọn lý do hủy nhiệm vụ:',
                  style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                ),
                const SizedBox(height: 16),
                // Radio buttons for abort reasons
                ...abortReasons.map((reason) {
                  final isSelected = selectedReason == reason;
                  final isOther = reason == 'Lý do khác';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedReason = reason;
                          showCustomField = isOther;
                          if (!isOther) {
                            customReasonController.clear();
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFF8800).withOpacity(0.1)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFF8800)
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFFF8800)
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFF8800),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                reason,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? const Color(0xFF1C100D)
                                      : const Color(0xFF666666),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),

                // Custom reason text field
                if (showCustomField) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: customReasonController,
                    decoration: InputDecoration(
                      hintText: 'Nhập lý do cụ thể...',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFFFF8800),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 3,
                    maxLength: 500,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Quay lại',
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate selection
                if (selectedReason == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng chọn lý do hủy nhiệm vụ'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Get final reason
                String finalReason = selectedReason!;
                if (showCustomField) {
                  final customReason = customReasonController.text.trim();
                  if (customReason.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng nhập lý do cụ thể'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  finalReason = customReason;
                }

                Navigator.pop(context);

                final success = await ref
                    .read(missionDetailProvider.notifier)
                    .abortMission(finalReason);

                if (!mounted) return;

                if (success) {
                  // Clean up: stop mission GPS and disconnect MissionHub
                  // so the rescuer can receive new SOS requests immediately.
                  ref.read(locationManagerProvider).stopMissionTracking();
                  await ref
                      .read(missionHubConnectionProvider.notifier)
                      .disconnect();

                  // Clear active mission from provider and local storage
                  await ref
                      .read(activeMissionProvider.notifier)
                      .clearActiveMission();
                  debugPrint('✅ Active mission cleared after abort');

                  // Restart idle tracking so this rescuer is discoverable for new missions
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    final rescuerId = prefs.getString('user_id');
                    if (rescuerId != null) {
                      await ref
                          .read(locationManagerProvider)
                          .startTracking(rescuerId);
                      debugPrint(
                        '✅ Restarted idle tracking after mission abort',
                      );
                    }
                  } catch (e) {
                    debugPrint('⚠️ Failed to restart idle tracking: $e');
                  }

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Đã hủy nhiệm vụ'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.pop(); // Go back to previous screen
                } else {
                  final error = ref.read(missionDetailProvider).error;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error ?? 'Lỗi khi hủy nhiệm vụ'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Xác nhận hủy',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
