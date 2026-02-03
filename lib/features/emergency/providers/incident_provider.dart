import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/sos_incident_response.dart';
import '../repository/incident_repository.dart';

/// Active Incident State
class ActiveIncidentState {
  final IncidentData? incident;
  final bool isLoading;
  final String? error;

  ActiveIncidentState({
    this.incident,
    this.isLoading = false,
    this.error,
  });

  ActiveIncidentState copyWith({
    IncidentData? incident,
    bool? isLoading,
    String? error,
    bool clearIncident = false,
  }) {
    return ActiveIncidentState(
      incident: clearIncident ? null : (incident ?? this.incident),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasActiveIncident => incident != null;
  String? get activeIncidentId => incident?.id;
}

/// Active Incident Notifier
class ActiveIncidentNotifier extends StateNotifier<ActiveIncidentState> {
  final IncidentRepository incidentRepository;
  static const String _activeIncidentKey = 'active_sos_incident';
  static const String _activeIncidentIdKey = 'active_sos_incident_id';

  ActiveIncidentNotifier({
    required this.incidentRepository,
  }) : super(ActiveIncidentState()) {
    _loadActiveIncident();
  }

  /// Load active incident from local storage and verify with server
  Future<void> _loadActiveIncident() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final incidentJson = prefs.getString(_activeIncidentKey);

      if (incidentJson != null) {
        final incidentMap = jsonDecode(incidentJson) as Map<String, dynamic>;
        final incident = IncidentData.fromJson(incidentMap);
        
        debugPrint('📋 Found cached incident: ${incident.id}');
        
        // Verify incident still exists on server
        try {
          final response = await incidentRepository.getIncident(incident.id);
          
          if (response.isSuccess && response.data != null) {
            // Incident exists on server - update with latest data
            final serverIncident = response.data!;
            await saveActiveIncident(serverIncident);
            debugPrint('✅ Incident verified and updated from server');
            debugPrint('📋 Status: ${serverIncident.status}');
          } else {
            // Incident not found on server - clear local storage
            debugPrint('⚠️ Incident not found on server (deleted/expired)');
            await clearActiveIncident();
            debugPrint('🗑️ Cleared invalid cached incident');
          }
        } catch (e) {
          final errorMsg = e.toString();
          
          // Check if this is a 404 or other error indicating incident doesn't exist
          if (errorMsg.contains('Không tìm thấy thông tin yêu cầu') ||
              errorMsg.contains('404')) {
            // Incident was deleted - clear local storage
            debugPrint('🗑️ Incident deleted on server - clearing local cache');
            await clearActiveIncident();
          } else if (errorMsg.contains('Không thể kết nối') ||
                     errorMsg.contains('timeout') ||
                     errorMsg.contains('network')) {
            // Network error - keep cached data temporarily
            debugPrint('⚠️ Network error, cannot verify incident: $e');
            debugPrint('📋 Using cached data temporarily');
            state = state.copyWith(incident: incident);
          } else {
            // Other error (auth, server error, etc) - clear to be safe
            debugPrint('⚠️ Error verifying incident: $e');
            debugPrint('🗑️ Clearing incident due to verification error');
            await clearActiveIncident();
          }
        }
      } else {
        debugPrint('ℹ️ No active incident found');
      }
    } catch (e) {
      debugPrint('❌ Failed to load active incident: $e');
    }
  }

  /// Save active incident to local storage
  Future<void> saveActiveIncident(IncidentData incident) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Lưu incident ID
      await prefs.setString(_activeIncidentIdKey, incident.id);

      // Lưu toàn bộ incident data
      final incidentJson = jsonEncode(incident.toJson());
      await prefs.setString(_activeIncidentKey, incidentJson);

      // Update state
      state = state.copyWith(incident: incident);

      debugPrint('💾 Active incident saved: ${incident.id}');
      debugPrint('💾 Status: ${incident.status}');
    } catch (e) {
      debugPrint('❌ Failed to save active incident: $e');
      state = state.copyWith(error: 'Không thể lưu thông tin yêu cầu SOS');
    }
  }

  /// Clear active incident
  Future<void> clearActiveIncident() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_activeIncidentIdKey);
      await prefs.remove(_activeIncidentKey);

      state = state.copyWith(clearIncident: true);
      debugPrint('🗑️ Active incident cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear active incident: $e');
    }
  }

  /// Update incident status
  Future<void> updateIncidentStatus(String status) async {
    if (state.incident != null) {
      final updatedIncident = IncidentData(
        id: state.incident!.id,
        userId: state.incident!.userId,
        locationCoordinates: state.incident!.locationCoordinates,
        symptomsReport: state.incident!.symptomsReport,
        status: status,
        currentSessionNumber: state.incident!.currentSessionNumber,
        currentRadiusKm: state.incident!.currentRadiusKm,
        lastSessionAt: state.incident!.lastSessionAt,
        assignedAt: state.incident!.assignedAt,
        assignedRescuerId: state.incident!.assignedRescuerId,
        cancellationReason: state.incident!.cancellationReason,
        severityLevel: state.incident!.severityLevel,
        incidentOccurredAt: state.incident!.incidentOccurredAt,
        sessions: state.incident!.sessions,
      );

      await saveActiveIncident(updatedIncident);
      debugPrint('✅ Incident status updated: $status');
    }
  }

  /// Refresh incident from API
  Future<void> refreshIncident() async {
    if (state.incident == null) return;

    try {
      state = state.copyWith(isLoading: true);

      final response = await incidentRepository.getIncident(state.incident!.id);

      if (response.isSuccess && response.data != null) {
        await saveActiveIncident(response.data!);
      } else {
        // Incident not found - clear it
        debugPrint('⚠️ Incident no longer exists on server');
        await clearActiveIncident();
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Validate if current incident still exists on server
  Future<bool> validateActiveIncident() async {
    if (state.incident == null) return false;

    try {
      final response = await incidentRepository.getIncident(state.incident!.id);
      
      if (response.isSuccess && response.data != null) {
        // Update with latest data
        await saveActiveIncident(response.data!);
        return true;
      } else {
        // Incident deleted/expired - clear local storage
        await clearActiveIncident();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Failed to validate incident: $e');
      // On network error, assume incident still valid
      return true;
    }
  }
}

/// Provider for Active Incident
final activeIncidentProvider = StateNotifierProvider<ActiveIncidentNotifier, ActiveIncidentState>((ref) {
  final incidentRepository = ref.watch(incidentRepositoryProvider);
  return ActiveIncidentNotifier(incidentRepository: incidentRepository);
});
