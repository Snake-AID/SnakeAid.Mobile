import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/video_call_provider.dart';
import '../widgets/video_tile.dart';
import '../widgets/call_controls.dart';
import '../../../core/services/livekit_service.dart';

/// Standalone demo video call screen
/// Uses livekit-token/demo/{roomname} endpoint
/// Entry point: /demo-video-call route
class DemoVideoCallScreen extends ConsumerStatefulWidget {
  const DemoVideoCallScreen({super.key});

  @override
  ConsumerState<DemoVideoCallScreen> createState() =>
      _DemoVideoCallScreenState();
}

class _DemoVideoCallScreenState extends ConsumerState<DemoVideoCallScreen> {
  final _roomNameController = TextEditingController();

  // UI state
  _CallState _callState = _CallState.idle;
  String? _errorMessage;

  // LiveKit state
  Room? _room;
  EventsListener<RoomEvent>? _listener;
  List<RemoteParticipant> _remoteParticipants = [];
  bool _isMicEnabled = true;
  bool _isCameraEnabled = true;
  LiveKitService? _liveKitService;

  @override
  void dispose() {
    _roomNameController.dispose();
    _disconnectRoom();
    super.dispose();
  }

  // === Permission handling ===

  Future<bool> _requestPermissions() async {
    final camera = await Permission.camera.request();
    final mic = await Permission.microphone.request();

    if (camera.isPermanentlyDenied || mic.isPermanentlyDenied) {
      if (mounted) {
        _showPermissionDeniedDialog();
      }
      return false;
    }
    return camera.isGranted && mic.isGranted;
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quyền truy cập bị từ chối'),
        content: const Text(
          'Vui lòng cấp quyền camera và microphone trong Cài đặt để sử dụng video call.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: const Text('Mở Cài đặt'),
          ),
        ],
      ),
    );
  }

  // === Call flow ===

  Future<void> _joinCall() async {
    final roomName = _roomNameController.text.trim();
    if (roomName.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập tên phòng');
      return;
    }

    // Request permissions
    final granted = await _requestPermissions();
    if (!granted) return;

    setState(() {
      _callState = _CallState.connecting;
      _errorMessage = null;
    });

    try {
      // Fetch demo token
      final repository = ref.read(videoCallRepositoryProvider);
      final tokenResponse = await repository.getDemoVideoToken(roomName);

      // Connect to LiveKit room
      _liveKitService = ref.read(liveKitServiceProvider);
      _room = await _liveKitService!.connect(
        tokenResponse.wsUrl,
        tokenResponse.token,
      );
      _listener = _liveKitService!.listener;

      // Setup event listeners
      _setupRoomListeners();

      // Enable camera and microphone
      await _liveKitService!.setCameraEnabled(true);
      await _liveKitService!.setMicrophoneEnabled(true);

      setState(() {
        _callState = _CallState.connected;
        _isMicEnabled = true;
        _isCameraEnabled = true;
        _updateRemoteParticipants();
      });
    } catch (e) {
      setState(() {
        _callState = _CallState.idle;
        _errorMessage = 'Không thể kết nối: ${e.toString()}';
      });
    }
  }

  void _setupRoomListeners() {
    _listener
      ?..on<RoomDisconnectedEvent>((event) {
        if (mounted) {
          setState(() {
            _callState = _CallState.disconnected;
          });
        }
      })
      ..on<ParticipantConnectedEvent>((event) {
        if (mounted) {
          setState(() => _updateRemoteParticipants());
        }
      })
      ..on<ParticipantDisconnectedEvent>((event) {
        if (mounted) {
          setState(() => _updateRemoteParticipants());
        }
      })
      ..on<TrackPublishedEvent>((event) {
        if (mounted) setState(() {});
      })
      ..on<TrackUnpublishedEvent>((event) {
        if (mounted) setState(() {});
      })
      ..on<TrackSubscribedEvent>((event) {
        if (mounted) setState(() {});
      })
      ..on<TrackUnsubscribedEvent>((event) {
        if (mounted) setState(() {});
      });
  }

  void _updateRemoteParticipants() {
    _remoteParticipants = _room?.remoteParticipants.values.toList() ?? [];
  }

  Future<void> _toggleMic() async {
    final newState = !_isMicEnabled;
    await _liveKitService?.setMicrophoneEnabled(newState);
    setState(() => _isMicEnabled = newState);
  }

  Future<void> _toggleCamera() async {
    final newState = !_isCameraEnabled;
    await _liveKitService?.setCameraEnabled(newState);
    setState(() => _isCameraEnabled = newState);
  }

  Future<void> _flipCamera() async {
    final publication = _room?.localParticipant?.videoTrackPublications
        .where((pub) => pub.source == TrackSource.camera)
        .firstOrNull;
    if (publication?.track != null) {
      // final track = publication!.track as LocalVideoTrack;
      // await track.switchCamera(); // expect deviceId
    }
  }

  Future<void> _endCall() async {
    await _disconnectRoom();
    setState(() {
      _callState = _CallState.disconnected;
    });
  }

  Future<void> _disconnectRoom() async {
    await _liveKitService?.disconnect();
    _room = null;
    _listener = null;
    _remoteParticipants = [];
    _liveKitService = null;
  }

  void _rejoin() {
    setState(() {
      _callState = _CallState.idle;
      _errorMessage = null;
    });
  }

  // === UI ===

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: _callState == _CallState.connected
          ? null
          : AppBar(
              title: const Text('Video Call Demo'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
      body: switch (_callState) {
        _CallState.idle => _buildIdleView(),
        _CallState.connecting => _buildConnectingView(),
        _CallState.connected => _buildConnectedView(),
        _CallState.disconnected => _buildDisconnectedView(),
      },
    );
  }

  Widget _buildIdleView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.video_call, size: 80, color: Colors.tealAccent),
            const SizedBox(height: 24),
            const Text(
              'Demo Video Call',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhập tên phòng để bắt đầu cuộc gọi video',
              style: TextStyle(color: Colors.white60, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _roomNameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tên phòng (VD: test-room)',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(
                  Icons.meeting_room,
                  color: Colors.white54,
                ),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.tealAccent,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _joinCall,
                icon: const Icon(Icons.video_call),
                label: const Text(
                  'Tham gia cuộc gọi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectingView() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.tealAccent),
          SizedBox(height: 16),
          Text(
            'Đang kết nối...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Remote participant (full screen) or waiting placeholder
        if (_remoteParticipants.isNotEmpty)
          VideoTile(participant: _remoteParticipants.first, showInfo: true)
        else
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_outline, color: Colors.white38, size: 64),
                SizedBox(height: 16),
                Text(
                  'Đang chờ người tham gia...',
                  style: TextStyle(color: Colors.white60, fontSize: 16),
                ),
              ],
            ),
          ),

        // Local participant (PiP, top-right)
        if (_room?.localParticipant != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            width: 120,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white30, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: VideoTile(
                  participant: _room!.localParticipant!,
                  isMirrored: true,
                  showInfo: false,
                ),
              ),
            ),
          ),

        // Room name badge
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.meeting_room,
                  color: Colors.tealAccent,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  _roomNameController.text,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ),

        // Controls at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CallControls(
            isMicEnabled: _isMicEnabled,
            isCameraEnabled: _isCameraEnabled,
            onToggleMic: _toggleMic,
            onToggleCamera: _toggleCamera,
            onFlipCamera: _flipCamera,
            onEndCall: _endCall,
          ),
        ),
      ],
    );
  }

  Widget _buildDisconnectedView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.call_end, color: Colors.redAccent, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Cuộc gọi đã kết thúc',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _rejoin,
                icon: const Icon(Icons.refresh),
                label: const Text('Gọi lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Quay lại'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _CallState { idle, connecting, connected, disconnected }
