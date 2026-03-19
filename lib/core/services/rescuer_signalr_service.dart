import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/emergency/models/rescue_request.dart';

/// SignalR Service for Rescuer Emergency Requests
///
/// Maintains persistent connection to RescuerHub for real-time mission notifications
/// Handles connection lifecycle, auto-reconnect, and event listeners
class RescuerSignalRService {
  static RescuerSignalRService? _instance;
  final String baseUrl;

  RescuerSignalRService._internal(this.baseUrl);

  factory RescuerSignalRService({required String baseUrl}) {
    _instance ??= RescuerSignalRService._internal(baseUrl);
    return _instance!;
  }

  HubConnection? _hubConnection;

  // Stream controllers for events
  final _newRequestController = StreamController<RescueRequest>.broadcast();
  final _requestTakenController = StreamController<String>.broadcast();
  final _requestExpiredController = StreamController<String>.broadcast();
  final _requestCancelledController = StreamController<String>.broadcast();
  final _requestAcceptedController =
      StreamController<AcceptRequestResponse>.broadcast();
  final _connectionStateController =
      StreamController<HubConnectionState>.broadcast();
  final _snakeCatchingRequestAssignedController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Completers for pending accept requests (requestId -> Completer)
  final Map<String, Completer<AcceptRequestResponse>> _pendingAccepts = {};

  // Streams for UI to listen
  Stream<RescueRequest> get newRequestStream => _newRequestController.stream;
  Stream<String> get requestTakenStream => _requestTakenController.stream;
  Stream<String> get requestExpiredStream => _requestExpiredController.stream;
  Stream<String> get requestCancelledStream =>
      _requestCancelledController.stream;
  Stream<AcceptRequestResponse> get requestAcceptedStream =>
      _requestAcceptedController.stream;
  Stream<HubConnectionState> get connectionStateStream =>
      _connectionStateController.stream;
  Stream<Map<String, dynamic>> get snakeCatchingRequestAssignedStream =>
      _snakeCatchingRequestAssignedController.stream;

  // Connection state
  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;
  HubConnectionState? get connectionState => _hubConnection?.state;

  String? _currentRescuerId;

  /// Connect to RescuerHub as a rescuer
  ///
  /// [rescuerId] - ID of the rescuer
  Future<void> connectAsRescuer(String rescuerId) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔌 Connecting to RescuerHub...');
      debugPrint('👤 Rescuer ID: $rescuerId');

      // Disconnect existing connection if any
      if (_hubConnection != null) {
        await disconnect();
      }

