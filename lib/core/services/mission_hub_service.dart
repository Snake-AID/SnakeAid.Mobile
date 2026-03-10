import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Data model for rescuer-accepted event from MissionHub
class RescuerAcceptedData {
  final String missionId;
  final String rescuerId;
  final DateTime acceptedAt;
  final String message;

  const RescuerAcceptedData({
    required this.missionId,
    required this.rescuerId,
    required this.acceptedAt,
    required this.message,
  });

  factory RescuerAcceptedData.fromJson(Map<String, dynamic> json) {
    return RescuerAcceptedData(
      missionId:
          json['MissionId'] as String? ?? json['missionId'] as String? ?? '',
      rescuerId:
          json['RescuerId'] as String? ?? json['rescuerId'] as String? ?? '',
      acceptedAt: json['AcceptedAt'] != null
          ? DateTime.parse(json['AcceptedAt'] as String)
          : (json['acceptedAt'] != null
                ? DateTime.parse(json['acceptedAt'] as String)
                : DateTime.now()),
      message: json['Message'] as String? ?? json['message'] as String? ?? '',
    );
  }
}

/// Data model for rescuer location update from MissionHub
class RescuerLocationData {
  final String userId;
  final double latitude;
  final double longitude;
  final DateTime updatedAt;

  const RescuerLocationData({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });

  factory RescuerLocationData.fromJson(Map<String, dynamic> json) {
    return RescuerLocationData(
      userId: json['UserId'] as String? ?? json['userId'] as String? ?? '',
      latitude: (json['Latitude'] ?? json['latitude'] as num).toDouble(),
      longitude: (json['Longitude'] ?? json['longitude'] as num).toDouble(),
      updatedAt: json['UpdatedAt'] != null
          ? DateTime.parse(json['UpdatedAt'] as String)
          : DateTime.now(),
    );
  }
}

/// Data model for member location update sent to MissionHub (for rescuer map)
class MemberLocationData {
  final String userId;
  final double latitude;
  final double longitude;
  final DateTime updatedAt;

  const MemberLocationData({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });

  factory MemberLocationData.fromJson(Map<String, dynamic> json) {
    return MemberLocationData(
      userId: json['UserId'] as String? ?? json['userId'] as String? ?? '',
      latitude: (json['Latitude'] ?? json['latitude'] as num).toDouble(),
      longitude: (json['Longitude'] ?? json['longitude'] as num).toDouble(),
      updatedAt: json['UpdatedAt'] != null
          ? DateTime.parse(json['UpdatedAt'] as String)
          : DateTime.now(),
    );
  }
}

/// Data model for mission-completed event
class MissionCompletedData {
  final String? result;
  final DateTime? completedAt;

  const MissionCompletedData({this.result, this.completedAt});

  factory MissionCompletedData.fromJson(Map<String, dynamic> json) {
    return MissionCompletedData(
      result: json['Result'] as String? ?? json['result'] as String?,
      completedAt: json['CompletedAt'] != null
          ? DateTime.parse(json['CompletedAt'] as String)
          : null,
    );
  }
}

/// SignalR Service for Member – MissionHub
///
/// Connects to `/hubs/mission?incidentId=<id>` after SOS is created.
/// Receives real-time updates: RescuerAccepted, LocationUpdated,
/// RescuerArrived, MissionCompleted, MissionCancelled, SessionExpired.
class MissionHubService {
  static MissionHubService? _instance;
  final String baseUrl;

  MissionHubService._internal(this.baseUrl);

  factory MissionHubService({required String baseUrl}) {
    _instance ??= MissionHubService._internal(baseUrl);
    return _instance!;
  }

  HubConnection? _hubConnection;
  String? _currentIncidentId;

  // ── Stream controllers ──────────────────────────────────────────────────────
  final _rescuerAcceptedController =
      StreamController<RescuerAcceptedData>.broadcast();
  final _locationUpdatedController =
      StreamController<RescuerLocationData>.broadcast();
  final _memberLocationUpdatedController =
      StreamController<MemberLocationData>.broadcast();
  final _rescuerArrivedController = StreamController<void>.broadcast();
  final _missionCompletedController =
      StreamController<MissionCompletedData>.broadcast();
  final _missionCancelledController = StreamController<String>.broadcast();
  final _sessionExpiredController = StreamController<void>.broadcast();
  final _connectionStateController =
      StreamController<HubConnectionState>.broadcast();

