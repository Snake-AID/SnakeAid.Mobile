import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../models/Class.dart';
import '../repository/signalr_repository.dart';
import 'dart:async';

// Repository provider
final signalRRepositoryProvider = Provider<SignalRRepository>((ref) {
  final repo = SignalRRepository();
  ref.onDispose(() => repo.dispose());
  return repo;
});

// User info state
class UserInfo {
  final String userId;
  final String userName;

  UserInfo({required this.userId, required this.userName});
}

final userInfoProvider = StateProvider<UserInfo>((ref) {
  const uuid = Uuid();
  return UserInfo(
    userId: uuid.v4(),
    userName: 'User_${DateTime.now().millisecondsSinceEpoch % 10000}',
  );
});

// Connection state notifier
class SignalRConnectionNotifier extends StateNotifier<UserConnectionState> {
  final SignalRRepository _repository;
  StreamSubscription? _connectionSubscription;

  SignalRConnectionNotifier(this._repository)
    : super(UserConnectionState.disconnected) {
    _connectionSubscription = _repository.connectionState.listen((
      connectionState,
    ) {
      state = connectionState;
    });
  }

  Future<void> connect() async {
    await _repository.initializeConnection();
  }

  Future<void> disconnect() async {
    await _repository.disconnect();
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    super.dispose();
  }
}

final connectionStateProvider =
    StateNotifierProvider<SignalRConnectionNotifier, UserConnectionState>((
      ref,
    ) {
      final repository = ref.watch(signalRRepositoryProvider);
      return SignalRConnectionNotifier(repository);
    });

// Messages state
final messagesProvider = StreamProvider<List<MessageData>>((ref) {
  final repository = ref.watch(signalRRepositoryProvider);
  final messages = <MessageData>[];

  return repository.messages.map((message) {
    messages.add(message);
    return List<MessageData>.from(messages);
  });
});

// Users list state
final userListProvider = StreamProvider<List<String>>((ref) {
  final repository = ref.watch(signalRRepositoryProvider);
  return repository.userList;
});

// Location updates state
final locationUpdatesProvider = StreamProvider<List<UserLocationData>>((ref) {
  final repository = ref.watch(signalRRepositoryProvider);
  final locations = <String, UserLocationData>{};

  return repository.locationUpdates.map((location) {
    locations[location.userId] = location;
    return locations.values.toList();
  });
});

// Latest user locations (from BroadcastLatestLocations)
final latestUserLocationsProvider = StreamProvider<List<UserLocationData>>((
  ref,
) {
  final repository = ref.watch(signalRRepositoryProvider);
  return repository.latestUserLocations;
});

// Other user locations (when user joins)
final otherUserLocationsProvider = StreamProvider<List<UserLocationData>>((
  ref,
) {
  final repository = ref.watch(signalRRepositoryProvider);
  return repository.otherUserLocations;
});

// Current location provider
final currentLocationProvider = StateProvider<Position?>((ref) => null);

// Location service notifier
class LocationServiceNotifier extends StateNotifier<bool> {
  LocationServiceNotifier(this._ref) : super(false) {
    _listenToLocationRequests();
  }

  final Ref _ref;
  Timer? _locationTimer;
  StreamSubscription? _locationRequestSubscription;

  void _listenToLocationRequests() {
    // Listen for location update requests from other users
    final repository = _ref.read(signalRRepositoryProvider);
    // This would need to be implemented as a separate stream in repository
  }

  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await openAppSettings();
      return false;
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Start sending location every 5 seconds (for testing)
  void startLocationSharing() {
    if (state) return; // Already started

    state = true;
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _sendCurrentLocation();
    });

    // Send initial location immediately
    _sendCurrentLocation();
  }

  // Send location immediately when user moves significantly
  void startLocationTracking() {
    if (state) return;

    state = true;

    // Send initial location
    _sendCurrentLocation();

    // Listen to position changes (when user moves > 10 meters)
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Only update when moved > 10 meters
      ),
    ).listen((Position position) {
      _sendLocationUpdate(position);
    });
  }

  Future<void> _sendCurrentLocation() async {
    try {
      final position = await getCurrentLocation();
      if (position != null) {
        await _sendLocationUpdate(position);
      }
    } catch (e) {
      print('Error sending current location: $e');
    }
  }

  Future<void> _sendLocationUpdate(Position position) async {
    try {
      final repository = _ref.read(signalRRepositoryProvider);
      final userInfo = _ref.read(userInfoProvider);

      await repository.updateLocation(
        userInfo.userId,
        userInfo.userName,
        position.latitude,
        position.longitude,
      );

      print(
        'Location update sent: ${position.latitude}, ${position.longitude}',
      );
    } catch (e) {
      print('Error sending location update: $e');
    }
  }

  // Request location from other user
  Future<void> requestLocationFromUser(String userId) async {
    try {
      final repository = _ref.read(signalRRepositoryProvider);
      await repository.requestLocationUpdate(userId);
    } catch (e) {
      print('Error requesting location from user: $e');
    }
  }

  // Broadcast latest locations to all users
  Future<void> broadcastLatestLocations() async {
    try {
      final repository = _ref.read(signalRRepositoryProvider);
      await repository.broadcastLatestLocations();
    } catch (e) {
      print('Error broadcasting latest locations: $e');
    }
  }

  void stopLocationSharing() {
    state = false;
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  @override
  void dispose() {
    stopLocationSharing();
    _locationRequestSubscription?.cancel();
    super.dispose();
  }
}

final locationServiceProvider =
    StateNotifierProvider<LocationServiceNotifier, bool>((ref) {
      return LocationServiceNotifier(ref);
    });

// Error messages state
final errorMessagesProvider = StreamProvider<String>((ref) {
  final repository = ref.watch(signalRRepositoryProvider);
  return repository.errors;
});
