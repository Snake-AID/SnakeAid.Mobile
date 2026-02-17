import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/http_provider.dart';
import '../services/rescuer_signalr_service.dart';
import '../managers/location_manager.dart';

final rescuerSignalRServiceProvider = Provider<RescuerSignalRService>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return RescuerSignalRService(baseUrl: httpService.baseUrl);
});

final locationManagerProvider = Provider<LocationManager>((ref) {
  final signalRService = ref.watch(rescuerSignalRServiceProvider);
  return LocationManager(signalRService);
});
