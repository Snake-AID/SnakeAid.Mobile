import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../../../shared/widgets/chat_screen.dart';
import '../../providers/mission_hub_provider.dart';
import '../../providers/incident_provider.dart';
import '../../../../core/services/openroute_service.dart' as ors;
import '../../../../core/services/mission_hub_service.dart';
import '../../../../core/providers/openroute_provider.dart';

class EmergencyTrackingScreen extends ConsumerStatefulWidget {
  final String? incidentId;
  final String? missionId;
  final String? rescuerId;

  const EmergencyTrackingScreen({
    super.key,
    this.incidentId,
    this.missionId,
    this.rescuerId,
  });

  @override
  ConsumerState<EmergencyTrackingScreen> createState() =>
      _EmergencyTrackingScreenState();
}

class _EmergencyTrackingScreenState
    extends ConsumerState<EmergencyTrackingScreen>
    with TickerProviderStateMixin {
  // ── Map ───────────────────────────────────────────────────────────────────
  late final MapController _mapController;
  bool _isFollowingMember = true;

  // ── Live positions ────────────────────────────────────────────────────────
  LatLng? _memberPosition; // member's own GPS
  LatLng? _rescuerPosition; // rescuer's position received via MissionHub

  // ── Effective mission/rescuer (may arrive via stream if screen opened early)
  String? _effectiveMissionId;
  // ignore: unused_field  – kept for future rescuer-profile fetch / call action
  String? _effectiveRescuerId;
  bool get _hasRescuer => _effectiveMissionId != null;

  // ── GPS stream ────────────────────────────────────────────────────────────
  StreamSubscription<Position>? _gpsSubscription;
  bool _hasInitialGps = false;

  // ── Member location broadcast throttle ───────────────────────────────────
  Timer? _memberBroadcastThrottle;
  bool _isMemberBroadcastThrottled = false;

  // ── SOS origin (static pin — where SOS was first pressed) ────────────────
  LatLng? _sosOriginPosition;

  // ── Route: rescuer GPS → SOS origin (from OpenRouteService) ──────────────
  ors.RouteData? _routeData;
  bool _isRouteFetching = false;
  Timer? _routeDebounce;

  // ── Route progress (traveled vs remaining segments) ──────────────────────
  List<LatLng>? _traveledRoutePoints; // gray/dimmed
  List<LatLng>? _remainingRoutePoints; // orange/normal
  static const double _routeDeviationThreshold = 100.0; // meters

  // ── MissionHub subscriptions ──────────────────────────────────────────────
  final List<StreamSubscription> _missionHubSubscriptions = [];

  // ── ETA / distance display ────────────────────────────────────────────────
  double? _distanceKm;
  int? _etaMinutes; // estimated at 30 km/h

  // ── SOS countdown ─────────────────────────────────────────────────────────
  int _remainingSeconds = 330;
  Timer? _countdownTimer;

  // ── Bottom-sheet expand state ─────────────────────────────────────────────
  bool _showWhileWaitingExpanded = false;

  // ── Member blue-dot pulse (also used for rescuer & SOS origin) ───────────
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _mapController = MapController();

    // 🔋 Thermal optimization: slower animation = less CPU/GPU work
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Increased from 2s → 3s
    )..repeat();
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 2.2, // Reduced from 2.5 → 2.2 (smaller scale = less work)
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));

    // Initialise from navigation params (may be null if screen opened at SOS creation)
    _effectiveMissionId = widget.missionId;
    _effectiveRescuerId = widget.rescuerId;

    // Load SOS origin from cached incident (static pin on map)
    final incident = ref.read(activeIncidentProvider).incident;
    if (incident != null) {
      _sosOriginPosition = LatLng(
        incident.locationCoordinates.latitude,
        incident.locationCoordinates.longitude,
      );
    }

    // ── Restore rescuer position from provider (in case user backed and returned)
    final missionStatus = ref.read(missionStatusProvider);
    if (missionStatus.rescuerLat != null && missionStatus.rescuerLng != null) {
      _rescuerPosition = LatLng(
        missionStatus.rescuerLat!,
        missionStatus.rescuerLng!,
      );
      debugPrint(
        '✅ Restored rescuer position from provider: ${_rescuerPosition!.latitude}, ${_rescuerPosition!.longitude}',
      );
    }

    _startCountdown();
    _startMemberGps();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureMissionHubConnected();
      _setupMissionHubListeners();
      // Rescuer may have accepted while member was navigating to this screen
      _checkAlreadyAccepted();

      // Recalc ETA and fetch route if rescuer position was restored
      if (_rescuerPosition != null) {
        _recalcEta();
        if (_sosOriginPosition != null) {
          debugPrint('🗺️ Fetching route with restored rescuer position...');
          _fetchRoute();
        }
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GPS – member's own location
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _startMemberGps() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cần quyền vị trí để hiển thị bản đồ')),
        );
      }
      return;
    }

    // Fast initial fix
    try {
      final initial = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _onMemberPositionUpdate(initial);
    } catch (_) {}

    // Continuous stream
    // 🔋 Thermal optimization: increased distanceFilter 5m → 15m
    // This reduces GPS callback frequency significantly
    _gpsSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15, // Increased from 5m for battery/thermal savings
      ),
    ).listen(_onMemberPositionUpdate);
  }

  void _onMemberPositionUpdate(Position pos) {
    if (!mounted) return;
    final ll = LatLng(pos.latitude, pos.longitude);
    setState(() {
      _memberPosition = ll;
      _hasInitialGps = true;
      _recalcEta();
    });
    // 🔋 Auto-follow with throttle to reduce map redraws
    if (_isFollowingMember && mounted) {
      _mapController.move(ll, _mapController.camera.zoom);
    }

    // Broadcast member live GPS to MissionHub (rescuer sees it on their map)
    if (!_isMemberBroadcastThrottled && widget.incidentId != null) {
      final svc = ref.read(missionHubServiceProvider);
      if (svc.isConnected) {
        svc.updateLocation(widget.incidentId!, pos.latitude, pos.longitude);
        _isMemberBroadcastThrottled = true;
        _memberBroadcastThrottle = Timer(const Duration(seconds: 15), () {
          _isMemberBroadcastThrottled = false;
        });
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MissionHub – real-time rescuer location + lifecycle events
  // ─────────────────────────────────────────────────────────────────────────

  /// If RescuerAccepted already fired before this screen mounted, the stream
  /// event is gone but MissionStatusNotifier cached it globally.
  void _checkAlreadyAccepted() {
    if (_hasRescuer) return; // already have params from navigation
    final status = ref.read(missionStatusProvider);
    if (status.hasRescuer) {
      debugPrint('✅ TrackingScreen: rescuer already cached → updating state');
      setState(() {
        _effectiveMissionId = status.missionId;
        _effectiveRescuerId = status.rescuerId;
      });
    }
  }

  /// Ensure MissionHub is connected before setting up listeners
  /// (in case user backed to home and returned)
  Future<void> _ensureMissionHubConnected() async {
    debugPrint('🔌 [TrackingScreen] Ensuring MissionHub connection...');
    final incident = ref.read(activeIncidentProvider).incident;
    if (incident == null) {
      debugPrint('⚠️ Cannot ensure MissionHub connection: no active incident');
      return;
    }

    final connectionState = ref.read(missionHubConnectionProvider);
    debugPrint(
      '📡 [TrackingScreen] Current connection state: ${connectionState.isConnected}',
    );
    if (connectionState.isConnected) {
      debugPrint('✅ MissionHub already connected for incident ${incident.id}');
      return;
    }

    debugPrint('🔌 Reconnecting to MissionHub for incident ${incident.id}...');
    try {
      await ref
          .read(missionHubConnectionProvider.notifier)
          .connectForIncident(incident.id);
      debugPrint('✅ MissionHub reconnected successfully');
    } catch (e) {
      debugPrint('❌ Failed to reconnect MissionHub: $e');
    }
  }

  void _setupMissionHubListeners() {
    debugPrint('🎧 [TrackingScreen] Setting up MissionHub listeners...');
    final svc = ref.read(missionHubServiceProvider);

    // 🚨 Rescuer accepts → update state in place (no screen transition needed)
    _missionHubSubscriptions.add(
      svc.rescuerAcceptedStream.listen((data) {
        if (!mounted) return;
        debugPrint(
          '🚨 TrackingScreen: RescuerAccepted – updating rescuer state',
        );
        setState(() {
          _effectiveMissionId = data.missionId;
          _effectiveRescuerId = data.rescuerId;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🚑 Đã tìm thấy đội cứu hộ! Đang trên đường đến...'),
            backgroundColor: Color(0xFF228B22),
            duration: Duration(seconds: 3),
          ),
        );
      }),
    );

    // 📍 Rescuer GPS broadcast → update map marker and ETA
    debugPrint('🎧 [TrackingScreen] Subscribing to locationUpdatedStream...');
    _missionHubSubscriptions.add(
      svc.locationUpdatedStream.listen(
        (data) {
          debugPrint(
            '📨 [TrackingScreen] Received location update from stream',
          );
          _onRescuerLocationUpdate(data);
        },
        onError: (error) {
          debugPrint(
            '❌ [TrackingScreen] Error in locationUpdatedStream: $error',
          );
        },
        onDone: () {
          debugPrint('ℹ️ [TrackingScreen] locationUpdatedStream closed');
        },
      ),
    );

    // 🎯 Rescuer arrived at scene
    _missionHubSubscriptions.add(
      svc.rescuerArrivedStream.listen((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎯 Đội cứu hộ đã đến nơi!'),
            backgroundColor: Color(0xFF228B22),
            duration: Duration(seconds: 4),
          ),
        );
        context.pushNamed('member_rescuer_arrived');
      }),
    );

    // ✅ Mission completed
    _missionHubSubscriptions.add(
      svc.missionCompletedStream.listen((_) async {
        if (!mounted) return;
        // Clean up member-side state so a future SOS starts fresh.
        await ref.read(missionHubConnectionProvider.notifier).disconnect();
        ref.read(missionStatusProvider.notifier).reset();
        await ref.read(activeIncidentProvider.notifier).clearActiveIncident();
        if (!mounted) return;
        // go() resets the entire nav stack – no way to swipe back to tracking.
        context.go('/emergency-completion');
      }),
    );

    // ❌ Mission cancelled
    _missionHubSubscriptions.add(
      svc.missionCancelledStream.listen((reason) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Nhiệm vụ đã bị hủy: $reason'),
            backgroundColor: const Color(0xFFDC3545),
            duration: const Duration(seconds: 5),
          ),
        );
      }),
    );
  }

  void _onRescuerLocationUpdate(RescuerLocationData data) {
    if (!mounted) return;
    debugPrint(
      '📍 Member tracking: Rescuer location updated: ${data.latitude}, ${data.longitude}',
    );
    setState(() {
      _rescuerPosition = LatLng(data.latitude, data.longitude);
      _recalcEta();
    });

    // Smart route optimization: only refetch if off-route or first time
    final bool isOnRoute = _isRescuerOnRoute();
    final bool isFirstTime = _routeData == null;

    if (isFirstTime || !isOnRoute) {
      // Rescuer deviated from route or no route yet → refetch
      _routeDebounce?.cancel();
      _routeDebounce = Timer(
        isFirstTime ? Duration.zero : const Duration(seconds: 20),
        _fetchRoute,
      );
      debugPrint(
        '🔄 Route fetch scheduled (first: $isFirstTime, off-route: ${!isOnRoute})',
      );
    } else {
      // Rescuer still on route → just update traveled/remaining segments
      _splitRouteByProgress();
      debugPrint('✅ Rescuer on-route, reusing existing route (no API call)');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Route: rescuer position → SOS origin (via OpenRouteService)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _fetchRoute() async {
    if (_rescuerPosition == null) {
      debugPrint('⚠️ Route fetch skipped: rescuer position null');
      return;
    }
    final destination = _sosOriginPosition ?? _memberPosition;
    if (destination == null) {
      debugPrint('⚠️ Route fetch skipped: destination null');
      return;
    }
    if (_isRouteFetching) {
      debugPrint('⚠️ Route fetch already in progress, skipping');
      return;
    }

    debugPrint(
      '🗺️ Fetching route: rescuer ${_rescuerPosition!.latitude},${_rescuerPosition!.longitude} → destination ${destination.latitude},${destination.longitude}',
    );
    setState(() => _isRouteFetching = true);
    try {
      final routeData = await ref
          .read(openRouteServiceProvider)
          .getRoute(start: _rescuerPosition!, end: destination);
      if (mounted) {
        setState(() {
          _routeData = routeData;
          _splitRouteByProgress(); // Initialize traveled/remaining segments
        });
        debugPrint(
          '✅ Route fetched successfully: ${routeData.points.length} points, ${routeData.distanceKm.toStringAsFixed(2)} km',
        );
      }
    } catch (e, stack) {
      debugPrint('❌ Member tracking – route fetch failed: $e');
      debugPrint('Stack trace: $stack');
    } finally {
      if (mounted) setState(() => _isRouteFetching = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Route optimization: check if rescuer is still on route
  // ─────────────────────────────────────────────────────────────────────────

  bool _isRescuerOnRoute() {
    if (_routeData == null || _rescuerPosition == null) return false;
    if (_routeData!.points.isEmpty) return false;

    // Find minimum distance from rescuer to any point on route
    double minDistance = double.infinity;
    for (final point in _routeData!.points) {
      final distance = Geolocator.distanceBetween(
        _rescuerPosition!.latitude,
        _rescuerPosition!.longitude,
        point.latitude,
        point.longitude,
      );
      if (distance < minDistance) minDistance = distance;
    }

    return minDistance <= _routeDeviationThreshold;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Split route into traveled (gray) and remaining (orange) segments
  // ─────────────────────────────────────────────────────────────────────────

  void _splitRouteByProgress() {
    if (_routeData == null || _rescuerPosition == null) {
      setState(() {
        _traveledRoutePoints = null;
        _remainingRoutePoints = null;
      });
      return;
    }

    // Find closest point to rescuer on route
    int closestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < _routeData!.points.length; i++) {
      final distance = Geolocator.distanceBetween(
        _rescuerPosition!.latitude,
        _rescuerPosition!.longitude,
        _routeData!.points[i].latitude,
        _routeData!.points[i].longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    setState(() {
      // Traveled: from start to closest point (gray)
      _traveledRoutePoints = closestIndex > 0
          ? _routeData!.points.sublist(0, closestIndex + 1)
          : null;

      // Remaining: from closest point to end (orange)
      _remainingRoutePoints = closestIndex < _routeData!.points.length - 1
          ? _routeData!.points.sublist(closestIndex)
          : _routeData!.points; // fallback to full route if at end
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  void _recalcEta() {
    if (_memberPosition == null || _rescuerPosition == null) return;
    final meters = Geolocator.distanceBetween(
      _memberPosition!.latitude,
      _memberPosition!.longitude,
      _rescuerPosition!.latitude,
      _rescuerPosition!.longitude,
    );
    _distanceKm = meters / 1000;
    _etaMinutes = ((_distanceKm! / 30) * 60).ceil();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        t.cancel();
      }
    });
  }

  String _formatTime(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  /// Fit camera to show both member and rescuer simultaneously.
  void _centerOnBoth() {
    if (_memberPosition == null && _rescuerPosition == null) return;
    final pts = [
      if (_memberPosition != null) _memberPosition!,
      if (_rescuerPosition != null) _rescuerPosition!,
      if (_sosOriginPosition != null) _sosOriginPosition!,
    ];
    if (pts.length == 1) {
      _mapController.move(pts.first, 16.0);
      setState(() => _isFollowingMember = false);
      return;
    }
    double minLat = pts.first.latitude, maxLat = pts.first.latitude;
    double minLng = pts.first.longitude, maxLng = pts.first.longitude;
    for (final p in pts) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    final pad = 0.002;
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(
          LatLng(minLat - pad, minLng - pad),
          LatLng(maxLat + pad, maxLng + pad),
        ),
        padding: const EdgeInsets.all(80),
      ),
    );
    setState(() => _isFollowingMember = false);
  }

  @override
  void dispose() {
    _gpsSubscription?.cancel();
    _memberBroadcastThrottle?.cancel();
    _routeDebounce?.cancel();
    _countdownTimer?.cancel();

    // Cancel local subscriptions (will be re-setup when screen is reopened)
    for (final s in _missionHubSubscriptions) {
      s.cancel();
    }
    _missionHubSubscriptions.clear();

    // NOTE: We do NOT disconnect MissionHub here because:
    // 1. User may just be temporarily going to home/detail screen
    // 2. MissionHub needs to stay connected to receive events
    // 3. MissionStatusNotifier maintains global state across screens
    // 4. We'll reconnect in initState if connection was lost

    _pulseController.stop();
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          if (!_hasInitialGps) _buildGpsLoadingOverlay(),
          _buildTopBar(),
          _buildMapControls(),
          _buildWarningBanner(),
          _buildBottomSheet(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Real FlutterMap
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildMap() {
    final defaultCenter =
        _memberPosition ??
        _sosOriginPosition ??
        _rescuerPosition ??
        const LatLng(10.7769, 106.7009);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: defaultCenter,
        initialZoom: 15.0,
        onPositionChanged: (_, hasGesture) {
          if (hasGesture && _isFollowingMember) {
            setState(() => _isFollowingMember = false);
          }
        },
      ),
      children: [
        // OSM tile layer
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.snakeaid.mobile',
        ),

        // ── Route polylines: traveled (gray) + remaining (orange) ────────
        // Traveled segment (dimmed gray)
        if (_traveledRoutePoints != null && _traveledRoutePoints!.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _traveledRoutePoints!,
                strokeWidth: 5.0,
                color: Colors.grey.withOpacity(0.4),
                borderColor: Colors.white.withOpacity(0.3),
                borderStrokeWidth: 1.5,
              ),
            ],
          ),

        // Remaining segment (bright orange)
        if (_remainingRoutePoints != null && _remainingRoutePoints!.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _remainingRoutePoints!,
                strokeWidth: 5.0,
                color: const Color(0xFFFF8800),
                borderColor: Colors.white,
                borderStrokeWidth: 1.5,
              ),
            ],
          ),

        // Fallback dashed line while route is loading
        if (_routeData == null &&
            _rescuerPosition != null &&
            (_sosOriginPosition ?? _memberPosition) != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: [
                  _rescuerPosition!,
                  _sosOriginPosition ?? _memberPosition!,
                ],
                strokeWidth: 2.5,
                color: const Color(0xFF228B22),
                pattern: const StrokePattern.dotted(),
              ),
            ],
          ),

        // ── SOS origin marker (red pulsing pin – static) ──────────────────
        if (_sosOriginPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _sosOriginPosition!,
                width: 64,
                height: 64,
                child: _buildSosOriginPin(),
              ),
            ],
          ),

        // ── Rescuer marker (green pin) ────────────────────────────────────
        if (_rescuerPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _rescuerPosition!,
                width: 60,
                height: 72,
                child: _buildRescuerPin(),
              ),
            ],
          ),

        // ── Member marker (blue pulsing dot) ──────────────────────────────
        if (_memberPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _memberPosition!,
                width: 80,
                height: 80,
                child: _buildMemberDot(),
              ),
            ],
          ),
      ],
    );
  }

  /// Static red pin at the SOS origin location.
  Widget _buildSosOriginPin() {
    return const Icon(
      Icons.location_on,
      color: Color(0xFFDC3545),
      size: 40,
      shadows: [
        Shadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
      ],
    );
  }

  /// Green pulsing dot for rescuer's live position.
  Widget _buildRescuerPin() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulse ring – green
          Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF228B22).withOpacity(
                  (0.4 * (1.0 - (_pulseAnimation.value - 1.0) / 1.5)).clamp(
                    0.0,
                    1.0,
                  ),
                ),
              ),
            ),
          ),
          // White halo
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          // Core green dot with medical icon
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF228B22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF228B22).withOpacity(0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.medical_services,
              color: Colors.white,
              size: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberDot() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulse ring
          Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(
                  0xFF2563EB,
                ).withOpacity(0.15 * (2.5 - _pulseAnimation.value) / 1.5),
              ),
            ),
          ),
          // White halo
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          // Core blue dot
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2563EB),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.35),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Top bar
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white.withOpacity(0.95), Colors.transparent],
            ),
          ),
          child: Row(
            children: [
              // Back
              _circleButton(
                icon: Icons.arrow_back,
                onTap: () => context.canPop()
                    ? context.pop()
                    : context.goNamed('emergency_alert'),
              ),
              const SizedBox(width: 12),

              // SOS status pill
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDC3545), Color(0xFFC82333)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDC3545).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _LiveDot(),
                      const SizedBox(width: 8),
                      const Text(
                        'SOS',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 16,
                        width: 1,
                        color: Colors.white.withOpacity(0.4),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'ĐANG HOẠT ĐỘNG',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatTime(_remainingSeconds),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // "See both on map" button
              _circleButton(
                icon: Icons.fit_screen,
                onTap: _centerOnBoth,
                tooltip: 'Xem cả hai trên bản đồ',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Right-side map controls
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildMapControls() {
    final topPad = MediaQuery.of(context).padding.top;
    return Positioned(
      right: 16,
      top: topPad + 80,
      child: Column(
        children: [
          _squareButton(
            icon: _isFollowingMember
                ? Icons.my_location
                : Icons.location_searching,
            active: _isFollowingMember,
            tooltip: _isFollowingMember ? 'Bám theo tôi' : 'Bật bám theo',
            onTap: () {
              setState(() => _isFollowingMember = !_isFollowingMember);
              if (_isFollowingMember && _memberPosition != null) {
                _mapController.move(
                  _memberPosition!,
                  _mapController.camera.zoom,
                );
              }
            },
          ),
          const SizedBox(height: 10),
          _squareButton(
            icon: Icons.add,
            onTap: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom + 1,
            ),
          ),
          const SizedBox(height: 10),
          _squareButton(
            icon: Icons.remove,
            onTap: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom - 1,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Warning banner (below top bar, above map)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildWarningBanner() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      left: 16,
      right: 68,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937).withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.warning_amber, color: Color(0xFFF59E0B), size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Giữ bình tĩnh · Hạn chế vận động',
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Loading overlay before first GPS fix
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildGpsLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.4),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Đang lấy vị trí GPS...',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Draggable bottom sheet
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.38,
      minChildSize: 0.28,
      maxChildSize: 0.88,
      snap: true,
      snapSizes: const [0.28, 0.38, 0.65, 0.88],
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: _hasRescuer
                    ? Column(
                        children: [
                          _buildRescuerInfoRow(),
                          const Divider(height: 28, color: Color(0xFFF3F4F6)),
                          _buildETARow(),
                          const SizedBox(height: 16),
                          _buildConnectionStatus(),
                          const SizedBox(height: 16),
                          _buildWhileWaitingSection(),
                        ],
                      )
                    : _buildSearchingRescuerSheet(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Searching state bottom sheet (no rescuer yet – Grab/Be style) ─────────

  Widget _buildSearchingRescuerSheet() {
    final radiusKm = _remainingSeconds > 270
        ? '5'
        : _remainingSeconds > 150
        ? '10'
        : '20';
    return Column(
      children: [
        const SizedBox(height: 8),
        // Animated search indicator
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF228B22).withOpacity(0.18),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(
              strokeWidth: 3.5,
              color: Color(0xFF228B22),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Đang tìm đội cứu hộ gần bạn...',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191910),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bán kính tìm kiếm: $radiusKm km',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 20),
        // Countdown pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.timer_outlined,
                size: 16,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 6),
              Text(
                'Hết giờ sau ${_formatTime(_remainingSeconds)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Divider(color: Color(0xFFF3F4F6)),
        const SizedBox(height: 16),
        _buildConnectionStatus(),
        const SizedBox(height: 16),
        _buildWhileWaitingSection(),
      ],
    );
  }

  // ── Bottom sheet sections ─────────────────────────────────────────────────

  Widget _buildRescuerInfoRow() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF228B22),
            border: Border.all(color: const Color(0xFFF3F4F6), width: 2),
          ),
          child: const Icon(
            Icons.medical_services,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Đội cứu hộ',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191910),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _rescuerPosition != null
                        ? 'ĐANG TRÊN ĐƯỜNG ĐẾN'
                        : 'ĐANG KẾT NỐI...',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF59E0B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _circleButton(
          icon: Icons.chat_bubble_outline,
          size: 42,
          iconColor: const Color(0xFF228B22),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChatScreen(
                recipientName: 'Đội cứu hộ',
                recipientAvatar: '🚑',
                isExpert: false,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _circleButton(
          icon: Icons.call,
          size: 42,
          bgColor: const Color(0xFF228B22),
          iconColor: Colors.white,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildETARow() {
    final hasData = _distanceKm != null && _etaMinutes != null;

    return Column(
      children: [
        Text(
          'CỨU HỘ SẼ ĐẾN TRONG',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        if (hasData)
          Text(
            '$_etaMinutes phút',
            style: const TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w800,
              color: Color(0xFF228B22),
              height: 1,
              letterSpacing: -1,
            ),
          )
        else
          const SizedBox(
            height: 52,
            child: Center(
              child: SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Color(0xFF228B22),
                ),
              ),
            ),
          ),
        const SizedBox(height: 14),
        if (hasData)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.near_me, size: 16, color: Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Text(
                  'Cách ${_distanceKm!.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            'Đang chờ dữ liệu vị trí cứu hộ...',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        const SizedBox(height: 12),
        // Live update indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_rescuerPosition != null)
              const Icon(Icons.wifi, size: 14, color: Color(0xFF228B22))
            else
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            const SizedBox(width: 6),
            Text(
              _rescuerPosition != null
                  ? 'Đang nhận vị trí realtime'
                  : 'Chờ cứu hộ phát vị trí...',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: _rescuerPosition != null
                    ? const Color(0xFF228B22)
                    : Colors.grey[500],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConnectionStatus() {
    final stream = ref.watch(missionHubConnectionStateStreamProvider);
    return stream.when(
      data: (state) {
        final connected = state == HubConnectionState.Connected;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: connected
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFFF9800),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              connected ? 'MissionHub đã kết nối' : 'Đang kết nối lại...',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: connected
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFFF9800),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildWhileWaitingSection() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(
              () => _showWhileWaitingExpanded = !_showWhileWaitingExpanded,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  const Text(
                    'Trong lúc chờ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF191910),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _showWhileWaitingExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_right,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          if (_showWhileWaitingExpanded) ...[
            _buildWaitingItem(
              icon: Icons.medical_information,
              title: 'Hướng dẫn sơ cứu',
              subtitle: 'Xem các bước sơ cứu',
              onTap: () => context.push(
                '/emergency/first-aid-steps',
                extra: 'King Cobra',
              ),
            ),
            const SizedBox(height: 10),
            _buildWaitingItem(
              icon: Icons.assessment,
              title: 'Báo cáo triệu chứng',
              subtitle: 'Cập nhật triệu chứng hiện tại',
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _buildWaitingItem(
              icon: Icons.warning_amber,
              title: 'Mức độ nghiêm trọng',
              subtitle: 'Điểm: 85/100 – Nghiêm trọng',
              color: const Color(0xFFDC3545),
              onTap: () {},
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildWaitingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    final c = color ?? const Color(0xFF228B22);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: c, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF191910),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Reusable button helpers
  // ─────────────────────────────────────────────────────────────────────────

  Widget _circleButton({
    required IconData icon,
    VoidCallback? onTap,
    String? tooltip,
    double size = 40,
    Color? bgColor,
    Color? iconColor,
  }) {
    final btn = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: size * 0.45,
          color: iconColor ?? const Color(0xFF191910),
        ),
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip, child: btn) : btn;
  }

  Widget _squareButton({
    required IconData icon,
    VoidCallback? onTap,
    bool active = false,
    String? tooltip,
  }) {
    final btn = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF228B22) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 20,
          color: active ? Colors.white : const Color(0xFF374151),
        ),
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip, child: btn) : btn;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// Animated live-indicator dot in the SOS top bar
// ─────────────────────────────────────────────────────────────────────────────

class _LiveDot extends StatefulWidget {
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _anim,
    child: Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    ),
  );
}
