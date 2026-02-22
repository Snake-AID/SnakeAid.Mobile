import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor để logging requests/responses
/// Chỉ log khi ở debug mode
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📤 REQUEST [${options.method}] => ${options.path}');
      if (options.queryParameters.isNotEmpty) {
        debugPrint('📋 Query: ${options.queryParameters}');
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
