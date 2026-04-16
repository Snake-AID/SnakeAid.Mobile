import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/rescue_mission_response.dart';
import '../repository/rescue_mission_repository.dart';

/// Active Mission State
class ActiveMissionState {
  final BasicRescueMissionResponse? mission;
  final bool isLoading;
  final String? error;

  ActiveMissionState({this.mission, this.isLoading = false, this.error});

  ActiveMissionState copyWith({
    BasicRescueMissionResponse? mission,
    bool? isLoading,
    String? error,
    bool clearMission = false,
  }) {
    return ActiveMissionState(
      mission: clearMission ? null : (mission ?? this.mission),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasActiveMission => mission != null;
  String? get activeMissionId => mission?.missionId;
}

/// Active Mission Notifier
class ActiveMissionNotifier extends StateNotifier<ActiveMissionState> {
  final RescueMissionRepository missionRepository;
  static const String _activeMissionKey = 'active_rescue_mission';
  static const String _activeMissionIdKey = 'active_rescue_mission_id';

  /// Mission statuses that mean the mission is over and should NOT be cached.
  /// Mission statuses that mean the mission is over and should NOT be cached.
  ///
  /// Normalize all status comparisons to lower-case to support legacy
  /// and current status naming (API may return "MissionCompleted", while
  /// some checks may use "completed" / "missionCompleted").
  static const _terminalStatuses = {
    'missioncompleted',
    'completed',
    'missionuncompleted',
    'uncompleted',
    'missionaborted',
    'aborted',
    'cancelled',
    'expired',
    'failed',
  };

  static bool _isTerminal(String status) {
    return _terminalStatuses.contains(status.trim().toLowerCase());
  }

  ActiveMissionNotifier({required this.missionRepository})
    : super(ActiveMissionState()) {
    _loadActiveMission();
  }

  /// Load active mission from local storage and verify with server
  Future<void> _loadActiveMission() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final missionJson = prefs.getString(_activeMissionKey);

      if (missionJson != null) {
        final missionMap = jsonDecode(missionJson) as Map<String, dynamic>;
        final mission = BasicRescueMissionResponse.fromJson(missionMap);

        debugPrint('📋 Found cached mission: ${mission.missionId}');

        // Verify mission still exists on server
        try {
          final detailedMission = await missionRepository.getMissionDetail(
            missionId: mission.missionId,
          );

          // Mission exists on server - check if it's terminal
          if (_isTerminal(detailedMission.missionStatus.name)) {
            debugPrint(
              '🏁 Cached mission is terminal (${detailedMission.missionStatus.name}) – auto-clearing',
            );
            await clearActiveMission();
          } else {
            // Update mission data from server
            final updatedBasicMission = BasicRescueMissionResponse(
              missionId: detailedMission.id,
              incidentId: detailedMission.incident.id,
              status: detailedMission.status,
              startedAt: detailedMission.startedAt,
              acceptedAt: detailedMission.createdAt,
            );
            await saveActiveMission(updatedBasicMission);
            debugPrint('✅ Mission verified and updated from server');
            debugPrint('📋 Status: ${detailedMission.status}');
          }
        } catch (e) {
          final errorMsg = e.toString();

          // Check if mission doesn't exist (404 or not found error)
          if (errorMsg.contains('Không tìm thấy') ||
              errorMsg.contains('404') ||
              errorMsg.contains('not found')) {
            // Mission was deleted - clear local storage
            debugPrint('🗑️ Mission deleted on server - clearing local cache');
            await clearActiveMission();
          } else if (errorMsg.contains('Không thể kết nối') ||
              errorMsg.contains('timeout') ||
              errorMsg.contains('network')) {
            // Network error - keep cached data temporarily
            debugPrint('⚠️ Network error, cannot verify mission: $e');
            debugPrint('📋 Using cached data temporarily');
            state = state.copyWith(mission: mission);
          } else {
            // Other error (auth, server error, etc) - clear to be safe
            debugPrint('⚠️ Error verifying mission: $e');
            debugPrint('🗑️ Clearing mission due to verification error');
            await clearActiveMission();
          }
        }
      } else {
        debugPrint('ℹ️ No active mission found');
      }
    } catch (e) {
      debugPrint('❌ Failed to load active mission: $e');
    }
  }

