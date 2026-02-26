import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/http_service.dart';
import '../services/health_check_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String baseUrl =
    dotenv.env['BASE_URL'] ?? 'https://snakeaid-dev.duykhiem.id.vn';
// const String baseUrl = 'http://10.0.2.2:8080';
final httpServiceProvider = Provider<HttpService>((ref) {
  final healthCheckService = ref.watch(healthCheckServiceProvider);
  return HttpService(baseUrl: baseUrl, healthCheckService: healthCheckService);
});

final healthCheckServiceProvider = Provider<HealthCheckService>((ref) {
  return HealthCheckService(baseUrl: baseUrl);
});
