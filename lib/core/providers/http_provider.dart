import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snakeaid_mobile/core/services/health_check_service.dart';
import '../services/http_service.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String baseUrl =
    dotenv.env['BASE_URL'] ?? 'https://dev.snakeaid.tech';
// const String baseUrl = 'http://10.0.2.2:8080';
final httpServiceProvider = Provider<HttpService>((ref) {
  final healthCheckService = ref.read(healthCheckServiceProvider);
  return HttpService(
    baseUrl: baseUrl,
    onForceLogout: () => ref.read(authProvider.notifier).forceLogout(),
    healthCheckService: healthCheckService,
  );
});

final healthCheckServiceProvider = Provider<HealthCheckService>((ref) {
  return HealthCheckService(baseUrl: baseUrl);
});
