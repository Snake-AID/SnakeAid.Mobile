import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../../../core/services/rescuer_signalr_service.dart';
import '../../../core/providers/http_provider.dart';
import '../models/rescue_request.dart';

/// State for rescue mode (SignalR connection status)
class RescueModeState {
  final bool isActive;
  final bool isConnecting;
  final bool isConnected;
  final HubConnectionState? connectionState;
  final String? error;
  final String? rescuerId;

  const RescueModeState({
    this.isActive = false,
    this.isConnecting = false,
    this.isConnected = false,
    this.connectionState,
    this.error,
    this.rescuerId,
  });

  RescueModeState copyWith({
    bool? isActive,
    bool? isConnecting,
    bool? isConnected,
    HubConnectionState? connectionState,
    String? error,
    String? rescuerId,
    bool clearError = false,
  }) {
    return RescueModeState(
      isActive: isActive ?? this.isActive,
      isConnecting: isConnecting ?? this.isConnecting,
      isConnected: isConnected ?? this.isConnected,
      connectionState: connectionState ?? this.connectionState,
      error: clearError ? null : (error ?? this.error),
      rescuerId: rescuerId ?? this.rescuerId,
    );
  }

  @override
  String toString() =>
      'RescueModeState(active: $isActive, connected: $isConnected)';
}

/// Notifier for rescue mode management
class RescueModeNotifier extends StateNotifier<RescueModeState> {
  final RescuerSignalRService _signalRService;

  RescueModeNotifier(this._signalRService) : super(const RescueModeState()) {
    // Listen to connection state changes
    _signalRService.connectionStateStream.listen((hubState) {
      state = state.copyWith(
        isConnected: hubState == HubConnectionState.Connected,
        isConnecting:
            hubState == HubConnectionState.Connecting ||
            hubState == HubConnectionState.Reconnecting,
        connectionState: hubState,
      );
    });
  }

  /// Start rescue mode (connect to SignalR)
  Future<void> startRescueMode(String rescuerId) async {
    try {
      debugPrint('🚀 Starting rescue mode for rescuer: $rescuerId');

      state = state.copyWith(isConnecting: true, clearError: true);

      await _signalRService.connectAsRescuer(rescuerId);

      state = state.copyWith(
        isActive: true,
        isConnecting: false,
        isConnected: true,
        rescuerId: rescuerId,
      );

      debugPrint('✅ Rescue mode started successfully');
    } catch (e) {
      debugPrint('❌ Failed to start rescue mode: $e');

      state = state.copyWith(
        isActive: false,
        isConnecting: false,
        isConnected: false,
        error: 'Không thể kết nối. Vui lòng kiểm tra mạng và thử lại.',
      );

      rethrow;
    }
  }

  /// Stop rescue mode (disconnect from SignalR)
  Future<void> stopRescueMode() async {
    try {
      debugPrint('🛑 Stopping rescue mode...');

      await _signalRService.disconnect();

      state = const RescueModeState();

      debugPrint('✅ Rescue mode stopped');
    } catch (e) {
      debugPrint('❌ Error stopping rescue mode: $e');
      state = const RescueModeState();
    }
  }

