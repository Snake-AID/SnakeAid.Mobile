import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../../../core/services/mission_hub_service.dart';
import '../../../core/providers/http_provider.dart';

// ── Singleton service provider ─────────────────────────────────────────────────
final missionHubServiceProvider = Provider<MissionHubService>((ref) {
  final service = MissionHubService(baseUrl: baseUrl);
  ref.onDispose(() => service.dispose());
  return service;
});

// ── Connection state ──────────────────────────────────────────────────────────

/// Full state of the MissionHub connection for this member's active incident
class MissionHubConnectionState {
  final bool isConnecting;
  final bool isConnected;
  final HubConnectionState? hubState;
  final String? incidentId;
  final String? error;

  const MissionHubConnectionState({
    this.isConnecting = false,
    this.isConnected = false,
    this.hubState,
    this.incidentId,
    this.error,
  });

  MissionHubConnectionState copyWith({
    bool? isConnecting,
    bool? isConnected,
    HubConnectionState? hubState,
    String? incidentId,
    String? error,
    bool clearError = false,
  }) {
    return MissionHubConnectionState(
      isConnecting: isConnecting ?? this.isConnecting,
      isConnected: isConnected ?? this.isConnected,
      hubState: hubState ?? this.hubState,
      incidentId: incidentId ?? this.incidentId,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MissionHubConnectionNotifier
    extends StateNotifier<MissionHubConnectionState> {
  final MissionHubService _service;

  MissionHubConnectionNotifier(this._service)
    : super(const MissionHubConnectionState()) {
    _service.connectionStateStream.listen((hubState) {
      state = state.copyWith(
        isConnected: hubState == HubConnectionState.Connected,
        isConnecting:
            hubState == HubConnectionState.Connecting ||
            hubState == HubConnectionState.Reconnecting,
        hubState: hubState,
      );
    });
  }

  Future<void> connectForIncident(String incidentId) async {
    if (state.isConnected && state.incidentId == incidentId) {
      debugPrint('✅ MissionHub already connected for $incidentId');
      return;
    }

    state = state.copyWith(isConnecting: true, clearError: true);

    try {
      await _service.connectForIncident(incidentId);
      state = state.copyWith(
        isConnecting: false,
        isConnected: true,
        incidentId: incidentId,
      );
    } catch (e) {
      debugPrint('❌ MissionHub connect failed: $e');
      state = state.copyWith(
        isConnecting: false,
        isConnected: false,
        error: 'Không thể kết nối MissionHub. Vui lòng thử lại.',
      );
    }
  }

  Future<void> disconnect() async {
    await _service.disconnect();
    state = const MissionHubConnectionState();
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final missionHubConnectionProvider =
    StateNotifierProvider<
      MissionHubConnectionNotifier,
      MissionHubConnectionState
    >((ref) {
      final service = ref.watch(missionHubServiceProvider);
      return MissionHubConnectionNotifier(service);
    });

// ── Mission status (updated by events) ───────────────────────────────────────

class MissionStatus {
  final String? missionId;
  final String? rescuerId;
  final double? rescuerLat;
  final double? rescuerLng;
  final DateTime? rescuerLocationUpdatedAt;
  final bool rescuerArrived;
  final bool missionCompleted;
  final bool missionCancelled;
  final String? cancellationReason;
  final bool sessionExpired;

  const MissionStatus({
    this.missionId,
    this.rescuerId,
    this.rescuerLat,
    this.rescuerLng,
    this.rescuerLocationUpdatedAt,
    this.rescuerArrived = false,
    this.missionCompleted = false,
    this.missionCancelled = false,
    this.cancellationReason,
    this.sessionExpired = false,
  });

  bool get hasRescuer => missionId != null && rescuerId != null;

  MissionStatus copyWith({
    String? missionId,
    String? rescuerId,
    double? rescuerLat,
    double? rescuerLng,
    DateTime? rescuerLocationUpdatedAt,
    bool? rescuerArrived,
    bool? missionCompleted,
    bool? missionCancelled,
    String? cancellationReason,
    bool? sessionExpired,
  }) {
    return MissionStatus(
      missionId: missionId ?? this.missionId,
      rescuerId: rescuerId ?? this.rescuerId,
      rescuerLat: rescuerLat ?? this.rescuerLat,
      rescuerLng: rescuerLng ?? this.rescuerLng,
      rescuerLocationUpdatedAt:
          rescuerLocationUpdatedAt ?? this.rescuerLocationUpdatedAt,
      rescuerArrived: rescuerArrived ?? this.rescuerArrived,
      missionCompleted: missionCompleted ?? this.missionCompleted,
      missionCancelled: missionCancelled ?? this.missionCancelled,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      sessionExpired: sessionExpired ?? this.sessionExpired,
    );
  }
}

class MissionStatusNotifier extends StateNotifier<MissionStatus> {
  final MissionHubService _service;
  final List<StreamSubscription> _subscriptions = [];

  MissionStatusNotifier(this._service) : super(const MissionStatus()) {
    _subscriptions.add(
      _service.rescuerAcceptedStream.listen((data) {
        debugPrint(
          '🎯 MissionStatusNotifier: RescuerAccepted '
          'mission=${data.missionId}',
        );
        state = state.copyWith(
          missionId: data.missionId,
          rescuerId: data.rescuerId,
        );
      }),
    );

    _subscriptions.add(
      _service.locationUpdatedStream.listen((loc) {
        state = state.copyWith(
          rescuerLat: loc.latitude,
          rescuerLng: loc.longitude,
          rescuerLocationUpdatedAt: loc.updatedAt,
        );
      }),
    );

    _subscriptions.add(
      _service.rescuerArrivedStream.listen((_) {
        state = state.copyWith(rescuerArrived: true);
      }),
    );

    _subscriptions.add(
      _service.missionCompletedStream.listen((_) {
        state = state.copyWith(missionCompleted: true);
      }),
    );

    _subscriptions.add(
      _service.missionCancelledStream.listen((reason) {
        state = state.copyWith(
          missionCancelled: true,
          cancellationReason: reason,
        );
      }),
    );

    _subscriptions.add(
      _service.sessionExpiredStream.listen((_) {
        state = state.copyWith(sessionExpired: true);
      }),
    );
  }

  void reset() => state = const MissionStatus();

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}

final missionStatusProvider =
    StateNotifierProvider<MissionStatusNotifier, MissionStatus>((ref) {
      final service = ref.watch(missionHubServiceProvider);
      return MissionStatusNotifier(service);
    });

// ── Convenience stream providers ──────────────────────────────────────────────

final rescuerAcceptedStreamProvider = StreamProvider<RescuerAcceptedData>((
  ref,
) {
  final service = ref.watch(missionHubServiceProvider);
  return service.rescuerAcceptedStream;
});

final rescuerLocationStreamProvider = StreamProvider<RescuerLocationData>((
  ref,
) {
  final service = ref.watch(missionHubServiceProvider);
  return service.locationUpdatedStream;
});

final missionHubConnectionStateStreamProvider =
    StreamProvider<HubConnectionState>((ref) {
      final service = ref.watch(missionHubServiceProvider);
      return service.connectionStateStream;
    });
