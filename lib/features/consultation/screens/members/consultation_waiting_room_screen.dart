import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Phòng chờ trước/sau buổi tư vấn video
class ConsultationWaitingRoomScreen extends StatefulWidget {
  final String consultationId;
  final String expertName;
  final String expertSpecialty;
  /// true khi quay lại từ cuộc gọi đã kết thúc → hiện nút "Xác nhận hoàn thành"
  final bool showCompleteButton;
  final int durationSeconds;
  /// Trạng thái mic được đồng bộ từ video call (hoặc mặc định bật)
  final bool initialMicOn;
  /// Trạng thái camera được đồng bộ từ video call (hoặc mặc định bật)
  final bool initialCameraOn;

  const ConsultationWaitingRoomScreen({
    super.key,
    required this.consultationId,
    required this.expertName,
    required this.expertSpecialty,
    this.showCompleteButton = false,
    this.durationSeconds = 0,
    this.initialMicOn = true,
    this.initialCameraOn = true,
  });

  @override
  State<ConsultationWaitingRoomScreen> createState() =>
      _ConsultationWaitingRoomScreenState();
}

class _ConsultationWaitingRoomScreenState
    extends State<ConsultationWaitingRoomScreen>
    with TickerProviderStateMixin {
  static const Color _green = Color(0xFF228B22);
  static const Color _joinButtonColor = Color(0xFF22628C);
  static const Color _bg = Color(0xFFF7F6F8);

  bool _isMicOn = true;
  bool _isCameraOn = true;

  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  // Three dot animation controllers (staggered)
  late List<AnimationController> _dotControllers;
  late List<Animation<double>> _dotAnims;

  @override
  void initState() {
    super.initState();
    // Đồng bộ trạng thái mic/camera từ video call (hoặc giá trị mặc định)
    _isMicOn = widget.initialMicOn;
    _isCameraOn = widget.initialCameraOn;

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
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
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    for (final c in _dotControllers) {
      c.dispose();
    }
    super.dispose();
  }

  String get _formattedNow {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _enterRoom() {
    context.push(
      '/video-consultation/${widget.consultationId}',
      extra: {
        'expertName': widget.expertName,
        'expertSpecialty': widget.expertSpecialty,
        // Đồng bộ trạng thái mic/camera sang màn hình video call
        'initialMicOn': _isMicOn,
        'initialCameraOn': _isCameraOn,
      },
    );
  }

  void _confirmComplete() {
    context.go(
      '/consultation-complete',
      extra: {
        'expertName': widget.expertName,
        'expertSpecialty': widget.expertSpecialty,
        'durationSeconds': widget.durationSeconds,
        'consultationId': widget.consultationId,
      },
    );
  }

  void _cancelCall() {
    context.go('/consultation-home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildVideoPreview(context),
                      const SizedBox(height: 8),
                      _buildInfoCard(),
                      const SizedBox(height: 24),
                      _buildButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Phiên tư vấn',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _green,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Video preview ──────────────────────────────────────────────────────────

  Widget _buildVideoPreview(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: const Color(0xFF111827),
            child: Stack(
              children: [
                // Dark gradient background
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF0d1117),
                        Color(0xFF1a1a2e),
                        Color(0xFF0d1117),
                      ],
                    ),
                  ),
                ),

                // Centre person placeholder
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.15), width: 2),
                    ),
                    child: const Icon(Icons.person,
                        size: 40, color: Colors.white38),
                  ),
                ),

                // Bottom gradient
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 120,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0x99000000), Colors.transparent],
                      ),
                    ),
                  ),
                ),

                // Controls strip
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Flip camera
                          GestureDetector(
                            onTap: () {},
                            child: const Icon(
                              Icons.flip_camera_ios_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 24),

                          // Mic (active = green circle)
                          GestureDetector(
                            onTap: () =>
                                setState(() => _isMicOn = !_isMicOn),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _isMicOn
                                    ? _green
                                    : Colors.red.withOpacity(0.75),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  if (_isMicOn)
                                    BoxShadow(
                                      color: _green.withOpacity(0.4),
                                      blurRadius: 12,
                                    ),
                                ],
                              ),
                              child: Icon(
                                _isMicOn ? Icons.mic : Icons.mic_off,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),

                          // Camera toggle
                          GestureDetector(
                            onTap: () =>
                                setState(() => _isCameraOn = !_isCameraOn),
                            child: Icon(
                              _isCameraOn
                                  ? Icons.videocam
                                  : Icons.videocam_off,
                              color: _isCameraOn
                                  ? Colors.white
                                  : Colors.red.shade300,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Info card ──────────────────────────────────────────────────────────────

  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expert row
            Row(
              children: [
                // Avatar + status dot
                Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _green.withOpacity(0.1),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 4),
                        ],
                      ),
                      child:
                          const Icon(Icons.person, size: 28, color: _green),
                    ),
                    Positioned(
                      bottom: 1,
                      right: 1,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Name + time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.expertName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF160D1B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _green.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.chat_bubble_outline,
                                size: 16, color: _green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.schedule_outlined,
                              size: 16, color: Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                          const Text(
                            'Lịch: 14:00 - 14:30',
                            style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Status checks
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildStatusRow('Camera hoạt động'),
                  const SizedBox(height: 8),
                  _buildStatusRow('Micro hoạt động'),
                  const SizedBox(height: 8),
                  _buildStatusRow('Kết nối ổn định'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle, size: 20, color: Color(0xFF22C55E)),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF160D1B)),
        ),
      ],
    );
  }

  // ── Buttons ────────────────────────────────────────────────────────────────

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Vào phòng
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _enterRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: _joinButtonColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Vào phòng',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Xác nhận hoàn thành — chỉ hiện sau khi kết thúc call
          if (widget.showCompleteButton) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _confirmComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Xác nhận hoàn thành',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Huỷ cuộc gọi
          GestureDetector(
            onTap: _cancelCall,
            child: const Text(
              'Hủy cuộc gọi',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
