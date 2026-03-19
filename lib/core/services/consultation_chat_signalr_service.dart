import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/signalr_client.dart';

class ConsultationChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final String? attachmentUrl;
  final DateTime sentAt;
  final bool isMine;

  const ConsultationChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.sentAt,
    required this.isMine,
    this.attachmentUrl,
  });

  factory ConsultationChatMessage.fromHubPayload(
    Map<String, dynamic> payload, {
    required String? currentUserId,
  }) {
    final senderId =
        (payload['senderId'] ?? payload['SenderId'] ?? '').toString();
    final sentAtRaw = payload['sentAt'] ?? payload['SentAt'];

    return ConsultationChatMessage(
      id: (payload['id'] ?? payload['Id'] ?? '').toString(),
      senderId: senderId,
      senderName: (payload['senderName'] ?? payload['SenderName'] ?? 'Ẩn danh')
          .toString(),
      content: (payload['content'] ?? payload['Content'] ?? '').toString(),
      attachmentUrl: (payload['attachmentUrl'] ?? payload['AttachmentUrl'])
          ?.toString(),
      sentAt: sentAtRaw != null
          ? (DateTime.tryParse(sentAtRaw.toString())?.toLocal() ??
              DateTime.now())
          : DateTime.now(),
      isMine: currentUserId != null &&
          currentUserId.isNotEmpty &&
          senderId == currentUserId,
    );
  }
}

class ConsultationChatSignalRService {
  final String baseUrl;

  ConsultationChatSignalRService({required this.baseUrl});

  HubConnection? _hubConnection;
  String? _currentUserId;

  final _messageController =
      StreamController<ConsultationChatMessage>.broadcast();
  final _signalController =
      StreamController<({String eventType, String payload})>.broadcast();
  final _connectionStateController =
      StreamController<HubConnectionState>.broadcast();

  Stream<ConsultationChatMessage> get messageStream => _messageController.stream;
  Stream<({String eventType, String payload})> get signalStream =>
      _signalController.stream;
  Stream<HubConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;

  Map<String, dynamic>? _tryParseMap(dynamic raw) {
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic>? _normalizeMessagePayload(List<Object?> arguments) {
    if (arguments.isEmpty) return null;

    // Case 1: argument[0] is map or JSON string map
    final direct = _tryParseMap(arguments[0]);
    if (direct != null) {
      // Some backends wrap chat message inside "data"
      final nested = _tryParseMap(direct['data']);
      return nested ?? direct;
    }

    // Case 2: argument[0] is string content and rest are scalar fields
    // Best-effort positional mapping for common hub payloads.
    if (arguments[0] is String && arguments.length >= 2) {
      return {
        'content': arguments[0],
        'attachmentUrl': arguments.length > 1 ? arguments[1] : null,
        'senderId': arguments.length > 2 ? arguments[2] : '',
        'senderName': arguments.length > 3 ? arguments[3] : 'Ẩn danh',
        'sentAt': arguments.length > 4 ? arguments[4] : DateTime.now().toUtc().toIso8601String(),
        'id': arguments.length > 5 ? arguments[5] : '',
      };
    }

    return null;
  }

  Future<void> connect(String consultationId) async {
    if (_hubConnection != null) {
      await disconnect();
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? prefs.getString('auth_token');
    _currentUserId = prefs.getString('user_id');

    if (token == null || token.isEmpty) {
      throw Exception('Không tìm thấy access token để kết nối chat realtime');
    }

    final hubUrl = '$baseUrl/hubs/consultation?consultationId=$consultationId';

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
            transport: HttpTransportType.WebSockets,
          ),
        )
        .withAutomaticReconnect(
          retryDelays: [0, 2000, 5000, 10000, 30000],
        )
        .build();

    _registerEvents();

    _hubConnection!.onclose(({error}) {
      debugPrint('Consultation chat disconnected: $error');
      _connectionStateController.add(HubConnectionState.Disconnected);
    });

    _hubConnection!.onreconnecting(({error}) {
      debugPrint('Consultation chat reconnecting: $error');
      _connectionStateController.add(HubConnectionState.Reconnecting);
    });

    _hubConnection!.onreconnected(({connectionId}) {
      debugPrint('Consultation chat reconnected: $connectionId');
      _connectionStateController.add(HubConnectionState.Connected);
    });

    await _hubConnection!.start();

    // Some backend implementations require explicit room join after connect.
    // Try both common method names without failing the whole connection.
    try {
      await _hubConnection!.invoke(
        'JoinConsultationRoom',
        args: <Object>[consultationId],
      );
    } catch (_) {
      try {
        await _hubConnection!.invoke(
          'JoinRoom',
          args: <Object>[consultationId],
        );
      } catch (_) {
        // Ignore if hub doesn't expose explicit join methods.
      }
    }

    _connectionStateController.add(HubConnectionState.Connected);
  }

  void _registerEvents() {
    void messageHandler(List<Object?>? arguments) {
      try {
        if (arguments == null || arguments.isEmpty) return;
        final payload = _normalizeMessagePayload(arguments);
        if (payload == null) return;
        final msg = ConsultationChatMessage.fromHubPayload(
          payload,
          currentUserId: _currentUserId,
        );
        if (msg.content.trim().isEmpty &&
            (msg.attachmentUrl == null || msg.attachmentUrl!.isEmpty)) {
          return;
        }
        _messageController.add(msg);
      } catch (e) {
        debugPrint('Failed to parse MessageReceived: $e');
      }
    }

    // Operation 5 contract: server emits MessageReceived.
    _hubConnection!.on('MessageReceived', messageHandler);

    _hubConnection!.on('SignalReceived', (arguments) {
      try {
        if (arguments == null || arguments.isEmpty) return;

        if (arguments.length >= 2) {
          _signalController.add((
            eventType: arguments[0].toString(),
            payload: arguments[1].toString(),
          ));
          return;
        }

        final map = _tryParseMap(arguments[0]);
        if (map != null) {
          _signalController.add((
            eventType: (map['eventType'] ?? '').toString(),
            payload: (map['payload'] ?? '').toString(),
          ));
        }
      } catch (e) {
        debugPrint('Failed to parse SignalReceived: $e');
      }
    });
  }

  Future<void> sendMessage({
    required String content,
    String? attachmentUrl,
  }) async {
    if (!isConnected) throw Exception('Chat chưa kết nối');

    final normalizedAttachment = attachmentUrl?.trim();
    debugPrint(
      '📨 Send chat message: content="${content.trim()}", '
      'hasAttachment=${normalizedAttachment != null && normalizedAttachment.isNotEmpty}',
    );

    await _hubConnection!.invoke(
      'ReceiveMessage',
      args: <Object>[content, normalizedAttachment ?? ''],
    );
  }

  Future<void> sendSignal({
    required String eventType,
    required String payload,
  }) async {
    if (!isConnected) return;
    await _hubConnection!.invoke(
      'Signal',
      args: <Object>[eventType, payload],
    );
  }

  Future<void> disconnect() async {
    try {
      if (_hubConnection != null) {
        await _hubConnection!.stop();
      }
    } catch (_) {
      // Ignore disconnect errors.
    }
    _hubConnection = null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _messageController.close();
    await _signalController.close();
    await _connectionStateController.close();
  }
}
