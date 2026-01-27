import 'dart:async';
import 'dart:convert';
import 'package:signalr_netcore/signalr_client.dart';
import '../models/Class.dart';

class SignalRRepository {
  HubConnection? _hubConnection;
  final String _hubUrl =
      'http://192.168.88.138:5009/chat-hub'; // Android emulator
  // final String _hubUrl = 'http://localhost:5000/testchathub'; // iOS simulator

  final StreamController<UserConnectionState> _connectionStateController =
      StreamController<UserConnectionState>.broadcast();
  final StreamController<List<String>> _userListController =
      StreamController<List<String>>.broadcast();
  final StreamController<MessageData> _messageController =
      StreamController<MessageData>.broadcast();
  final StreamController<UserLocationData> _locationController =
      StreamController<UserLocationData>.broadcast();
  final StreamController<List<UserLocationData>> _allLocationsController =
      StreamController<List<UserLocationData>>.broadcast();
  final StreamController<List<UserLocationData>> _latestLocationsController =
      StreamController<List<UserLocationData>>.broadcast();
  final StreamController<List<UserLocationData>> _otherLocationsController =
      StreamController<List<UserLocationData>>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  // Streams
  Stream<UserConnectionState> get connectionState =>
      _connectionStateController.stream;
  Stream<List<String>> get userList => _userListController.stream;
  Stream<MessageData> get messages => _messageController.stream;
  Stream<UserLocationData> get locationUpdates => _locationController.stream;
  Stream<List<UserLocationData>> get allLocations =>
      _allLocationsController.stream;
  Stream<List<UserLocationData>> get latestUserLocations =>
      _latestLocationsController.stream;
  Stream<List<UserLocationData>> get otherUserLocations =>
      _otherLocationsController.stream;
  Stream<String> get errors => _errorController.stream;

  Future<void> initializeConnection() async {
    if (_hubConnection != null) {
      await disconnect();
    }

    _connectionStateController.add(UserConnectionState.connecting);

    _hubConnection = HubConnectionBuilder()
        .withUrl(_hubUrl)
        .withAutomaticReconnect()
        .build();

    // Setup event handlers
    _setupEventHandlers();

    try {
      await _hubConnection!.start();
      _connectionStateController.add(UserConnectionState.connected);
      print('SignalR Connected successfully');
    } catch (e) {
      _connectionStateController.add(UserConnectionState.disconnected);
      _errorController.add('Connection failed: ${e.toString()}');
      print('SignalR Connection failed: $e');
    }
  }

