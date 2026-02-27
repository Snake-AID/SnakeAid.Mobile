import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snakeaid_mobile/core/services/health_check_service.dart';
import '../services/http_service.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String baseUrl =
    dotenv.env['BASE_URL'] ?? 'https://snakeaid-dev.duykhiem.id.vn';
// const String baseUrl = 'http://10.0.2.2:8080';
final httpServiceProvider = Provider<HttpService>((ref) {
  return HttpService(
    baseUrl: baseUrl,
    onForceLogout: () => ref.read(authProvider.notifier).forceLogout(),
  );
});

final healthCheckServiceProvider = Provider<HealthCheckService>((ref) {
  return HealthCheckService(baseUrl: baseUrl);
});
