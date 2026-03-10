import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/services/rescuer_signalr_service.dart';
import '../../../core/services/mission_hub_service.dart';

/// Kết quả kiểm tra GPS trước khi bật chế độ cứu hộ
enum GpsCheckResult {
  /// GPS sẵn sàng hoàn toàn
  ready,

  /// Dịch vụ vị trí đang tắt (người dùng cần bật trong Settings)
  serviceDisabled,

  /// Quyền bị từ chối nhưng có thể xin lại
  permissionDenied,

  /// Quyền bị từ chối vĩnh viễn (cần vào App Settings)
  permissionDeniedForever,
}

class LocationManager {
  final RescuerSignalRService _signalRService;

  // ── Idle tracking (Scenario 1 – RescuerHub) ──────────────────────────────────
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _throttleTimer;
  bool _isThrottled = false;

  // ── Mission tracking (Scenario 2 – MissionHub) ───────────────────────────────
  MissionHubService? _missionHubService;
  String? _missionIncidentId;
  StreamSubscription<Position>? _missionPositionStreamSubscription;
  Timer? _missionThrottleTimer;
  bool _isMissionThrottled = false;

  LocationManager(this._signalRService);

  // ── GPS availability check ────────────────────────────────────────────────────

  /// Kiểm tra dịch vụ GPS + quyền truy cập vị trí.
  ///
  /// Trả về [GpsCheckResult.ready] nếu sẵn sàng.
  /// Các giá trị còn lại cho biết lý do thất bại để UI hiển thị thông báo.
  Future<GpsCheckResult> checkGpsReady() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return GpsCheckResult.serviceDisabled;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return GpsCheckResult.permissionDenied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return GpsCheckResult.permissionDeniedForever;
    }

    return GpsCheckResult.ready;
  }

  // ── Idle tracking (Scenario 1 – RescuerHub) ──────────────────────────────────

  Future<void> startTracking(String userId) async {
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
      distanceFilter: 25, // Idle tracking - less frequent updates OK
    );

    // Prevent duplicate subscriptions and stale throttle state
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;

    _throttleTimer?.cancel();
    _throttleTimer = null;
    _isThrottled = false;

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            _handleNewPosition(userId, position);
          },
          onError: (error) {
            debugPrint("❌ Location stream error for user $userId: $error");
          },
          onDone: () {
            debugPrint("ℹ️ Location stream closed for user $userId");
            _positionStreamSubscription = null;
          },
        );

    debugPrint("LocationManager started tracking for user: $userId");
  }

  void _handleNewPosition(String userId, Position position) {
    if (_isThrottled) return;

    // Send immediately
    _sendIdleLocation(position);

    // Enforce minimum 10-second gap between idle pushes
    _isThrottled = true;
    _throttleTimer = Timer(const Duration(seconds: 10), () {
      _isThrottled = false;
    });
  }

  void _sendIdleLocation(Position position) {
    // Backend identifies rescuer via JWT – no userId argument needed
    _signalRService
        .updateLocation(position.latitude, position.longitude)
        .catchError((error) {
          debugPrint('❌ Failed to push idle location to RescuerHub: $error');
        });
  }

  // ── Mission tracking (Scenario 2 – MissionHub) ───────────────────────────────

  /// Start broadcasting rescuer location to the member during an active mission.
  ///
  /// Call this as soon as the rescuer accepts a request.
  /// [userId]          – for logging only
  /// [incidentId]      – group key on MissionHub
  /// [missionHubSvc]   – connected [MissionHubService] instance
  Future<void> startMissionTracking(
    String userId,
    String incidentId,
    MissionHubService missionHubSvc,
  ) async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📍 [LocationManager] startMissionTracking() called');
    debugPrint('   User ID: $userId');
    debugPrint('   Incident ID: $incidentId');
    debugPrint('   Current mission incident: $_missionIncidentId');
    debugPrint(
      '   Current mission stream active: ${_missionPositionStreamSubscription != null}',
    );
    debugPrint(
      '   Current idle stream active: ${_positionStreamSubscription != null}',
    );

    // Guard against duplicate starts for the same incident
    if (_missionIncidentId == incidentId &&
        _missionPositionStreamSubscription != null) {
      debugPrint(
        '⚠️ [LocationManager] Already tracking mission for incident $incidentId - skipping',
      );
      return;
    }

    // When a mission starts, we ONLY want mission tracking (MissionHub),
    // not idle tracking (RescuerHub). Both streams would compete otherwise.
    debugPrint('⏸️ [LocationManager] Stopping idle tracking for mission...');
    stopTracking();
    debugPrint('✅ [LocationManager] Idle tracking stopped');

    // Stop any previous mission tracking first
    debugPrint(
      '⏸️ [LocationManager] Stopping any previous mission tracking...',
    );
    stopMissionTracking();
    debugPrint('✅ [LocationManager] Previous mission tracking stopped');

    _missionHubService = missionHubSvc;
    _missionIncidentId = incidentId;
    debugPrint('✅ [LocationManager] Mission hub service and incident ID set');

    // Check / request permissions (shared with idle tracking)
    debugPrint('🔐 [LocationManager] Checking location permissions...');
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint(
        '❌ [LocationManager] Location services disabled – cannot start mission tracking',
      );
      return;
    }
    debugPrint('✅ [LocationManager] Location services enabled');

    LocationPermission permission = await Geolocator.checkPermission();
    debugPrint('🔐 [LocationManager] Current permission: $permission');
    if (permission == LocationPermission.denied) {
      debugPrint('🔐 [LocationManager] Requesting permission...');
      permission = await Geolocator.requestPermission();
      debugPrint('🔐 [LocationManager] Permission after request: $permission');
      if (permission == LocationPermission.denied) {
        debugPrint(
          '❌ [LocationManager] Location permission denied – cannot start mission tracking',
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      debugPrint(
        '❌ [LocationManager] Location permission permanently denied – cannot start mission tracking',
      );
      return;
    }
    debugPrint('✅ [LocationManager] Permissions OK');

    debugPrint(
      '📡 [LocationManager] Setting up GPS stream with distanceFilter=15m...',
    );
    const missionLocationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 15,
    );

    _missionPositionStreamSubscription =
        Geolocator.getPositionStream(
          locationSettings: missionLocationSettings,
        ).listen(
          (Position position) {
            debugPrint(
              '📍 [LocationManager] GPS update received: ${position.latitude}, ${position.longitude}',
            );
            _handleNewMissionPosition(incidentId, position);
          },
          onError: (error) {
            debugPrint(
              '❌ [LocationManager] Mission location stream error for $userId: $error',
            );
          },
          onDone: () {
            debugPrint(
              'ℹ️ [LocationManager] Mission location stream closed for $userId',
            );
            _missionPositionStreamSubscription = null;
          },
        );

    debugPrint('✅✅✅ [LocationManager] Mission tracking FULLY STARTED! ✅✅✅');
    debugPrint('   Incident: $incidentId');
    debugPrint('   User: $userId');
    debugPrint(
      '   Stream active: ${_missionPositionStreamSubscription != null}',
    );
    debugPrint(
      '   Hub service connected: ${_missionHubService?.isConnected ?? false}',
    );
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  void _handleNewMissionPosition(String incidentId, Position position) {
    debugPrint('🔄 [LocationManager] _handleNewMissionPosition called');
    debugPrint('   Throttled: $_isMissionThrottled');

    if (_isMissionThrottled) {
      debugPrint('⏭️ [LocationManager] Skipping - throttled');
      return;
    }

    debugPrint('✅ [LocationManager] Processing position update...');
    _sendMissionLocation(incidentId, position);

    _isMissionThrottled = true;
    _missionThrottleTimer = Timer(const Duration(seconds: 12), () {
      debugPrint('🔓 [LocationManager] Throttle released');
      _isMissionThrottled = false;
    });
    debugPrint('🔒 [LocationManager] Throttle engaged for 12s');
  }

  void _sendMissionLocation(String incidentId, Position position) {
    debugPrint(
      '📡 [LocationManager] Sending location to MissionHub: '
      'incident=$incidentId, lat=${position.latitude}, lng=${position.longitude}',
    );
    _missionHubService
        ?.updateLocation(incidentId, position.latitude, position.longitude)
        .then((_) {
          debugPrint('✅ [LocationManager] Location sent successfully');
        })
        .catchError((error) {
          debugPrint('❌ Failed to push mission location to MissionHub: $error');
        });
  }

  /// Stop mission location broadcasting.
  /// Call when mission ends, is cancelled, or the screen is disposed.
  void stopMissionTracking() {
    _missionPositionStreamSubscription?.cancel();
    _missionPositionStreamSubscription = null;
    _missionThrottleTimer?.cancel();
    _missionThrottleTimer = null;
    _isMissionThrottled = false;
    _missionHubService = null;
    _missionIncidentId = null;
    debugPrint('📍 LocationManager: mission tracking stopped');
  }

  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _throttleTimer?.cancel();
    _isThrottled = false;
    // Also stop mission tracking if it was left running
    stopMissionTracking();
    debugPrint('LocationManager: idle tracking stopped');
  }
}
