import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import '../../models/sos_incident_response.dart';
import '../../providers/incident_provider.dart';
import '../../repository/incident_repository.dart';

/// Emergency Alert Screen - Shows when user presses SOS button
/// Displays map, searching for rescuers, and safety instructions
class EmergencyAlertScreen extends ConsumerStatefulWidget {
  final IncidentData? incident;
  
  const EmergencyAlertScreen({super.key, this.incident});

  @override
  ConsumerState<EmergencyAlertScreen> createState() => _EmergencyAlertScreenState();
}

class _EmergencyAlertScreenState extends ConsumerState<EmergencyAlertScreen>
    with TickerProviderStateMixin {
  late AnimationController _radarController;
  late AnimationController _pulseController;
  int _countdown = 60;
  Timer? _countdownTimer;
  Timer? _refreshTimer;
  
  // Incident data - from navigation or provider
  IncidentData? _currentIncident;
  
  // Track if user has provided snake detection and symptoms
  String? _recognitionResultId;
  bool _hasSymptomsReport = false;
  List<String> _symptomsList = [];

  final List<RescuerMarker> _rescuers = [
    RescuerMarker(top: 0.30, left: 0.20),
    RescuerMarker(top: 0.60, right: 0.25),
    RescuerMarker(top: 0.15, right: 0.15, opacity: 0.7),
  ];

  @override
  void initState() {
    super.initState();
    
    // Get incident from parameter or provider
    _currentIncident = widget.incident ?? ref.read(activeIncidentProvider).incident;
    
    if (_currentIncident != null) {
      debugPrint('🚨 Emergency Alert Screen loaded');
      debugPrint('📍 Incident ID: ${_currentIncident!.id}');
      debugPrint('📍 Location: ${_currentIncident!.locationCoordinates.latitude}, ${_currentIncident!.locationCoordinates.longitude}');
      debugPrint('📍 Status: ${_currentIncident!.status}');
      
      // Load tracking data
      _loadTrackingData();
      
      // Refresh incident data from API
      _refreshIncidentData();
      
      // Set up periodic refresh every 10 seconds
      _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        _refreshIncidentData();
      });
    }
    
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _startCountdown();
  }

  Future<void> _loadTrackingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final incidentId = _currentIncident!.id;
      
      setState(() {
        _recognitionResultId = prefs.getString('recognition_result_$incidentId');
        _hasSymptomsReport = prefs.getBool('has_symptoms_$incidentId') ?? false;
      });
      
      debugPrint('📊 Recognition Result ID: $_recognitionResultId');
      debugPrint('📊 Has Symptoms Report: $_hasSymptomsReport');
    } catch (e) {
      debugPrint('❌ Error loading tracking data: $e');
    }
  }

  Future<void> _refreshIncidentData() async {
    try {
      final repository = ref.read(incidentRepositoryProvider);
      final response = await repository.getIncident(_currentIncident!.id);
      
      if (response.isSuccess && response.data != null) {
        setState(() {
          _currentIncident = response.data;
          _symptomsList = _parseSymptomsReport(response.data!.symptomsReport);
        });
        debugPrint('✅ Incident refreshed. Symptoms count: ${_symptomsList.length}');
      }
    } catch (e) {
      final errorMessage = e.toString();
      debugPrint('❌ Error refreshing incident: $errorMessage');
      
      // Nếu gặp lỗi authentication, không hiển thị lỗi cho user
      // App sẽ tiếp tục hoạt động với data hiện tại
      // Token refresh sẽ được thử lại ở lần request tiếp theo
      if (errorMessage.contains('Authentication') || errorMessage.contains('401')) {
        debugPrint('⚠️ Auth error during refresh - will retry on next cycle');
      }
      
      // Không throw error để app không crash
      // Incident data hiện tại vẫn được giữ nguyên
    }
  }

  List<String> _parseSymptomsReport(String? symptomsReport) {
    if (symptomsReport == null || symptomsReport.isEmpty) {
      return [];
    }
    
    try {
      // symptomsReport is a JSON string like: "[\"symptom1\", \"symptom2\"]"
      final List<dynamic> decoded = jsonDecode(symptomsReport);
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      debugPrint('❌ Error parsing symptoms report: $e');
      return [];
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _radarController.dispose();
    _pulseController.dispose();
    _countdownTimer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// Get current radius from incident data (currentRadiusKm)
  int get _currentRadius {
    return _currentIncident?.currentRadiusKm ?? 5;
  }

  /// Get total rescuers pinged from all sessions
  int get _totalRescuersPinged {
    if (_currentIncident == null || _currentIncident!.sessions.isEmpty) {
      return 0;
    }
    return _currentIncident!.sessions
        .fold(0, (sum, session) => sum + session.rescuersPinged);
  }

  /// Get current session number
  int get _currentSessionNumber {
    return _currentIncident?.currentSessionNumber ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      body: Stack(
        children: [
          // Background Map
          Column(
            children: [
              // Top Navigation Bar
              Container(
                color: Colors.white,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.goNamed('member_home');
                            }
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'Cảnh báo khẩn cấp',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.goNamed('member_home');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Emergency Status Banner
              Container(
                color: const Color(0xFFDC3545),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Pulsing dot
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ScaleTransition(
                            scale: Tween<double>(begin: 1.0, end: 2.0).animate(
                              CurvedAnimation(
                                parent: _pulseController,
                                curve: Curves.easeOut,
                              ),
                            ),
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Đang tìm đội cứu hộ gần bạn...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text(
                                'GPS đã kích hoạt',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 14,
                              ),
                              if (_currentIncident != null) ...[
                                const SizedBox(width: 8),
                                const Text(
                                  '•',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${_currentIncident!.locationCoordinates.latitude.toStringAsFixed(4)}, ${_currentIncident!.locationCoordinates.longitude.toStringAsFixed(4)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Map Section
              Expanded(
            child: Stack(
              children: [
                // Map Background
                Container(
                  color: const Color(0xFFE8F5E9),
                  child: Center(
                    child: Icon(
                      Icons.map,
                      size: 80,
                      color: const Color(0xFF228B22).withOpacity(0.2),
                    ),
                  ),
                ),

                // Radar circles
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF228B22).withOpacity(0.2),
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF228B22).withOpacity(0.3),
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Radar sweep
                      RotationTransition(
                        turns: _radarController,
                        child: CustomPaint(
                          size: const Size(250, 250),
                          painter: RadarSweepPainter(),
                        ),
                      ),
                      // User location
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ScaleTransition(
                            scale: Tween<double>(begin: 1.0, end: 1.5).animate(
                              CurvedAnimation(
                                parent: _pulseController,
                                curve: Curves.easeOut,
                              ),
                            ),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3).withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Rescuer pins
                ..._rescuers.map((rescuer) => _buildRescuerPin(rescuer)),

                // Map overlay info
                Positioned(
                  bottom: 70,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RotationTransition(
                            turns: _radarController,
                            child: const Icon(
                              Icons.sync,
                              color: Color(0xFF228B22),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _totalRescuersPinged > 0
                                ? 'Đã ping: $_totalRescuersPinged đội | Bán kính: ${_currentRadius}km'
                                : 'Đang quét bán kính ${_currentRadius}km...',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Recenter button
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
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
                    child: IconButton(
                      icon: const Icon(Icons.my_location, size: 20),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
          ),
            ],
          ),

          // Bottom Sheet - Draggable
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.35,
            maxChildSize: 0.9,
            snap: true,
            snapSizes: const [0.35, 0.55, 0.9],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 24,
                      offset: const Offset(0, -8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Scrollable content with drag handle
                    ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.only(
                        top: 40,
                        left: 20,
                        right: 20,
                        bottom: 320, // Increased to prevent content being hidden by footer
                      ),
                      physics: const ClampingScrollPhysics(),
                      children: [
                        // Quick stats
                        _buildQuickStats(),
                        const SizedBox(height: 24),

                        // Rescuer status card
                        _buildRescuerStatusCard(),
                        const SizedBox(height: 24),

                        // Safety warnings
                        _buildSafetyWarnings(),
                        const SizedBox(height: 16),

                        // Symptoms report (if available)
                        if (_symptomsList.isNotEmpty) ...[
                          _buildSymptomsReportCard(),
                          const SizedBox(height: 16),
                        ],

                        // Success actions
                        _buildSuccessActions(),
                      ],
                    ),

                    // Drag handle at top
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Container(
                            width: 48,
                            height: 5,
                            decoration: BoxDecoration(
                              color: const Color(0xFFBDBDBD),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Sticky footer at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildStickyFooter(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRescuerPin(RescuerMarker rescuer) {
    return Positioned(
      top: rescuer.top != null
          ? MediaQuery.of(context).size.height * 0.4 * rescuer.top!
          : null,
      bottom: rescuer.bottom != null
          ? MediaQuery.of(context).size.height * 0.4 * rescuer.bottom!
          : null,
      left: rescuer.left != null
          ? MediaQuery.of(context).size.width * rescuer.left!
          : null,
      right: rescuer.right != null
          ? MediaQuery.of(context).size.width * rescuer.right!
          : null,
      child: Opacity(
        opacity: rescuer.opacity,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFFF9800),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.medical_services,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final rescuersCount = _totalRescuersPinged;
    final radiusKm = _currentRadius;
    
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      child: Row(
        children: [
          Text(
            rescuersCount > 0 ? '$rescuersCount đội đã ping' : 'Đang tìm đội cứu hộ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 2,
            backgroundColor: Color(0xFFBDBDBD),
          ),
          const SizedBox(width: 12),
          const Text(
            'Bán kính: ',
            style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
          Text(
            '${radiusKm}km',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF228B22),
            ),
          ),
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 2,
            backgroundColor: Color(0xFFBDBDBD),
          ),
          const SizedBox(width: 12),
          Text(
            'Vòng $_currentSessionNumber',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF9800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRescuerStatusCard() {
    final rescuersCount = _totalRescuersPinged;
    final hasAssignedRescuer = _currentIncident?.assignedRescuerId != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TRẠNG THÁI KẾT NỐI',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF888888),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Progress bar
              Container(
                height: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(
                  value: _countdown / 60,
                  backgroundColor: const Color(0xFFE0E0E0),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFFC107),
                  ),
                ),
              ),

              // Status info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Stack(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF8E1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.radar,
                          color: Color(0xFFFFC107),
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasAssignedRescuer 
                              ? 'Đã tìm thấy đội cứu hộ'
                              : 'Đang tìm đội cứu hộ',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          rescuersCount > 0
                              ? 'Đã gửi tín hiệu đến $rescuersCount đội trong bán kính ${_currentRadius}km'
                              : 'Đang quét bán kính ${_currentRadius}km...',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFFFFECB3),
                                ),
                              ),
                              child: Text(
                                hasAssignedRescuer 
                                    ? 'Đang kết nối...'
                                    : 'Đang chờ phản hồi...',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFE65100),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '00:${_countdown.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF9800),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            rescuersCount > 0
                ? 'Vòng ping $_currentSessionNumber | Bán kính ${_currentRadius}km'
                : 'Hệ thống đang tìm kiếm đội cứu hộ gần bạn',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF999999),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyWarnings() {
    final warnings = [
      {'icon': Icons.content_cut, 'text': 'Cắt\nvết thương'},
      {'icon': Icons.water_drop, 'text': 'Hút\nnọc độc'},
      {'icon': Icons.healing, 'text': 'Đắp\nbăng garo'},
      {'icon': Icons.local_bar, 'text': 'Uống\nrượu bia'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFECB3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning, color: Color(0xFFE65100), size: 20),
              SizedBox(width: 8),
              Text(
                'TUYỆT ĐỐI KHÔNG:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE65100),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: warnings.map((warning) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFECB3)),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              warning['icon'] as IconData,
                              color: const Color(0xFFDC3545),
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              warning['text'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: Text(
                          '✕',
                          style: TextStyle(
                            color: Color(0xFFDC3545),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessActions() {
    final actions = [
      {
        'number': '1',
        'title': 'Giữ bình tĩnh',
        'description': ' và hạn chế vận động tối đa.',
      },
      {
        'number': '2',
        'title': 'Cởi bỏ trang sức',
        'description': ', đồng hồ ở vùng bị cắn.',
      },
      {
        'number': '3',
        'title': 'Giữ vết cắn',
        'description': ' ở vị trí thấp hơn tim.',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified, color: Color(0xFF228B22), size: 20),
              SizedBox(width: 8),
              Text(
                'LÀM NGAY (TRONG LÚC CHỜ):',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF228B22),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...actions.map((action) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFC8E6C9),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        action['number']!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF228B22),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF333333),
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(
                            text: action['title'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: action['description']),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSymptomsReportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment, color: Color(0xFFE65100), size: 20),
              SizedBox(width: 8),
              Text(
                'TRIỆU CHỨNG ĐÃ CUNG CẤP:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE65100),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._symptomsList.asMap().entries.map((entry) {
            final index = entry.key;
            final symptom = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE65100),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      symptom,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF333333),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStickyFooter() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE0E0E0)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Waiting button (disabled)
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RotationTransition(
                        turns: _radarController,
                        child: const Icon(
                          Icons.refresh,
                          color: Color(0xFF999999),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Đang chờ phản hồi...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Dynamic action buttons based on state
              ..._buildActionButtons(),
              
              const SizedBox(height: 8),

              // Cancel button
              TextButton(
                onPressed: () {
                  _showCancelDialog();
                },
                child: const Text(
                  'Hủy yêu cầu',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF888888),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy yêu cầu cứu hộ?'),
        content: const Text(
          'Bạn có chắc muốn hủy yêu cầu cứu hộ khẩn cấp này không?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Tiếp tục chờ'),
          ),
          TextButton(
            onPressed: () async {
              // Clear active incident from provider and local storage
              await ref.read(activeIncidentProvider.notifier).clearActiveIncident();
              
              if (mounted) {
                context.pop(); // Close dialog
                context.goNamed('member_home'); // Go to member_home
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFDC3545),
            ),
            child: const Text('Hủy yêu cầu'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons() {
    final hasRecognition = _recognitionResultId != null;
    final hasSymptoms = _hasSymptomsReport;

    if (!hasRecognition) {
      // Case 1: Chưa có ảnh rắn - Hiển thị "Cung cấp ảnh rắn"
      return [
        OutlinedButton.icon(
          onPressed: () {
            context.pushNamed(
              'snake_identification',
              extra: {'incident': _currentIncident},
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF228B22),
            side: const BorderSide(color: Color(0xFF228B22), width: 2),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 48),
          ),
          icon: const Icon(Icons.camera_alt),
          label: const Text(
            'Cung cấp ảnh rắn để xem hướng dẫn sơ cứu chi tiết',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ),
      ];
    } else if (hasRecognition && !hasSymptoms) {
      // Case 2: Đã có ảnh rắn, chưa có triệu chứng - Hiển thị 2 nút
      return [
        ElevatedButton.icon(
          onPressed: () {
            context.pushNamed(
              'symptom_report',
              extra: {
                'incidentId': _currentIncident!.id,
                'recognitionResultId': _recognitionResultId,
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF228B22),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 48),
          ),
          icon: const Icon(Icons.assignment),
          label: const Text(
            'Cung cấp triệu chứng',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            context.pushNamed(
              'first_aid_steps',
              extra: {
                'incident': _currentIncident,
                'recognitionResultId': _recognitionResultId,
              },
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF228B22),
            side: const BorderSide(color: Color(0xFF228B22), width: 2),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 48),
          ),
          icon: const Icon(Icons.healing),
          label: const Text(
            'Xem lại hướng dẫn sơ cứu',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ];
    } else {
      // Case 3: Đã có cả ảnh và triệu chứng - Hiển thị 2 nút xem lại
      return [
        ElevatedButton.icon(
          onPressed: () {
            context.pushNamed(
              'first_aid_steps',
              extra: {
                'incident': _currentIncident,
                'recognitionResultId': _recognitionResultId,
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF228B22),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 48),
          ),
          icon: const Icon(Icons.healing),
          label: const Text(
            'Xem lại hướng dẫn sơ cứu',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            context.pushNamed(
              'symptom_report',
              extra: {
                'incidentId': _currentIncident!.id,
                'recognitionResultId': _recognitionResultId,
              },
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF228B22),
            side: const BorderSide(color: Color(0xFF228B22), width: 2),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 48),
          ),
          icon: const Icon(Icons.assignment),
          label: const Text(
            'Cập nhật triệu chứng',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ];
    }
  }
}

// Radar sweep painter
class RadarSweepPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xFF228B22).withOpacity(0.0),
          const Color(0xFF228B22).withOpacity(0.1),
          const Color(0xFF228B22).withOpacity(0.4),
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2,
      ));

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Rescuer marker model
class RescuerMarker {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double opacity;

  RescuerMarker({
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.opacity = 1.0,
  });
}
