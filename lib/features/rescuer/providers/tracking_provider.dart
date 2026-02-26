import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../emergency/providers/rescuer_emergency_provider.dart';
import '../managers/location_manager.dart';

final locationManagerProvider = Provider<LocationManager>((ref) {
  final signalRService = ref.watch(rescuerSignalRServiceProvider);
  final manager = LocationManager(signalRService);

  ref.onDispose(() {
    manager.stopTracking();
  });

  return manager;
});
