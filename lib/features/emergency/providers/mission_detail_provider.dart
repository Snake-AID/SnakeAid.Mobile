import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/rescue_mission_response.dart';
import '../models/route_navigation_data.dart';
import '../repository/rescue_mission_repository.dart';
import '../../../core/utils/distance_utils.dart';

/// Mission detail state
class MissionDetailState {
  final DetailRescueMissionResponse? mission;
  final bool isLoading;
  final String? error;
  final Position? rescuerLocation;
  final double? distanceKm;
  final int? etaMinutes;
  final bool isUpdatingStatus;
  final RouteNavigationData? routeData; // Route from OpenRouteService

  MissionDetailState({
    this.mission,
    this.isLoading = false,
    this.error,
    this.rescuerLocation,
    this.distanceKm,
    this.etaMinutes,
    this.isUpdatingStatus = false,
    this.routeData,
  });

  MissionDetailState copyWith({
    DetailRescueMissionResponse? mission,
    bool? isLoading,
    String? error,
    Position? rescuerLocation,
    double? distanceKm,
    int? etaMinutes,
    bool? isUpdatingStatus,
    RouteNavigationData? routeData,
  }) {
    return MissionDetailState(
      mission: mission ?? this.mission,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      rescuerLocation: rescuerLocation ?? this.rescuerLocation,
      distanceKm: distanceKm ?? this.distanceKm,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      isUpdatingStatus: isUpdatingStatus ?? this.isUpdatingStatus,
      routeData: routeData ?? this.routeData,
    );
  }

  // Clear error
  MissionDetailState clearError() {
    return copyWith(error: '');
  }
}

/// Mission detail notifier
class MissionDetailNotifier extends StateNotifier<MissionDetailState> {
  final RescueMissionRepository _repository;

  MissionDetailNotifier(this._repository) : super(MissionDetailState());

  /// Load mission details with optional rescuer location
  Future<void> loadMissionDetail({
    required String missionId,
    Position? rescuerLocation,
  }) async {
    state = state.copyWith(isLoading: true, error: '');

    try {
      final mission = await _repository.getMissionDetail(
        missionId: missionId,
        rescuerLat: rescuerLocation?.latitude,
        rescuerLng: rescuerLocation?.longitude,
      );

      // Calculate distance if mission has location and rescuer location available
      double? distance;
      int? eta;

      if (rescuerLocation != null) {
        distance = DistanceUtils.calculateDistance(
          lat1: rescuerLocation.latitude,
          lon1: rescuerLocation.longitude,
          lat2: mission.incident.locationCoordinates.latitude,
          lon2: mission.incident.locationCoordinates.longitude,
        );
        eta = DistanceUtils.estimateETA(distance);
      }

      state = MissionDetailState(
        mission: mission,
        isLoading: false,
        rescuerLocation: rescuerLocation,
        distanceKm: distance,
        etaMinutes: eta,
        routeData: state.routeData, // Preserve routeData
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Update rescuer location and recalculate distance/ETA
  void updateRescuerLocation(Position position) {
    if (state.mission == null) return;

    final distance = DistanceUtils.calculateDistance(
      lat1: position.latitude,
      lon1: position.longitude,
      lat2: state.mission!.incident.locationCoordinates.latitude,
      lon2: state.mission!.incident.locationCoordinates.longitude,
    );

    final eta = DistanceUtils.estimateETA(distance);

    state = state.copyWith(
      rescuerLocation: position,
      distanceKm: distance,
      etaMinutes: eta,
    );
  }

  /// Set route data from OpenRouteService
  void setRouteData(RouteNavigationData routeData) {
    state = state.copyWith(routeData: routeData);
  }

  /// Start mission (Preparing → EnRoute)
  Future<bool> startMission() async {
    if (state.mission == null) return false;

    state = state.copyWith(isUpdatingStatus: true, error: '');

    try {
      await _repository.startMission(state.mission!.id);

      // Reload mission to get updated status
      await loadMissionDetail(
        missionId: state.mission!.id,
        rescuerLocation: state.rescuerLocation,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdatingStatus: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Mark arrival (EnRoute → RescuerArrived)
  Future<bool> markArrival() async {
    if (state.mission == null) return false;

    state = state.copyWith(isUpdatingStatus: true, error: '');

    try {
      await _repository.arriveAtLocation(state.mission!.id);

      // Reload mission to get updated status
      await loadMissionDetail(
        missionId: state.mission!.id,
        rescuerLocation: state.rescuerLocation,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdatingStatus: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Complete mission with evidence photos (RescuerArrived → MissionCompleted)
  Future<bool> completeMission({
    required List<String> evidenceMediaIds,
    String? completionNotes,
  }) async {
    if (state.mission == null) return false;

    state = state.copyWith(isUpdatingStatus: true, error: '');

    try {
      await _repository.completeMission(
        missionId: state.mission!.id,
        evidenceMediaIds: evidenceMediaIds,
        completionNotes: completionNotes,
      );

      // Reload mission to get updated status
      await loadMissionDetail(
        missionId: state.mission!.id,
        rescuerLocation: state.rescuerLocation,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdatingStatus: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Abort mission with reason
  Future<bool> abortMission(String reason) async {
    if (state.mission == null) return false;

    state = state.copyWith(isUpdatingStatus: true, error: '');

    try {
      await _repository.abortMission(
        missionId: state.mission!.id,
        reason: reason,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdatingStatus: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    state = state.clearError();
  }

  /// Refresh mission data
  Future<void> refresh() async {
    if (state.mission == null) return;

    await loadMissionDetail(
      missionId: state.mission!.id,
      rescuerLocation: state.rescuerLocation,
    );
  }
}

/// Provider for mission detail
final missionDetailProvider =
    StateNotifierProvider.autoDispose<
      MissionDetailNotifier,
      MissionDetailState
    >((ref) {
      final repository = ref.watch(rescueMissionRepositoryProvider);
      return MissionDetailNotifier(repository);
    });
