import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles automatic token refresh when a mid-session API call returns 401.
///
/// Responsibilities (ONLY these):
/// - Attach Bearer token to every non-public request.
/// - On 401: call /auth/refresh → retry original request.
/// - On refresh 401/403: call [onForceLogout] so the UI redirects to login.
/// - FormData requests: cannot re-send body, update header only, let caller retry.
///
/// NOT responsible for:
/// - Proactive / startup token refresh  →  AuthNotifier._loadSavedSession
/// - Offline detection                  →  AuthNotifier._loadSavedSession
class TokenRefreshInterceptor extends Interceptor {
  final Dio dio;

  /// Called when server rejects the refresh token (401/403).
  /// Wire to AuthNotifier.forceLogout() via http_provider.
  final Future<void> Function() onForceLogout;

  static const _publicEndpoints = [
    '/api/auth/login',
    '/api/auth/register',
    '/api/auth/refresh',
    '/api/auth/logout',
    '/api/auth/verify-account',
    '/api/email/send-otp',
    '/api/email/verify',
  ];

  // Prevent concurrent refresh calls
  bool _isRefreshing = false;
  final _waitingCompleters = <Completer<bool>>[];

  TokenRefreshInterceptor(this.dio, {required this.onForceLogout});

  // ==================== INTERCEPTOR HOOKS ====================

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isPublicEndpoint(options.path)) return handler.next(options);

    final token = await _getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_isPublicEndpoint(err.requestOptions.path)) {
      return handler.next(err);
    }
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    debugPrint('🔄 401 on ${err.requestOptions.path} — refreshing token...');

    // If a refresh is already in flight, wait for its result
    if (_isRefreshing) {
      debugPrint('⏳ Waiting for in-flight refresh...');
      final completer = Completer<bool>();
      _waitingCompleters.add(completer);
      final success = await completer.future;
      if (!success) return handler.next(err);
      return _retryRequest(err, handler);
    }

    // First caller — do the refresh
    _isRefreshing = true;
    final refreshed = await _performRefresh();
    _isRefreshing = false;

    // Wake up waiting requests
    for (final c in _waitingCompleters) {
      c.complete(refreshed);
    }
    _waitingCompleters.clear();

    if (!refreshed) {
      debugPrint('🚨 Refresh token rejected — forcing logout');
      await onForceLogout();
      return handler.next(err);
    }

    return _retryRequest(err, handler);
  }

  // ==================== PRIVATE METHODS ====================

  Future<void> _retryRequest(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final newToken = await _getAccessToken();

    // FormData body cannot be re-sent — update the token header and return
    // the error so the caller (e.g. an upload screen) can show a retry button.
    if (_isFormData(err.requestOptions)) {
      debugPrint('📎 FormData request — token updated, caller must retry');
      err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      return handler.next(err);
    }

    try {
      err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      final response = await dio.fetch(err.requestOptions);
      debugPrint('✅ Retried successfully after token refresh');
      return handler.resolve(response);
    } catch (e) {
      debugPrint('❌ Retry failed: $e');
      return handler.next(err);
    }
  }

  /// Returns true  → tokens saved, caller may retry request.
  /// Returns false → server rejected refresh (401/403), caller must logout.
  /// Network errors return true to avoid false logouts in poor connectivity.
  Future<bool> _performRefresh() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      final userId = prefs.getString('user_id');

      if (refreshToken == null || userId == null) {
        debugPrint('⚠️ No refresh token/userId in storage');
        return false;
      }

      final response = await dio.post(
        '/api/auth/refresh',
        data: {'userId': userId, 'refreshToken': refreshToken},
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final respData = response.data;
      if (respData?['is_success'] == true && respData?['data'] != null) {
        final tokenData = respData['data'] as Map<String, dynamic>;
        final newAccess = tokenData['accessToken'] as String;
        final newRefresh = tokenData['refreshToken'] as String;
        final newUserId =
            (tokenData['user'] as Map<String, dynamic>?)?['id'] as String? ??
            userId;

        await Future.wait([
          prefs.setString('access_token', newAccess),
          prefs.setString('refresh_token', newRefresh),
          prefs.setString('auth_token', newAccess),
          prefs.setString('user_id', newUserId),
          prefs.setString(
            'token_expiry',
            DateTime.now().add(const Duration(minutes: 55)).toIso8601String(),
          ),
        ]);

        debugPrint('✅ Mid-session token refreshed');
        return true;
      }

      debugPrint('⚠️ Refresh response not successful');
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        debugPrint(
          '🚨 Server rejected refresh token (${e.response?.statusCode})',
        );
        return false; // Trigger logout
      }
      // Network/timeout → keep session alive, don't logout
      debugPrint('⚠️ Refresh network error (${e.type}) — keeping session');
      return true;
    } catch (e) {
      debugPrint('⚠️ Refresh unexpected error: $e — keeping session');
      return true;
    }
  }

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? prefs.getString('auth_token');
  }

  bool _isFormData(RequestOptions options) =>
      options.data is FormData ||
      (options.headers['Content-Type']?.toString().contains('multipart') ??
          false);

  bool _isPublicEndpoint(String path) =>
      _publicEndpoints.any((ep) => path.contains(ep));
}