  // ── Public streams ──────────────────────────────────────────────────────────
  Stream<RescuerAcceptedData> get rescuerAcceptedStream =>
      _rescuerAcceptedController.stream;
  Stream<RescuerLocationData> get locationUpdatedStream =>
      _locationUpdatedController.stream;
  Stream<MemberLocationData> get memberLocationUpdatedStream =>
      _memberLocationUpdatedController.stream;
  Stream<void> get rescuerArrivedStream => _rescuerArrivedController.stream;
  Stream<MissionCompletedData> get missionCompletedStream =>
      _missionCompletedController.stream;
  Stream<String> get missionCancelledStream =>
      _missionCancelledController.stream;
  Stream<void> get sessionExpiredStream => _sessionExpiredController.stream;
  Stream<HubConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  // ── State ────────────────────────────────────────────────────────────────────
  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;
  HubConnectionState? get connectionState => _hubConnection?.state;
  String? get currentIncidentId => _currentIncidentId;

  // ────────────────────────────────────────────────────────────────────────────
  /// Connect to MissionHub for a given [incidentId].
  ///
  /// Reads `access_token` from SharedPreferences automatically.
  /// Safe to call multiple times – disconnects existing connection first.
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> connectForIncident(String incidentId) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔌 Connecting to MissionHub...');
      debugPrint('📋 Incident ID: $incidentId');

      // Avoid reconnecting for the same incident
      if (_hubConnection != null &&
          isConnected &&
          _currentIncidentId == incidentId) {
        debugPrint(
          '✅ Already connected to MissionHub for incident $incidentId',
        );
        return;
      }

      // Disconnect existing connection if any
      if (_hubConnection != null) {
        await disconnect();
      }

