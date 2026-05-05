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
import '../../widgets/rescuer_abort_reason_dialog.dart';
import '../../../rescuer/providers/tracking_provider.dart';

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
  RouteNavigationData? _routeData;
  String? _routeError;
  final List<StreamSubscription> _missionHubSubscriptions = [];
  final _nominatimService = NominatimService();
  String? _incidentAddress;
  bool _isLoadingIncidentAddress = false;
  bool _missionEnded = false;
  bool _isInitializing = true;

  // Design tokens
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMissionAndStartTracking();
    });
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _locationSubscription?.cancel();
    for (final s in _missionHubSubscriptions) s.cancel();
    super.dispose();
  }

  Future<void> _loadMissionAndStartTracking() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      await ref
          .read(missionDetailProvider.notifier)
          .loadMissionDetail(
            missionId: widget.missionId,
            rescuerLocation: position,
          );
      await _resolveIncidentAddress();
      final mission = ref.read(missionDetailProvider).mission;
      if (mission != null) {
        try {
          await ref
              .read(missionHubConnectionProvider.notifier)
              .connectForIncident(mission.incident.id);
          _setupMissionHubListeners();
          final prefs = await SharedPreferences.getInstance();
          final rescuerId = prefs.getString('user_id');
          if (rescuerId != null) {
            final svc = ref.read(missionHubServiceProvider);
            await ref
                .read(locationManagerProvider)
                .startMissionTracking(rescuerId, mission.incident.id, svc);
          }
        } catch (e) {
          debugPrint('⚠️ MissionHub connect failed: $e');
        }
      }
      _startLocationTracking();
      _startElapsedTimer();
    } catch (e) {
      await ref
          .read(missionDetailProvider.notifier)
          .loadMissionDetail(missionId: widget.missionId);
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  void _startLocationTracking() {
    _locationSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 15,
          ),
        ).listen(
          (pos) => ref
              .read(missionDetailProvider.notifier)
              .updateRescuerLocation(pos),
        );
  }

  Future<void> _resolveIncidentAddress() async {
    final mission = ref.read(missionDetailProvider).mission;
    if (mission == null) return;
    final apiAddr = mission.incident.address;
    if (apiAddr != null && apiAddr.isNotEmpty) {
      setState(() => _incidentAddress = apiAddr);
      return;
    }
    setState(() => _isLoadingIncidentAddress = true);
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
    _missionHubSubscriptions.add(
      svc.missionCancelledStream.listen((reason) async {
        await _handleMissionTermination('Nhiệm vụ đã bị hủy bởi nạn nhân.');
      }),
    );
  }

  Future<void> _handleMissionTermination(
    String message, {
    bool restartIdle = true,
  }) async {
    if (_missionEnded) return;
    _missionEnded = true;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.orange),
      );
    }
    ref.read(locationManagerProvider).stopMissionTracking();
    await ref.read(missionHubConnectionProvider.notifier).disconnect();
    await ref.read(activeMissionProvider.notifier).clearActiveMission();
    if (restartIdle) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final rescuerId = prefs.getString('user_id');
        if (rescuerId != null) {
          await ref.read(locationManagerProvider).startTracking(rescuerId);
          await ref
              .read(rescueModeProvider.notifier)
              .startRescueMode(rescuerId);
        }
      } catch (_) {}
    }
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    context.goNamed('rescuer_home');
  }

  void _startElapsedTimer() {
    final mission = ref.read(missionDetailProvider).mission;
    if (mission == null) return;
    if (mission.startedAt != null) {
      _elapsedTime = DateTime.now().difference(mission.startedAt!);
    }
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedTime += const Duration(seconds: 1));
    });
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
        appBar: _simpleAppBar('Nhiệm vụ cứu hộ'),
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
                  onPressed: () =>
                      ref.read(missionDetailProvider.notifier).refresh(),
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
        appBar: _simpleAppBar('Nhiệm vụ cứu hộ'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: _textSecondary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Không tìm thấy nhiệm vụ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nhiệm vụ có thể đã bị hủy hoặc không tồn tại',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: _textSecondary),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.goNamed('rescuer_home'),
                  icon: const Icon(Icons.home_outlined, size: 18),
                  label: const Text('Về trang chủ'),
                  style: FilledButton.styleFrom(backgroundColor: _accent),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final status = mission.missionStatus;
    return Scaffold(
      backgroundColor: _surface,
      body: Column(
        children: [
          _buildHeader(mission),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (status == MissionStatus.preparing ||
                      status == MissionStatus.enRoute ||
                      status == MissionStatus.rescuerArrived)
                    _buildPreviewMap(mission, state),
                  _buildActionButton(mission, state),
                  const SizedBox(height: 16),
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
                  if (mission.user.emergencyContacts.any(
                    (c) => c.trim().isNotEmpty,
                  )) ...[
                    const SizedBox(height: 12),
                    _buildEmergencyContactsCard(mission),
                  ],
                  const SizedBox(height: 12),
                  _buildLocationCard(mission),
                  const SizedBox(height: 12),
                  _buildSymptomsCard(mission),
                  const SizedBox(height: 12),
                  _buildMediaCard(mission),
                  const SizedBox(height: 12),
                  _buildIncidentTimeCard(mission),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
    final status = mission.missionStatus;
    final (statusLabel, statusColor) = _statusInfo(status);

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
                    'NHIỆM VỤ CỨU HỘ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.phone_outlined, color: _accent),
                  onPressed: () =>
                      _makePhoneCall(mission.user.phoneNumber ?? ''),
                  style: IconButton.styleFrom(
                    backgroundColor: _accent.withOpacity(0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: _textSecondary),
                  onPressed: () => _showOptionsMenu(mission),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
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
                  if (_elapsedTime.inSeconds > 0) ...[
                    const Icon(
                      Icons.timer_outlined,
                      size: 15,
                      color: _textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatElapsed(_elapsedTime),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
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

  (String, Color) _statusInfo(MissionStatus status) => switch (status) {
    MissionStatus.preparing => ('Đang chuẩn bị', const Color(0xFFE65100)),
    MissionStatus.enRoute => ('Đang di chuyển', const Color(0xFF1565C0)),
    MissionStatus.rescuerArrived => ('Đã đến nơi', _green),
    MissionStatus.missionCompleted => ('Hoàn thành', _green),
    MissionStatus.missionUncompleted => (
      'Chưa hoàn thành',
      const Color(0xFFE65100),
    ),
    MissionStatus.missionAborted => ('Đã hủy bỏ', _danger),
    MissionStatus.cancelled => ('Đã hủy', _textSecondary),
  };

  String _formatElapsed(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0)
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ── Preview Map ────────────────────────────────────────────────────────────
  Widget _buildPreviewMap(
    DetailRescueMissionResponse mission,
    MissionDetailState state,
  ) {
    final incidentLatLng = LatLng(
      mission.incident.locationCoordinates.latitude,
      mission.incident.locationCoordinates.longitude,
    );
    return Container(
      height: 180,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: incidentLatLng,
              initialZoom: 13.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.snakeaid.mobile',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: incidentLatLng,
                    width: 36,
                    height: 36,
                    child: const Icon(
                      Icons.location_pin,
                      color: _danger,
                      size: 36,
                    ),
                  ),
                  if (state.rescuerLocation != null)
                    Marker(
                      point: LatLng(
                        state.rescuerLocation!.latitude,
                        state.rescuerLocation!.longitude,
                      ),
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                  const Icon(Icons.location_on, size: 14, color: _danger),
                  const SizedBox(width: 4),
                  Text(
                    'Vị trí nạn nhân',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (state.distanceKm != null)
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  DistanceUtils.formatDistance(state.distanceKm!),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Action Button ──────────────────────────────────────────────────────────
  Widget _buildActionButton(
    DetailRescueMissionResponse mission,
    MissionDetailState state,
  ) {
    final status = mission.missionStatus;
    if (status == MissionStatus.enRoute) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _navigateToNavigation(mission, state),
            icon: const Icon(Icons.navigation_outlined, size: 18),
            label: const Text(
              'Quay lại điều hướng',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: _accent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      );
    }
    if (status == MissionStatus.preparing) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: state.isUpdatingStatus ? null : _startMission,
            icon: state.isUpdatingStatus
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.directions_car_outlined, size: 18),
            label: const Text(
              'Bắt đầu di chuyển',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: _accent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      );
    }
    if (status == MissionStatus.rescuerArrived) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _navigateToSupport(mission),
            icon: const Icon(Icons.medical_services_outlined, size: 18),
            label: const Text(
              'Bắt đầu xử lý',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: _green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
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
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.payments_outlined, color: _green, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Phí dịch vụ',
                style: TextStyle(fontSize: 12, color: _textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                mission.formattedPrice,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _green,
                ),
              ),
            ],
          ),
        ],
      ),
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
                      account?.fullName ?? 'Không rõ',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 16,
                          color: _accent,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            user.phoneNumber ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.phone_outlined, color: _accent),
                onPressed: () => _makePhoneCall(user.phoneNumber ?? ''),
                style: IconButton.styleFrom(
                  backgroundColor: _accent.withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: _accent,
                  ),
                  const SizedBox(width: 8),
                  const Text(
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
    if (contacts.isEmpty) return const SizedBox.shrink();

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
                    IconButton(
                      icon: const Icon(
                        Icons.phone_outlined,
                        size: 18,
                        color: _accent,
                      ),
                      onPressed: () => _makePhoneCall(phone),
                      style: IconButton.styleFrom(
                        backgroundColor: _accent.withOpacity(0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(6),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  // ── Location Card ──────────────────────────────────────────────────────────
  Widget _buildLocationCard(DetailRescueMissionResponse mission) {
    final lat = mission.incident.locationCoordinates.latitude;
    final lon = mission.incident.locationCoordinates.longitude;
    final address = _incidentAddress ?? mission.incident.address;
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
          if (_isLoadingIncidentAddress) ...[
            const SizedBox(height: 8),
            _infoRow(Icons.place_outlined, 'Địa chỉ', 'Đang tải...'),
          ] else if (address != null && address.isNotEmpty) ...[
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

    final elapsed = DateTime.now().difference(occurredAt);
    final minutes = elapsed.inMinutes;
    final color = minutes > 60
        ? _danger
        : minutes > 30
        ? _accent
        : _green;
    final timeText = minutes < 60
        ? '$minutes phút trước'
        : '${minutes ~/ 60} giờ ${minutes % 60} phút trước';

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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.schedule_rounded, color: color, size: 22),
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
                timeText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
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
    Color _iconColor(IconData icon) {
      if (icon == Icons.my_location_outlined) return const Color(0xFF4CAF50);
      if (icon == Icons.place_outlined) return const Color(0xFF4CAF50);
      if (icon == Icons.monitor_heart_outlined) return const Color(0xFFE65100);
      if (icon == Icons.schedule_outlined) return const Color(0xFFFF9800);
      return _textSecondary;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: _iconColor(icon)),
        const SizedBox(width: 8),
        SizedBox(
          width: 72,
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

  // ── Actions ────────────────────────────────────────────────────────────────
  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleaned = phoneNumber.trim().replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _startMission() async {
    await _fetchRoute();
    if (_routeError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_routeError!), backgroundColor: _danger),
        );
      }
      return;
    }
    final success = await ref
        .read(missionDetailProvider.notifier)
        .startMission();
    if (!mounted) return;
    if (success) {
      await ref
          .read(activeMissionProvider.notifier)
          .updateMissionStatus('EnRoute');
      final mission = ref.read(missionDetailProvider).mission;
      final routeData = ref.read(missionDetailProvider).routeData;
      context.push(
        '/rescuer/navigation',
        extra: {
          'missionId': mission!.id,
          'mission': mission,
          'routeData': routeData,
        },
      );
    } else {
      final error = ref.read(missionDetailProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Lỗi khi bắt đầu nhiệm vụ'),
          backgroundColor: _danger,
        ),
      );
    }
  }

  Future<void> _fetchRoute() async {
    final state = ref.read(missionDetailProvider);
    final mission = state.mission;
    final rescuerLocation = state.rescuerLocation;
    if (mission == null || rescuerLocation == null) return;
    setState(() => _routeError = null);
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
                ? route.steps
                : [
                    RouteStep(
                      instruction: 'Đi theo đường đến vị trí nạn nhân',
                      distanceMeters: route.distanceKm * 1000,
                      durationSeconds: route.durationMinutes * 60,
                      type: 7,
                      roadName: null,
                    ),
                  ],
          );
        });
        ref.read(missionDetailProvider.notifier).setRouteData(_routeData!);
      }
    } on OpenRouteException catch (e) {
      if (mounted) setState(() => _routeError = e.message);
    } catch (e) {
      if (mounted) setState(() => _routeError = 'Lỗi không xác định: $e');
    }
  }

  void _navigateToSupport(DetailRescueMissionResponse mission) {
    context.push(
      '/rescuer/support',
      extra: {'missionId': mission.id, 'incidentId': mission.incidentId},
    );
  }

  void _navigateToNavigation(
    DetailRescueMissionResponse mission,
    MissionDetailState state,
  ) {
    context.push(
      '/rescuer/navigation',
      extra: {
        'missionId': mission.id,
        'mission': mission,
        'routeData': state.routeData,
      },
    );
  }

  void _showOptionsMenu(DetailRescueMissionResponse mission) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.refresh_rounded),
              title: const Text('Làm mới'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(missionDetailProvider.notifier).refresh();
              },
            ),
            if (mission.missionStatus == MissionStatus.preparing ||
                mission.missionStatus == MissionStatus.enRoute)
              ListTile(
                leading: const Icon(Icons.cancel_outlined, color: _danger),
                title: const Text(
                  'Hủy nhiệm vụ',
                  style: TextStyle(color: _danger),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAbortDialog(mission);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showAbortDialog(DetailRescueMissionResponse mission) {
    if (mission.missionStatus != MissionStatus.preparing &&
        mission.missionStatus != MissionStatus.enRoute)
      return;

    showRescuerAbortReasonDialog(
      context,
      onSubmit: (reason) async {
        final success = await ref
            .read(missionDetailProvider.notifier)
            .abortMission(reason);
        if (success) return null;
        return ref.read(missionDetailProvider).error ?? 'Lỗi khi hủy';
      },
    ).then((reason) async {
      if (reason == null || !mounted) return;
      await _handleMissionTermination('Đã hủy nhiệm vụ.', restartIdle: false);
    });
  }
}

// ── Shared small widgets ───────────────────────────────────────────────────
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
