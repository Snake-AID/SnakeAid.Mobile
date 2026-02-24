import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor để logging requests/responses
/// Chỉ log khi ở debug mode
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(
        '📤 REQUEST [${options.method}] => ${options.baseUrl}${options.path}',
      );
      if (options.queryParameters.isNotEmpty) {
        debugPrint('📋 Query: ${options.queryParameters}');
      }
      if (options.headers.isNotEmpty) {
        // Mask sensitive headers
        final maskedHeaders = Map<String, dynamic>.from(options.headers);
        if (maskedHeaders.containsKey('Authorization')) {
          final auth = maskedHeaders['Authorization'].toString();
          maskedHeaders['Authorization'] = auth.length > 14
              ? '${auth.substring(0, 10)}...${auth.substring(auth.length - 4)}'
              : auth;
        }
        debugPrint('📋 Headers: $maskedHeaders');
      }
      if (options.data != null) {
        debugPrint('📋 Body: ${options.data}');
      }
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(
        '📥 RESPONSE [${response.statusCode}] => ${response.requestOptions.path}',
      );
      debugPrint('📋 Data: ${response.data}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(
        '❌ ERROR [${err.response?.statusCode}] => ${err.requestOptions.path}',
      );
      debugPrint('❌ Type: ${err.type}');
      debugPrint('❌ Message: ${err.message}');
      if (err.response?.data != null) {
        debugPrint('❌ Response: ${err.response?.data}');
      }
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
    super.onError(err, handler);
  }
}