  /// Save active mission to local storage.
  /// Terminal-status missions are auto-cleared instead of saved.
  Future<void> saveActiveMission(BasicRescueMissionResponse mission) async {
    if (_isTerminal(mission.status)) {
      debugPrint(
        '🏁 saveActiveMission: terminal status (${mission.status}) – clearing instead of saving',
      );
      await clearActiveMission();
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // Save mission ID
      await prefs.setString(_activeMissionIdKey, mission.missionId);

      // Save full mission data
      final missionJson = jsonEncode(mission.toJson());
      await prefs.setString(_activeMissionKey, missionJson);

      // Update state
      state = state.copyWith(mission: mission);

      debugPrint('💾 Active mission saved: ${mission.missionId}');
      debugPrint('💾 Status: ${mission.status}');
    } catch (e) {
      debugPrint('❌ Failed to save active mission: $e');
      state = state.copyWith(error: 'Không thể lưu thông tin nhiệm vụ');
    }
  }

  /// Clear active mission
  Future<void> clearActiveMission() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_activeMissionIdKey);
      await prefs.remove(_activeMissionKey);

      state = state.copyWith(clearMission: true);
      debugPrint('🗑️ Active mission cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear active mission: $e');
    }
  }

  /// Update mission status
  Future<void> updateMissionStatus(String status) async {
    if (state.mission != null) {
      final updatedMission = BasicRescueMissionResponse(
        missionId: state.mission!.missionId,
        incidentId: state.mission!.incidentId,
        status: status,
        startedAt: state.mission!.startedAt,
        acceptedAt: state.mission!.acceptedAt,
      );

      await saveActiveMission(updatedMission);
      debugPrint('✅ Mission status updated: $status');
    }
  }

  /// Refresh mission from API
  Future<void> refreshMission() async {
    if (state.mission == null) return;

    try {
      state = state.copyWith(isLoading: true);

      final detailedMission = await missionRepository.getMissionDetail(
        missionId: state.mission!.missionId,
      );

      // Convert to basic mission and save
      final basicMission = BasicRescueMissionResponse(
        missionId: detailedMission.id,
        incidentId: detailedMission.incident.id,
        status: detailedMission.status,
        startedAt: detailedMission.startedAt,
        acceptedAt: detailedMission.createdAt,
      );

      await saveActiveMission(basicMission);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      // Mission not found - clear it
      if (e.toString().contains('Không tìm thấy') ||
          e.toString().contains('404')) {
        debugPrint('⚠️ Mission no longer exists on server');
        await clearActiveMission();
      }

      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Validate if current mission still exists on server
  Future<bool> validateActiveMission() async {
    if (state.mission == null) return false;

    try {
      final detailedMission = await missionRepository.getMissionDetail(
        missionId: state.mission!.missionId,
      );

      // Mission exists - update with latest data
      final basicMission = BasicRescueMissionResponse(
        missionId: detailedMission.id,
        incidentId: detailedMission.incident.id,
        status: detailedMission.status,
        startedAt: detailedMission.startedAt ?? detailedMission.createdAt,
        acceptedAt: detailedMission.createdAt,
      );

      await saveActiveMission(basicMission);
      return true;
    } catch (e) {
      debugPrint('❌ Failed to validate mission: $e');
      // On network error, assume mission still valid
      return true;
    }
  }
}

/// Provider for Active Mission
final activeMissionProvider =
    StateNotifierProvider<ActiveMissionNotifier, ActiveMissionState>((ref) {
      final missionRepository = ref.watch(rescueMissionRepositoryProvider);
      return ActiveMissionNotifier(missionRepository: missionRepository);
    });
