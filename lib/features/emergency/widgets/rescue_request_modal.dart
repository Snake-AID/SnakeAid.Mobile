import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../models/rescue_request.dart';
import '../models/detailed_incident_response.dart';
import '../models/rescue_mission_response.dart';
import '../repository/incident_repository.dart';
import '../providers/rescuer_emergency_provider.dart';
import '../providers/mission_hub_provider.dart';
import '../providers/active_mission_provider.dart';
import '../../rescuer/providers/tracking_provider.dart';
import '../../../core/services/nominatim_service.dart';
import '../../../core/utils/distance_utils.dart';

/// Rescue Request Modal - Can be minimized to bubble
/// Displays rescue request and fetches incident details via HTTP
class RescueRequestModal extends ConsumerStatefulWidget {
  final RescueRequest request;
  final VoidCallback onDismiss;

  const RescueRequestModal({
    super.key,
    required this.request,
    required this.onDismiss,
  });

  @override
  ConsumerState<RescueRequestModal> createState() => _RescueRequestModalState();
}

class _RescueRequestModalState extends ConsumerState<RescueRequestModal>
    with TickerProviderStateMixin {
  bool _isMinimized = false;
  bool _isLoadingIncident = true;
  bool _isAccepting = false;
  DetailedIncidentData? _incident;
  String? _errorMessage;

  // Rescuer location for distance calculation
  Position? _rescuerPosition;
  double? _distanceKm;
  int? _etaMinutes;

  // Map & Location
  final MapController _mapController = MapController();
  String? _locationAddress;
  bool _isLoadingAddress = true;
  final NominatimService _nominatimService = NominatimService();

  int _remainingSeconds = 60;
  Timer? _countdownTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _bubbleController;

  @override
  void initState() {
    super.initState();

    _remainingSeconds = RescueRequest.requestTimeoutSeconds;
    debugPrint('⏱️ Starting internal countdown: $_remainingSeconds seconds');

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Bubble animation
    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _startCountdown();
    _playAlarmSound();
    _vibrate();
    _fetchIncidentDetails();
    _getRescuerLocation();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _audioPlayer.dispose();
    _pulseController.dispose();
    _bubbleController.dispose();
    // MapController (flutter_map) doesn't need dispose
    super.dispose();
  }

  Future<void> _fetchIncidentDetails() async {
    try {
      setState(() {
        _isLoadingIncident = true;
        _errorMessage = null;
      });

      final repository = ref.read(incidentRepositoryProvider);
      final response = await repository.getDetailedIncident(
        widget.request.incidentId,
      );

      if (response.isSuccess && response.data != null) {
        setState(() {
          _incident = response.data;
          _isLoadingIncident = false;
        });

        // Use API address if provided, otherwise fallback to reverse geocode
        if (_incident?.address != null && _incident!.address!.isNotEmpty) {
          setState(() {
            _locationAddress = _incident!.address;
            _isLoadingAddress = false;
          });
        } else {
          _fetchLocationAddress(
            _incident!.locationCoordinates.latitude,
            _incident!.locationCoordinates.longitude,
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Không thể tải thông tin sự cố';
          _isLoadingIncident = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch incident: $e');
      setState(() {
        _errorMessage =
            'Lỗi khi tải thông tin: ${e.toString().replaceAll('Exception: ', '')}';
        _isLoadingIncident = false;
      });
    }
  }

  Future<void> _getRescuerLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _rescuerPosition = position;
          _calculateDistance();
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to get rescuer location: $e');
      // Non-critical, just won't show distance/ETA
    }
  }

  void _calculateDistance() {
    if (_rescuerPosition == null || _incident == null) return;

    final distance = DistanceUtils.calculateDistance(
      lat1: _rescuerPosition!.latitude,
      lon1: _rescuerPosition!.longitude,
      lat2: _incident!.locationCoordinates.latitude,
      lon2: _incident!.locationCoordinates.longitude,
    );

    final eta = DistanceUtils.estimateETA(distance);

    setState(() {
      _distanceKm = distance;
      _etaMinutes = eta;
    });

    debugPrint(
      '📍 Distance to incident: ${DistanceUtils.formatDistance(distance)}',
    );
    debugPrint('⏱️ ETA: ${DistanceUtils.formatETA(eta)}');
  }

  Future<void> _fetchLocationAddress(double lat, double lon) async {
    try {
      setState(() {
        _isLoadingAddress = true;
      });

      debugPrint('🗺️ Fetching address for: $lat, $lon');

      // geocoding address
      final address = await _nominatimService.reverseGeocode(lat, lon);

      if (address != null && address.isNotEmpty) {
        setState(() {
          _locationAddress = address;
          _isLoadingAddress = false;
        });

        debugPrint('✅ Address: $address');
      } else {
        setState(() {
          _locationAddress = 'Không tìm thấy địa chỉ';
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch address: $e');
      setState(() {
        _locationAddress = 'Lỗi khi tải địa chỉ';
        _isLoadingAddress = false;
      });
    }
  }

  void _startCountdown() {
    _remainingSeconds = RescueRequest.requestTimeoutSeconds;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        final nextSeconds = _remainingSeconds - 1;
        _remainingSeconds = nextSeconds > 0 ? nextSeconds : 0;

        if (_remainingSeconds % 10 == 0 &&
            _remainingSeconds > 0 &&
            !_isMinimized) {
          _vibrate();
        }

        if (_remainingSeconds <= 0) {
          timer.cancel();
          _onTimeout();
        }
      });
    });
  }

  Future<void> _playAlarmSound() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(0.5);
    } catch (e) {
      debugPrint('Failed to play alarm: $e');
    }
  }

  void _stopAlarmSound() {
    _audioPlayer.stop();
  }

  Future<void> _vibrate() async {
    try {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(pattern: [0, 300, 100, 300]);
      }
    } catch (e) {
      debugPrint('Failed to vibrate: $e');
    }
  }

  Future<void> _onTimeout() async {
    _stopAlarmSound();

    // Notify backend that dispatch request was not accepted in time.
    try {
      await ref
          .read(rescuerSignalRServiceProvider)
          .declineDispatchRequest(widget.request.requestId, 'TIMEOUT');
    } catch (e) {
      debugPrint('❌ Failed to send decline request on timeout: $e');
    }

    // Clear active request state
    ref.read(activeRescueRequestProvider.notifier).clearRequest();

    widget.onDismiss();
  }

  void _toggleMinimize() {
    setState(() {
      _isMinimized = !_isMinimized;
      if (_isMinimized) {
        _bubbleController.forward();
        _stopAlarmSound(); // Stop alarm when minimized
      } else {
        _bubbleController.reverse();
      }
    });
  }

  /// Connect rescuer to MissionHub and start broadcasting GPS to the member.
  Future<void> _connectRescuerToMissionHub(
    String incidentId,
    String rescuerId,
  ) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(
        '🔌 [RescueRequestModal] _connectRescuerToMissionHub() called',
      );
      debugPrint('   Incident ID: $incidentId');
      debugPrint('   Rescuer ID: $rescuerId');

      debugPrint(
        '🔌 [RescueRequestModal] Connecting rescuer to MissionHub for incident: $incidentId',
      );
      await ref
          .read(missionHubConnectionProvider.notifier)
          .connectForIncident(incidentId);
      debugPrint(
        '✅ [RescueRequestModal] Rescuer joined MissionHub group: $incidentId',
      );

      // Start streaming GPS → MissionHub.UpdateLocation → member map
      debugPrint('📍 [RescueRequestModal] Starting mission tracking...');
      final missionHubService = ref.read(missionHubServiceProvider);
      debugPrint(
        '📍 [RescueRequestModal] MissionHub service connected: ${missionHubService.isConnected}',
      );

      await ref
          .read(locationManagerProvider)
          .startMissionTracking(rescuerId, incidentId, missionHubService);
      debugPrint(
        '✅✅✅ [RescueRequestModal] Rescuer GPS tracking started for incident $incidentId ✅✅✅',
      );
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } catch (e, stack) {
      debugPrint(
        '❌ [RescueRequestModal] Failed to connect rescuer to MissionHub: $e',
      );
      debugPrint('Stack trace: $stack');
    }
  }

  Future<void> _onAccept() async {
    if (_isAccepting || _incident == null) return;

    setState(() {
      _isAccepting = true;
    });

    _countdownTimer?.cancel();
    _stopAlarmSound();

    try {
      final prefs = await SharedPreferences.getInstance();
      final rescuerId = prefs.getString('user_id');

      if (rescuerId == null) {
        throw Exception('Rescuer ID not found');
      }

      final response = await ref
          .read(activeRescueRequestProvider.notifier)
          .acceptRequest(rescuerId);

      if (!mounted) return;

      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã nhận nhiệm vụ thành công!'),
            backgroundColor: Colors.green,
          ),
        );

        // 🔌 DISCONNECT from RescuerHub (stop receiving new rescue requests)
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('🔌 Disconnecting from RescuerHub...');
        debugPrint('   Reason: Mission accepted, switching to MissionHub');
        try {
          await ref.read(rescueModeProvider.notifier).stopRescueMode();
          debugPrint('✅ Disconnected from RescuerHub successfully');
        } catch (e) {
          debugPrint('❌ Failed to disconnect RescuerHub: $e');
          // Continue anyway - not critical
        }
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        // Save mission to active_mission_provider for persistence
        if (response.missionId != null && response.incidentId != null) {
          final basicMission = BasicRescueMissionResponse(
            missionId: response.missionId!,
            incidentId: response.incidentId!,
            status: 'Preparing', // Initial status when accepted
            acceptedAt: DateTime.now(),
            startedAt: null,
          );
          await ref
              .read(activeMissionProvider.notifier)
              .saveActiveMission(basicMission);
          debugPrint(
            '💾 [RescueRequestModal] Active mission saved: ${response.missionId}',
          );
        }

        // Navigate FIRST for instant UI response
        if (response.missionId != null) {
          debugPrint(
            '🚀 [RescueRequestModal] Navigating to mission detail: ${response.missionId}',
          );
          context.push('/rescuer/mission-detail/${response.missionId}');

          // Dismiss modal AFTER navigation started
          widget.onDismiss();

          // Connect rescuer to MissionHub and start GPS broadcast to member
          // Run in background (no await) to not block UI
          if (response.incidentId != null) {
            debugPrint(
              '🔌 [RescueRequestModal] Starting MissionHub connection in background...',
            );
            _connectRescuerToMissionHub(response.incidentId!, rescuerId)
                .then((_) {
                  debugPrint(
                    '✅ [RescueRequestModal] Background MissionHub connection completed',
                  );
                })
                .catchError((error) {
                  debugPrint(
                    '❌ [RescueRequestModal] Background connection failed: $error',
                  );
                });
          }
        } else {
          widget.onDismiss();
          debugPrint('⚠️ WARNING: Mission accepted but no missionId returned!');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '⚠️ Nhiệm vụ đã nhận nhưng không có ID. Vui lòng kiểm tra lịch sử.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: response.error == 'RACE_CONDITION'
                ? Colors.orange
                : Colors.red,
          ),
        );
        widget.onDismiss();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Có lỗi xảy ra. Vui lòng thử lại.'),
          backgroundColor: Colors.red,
        ),
      );
      widget.onDismiss();
    } finally {
      if (mounted) {
        setState(() {
          _isAccepting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isMinimized) {
      return _buildMinimizedBubble();
    }
    return DefaultTextStyle.merge(
      style: const TextStyle(
        decoration: TextDecoration.none,
        fontFamily: 'Roboto',
      ),
      child: _buildFullModal(),
    );
  }

  Widget _buildMinimizedBubble() {
    // Wrap in Stack with transparent barrier to allow tap-through
    return Stack(
      children: [
        // Transparent barrier (allow interaction with app below)
        const SizedBox.expand(),

        // Floating bubble
        Positioned(
          right: 16,
          bottom: 100,
          child: GestureDetector(
            onTap: _toggleMinimize,
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF1744), Color(0xFFDC3545)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDC3545).withOpacity(0.6),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // SOS text and icon
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emergency,
                              color: Colors.white,
                              size: 36,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'SOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_remainingSeconds}s',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Pulse ring indicator
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullModal() {
    return Container(
      color: const Color(0xFFF5F6FA),
      child: SafeArea(
        child: Column(
          children: [
            _buildModalHeader(),
            Expanded(
              child: _isLoadingIncident
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFD32F2F),
                      ),
                    )
                  : _errorMessage != null
                  ? _buildErrorDisplay()
                  : _buildIncidentDetails(),
            ),
            _buildAcceptFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildModalHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFC62828), Color(0xFFE53935)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      child: Column(
        children: [
          // ─── Title row ──────────────────────────────────────────
          Row(
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.emergency,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YÊU CẦU CỨU HỘ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      'Khẩn cấp · Cần phản hồi ngay',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _toggleMinimize,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.minimize, color: Colors.white70, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'X',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // ─── Countdown ──────────────────────────────────────────
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              final urgency = _remainingSeconds < 15;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: (_remainingSeconds / 60).clamp(0.0, 1.0),
                          strokeWidth: 5,
                          backgroundColor: Colors.white.withOpacity(0.25),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            urgency ? Colors.yellow : Colors.white,
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$_remainingSeconds',
                                style: TextStyle(
                                  color: urgency ? Colors.yellow : Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'giây',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        urgency
                            ? '⚠️ Sắp hết thời gian!'
                            : 'Thời gian phản hồi',
                        style: TextStyle(
                          color: urgency ? Colors.yellow : Colors.white,
                          fontSize: 14,
                          fontWeight: urgency
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        urgency ? 'Quyết định ngay!' : 'Hãy quyết định nhanh',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptFooter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isAccepting || _incident == null ? null : _onAccept,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            disabledBackgroundColor: const Color(0xFF2E7D32).withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: _isAccepting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 22,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'NHẬN NHIỆM VỤ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildErrorDisplay() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 58, color: Color(0xFFD32F2F)),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _fetchIncidentDetails,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentDetails() {
    if (_incident == null) return const SizedBox();

    final lat = _incident!.locationCoordinates.latitude;
    final lon = _incident!.locationCoordinates.longitude;
    final latLng = LatLng(lat, lon);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Quick stat chips ────────────────────────────────────
          _buildQuickStatsRow(),
          const SizedBox(height: 14),

          // ─── Price ───────────────────────────────────────────────
          _buildMissionPriceCard(),
          const SizedBox(height: 12),

          // ─── Victim ──────────────────────────────────────────────
          _buildVictimInfoCard(),
          const SizedBox(height: 12),

          // ─── Emergency contacts ──────────────────────────────────
          _buildEmergencyContactsCard(),
          const SizedBox(height: 12),

          // ─── Map ─────────────────────────────────────────────────
          _buildSectionCard(
            icon: Icons.map_outlined,
            iconColor: const Color(0xFF2196F3),
            title: 'Bản đồ vị trí',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 180,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: latLng,
                    initialZoom: 15.0,
                    minZoom: 10.0,
                    maxZoom: 18.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.snakeaid.mobile',
                      maxZoom: 19,
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: latLng,
                          width: 40,
                          height: 40,
                          alignment: Alignment.topCenter,
                          child: const Icon(
                            Icons.location_pin,
                            size: 40,
                            color: Color(0xFFD32F2F),
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black38,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        color: Colors.white70,
                        child: const Text(
                          '© OpenStreetMap',
                          style: TextStyle(fontSize: 8, color: Colors.black54),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ─── Address ─────────────────────────────────────────────
          _buildSectionCard(
            icon: Icons.place_outlined,
            iconColor: const Color(0xFF4CAF50),
            title: 'Địa điểm',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLoadingAddress
                      ? 'Đang tải địa chỉ...'
                      : (_locationAddress ?? 'Không xác định'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tọa độ: ${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ─── Symptoms ────────────────────────────────────────────
          _buildSymptomsCard(),
          const SizedBox(height: 12),

          // ─── Snake image & detection ─────────────────────────────
          _buildSnakeDetectionCard(),
          const SizedBox(height: 12),

          // ─── Incident time ───────────────────────────────────────
          _buildIncidentTimeCard(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildQuickStatsRow() {
    final severityText = _getSeverityText(_incident!.severityLevel);
    final severityColor = _getSeverityColor(_incident!.severityLevel);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildStatChip(
          icon: Icons.medical_services_outlined,
          label: severityText,
          color: severityColor,
        ),
        _buildStatChip(
          icon: Icons.radio_button_checked,
          label: widget.request.formattedRadius,
          color: const Color(0xFF2196F3),
        ),
        if (_distanceKm != null)
          _buildStatChip(
            icon: Icons.navigation_outlined,
            label: DistanceUtils.formatDistance(_distanceKm!),
            color: const Color(0xFF9C27B0),
          ),
        if (_etaMinutes != null)
          _buildStatChip(
            icon: Icons.access_time_outlined,
            label: 'ETA: ${DistanceUtils.formatETA(_etaMinutes!)}',
            color: const Color(0xFFFF9800),
          ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: iconColor),
              const SizedBox(width: 7),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildMissionPriceCard() {
    final mission = _incident!.activeMission;
    final hasPrice = mission != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: hasPrice
            ? const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.grey[400]!, Colors.grey[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              hasPrice ? Icons.attach_money : Icons.info_outline,
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
                  'Phí dịch vụ',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  hasPrice ? mission.formattedPrice : 'Chưa xác định',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!hasPrice)
                  const Text(
                    'Sẽ được tính sau khi hoàn thành',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVictimInfoCard() {
    final user = _incident!.user;
    final account = user.account;

    return _buildSectionCard(
      icon: Icons.person_outline,
      iconColor: const Color(0xFF1565C0),
      title: 'Thông tin nạn nhân',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF4CAF50),
                backgroundImage: account?.avatarUrl != null
                    ? NetworkImage(account!.avatarUrl!)
                    : null,
                child: account?.avatarUrl == null
                    ? Text(
                        account?.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (user.ratingCount > 0)
                      Row(
                        children: [
                          const Icon(Icons.star, size: 13, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${user.rating.toStringAsFixed(1)} (${user.ratingCount} đánh giá)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'Người dùng mới',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (user.hasUnderlyingDisease) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nạn nhân có bệnh nền - cần thận trọng',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
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

  Widget _buildEmergencyContactsCard() {
    final contacts = _incident!.user.emergencyContacts
        .where((c) => c.trim().isNotEmpty)
        .toList();
    final hasContacts = contacts.isNotEmpty;

    return _buildSectionCard(
      icon: Icons.phone_outlined,
      iconColor: const Color(0xFFFF6B35),
      title: 'Liên hệ khẩn cấp',
      child: hasContacts
          ? Column(
              children: contacts.asMap().entries.map((entry) {
                final index = entry.key;
                final phone = entry.value;
                return Column(
                  children: [
                    if (index > 0) Divider(height: 16, color: Colors.grey[200]),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            phone,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _makePhoneCall(phone),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.phone,
                                  size: 14,
                                  color: Color(0xFF2E7D32),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Gọi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF2E7D32),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }).toList(),
            )
          : Row(
              children: [
                Icon(Icons.info_outline, size: 15, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Người dùng chưa cung cấp số liên hệ khẩn cấp',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSymptomsCard() {
    final hasSymptoms =
        _incident!.symptomsReport != null &&
        _incident!.symptomsReport!.isNotEmpty;

    return _buildSectionCard(
      icon: Icons.medical_information_outlined,
      iconColor: const Color(0xFFE65100),
      title: 'Triệu chứng',
      child: hasSymptoms
          ? Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _incident!.symptomsReport!
                  .map(
                    (symptom) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFF9800).withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        symptom.symptomName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFE65100),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            )
          : Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Text(
                  'Người dùng chưa cung cấp thông tin',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSnakeDetectionCard() {
    final media = _incident!.media;
    final hasMedia = media.isNotEmpty && media.first.mediaUrl.trim().isNotEmpty;
    final firstMedia = hasMedia ? media.first : null;
    final hasAI = firstMedia?.detectedSpecies.isNotEmpty ?? false;

    return _buildSectionCard(
      icon: Icons.image_search_outlined,
      iconColor: const Color(0xFF4CAF50),
      title: 'Hình ảnh & nhận diện',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          hasMedia
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Image.network(
                        firstMedia!.mediaUrl,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 160,
                            color: Colors.grey[100],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, _) => Container(
                          height: 160,
                          color: Colors.grey[100],
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Không thể tải ảnh',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (hasAI)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.black87, Colors.transparent],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  firstMedia.detectedSpecies.first.commonName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Loài: ${firstMedia.detectedSpecies.first.scientificName}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported_outlined,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Người dùng chưa cung cấp hình ảnh',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'AI chưa thể nhận diện loài rắn',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          if (hasMedia && media.length > 1) ...[
            const SizedBox(height: 6),
            Text(
              '+${media.length - 1} ảnh khác',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIncidentTimeCard() {
    final occurredAt = _incident!.incidentOccurredAt;

    if (occurredAt == null) {
      return _buildSectionCard(
        icon: Icons.access_time_outlined,
        iconColor: Colors.grey,
        title: 'Thời gian xảy ra',
        child: Text(
          'Không xác định',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    final elapsed = DateTime.now().difference(occurredAt);
    final minutes = elapsed.inMinutes;
    final String timeText;
    final Color timeColor;

    if (minutes < 60) {
      timeText = '$minutes phút trước';
      timeColor = minutes > 30
          ? const Color(0xFFD32F2F)
          : const Color(0xFFFF9800);
    } else {
      final hours = minutes ~/ 60;
      final remaining = minutes % 60;
      timeText = '$hours giờ $remaining phút trước';
      timeColor = const Color(0xFFD32F2F);
    }

    return _buildSectionCard(
      icon: Icons.access_time_outlined,
      iconColor: timeColor,
      title: 'Thời gian xảy ra',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            timeText,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: timeColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            occurredAt.toString().substring(0, 16),
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // Clean and validate phone number
    final cleanedPhone = phoneNumber.trim().replaceAll(RegExp(r'[^0-9+]'), '');

    if (cleanedPhone.isEmpty) {
      if (!mounted) return;
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
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể thực hiện cuộc gọi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to make call: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi khi thực hiện cuộc gọi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getSeverityText(int level) {
    if (level >= 70) return 'Nghiêm trọng';
    if (level >= 40) return 'Cao';
    if (level >= 10) return 'Trung bình';
    return 'Thấp';
  }

  Color _getSeverityColor(int level) {
    if (level >= 70) return const Color(0xFFD32F2F);
    if (level >= 40) return const Color(0xFFFF9800);
    if (level >= 10) return const Color(0xFFFFC107);
    return const Color(0xFF4CAF50);
  }
}
