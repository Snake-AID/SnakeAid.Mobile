import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snakeaid_mobile/features/emergency/providers/rescuer_emergency_provider.dart';
import 'rescuer_signalr_service.dart';

/// App Lifecycle Service
/// Manages rescuer online/offline status based on app state
class AppLifecycleService with WidgetsBindingObserver {
  final RescuerSignalRService _signalRService;
  String? _rescuerId;

  AppLifecycleService(this._signalRService);

  /// Initialize lifecycle observer
  void initialize(String rescuerId) {
    _rescuerId = rescuerId;
    WidgetsBinding.instance.addObserver(this);
    debugPrint('📱 App lifecycle observer initialized for rescuer: $rescuerId');
  }

  /// Dispose lifecycle observer
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    debugPrint('📱 App lifecycle observer disposed');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('📱 App lifecycle changed: $state');

    switch (state) {
      case AppLifecycleState.resumed:
        // App vào foreground → reconnect SignalR nếu bị disconnect
        _handleResumed();
        break;

      case AppLifecycleState.paused:
        // App vào background → có thể keep connection
        _handlePaused();
        break;

      case AppLifecycleState.inactive:
        // App đang transition (phone call, etc.)
        debugPrint('📱 App inactive');
        break;

      case AppLifecycleState.detached:
        // App sắp bị kill
        _handleDetached();
        break;

      case AppLifecycleState.hidden:
        debugPrint('📱 App hidden');
        break;
    }
  }

  /// Handle app resumed (foreground)
  Future<void> _handleResumed() async {
    debugPrint('✅ App resumed - checking SignalR connection...');

    if (_rescuerId == null) return;

    // Check if SignalR is connected
    if (!_signalRService.isConnected) {
      debugPrint('🔄 Reconnecting SignalR...');
      try {
        await _signalRService.connectAsRescuer(_rescuerId!);
        debugPrint('✅ SignalR reconnected on app resume');
      } catch (e) {
        debugPrint('❌ Failed to reconnect SignalR: $e');
      }
    } else {
      debugPrint('✅ SignalR already connected');
    }
  }

  /// Handle app paused (background)
  void _handlePaused() {
    debugPrint('⏸️ App paused - keeping SignalR connection for background');

    // ⚠️ OPTION 1: Keep connection (recommended for rescuers)
    // → Server still sees them as online, can receive urgent requests
    debugPrint('📡 Keeping SignalR connection alive in background');

    // ⚠️ OPTION 2: Disconnect to save battery (optional)
    // await _signalRService.disconnect();
    // → Use this if you want to explicitly go offline when app is backgrounded
  }

  /// Handle app detached (about to be killed)
  Future<void> _handleDetached() async {
    debugPrint('🚪 App detached - gracefully disconnecting...');

    if (_rescuerId != null && _signalRService.isConnected) {
      try {
        await _signalRService.disconnect();
        debugPrint('✅ SignalR disconnected gracefully');
      } catch (e) {
        debugPrint('❌ Error disconnecting SignalR: $e');
      }
    }
  }
}

/// Provider for AppLifecycleService
final appLifecycleServiceProvider = Provider<AppLifecycleService>((ref) {
  final signalRService = ref.watch(rescuerSignalRServiceProvider);
  return AppLifecycleService(signalRService);
});