  /// Reconnect to SignalR
  Future<void> reconnect() async {
    if (state.rescuerId == null) {
      debugPrint('⚠️ Cannot reconnect: No rescuer ID');
      return;
    }

    try {
      debugPrint('🔄 Reconnecting to SignalR...');
      state = state.copyWith(isConnecting: true);

      await _signalRService.reconnect();

      debugPrint('✅ Reconnected successfully');
    } catch (e) {
      debugPrint('❌ Reconnection failed: $e');
      state = state.copyWith(
        isConnecting: false,
        error: 'Không thể kết nối lại',
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for RescuerSignalRService singleton
final rescuerSignalRServiceProvider = Provider<RescuerSignalRService>((ref) {
  return RescuerSignalRService(baseUrl: baseUrl);
});

/// Provider for rescue mode state
final rescueModeProvider =
    StateNotifierProvider<RescueModeNotifier, RescueModeState>((ref) {
      final signalRService = ref.watch(rescuerSignalRServiceProvider);
      return RescueModeNotifier(signalRService);
    });

/// Stream provider for new rescue requests
final newRescueRequestStreamProvider = StreamProvider<RescueRequest>((ref) {
  final signalRService = ref.watch(rescuerSignalRServiceProvider);
  debugPrint('🔗 newRescueRequestStreamProvider: Watching stream...');

  return signalRService.newRequestStream.map((request) {
    debugPrint(
      '🎯 Stream Provider: New request received! ${request.requestId}',
    );
    return request;
  });
});

/// Stream provider for request taken events
final requestTakenStreamProvider = StreamProvider<String>((ref) {
  final signalRService = ref.watch(rescuerSignalRServiceProvider);
  debugPrint('🔗 requestTakenStreamProvider: Watching stream...');

  return signalRService.requestTakenStream.map((requestId) {
    debugPrint('🎯 Stream Provider: Request taken! $requestId');
    return requestId;
  });
});

/// Stream provider for request expired events
final requestExpiredStreamProvider = StreamProvider<String>((ref) {
  final signalRService = ref.watch(rescuerSignalRServiceProvider);
  debugPrint('🔗 requestExpiredStreamProvider: Watching stream...');

  return signalRService.requestExpiredStream.map((requestId) {
    debugPrint('🎯 Stream Provider: Request expired! $requestId');
    return requestId;
  });
});

/// Stream provider for request cancelled events
final requestCancelledStreamProvider = StreamProvider<String>((ref) {
  final signalRService = ref.watch(rescuerSignalRServiceProvider);
  debugPrint('🔗 requestCancelledStreamProvider: Watching stream...');

  return signalRService.requestCancelledStream.map((requestId) {
    debugPrint('🎯 Stream Provider: Request cancelled! $requestId');
    return requestId;
  });
});

/// Current active rescue request state
class ActiveRescueRequestState {
  final RescueRequest? request;
  final bool isAccepting;
  final String? error;

  const ActiveRescueRequestState({
    this.request,
    this.isAccepting = false,
    this.error,
  });

  ActiveRescueRequestState copyWith({
    RescueRequest? request,
    bool? isAccepting,
    String? error,
    bool clearRequest = false,
    bool clearError = false,
  }) {
    return ActiveRescueRequestState(
      request: clearRequest ? null : (request ?? this.request),
      isAccepting: isAccepting ?? this.isAccepting,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get hasActiveRequest => request != null && (request?.isValid ?? false);
}

/// Notifier for active rescue request
class ActiveRescueRequestNotifier
    extends StateNotifier<ActiveRescueRequestState> {
  final RescuerSignalRService _signalRService;

  ActiveRescueRequestNotifier(this._signalRService)
    : super(const ActiveRescueRequestState());

  /// Set active request
  void setRequest(RescueRequest request) {
    debugPrint('📋 Setting active request: ${request.requestId}');
    state = state.copyWith(request: request);
  }

  /// Clear active request
  void clearRequest() {
    debugPrint('🗑️ Clearing active request');
    state = state.copyWith(clearRequest: true);
  }

  /// Accept the current request
  Future<AcceptRequestResponse> acceptRequest(String rescuerId) async {
    if (state.request == null) {
      return AcceptRequestResponse(
        isSuccess: false,
        message: 'Không có yêu cầu nào đang hoạt động',
        error: 'NO_ACTIVE_REQUEST',
      );
    }

    try {
      debugPrint('✅ Accepting request: ${state.request!.requestId}');

      state = state.copyWith(isAccepting: true, clearError: true);

      final response = await _signalRService.acceptRequest(
        state.request!.requestId,
        rescuerId,
      );

      if (response.isSuccess) {
        debugPrint('✅ Request accepted successfully');
        // Clear request after successful accept
        state = state.copyWith(clearRequest: true, isAccepting: false);
      } else {
        debugPrint('⚠️ Failed to accept request: ${response.message}');
        state = state.copyWith(isAccepting: false, error: response.message);
      }

      return response;
    } catch (e) {
      debugPrint('❌ Error accepting request: $e');

      state = state.copyWith(
        isAccepting: false,
        error: 'Có lỗi xảy ra. Vui lòng thử lại.',
      );

      return AcceptRequestResponse(
        isSuccess: false,
        message: 'Có lỗi xảy ra. Vui lòng thử lại.',
        error: e.toString(),
      );
    }
  }

  /// Decline the current request
  void declineRequest() {
    debugPrint('❌ Declining request');
    clearRequest();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for active rescue request
final activeRescueRequestProvider =
    StateNotifierProvider<
      ActiveRescueRequestNotifier,
      ActiveRescueRequestState
    >((ref) {
      final signalRService = ref.watch(rescuerSignalRServiceProvider);
      return ActiveRescueRequestNotifier(signalRService);
    });
