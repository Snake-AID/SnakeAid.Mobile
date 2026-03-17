import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snakeaid_mobile/core/services/health_check_service.dart';
import '../services/http_service.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../config/base_url_config.dart';

/// Provider for the current base URL (dynamic, can be overridden in debug mode)
final baseUrlProvider = Provider<String>((ref) {
  return ref.watch(currentBaseUrlProvider);
});

/// Provider for HttpService using dynamic base URL
final httpServiceProvider = Provider<HttpService>((ref) {
  final healthCheckService = ref.read(healthCheckServiceProvider);
  final baseUrl = ref.watch(baseUrlProvider);
  return HttpService(
    baseUrl: baseUrl,
    onForceLogout: () => ref.read(authProvider.notifier).forceLogout(),
    healthCheckService: healthCheckService,
  );
});

/// Provider for HealthCheckService using dynamic base URL
final healthCheckServiceProvider = Provider<HealthCheckService>((ref) {
  final baseUrl = ref.watch(baseUrlProvider);
  return HealthCheckService(baseUrl: baseUrl);
});
