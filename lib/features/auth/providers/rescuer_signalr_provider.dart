import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../../../core/services/rescuer_signalr_service.dart';
import '../../../core/providers/http_provider.dart';
import '../models/user_role.dart';
import 'auth_provider.dart';

// ==================== SIGNALR CONNECTION STATE ====================

/// SignalR connection state for rescuer
class RescuerSignalRState {
  /// Whether SignalR is connected
  final bool isConnected;

  /// Whether connection is in progress
  final bool isConnecting;

  /// Current connection state
  final HubConnectionState? connectionState;

  /// Error message if connection failed
  final String? error;

  const RescuerSignalRState({
    this.isConnected = false,
    this.isConnecting = false,
    this.connectionState,
    this.error,
  });

  RescuerSignalRState copyWith({
    bool? isConnected,
    bool? isConnecting,
    HubConnectionState? connectionState,
    String? error,
    bool clearError = false,
  }) {
    return RescuerSignalRState(
      isConnected: isConnected ?? this.isConnected,
      isConnecting: isConnecting ?? this.isConnecting,
      connectionState: connectionState ?? this.connectionState,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  String toString() =>
      'RescuerSignalRState(connected: $isConnected, connecting: $isConnecting, state: $connectionState)';
}

// ==================== SIGNALR CONNECTION NOTIFIER ====================

/// Manages SignalR connection for rescuer
/// Auto-connects when user logs in as rescuer
/// Auto-disconnects when user logs out
class RescuerSignalRNotifier extends StateNotifier<RescuerSignalRState> {
  final RescuerSignalRService _signalRService;
  final Ref _ref;

  RescuerSignalRNotifier({
    required RescuerSignalRService signalRService,
    required Ref ref,
  }) : _signalRService = signalRService,
       _ref = ref,
       super(const RescuerSignalRState()) {
    // Listen to auth state changes
    _listenToAuthChanges();

    // Listen to SignalR connection state changes
    _listenToConnectionChanges();
  }

  /// Listen to authentication state changes
  /// Auto-connect when rescuer logs in
  /// Auto-disconnect when logs out
  void _listenToAuthChanges() {
    _ref.listen(authProvider, (previous, next) {
      final user = next.user;
      final wasAuthenticated = previous?.isAuthenticated ?? false;
      final isAuthenticated = next.isAuthenticated;

      // User just logged in as rescuer
      if (!wasAuthenticated && isAuthenticated && user != null) {
        if (user.role == UserRole.rescuer) {
          debugPrint('🚑 Rescuer logged in - auto-connecting to SignalR hub');
          connect(user.id);
        }
      }

      // User logged out
      if (wasAuthenticated && !isAuthenticated) {
        debugPrint('🚪 User logged out - disconnecting from SignalR hub');
        disconnect();
      }
    });
  }

  /// Listen to SignalR connection state stream
  void _listenToConnectionChanges() {
    _signalRService.connectionStateStream.listen((connectionState) {
      debugPrint('📡 SignalR state changed: $connectionState');

      state = state.copyWith(
        connectionState: connectionState,
        isConnected: connectionState == HubConnectionState.Connected,
        isConnecting:
            connectionState == HubConnectionState.Connecting ||
            connectionState == HubConnectionState.Reconnecting,
      );
    });
  }

  /// Manually connect to SignalR hub
  /// Typically called automatically when rescuer logs in
  Future<void> connect(String rescuerId) async {
    if (state.isConnected || state.isConnecting) {
      debugPrint('⚠️ Already connected or connecting');
      return;
    }

    state = state.copyWith(isConnecting: true, clearError: true);

    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔌 Connecting rescuer to SignalR hub...');

      await _signalRService.connectAsRescuer(rescuerId);

      state = state.copyWith(
        isConnected: true,
        isConnecting: false,
        connectionState: HubConnectionState.Connected,
      );

      debugPrint('✅ Rescuer connected to SignalR hub');
    } catch (e) {
      debugPrint('❌ Failed to connect to SignalR: $e');

      state = state.copyWith(
        isConnected: false,
        isConnecting: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Manually disconnect from SignalR hub
  Future<void> disconnect() async {
    if (!state.isConnected && !state.isConnecting) {
      debugPrint('ℹ️ Already disconnected');
      return;
    }

    try {
      debugPrint('🔌 Disconnecting from SignalR hub...');

      await _signalRService.disconnect();

      state = state.copyWith(
        isConnected: false,
        isConnecting: false,
        connectionState: HubConnectionState.Disconnected,
        clearError: true,
      );

      debugPrint('✅ Disconnected from SignalR hub');
    } catch (e) {
      debugPrint('❌ Error during disconnect: $e');
      // Force state to disconnected anyway
      state = state.copyWith(
        isConnected: false,
        isConnecting: false,
        connectionState: HubConnectionState.Disconnected,
      );
    }
  }

  /// Reconnect to SignalR hub
  /// Useful after network issues
  Future<void> reconnect() async {
    debugPrint('🔄 Manually reconnecting to SignalR...');

    final user = _ref.read(currentUserProvider);

    if (user == null || user.role != UserRole.rescuer) {
      debugPrint('⚠️ Cannot reconnect: User is not a rescuer');
      return;
    }

    await disconnect();
    await connect(user.id);
  }

  /// Check connection health
  Future<bool> checkHealth() async {
    return await _signalRService.checkHealth();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ==================== PROVIDERS ====================

/// Rescuer SignalR connection provider
/// Manages connection state and auto-connects for rescuers
final rescuerSignalRProvider =
    StateNotifierProvider<RescuerSignalRNotifier, RescuerSignalRState>((ref) {
      return RescuerSignalRNotifier(
        signalRService: RescuerSignalRService(baseUrl: baseUrl),
        ref: ref,
      );
    });

/// Computed: Is SignalR connected?
final isSignalRConnectedProvider = Provider<bool>((ref) {
  final signalRState = ref.watch(rescuerSignalRProvider);
  return signalRState.isConnected;
});

/// Computed: SignalR connection status text
final signalRStatusTextProvider = Provider<String>((ref) {
  final signalRState = ref.watch(rescuerSignalRProvider);

  if (signalRState.isConnected) {
    return 'Đang kết nối';
  } else if (signalRState.isConnecting) {
    return 'Đang kết nối...';
  } else if (signalRState.error != null) {
    return 'Lỗi kết nối';
  } else {
    return 'Ngoại tuyến';
  }
});
