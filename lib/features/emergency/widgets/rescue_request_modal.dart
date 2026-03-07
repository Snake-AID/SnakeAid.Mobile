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
import '../repository/incident_repository.dart';
import '../providers/rescuer_emergency_provider.dart';
import '../providers/mission_hub_provider.dart';
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

    _remainingSeconds = widget.request.remainingSeconds;
    debugPrint(
      '⏱️ Initial remaining seconds: $_remainingSeconds (calculated from UTC)',
    );

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

        // Fetch address from coordinates
        _fetchLocationAddress(
          _incident!.locationCoordinates.latitude,
          _incident!.locationCoordinates.longitude,
        );
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
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingSeconds = widget.request.remainingSeconds;

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

  void _onTimeout() {
    _stopAlarmSound();
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
    return _buildFullModal();
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
      color: Colors.black54,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFD32F2F),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: const Icon(
                        Icons.emergency,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'YÊU CẦU CỨU HỘ KHẨN CẤP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.minimize, color: Colors.white),
                      onPressed: _toggleMinimize,
                      tooltip: 'Thu nhỏ',
                    ),
                  ],
                ),
              ),

              // Countdown
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                color: const Color(0xFFFFF3E0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer, color: Color(0xFFFF6B35)),
                    const SizedBox(width: 8),
                    Text(
                      'Còn $_remainingSeconds giây',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _isLoadingIncident
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _buildIncidentDetails(),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isAccepting || _incident == null
                            ? null
                            : _onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          disabledBackgroundColor: const Color(
                            0xFF4CAF50,
                          ).withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isAccepting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle, size: 24),
                                  SizedBox(width: 8),
                                  Text(
                                    'NHẬN NHIỆM VỤ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mission price (always show)
          _buildMissionPriceCard(),

          if (_distanceKm != null) ...[
            const SizedBox(height: 12),
            _buildDistanceCard(),
          ],
          const SizedBox(height: 16),

          // Victim info
          _buildVictimInfoCard(),
          const SizedBox(height: 16),

          // Emergency contacts (always show)
          _buildEmergencyContactsCard(),
          const SizedBox(height: 16),

          // Map section
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            clipBehavior: Clip.antiAlias,
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
                // Maptile
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.snakeaid.mobile',
                  maxZoom: 19,
                  tileBuilder: (context, tileWidget, tile) {
                    // Add subtle attribution watermark
                    return DecoratedBox(
                      decoration: const BoxDecoration(),
                      child: tileWidget,
                    );
                  },
                ),

                // Emergency location marker
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
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                      ),
                    ),
                    child: const Text(
                      '© OpenStreetMap',
                      style: TextStyle(fontSize: 8, color: Colors.black54),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Address card
          _buildInfoCard(
            icon: Icons.place,
            title: 'Địa điểm',
            value: _isLoadingAddress
                ? 'Đang tải địa chỉ...'
                : (_locationAddress ?? 'Không xác định'),
            subtitle:
                'Tọa độ: ${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}',
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 12),

          _buildInfoCard(
            icon: Icons.radio_button_checked,
            title: 'Bán kính tìm kiếm',
            value: widget.request.formattedRadius,
            color: const Color(0xFF2196F3),
          ),
          const SizedBox(height: 12),

          _buildInfoCard(
            icon: Icons.medical_services,
            title: 'Mức độ nghiêm trọng',
            value: _getSeverityText(_incident!.severityLevel),
            color: _getSeverityColor(_incident!.severityLevel),
          ),
          const SizedBox(height: 12),

          // Symptoms (always show, even if empty)
          const Text(
            'Triệu chứng:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildSymptomsCard(),
          const SizedBox(height: 12),

          // Snake detection results (always show)
          _buildSnakeDetectionCard(),
          const SizedBox(height: 12),

          // Incident occurred time (always show)
          _buildIncidentTimeCard(),
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
                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.grey[300]!, Colors.grey[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: hasPrice
            ? [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              hasPrice ? Icons.attach_money : Icons.info_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phí dịch vụ',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasPrice ? mission.formattedPrice : 'Chưa xác định',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                if (!hasPrice)
                  const Text(
                    'Sẽ được tính sau khi hoàn thành',
                    style: TextStyle(
                      color: Colors.white70,
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

  Widget _buildDistanceCard() {
    if (_distanceKm == null || _etaMinutes == null) return const SizedBox();

    final colorStr = DistanceUtils.getDistanceColorHex(_distanceKm!);
    final color = Color(int.parse('0xFF$colorStr'));

    return _buildInfoCard(
      icon: Icons.navigation,
      title: 'Khoảng cách & ETA',
      value: DistanceUtils.formatDistance(_distanceKm!),
      subtitle: 'Thời gian dự kiến: ${DistanceUtils.formatETA(_etaMinutes!)}',
      color: color,
    );
  }

  Widget _buildVictimInfoCard() {
    final user = _incident!.user;
    final account = user.account;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
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
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF4CAF50),
                backgroundImage: account?.avatarUrl != null
                    ? NetworkImage(account!.avatarUrl!)
                    : null,
                child: account?.avatarUrl == null
                    ? Text(
                        account?.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 20,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (user.ratingCount > 0)
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${user.rating.toStringAsFixed(1)} (${user.ratingCount} đánh giá)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'Người dùng mới',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
            ],
          ),
          // Underlying disease warning
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
                  const Icon(
                    Icons.warning_amber,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '⚠️ Nạn nhân có bệnh nền - cần thận trọng',
                      style: TextStyle(
                        fontSize: 13,
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
    // Filter out null, empty, or whitespace-only contacts
    final contacts = _incident!.user.emergencyContacts
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
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: hasContacts
                      ? const Color(0xFFE65100)
                      : Colors.grey[700],
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
                      Expanded(
                        child: Text(
                          phone,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _makePhoneCall(phone),
                        icon: const Icon(Icons.phone, color: Color(0xFF4CAF50)),
                        tooltip: 'Gọi',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
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

  Widget _buildSymptomsCard() {
    final hasSymptoms =
        _incident!.symptomsReport != null &&
        _incident!.symptomsReport!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasSymptoms ? const Color(0xFFFFF3E0) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasSymptoms
              ? const Color(0xFFFF9800).withOpacity(0.3)
              : Colors.grey[300]!,
        ),
      ),
      child: hasSymptoms
          ? Text(
              _incident!.symptomsReport!,
              style: const TextStyle(fontSize: 14, color: Color(0xFFE65100)),
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
    );
  }

  Widget _buildSnakeDetectionCard() {
    final media = _incident!.media;
    final hasMedia = media.isNotEmpty && media.first.mediaUrl.trim().isNotEmpty;

    final firstMedia = hasMedia ? media.first : null;
    final hasAI = firstMedia?.detectedSpecies.isNotEmpty ?? false;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.image, color: Color(0xFF4CAF50), size: 18),
              SizedBox(width: 8),
              Text(
                '🐍 Hình ảnh & nhận diện',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Show image or placeholder
          hasMedia
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Image.network(
                        firstMedia!.mediaUrl,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 150,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    size: 48,
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
                          );
                        },
                      ),
                      if (hasAI)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
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
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
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
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'AI chưa thể nhận diện loài rắn',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          if (hasMedia && media.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '+${media.length - 1} ảnh khác',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIncidentTimeCard() {
    final occurredAt = _incident!.incidentOccurredAt;

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
        timeText = '$hours giờ ${remainingMinutes} phút trước';
        timeColor = const Color(0xFFD32F2F);
      }

      return _buildInfoCard(
        icon: Icons.access_time,
        title: 'Thời gian xảy ra',
        value: timeText,
        subtitle: occurredAt.toString().substring(0, 16),
        color: timeColor,
      );
    } else {
      // Show placeholder when time not available
      return _buildInfoCard(
        icon: Icons.access_time_outlined,
        title: 'Thời gian xảy ra',
        value: 'Không xác định',
        subtitle: 'Vừa mới được báo cáo',
        color: Colors.grey,
      );
    }
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
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
    if (level >= 4) return 'Nghiêm trọng';
    if (level >= 3) return 'Cao';
    if (level >= 2) return 'Trung bình';
    return 'Thấp';
  }

  Color _getSeverityColor(int level) {
    if (level >= 4) return const Color(0xFFD32F2F);
    if (level >= 3) return const Color(0xFFFF9800);
    if (level >= 2) return const Color(0xFFFFC107);
    return const Color(0xFF4CAF50);
  }
}
