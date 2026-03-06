import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../repository/consultation_repository.dart';

/// Video consultation screen powered by LiveKit.
/// Receives [livekitToken] and [wsUrl] from WaitingRoom (fetched via API) and connects
/// to the LiveKit server URL provided by the token API response.
class VideoConsultationScreen extends ConsumerStatefulWidget {
  final String consultationId;
  final String expertName;
  final String expertSpecialty;
  /// Mic state chosen in the waiting room (default on)
  final bool initialMicOn;
  /// Camera state chosen in the waiting room (default on)
  final bool initialCameraOn;
  /// Route to go to after ending the call (null = use default member waiting room)
  final String? afterCallRoute;
  /// LiveKit JWT token received from backend
  final String livekitToken;
  /// LiveKit server WebSocket URL received from backend (e.g. wss://livekit.example.com)
  final String wsUrl;

  const VideoConsultationScreen({
    super.key,
    required this.consultationId,
    required this.expertName,
    required this.expertSpecialty,
    this.initialMicOn = true,
    this.initialCameraOn = true,
    this.afterCallRoute,
    this.livekitToken = '',
    this.wsUrl = '',
  });

  @override
  ConsumerState<VideoConsultationScreen> createState() =>
      _VideoConsultationScreenState();
}

class _VideoConsultationScreenState extends ConsumerState<VideoConsultationScreen>
    with TickerProviderStateMixin {
  // ── LiveKit ────────────────────────────────────────────────────────────────
  late Room _room;
  bool _isConnecting = true;
  String? _connectionError;

  // ── Timer ──────────────────────────────────────────────────────────────────
  late Timer _timer;
  int _secondsElapsed = 0;

  // ── Controls ───────────────────────────────────────────────────────────────
  late bool _isMicOn;
  late bool _isCameraOn;
  bool _isFrontCamera = true;

  // ── PiP position ───────────────────────────────────────────────────────────
  double _pipTop = 96;
  double _pipRight = 16;

  // ── Animations ─────────────────────────────────────────────────────────────
  late AnimationController _liveBadgeController;

  // ── Notes ──────────────────────────────────────────────────────────────────
  final TextEditingController _notesController = TextEditingController();

  // ── Computed helpers ───────────────────────────────────────────────────────

  /// Local video track (null when camera off or not yet published)
  VideoTrack? get _localVideoTrack {
    if (!_isCameraOn) return null;
    return _room.localParticipant?.videoTrackPublications
        .where((p) => p.track != null)
        .map((p) => p.track!)
        .whereType<VideoTrack>()
        .firstOrNull;
  }

  /// Remote participant's video track (first remote participant)
  VideoTrack? get _remoteVideoTrack {
    final remote = _room.remoteParticipants.values.firstOrNull;
    return remote?.videoTrackPublications
        .where((p) => p.track != null)
        .map((p) => p.track!)
        .whereType<VideoTrack>()
        .firstOrNull;
  }

  bool get _isAnyoneConnected => _room.remoteParticipants.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _isMicOn = widget.initialMicOn;
    _isCameraOn = widget.initialCameraOn;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _room = Room(
      roomOptions: const RoomOptions(
        adaptiveStream: true,
        dynacast: true,
      ),
    );
    _room.addListener(_onRoomChanged);
    _connectToRoom();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _secondsElapsed++);
    });

    _liveBadgeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  Future<void> _connectToRoom() async {
    final wsUrl = widget.wsUrl.isNotEmpty ? widget.wsUrl : '';
    if (wsUrl.isEmpty || widget.livekitToken.isEmpty) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _connectionError = 'Thiếu wsUrl hoặc token — không thể kết nối phòng';
        });
      }
      return;
    }
    try {
      await _room.connect(wsUrl, widget.livekitToken);
      if (!mounted) return;
      await _room.localParticipant?.setMicrophoneEnabled(_isMicOn);
      await _room.localParticipant?.setCameraEnabled(_isCameraOn);
      if (mounted) setState(() => _isConnecting = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _connectionError = 'Không thể kết nối phòng: $e';
        });
      }
    }
  }

  void _onRoomChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _timer.cancel();
    _liveBadgeController.dispose();
    _notesController.dispose();
    _room.removeListener(_onRoomChanged);
    _room.disconnect();
    _room.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  String get _formattedTime {
    final m = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _endCall() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1022),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Kết Thúc Phiên',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc muốn kết thúc buổi tư vấn?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tiếp Tục',
                style: TextStyle(color: Color(0xFF228B22))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Best-effort: call end API, then navigate regardless of result
              final repo = ref.read(consultationRepositoryProvider);
              await repo.endConsultation(widget.consultationId);

              if (!mounted) return;
              final targetRoute = widget.afterCallRoute ??
                  '/video-waiting/${widget.consultationId}';
              context.go(
                targetRoute,
                extra: {
                  'expertName': widget.expertName,
                  'expertSpecialty': widget.expertSpecialty,
                  'durationSeconds': _secondsElapsed,
                  'showCompleteButton': true,
                  // Đồng bộ trạng thái mic/camera về sảnh chờ
                  'initialMicOn': _isMicOn,
                  'initialCameraOn': _isCameraOn,
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Kết Thúc',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleMic() async {
    _isMicOn = !_isMicOn;
    await _room.localParticipant?.setMicrophoneEnabled(_isMicOn);
    setState(() {});
  }

  Future<void> _toggleCamera() async {
    _isCameraOn = !_isCameraOn;
    await _room.localParticipant?.setCameraEnabled(_isCameraOn);
    setState(() {});
  }

  Future<void> _flipCamera() async {
    if (!_isCameraOn) return;
    _isFrontCamera = !_isFrontCamera;
    await _room.localParticipant?.setCameraEnabled(
      true,
      cameraCaptureOptions: CameraCaptureOptions(
        cameraPosition:
            _isFrontCamera ? CameraPosition.front : CameraPosition.back,
      ),
    );
    setState(() {});
  }

  void _showChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1a1022),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        builder: (ctx, controller) =>
            _ChatPanel(expertName: widget.expertName, scrollController: controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Remote participant's camera (full-screen background) ───────
          _buildRemoteVideo(),

          // ── Gradient overlay (top + bottom) ───────────────────────────
          _buildGradientOverlay(),

          // ── PiP: local camera (draggable) ─────────────────────────────
          _buildDraggablePip(),

          // ── Top bar ───────────────────────────────────────────────────
          _buildTopBar(),

          // ── Connecting / error overlay ────────────────────────────────
          if (_isConnecting) _buildConnectingOverlay(),
          if (_connectionError != null) _buildErrorOverlay(),

          // ── Bottom controls ───────────────────────────────────────────
          _buildBottomControls(),
        ],
      ),
    );
  }

  // ─── Remote video (full-screen background) ────────────────────────────────

  Widget _buildRemoteVideo() {
    final remoteTrack = _remoteVideoTrack;
    if (remoteTrack != null) {
      return Positioned.fill(
        child: VideoTrackRenderer(remoteTrack),
      );
    }
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0d1117), Color(0xFF1a1a2e), Color(0xFF0d1117)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
                border:
                    Border.all(color: Colors.white.withOpacity(0.15), width: 2),
              ),
              child: const Icon(Icons.person, size: 56, color: Colors.white38),
            ),
            const SizedBox(height: 16),
            Text(
              _isAnyoneConnected
                  ? '${widget.expertName} đang tắt camera'
                  : 'Đang chờ đối phương kết nối...',
              style:
                  TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Connecting overlay ───────────────────────────────────────────────────

  Widget _buildConnectingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text(
                'Đang kết nối phòng...',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Error overlay ────────────────────────────────────────────────────────

  Widget _buildErrorOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.signal_wifi_off, color: Colors.red, size: 56),
                const SizedBox(height: 16),
                const Text(
                  'Không thể kết nối',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _connectionError ?? '',
                  style:
                      const TextStyle(color: Colors.white60, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _connectionError = null;
                      _isConnecting = true;
                    });
                    _connectToRoom();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF228B22)),
                  child: const Text('Thử lại',
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/consultation-home'),
                  child: const Text('Quay về',
                      style: TextStyle(color: Colors.white60)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Gradient overlay ─────────────────────────────────────────────────────

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Column(
          children: [
            // top gradient
            Container(
              height: 160,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xCC000000), Colors.transparent],
                ),
              ),
            ),
            const Spacer(),
            // bottom gradient
            Container(
              height: 260,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xE6000000), Colors.transparent],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Top bar ──────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Row(
            children: [
              // Live indicator
              Expanded(
                child: Row(
                  children: [
                    FadeTransition(
                      opacity: _liveBadgeController,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4ade80),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Trực tuyến',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4ade80),
                      ),
                    ),
                  ],
                ),
              ),

              // Timer
              Text(
                _formattedTime,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),

              // Expert name
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        widget.expertName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.person,
                        size: 18, color: Colors.white70),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Draggable PiP (local camera) ─────────────────────────────────────

  Widget _buildDraggablePip() {
    return Positioned(
      top: _pipTop,
      right: _pipRight,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _pipTop += details.delta.dy;
            _pipRight -= details.delta.dx;
            _pipTop = _pipTop.clamp(
                MediaQuery.of(context).padding.top + 8.0,
                MediaQuery.of(context).size.height - 200.0);
            _pipRight = _pipRight.clamp(
                8.0, MediaQuery.of(context).size.width - 128.0);
          });
        },
        child: Container(
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF228B22), width: 2),
            color: Colors.black,
            boxShadow: const [
              BoxShadow(
                  color: Colors.black54, blurRadius: 16, offset: Offset(0, 4))
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Local video or placeholder
              _localVideoTrack != null
                  ? VideoTrackRenderer(_localVideoTrack!)
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1e3a1e), Color(0xFF0d1f0d)],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                              ),
                              child: Icon(
                                _isCameraOn
                                    ? Icons.person
                                    : Icons.videocam_off,
                                size: 28,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text('Bạn',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),

              // Flip camera button
              Positioned(
                bottom: 6,
                right: 6,
                child: GestureDetector(
                  onTap: _flipCamera,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cameraswitch,
                        color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Bottom controls ──────────────────────────────────────────────────────

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 24,
          left: 16,
          right: 16,
          top: 20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildControlButton(
              icon: _isMicOn ? Icons.mic : Icons.mic_off,
              label: _isMicOn ? 'Tắt Mic' : 'Bật Mic',
              active: !_isMicOn,
              onTap: _toggleMic,
            ),
            _buildControlButton(
              icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
              label: 'Camera',
              highlighted: _isCameraOn,
              onTap: _toggleCamera,
            ),

            // Nút Kết Thúc — tâm màn hình, lớn hơn
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _endCall,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.black.withOpacity(0.3), width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.call_end,
                        color: Colors.white, size: 30),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Kết Thúc',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            _buildControlButton(
              icon: Icons.chat_bubble_outline,
              label: 'Chat',
              onTap: _showChat,
            ),
            _buildControlButton(
              icon: Icons.flip_camera_ios_outlined,
              label: 'Lật Cam',
              onTap: _flipCamera,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    bool active = false,
    bool highlighted = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: highlighted
                  ? const Color(0xFF228B22)
                  : active
                      ? Colors.red.withOpacity(0.3)
                      : Colors.white.withOpacity(0.12),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.75),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Chat panel (delegated to _ChatPanel widget) ─────────────────────────
}

