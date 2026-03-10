import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/detailed_incident_response.dart';
import '../repository/incident_repository.dart';

/// Detailed Incident State
/// Caches DetailedIncidentData to avoid duplicate API calls across screens
class DetailedIncidentState {
  final DetailedIncidentData? incident;
  final bool isLoading;
  final String? error;
  final DateTime? lastFetched;

  DetailedIncidentState({
    this.incident,
    this.isLoading = false,
    this.error,
    this.lastFetched,
  });

  DetailedIncidentState copyWith({
    DetailedIncidentData? incident,
    bool? isLoading,
    String? error,
    DateTime? lastFetched,
    bool clearIncident = false,
    bool clearError = false,
  }) {
    return DetailedIncidentState(
      incident: clearIncident ? null : (incident ?? this.incident),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastFetched: lastFetched ?? this.lastFetched,
    );
  }

  bool get hasIncident => incident != null;
  String? get incidentId => incident?.id;

  /// Check if cache is still fresh (< 30 seconds old)
  bool get isCacheFresh {
    if (lastFetched == null) return false;
    final age = DateTime.now().difference(lastFetched!);
    return age.inSeconds < 30;
  }

  /// Check if cache is stale (needs refresh)
  bool get isCacheStale => !isCacheFresh;
}

/// Detailed Incident Notifier
/// Manages detailed incident data with smart caching
class DetailedIncidentNotifier extends StateNotifier<DetailedIncidentState> {
  final IncidentRepository incidentRepository;

  DetailedIncidentNotifier({required this.incidentRepository})
    : super(DetailedIncidentState());

  /// Load detailed incident with smart caching
  /// - If cache exists and fresh → return cached data
  /// - If forceRefresh=true → always fetch from API
  /// - Otherwise → fetch from API
  Future<void> loadDetailedIncident(
    String incidentId, {
    bool forceRefresh = false,
  }) async {
    // Return cached data if available and fresh
    if (!forceRefresh &&
        state.incident?.id == incidentId &&
        state.isCacheFresh) {
      debugPrint(
        '📦 [DetailedIncident] Using cached data (${state.lastFetched})',
      );
      return;
    }

    try {
      debugPrint('🔍 [DetailedIncident] Fetching: $incidentId');
      state = state.copyWith(isLoading: true, clearError: true);

      final response = await incidentRepository.getDetailedIncident(incidentId);

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(
          incident: response.data,
          isLoading: false,
          lastFetched: DateTime.now(),
        );
        debugPrint(
          '✅ [DetailedIncident] Loaded and cached: ${response.data!.id}',
        );
        debugPrint('   Status: ${response.data!.status.value}');
        debugPrint('   Has Rescuer: ${response.data!.hasAssignedRescuer}');
        debugPrint(
          '   Symptoms: ${response.data!.symptomsReport?.length ?? 0}',
        );
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        debugPrint('❌ [DetailedIncident] Failed: ${response.message}');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      debugPrint('❌ [DetailedIncident] Error: $e');
    }
  }

  /// Force refresh detailed incident from API
  Future<void> refreshDetailedIncident() async {
    if (state.incident == null) {
      debugPrint('⚠️ [DetailedIncident] No incident to refresh');
      return;
    }

    debugPrint('🔄 [DetailedIncident] Force refreshing: ${state.incident!.id}');
    await loadDetailedIncident(state.incident!.id, forceRefresh: true);
  }

  /// Invalidate cache - marks data as stale without clearing it
  /// Next loadDetailedIncident() will fetch fresh data
  /// Use this after actions that change incident data (submit symptoms, etc)
  void invalidateCache() {
    if (state.incident != null) {
      debugPrint(
        '🔄 [DetailedIncident] Cache invalidated for: ${state.incident!.id}',
      );
      // Set lastFetched to null to force refresh on next load
      state = state.copyWith(lastFetched: DateTime.fromMillisecondsSinceEpoch(0));
    }
  }

  /// Load incident only if cache is stale or missing
  /// Useful for screens that auto-refresh on focus
  Future<void> loadIfStale(String incidentId) async {
    if (state.incident?.id == incidentId && state.isCacheFresh) {
      debugPrint(
        '✅ [DetailedIncident] Cache still fresh, skipping load',
      );
      return;
    }

    debugPrint('🔄 [DetailedIncident] Cache stale, loading...');
    await loadDetailedIncident(incidentId);
  }

  /// Clear cached incident data
  void clearCache() {
    debugPrint('🗑️ [DetailedIncident] Cache cleared');
    state = DetailedIncidentState();
  }

  /// Update specific incident data (e.g., after symptom update)
  /// This updates the cache without a full API call
  void updateIncidentInCache(DetailedIncidentData updatedIncident) {
    if (state.incident?.id == updatedIncident.id) {
      debugPrint(
        '💾 [DetailedIncident] Cache updated for: ${updatedIncident.id}',
      );
      state = state.copyWith(
        incident: updatedIncident,
        lastFetched: DateTime.now(),
      );
    }
  }

  /// Check if cache exists for specific incident ID
  bool hasCachedIncident(String incidentId) {
    return state.incident?.id == incidentId;
  }
}

/// Provider for Detailed Incident
final detailedIncidentProvider =
    StateNotifierProvider<DetailedIncidentNotifier, DetailedIncidentState>((
      ref,
    ) {
      final incidentRepository = ref.watch(incidentRepositoryProvider);
      return DetailedIncidentNotifier(incidentRepository: incidentRepository);
    });
