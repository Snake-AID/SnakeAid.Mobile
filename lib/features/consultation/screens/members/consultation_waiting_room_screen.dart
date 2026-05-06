import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repository/consultation_repository.dart';

/// Phòng chờ trước/sau buổi tư vấn video
class ConsultationWaitingRoomScreen extends ConsumerStatefulWidget {
  final String consultationId;
  final String expertName;
  final String expertSpecialty;

  /// Enable report-expert-absent action for scheduled consultations.
  final bool canReportExpertAbsent;

  /// Scheduled start time (epoch ms) used for StartTime business rule.
  final int? scheduledStartAtMs;

  /// Scheduled duration used to render the schedule time range.
  final int scheduledDurationSeconds;

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
    this.canReportExpertAbsent = false,
    this.scheduledStartAtMs,
    this.scheduledDurationSeconds = 1800,
    this.showCompleteButton = false,
    this.durationSeconds = 0,
    this.initialMicOn = true,
    this.initialCameraOn = true,
  });

  @override
  ConsumerState<ConsultationWaitingRoomScreen> createState() =>
      _ConsultationWaitingRoomScreenState();
}

class _ConsultationWaitingRoomScreenState
    extends ConsumerState<ConsultationWaitingRoomScreen>
    with TickerProviderStateMixin {
  static const Color _green = Color(0xFF228B22);
  static const Color _joinButtonColor = Color(0xFF22628C);
  static const Color _bg = Color(0xFFF7F6F8);

  bool _isMicOn = true;
  bool _isCameraOn = true;
  bool _isJoining = false;
  bool _isReportingAbsent = false;

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
        .map(
          (c) => Tween<double>(
            begin: 0,
            end: -7,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)),
        )
        .toList();

    _dotControllers[0].repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _dotControllers[1].repeat(reverse: true);
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _dotControllers[2].repeat(reverse: true);
    });
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
        'expertName': widget.expertName,
        'expertSpecialty': widget.expertSpecialty,
        'canReportExpertAbsent': widget.canReportExpertAbsent,
        'initialMicOn': _isMicOn,
        'initialCameraOn': _isCameraOn,
        'scheduledStartAtMs': widget.scheduledStartAtMs,
        'scheduledDurationSeconds': widget.scheduledDurationSeconds,
        'livekitToken': livekitResult.token,
        'wsUrl': livekitResult.wsUrl,
      },
    );
  }

  Future<void> _endConsultation() async {
    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Kết Thúc Tư Vấn?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF160D1B),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Bạn có chắc chắn muốn kết thúc buổi tư vấn này không? Sau khi kết thúc, bạn sẽ không thể quay lại cuộc gọi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Kết Thúc',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    // Call API to end consultation
    final repo = ref.read(consultationRepositoryProvider);
    final result = await repo.endConsultation(widget.consultationId);

    if (!mounted) return;

    if (result) {
      // Navigate to review/completion screen
      context.go(
        '/consultation-complete',
        extra: {
          'expertName': widget.expertName,
          'expertSpecialty': widget.expertSpecialty,
          'durationSeconds': widget.durationSeconds,
          'consultationId': widget.consultationId,
        },
      );
    } else {
      // Show error if API call failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể kết thúc buổi tư vấn, vui lòng thử lại'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _cancelCall() {
    context.go('/consultation-home');
  }

  bool get _canSubmitAbsentByTime {
    final startMs = widget.scheduledStartAtMs;
    if (startMs == null) return true;
    final start = DateTime.fromMillisecondsSinceEpoch(startMs);
    return DateTime.now().isAfter(start) ||
        DateTime.now().isAtSameMomentAs(start);
  }

  Future<void> _showReportExpertAbsentDialog() async {
    if (_isReportingAbsent) return;

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return const _ReportExpertAbsentModalContent();
      },
    );

    // Only process result after sheet is completely closed and controller disposed
    final report = (result ?? '').trim();
    if (report.isEmpty || !mounted) return;

    setState(() => _isReportingAbsent = true);
    try {
      final repo = ref.read(consultationRepositoryProvider);
      await repo.reportExpertAbsent(
        consultationId: widget.consultationId,
        customerReport: report,
      );

      try {
        await repo.endConsultation(widget.consultationId);
      } catch (_) {
        // Ignore end-call failures for expert-absent flow.
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Báo cáo đã được gửi đến admin. Sau khi được phê duyệt, tiền sẽ được hoàn về ví của bạn.',
          ),
          backgroundColor: Color(0xFF228B22),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/consultation-home', extra: {'initialTab': 1});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isReportingAbsent = false);
      }
    }
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
                        color: Colors.white.withOpacity(0.15),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white38,
                    ),
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
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
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
                            onTap: () => setState(() => _isMicOn = !_isMicOn),
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
                              _isCameraOn ? Icons.videocam : Icons.videocam_off,
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
              offset: const Offset(0, 2),
            ),
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
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person, size: 28, color: _green),
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
                          border: Border.all(color: Colors.white, width: 2),
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
                            child: const Icon(
                              Icons.chat_bubble_outline,
                              size: 16,
                              color: _green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_outlined,
                            size: 16,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Lịch: ${_formatTimeRange(widget.scheduledStartAtMs, widget.scheduledDurationSeconds)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
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
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF160D1B),
            ),
          ),
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
              onPressed: _isJoining ? null : _enterRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: _joinButtonColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isJoining
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Vào phòng',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          // Kết thúc buổi tư vấn — chỉ hiện sau khi kết thúc call
          if (widget.showCompleteButton) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _endConsultation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 34, 139, 34),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Hoàn Thành Tư Vấn',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],

          // Chỉ hiện report sau khi member đã vào call và quay lại sảnh chờ.
          if (widget.canReportExpertAbsent && widget.showCompleteButton) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: _isReportingAbsent
                    ? null
                    : _showReportExpertAbsentDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6B7280),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isReportingAbsent
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.report_problem_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Báo chuyên gia vắng mặt',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Huỷ cuộc gọi
          GestureDetector(
            onTap: _cancelCall,
            child: const Text(
              'Rời phòng chờ',
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

  String _formatTimeRange(int? startMs, int durationSeconds) {
    if (startMs == null || startMs == 0) return 'Đang cập nhật...';

    final start = DateTime.fromMillisecondsSinceEpoch(startMs);
    // Use durationSeconds if provided (> 0), otherwise fallback to 30 mins (1800s)
    final duration = durationSeconds > 0 ? durationSeconds : 1800;
    final end = start.add(Duration(seconds: duration));

    final h1 = start.hour.toString().padLeft(2, '0');
    final m1 = start.minute.toString().padLeft(2, '0');
    final h2 = end.hour.toString().padLeft(2, '0');
    final m2 = end.minute.toString().padLeft(2, '0');

    return '$h1:$m1 - $h2:$m2';
  }
}

/// Separate widget to avoid StatefulBuilder lifecycle issues
class _ReportExpertAbsentModalContent extends StatefulWidget {
  const _ReportExpertAbsentModalContent();

  @override
  State<_ReportExpertAbsentModalContent> createState() =>
      _ReportExpertAbsentModalContentState();
}

class _ReportExpertAbsentModalContentState
    extends State<_ReportExpertAbsentModalContent> {
  late TextEditingController _controller;
  late bool _isFilled;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _isFilled = _controller.text.trim().isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final newFilled = _controller.text.trim().isNotEmpty;
    if (_isFilled != newFilled) {
      setState(() => _isFilled = newFilled);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.86,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF228B22), Color(0xFF1a6b1a)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.report_problem_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Báo cáo chuyên gia vắng mặt',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Gửi thông tin để hệ thống xác minh và xử lý nhanh hơn.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Color(0xFF228B22),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Mô tả ngắn gọn tình huống, ví dụ: đã đến giờ hẹn nhưng chuyên gia chưa vào phòng tư vấn.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF374151),
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nội dung báo cáo',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _controller,
                      minLines: 5,
                      maxLines: 8,
                      maxLength: 2000,
                      decoration: InputDecoration(
                        hintText:
                            'Ví dụ: Đã đến giờ hẹn nhưng chuyên gia chưa vào phòng tư vấn.',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        contentPadding: const EdgeInsets.fromLTRB(
                          16,
                          16,
                          16,
                          16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF228B22),
                            width: 1.6,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Thông tin sẽ được gửi đến admin để kiểm tra và xử lý.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isFilled
                          ? () =>
                                Navigator.pop(context, _controller.text.trim())
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.white70,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Gửi báo cáo',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
