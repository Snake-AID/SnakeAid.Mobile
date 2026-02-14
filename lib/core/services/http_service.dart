import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HttpService {
  late final Dio _dio;
  final String baseUrl;
  bool _isRefreshing = false;

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

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Check if token needs refresh (trước khi gửi request)
          final prefs = await SharedPreferences.getInstance();
          final tokenExpiryStr = prefs.getString('token_expiry');
          
          if (tokenExpiryStr != null) {
            final tokenExpiry = DateTime.parse(tokenExpiryStr);
            final now = DateTime.now();
            
            // Nếu token sắp hết hạn (hoặc đã hết), refresh trước
            if ((now.isAfter(tokenExpiry) || now.isAtSameMomentAs(tokenExpiry)) && !_isRefreshing) {
              debugPrint('⏰ Token sắp hết hạn, refreshing proactively...');
              _isRefreshing = true;
              
              final refreshToken = prefs.getString('refresh_token');
              final userId = prefs.getString('user_id');
              
              if (refreshToken != null && userId != null) {
                try {
                  // Gọi API refresh token
                  final refreshResponse = await _dio.post(
                    '/api/auth/refresh',
                    data: {
                      'userId': userId,
                      'refreshToken': refreshToken,
                    },
                  );
                  
                  // Lưu token mới
                  if (refreshResponse.data != null && 
                      refreshResponse.data['is_success'] == true &&
                      refreshResponse.data['data'] != null) {
                    final newAccessToken = refreshResponse.data['data']['accessToken'];
                    final newRefreshToken = refreshResponse.data['data']['refreshToken'];
                    
                    await prefs.setString('access_token', newAccessToken);
                    await prefs.setString('refresh_token', newRefreshToken);
                    await prefs.setString('auth_token', newAccessToken);
                    
                    // Cập nhật expiry time mới (refresh trước 5 phút)
                    final newExpiry = DateTime.now().add(const Duration(minutes: 55));
                    await prefs.setString('token_expiry', newExpiry.toIso8601String());
                    
                    debugPrint('✅ Token refreshed proactively');
                    debugPrint('⏰ Next refresh at: $newExpiry');
                    
                    // Cập nhật header với token mới
                    options.headers['Authorization'] = 'Bearer $newAccessToken';
                    _isRefreshing = false;
                  } else {
                    // Refresh thất bại, clear session
                    _isRefreshing = false;
                    await prefs.remove('access_token');
                    await prefs.remove('refresh_token');
                    await prefs.remove('user_id');
                    await prefs.remove('auth_token');
                    await prefs.remove('token_expiry');
                    debugPrint('🗑️ Session cleared due to refresh failure');
                  }
                } catch (e) {
                  debugPrint('❌ Proactive refresh failed: $e');
                  _isRefreshing = false;
                  // Clear session khi refresh thất bại
                  await prefs.remove('access_token');
                  await prefs.remove('refresh_token');
                  await prefs.remove('user_id');
                  await prefs.remove('auth_token');
                  await prefs.remove('token_expiry');
                  debugPrint('🗑️ Session cleared due to refresh error');
                }
              } else {
                _isRefreshing = false;
              }
            }
          }
          
          // Add auth token if available
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          debugPrint('📤 REQUEST[${options.method}] => ${options.path}');
          debugPrint('📋 Data: ${options.data}');
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          debugPrint('📥 RESPONSE[${response.statusCode}] => ${response.requestOptions.path}');
          debugPrint('📋 Data: ${response.data}');
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          return handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          debugPrint('❌ ERROR[${error.response?.statusCode}] => ${error.requestOptions.path}');
          debugPrint('❌ Message: ${error.message}');
          debugPrint('❌ Response: ${error.response?.data}');
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          
          // Danh sách các endpoint không cần refresh token khi gặp 401
          final publicEndpoints = [
            '/api/auth/login',
            '/api/auth/register',
            '/api/auth/refresh',
            '/api/email/send-otp',
            '/api/email/verify',
          ];
          
          final requestPath = error.requestOptions.path;
          final isPublicEndpoint = publicEndpoints.any((endpoint) => requestPath.contains(endpoint));
          
          // Auto refresh token nếu gặp 401 Unauthorized (fallback)
          // NHƯNG không refresh nếu là public endpoint (login/register/verify)
          if (error.response?.statusCode == 401 && !isPublicEndpoint && !_isRefreshing) {
            debugPrint('🔄 Token expired (401), attempting fallback refresh...');
            _isRefreshing = true;
            
            // Lấy refresh token và userId
            final prefs = await SharedPreferences.getInstance();
            final refreshToken = prefs.getString('refresh_token');
            final userId = prefs.getString('user_id');
            
            if (refreshToken != null && userId != null) {
              try {
                // Gọi API refresh token
                final refreshResponse = await _dio.post(
                  '/api/auth/refresh',
                  data: {
                    'userId': userId,
                    'refreshToken': refreshToken,
                  },
                );
                
                // Lưu token mới
                if (refreshResponse.data != null && 
                    refreshResponse.data['is_success'] == true &&
                    refreshResponse.data['data'] != null) {
                  final newAccessToken = refreshResponse.data['data']['accessToken'];
                  final newRefreshToken = refreshResponse.data['data']['refreshToken'];
                  
                  await prefs.setString('access_token', newAccessToken);
                  await prefs.setString('refresh_token', newRefreshToken);
                  await prefs.setString('auth_token', newAccessToken);
                  
                  // Cập nhật expiry time
                  final newExpiry = DateTime.now().add(const Duration(minutes: 55));
                  await prefs.setString('token_expiry', newExpiry.toIso8601String());
                  
                  debugPrint('✅ Token refreshed (fallback)');
                  _isRefreshing = false;
                  
                  // Retry request ban đầu với token mới
                  error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                  final cloneReq = await _dio.fetch(error.requestOptions);
                  return handler.resolve(cloneReq);
                } else {
                  // Refresh response không hợp lệ
                  _isRefreshing = false;
                  await prefs.remove('access_token');
                  await prefs.remove('refresh_token');
                  await prefs.remove('user_id');
                  await prefs.remove('auth_token');
                  await prefs.remove('token_expiry');
                  debugPrint('🗑️ Session cleared - invalid refresh response');
                }
              } catch (e) {
                debugPrint('❌ Fallback refresh failed: $e');
                _isRefreshing = false;
                // Clear session nếu refresh thất bại
                await prefs.remove('access_token');
                await prefs.remove('refresh_token');
                await prefs.remove('user_id');
                await prefs.remove('auth_token');
                await prefs.remove('token_expiry');
                debugPrint('🗑️ Session cleared due to refresh failure');
              }
            } else {
              _isRefreshing = false;
            }
          } else if (error.response?.statusCode == 401 && isPublicEndpoint) {
            debugPrint('⚠️ 401 on public endpoint - không refresh token');
          }
          
          return handler.next(error);
        },
      ),
    );
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

  // Error handler - extracts message from ApiResponse structure
  String _handleError(DioException error) {
    debugPrint('🔍 Handling DioException: ${error.type}');
    
    String errorMessage;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Kết nối timeout. Vui lòng thử lại.';
        break;
      case DioExceptionType.badResponse:
        // Try to extract message from ApiResponse structure
        if (error.response?.data != null) {
          debugPrint('🔍 Response data type: ${error.response?.data.runtimeType}');
          
          if (error.response?.data is Map) {
            final data = error.response?.data as Map;
            debugPrint('🔍 Response keys: ${data.keys}');
            
            // Backend returns ApiResponse with 'message' field
            if (data.containsKey('message')) {
              errorMessage = data['message'].toString();
            } else if (data.containsKey('error') && data['error'] is Map) {
              final errorData = data['error'] as Map;
              errorMessage = errorData['message']?.toString() ?? _handleHttpError(error.response?.statusCode);
            } else {
              errorMessage = _handleHttpError(error.response?.statusCode);
            }
          } else {
            errorMessage = error.response?.data.toString() ?? _handleHttpError(error.response?.statusCode);
          }
        } else {
          errorMessage = _handleHttpError(error.response?.statusCode);
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request đã bị hủy.';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'Không thể kết nối tới server. Kiểm tra kết nối mạng.';
        break;
      case DioExceptionType.unknown:
        errorMessage = error.message?.contains('SocketException') ?? false
            ? 'Không thể kết nối tới server'
            : 'Lỗi mạng. Vui lòng kiểm tra kết nối.';
        break;
      default:
        errorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại.';
    }
    
    debugPrint('🔍 Final error message: $errorMessage');
    return errorMessage;
  }

  String _handleHttpError(int? statusCode) {
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

  // Save auth token
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear auth token
  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Get auth token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
