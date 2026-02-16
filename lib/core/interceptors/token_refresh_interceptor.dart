import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Interceptor xử lý token refresh tự động
/// - Proactive refresh: Refresh token TRƯỚC khi hết hạn (5 phút trước)
/// - Fallback refresh: Retry khi gặp 401 Unauthorized
/// - Session preservation: KHÔNG force logout, giữ session như Facebook
class TokenRefreshInterceptor extends Interceptor {
  final Dio dio;

  // Public endpoints không cần token hoặc refresh
  static const _publicEndpoints = [
    '/api/auth/login',
    '/api/auth/register',
    '/api/auth/refresh',
    '/api/email/send-otp',
    '/api/email/verify',
  ];

  TokenRefreshInterceptor(this.dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip cho public endpoints
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    try {
      // Proactive token refresh: Check nếu token sắp hết hạn
      await _proactiveRefreshIfNeeded();

      // Add auth header
      final token = await _getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      return handler.next(options);
    } catch (e) {
      debugPrint('⚠️ Error in request interceptor: $e');
      return handler.next(options);
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Skip cho public endpoints
    if (_isPublicEndpoint(err.requestOptions.path)) {
      return handler.next(err);
    }

    // Fallback refresh: Nếu gặp 401, thử refresh token và retry
    if (err.response?.statusCode == 401) {
      debugPrint('🔄 Got 401, attempting fallback token refresh...');

      final refreshed = await _fallbackRefresh();

      if (refreshed) {
        // Retry request với token mới
        try {
          final token = await _getAccessToken();
          err.requestOptions.headers['Authorization'] = 'Bearer $token';

          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          debugPrint('❌ Retry after refresh failed: $e');
          return handler.next(err);
        }
      } else {
        // 🔴 BUG FIX: Refresh thất bại → FORCE LOGOUT
        debugPrint('🚨 Token refresh failed, forcing session logout...');
        await _forceLogout();
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  /// Proactive refresh: Refresh token nếu sắp hết hạn
  Future<void> _proactiveRefreshIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenExpiryStr = prefs.getString('token_expiry');

      if (tokenExpiryStr == null) return;

      final tokenExpiry = DateTime.parse(tokenExpiryStr);
      final now = DateTime.now();

      // Refresh nếu token đã hết hạn HOẶC sắp hết hạn trong 5 phút
      final isExpired = now.isAfter(tokenExpiry);
      final isExpiringSoon = now.isAfter(
        tokenExpiry.subtract(const Duration(minutes: 5)),
      );

      if (isExpired || isExpiringSoon) {
        debugPrint(
          '⏰ Token ${isExpired ? "expired" : "expiring soon"}, proactive refresh...',
        );
        await _refreshToken();
      }
    } catch (e) {
      debugPrint('⚠️ Proactive refresh check failed: $e');
    }
  }

  /// Fallback refresh: Gọi khi gặp 401
  Future<bool> _fallbackRefresh() async {
    try {
      debugPrint('🔄 Fallback token refresh...');
      return await _refreshToken();
    } catch (e) {
      debugPrint('❌ Fallback refresh failed: $e');
      return false;
    }
  }

  /// Thực hiện refresh token
  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      final userId = prefs.getString('user_id');

      if (refreshToken == null || userId == null) {
        debugPrint('⚠️ No refresh token or userId available');
        return false;
      }

      // Call refresh API
      final response = await dio.post(
        '/api/auth/refresh',
        data: {'userId': userId, 'refreshToken': refreshToken},
      );

      // Parse response
      if (response.data != null &&
          response.data['is_success'] == true &&
          response.data['data'] != null) {
        final newAccessToken = response.data['data']['accessToken'] as String;
        final newRefreshToken = response.data['data']['refreshToken'] as String;

        // Save new tokens
        await prefs.setString('access_token', newAccessToken);
        await prefs.setString('refresh_token', newRefreshToken);
        await prefs.setString('auth_token', newAccessToken);

        // Update expiry time (55 minutes from now)
        final newExpiry = DateTime.now().add(const Duration(minutes: 55));
        await prefs.setString('token_expiry', newExpiry.toIso8601String());

        // Clear needs_reauth flag nếu có
        await prefs.remove('token_needs_reauth');

        debugPrint('✅ Token refreshed successfully');
        debugPrint('⏰ New expiry: $newExpiry');

        return true;
      }

      debugPrint('⚠️ Refresh response invalid');
      return false;
    } catch (e) {
      debugPrint('❌ Token refresh failed: $e');
      return false;
    }
  }

  /// Get access token từ storage
  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? prefs.getString('auth_token');
  }

  /// 🔴 Force logout: Clear all session data khi token hết hạn
  /// Called when refresh token fails or is invalid
  Future<void> _forceLogout() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🚨 FORCE LOGOUT: Clearing session due to token expiration');

      final prefs = await SharedPreferences.getInstance();

      // Clear ALL auth-related data
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
      await prefs.remove('token_expiry');
      await prefs.remove('cached_user');
      await prefs.remove('token_needs_reauth');

      // Set flag to trigger UI logout
      await prefs.setBool('force_logout_required', true);

      debugPrint('✅ Session cleared, logout flag set');
      debugPrint('📱 App should redirect to login screen');
    } catch (e) {
      debugPrint('❌ Force logout error: $e');
    }
  }

  /// Check if endpoint is public (không cần auth)
  bool _isPublicEndpoint(String path) {
    return _publicEndpoints.any((endpoint) => path.contains(endpoint));
  }
}