      _currentRescuerId = rescuerId;

      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('No access token found. Please login first.');
      }

      // Build hub connection
      _hubConnection = HubConnectionBuilder()
          .withUrl(
            '$baseUrl/rescuer-hub',
            options: HttpConnectionOptions(
              accessTokenFactory: () async => token,
              transport: HttpTransportType.WebSockets,
            ),
          )
          .withAutomaticReconnect(
            retryDelays: [0, 2000, 5000, 10000, 30000], // Progressive backoff
          )
          .build();

      // Register event handlers
      _registerEventHandlers();

      // Register connection state handlers
      _hubConnection!.onclose(({error}) {
        debugPrint('❌ SignalR Connection Closed: $error');
        _connectionStateController.add(HubConnectionState.Disconnected);
      });

      _hubConnection!.onreconnecting(({error}) {
        debugPrint('🔄 SignalR Reconnecting: $error');
        _connectionStateController.add(HubConnectionState.Reconnecting);
      });

      _hubConnection!.onreconnected(({connectionId}) {
        debugPrint('✅ SignalR Reconnected: $connectionId');
        _connectionStateController.add(HubConnectionState.Connected);
        // Re-join as rescuer after reconnect
        _joinAsRescuer();
      });

      // Start connection
      await _hubConnection!.start();
      _connectionStateController.add(HubConnectionState.Connected);

      debugPrint('✅ Connected to RescuerHub');
      debugPrint('📡 Connection ID: ${_hubConnection!.connectionId}');

      // Join as rescuer
      await _joinAsRescuer();
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to connect to RescuerHub: $e');
      debugPrint('Stack trace: $stackTrace');
      _connectionStateController.add(HubConnectionState.Disconnected);
      rethrow;
    }
  }

  /// Join as rescuer in the hub
  Future<void> _joinAsRescuer() async {
    if (_currentRescuerId == null) return;

    try {
      debugPrint('📍 Joining as rescuer: $_currentRescuerId');
      await _hubConnection!.invoke(
        'JoinAsRescuer',
        args: <Object>[_currentRescuerId!],
      );
      debugPrint('✅ Joined as rescuer successfully');
    } catch (e) {
      debugPrint('❌ Failed to join as rescuer: $e');
    }
  }

  /// Register all event handlers from hub
  void _registerEventHandlers() {
    // 🚨 NEW RESCUE REQUEST (URGENT!)
    // Note: Backend now sends "DispatchRequested" for operator dispatch flow.
    // We still treat it as a rescue request in the UI.
    _hubConnection!.on('DispatchRequested', (arguments) {
      try {
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('🚨 DISPATCH REQUEST RECEIVED!');

        if (arguments == null || arguments.isEmpty) {
          debugPrint('⚠️ Empty arguments received');
          return;
        }

        final data = arguments[0] as Map<String, dynamic>;
        debugPrint('📋 Dispatch payload: $data');

        // Map dispatch payload to existing RescueRequest model used by the UI
        final dispatchedAt = data['dispatchedAt'] != null
            ? DateTime.parse(data['dispatchedAt'] as String).toUtc()
            : DateTime.now().toUtc();
        final request = RescueRequest(
          requestId: data['requestId'] as String,
          sessionId: data['operatorId'] as String? ?? '',
          incidentId: data['incidentId'] as String,
          // Dispatch requests do not include radius; default to 10km for UI.
          radiusKm: 10.0,
          requestSentAt: dispatchedAt,
          expiredAt: dispatchedAt.add(const Duration(seconds: 60)),
        );

        // 🔍 UTC TIME VALIDATION
        debugPrint('✅ Parsed dispatch request: ${request.requestId}');
        debugPrint('⏰ Expires in: ${request.remainingSeconds}s');
        debugPrint(
          '🌐 DispatchedAt (UTC): ${dispatchedAt.toIso8601String()}',
        );
        debugPrint(
          '🕒 Current time (UTC): ${DateTime.now().toUtc().toIso8601String()}',
        );

        // Broadcast to listeners
        _newRequestController.add(request);
      } catch (e, stackTrace) {
        debugPrint('❌ Error parsing DispatchRequested event: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    });

    // ── Legacy: NEW RESCUE REQUEST (pre-dispatch flow)
    _hubConnection!.on('NewRescueRequest', (arguments) {
      try {
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('🚨 NEW RESCUE REQUEST RECEIVED!');

        if (arguments == null || arguments.isEmpty) {
          debugPrint('⚠️ Empty arguments received');
          return;
        }

        final data = arguments[0] as Map<String, dynamic>;
        debugPrint('📋 Request data: $data');

        final request = RescueRequest.fromJson(data);

        // 🔍 UTC TIME VALIDATION
        debugPrint('✅ Parsed request: ${request.requestId}');
        debugPrint('📍 Radius: ${request.formattedRadius}');
        debugPrint('⏰ Expires in: ${request.remainingSeconds}s');
        debugPrint(
          '🌐 ExpiredAt (UTC): ${request.expiredAt.toUtc().toIso8601String()}',
        );
        debugPrint(
          '🕒 Current time (UTC): ${DateTime.now().toUtc().toIso8601String()}',
        );
        debugPrint('📊 ExpiredAt isUtc: ${request.expiredAt.isUtc}');

        // Broadcast to listeners
        _newRequestController.add(request);
      } catch (e, stackTrace) {
        debugPrint('❌ Error parsing NewRescueRequest: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    });

    // ⚠️ REQUEST TAKEN (by another rescuer)
    _hubConnection!.on('RequestTaken', (arguments) {
      try {
        debugPrint('⚠️ Request taken by another rescuer');

        if (arguments == null || arguments.isEmpty) return;

        final data = arguments[0] as Map<String, dynamic>;
        final requestId = data['requestId'] as String;

        debugPrint('🔒 Request ID: $requestId');
        _requestTakenController.add(requestId);
      } catch (e) {
        debugPrint('❌ Error parsing RequestTaken: $e');
      }
    });

    // ⏰ REQUEST EXPIRED (timeout)
    _hubConnection!.on('RequestExpired', (arguments) {
      try {
        debugPrint('⏰ Request expired (timeout)');

        if (arguments == null || arguments.isEmpty) return;

        final data = arguments[0] as Map<String, dynamic>;
        final requestId = data['requestId'] as String;

        debugPrint('⌛ Request ID: $requestId');
        _requestExpiredController.add(requestId);
      } catch (e) {
        debugPrint('❌ Error parsing RequestExpired: $e');
      }
    });

    // ❌ REQUEST CANCELLED (by user)
    _hubConnection!.on('RequestCancelled', (arguments) {
      try {
        debugPrint('❌ Request cancelled by user');

        if (arguments == null || arguments.isEmpty) return;

        final data = arguments[0] as Map<String, dynamic>;
        final requestId = data['requestId'] as String;

        debugPrint('🚫 Request ID: $requestId');
        _requestCancelledController.add(requestId);
      } catch (e) {
        debugPrint('❌ Error parsing RequestCancelled: $e');
      }
    });

    // ═══════════════════════════════════════════════════════
    // RescuerHub Specific Events (from backend C# hub)
    // ═══════════════════════════════════════════════════════

    // ✅ JOINED confirmation (after JoinAsRescuer call)
    _hubConnection!.on('Joined', (arguments) {
      try {
        if (arguments == null || arguments.isEmpty) return;

        final data = arguments[0] as Map<String, dynamic>;
        debugPrint('✅ Joined RescuerHub successfully');
        debugPrint('   UserId: ${data['userId']}');
        debugPrint('   ConnectionId: ${data['connectionId']}');
        debugPrint('   Message: ${data['message']}');
      } catch (e) {
        debugPrint('❌ Error parsing Joined event: $e');
      }
    });

    // ✅ REQUEST ACCEPTED confirmation (after AcceptRequest call)
    _hubConnection!.on('RequestAccepted', (arguments) {
      try {
        if (arguments == null || arguments.isEmpty) return;

        final data = arguments[0] as Map<String, dynamic>;
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('✅ REQUEST ACCEPTED confirmation from server');
        debugPrint('📋 Request ID: ${data['requestId']}');
        debugPrint('🚑 Incident ID: ${data['incidentId']}');
        debugPrint('📝 Mission ID: ${data['missionId']}');
        debugPrint('⏰ Accepted At: ${data['acceptedAt']}');
        debugPrint('💬 Message: ${data['message']}');

        // Parse response
        final requestId = data['requestId'] as String;
        final response = AcceptRequestResponse(
          isSuccess: true,
          message:
              data['message'] as String? ?? 'Request accepted successfully',
          requestId: requestId,
          incidentId: data['incidentId'] as String?,
          missionId: data['missionId'] as String?,
          acceptedAt: data['acceptedAt'] != null
              ? DateTime.parse(data['acceptedAt'] as String)
              : null,
        );

        // Complete pending request
        final completer = _pendingAccepts.remove(requestId);
        if (completer != null && !completer.isCompleted) {
          completer.complete(response);
          debugPrint('✅ Completed completer for request: $requestId');
        }

        // Broadcast to stream
        _requestAcceptedController.add(response);
      } catch (e, stackTrace) {
        debugPrint('❌ Error parsing RequestAccepted event: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    });

    // ❌ REQUEST ERROR (when AcceptRequest fails)
    _hubConnection!.on('RequestError', (arguments) {
      try {
        if (arguments == null || arguments.isEmpty) return;

        final data = arguments[0] as Map<String, dynamic>;
        final requestId = data['requestId'] as String;
        final error = data['error'] as String;

        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('❌ REQUEST ERROR from server');
        debugPrint('📋 Request ID: $requestId');
        debugPrint('⚠️ Error: $error');

        // Create error response
        final response = AcceptRequestResponse(
          isSuccess: false,
          message: error,
          requestId: requestId,
          error: error,
        );

        // Complete pending request with error
        final completer = _pendingAccepts.remove(requestId);
        if (completer != null && !completer.isCompleted) {
          completer.complete(response);
          debugPrint(
            '✅ Completed completer with error for request: $requestId',
          );
        }
      } catch (e) {
        debugPrint('❌ Error parsing RequestError event: $e');
      }
    });

    // � SNAKE CATCHING REQUEST ASSIGNED (rescuer was assigned a new catching job)
    _hubConnection!.on('SnakeCatchingRequestAssigned', (arguments) {
      try {
        debugPrint('🐍 SnakeCatchingRequestAssigned event received');

        if (arguments == null || arguments.isEmpty) return;

        final data = arguments[0] as Map<String, dynamic>;
        debugPrint('📋 Assigned request data: $data');

        _snakeCatchingRequestAssignedController.add(data);
      } catch (e) {
        debugPrint('❌ Error parsing SnakeCatchingRequestAssigned: $e');
      }
    });

    // �📍 LOCATION UPDATED confirmation
    _hubConnection!.on('LocationUpdated', (arguments) {
      try {
        if (arguments == null || arguments.isEmpty) return;

        final data = arguments[0] as Map<String, dynamic>;
        debugPrint('📍 Location update confirmed');
        debugPrint('   UserId: ${data['userId']}');
        debugPrint('   Lat: ${data['latitude']}, Lng: ${data['longitude']}');
      } catch (e) {
        debugPrint('❌ Error parsing LocationUpdated event: $e');
      }
    });

    // 👥 CONNECTED RESCUERS list
    _hubConnection!.on('ConnectedRescuers', (arguments) {
      try {
        if (arguments == null || arguments.isEmpty) return;

        final data = arguments[0] as Map<String, dynamic>;
        final count = data['count'] as int;
        final rescuerIds = (data['rescuerIds'] as List?)?.cast<String>() ?? [];

        debugPrint('👥 Connected rescuers: $count');
        debugPrint('   IDs: ${rescuerIds.join(', ')}');
      } catch (e) {
        debugPrint('❌ Error parsing ConnectedRescuers event: $e');
      }
    });
  }

  /// Accept a rescue request
  ///
  /// Invokes AcceptRequest on backend and waits for RequestAccepted/RequestError event
  /// Backend sends response via SignalR event instead of return value
  Future<AcceptRequestResponse> acceptRequest(
    String requestId,
    String rescuerId,
  ) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('✅ Accepting dispatch request...');
      debugPrint('📋 Request ID: $requestId');
      debugPrint('👤 Rescuer ID: $rescuerId');

      if (_hubConnection == null || !isConnected) {
        return AcceptRequestResponse(
          isSuccess: false,
          message: 'Not connected to server',
          error: 'SignalR connection not established',
        );
      }

      // Create completer to wait for RequestAccepted/RequestError event
      final completer = Completer<AcceptRequestResponse>();
      _pendingAccepts[requestId] = completer;
      debugPrint('📝 Created completer for request: $requestId');

      try {
        // Invoke AcceptDispatchRequest method on hub (no return value expected)
        await _hubConnection!.invoke(
          'AcceptDispatchRequest',
          args: <Object>[requestId],
        );

        debugPrint('✅ AcceptDispatchRequest invoked, waiting for response event...');

        // Wait for RequestAccepted or RequestError event (20 second timeout)
        final response = await completer.future.timeout(
          const Duration(seconds: 20),
          onTimeout: () {
            debugPrint('⏰ Timeout waiting for RequestAccepted event');
            return AcceptRequestResponse(
              isSuccess: false,
              message: 'Timeout: Backend không phản hồi trong 20 giây',
              error: 'TIMEOUT',
              requestId: requestId,
            );
          },
        );

        debugPrint('✅ Received response from event');
        debugPrint('   Success: ${response.isSuccess}');
        debugPrint('   Mission ID: ${response.missionId}');
        debugPrint('   Incident ID: ${response.incidentId}');

        return response;
      } finally {
        // Clean up completer if still pending
        _pendingAccepts.remove(requestId);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to accept request: $e');
      debugPrint('Stack trace: $stackTrace');

      // Clean up completer
      _pendingAccepts.remove(requestId);

      // Check if it's a race condition error
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('already') ||
          errorMessage.contains('taken') ||
          errorMessage.contains('accepted')) {
        return AcceptRequestResponse(
          isSuccess: false,
          message: 'Nhiệm vụ đã được nhận bởi người khác',
          error: 'RACE_CONDITION',
          requestId: requestId,
        );
      }

      return AcceptRequestResponse(
        isSuccess: false,
        message: 'Không thể nhận nhiệm vụ. Vui lòng thử lại.',
        error: e.toString(),
        requestId: requestId,
      );
    }
  }

  /// Decline a dispatch request
  ///
  /// Backend method signature: `DeclineDispatchRequest(string requestId, string reason)`
  Future<AcceptRequestResponse> declineDispatchRequest(
    String requestId,
    String reason,
  ) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ Declining dispatch request...');
      debugPrint('📋 Request ID: $requestId');
      debugPrint('💬 Reason: $reason');

      if (_hubConnection == null || !isConnected) {
        return AcceptRequestResponse(
          isSuccess: false,
          message: 'Not connected to server',
          error: 'SignalR connection not established',
          requestId: requestId,
        );
      }

      await _hubConnection!.invoke(
        'DeclineDispatchRequest',
        args: <Object>[requestId, reason],
      );

      return AcceptRequestResponse(
        isSuccess: true,
        message: 'Declined',
        requestId: requestId,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to decline request: $e');
      debugPrint('Stack trace: $stackTrace');

      return AcceptRequestResponse(
        isSuccess: false,
        message: 'Failed to decline request',
        error: e.toString(),
        requestId: requestId,
      );
    }
  }

  /// Update rescuer idle location (Scenario 1 – RescuerHub)
  ///
  /// Backend method signature: `UpdateLocation(double latitude, double longitude)`
  /// The user identity is taken from JWT – no userId argument needed.
  /// Used for PostGIS radius search when a new SOS incident occurs.
  /// Frequency guideline: every 30-60 s or after 25 m movement.
  Future<void> updateLocation(double latitude, double longitude) async {
    if (_hubConnection == null || !isConnected) {
      debugPrint('⚠️ Cannot update idle location: Not connected');
      return;
    }

    try {
      debugPrint('📍 [Idle] Updating location → $latitude, $longitude');

      await _hubConnection!.invoke(
        'UpdateLocation',
        args: <Object>[latitude, longitude],
      );

      debugPrint('✅ Idle location sent to RescuerHub');
    } catch (e) {
      debugPrint('❌ Failed to update idle location: $e');
    }
  }

  /// Disconnect from hub
  Future<void> disconnect() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔌 Disconnecting from RescuerHub...');

      if (_hubConnection != null) {
        await _hubConnection!.stop();
        _hubConnection = null;
      }

      _currentRescuerId = null;
      _connectionStateController.add(HubConnectionState.Disconnected);

      debugPrint('✅ Disconnected from RescuerHub');
    } catch (e) {
      debugPrint('❌ Error disconnecting: $e');
    }
  }

  /// Reconnect to hub (useful after network reconnection)
  Future<void> reconnect() async {
    if (_currentRescuerId == null) {
      debugPrint('⚠️ Cannot reconnect: No rescuer ID stored');
      return;
    }

    debugPrint('🔄 Attempting to reconnect...');
    await disconnect();
    await connectAsRescuer(_currentRescuerId!);
  }

  /// Check connection health
  Future<bool> checkHealth() async {
    if (_hubConnection == null || !isConnected) {
      return false;
    }

    try {
      // Try to invoke a ping method if backend supports it
      // Otherwise just check connection state
      return isConnected;
    } catch (e) {
      debugPrint('❌ Health check failed: $e');
      return false;
    }
  }

  /// Dispose service and close streams
  /// Dispose service and close streams
  void dispose() {
    disconnect();
    _newRequestController.close();
    _requestTakenController.close();
    _requestExpiredController.close();
    _requestCancelledController.close();
    _requestAcceptedController.close();
    _connectionStateController.close();
    _snakeCatchingRequestAssignedController.close();
  }
}
