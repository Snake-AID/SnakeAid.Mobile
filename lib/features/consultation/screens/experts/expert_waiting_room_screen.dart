import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repository/consultation_repository.dart';
import '../../../../core/services/consultation_chat_signalr_service.dart';

/// Phòng chờ tư vấn video dành cho chuyên gia
/// Hiển thị trước/sau buổi tư vấn, chờ bệnh nhân tham gia
class ExpertWaitingRoomScreen extends ConsumerStatefulWidget {
  final String consultationId;
  final String patientName;
  final String consultationType;

  /// true khi quay lại từ cuộc gọi đã kết thúc → hiện nút "Xác nhận hoàn thành"
  final bool showCompleteButton;
  final int durationSeconds;
  final int feeCost;

  /// Trạng thái mic/camera được đồng bộ từ video call
  final bool initialMicOn;
  final bool initialCameraOn;

  const ExpertWaitingRoomScreen({
    super.key,
    required this.consultationId,
    required this.patientName,
    required this.consultationType,
    this.showCompleteButton = false,
    this.durationSeconds = 0,
    this.feeCost = 0,
    this.initialMicOn = true,
    this.initialCameraOn = true,
  });

  @override
  ConsumerState<ExpertWaitingRoomScreen> createState() =>
      _ExpertWaitingRoomScreenState();
}

