import 'package:dio/dio.dart';

class HealthCheckService {
  final String baseUrl;
  late final Dio _pingDio;

  HealthCheckService({required this.baseUrl}) {
    _pingDio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(
          seconds: 2,
        ), // Ép đóng sau 2s nếu server không thưa
        receiveTimeout: const Duration(seconds: 2),
      ),
    );
  }

  Future<bool> isServerAlive() async {
    try {
      final response = await _pingDio.get('/health');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      // Lỗi do timeout hoặc tèo server, đều quy về false
      return false;
    }
  }
}
