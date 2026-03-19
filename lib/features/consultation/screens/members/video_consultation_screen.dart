import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:snakeaid_mobile/core/services/consultation_chat_signalr_service.dart';
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
  Timer? _trackSubscriptionTimer;

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

  // ── In-room chat (SignalR) ────────────────────────────────────────────────
  ConsultationChatSignalRService? _chatService;
  StreamSubscription<ConsultationChatMessage>? _chatSub;
  final ValueNotifier<List<ConsultationChatMessage>> _chatMessagesNotifier =
      ValueNotifier<List<ConsultationChatMessage>>([]);
  bool _isChatConnected = false;

  void _appendChatMessage(ConsultationChatMessage msg) {
    final messages = _chatMessagesNotifier.value;

    final hasSameId = msg.id.isNotEmpty &&
        messages.any((m) => m.id.isNotEmpty && m.id == msg.id);
    if (hasSameId) return;

    // Deduplicate optimistic self message when server echoes back shortly after.
    final hasRecentSelfEcho = msg.isMine &&
        messages.any(
          (m) =>
              m.isMine == msg.isMine &&
              m.content == msg.content &&
              m.attachmentUrl == msg.attachmentUrl &&
              (m.sentAt.difference(msg.sentAt).inSeconds).abs() <= 8,
        );
    if (hasRecentSelfEcho) return;

    _chatMessagesNotifier.value = [...messages, msg];
  }

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
    
    // Listen to all important room events
    _room.addListener(_onRoomChanged);
    
    _connectToRoom();
    _initChatRealtime();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _secondsElapsed++);
    });

    // Periodic check to subscribe to remote tracks
    _trackSubscriptionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _subscribeToRemoteTracks();
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
      
      // Enable microphone
      await _room.localParticipant?.setMicrophoneEnabled(_isMicOn);
      
      // Enable camera with proper capture options
      if (_isCameraOn) {
        await _room.localParticipant?.setCameraEnabled(
          true,
          cameraCaptureOptions: CameraCaptureOptions(
            cameraPosition: _isFrontCamera 
                ? CameraPosition.front 
                : CameraPosition.back,
          ),
        );
      }
      
      // Subscribe to any existing remote participant tracks
      _subscribeToRemoteTracks();
      
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

  /// Subscribe to remote participant's tracks
  void _subscribeToRemoteTracks() {
    final remoteParticipants = _room.remoteParticipants.values;
    for (final participant in remoteParticipants) {
      for (final publication in participant.trackPublications.values) {
        if (!publication.subscribed) {
          try {
            publication.subscribe();
          } catch (e) {
            debugPrint('Failed to subscribe to track: $e');
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _trackSubscriptionTimer?.cancel();
    _liveBadgeController.dispose();
    _notesController.dispose();
    _room.removeListener(_onRoomChanged);
    _room.disconnect();
    _room.dispose();
    _chatSub?.cancel();
    _chatService?.dispose();
    _chatMessagesNotifier.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _initChatRealtime() async {
    try {
      final baseUrl = ref.read(consultationRepositoryProvider).httpService.baseUrl;
      _chatService = ConsultationChatSignalRService(baseUrl: baseUrl);

      _appendChatMessage(
        ConsultationChatMessage(
          id: 'local-welcome',
          senderId: '',
          senderName: widget.expertName,
          content: 'Xin chào! Bạn có thể nhắn tin trong phòng tư vấn.',
          sentAt: DateTime.now(),
          isMine: false,
        ),
      );

      _chatSub = _chatService!.messageStream.listen((msg) {
        if (!mounted) return;
        setState(() {
          _appendChatMessage(msg);
        });
      });

      await _chatService!.connect(widget.consultationId);
      if (!mounted) return;
      setState(() => _isChatConnected = true);
    } catch (e) {
      debugPrint('Chat realtime not connected: $e');
      if (!mounted) return;
      setState(() => _isChatConnected = false);
    }
  }

  Future<void> _handleSendChatText(String text) async {
    final content = text.trim();
    if (content.isEmpty) return;

    try {
      await _chatService?.sendMessage(content: content);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không gửi được tin nhắn: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleSendChatImage(String filePath, String caption) async {
    try {
      final repo = ref.read(consultationRepositoryProvider);
      debugPrint('🖼️ Uploading chat image from: $filePath');
      final secureUrl = await repo.uploadChatImage(filePath);
      final outgoingContent =
          caption.trim().isEmpty ? '[image]' : caption.trim();
      debugPrint('🖼️ Sending image message, url: $secureUrl');

      await _chatService?.sendMessage(
        content: outgoingContent,
        attachmentUrl: secureUrl,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không gửi được ảnh chat: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
        title: const Text('Quay Về Sảnh Chờ?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Bạn có muốn tạm rời khỏi cuộc gọi và quay về sảnh chờ không?\nBạn có thể vào lại bất cứ lúc nào.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Ở Lại',
                style: TextStyle(color: Color(0xFF228B22))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Just navigate back to waiting room, don't call end API
              // User will end consultation from waiting room with separate button

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
            child: const Text('Về Sảnh Chờ',
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
        builder: (ctx, controller) => _ChatPanel(
          expertName: widget.expertName,
          scrollController: controller,
          messagesListenable: _chatMessagesNotifier,
          isConnected: _isChatConnected,
          onSendText: _handleSendChatText,
          onSendImage: _handleSendChatImage,
        ),
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
class _ChatPanel extends StatefulWidget {
  final String expertName;
  final ScrollController scrollController;
  final ValueListenable<List<ConsultationChatMessage>> messagesListenable;
  final bool isConnected;
  final Future<void> Function(String text) onSendText;
  final Future<void> Function(String filePath, String caption) onSendImage;

  const _ChatPanel({
    required this.expertName,
    required this.scrollController,
    required this.messagesListenable,
    required this.isConnected,
    required this.onSendText,
    required this.onSendImage,
  });

  @override
  State<_ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<_ChatPanel> {
  final TextEditingController _msgController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _pendingImagePath;

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    final pendingImagePath = _pendingImagePath;

    if ((pendingImagePath == null || pendingImagePath.isEmpty) && text.isEmpty) {
      return;
    }

    if (pendingImagePath != null && pendingImagePath.isNotEmpty) {
      await widget.onSendImage(pendingImagePath, text);
      _pendingImagePath = null;
    } else {
      await widget.onSendText(text);
    }

    _msgController.clear();
    if (mounted) setState(() {});
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
      if (!mounted) return;
      setState(() {
        _pendingImagePath = file.path;
      });
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

        if (!widget.isConnected)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Chat realtime chưa kết nối. Tin nhắn có thể không gửi được.',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),

        const Divider(color: Colors.white12, height: 1),

        // Messages
        Expanded(
          child: ValueListenableBuilder<List<ConsultationChatMessage>>(
            valueListenable: widget.messagesListenable,
            builder: (_, messages, __) {
              return ListView.builder(
                controller: widget.scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: messages.length,
                itemBuilder: (ctx, i) => _buildBubble(messages[i]),
              );
            },
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_pendingImagePath != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_pendingImagePath!),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Ảnh đã chọn. Bấm gửi để gửi ảnh.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => _pendingImagePath = null);
                        },
                        child: const Icon(
                          Icons.close,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
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
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: _pendingImagePath != null
                            ? 'Thêm chú thích (tuỳ chọn)...'
                            : 'Nhắn tin...',
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
                    onTap: _sendMessage,
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBubble(ConsultationChatMessage msg) {
    final isMe = msg.isMine;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            '${isMe ? 'Bạn' : msg.senderName} · ${_formatTime(msg.sentAt)}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 4),
          if (msg.attachmentUrl != null && msg.attachmentUrl!.isNotEmpty)
            // Image bubble
            GestureDetector(
              onTap: () => _openImagePreview(msg.attachmentUrl!),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  msg.attachmentUrl!,
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
                msg.content,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _openImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.network(imageUrl, fit: BoxFit.contain),
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
