import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RescuerSignalRService {
  HubConnection? _hubConnection;
  final String baseUrl;

  // Events
  Function(Map<String, dynamic>)? onJoined;
  Function(Map<String, dynamic>)? onNewRescueRequest;
  Function(Map<String, dynamic>)? onRequestAccepted;
  Function(Map<String, dynamic>)? onRequestTaken;
  Function(Map<String, dynamic>)? onRequestCancelled;
  Function(Map<String, dynamic>)? onRequestRejected;
  Function(Map<String, dynamic>)? onRequestError;
  Function(Map<String, dynamic>)? onLocationUpdated;
  Function(Exception?)? onClosed;

  RescuerSignalRService({required this.baseUrl});

  Future<void> connect() async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString('auth_token') ?? prefs.getString('access_token');

    if (token == null) {
      throw Exception("Unauthorized: No access token found");
    }

    final hubUrl = "$baseUrl/rescuer-hub";

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(accessTokenFactory: () async => token),
        )
        .withAutomaticReconnect()
        .build();

    _hubConnection?.onclose(({Exception? error}) {
      debugPrint("SignalR Connection Closed: $error");
      if (onClosed != null) onClosed!(error);
    });

    _hubConnection?.on("Joined", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map<String, dynamic>;
        debugPrint("SignalR Joined: ${data['message']}");
        if (onJoined != null) onJoined!(data);
      }
    });

    _hubConnection?.on("NewRescueRequest", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final data = arguments[0] as Map<String, dynamic>;
        debugPrint("SignalR NewRescueRequest: $data");
        if (onNewRescueRequest != null) onNewRescueRequest!(data);
      }
    });

    _hubConnection?.on("LocationUpdated", (arguments) {
      debugPrint("SignalR Location ack received from server");
      if (arguments != null &&
          arguments.isNotEmpty &&
          onLocationUpdated != null) {
        onLocationUpdated!(arguments[0] as Map<String, dynamic>);
      }
    });

    // Other events
    _hubConnection?.on(
      "RequestAccepted",
      (args) => _handleMapEvent(args, onRequestAccepted),
    );
    _hubConnection?.on(
      "RequestTaken",
      (args) => _handleMapEvent(args, onRequestTaken),
    );
    _hubConnection?.on(
      "RequestCancelled",
      (args) => _handleMapEvent(args, onRequestCancelled),
    );
    _hubConnection?.on(
      "RequestRejected",
      (args) => _handleMapEvent(args, onRequestRejected),
    );
    _hubConnection?.on(
      "RequestError",
      (args) => _handleMapEvent(args, onRequestError),
    );

    await _hubConnection?.start();
    debugPrint("SignalR Connected: ${_hubConnection?.state}");
  }

  void _handleMapEvent(
    List<Object?>? args,
    Function(Map<String, dynamic>)? callback,
  ) {
    if (args != null && args.isNotEmpty && callback != null) {
      callback(args[0] as Map<String, dynamic>);
    }
  }

  Future<void> disconnect() async {
    await _hubConnection?.stop();
    _hubConnection = null;
    debugPrint("SignalR Disconnected");
  }

  // LT-1: Send Location
  Future<void> updateLocation(String userId, double lat, double lng) async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      debugPrint("SignalR Sending location: $lat, $lng");
      await _hubConnection?.invoke("UpdateLocation", args: [userId, lat, lng]);
    } else {
      debugPrint("SignalR Cannot send location: Disconnected from Hub");
    }
  }

  Future<void> joinAsRescuer(String userId) async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      await _hubConnection?.invoke("JoinAsRescuer", args: [userId]);
    } else {
      debugPrint("SignalR Cannot join: Disconnected from Hub");
    }
  }
}
