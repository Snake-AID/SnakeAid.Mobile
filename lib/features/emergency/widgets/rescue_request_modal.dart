import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import '../models/rescue_request.dart';
import '../models/sos_incident_response.dart';
import '../repository/incident_repository.dart';
import '../providers/rescuer_emergency_provider.dart';

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
  IncidentData? _incident;
  String? _errorMessage;

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
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _audioPlayer.dispose();
    _pulseController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  Future<void> _fetchIncidentDetails() async {
    try {
      setState(() {
        _isLoadingIncident = true;
        _errorMessage = null;
      });

      final repository = ref.read(incidentRepositoryProvider);
      final response = await repository.getIncident(widget.request.incidentId);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _incident = response.data;
          _isLoadingIncident = false;
        });
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
      // Play system sound as fallback (add custom sound later)
      // await _audioPlayer.play(AssetSource('sounds/emergency_alarm.mp3'));
    } catch (e) {
      debugPrint('Failed to play alarm: $e');
    }
  }

  void _stopAlarmSound() {
    _audioPlayer.stop();
  }

  Future<void> _vibrate() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
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
        widget.onDismiss();
        // TODO: Navigate to mission screen
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            icon: Icons.radio_button_checked,
            title: 'Bán kính tìm kiếm',
            value: widget.request.formattedRadius,
            color: const Color(0xFF2196F3),
          ),
          const SizedBox(height: 12),

          _buildInfoCard(
            icon: Icons.place,
            title: 'Địa điểm',
            value:
                '${_incident!.locationCoordinates.latitude.toStringAsFixed(4)}, ${_incident!.locationCoordinates.longitude.toStringAsFixed(4)}',
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 12),

          _buildInfoCard(
            icon: Icons.medical_services,
            title: 'Mức độ nghiêm trọng',
            value: _getSeverityText(_incident!.severityLevel),
            color: _getSeverityColor(_incident!.severityLevel),
          ),
          const SizedBox(height: 12),

          if (_incident!.symptomsReport != null &&
              _incident!.symptomsReport!.isNotEmpty) ...[
            const Text(
              'Triệu chứng:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _incident!.symptomsReport!,
                style: const TextStyle(fontSize: 14, color: Color(0xFFE65100)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
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
