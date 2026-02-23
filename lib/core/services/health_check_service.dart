import 'package:dio/dio.dart';

class HealthCheckService {
  final String baseUrl;

  /// TTL của cache. Trong khoảng thời gian này, kết quả health check
  /// được tái sử dụng mà không cần ping lại server.
  final Duration cacheTtl;

  late final Dio _pingDio;

  // Cache state
  bool? _cachedResult;
  DateTime? _lastCheckTime;

  HealthCheckService({
    required this.baseUrl,
    this.cacheTtl = const Duration(seconds: 15),
  }) {
    _pingDio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 2), // Fail-fast: đóng sau 2s
        receiveTimeout: const Duration(seconds: 2),
      ),
    );
  }

  Future<bool> isServerAlive() async {
    final now = DateTime.now();

    // Trả về cache nếu vẫn còn trong TTL
    if (_cachedResult != null &&
        _lastCheckTime != null &&
        now.difference(_lastCheckTime!) < cacheTtl) {
      return _cachedResult!;
    }

    // Ping thực sự và cập nhật cache
    try {
      final response = await _pingDio.get('/health');
      _cachedResult = response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      // Timeout hoặc server không phản hồi → đánh dấu offline
      _cachedResult = false;
    }

    _lastCheckTime = now;
    return _cachedResult!;
  }

  /// Xóa cache thủ công (dùng khi muốn force re-check ngay lập tức)
  void invalidateCache() {
    _cachedResult = null;
    _lastCheckTime = null;
  }
}
