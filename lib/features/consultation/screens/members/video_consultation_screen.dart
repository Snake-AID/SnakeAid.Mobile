import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livekit_client/livekit_client.dart' hide ConnectionState;
import 'package:snakeaid_mobile/core/services/consultation_chat_signalr_service.dart';
import '../../repository/consultation_repository.dart';

/// Video consultation screen powered by LiveKit.
/// Receives [livekitToken] and [wsUrl] from WaitingRoom (fetched via API) and connects
/// to the LiveKit server URL provided by the token API response.
class VideoConsultationScreen extends ConsumerStatefulWidget {
  final String consultationId;
  final String expertName;
  final String expertSpecialty;

  /// Controls expert-only in-room features (e.g. snake search)
  final bool isExpertMode;

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
    this.isExpertMode = false,
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

class _VideoConsultationScreenState
    extends ConsumerState<VideoConsultationScreen>
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
  StreamSubscription<({String eventType, String payload})>? _signalSub;
  StreamSubscription<ConsultationCallEndedEvent>? _consultationCallEndedSub;
  final ValueNotifier<List<ConsultationChatMessage>> _chatMessagesNotifier =
      ValueNotifier<List<ConsultationChatMessage>>([]);
  final ValueNotifier<bool> _remoteIsTypingNotifier = ValueNotifier(false);
  Timer? _typingAutoHideTimer;
  bool? _remoteMicOn;
  bool? _remoteCameraOn;
  bool _isChatConnected = false;
  bool _isHandlingRoomExpiry = false;
  final List<_PendingOutgoingEcho> _pendingOutgoingEchoes = [];

  ConsultationChatMessage _buildOptimisticMessage({
    required String content,
    String? attachmentUrl,
  }) {
    return ConsultationChatMessage(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      senderId: 'me',
      senderName: 'Bạn',
      content: content,
      attachmentUrl: attachmentUrl,
      sentAt: DateTime.now(),
      isMine: true,
    );
  }

  String _normalizeChatText(String text) => text.trim().toLowerCase();

  String _normalizeAttachmentUrl(String? url) => (url ?? '').trim();

  bool _isPlaceholderImageText(String text) =>
      _normalizeChatText(text) == '[image]';

  void _markPendingOutgoingEcho({
    required String content,
    String? attachmentUrl,
  }) {
    _pendingOutgoingEchoes.add(
      _PendingOutgoingEcho(
        content: _normalizeChatText(content),
        attachmentUrl: _normalizeAttachmentUrl(attachmentUrl),
        createdAt: DateTime.now(),
      ),
    );

    // Keep memory bounded and drop stale signatures.
    final now = DateTime.now();
    _pendingOutgoingEchoes.removeWhere(
      (e) => now.difference(e.createdAt).inSeconds > 30,
    );
  }

  void _removePendingOutgoingEcho({
    required String content,
    String? attachmentUrl,
  }) {
    final normalizedContent = _normalizeChatText(content);
    final normalizedAttachment = _normalizeAttachmentUrl(attachmentUrl);
    final index = _pendingOutgoingEchoes.indexWhere(
      (e) =>
          e.content == normalizedContent &&
          e.attachmentUrl == normalizedAttachment,
    );
    if (index >= 0) {
      _pendingOutgoingEchoes.removeAt(index);
    }
  }

  void _removeMessageById(String id) {
    final messages = _chatMessagesNotifier.value;
    final next = messages.where((m) => m.id != id).toList();
    if (next.length != messages.length) {
      _chatMessagesNotifier.value = next;
    }
  }

  bool _consumePendingOutgoingEcho(ConsultationChatMessage msg) {
    final normalizedContent = _normalizeChatText(msg.content);
    final normalizedAttachment = _normalizeAttachmentUrl(msg.attachmentUrl);
    final now = DateTime.now();

    for (int i = 0; i < _pendingOutgoingEchoes.length; i++) {
      final pending = _pendingOutgoingEchoes[i];
      final isExpired = now.difference(pending.createdAt).inSeconds > 30;
      if (isExpired) continue;

      final sameContent = pending.content == normalizedContent;
      final sameAttachment = pending.attachmentUrl == normalizedAttachment;
      if (sameContent && sameAttachment) {
        _pendingOutgoingEchoes.removeAt(i);
        return true;
      }
    }

    _pendingOutgoingEchoes.removeWhere(
      (e) => now.difference(e.createdAt).inSeconds > 30,
    );
    return false;
  }