class _ExpertWaitingRoomScreenState extends ConsumerState<ExpertWaitingRoomScreen>
    with TickerProviderStateMixin {
  static const Color _purple = Color(0xFF6C47C2);
  static const Color _enterColor = Color(0xFF22628C);
  static const Color _bg = Color(0xFFF7F6F8);

  bool _isMicOn = true;
  bool _isCameraOn = true;
  bool _isFrontCamera = true;
  bool _isJoining = false;

  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  // Staggered dot animation
  late List<AnimationController> _dotControllers;
  late List<Animation<double>> _dotAnims;

  // SignalR for "end consultation" listener
  ConsultationChatSignalRService? _chatService;
  StreamSubscription<ConsultationCallEndedEvent>? _consultationCallEndedSub;
  bool _isHandlingEndEvent = false;

  @override
  void initState() {
    super.initState();
    _isMicOn = widget.initialMicOn;
    _isCameraOn = widget.initialCameraOn;

    _clockTimer = Timer.periodic(
        const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });

    _dotControllers = List.generate(
      3,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
    _dotAnims = _dotControllers
        .map((c) => Tween<double>(begin: 0, end: -7).animate(
              CurvedAnimation(parent: c, curve: Curves.easeInOut),
            ))
        .toList();

    _dotControllers[0].repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 200),
        () { if (mounted) _dotControllers[1].repeat(reverse: true); });
    Future.delayed(const Duration(milliseconds: 400),
        () { if (mounted) _dotControllers[2].repeat(reverse: true); });

    // Initialize SignalR listener for end-consultation events
    _initSignalR();
  }

  void _initSignalR() async {
    try {
      final baseUrl = ref.read(consultationRepositoryProvider).httpService.baseUrl;
      _chatService = ConsultationChatSignalRService(baseUrl: baseUrl);

      _consultationCallEndedSub = _chatService!.consultationCallEndedStream.listen((event) {
        if (event.consultationId == widget.consultationId) {
          _handleConsultationEnded(event.reason);
        }
      });

      await _chatService!.connect(widget.consultationId);
      debugPrint('🔔 Expert Waiting Room connected to SignalR');
    } catch (e) {
      debugPrint('⚠️ Expert Waiting Room SignalR connection failed: $e');
    }
  }

  void _handleConsultationEnded(String reason) {
    if (!mounted || _isHandlingEndEvent) return;
    _isHandlingEndEvent = true;

    debugPrint('🏁 Consultation ended detected in waiting room: $reason');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          reason.toLowerCase() == 'timeout'
              ? 'Phiên tư vấn đã hết thời gian.'
              : 'Phiên tư vấn đã kết thúc.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Auto-navigate to completion screen
    context.go(
      '/expert-consultation-complete',
      extra: {
        'consultationId': widget.consultationId,
        'patientName': widget.patientName,
        'durationSeconds': 0, // In waiting room, duration spent in call is 0
        'feeCost': widget.feeCost,
        'expiryReason': reason,
      },
    );
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    for (final c in _dotControllers) c.dispose();
    _consultationCallEndedSub?.cancel();
    _chatService?.dispose();
    super.dispose();
  }

  String get _formattedNow {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _enterRoom() async {
    if (_isJoining) return;
    setState(() => _isJoining = true);

    ({String token, String wsUrl})? livekitResult;
    try {
      final repo = ref.read(consultationRepositoryProvider);
      livekitResult = await repo.getLivekitToken(widget.consultationId);
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _isJoining = false);
      final msg = e.toString().contains('403')
          ? 'Bạn không phải thành viên của phòng tư vấn này'
          : e.toString().contains('404')
              ? 'Không tìm thấy buổi tư vấn'
              : 'Không thể kết nối phòng, vui lòng thử lại';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isJoining = false);
    context.push(
      '/video-consultation/${widget.consultationId}',
      extra: {
        'expertName': widget.patientName,
        'expertSpecialty': widget.consultationType,
        'isExpertMode': true,
        'initialMicOn': _isMicOn,
        'initialCameraOn': _isCameraOn,
        'afterCallRoute': '/expert-video-waiting/${widget.consultationId}',
        'livekitToken': livekitResult.token,
        'wsUrl': livekitResult.wsUrl,
      },
    );
  }

  void _cancelCall() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Rời phòng chờ?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content:
            const Text('Bạn có chắc muốn rời khỏi phòng chờ không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Ở lại',
                style: TextStyle(color: Color(0xFF999999))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/expert-home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC3545),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Rời khỏi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _purple,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: _cancelCall,
        ),
        title: const Text(
          'Phòng Chờ Tư Vấn',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                _formattedNow,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Camera preview
            _buildCameraPreview(),
            const SizedBox(height: 20),

            // Patient info card
            _buildPatientCard(),
            const SizedBox(height: 24),

            // Action buttons
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Camera or off state
            Center(
              child: _isCameraOn
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _purple.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.videocam,
                              color: Colors.white70, size: 40),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Camera đang hoạt động',
                          style: TextStyle(
                              color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.videocam_off,
                              color: Colors.white38, size: 36),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Camera đã tắt',
                          style: TextStyle(
                              color: Colors.white38, fontSize: 13),
                        ),
                      ],
                    ),
            ),

            // Waiting overlay (only when not showCompleteButton)
            if (!widget.showCompleteButton)
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ..._dotAnims.map(
                          (anim) => AnimatedBuilder(
                            animation: anim,
                            builder: (_, __) => Transform.translate(
                              offset: Offset(0, anim.value),
                              child: Container(
                                width: 7,
                                height: 7,
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                decoration: const BoxDecoration(
                                  color: Colors.white70,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Flip camera button
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () =>
                    setState(() => _isFrontCamera = !_isFrontCamera),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _isFrontCamera
                        ? Icons.camera_front
                        : Icons.camera_rear,
                    color: Colors.white70,
                    size: 22,
                  ),
                ),
              ),
            ),

            // Mic / Camera controls
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    icon: _isMicOn ? Icons.mic : Icons.mic_off,
                    label: _isMicOn ? 'Mic' : 'Tắt mic',
                    active: _isMicOn,
                    onTap: () => setState(() => _isMicOn = !_isMicOn),
                  ),
                  const SizedBox(width: 20),
                  _buildControlButton(
                    icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                    label: _isCameraOn ? 'Camera' : 'Tắt cam',
                    active: _isCameraOn,
                    onTap: () =>
                        setState(() => _isCameraOn = !_isCameraOn),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFF28A745).withOpacity(0.85)
                  : const Color(0xFFDC3545).withOpacity(0.85),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _purple.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _purple.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                  color: _purple.withOpacity(0.3), width: 2),
            ),
            child:
                const Icon(Icons.person, color: _purple, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Khách hàng',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF999999),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.patientName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.consultationType == 'Khẩn Cấp'
                            ? const Color(0xFFDC3545).withOpacity(0.1)
                            : _purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.consultationType,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: widget.consultationType == 'Khẩn Cấp'
                              ? const Color(0xFFDC3545)
                              : _purple,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Chat icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _purple.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.chat_bubble_outline,
                  color: _purple, size: 18),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Chat - Đang phát triển')),
                );
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Enter room button
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isJoining ? null : _enterRoom,
            icon: _isJoining
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.video_call, size: 22),
            label: Text(
              _isJoining ? 'Đang kết nối...' : 'Bắt Đầu Tư Vấn',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _enterColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Cancel button
        SizedBox(
          height: 46,
          child: OutlinedButton(
            onPressed: _cancelCall,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                  color: const Color(0xFFDC3545).withOpacity(0.6),
                  width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              foregroundColor: const Color(0xFFDC3545),
            ),
            child: const Text(
              'Rời Phòng Chờ',
              style:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