      _currentIncidentId = incidentId;

      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('No access token found. Please login first.');
      }

      // Build connection – incidentId passed as query param
      _hubConnection = HubConnectionBuilder()
          .withUrl(
            '$baseUrl/mission-hub?incidentId=$incidentId',
            options: HttpConnectionOptions(
              accessTokenFactory: () async => token,
              transport: HttpTransportType.WebSockets,
            ),
          )
          .withAutomaticReconnect(retryDelays: [0, 2000, 5000, 10000, 30000])
          .build();

      _registerEventHandlers();

      _hubConnection!.onclose(({error}) {
        debugPrint('❌ MissionHub Connection Closed: $error');
        _connectionStateController.add(HubConnectionState.Disconnected);
      });

      _hubConnection!.onreconnecting(({error}) {
        debugPrint('🔄 MissionHub Reconnecting: $error');
        _connectionStateController.add(HubConnectionState.Reconnecting);
      });

      _hubConnection!.onreconnected(({connectionId}) {
        debugPrint('✅ MissionHub Reconnected: $connectionId');
        _connectionStateController.add(HubConnectionState.Connected);
      });

      await _hubConnection!.start();
      _connectionStateController.add(HubConnectionState.Connected);

      debugPrint('✅ Connected to MissionHub');
      debugPrint('📡 Connection ID: ${_hubConnection!.connectionId}');
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to connect to MissionHub: $e');
      debugPrint('Stack trace: $stackTrace');
      _connectionStateController.add(HubConnectionState.Disconnected);
      rethrow;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  /// Register all event handlers from MissionHub
  // ────────────────────────────────────────────────────────────────────────────
  void _registerEventHandlers() {
    // ✅ Joined confirmation
    _hubConnection!.on('JoinedMissionHub', (arguments) {
      try {
        if (arguments == null || arguments.isEmpty) return;
        final data = arguments[0] as Map<String, dynamic>;
        debugPrint('✅ Joined MissionHub');
        debugPrint('   Role   : ${data['role'] ?? data['Role']}');
        debugPrint('   Incident: ${data['incidentId'] ?? data['IncidentId']}');
        debugPrint('   Message : ${data['message'] ?? data['Message']}');
      } catch (e) {
        debugPrint('❌ Error parsing JoinedMissionHub: $e');
      }
    });

    // 🚨 Rescuer accepted the SOS request → mission created
    _hubConnection!.on('RescuerAccepted', (arguments) {
      try {
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('🚨 RESCUER ACCEPTED received!');

        if (arguments == null || arguments.isEmpty) return;
        final data = arguments[0] as Map<String, dynamic>;
        debugPrint('📋 Data: $data');

        final event = RescuerAcceptedData.fromJson(data);
        debugPrint('   Mission ID : ${event.missionId}');
        debugPrint('   Rescuer ID : ${event.rescuerId}');
        debugPrint('   Accepted At: ${event.acceptedAt}');

        _rescuerAcceptedController.add(event);
      } catch (e, stackTrace) {
        debugPrint('❌ Error parsing RescuerAccepted: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    });

    // 📍 Rescuer location update → member map
    _hubConnection!.on('RescuerLocationUpdated', (arguments) {
      try {
        debugPrint('🔔 [MissionHub] RescuerLocationUpdated event received!');
        if (arguments == null || arguments.isEmpty) {
          debugPrint('⚠️ [MissionHub] RescuerLocationUpdated: empty arguments');
          return;
        }
        final data = arguments[0] as Map<String, dynamic>;
        debugPrint('📋 [MissionHub] RescuerLocationUpdated data: $data');

        final loc = RescuerLocationData.fromJson(data);
        debugPrint('📍 LocationUpdated: ${loc.latitude}, ${loc.longitude}');

        _locationUpdatedController.add(loc);
        debugPrint('✅ [MissionHub] Location added to stream');
      } catch (e, stack) {
        debugPrint('❌ Error parsing LocationUpdated: $e');
        debugPrint('Stack trace: $stack');
      }
    });

    // 📍 Member location update (member's live GPS → rescuer map)
    _hubConnection!.on('MemberLocationUpdated', (arguments) {
      try {
        if (arguments == null || arguments.isEmpty) return;
        final data = arguments[0] as Map<String, dynamic>;
        final loc = MemberLocationData.fromJson(data);
        debugPrint(
          '📍 MemberLocationUpdated: ${loc.latitude}, ${loc.longitude}',
        );
        _memberLocationUpdatedController.add(loc);
      } catch (e) {
        debugPrint('❌ Error parsing MemberLocationUpdated: $e');
      }
    });

    // 🎯 Rescuer arrived at scene
    _hubConnection!.on('RescuerArrived', (arguments) {
      try {
        debugPrint('🎯 RescuerArrived!');
        _rescuerArrivedController.add(null);
      } catch (e) {
        debugPrint('❌ Error parsing RescuerArrived: $e');
      }
    });

    // ✅ Mission completed
    _hubConnection!.on('MissionCompleted', (arguments) {
      try {
        if (arguments == null || arguments.isEmpty) {
          _missionCompletedController.add(const MissionCompletedData());
          return;
        }
        final data = arguments[0] as Map<String, dynamic>;
        final event = MissionCompletedData.fromJson(data);
        debugPrint('✅ MissionCompleted: ${event.result}');
        _missionCompletedController.add(event);
      } catch (e) {
        debugPrint('❌ Error parsing MissionCompleted: $e');
      }
    });

    // ❌ Mission cancelled
    _hubConnection!.on('MissionCancelled', (arguments) {
      try {
        if (arguments == null || arguments.isEmpty) {
          _missionCancelledController.add('');
          return;
        }
        final data = arguments[0] as Map<String, dynamic>;
        final reason = (data['reason'] ?? data['Reason']) as String? ?? '';
        debugPrint('❌ MissionCancelled: $reason');
        _missionCancelledController.add(reason);
      } catch (e) {
        debugPrint('❌ Error parsing MissionCancelled: $e');
      }
    });

    // ⏰ Session expired (no rescuer found in time)
    _hubConnection!.on('SessionExpired', (arguments) {
      try {
        debugPrint('⏰ SessionExpired');
        _sessionExpiredController.add(null);
      } catch (e) {
        debugPrint('❌ Error parsing SessionExpired: $e');
      }
    });
  }

  // ────────────────────────────────────────────────────────────────────────────
  /// Send a live GPS update to MissionHub (`UpdateLocation` hub method).
  ///
  /// Works for **both Member and Rescuer** – the backend identifies the caller
  /// via `Context.UserIdentifier` (JWT) and broadcasts the appropriate event:
  ///   • Rescuer → `RescuerLocationUpdated` (member map updates rescuer pin)
  ///   • Member  → `MemberLocationUpdated`  (rescuer map updates member dot)
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> updateLocation(
    String incidentId,
    double latitude,
    double longitude,
  ) async {
    if (_hubConnection == null || !isConnected) {
      debugPrint('⚠️ Cannot update location: Not connected to MissionHub');
      return;
    }
    try {
      debugPrint(
        '📍 Updating location → $latitude, $longitude (incident: $incidentId)',
      );
      await _hubConnection!.invoke(
        'UpdateLocation',
        args: <Object>[incidentId, latitude, longitude],
      );
      debugPrint('✅ Location sent to MissionHub');
    } catch (e) {
      debugPrint('❌ Failed to update location: $e');
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  /// Disconnect from MissionHub
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> disconnect() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔌 Disconnecting from MissionHub...');

      if (_hubConnection != null) {
        await _hubConnection!.stop();
        _hubConnection = null;
      }

      _currentIncidentId = null;
      _connectionStateController.add(HubConnectionState.Disconnected);

      debugPrint('✅ Disconnected from MissionHub');
    } catch (e) {
      debugPrint('❌ Error disconnecting from MissionHub: $e');
    }
  }

  /// Dispose service and close all streams
  void dispose() {
    disconnect();
    _rescuerAcceptedController.close();
    _locationUpdatedController.close();
    _memberLocationUpdatedController.close();
    _rescuerArrivedController.close();
    _missionCompletedController.close();
    _missionCancelledController.close();
    _sessionExpiredController.close();
    _connectionStateController.close();
  }
}