  void _appendChatMessage(ConsultationChatMessage msg) {
    if (!msg.id.startsWith('local-') && _consumePendingOutgoingEcho(msg)) {
      return;
    }

    final messages = _chatMessagesNotifier.value;

    final hasSameId =
        msg.id.isNotEmpty &&
        messages.any((m) => m.id.isNotEmpty && m.id == msg.id);
    if (hasSameId) return;

    // Deduplicate optimistic self message when server echoes back shortly after.
    final hasRecentSelfEcho =
        msg.isMine &&
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
      roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true),
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
    _signalSub?.cancel();
    _consultationCallEndedSub?.cancel();
    _typingAutoHideTimer?.cancel();
    _chatService?.dispose();
    _chatMessagesNotifier.dispose();
    _remoteIsTypingNotifier.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _initChatRealtime() async {
    try {
      final baseUrl = ref
          .read(consultationRepositoryProvider)
          .httpService
          .baseUrl;
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

      // Listen to Signal events (typing, mic/cam state)
      _signalSub = _chatService!.signalStream.listen((signal) {
        if (!mounted) return;
        _handleSignalEvent(signal.eventType, signal.payload);
      });

      _consultationCallEndedSub = _chatService!.consultationCallEndedStream
          .listen((event) {
            _handleConsultationCallEndedEvent(event);
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

    final optimistic = _buildOptimisticMessage(content: content);
    _markPendingOutgoingEcho(content: content);
    _appendChatMessage(optimistic);

    try {
      await _chatService?.sendMessage(content: content);
    } catch (e) {
      _removePendingOutgoingEcho(content: content);
      _removeMessageById(optimistic.id);
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
    final outgoingContent = caption.trim().isEmpty ? '[image]' : caption.trim();
    String? uploadedUrl;
    String? optimisticId;

    try {
      final repo = ref.read(consultationRepositoryProvider);
      debugPrint('🖼️ Uploading chat image from: $filePath');
      final secureUrl = await repo.uploadChatImage(filePath);
      uploadedUrl = secureUrl;
      debugPrint('🖼️ Sending image message, url: $secureUrl');

      final optimistic = _buildOptimisticMessage(
        content: outgoingContent,
        attachmentUrl: secureUrl,
      );
      optimisticId = optimistic.id;
      _markPendingOutgoingEcho(
        content: outgoingContent,
        attachmentUrl: secureUrl,
      );
      _appendChatMessage(optimistic);

      await _chatService?.sendMessage(
        content: outgoingContent,
        attachmentUrl: secureUrl,
      );
    } catch (e) {
      _removePendingOutgoingEcho(
        content: outgoingContent,
        attachmentUrl: uploadedUrl,
      );
      if (optimisticId != null) {
        _removeMessageById(optimisticId);
      }
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
        title: const Text(
          'Quay Về Sảnh Chờ?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Bạn có muốn tạm rời khỏi cuộc gọi và quay về sảnh chờ không?\nBạn có thể vào lại bất cứ lúc nào.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Ở Lại',
              style: TextStyle(color: Color(0xFF228B22)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Just navigate back to waiting room, don't call end API
              // User will end consultation from waiting room with separate button

              if (!mounted) return;
              final targetRoute =
                  widget.afterCallRoute ??
                  '/video-waiting/${widget.consultationId}';

              // Truyền lại canReportExpertAbsent nếu có, hoặc mặc định true nếu là tư vấn đặt lịch
              context.go(
                targetRoute,
                extra: {
                  'expertName': widget.expertName,
                  'expertSpecialty': widget.expertSpecialty,
                  'durationSeconds': _secondsElapsed,
                  'showCompleteButton': true,
                  'canReportExpertAbsent': true,
                  'initialMicOn': _isMicOn,
                  'initialCameraOn': _isCameraOn,
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Về Sảnh Chờ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleMic() async {
    _isMicOn = !_isMicOn;
    await _room.localParticipant?.setMicrophoneEnabled(_isMicOn);
    _sendMediaStateSignal('MicState', _isMicOn);
    setState(() {});
  }

  Future<void> _toggleCamera() async {
    _isCameraOn = !_isCameraOn;
    await _room.localParticipant?.setCameraEnabled(_isCameraOn);
    _sendMediaStateSignal('CameraState', _isCameraOn);
    setState(() {});
  }

  Future<void> _flipCamera() async {
    if (!_isCameraOn) return;
    _isFrontCamera = !_isFrontCamera;
    await _room.localParticipant?.setCameraEnabled(
      true,
      cameraCaptureOptions: CameraCaptureOptions(
        cameraPosition: _isFrontCamera
            ? CameraPosition.front
            : CameraPosition.back,
      ),
    );
    setState(() {});
  }

  void _sendTypingSignal(bool isTyping) {
    if (!_isChatConnected || _chatService == null) return;
    try {
      _chatService!.sendSignal(
        eventType: 'Typing',
        payload: isTyping.toString(),
      );
    } catch (e) {
      debugPrint('Failed to send typing signal: $e');
    }
  }

  void _sendMediaStateSignal(String eventType, bool enabled) {
    if (!_isChatConnected || _chatService == null) return;
    try {
      _chatService!.sendSignal(
        eventType: eventType,
        payload: enabled.toString(),
      );
    } catch (e) {
      debugPrint('Failed to send $eventType signal: $e');
    }
  }

  bool? _parseSignalBool(String payload) {
    final normalized = payload.trim().toLowerCase();
    if (normalized == 'true' || normalized == 'on' || normalized == '1') {
      return true;
    }
    if (normalized == 'false' || normalized == 'off' || normalized == '0') {
      return false;
    }
    return null;
  }

  void _handleSignalEvent(String eventType, String payload) {
    final type = eventType.trim().toLowerCase();

    if (type == 'consultationcallended') {
      try {
        final decoded = jsonDecode(payload);
        if (decoded is Map<String, dynamic>) {
          _handleConsultationCallEndedEvent(
            ConsultationCallEndedEvent(
              consultationId:
                  (decoded['ConsultationId'] ?? decoded['consultationId'] ?? '')
                      .toString(),
              reason: (decoded['Reason'] ?? decoded['reason'] ?? '').toString(),
            ),
          );
        }
      } catch (_) {
        // Ignore malformed ConsultationCallEnded payload.
      }
      return;
    }

    if (type == 'typing') {
      final isTyping = payload.toLowerCase() == 'true';
      setState(() => _remoteIsTypingNotifier.value = isTyping);

      // Auto-dismiss typing indicator after a short grace period.
      _typingAutoHideTimer?.cancel();
      if (isTyping) {
        _typingAutoHideTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() => _remoteIsTypingNotifier.value = false);
          }
        });
      }
      return;
    }

    final parsed = _parseSignalBool(payload);
    if (parsed == null) return;

    if (type == 'micstate' || type == 'mic' || type == 'microphone') {
      setState(() => _remoteMicOn = parsed);
      return;
    }

    if (type == 'camerastate' ||
        type == 'camstate' ||
        type == 'camera' ||
        type == 'cam') {
      setState(() => _remoteCameraOn = parsed);
    }
  }

  Future<void> _handleConsultationCallEndedEvent(
    ConsultationCallEndedEvent event,
  ) async {
    if (!mounted || _isHandlingRoomExpiry) return;
    if (event.consultationId != widget.consultationId) return;

    _isHandlingRoomExpiry = true;
    final normalizedReason = event.reason.trim().toLowerCase();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          normalizedReason == 'timeout'
              ? 'Phiên tư vấn đã hết thời gian. Đang kết thúc cuộc gọi...'
              : 'Phiên tư vấn đã kết thúc. Đang rời cuộc gọi...',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 350));

    try {
      await _room.disconnect();
    } catch (_) {
      // Ignore disconnect failure and continue navigation.
    }

    if (!mounted) return;

    // Always call backend to end consultation so settlement is triggered.
    // endConsultation catches any error internally, so navigation always proceeds.
    await ref
        .read(consultationRepositoryProvider)
        .endConsultation(widget.consultationId);

    if (!mounted) return;

    if (widget.isExpertMode) {
      context.go(
        '/expert-consultation-complete',
        extra: {
          'consultationId': widget.consultationId,
          'patientName': widget.expertName,
          'durationSeconds': _secondsElapsed,
          'feeCost': 0,
          'expiryReason': event.reason,
        },
      );
    } else {
      context.go(
        '/consultation-complete',
        extra: {
          'consultationId': widget.consultationId,
          'expertName': widget.expertName,
          'expertSpecialty': widget.expertSpecialty,
          'durationSeconds': _secondsElapsed,
        },
      );
    }
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
          remoteIsTypingListenable: _remoteIsTypingNotifier,
          isConnected: _isChatConnected,
          onSendText: _handleSendChatText,
          onSendImage: _handleSendChatImage,
          onTyping: _sendTypingSignal,
        ),
      ),
    );
  }

  void _showSnakeSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1a1022),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SnakeSearchPanel(
        onSearch: (query) async {
          final repo = ref.read(consultationRepositoryProvider);
          return repo.searchSnakeSpecies(query);
        },
        onFetchDetail: (id) async {
          final repo = ref.read(consultationRepositoryProvider);
          return repo.getSnakeSpeciesDetail(id);
        },
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
      return Positioned.fill(child: VideoTrackRenderer(remoteTrack));
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
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 2,
                ),
              ),
              child: const Icon(Icons.person, size: 56, color: Colors.white38),
            ),
            const SizedBox(height: 16),
            Text(
              _isAnyoneConnected
                  ? '${widget.expertName} đang tắt camera'
                  : 'Đang chờ đối phương kết nối...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
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
                  fontWeight: FontWeight.w600,
                ),
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _connectionError ?? '',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
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
                    backgroundColor: const Color(0xFF228B22),
                  ),
                  child: const Text(
                    'Thử lại',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/consultation-home'),
                  child: const Text(
                    'Quay về',
                    style: TextStyle(color: Colors.white60),
                  ),
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
                    if (_remoteMicOn == false) ...[
                      const Icon(
                        Icons.mic_off,
                        size: 16,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (_remoteCameraOn == false) ...[
                      const Icon(
                        Icons.videocam_off,
                        size: 16,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 4),
                    ],
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
                    const Icon(Icons.person, size: 18, color: Colors.white70),
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
              MediaQuery.of(context).size.height - 200.0,
            );
            _pipRight = _pipRight.clamp(
              8.0,
              MediaQuery.of(context).size.width - 128.0,
            );
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
                color: Colors.black54,
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
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
                                _isCameraOn ? Icons.person : Icons.videocam_off,
                                size: 28,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Bạn',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
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
                    child: const Icon(
                      Icons.cameraswitch,
                      color: Colors.white,
                      size: 14,
                    ),
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
                        color: Colors.black.withOpacity(0.3),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 30,
                    ),
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
            if (widget.isExpertMode)
              _buildControlButton(
                icon: Icons.pest_control_rodent,
                label: 'Tìm Rắn',
                onTap: _showSnakeSearch,
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
              border: Border.all(color: Colors.white.withOpacity(0.06)),
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
  final ValueListenable<bool> remoteIsTypingListenable;
  final bool isConnected;
  final Future<void> Function(String text) onSendText;
  final Future<void> Function(String filePath, String caption) onSendImage;
  final Function(bool isTyping) onTyping;

  const _ChatPanel({
    required this.expertName,
    required this.scrollController,
    required this.messagesListenable,
    required this.remoteIsTypingListenable,
    required this.isConnected,
    required this.onSendText,
    required this.onSendImage,
    required this.onTyping,
  });

  @override
  State<_ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<_ChatPanel> {
  final TextEditingController _msgController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _pendingImagePath;
  bool _isLocalTyping = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    widget.messagesListenable.addListener(_handleMessagesChanged);
    widget.remoteIsTypingListenable.addListener(_handleRemoteTypingChanged);
    _msgController.addListener(_handleLocalTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void didUpdateWidget(covariant _ChatPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messagesListenable != widget.messagesListenable) {
      oldWidget.messagesListenable.removeListener(_handleMessagesChanged);
      widget.messagesListenable.addListener(_handleMessagesChanged);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
    if (oldWidget.remoteIsTypingListenable != widget.remoteIsTypingListenable) {
      oldWidget.remoteIsTypingListenable.removeListener(
        _handleRemoteTypingChanged,
      );
      widget.remoteIsTypingListenable.addListener(_handleRemoteTypingChanged);
    }
  }

  void _handleMessagesChanged() {
    _scrollToBottom();
  }

  void _handleRemoteTypingChanged() {
    if (mounted) setState(() {});
    _scrollToBottom();
  }

  void _handleLocalTextChanged() {
    final hasText = _msgController.text.trim().isNotEmpty;
    if (hasText && !_isLocalTyping) {
      setState(() => _isLocalTyping = true);
      widget.onTyping(true);
    }

    // Reset typing indicator timer on each change
    _typingTimer?.cancel();
    if (hasText) {
      _typingTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isLocalTyping = false);
          widget.onTyping(false);
        }
      });
    }
  }

  @override
  void dispose() {
    widget.messagesListenable.removeListener(_handleMessagesChanged);
    widget.remoteIsTypingListenable.removeListener(_handleRemoteTypingChanged);
    _typingTimer?.cancel();
    _msgController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    final pendingImagePath = _pendingImagePath;

    if ((pendingImagePath == null || pendingImagePath.isEmpty) &&
        text.isEmpty) {
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
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
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
                style: const TextStyle(color: Colors.white54, fontSize: 13),
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
              return ValueListenableBuilder<bool>(
                valueListenable: widget.remoteIsTypingListenable,
                builder: (_, isRemoteTyping, __) {
                  return ListView.builder(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: messages.length + (isRemoteTyping ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (i < messages.length) {
                        return _buildBubble(messages[i]);
                      } else {
                        return _buildTypingIndicator();
                      }
                    },
                  );
                },
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
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
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
                      child: const Icon(
                        Icons.add,
                        color: Colors.white70,
                        size: 22,
                      ),
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
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.08),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
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
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
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
    final hasImage = msg.attachmentUrl != null && msg.attachmentUrl!.isNotEmpty;
    final showCaption =
        msg.content.trim().isNotEmpty &&
        msg.content.trim().toLowerCase() != '[image]';
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            '${isMe ? 'Bạn' : msg.senderName} · ${_formatTime(msg.sentAt)}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 4),
          if (hasImage)
            Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
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
                ),
                if (showCaption)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
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
            )
          else
            // Text bubble
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.expertName} · Đang gõ',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < 3; i++) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  if (i < 2) const SizedBox(width: 4),
                ],
              ],
            ),
          ),
        ],
      ),
    );
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

