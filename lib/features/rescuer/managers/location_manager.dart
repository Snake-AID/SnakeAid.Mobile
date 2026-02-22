import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/services/rescuer_signalr_service.dart';

class LocationManager {
  final RescuerSignalRService _signalRService;
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _throttleTimer;
  bool _isThrottled = false;

  LocationManager(this._signalRService);

  Future<void> startTracking(String userId) async {
    // Check permissions first
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint("Location permissions are denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint("Location permissions are permanently denied.");
      return;
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Only push if moved 10 meters
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            _handleNewPosition(userId, position);
          },
        );

    debugPrint("LocationManager started tracking for user: $userId");
  }

  void _handleNewPosition(String userId, Position position) {
    if (_isThrottled) return;

    // Send immediately
    _sendLocation(userId, position);

    // Enable throttle for 10 seconds (LT-1 Server Threshold)
    _isThrottled = true;
    _throttleTimer = Timer(const Duration(seconds: 10), () {
      _isThrottled = false;
    });
  }

  void _sendLocation(String userId, Position position) {
    _signalRService.updateLocation(
      userId,
      position.latitude,
      position.longitude,
    );
  }

  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _throttleTimer?.cancel();
    _isThrottled = false;
    debugPrint("LocationManager stopped tracking");
  }
}
