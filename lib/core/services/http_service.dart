import 'package:dio/dio.dart';
import '../interceptors/token_refresh_interceptor.dart';
import '../interceptors/logging_interceptor.dart';

/// HTTP Service - Simplified
/// Chỉ làm HTTP client wrapper, không quản lý auth logic
/// Token refresh được xử lý bởi TokenRefreshInterceptor
class HttpService {
  late final Dio _dio;
  final String baseUrl;

  HttpService({required this.baseUrl}) {
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

    // Add interceptors (in order)
    _dio.interceptors.addAll([
      LoggingInterceptor(), // Logging trước
      TokenRefreshInterceptor(_dio), // Token refresh sau
    ]);
  }

  Dio get dio => _dio;

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors và extract user-friendly messages
  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Kết nối timeout. Vui lòng thử lại.';

      case DioExceptionType.badResponse:
        return _extractErrorMessage(error.response);

      case DioExceptionType.cancel:
        return 'Request đã bị hủy.';

      case DioExceptionType.connectionError:
        return 'Không thể kết nối tới server. Kiểm tra kết nối mạng.';

      case DioExceptionType.unknown:
        return error.message?.contains('SocketException') ?? false
            ? 'Không thể kết nối tới server'
            : 'Lỗi mạng. Vui lòng kiểm tra kết nối.';

      default:
        return 'Đã có lỗi xảy ra. Vui lòng thử lại.';
    }
  }

  /// Extract error message từ response data (ApiResponse structure)
  String _extractErrorMessage(Response? response) {
    if (response?.data == null) {
      return _getHttpErrorMessage(response?.statusCode);
    }

    // Try to extract from backend ApiResponse format
    if (response!.data is Map) {
      final data = response.data as Map;

      // Priority: message > error.message > HTTP status message
      if (data.containsKey('message')) {
        return data['message'].toString();
      }

      if (data.containsKey('error') && data['error'] is Map) {
        final errorData = data['error'] as Map;
        if (errorData.containsKey('message')) {
          return errorData['message'].toString();
        }
      }
    }

    return _getHttpErrorMessage(response.statusCode);
  }

  /// Get generic error message based on HTTP status code
  String _getHttpErrorMessage(int? statusCode) {
    switch (statusCode) {
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
        return 'Đã có lỗi xảy ra (${statusCode ?? 'unknown'}).';
    }
  }
}
