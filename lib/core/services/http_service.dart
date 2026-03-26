import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../interceptors/token_refresh_interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../services/health_check_service.dart';

/// Thin Dio wrapper.
///
/// Responsibilities:
/// - Configure Dio with timeouts and base headers.
/// - Run [HealthCheckService] before each request (cached, low-overhead).
/// - Translate [DioException] into user-readable messages while preserving
///   the original exception type for callers that need to inspect status codes.
///
/// Auth / token refresh is handled entirely by [TokenRefreshInterceptor].
class HttpService {
  late final Dio _dio;
  final String baseUrl;
  final HealthCheckService? healthCheckService;
  final Future<void> Function() onForceLogout;

  HttpService({
    required this.baseUrl,
    required this.onForceLogout,
    this.healthCheckService,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      TokenRefreshInterceptor(_dio, onForceLogout: onForceLogout),
      LoggingInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  // ==================== HTTP METHODS ====================

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _healthCheck();
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _enrichError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _healthCheck();
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _enrichError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _healthCheck();
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _enrichError(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _healthCheck(); // ← was missing in original
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _enrichError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _healthCheck();
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _enrichError(e);
    }
  }

  // ==================== PRIVATE HELPERS ====================

  /// Fast-fail health check using cached result (15 s TTL by default).
  /// No-op when [healthCheckService] is null.
  Future<void> _healthCheck() async {
    if (healthCheckService == null) return;
    final alive = await healthCheckService!.isServerAlive();
    if (!alive) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionError,
        error: 'HEALTH_CHECK_FAILED',
        message:
            'Máy chủ đang bảo trì hoặc không thể kết nối. Vui lòng thử lại sau.',
      );
    }
  }

  /// Re-throws [original] with a user-readable [message] attached.
  ///
  /// Preserves the original [DioException] type and response so callers
  /// (repositories, interceptors) can still inspect status codes.
  DioException _enrichError(DioException original) {
    final message = _buildMessage(original);
    debugPrint('🌐 HTTP error: $message (${original.response?.statusCode})');
    return DioException(
      requestOptions: original.requestOptions,
      response: original.response,
      type: original.type,
      error: original.error,
      message: message, // ← user-readable, accessible via e.message
    );
  }

  String _buildMessage(DioException e) {
    // Health check shortcut
    if (e.error == 'HEALTH_CHECK_FAILED') {
      return 'Máy chủ đang bảo trì hoặc không thể kết nối. Vui lòng thử lại sau.';
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Kết nối timeout. Vui lòng thử lại.';

      case DioExceptionType.cancel:
        return 'Request đã bị hủy.';

      case DioExceptionType.connectionError:
        return 'Không thể kết nối tới server. Kiểm tra kết nối mạng.';

      case DioExceptionType.unknown:
        return (e.message?.contains('SocketException') ?? false)
            ? 'Không thể kết nối tới server.'
            : 'Lỗi mạng. Vui lòng kiểm tra kết nối.';

      case DioExceptionType.badResponse:
        return _messageFromResponse(e.response);

      default:
        return 'Đã có lỗi xảy ra. Vui lòng thử lại.';
    }
  }

  /// Extract message from backend ApiResponse envelope, then fall back to
  /// HTTP status code description.
  ///
  /// Priority order:
  /// 1. ValidationErrors (formatted as bullet list)
  /// 2. ApiResponse.Message
  /// 3. Error.Message
  /// 4. Status code fallback
  String _messageFromResponse(Response? response) {
    if (response?.data is Map) {
      final data = response!.data as Map;

      // Priority 1: Check for validation errors (most specific)
      if (data['error'] is Map) {
        final err = data['error'] as Map;
        
        // Format: error.validationErrors (Dictionary<string, string[]>)
        if (err['validationErrors'] is Map) {
          final validationErrors = err['validationErrors'] as Map;
          final errorMessages = <String>[];
          
          validationErrors.forEach((field, messages) {
            if (messages is List && messages.isNotEmpty) {
              // Format: "Field: error1, error2"
              errorMessages.add('${field}: ${messages.join(', ')}');
            } else if (messages != null) {
              errorMessages.add('${field}: $messages');
            }
          });
          
          if (errorMessages.isNotEmpty) {
            return errorMessages.join('\n');
          }
        }
      }

      // Priority 2: Main message from ApiResponse
      if (data['message'] != null && data['message'].toString().isNotEmpty) {
        return data['message'].toString();
      }

      // Priority 3: Error message (if exists)
      if (data['error'] is Map) {
        final err = data['error'] as Map;
        if (err['message'] != null && err['message'].toString().isNotEmpty) {
          return err['message'].toString();
        }
      }
    }

    // Priority 4: Fallback to status code
    return _messageFromStatusCode(response?.statusCode);
  }

  String _messageFromStatusCode(int? code) {
    switch (code) {
      case 400:
        return 'Yêu cầu không hợp lệ.';
      case 401:
        return 'Không có quyền truy cập.';
      case 403:
        return 'Truy cập bị cấm.';
      case 404:
        return 'Không tìm thấy.';
      case 500:
        return 'Lỗi máy chủ.';
      case 503:
        return 'Dịch vụ không khả dụng.';
      default:
        return 'Đã có lỗi xảy ra (${code ?? 'unknown'}).';
    }
  }
}
