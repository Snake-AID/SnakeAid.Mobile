import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../shared/widgets/custom_dialog.dart';
import '../../models/rescue_mission_response.dart';
import '../../models/route_navigation_data.dart';
import '../../providers/mission_detail_provider.dart';
import '../../providers/mission_hub_provider.dart';
import '../../../../core/services/mission_hub_service.dart'
    show MemberLocationData;

class RescuerNavigationScreen extends ConsumerStatefulWidget {
  final String missionId;
  final DetailRescueMissionResponse mission;
  final RouteNavigationData? routeData; // Optional, fallback to provider

  const RescuerNavigationScreen({
    super.key,
    required this.missionId,
    required this.mission,
    this.routeData,
  });

  @override
  ConsumerState<RescuerNavigationScreen> createState() =>
      _RescuerNavigationScreenState();
}

class _RescuerNavigationScreenState
    extends ConsumerState<RescuerNavigationScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bluePulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bluePulseAnimation;
  late MapController _mapController;

  StreamSubscription<Position>? _positionSubscription;
  Position? _currentPosition;
  double? _distanceToVictim;
  int? _estimatedTime;
  bool _isFollowingUser = true; // Auto-follow mode like Google Maps
  bool _hasInitialPosition = false; // Track if we got first position

  // Live member GPS from MissionHub
  LatLng? _memberLivePosition;
  final List<StreamSubscription> _missionHubSubscriptions = [];

  // Position tracking & turn-by-turn navigation
  int _currentStepIndex = 0; // Current instruction step
  double? _distanceToNextManeuver; // Distance to next turn (meters)
  bool _isOffRoute = false; // Off-route detection flag
  bool _hasShownOffRouteAlert = false; // Prevent spam alerts

  // 🔋 Thermal optimization: throttle off-route checks
  DateTime _lastOffRouteCheck = DateTime.now();
  static const Duration _offRouteCheckInterval = Duration(seconds: 15);

  RouteNavigationData? _getRouteData() {
    // Try widget parameter first, then fallback to provider
    if (widget.routeData != null) {
      return widget.routeData;
    }
    // Get from provider if not passed as parameter
    final routeFromProvider = ref.read(missionDetailProvider).routeData;
    return routeFromProvider;
  }

  @override
  void initState() {
    super.initState();

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🗺️ Navigation Screen Initialized');
    debugPrint('   Mission ID: ${widget.missionId}');

    final routeData = _getRouteData();
    debugPrint('   Route data available: ${routeData != null}');
    if (routeData != null) {
      debugPrint('   Route points: ${routeData.points.length}');
      debugPrint('   Distance: ${routeData.formattedDistance}');
      debugPrint('   Duration: ${routeData.formattedDuration}');
      debugPrint('   First point: ${routeData.points.first}');
      debugPrint('   Last point: ${routeData.points.last}');
    } else {
      debugPrint(
        '   ⚠️ WARNING: routeData is NULL in both parameter and provider!',
      );
    }
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    _mapController = MapController();

    // 🔋 Thermal optimization: slower animations = less CPU/GPU work
    // Red pin pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000), // Increased from 1500ms
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      // Reduced from 1.2
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Blue dot pulse animation
    _bluePulseController = AnimationController(
      duration: const Duration(seconds: 3), // Increased from 2s
      vsync: this,
    )..repeat();

    _bluePulseAnimation = Tween<double>(begin: 1.0, end: 2.5).animate(
      // Reduced from 3.0
      CurvedAnimation(parent: _bluePulseController, curve: Curves.easeOut),
    );

    // Start real-time location tracking
    _startLocationTracking();

    // Listen for member's live GPS from MissionHub
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupMissionHubListeners();
      _fitBoundsToRoute();
    });
  }

  void _setupMissionHubListeners() {
    final svc = ref.read(missionHubServiceProvider);
    _missionHubSubscriptions.add(
      svc.memberLocationUpdatedStream.listen((MemberLocationData data) {
        if (!mounted) return;
        setState(() {
          _memberLivePosition = LatLng(data.latitude, data.longitude);
        });
        debugPrint(
          '📍 [NavScreen] Member live position: ${data.latitude}, ${data.longitude}',
        );
      }),
    );
  }

  void _fitBoundsToRoute() {
    final routeData = _getRouteData();
    if (routeData == null || routeData.isEmpty) return;

    final points = routeData.points;

    // Calculate bounds
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    // Add padding
    final latPadding = (maxLat - minLat) * 0.2;
    final lngPadding = (maxLng - minLng) * 0.2;

    final bounds = LatLngBounds(
      LatLng(minLat - latPadding, minLng - lngPadding),
      LatLng(maxLat + latPadding, maxLng + lngPadding),
    );

    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
    );

    debugPrint('🗺️ Map bounds fitted to route');
  }

  void _startLocationTracking() async {
    debugPrint('📍 Starting location tracking...');

    // Check permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cần quyền truy cập vị trí để dẫn đường'),
          ),
        );
      }
      return;
    }

    // Get initial position immediately
    try {
      final initialPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (mounted) {
        setState(() {
          _currentPosition = initialPosition;
          _hasInitialPosition = true;
          _updateDistanceAndETA(initialPosition);
        });

        debugPrint(
          '✅ Initial position acquired: ${initialPosition.latitude}, ${initialPosition.longitude}',
        );

        // Center on user initially if following
        if (_isFollowingUser) {
          _mapController.move(
            LatLng(initialPosition.latitude, initialPosition.longitude),
            16.0,
          );
        }
      }
    } catch (e) {
      debugPrint('⚠️ Could not get initial position: $e');
    }

    // Start tracking
    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter:
                15, // Increased from 10m for battery/thermal savings
          ),
        ).listen((Position position) {
          if (mounted) {
            setState(() {
              _currentPosition = position;
              if (!_hasInitialPosition) {
                _hasInitialPosition = true;
              }
              _updateDistanceAndETA(position);
            });

            // Auto-follow user like Google Maps
            if (_isFollowingUser && mounted) {
              _mapController.move(
                LatLng(position.latitude, position.longitude),
                _mapController.camera.zoom, // Keep current zoom
              );
            }

            ref
                .read(missionDetailProvider.notifier)
                .updateRescuerLocation(position);
          }
        });
  }

  void _updateDistanceAndETA(Position position) {
    // Calculate distance to victim
    final previousDistance = _distanceToVictim;

    _distanceToVictim =
        Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          widget.mission.incident.locationCoordinates.latitude,
          widget.mission.incident.locationCoordinates.longitude,
        ) /
        1000; // Convert to km

    // Estimate time (assuming average speed of 30 km/h)
    if (_distanceToVictim != null) {
      _estimatedTime = (_distanceToVictim! * 2).round(); // minutes
    }

    // ============================================
    // 🧭 POSITION TRACKING & TURN-BY-TURN
    // ============================================
    final routeData = _getRouteData();
    if (routeData != null && routeData.steps.isNotEmpty) {
      // Update distance to next maneuver
      _updateDistanceToNextManeuver(position);

      // Auto-switch to next step when passing maneuver point
      _checkAndSwitchToNextStep(position);

      // Off-route detection
      _checkOffRoute(position);
    }

    // Auto-suggest arrival when very close (100 meters = 0.1km)
    if (_distanceToVictim != null &&
        _distanceToVictim! < 0.1 &&
        (previousDistance == null || previousDistance >= 0.1) &&
        widget.mission.status == 'EnRoute' &&
        widget.mission.arrivedAt == null) {
      // Show arrival confirmation automatically
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showArrivedConfirmation(context);
        }
      });
    }
  }

  /// Calculate distance to next maneuver point
  void _updateDistanceToNextManeuver(Position position) {
    final routeData = _getRouteData();
    if (routeData == null) return;
    final steps = routeData.steps;

    // If we're on the last step or past all steps, show distance to destination
    if (_currentStepIndex >= steps.length - 1) {
      _distanceToNextManeuver = _distanceToVictim! * 1000; // Convert to meters
      return;
    }

    // Get next step's maneuver location
    final nextStep = steps[_currentStepIndex + 1];
    if (nextStep.maneuverLocation != null) {
      _distanceToNextManeuver = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        nextStep.maneuverLocation!.latitude,
        nextStep.maneuverLocation!.longitude,
      );

      debugPrint(
        '📏 Distance to next maneuver: ${_distanceToNextManeuver!.toStringAsFixed(0)}m',
      );
    }
  }

  /// Check if rescuer passed the next maneuver point and switch to next step
  void _checkAndSwitchToNextStep(Position position) {
    final routeData = _getRouteData();
    if (routeData == null) return;
    final steps = routeData.steps;

    // Don't switch if we're already on the last step
    if (_currentStepIndex >= steps.length - 1) return;

    final nextStep = steps[_currentStepIndex + 1];

    // Check if we're close to the next maneuver point (within 20 meters)
    if (nextStep.maneuverLocation != null) {
      final distanceToManeuver = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        nextStep.maneuverLocation!.latitude,
        nextStep.maneuverLocation!.longitude,
      );

      // Switch to next instruction when within 20m of maneuver point
      if (distanceToManeuver < 20) {
        setState(() {
          _currentStepIndex++;
        });

        debugPrint(
          '🔄 Switched to step ${_currentStepIndex + 1}/${steps.length}',
        );
        debugPrint('   Instruction: ${steps[_currentStepIndex].instruction}');

        // Show notification for new instruction only when this route screen is active.
        if (mounted && _isCurrentRoute()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${steps[_currentStepIndex].directionIcon} ${steps[_currentStepIndex].instruction}',
              ),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFFFF8800),
            ),
          );
        }
      }
    }
  }

  /// Check if rescuer is off-route (too far from polyline)
  void _checkOffRoute(Position position) {
    // Throttle: only check every 15 seconds
    final now = DateTime.now();
    if (now.difference(_lastOffRouteCheck) < _offRouteCheckInterval) {
      return; // Skip this check
    }
    _lastOffRouteCheck = now;

    final routeData = _getRouteData();
    if (routeData == null) return;
    final routePoints = routeData.points;
    if (routePoints.isEmpty) return;

    // Find closest point on route polyline
    double minDistance = double.infinity;
    for (final point in routePoints) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        point.latitude,
        point.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
      }
    }

    // Off-route threshold: 50 meters
    final wasOffRoute = _isOffRoute;
    _isOffRoute = minDistance > 50;

    // Show alert when going off-route (only once)
    if (_isOffRoute && !wasOffRoute && !_hasShownOffRouteAlert) {
      _hasShownOffRouteAlert = true;

      debugPrint(
        '⚠️ OFF ROUTE! Distance to route: ${minDistance.toStringAsFixed(0)}m',
      );

      if (mounted && _isCurrentRoute()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Bạn đang đi sai đường! Vui lòng quay lại tuyến đường.',
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFFDC3545),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }

    // Reset alert flag when back on route
    if (!_isOffRoute && wasOffRoute) {
      _hasShownOffRouteAlert = false;
      debugPrint('✅ Back on route!');

      if (mounted && _isCurrentRoute()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Đã quay lại đúng đường!'),
              ],
            ),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    }
  }

  bool _isCurrentRoute() {
    final route = ModalRoute.of(context);
    return route != null && route.isCurrent;
  }

  void _toggleFollowUser() {
    setState(() {
      _isFollowingUser = !_isFollowingUser;
    });

    if (_isFollowingUser && _currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        16.0,
      );
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    for (final s in _missionHubSubscriptions) {
      s.cancel();
    }
    _pulseController.dispose();
    _bluePulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen Map with Route
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(
                widget.mission.incident.locationCoordinates.latitude,
                widget.mission.incident.locationCoordinates.longitude,
              ),
              initialZoom: 14.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              // Disable follow mode when user manually moves map
              onPositionChanged: (position, hasGesture) {
                if (hasGesture && _isFollowingUser) {
                  setState(() => _isFollowingUser = false);
                }
              },
            ),
            children: [
              // OpenStreetMap tiles
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.snakeaid.snakeaid_mobile',
              ),

              // Route polyline (if available)
              if (_getRouteData() != null && _getRouteData()!.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _getRouteData()!.points,
                      strokeWidth: 6.0, // Increased from 4.0 for visibility
                      color: const Color(0xFFFF8800),
                      borderColor: Colors.white,
                      borderStrokeWidth: 2.0,
                    ),
                  ],
                )
              else
                // Debug: Show message if no route
                Builder(
                  builder: (context) {
                    final routeData = _getRouteData();
                    debugPrint('⚠️ WARNING: Route polyline NOT displayed');
                    debugPrint('   routeData is null: ${routeData == null}');
                    debugPrint(
                      '   routeData is empty: ${routeData?.isEmpty ?? true}',
                    );
                    return const SizedBox.shrink();
                  },
                ),

              // Markers for rescuer and victim
              MarkerLayer(
                markers: [
                  // Victim SOS origin marker (red pin – static location where SOS was created)
                  Marker(
                    point: LatLng(
                      widget.mission.incident.locationCoordinates.latitude,
                      widget.mission.incident.locationCoordinates.longitude,
                    ),
                    width: 48,
                    height: 48,
                    child: const Icon(
                      Icons.location_on,
                      color: Color(0xFFDC3545),
                      size: 48,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),

                  // Rescuer location marker (blue dot)
                  if (_currentPosition != null)
                    Marker(
                      point: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      width: 32,
                      height: 32,
                      child: AnimatedBuilder(
                        animation: _bluePulseAnimation,
                        builder: (context, child) {
                          final scale = _bluePulseAnimation.value;
                          final opacity =
                              1.0 - (_bluePulseAnimation.value - 1.0) / 2.0;

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer pulse
                              Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(
                                        0xFF007AFF,
                                      ).withOpacity(opacity.clamp(0.0, 1.0)),
                                      width: 2,
                                    ),
                                    color: const Color(0xFF007AFF).withOpacity(
                                      (0.3 * opacity).clamp(0.0, 1.0),
                                    ),
                                  ),
                                ),
                              ),
                              // Inner dot
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF007AFF),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                ],
              ),

              // Live member position (orange pulsing dot – updates every 15 s)
              if (_memberLivePosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _memberLivePosition!,
                      width: 64,
                      height: 64,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (_, __) => Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer pulse ring – opacity fades out as scale grows
                            Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFFF8800).withOpacity(
                                    (0.4 *
                                            (1.0 -
                                                (_pulseAnimation.value - 1.0) /
                                                    0.2))
                                        .clamp(0.0, 1.0),
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
                            // Core orange dot
                            Container(
                              width: 17,
                              height: 17,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFF8800),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFF8800,
                                    ).withOpacity(0.4),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Top Bar - Simple Back and SOS
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.pop(),
                        customBorder: const CircleBorder(),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC3545),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'SOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Info Bar - Turn-by-turn with distance countdown
          Positioned(
            top: 80,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _isOffRoute
                    ? const Color(0xFFFFEBEE) // Red tint when off-route
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: _isOffRoute
                    ? Border.all(color: const Color(0xFFDC3545), width: 2)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    _isOffRoute ? Icons.warning : Icons.navigation,
                    color: _isOffRoute
                        ? const Color(0xFFDC3545)
                        : const Color(0xFFFF8800),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Distance countdown + instruction
                        Row(
                          children: [
                            // Distance countdown to next maneuver
                            if (_distanceToNextManeuver != null &&
                                _currentStepIndex <
                                    (_getRouteData()?.steps.length ?? 0) - 1)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF8800),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _distanceToNextManeuver! < 1000
                                      ? '${_distanceToNextManeuver!.toStringAsFixed(0)}m'
                                      : '${(_distanceToNextManeuver! / 1000).toStringAsFixed(1)}km',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            if (_distanceToNextManeuver != null &&
                                _currentStepIndex <
                                    (_getRouteData()?.steps.length ?? 0) - 1)
                              const SizedBox(width: 8),
                            // Instruction icon
                            if (_getRouteData() != null &&
                                _getRouteData()!.steps.isNotEmpty)
                              Text(
                                _getRouteData()!
                                    .steps[_currentStepIndex]
                                    .directionIcon,
                                style: const TextStyle(fontSize: 16),
                              ),
                            if (_getRouteData() != null &&
                                _getRouteData()!.steps.isNotEmpty)
                              const SizedBox(width: 6),
                            // Instruction text
                            Expanded(
                              child: Text(
                                _isOffRoute
                                    ? 'Đang đi sai đường!'
                                    : (_distanceToVictim != null &&
                                              _distanceToVictim! < 0.1
                                          ? 'Đã đến gần nạn nhân! 🎯'
                                          : (_getRouteData() != null &&
                                                    _getRouteData()!
                                                        .steps
                                                        .isNotEmpty
                                                ? _getRouteData()!
                                                      .steps[_currentStepIndex]
                                                      .instruction
                                                : 'Vị trí nạn nhân')),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _isOffRoute
                                      ? const Color(0xFFDC3545)
                                      : (_distanceToVictim != null &&
                                                _distanceToVictim! < 0.1
                                            ? const Color(0xFF28A745)
                                            : const Color(0xFF1C100D)),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Distance & ETA to destination
                        Text(
                          _distanceToVictim != null && _estimatedTime != null
                              ? '${_distanceToVictim!.toStringAsFixed(1)} km • $_estimatedTime phút${_isOffRoute ? " • Ngoài tuyến đường" : ""}'
                              : _hasInitialPosition
                              ? 'Đang tính khoảng cách...'
                              : 'Đang lấy vị trí của bạn...',
                          style: TextStyle(
                            fontSize: 11,
                            color: _isOffRoute
                                ? const Color(0xFFDC3545)
                                : const Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Side Controls
          Positioned(
            right: 16,
            top: screenHeight * 0.5 - 60,
            child: Column(
              children: [
                // Re-center / Follow button (like Google Maps)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _isFollowingUser
                        ? const Color(0xFF007AFF) // Blue when following
                        : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _toggleFollowUser,
                      customBorder: const CircleBorder(),
                      child: Icon(
                        _isFollowingUser
                            ? Icons
                                  .my_location // Filled when following
                            : Icons.location_searching, // Outline when not
                        size: 20,
                        color: _isFollowingUser
                            ? Colors.white
                            : const Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Zoom in button
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        final currentZoom = _mapController.camera.zoom;
                        _mapController.move(
                          _mapController.camera.center,
                          currentZoom + 1,
                        );
                        // Disable follow mode when manually zooming
                        setState(() => _isFollowingUser = false);
                      },
                      customBorder: const CircleBorder(),
                      child: const Icon(
                        Icons.add,
                        size: 20,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Zoom out button
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        final currentZoom = _mapController.camera.zoom;
                        _mapController.move(
                          _mapController.camera.center,
                          currentZoom - 1,
                        );
                        // Disable follow mode when manually zooming
                        setState(() => _isFollowingUser = false);
                      },
                      customBorder: const CircleBorder(),
                      child: const Icon(
                        Icons.remove,
                        size: 20,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Sheet - Compact Design
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 12),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        // Patient Info - One Line
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF8800),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.mission.user.account?.fullName ??
                                        'Nạn nhân',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1C100D),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${widget.mission.incident.getSeverityText()} • Rắn độc',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFDC3545),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF8800).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    // TODO: Call victim
                                  },
                                  customBorder: const CircleBorder(),
                                  child: const Icon(
                                    Icons.call,
                                    color: Color(0xFFFF8800),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 16),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(flex: 2, child: _buildArrivalButton()),
                            const SizedBox(width: 12),
                            _buildCompactButton(
                              Icons.info_outline,
                              const Color(0xFF666666),
                              () {
                                context.pop();
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildCompactButton(
                              Icons.close,
                              const Color(0xFFDC3545),
                              () => _showCancelTripDialog(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay when waiting for GPS
          if (!_hasInitialPosition)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFFF8800),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Đang lấy vị trí của bạn...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildArrivalButton() {
    // Enable button only when within 100m (0.1km)
    // final canArrive = _distanceToVictim != null && _distanceToVictim! < 0.1;
    final canArrive = true; // testing: enable nút arrival dù đang cách xa
    final isEnabled =
        canArrive ||
        !_hasInitialPosition; // Enable if no GPS yet (user can manually confirm)

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isEnabled
            ? const Color(0xFFFF8800)
            : const Color(0xFFCCCCCC), // Gray when disabled
        borderRadius: BorderRadius.circular(12),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: const Color(0xFFFF8800).withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isEnabled
              ? () => _showArrivedConfirmation(context)
              : null, // Disable tap when too far
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                canArrive ? Icons.check_circle : Icons.location_on,
                color: isEnabled ? Colors.white : const Color(0xFF999999),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                canArrive
                    ? 'Đã đến nơi'
                    : (_distanceToVictim != null
                          ? 'Còn ${(_distanceToVictim! * 1000).toStringAsFixed(0)}m'
                          : 'Đã đến nơi'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isEnabled ? Colors.white : const Color(0xFF999999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactButton(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  void _showCancelTripDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        String? selectedReason;

        return StatefulBuilder(
          builder: (context, setState) => CustomDialog(
            icon: Icons.cancel_outlined,
            iconBackgroundColor: const Color(0xFFFFEBEE),
            iconColor: const Color(0xFFDC3545),
            title: 'Hủy Chuyến Cứu Hộ?',
            description:
                'Vui lòng chọn lý do hủy chuyến để chúng tôi cải thiện dịch vụ',
            extraContent: [
              _buildReasonOption(
                'Không thể đến địa điểm',
                'location',
                selectedReason,
                (value) {
                  setState(() => selectedReason = value);
                },
              ),
              _buildReasonOption(
                'Bệnh nhân không liên lạc được',
                'contact',
                selectedReason,
                (value) {
                  setState(() => selectedReason = value);
                },
              ),
              _buildReasonOption(
                'Có việc khẩn cấp khác',
                'urgent',
                selectedReason,
                (value) {
                  setState(() => selectedReason = value);
                },
              ),
              _buildReasonOption(
                'Tình trạng không nghiêm trọng',
                'not_serious',
                selectedReason,
                (value) {
                  setState(() => selectedReason = value);
                },
              ),
              _buildReasonOption('Lý do khác', 'other', selectedReason, (
                value,
              ) {
                setState(() => selectedReason = value);
              }),
            ],
            actions: [
              DialogAction(
                label: 'Quay lại',
                isOutlined: true,
                onPressed: () => context.pop(),
              ),
              DialogAction(
                label: 'Xác nhận hủy',
                backgroundColor: const Color(0xFFDC3545),
                onPressed: () {
                  if (selectedReason != null) {
                    Navigator.of(dialogContext).pop();
                    context.pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReasonOption(
    String label,
    String value,
    String? selectedReason,
    Function(String) onSelect,
  ) {
    final isSelected = selectedReason == value;
    return InkWell(
      onTap: () => onSelect(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF8800).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF8800)
                : const Color(0xFFE5E5E5),
            width: isSelected ? 2 : 1,
          ),
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
                      : const Color(0xFFCCCCCC),
                  width: 2,
                ),
                color: isSelected ? const Color(0xFFFF8800) : Colors.white,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: const Color(0xFF1C100D),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showArrivedConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => CustomDialog(
        icon: Icons.check_circle,
        iconBackgroundColor: const Color(0xFFD4EDDA),
        iconColor: const Color(0xFFFF8800),
        title: 'Xác Nhận Đã Đến Nơi?',
        description:
            'Sau khi xác nhận, bệnh nhân sẽ được thông báo và bạn có thể bắt đầu hỗ trợ.',
        extraContent: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFE69C)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF856404), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Đảm bảo bạn đã ở đúng vị trí trước khi xác nhận',
                    style: TextStyle(fontSize: 13, color: Color(0xFF856404)),
                  ),
                ),
              ],
            ),
          ),
        ],
        actions: [
          DialogAction(
            label: 'Chưa đến',
            isOutlined: true,
            onPressed: () => Navigator.pop(dialogContext),
          ),
          DialogAction(
            label: 'Xác nhận',
            backgroundColor: const Color(0xFFFF8800),
            onPressed: () async {
              Navigator.pop(dialogContext);

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF8800),
                    ),
                  ),
                ),
              );

              // Call markArrival from provider
              try {
                final success = await ref
                    .read(missionDetailProvider.notifier)
                    .markArrival();

                if (mounted) {
                  Navigator.pop(context); // Close loading

                  if (success) {
                    // Navigate to support screen
                    context.pushNamed(
                      'rescuer_support',
                      extra: {
                        'missionId': widget.missionId,
                        'incidentId': widget.mission.incidentId,
                      },
                    );
                  } else {
                    // Show error
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Không thể cập nhật trạng thái. Vui lòng thử lại.',
                        ),
                        backgroundColor: Color(0xFFDC3545),
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: ${e.toString()}'),
                      backgroundColor: const Color(0xFFDC3545),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