// ═══════════════════════════════════════════════════════════════════════════
// Chat panel — StatefulWidget để quản lý messages & image picker
// ═══════════════════════════════════════════════════════════════════════════

class _ChatMessage {
  final String sender;
  final String text;
  final bool isExpert;
  final String time;
  final File? image; // null = text message
  const _ChatMessage({
    required this.sender,
    required this.text,
    required this.isExpert,
    required this.time,
    this.image,
  });
}

class _ChatPanel extends StatefulWidget {
  final String expertName;
  final ScrollController scrollController;

  const _ChatPanel({
    required this.expertName,
    required this.scrollController,
  });

  @override
  State<_ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<_ChatPanel> {
  final TextEditingController _msgController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      sender: '',
      text: '',
      isExpert: true,
      time: '12:30',
    ),
    _ChatMessage(
      sender: 'Bạn',
      text: 'Vết cắn ở cổ tay phải, có 2 dấu răng, đang sưng nhẹ',
      isExpert: false,
      time: '12:31',
    ),
    _ChatMessage(
      sender: '',
      text: 'Bạn có nhớ màu sắc và hoa văn của con rắn không?',
      isExpert: true,
      time: '12:32',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Set first message sender after init to avoid const issue
    _messages[0] = _ChatMessage(
      sender: widget.expertName,
      text: 'Xin chào! Tôi đã xem thông tin của bạn. Bạn có thể mô tả vết cắn không?',
      isExpert: true,
      time: '12:30',
    );
    _messages[2] = _ChatMessage(
      sender: widget.expertName,
      text: 'Bạn có nhớ màu sắc và hoa văn của con rắn không?',
      isExpert: true,
      time: '12:32',
    );
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  String get _nowTime {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _sendText() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(
        sender: 'Bạn',
        text: text,
        isExpert: false,
        time: _nowTime,
      ));
    });
    _msgController.clear();
    _scrollToBottom();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1080,
      );
      if (file == null) return;
      setState(() {
        _messages.add(_ChatMessage(
          sender: 'Bạn',
          text: '',
          isExpert: false,
          time: _nowTime,
          image: File(file.path),
        ));
      });
      _scrollToBottom();
    } catch (_) {
      // permission denied or camera unavailable — silently ignore
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scrollController.hasClients) {
        widget.scrollController.animateTo(
          widget.scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showAttachMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF251830),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAttachOption(
                icon: Icons.photo_library_outlined,
                label: 'Thư viện',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              _buildAttachOption(
                icon: Icons.camera_alt_outlined,
                label: 'Chụp ảnh',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF228B22).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF228B22), size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              const Text(
                'Chat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                widget.expertName,
                style: const TextStyle(
                    color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),

        const Divider(color: Colors.white12, height: 1),

        // Messages
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _messages.length,
            itemBuilder: (ctx, i) => _buildBubble(_messages[i]),
          ),
        ),

        // Input bar
        Container(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
          ),
          child: Row(
            children: [
              // Attach button
              GestureDetector(
                onTap: _showAttachMenu,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white70, size: 22),
                ),
              ),
              const SizedBox(width: 8),

              // Text field
              Expanded(
                child: TextField(
                  controller: _msgController,
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendText(),
                  decoration: InputDecoration(
                    hintText: 'Nhắn tin...',
                    hintStyle:
                        TextStyle(color: Colors.white.withOpacity(0.4)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Send button
              GestureDetector(
                onTap: _sendText,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF228B22),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBubble(_ChatMessage msg) {
    final isMe = !msg.isExpert;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            '${msg.sender} · ${msg.time}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 4),
          if (msg.image != null)
            // Image bubble
            GestureDetector(
              onTap: () => _openImagePreview(msg.image!),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  msg.image!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            // Text bubble
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? const Color(0xFF228B22).withOpacity(0.7)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                msg.text,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  void _openImagePreview(File image) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.file(image, fit: BoxFit.contain),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
