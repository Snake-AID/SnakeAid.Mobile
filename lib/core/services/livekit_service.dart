import 'package:livekit_client/livekit_client.dart';

/// Core LiveKit Service — wraps LiveKit Room lifecycle
/// Placed in core/services/ because it manages a long-lived connection
/// (same pattern as rescuer_signalr_service.dart)
class LiveKitService {
  Room? _room;
  EventsListener<RoomEvent>? _listener;

  /// Connect to a LiveKit room
  Future<Room> connect(String wsUrl, String token) async {
    // Disconnect any existing room first
    await disconnect();

    final options = const RoomOptions(adaptiveStream: true, dynacast: true);
    _room = Room(roomOptions: options);
    await _room!.prepareConnection(wsUrl, token);
    await _room!.connect(wsUrl, token);
    _listener = _room!.createListener();
    return _room!;
  }

  Future<void> setCameraEnabled(bool enabled) async {
    await _room?.localParticipant?.setCameraEnabled(enabled);
  }

  Future<void> setMicrophoneEnabled(bool enabled) async {
    await _room?.localParticipant?.setMicrophoneEnabled(enabled);
  }

  Future<void> disconnect() async {
    _listener?.dispose();
    await _room?.disconnect();
    _room = null;
    _listener = null;
  }

  Room? get room => _room;
  EventsListener<RoomEvent>? get listener => _listener;
  bool get isConnected => _room != null;
}
