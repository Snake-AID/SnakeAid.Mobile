import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/signalr_client.dart';

class EmergencyConsultationRequestEvent {
  final String requestId;
  final String requesterId;
  final String expertId;
  final DateTime? requestedAt;
  final DateTime? expiresAt;
  final String? requesterName;
  final String? snakeSuspect;
  final int? feeCost;

  const EmergencyConsultationRequestEvent({
    required this.requestId,
    required this.requesterId,
    required this.expertId,
    this.requestedAt,
    this.expiresAt,
    this.requesterName,
    this.snakeSuspect,
    this.feeCost,
  });

  factory EmergencyConsultationRequestEvent.fromJson(
      Map<String, dynamic> json) {
    int? parseAmount(dynamic value) {
      if (value is num) return value.toInt();
      if (value == null) return null;
      return int.tryParse(value.toString());
    }

    final payment = json['payment'] is Map
        ? Map<String, dynamic>.from(json['payment'] as Map)
        : <String, dynamic>{};

    final feeCost = parseAmount(json['feeCost']) ??
        parseAmount(json['amount']) ??
        parseAmount(json['consultationFee']) ??
        parseAmount(json['emergencyConsultationFee']) ??
        parseAmount(payment['amount']) ??
        parseAmount(payment['feeCost']);

    return EmergencyConsultationRequestEvent(
      requestId: (json['requestId'] ?? '').toString(),
      requesterId: (json['requesterId'] ?? '').toString(),
      expertId: (json['expertId'] ?? '').toString(),
      requestedAt: json['requestedAt'] != null
          ? DateTime.tryParse(json['requestedAt'].toString())
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
      requesterName:
          (json['requesterName'] ?? json['userName'] ?? json['patientName'])
              ?.toString(),
      snakeSuspect: (json['snakeSuspect'] ?? json['snakeName'])?.toString(),
      feeCost: feeCost,
    );
  }
}

class EmergencyRequestStatusChanged {
  final String requestId;
  final String status;
  final String? consultationId;
  final String? roomId;
  final DateTime? updatedAtUtc;

  const EmergencyRequestStatusChanged({
    required this.requestId,
    required this.status,
    this.consultationId,
    this.roomId,
    this.updatedAtUtc,
  });

  factory EmergencyRequestStatusChanged.fromJson(Map<String, dynamic> json) {
    return EmergencyRequestStatusChanged(
      requestId: (json['requestId'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      consultationId: json['consultationId']?.toString(),
      roomId: json['roomId']?.toString(),
      updatedAtUtc: json['updatedAtUtc'] != null
          ? DateTime.tryParse(json['updatedAtUtc'].toString())
          : null,
    );
  }
}

class ExpertPresenceChangedEvent {
  final String expertId;
  final bool isOnline;
  final DateTime? changedAtUtc;

  const ExpertPresenceChangedEvent({
    required this.expertId,
    required this.isOnline,
    this.changedAtUtc,
  });

  factory ExpertPresenceChangedEvent.fromJson(Map<String, dynamic> json) {
    return ExpertPresenceChangedEvent(
      expertId: (json['expertId'] ?? '').toString(),
      isOnline: (json['isOnline'] as bool?) ?? false,
      changedAtUtc: json['changedAtUtc'] != null
          ? DateTime.tryParse(json['changedAtUtc'].toString())
          : null,
    );
  }
}

class EmergencyConsultationSignalRService {
  final String baseUrl;

  EmergencyConsultationSignalRService({required this.baseUrl});

  HubConnection? _hubConnection;

  final _statusChangedController =
      StreamController<EmergencyRequestStatusChanged>.broadcast();
  Stream<EmergencyRequestStatusChanged> get statusChangedStream =>
      _statusChangedController.stream;

    final _requestController =
      StreamController<EmergencyConsultationRequestEvent>.broadcast();
    Stream<EmergencyConsultationRequestEvent> get requestStream =>
      _requestController.stream;

    final _onlineExpertsSnapshotController =
      StreamController<Set<String>>.broadcast();
    Stream<Set<String>> get onlineExpertsSnapshotStream =>
      _onlineExpertsSnapshotController.stream;

    final _expertPresenceChangedController =
      StreamController<ExpertPresenceChangedEvent>.broadcast();
    Stream<ExpertPresenceChangedEvent> get expertPresenceChangedStream =>
      _expertPresenceChangedController.stream;

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

  Future<HubConnection> _buildAndStartConnection() async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString('access_token') ?? prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Không tìm thấy access token để theo dõi tư vấn ngay');
    }

    final conn = HubConnectionBuilder()
        .withUrl(
          '$baseUrl/hubs/expert',
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
            transport: HttpTransportType.WebSockets,
          ),
        )
        .withAutomaticReconnect(
          retryDelays: [0, 2000, 5000, 10000, 30000],
        )
        .build();

    conn.on('EmergencyRequestStatusChanged', (arguments) {
      try {
        if (arguments == null || arguments.isEmpty) return;
        final data = _tryParseMap(arguments[0]);
        if (data == null) return;
        _statusChangedController.add(
          EmergencyRequestStatusChanged.fromJson(data),
        );
      } catch (e) {
        debugPrint('Failed to parse EmergencyRequestStatusChanged: $e');
      }
    });

    conn.on('EmergencyConsultationRequest', (arguments) {
      try {
        if (arguments == null || arguments.isEmpty) return;
        final data = _tryParseMap(arguments[0]);
        if (data == null) return;
        _requestController.add(
          EmergencyConsultationRequestEvent.fromJson(data),
        );
      } catch (e) {
        debugPrint('Failed to parse EmergencyConsultationRequest: $e');
      }
    });

    conn.on('OnlineExpertsSnapshot', (arguments) {
      try {
        if (arguments == null || arguments.isEmpty) return;
        final raw = _tryParseMap(arguments[0]);
        if (raw == null) return;
        final ids = (raw['onlineExpertIds'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toSet();
        _onlineExpertsSnapshotController.add(ids);
      } catch (e) {
        debugPrint('Failed to parse OnlineExpertsSnapshot: $e');
      }
    });

    conn.on('ExpertPresenceChanged', (arguments) {
      try {
        if (arguments == null || arguments.isEmpty) return;
        final raw = _tryParseMap(arguments[0]);
        if (raw == null) return;
        _expertPresenceChangedController.add(
          ExpertPresenceChangedEvent.fromJson(raw),
        );
      } catch (e) {
        debugPrint('Failed to parse ExpertPresenceChanged: $e');
      }
    });

    await conn.start();
    return conn;
  }

  Future<void> connectAsExpert() async {
    if (_hubConnection != null) {
      await disconnect();
    }
    _hubConnection = await _buildAndStartConnection();
    await _hubConnection!.invoke('JoinAsExpert');
  }

  Future<void> connectAsMember() async {
    if (_hubConnection != null) {
      await disconnect();
    }
    _hubConnection = await _buildAndStartConnection();
    await _hubConnection!.invoke('JoinAsMember');
  }

  Future<void> connectAndJoinRequestRoom(String requestId) async {
    if (_hubConnection != null) {
      await disconnect();
    }

    _hubConnection = await _buildAndStartConnection();

    await _hubConnection!.invoke(
      'JoinEmergencyRequestRoom',
      args: <Object>[requestId],
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
    await _statusChangedController.close();
    await _requestController.close();
    await _onlineExpertsSnapshotController.close();
    await _expertPresenceChangedController.close();
  }
}
