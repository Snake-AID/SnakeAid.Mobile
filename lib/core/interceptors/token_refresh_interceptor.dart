import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Result từ refresh token operation
enum RefreshResult {
  success, // Refresh thành công
  invalidToken, // Refresh token không hợp lệ (401)
  networkError, // Lỗi network/server (giữ session)
}

/// Interceptor xử lý token refresh tự động
/// - Proactive refresh: Refresh token TRƯỚC khi hết hạn (5-10 phút trước)
/// - Fallback refresh: Retry khi gặp 401 Unauthorized
/// - Session preservation: KHÔNG force logout khi network error (offline-first)
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

      final refreshResult = await _fallbackRefresh();

      if (refreshResult == RefreshResult.success) {
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
      } else if (refreshResult == RefreshResult.invalidToken) {
        // 🔴 Refresh token không hợp lệ → Force logout
        debugPrint('🚨 Refresh token invalid, forcing logout...');
        await _forceLogout();
        return handler.next(err);
      } else {
        // RefreshResult.networkError → GIỮ session, return error
        debugPrint(
          '⚠️ Refresh failed due to network, keeping session for offline mode',
        );
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  /// Proactive refresh: Refresh token nếu sắp hết hạn
  /// 🔥 CHỈ refresh khi SẮP hết hạn, KHÔNG refresh khi ĐÃ hết hạn
  /// (để tránh clear session khi offline/network error)
  Future<void> _proactiveRefreshIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenExpiryStr = prefs.getString('token_expiry');

      if (tokenExpiryStr == null) return;

      final tokenExpiry = DateTime.parse(tokenExpiryStr);
      final now = DateTime.now();

      // 🔴 CHỈ refresh khi token SẮP hết hạn (5-10 phút trước)
      // KHÔNG refresh nếu đã hết hạn (để giữ session cho offline mode)
      final isExpired = now.isAfter(tokenExpiry);
      final isExpiringSoon =
          now.isAfter(tokenExpiry.subtract(const Duration(minutes: 10))) &&
          !isExpired;

      if (isExpiringSoon) {
        debugPrint('⏰ Token expiring soon, proactive refresh...');
        final result = await _refreshToken();

        if (result != RefreshResult.success) {
          debugPrint(
            '⚠️ Proactive refresh failed: $result, will retry on next request',
          );
          // KHÔNG force logout - giữ session cho offline mode
        }
      } else if (isExpired) {
        debugPrint(
          '⏰ Token expired, waiting for 401 to trigger fallback refresh',
        );
        // KHÔNG force logout - chờ request thất bại rồi fallback refresh
      }
    } catch (e) {
      debugPrint('⚠️ Proactive refresh check failed: $e');
      // KHÔNG force logout - giữ session
    }
  }

  /// Fallback refresh: Gọi khi gặp 401
  Future<RefreshResult> _fallbackRefresh() async {
    try {
      debugPrint('🔄 Fallback token refresh...');
      return await _refreshToken();
    } catch (e) {
      debugPrint('❌ Fallback refresh failed: $e');
      return RefreshResult.networkError;
    }
  }

  /// Thực hiện refresh token với connectivity awareness
  /// Checks network state before making API call to avoid unnecessary timeouts
  Future<RefreshResult> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      final userId = prefs.getString('user_id');

      if (refreshToken == null || userId == null) {
        debugPrint('⚠️ No refresh token or userId available');
        return RefreshResult.invalidToken;
      }

      // 🔥 Check connectivity BEFORE calling API (fast fail if offline)
      try {
        final connectivityResults = await Connectivity().checkConnectivity();
        final isOffline =
            connectivityResults.isEmpty ||
            connectivityResults.every(
              (result) => result == ConnectivityResult.none,
            );

        if (isOffline) {
          debugPrint(
            '📵 No network connection, skipping refresh (offline mode)',
          );
          debugPrint('   → Keeping session for offline access to cached data');
          return RefreshResult
              .networkError; // ← Fast fail, don't wait for timeout
        }

        debugPrint(
          '📶 Network available (${connectivityResults.first.name}), proceeding with refresh...',
        );
      } catch (e) {
        // If connectivity check fails, proceed with API call anyway
        debugPrint(
          '⚠️ Connectivity check failed: $e, proceeding with refresh...',
        );
      }

      // Call refresh API (only when network is available)
      final response = await dio.post(
        '/api/auth/refresh',
        data: {'userId': userId, 'refreshToken': refreshToken},
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 5),
        ),
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

        return RefreshResult.success;
      }

      debugPrint('⚠️ Refresh response invalid');
      return RefreshResult.invalidToken;
    } on DioException catch (e) {
      // Phân biệt giữa network error và invalid token
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        // Server rejected token → Token thật sự invalid
        debugPrint('🚨 Refresh token invalid (${e.response?.statusCode})');
        debugPrint('   → Token expired or revoked, will force logout');
        return RefreshResult.invalidToken;
      }

      // Network/server errors → Keep session for offline mode
      debugPrint('⚠️ Token refresh network error: ${e.type}');
      debugPrint('   → Keeping session, user can access cached data');
      return RefreshResult.networkError;
    } catch (e) {
      debugPrint('❌ Token refresh unexpected error: $e');
      return RefreshResult.networkError;
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
