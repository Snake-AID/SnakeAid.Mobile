import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../models/rescue_mission_response.dart';
import '../../models/detailed_incident_response.dart';
import '../../models/route_navigation_data.dart';
import '../../providers/mission_detail_provider.dart';
import '../../../../core/utils/distance_utils.dart';
import '../../../../core/providers/openroute_provider.dart';
import '../../../../core/services/openroute_service.dart';

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
  final MapController _mapController = MapController();
  Timer? _elapsedTimer;
  Duration _elapsedTime = Duration.zero;
  StreamSubscription<Position>? _locationSubscription;
  RouteNavigationData? _routeData; // Route data from OpenRouteService
  bool _isLoadingRoute = false;
  String? _routeError;
  bool _hasRedirected = false; // Prevent multiple redirects

  @override
  void initState() {
    super.initState();
    _loadMissionAndStartTracking();
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _locationSubscription?.cancel();
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
    _locationSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10, // Update every 10 meters
          ),
        ).listen((position) {
          ref
              .read(missionDetailProvider.notifier)
              .updateRescuerLocation(position);
        });
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

    // For Preparing state: show details with small map preview
    // For other states: redirect to appropriate screen
    final status = mission.missionStatus;
    if (status == MissionStatus.enRoute && !_hasRedirected) {
      // Should be in Navigation Screen - redirect if accidentally here
      _hasRedirected = true; // Set flag to prevent multiple redirects
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('🔄 Auto-redirect to Navigation Screen (EnRoute state)');
        debugPrint('   Route data available: ${state.routeData != null}');

        context.replace(
          '/rescuer/navigation',
          extra: {
            'missionId': mission.id,
            'mission': mission,
            'routeData': state.routeData, // Pass routeData from provider
          },
        );
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      body: Column(
        children: [
          _buildHeader(mission),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Small preview map for Preparing state
                  if (status == MissionStatus.preparing)
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
      case MissionStatus.arrived:
        statusColor = const Color(0xFF4CAF50);
        statusText = 'ĐÃ ĐẾN NƠI';
        break;
      case MissionStatus.inProgress:
        statusColor = const Color(0xFFFF6B35);
        statusText = 'ĐANG XỬ LÝ';
        break;
      case MissionStatus.missionCompleted:
        statusColor = const Color(0xFF10B981);
        statusText = 'HOÀN THÀNH';
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
                      _makePhoneCall(mission.user.account?.phoneNumber ?? ''),
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

  Widget _buildMapSection(
    DetailRescueMissionResponse mission,
    MissionDetailState state,
  ) {
    final incidentLat = mission.incident.locationCoordinates.latitude;
    final incidentLon = mission.incident.locationCoordinates.longitude;
    final incidentLatLng = LatLng(incidentLat, incidentLon);

    return Container(
      height: 300,
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
            mapController: _mapController,
            options: MapOptions(
              initialCenter: incidentLatLng,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.snakeaid.mobile',
              ),
              // Route polyline (blue line from rescuer to victim)
              if (_routeData != null && _routeData!.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routeData!.points,
                      strokeWidth: 4.0,
                      color: const Color(0xFF2196F3),
                      borderStrokeWidth: 2.0,
                      borderColor: Colors.white,
                    ),
                  ],
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
                  // Rescuer location (blue dot)
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
          // Distance & ETA overlay
          if (state.distanceKm != null && state.etaMinutes != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.navigation,
                          size: 20,
                          color: Color(0xFF2196F3),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DistanceUtils.formatDistance(state.distanceKm!),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 20, color: Colors.grey[300]),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 20,
                          color: Color(0xFF2196F3),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DistanceUtils.formatETA(state.etaMinutes!),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          // Open navigation button
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: () => _openNavigation(incidentLat, incidentLon),
              icon: const Icon(Icons.navigation, color: Colors.white),
              label: const Text('Chỉ đường'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
          // Route loading indicator
          if (_isLoadingRoute)
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Đang tính đường...',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
          // Route error indicator
          if (_routeError != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 80,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[700], size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _routeError!,
                        style: TextStyle(fontSize: 12, color: Colors.red[700]),
                      ),
                    ),
                  ],
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
      case MissionStatus.enRoute:
        buttonText = 'ĐÃ ĐẾN NƠI';
        buttonColor = const Color(0xFF4CAF50);
        buttonIcon = Icons.check_circle;
        onPressed = state.isUpdatingStatus ? null : () => _markArrival();
        break;
      case MissionStatus.arrived:
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
                onPressed: () => _makePhoneCall(account?.phoneNumber ?? ''),
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
          _buildDetailRow(
            'Bán kính tìm kiếm',
            mission.incident.formattedRadius,
          ),
          const Divider(height: 20),
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
        mission.incident.symptomsReport!.trim().isNotEmpty;

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
                color: hasSymptoms ? const Color(0xFFFF9800) : Colors.grey[600],
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
              ? Text(
                  mission.incident.symptomsReport!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFE65100),
                  ),
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
    final hasMedia = media.isNotEmpty && media.first.mediaUrl.trim().isNotEmpty;
    final firstMedia = hasMedia ? media.first : null;
    final hasAI = firstMedia?.aiRecognitionResults.isNotEmpty ?? false;

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
          const Row(
            children: [
              Icon(Icons.image, color: Color(0xFF4CAF50), size: 20),
              SizedBox(width: 8),
              Text(
                '🐍 Hình ảnh & nhận diện',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasMedia)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                firstMedia!.mediaUrl,
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
          if (hasAI) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.smart_toy, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          firstMedia!.aiRecognitionResults.first.yoloClassName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Độ chính xác: ${(firstMedia.aiRecognitionResults.first.confidence * 100).toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
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

  Future<void> _openNavigation(double lat, double lon) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon';
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('❌ Failed to open navigation: $e');
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
      _isLoadingRoute = true;
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
          _isLoadingRoute = false;
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
          _isLoadingRoute = false;
        });
        debugPrint('❌ OpenRoute API Error: ${e.message}');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _routeError = 'Lỗi không xác định: $e';
          _isLoadingRoute = false;
        });
        debugPrint('❌ Route fetch error: $e');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      }
    }
  }

  Future<void> _markArrival() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đã đến nơi?'),
        content: const Text(
          'Bạn đã đến hiện trường chưa? Nạn nhân sẽ được thông báo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Chưa đến'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ref
        .read(missionDetailProvider.notifier)
        .markArrival();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Đã xác nhận đến nơi'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final error = ref.read(missionDetailProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Lỗi khi xác nhận đến nơi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToSupport(DetailRescueMissionResponse mission) {
    context.push(
      '/rescuer/mission-support',
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

  void _showAbortDialog(DetailRescueMissionResponse mission) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy nhiệm vụ?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vui lòng cho biết lý do hủy nhiệm vụ:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Lý do hủy nhiệm vụ',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Quay lại'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập lý do'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              final success = await ref
                  .read(missionDetailProvider.notifier)
                  .abortMission(reasonController.text.trim());

              if (!mounted) return;

              if (success) {
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xác nhận hủy'),
          ),
        ],
      ),
    );
  }
}