  void _setupEventHandlers() {
    if (_hubConnection == null) return;

    // Connection state changes
    _hubConnection!.onclose(({error}) {
      _connectionStateController.add(UserConnectionState.disconnected);
      print('SignalR Connection closed');
    });

    _hubConnection!.onreconnecting(({error}) {
      _connectionStateController.add(UserConnectionState.reconnecting);
      print('SignalR Reconnecting...');
    });

    _hubConnection!.onreconnected(({connectionId}) {
      _connectionStateController.add(UserConnectionState.connected);
      print('SignalR Reconnected');
    });

    // Message handlers
    _hubConnection!.on('ReceiveMessage', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final messageData = MessageData.fromJson(
            arguments[0] as Map<String, dynamic>,
          );
          _messageController.add(messageData);
        } catch (e) {
          print('Error parsing message: $e');
        }
      }
    });

    _hubConnection!.on('UpdateUserList', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final users = List<String>.from(arguments[0] as List);
        _userListController.add(users);
      }
    });

    _hubConnection!.on('LocationUpdated', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final locationData = UserLocationData.fromJson(
            arguments[0] as Map<String, dynamic>,
          );
          _locationController.add(locationData);
        } catch (e) {
          print('Error parsing location: $e');
        }
      }
    });

    _hubConnection!.on('AllLocations', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final locations = (arguments[0] as List)
              .map(
                (loc) => UserLocationData.fromJson(loc as Map<String, dynamic>),
              )
              .toList();
          _allLocationsController.add(locations);
        } catch (e) {
          print('Error parsing all locations: $e');
        }
      }
    });

    _hubConnection!.on('LatestUserLocations', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final data = arguments[0] as Map<String, dynamic>;
          final locations = (data['locations'] as List)
              .map(
                (loc) => UserLocationData.fromJson(loc as Map<String, dynamic>),
              )
              .toList();
          _latestLocationsController.add(locations);
          print('Received latest locations for ${locations.length} users');
        } catch (e) {
          print('Error parsing latest locations: $e');
        }
      }
    });

    _hubConnection!.on('OtherUserLocations', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final data = arguments[0] as Map<String, dynamic>;
          final locations = (data['locations'] as List)
              .map(
                (loc) => UserLocationData.fromJson(loc as Map<String, dynamic>),
              )
              .toList();
          _otherLocationsController.add(locations);
          print('Received locations of ${locations.length} other users');
        } catch (e) {
          print('Error parsing other user locations: $e');
        }
      }
    });

    _hubConnection!.on('LocationUpdateRequested', (arguments) {
      print('Location update requested by another user');
      // Auto send current location when requested
      // This will be handled by the location service
    });

    _hubConnection!.on('Error', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        _errorController.add(arguments[0].toString());
      }
    });

    _hubConnection!.on('JoinedSuccessfully', (arguments) {
      print('Joined successfully');
    });

    _hubConnection!.on('Pong', (arguments) {
      print('Pong received at: ${arguments?[0]}');
    });
  }

  Future<void> joinChat(String userId, String userName) async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      try {
        await _hubConnection!.invoke('JoinChat', args: [userId, userName]);

        // Request immediate update of user list and locations after joining
        await Future.delayed(const Duration(milliseconds: 500));
        await getAllLocations();

        print('Joined chat successfully: $userId - $userName');
      } catch (e) {
        _errorController.add('Failed to join chat: ${e.toString()}');
        print('Failed to join chat: $e');
      }
    }
  }

  Future<void> sendMessage(
    String userId,
    String userName,
    String message,
  ) async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      try {
        await _hubConnection!.invoke(
          'SendMessageToAll',
          args: [userId, userName, message],
        );
      } catch (e) {
        _errorController.add('Failed to send message: ${e.toString()}');
      }
    }
  }

  Future<void> updateLocation(
    String userId,
    String userName,
    double latitude,
    double longitude,
  ) async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      try {
        await _hubConnection!.invoke(
          'UpdateLocation',
          args: [userId, userName, latitude, longitude],
        );
        print('Location sent: $latitude, $longitude');
      } catch (e) {
        _errorController.add('Failed to update location: ${e.toString()}');
        print('Error sending location: $e');
      }
    }
  }

  Future<void> getAllLocations() async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      try {
        await _hubConnection!.invoke('GetAllLocations');
        print('Requested all locations');
      } catch (e) {
        _errorController.add('Failed to get all locations: ${e.toString()}');
        print('Failed to get all locations: $e');
      }
    }
  }

  Future<void> requestUserList() async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      try {
        await _hubConnection!.invoke('GetConnectedUsers');
        print('Requested user list');
      } catch (e) {
        _errorController.add('Failed to request user list: ${e.toString()}');
        print('Failed to request user list: $e');
      }
    }
  }

  Future<void> broadcastLatestLocations() async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      try {
        await _hubConnection!.invoke('BroadcastLatestLocations');
        print('Requested broadcast of latest locations');
      } catch (e) {
        _errorController.add(
          'Failed to broadcast latest locations: ${e.toString()}',
        );
        print('Failed to broadcast latest locations: $e');
      }
    }
  }

  Future<void> requestLocationUpdate(String userId) async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      try {
        await _hubConnection!.invoke('RequestLocationUpdate', args: [userId]);
        print('Requested location update from user: $userId');
      } catch (e) {
        _errorController.add(
          'Failed to request location update: ${e.toString()}',
        );
        print('Failed to request location update: $e');
      }
    }
  }

  Future<void> ping() async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      try {
        await _hubConnection!.invoke('Ping');
      } catch (e) {
        _errorController.add('Failed to ping: ${e.toString()}');
      }
    }
  }

  Future<void> disconnect() async {
    if (_hubConnection != null) {
      await _hubConnection!.stop();
      _hubConnection = null;
      _connectionStateController.add(UserConnectionState.disconnected);
    }
  }

  void dispose() {
    _connectionStateController.close();
    _userListController.close();
    _messageController.close();
    _locationController.close();
    _allLocationsController.close();
    _latestLocationsController.close();
    _otherLocationsController.close();
    _errorController.close();
  }
}
