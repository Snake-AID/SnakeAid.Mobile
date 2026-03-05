import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Mock video consultation screen (UI only — LiveKit integration pending)
/// [initialMicOn] / [initialCameraOn] are synced from the waiting room so
/// the device state on entry matches what the user configured before joining.
/// [afterCallRoute] overrides the route to navigate to after ending the call
/// (default: `/video-waiting/:id` for members; expert side passes its own route).
class VideoConsultationScreen extends StatefulWidget {
  final String consultationId;
  final String expertName;
  final String expertSpecialty;
  /// Mic state chosen in the waiting room (default on)
  final bool initialMicOn;
  /// Camera state chosen in the waiting room (default on)
  final bool initialCameraOn;
  /// Route to go to after ending the call (null = use default member waiting room)
  final String? afterCallRoute;

  const VideoConsultationScreen({
    super.key,
    required this.consultationId,
    required this.expertName,
    required this.expertSpecialty,
    this.initialMicOn = true,
    this.initialCameraOn = true,
    this.afterCallRoute,
  });

  @override
  State<VideoConsultationScreen> createState() =>
      _VideoConsultationScreenState();
}

class _VideoConsultationScreenState extends State<VideoConsultationScreen>
    with TickerProviderStateMixin {
  // Timer đếm thời gian
  late Timer _timer;
  int _secondsElapsed = 0;

  // Trạng thái controls — khởi đầu từ sảnh chờ
  late bool _isMicOn;
  late bool _isCameraOn;

  // Vị trí PiP (picture-in-picture)
  double _pipTop = 96;
  double _pipRight = 16;

  // Animation cho blink "Trực tuyến"
  late AnimationController _liveBadgeController;

  // Controller cho notes
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Đồng bộ trạng thái mic/camera từ sảnh chờ
    _isMicOn = widget.initialMicOn;
    _isCameraOn = widget.initialCameraOn;

    // Ẩn status bar, full screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // TODO (LiveKit): sau khi room.connect() xong, gọi:
    //   room.localParticipant.setMicrophoneEnabled(_isMicOn);
    //   room.localParticipant.setCameraEnabled(_isCameraOn);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _secondsElapsed++);
    });

    _liveBadgeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer.cancel();
    _liveBadgeController.dispose();
    _notesController.dispose();
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
            onPressed: () {
              Navigator.pop(ctx);
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
          // ── Nền giả camera bệnh nhân ──────────────────────────────────
          _buildPatientBackground(),

          // ── Overlay gradient (trên + dưới) ────────────────────────────
          _buildGradientOverlay(),

          // ── PiP: camera chuyên gia (kéo được) ─────────────────────────
          _buildDraggablePip(),

          // ── Top bar ───────────────────────────────────────────────────
          _buildTopBar(),

          // ── Bottom controls ────────────────────────────────────
          _buildBottomControls(),
        ],
      ),
    );
  }

  // ─── Nền camera bệnh nhân ────────────────────────────────────────────────

  Widget _buildPatientBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
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
                    color: Colors.white.withOpacity(0.15), width: 2),
              ),
              child: const Icon(Icons.person,
                  size: 56, color: Colors.white38),
            ),
            const SizedBox(height: 16),
            Text(
              'Camera của bạn',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
          ],
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

  // ─── Draggable PiP ───────────────────────────────────────────────────────

  Widget _buildDraggablePip() {
    return Positioned(
      top: _pipTop,
      right: _pipRight,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _pipTop += details.delta.dy;
            _pipRight -= details.delta.dx;

            // Clamp inside screen
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
                  color: Colors.black54,
                  blurRadius: 16,
                  offset: Offset(0, 4))
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Mock expert video - placeholder
              Container(
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
                        child: const Icon(Icons.person,
                            size: 28, color: Colors.white54),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.expertName.split(' ').last,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),

              // Switch camera button on hover
              Positioned(
                bottom: 6,
                right: 6,
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
              onTap: () => setState(() => _isMicOn = !_isMicOn),
            ),
            _buildControlButton(
              icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
              label: 'Camera',
              highlighted: _isCameraOn,
              onTap: () => setState(() => _isCameraOn = !_isCameraOn),
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
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã lật camera'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
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