class _PendingOutgoingEcho {
  final String content;
  final String attachmentUrl;
  final DateTime createdAt;

  const _PendingOutgoingEcho({
    required this.content,
    required this.attachmentUrl,
    required this.createdAt,
  });
}

class _SnakeSearchPanel extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function(String query) onSearch;
  final Future<Map<String, dynamic>?> Function(int id) onFetchDetail;

  const _SnakeSearchPanel({
    required this.onSearch,
    required this.onFetchDetail,
  });

  @override
  State<_SnakeSearchPanel> createState() => _SnakeSearchPanelState();
}

class _SnakeSearchPanelState extends State<_SnakeSearchPanel> {
  final TextEditingController _queryController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _results = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _search());
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  String _firstNonEmpty(
    Map<String, dynamic> item,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = item[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return fallback;
  }

  List<String> _extractStringList(
    Map<String, dynamic> item,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = item[key];
      if (value is List) {
        final parsed = value
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (parsed.isNotEmpty) return parsed;
      }
      if (value is String && value.trim().isNotEmpty) {
        final parsed = value
            .split(RegExp(r'[;,|]'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (parsed.isNotEmpty) return parsed;
      }
    }
    return const [];
  }

  bool _isVenomousSnake(Map<String, dynamic> item) {
    final venomFlag = item['isVenomous'];
    if (venomFlag is bool) return venomFlag;

    final venomText = _firstNonEmpty(item, [
      'venomLevel',
      'dangerLevel',
      'venomType',
      'venom',
      'riskLevel',
    ]).toLowerCase();

    if (venomText.isEmpty) return false;
    return venomText.contains('doc') ||
        venomText.contains('venom') ||
        venomText.contains('nguy hiem') ||
        venomText.contains('cuc doc');
  }

  List<Map<String, dynamic>> get _displayResults {
    Iterable<Map<String, dynamic>> data = _results;

    final query = _queryController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      data = data.where((item) {
        final combined = [
          _firstNonEmpty(item, ['commonName', 'name', 'vietnameseName']),
          _firstNonEmpty(item, ['scientificName', 'scientific_name']),
          _firstNonEmpty(item, ['slug']),
          _firstNonEmpty(item, ['description']),
          _firstNonEmpty(item, ['identificationSummary']),
          _firstNonEmpty(item, ['primaryVenomType']),
        ].join(' ').toLowerCase();
        return combined.contains(query);
      });
    }

    return data.toList();
  }

  Future<void> _search() async {
    if (_results.isNotEmpty) {
      if (mounted) setState(() {});
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = await widget.onSearch('');
      if (!mounted) return;
      setState(() => _results = data);
    } catch (_) {
      if (!mounted) return;
      setState(() => _results = const []);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể tra cứu loài rắn lúc này'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildFeaturedCard(Map<String, dynamic> item) {
    final commonName = _firstNonEmpty(item, [
      'commonName',
      'name',
      'vietnameseName',
      'snakeName',
      'speciesName',
    ], fallback: 'Không rõ tên');
    final scientificName = _firstNonEmpty(item, [
      'scientificName',
      'scientific_name',
    ]);
    final habitat = _firstNonEmpty(item, [
      'habitat',
      'distribution',
      'region',
      'location',
    ], fallback: 'Chưa có dữ liệu môi trường sống');
    final venom = _firstNonEmpty(item, [
      'venomLevel',
      'dangerLevel',
      'venomType',
      'venom',
      'riskLevel',
    ], fallback: _isVenomousSnake(item) ? 'Độc' : 'Không rõ');
    final imageUrl = _firstNonEmpty(item, [
      'imageUrl',
      'thumbnailUrl',
      'image',
      'photoUrl',
      'avatarUrl',
    ]);
    final identify = _extractStringList(item, [
      'identificationFeatures',
      'identifyFeatures',
      'characteristics',
      'features',
    ]);
    final firstAid = _extractStringList(item, [
      'firstAid',
      'firstAidSteps',
      'recommendedFirstAid',
    ]);
    final antivenom = _firstNonEmpty(item, ['antivenom', 'serum', 'treatment']);

    return InkWell(
      onTap: () => _openDetail(item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1B7F4B).withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  colors: [Color(0x141B7F4B), Color(0x00FFFFFF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 68,
                      height: 68,
                      color: const Color(0xFFE3ECE7),
                      child: imageUrl.isEmpty
                          ? const Icon(Icons.pets, color: Color(0xFF1B7F4B))
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.pets,
                                color: Color(0xFF1B7F4B),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          commonName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F2E1C),
                          ),
                        ),
                        if (scientificName.isNotEmpty)
                          Text(
                            scientificName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF5B7D6A),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _isVenomousSnake(item)
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF16A34A),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                venom,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                habitat,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF5B7D6A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (identify.isNotEmpty) ...[
                    _sectionTitle(Icons.visibility, 'Đặc điểm nhận dạng'),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: identify
                          .take(6)
                          .map(
                            (e) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F6F3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                e,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF335244),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: _infoBox(
                          title: 'Nọc độc',
                          color: const Color(0xFFB91C1C),
                          icon: Icons.coronavirus,
                          lines: [venom],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _infoBox(
                          title: 'Sơ cứu',
                          color: const Color(0xFF15803D),
                          icon: Icons.medical_services,
                          lines: firstAid.isEmpty
                              ? const [
                                  'Băng ép, bất động và đưa đến cơ sở y tế',
                                ]
                              : firstAid.take(2).toList(),
                        ),
                      ),
                    ],
                  ),
                  if (antivenom.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1F0FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.vaccines,
                            color: Color(0xFF1D4ED8),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Huyết thanh: $antivenom',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1E3A8A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCard(Map<String, dynamic> item) {
    final commonName = _firstNonEmpty(item, [
      'commonName',
      'name',
      'vietnameseName',
      'snakeName',
      'speciesName',
    ], fallback: 'Không rõ tên');
    final scientificName = _firstNonEmpty(item, [
      'scientificName',
      'scientific_name',
    ]);
    final habitat = _firstNonEmpty(item, [
      'habitat',
      'distribution',
      'region',
      'location',
    ]);
    final imageUrl = _firstNonEmpty(item, [
      'imageUrl',
      'thumbnailUrl',
      'image',
      'photoUrl',
      'avatarUrl',
    ]);

    return InkWell(
      onTap: () => _openDetail(item),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE6F2EA)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 64,
                height: 64,
                color: const Color(0xFFE3ECE7),
                child: imageUrl.isEmpty
                    ? const Icon(Icons.pets, color: Color(0xFF1B7F4B))
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.pets, color: Color(0xFF1B7F4B)),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    commonName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F2E1C),
                    ),
                  ),
                  if (scientificName.isNotEmpty)
                    Text(
                      scientificName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF5B7D6A),
                      ),
                    ),
                  if (habitat.isNotEmpty)
                    Text(
                      habitat,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF5B7D6A),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _isVenomousSnake(item)
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF16A34A),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF5B7D6A)),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF5B7D6A),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  void _openDetail(Map<String, dynamic> item) {
    final id = item['id'];
    if (id is! int) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0E1B14),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          _SnakeDetailSheet(seed: item, detailFuture: widget.onFetchDetail(id)),
    );
  }

  Widget _infoBox({
    required String title,
    required Color color,
    required IconData icon,
    required List<String> lines,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...lines
              .take(2)
              .map(
                (line) => Text(
                  '- $line',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _displayResults;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      maxChildSize: 0.95,
      minChildSize: 0.55,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF6FBF7),
            borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0E5D6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B7F4B).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.pest_control_rodent,
                        color: Color(0xFF1B7F4B),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Tra cứu loài rắn',
                        style: TextStyle(
                          color: Color(0xFF0F2E1C),
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() => _results = const []);
                              _search();
                            },
                      icon: const Icon(Icons.refresh, color: Color(0xFF5B7D6A)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F2EA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _queryController,
                          style: const TextStyle(color: Color(0xFF0F2E1C)),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _search(),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF5B7D6A),
                            ),
                            hintText: 'Tìm loài rắn...',
                            hintStyle: const TextStyle(
                              color: Color(0xFF5B7D6A),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.only(top: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _search,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B7F4B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Tìm'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFD0E5D6))),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Loài rắn',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F2E1C),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? const Center(
                        child: Text(
                          'Nhập từ khóa để tìm rắn.\nVí dụ: hổ mang, lục, cạp nong...',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF5B7D6A)),
                        ),
                      )
                    : ListView.separated(
                        controller: controller,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, index) {
                          if (index == 0) {
                            return _buildFeaturedCard(items[index]);
                          }
                          return _buildCompactCard(items[index]);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SnakeDetailSheet extends StatelessWidget {
  final Map<String, dynamic> seed;
  final Future<Map<String, dynamic>?> detailFuture;

  const _SnakeDetailSheet({required this.seed, required this.detailFuture});

  String _stringFrom(Map<String, dynamic> data, String key) {
    return (data[key] ?? '').toString().trim();
  }

  List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return value
          .split(RegExp(r'[;,|]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      maxChildSize: 0.98,
      minChildSize: 0.6,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF4FAF5),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: FutureBuilder<Map<String, dynamic>?>(
            future: detailFuture,
            builder: (context, snapshot) {
              final data = snapshot.data ?? seed;
              final commonName = _stringFrom(data, 'commonName');
              final scientificName = _stringFrom(data, 'scientificName');
              final imageUrl = _stringFrom(data, 'imageUrl');
              final description = _stringFrom(data, 'description');
              final summary = _stringFrom(data, 'identificationSummary');
              final venomType = _stringFrom(data, 'primaryVenomType');
              final riskLevel = _stringFrom(data, 'riskLevel');
              final isVenomous = data['isVenomous'] == true;
              final alternativeNames = _stringList(data['alternativeNames']);
              final identification =
                  data['identification'] is Map<String, dynamic>
                  ? data['identification'] as Map<String, dynamic>
                  : const <String, dynamic>{};
              final traits = _stringList(identification['physicalTraits']);
              final behaviors = _stringList(identification['behaviors']);
              final habitat = _stringFrom(identification, 'habitat');
              final symptoms = data['symptomsByTime'] is List
                  ? data['symptomsByTime'] as List<dynamic>
                  : const [];
              final firstAid =
                  data['firstAidGuidelineOverride'] is Map<String, dynamic>
                  ? data['firstAidGuidelineOverride'] as Map<String, dynamic>
                  : const <String, dynamic>{};
              final firstAidContent =
                  firstAid['content'] is Map<String, dynamic>
                  ? firstAid['content'] as Map<String, dynamic>
                  : const <String, dynamic>{};
              final firstAidSteps = firstAidContent['steps'] is List
                  ? firstAidContent['steps'] as List<dynamic>
                  : const [];
              final venoms = data['venoms'] is List
                  ? data['venoms'] as List<dynamic>
                  : const [];
              final antivenoms = data['antivenoms'] is List
                  ? data['antivenoms'] as List<dynamic>
                  : const [];

              return ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD0E5D6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      Container(
                        height: 190,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1B7F4B), Color(0xFF0F2E1C)],
                          ),
                          image: imageUrl.isEmpty
                              ? null
                              : DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(0.2),
                                    BlendMode.darken,
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        top: 14,
                        right: 14,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.35),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              commonName.isEmpty ? 'Không rõ tên' : commonName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (scientificName.isNotEmpty)
                              Text(
                                scientificName,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isVenomous
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFF16A34A),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    isVenomous ? 'Có độc' : 'Không độc',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (venomType.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      venomType,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                if (riskLevel.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'Risk $riskLevel',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
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
                  const SizedBox(height: 16),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE6F2EA)),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Đang tải thông tin chi tiết...',
                              style: TextStyle(color: Color(0xFF335244)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (description.isNotEmpty) ...[
                    _detailSection('Tóm tắt', description),
                  ],
                  if (summary.isNotEmpty) ...[
                    _detailSection('Nhận dạng nhanh', summary),
                  ],
                  if (alternativeNames.isNotEmpty) ...[
                    _detailSection('Tên gọi khác', alternativeNames.join(', ')),
                  ],
                  if (traits.isNotEmpty) ...[
                    _detailListSection('Đặc điểm nhận dạng', traits),
                  ],
                  if (behaviors.isNotEmpty) ...[
                    _detailListSection('Hành vi', behaviors),
                  ],
                  if (habitat.isNotEmpty) ...[
                    _detailSection('Môi trường sống', habitat),
                  ],
                  if (symptoms.isNotEmpty) ...[_symptomSection(symptoms)],
                  if (firstAidSteps.isNotEmpty) ...[
                    _firstAidSection(firstAidSteps),
                  ],
                  if (venoms.isNotEmpty) ...[_venomSection(venoms)],
                  if (antivenoms.isNotEmpty) ...[_antivenomSection(antivenoms)],
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _detailSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6F2EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F2E1C),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(fontSize: 12, color: Color(0xFF335244)),
          ),
        ],
      ),
    );
  }

  Widget _detailListSection(String title, List<String> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6F2EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F2E1C),
            ),
          ),
          const SizedBox(height: 6),
          ...items
              .take(6)
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '- $e',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF335244),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _symptomSection(List<dynamic> symptoms) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6F2EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Triệu chứng theo thời gian',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F2E1C),
            ),
          ),
          const SizedBox(height: 6),
          ...symptoms.take(4).map((entry) {
            if (entry is! Map) return const SizedBox();
            final timeRange = (entry['timeRange'] ?? '').toString();
            final signs = _stringList(entry['signs']);
            final critical = entry['isCritical'] == true;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: critical
                    ? const Color(0xFFFEE2E2)
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeRange.isEmpty ? 'Không rõ' : timeRange,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: critical
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFF1D4ED8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...signs
                      .take(4)
                      .map(
                        (s) => Text(
                          '- $s',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF334155),
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

  Widget _firstAidSection(List<dynamic> steps) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6F2EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sơ cứu đề xuất',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F2E1C),
            ),
          ),
          const SizedBox(height: 6),
          ...steps.take(4).map((e) {
            if (e is! Map) return const SizedBox();
            final text = (e['text'] ?? '').toString();
            if (text.isEmpty) return const SizedBox();
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '- $text',
                style: const TextStyle(fontSize: 12, color: Color(0xFF335244)),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _venomSection(List<dynamic> venoms) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6F2EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thong tin doc to',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F2E1C),
            ),
          ),
          const SizedBox(height: 6),
          ...venoms.take(3).map((v) {
            if (v is! Map) return const SizedBox();
            final type = (v['venomType'] ?? '').toString();
            final desc = (v['description'] ?? '').toString();
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (type.isNotEmpty)
                    Text(
                      type,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B7F4B),
                      ),
                    ),
                  if (desc.isNotEmpty)
                    Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF335244),
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

  Widget _antivenomSection(List<dynamic> antivenoms) {
    final items = antivenoms
        .map((e) => e is Map ? (e['name'] ?? e['type'] ?? e['title']) : e)
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (items.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Huyet thanh',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D4ED8),
            ),
          ),
          const SizedBox(height: 6),
          ...items
              .take(4)
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '- $e',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
