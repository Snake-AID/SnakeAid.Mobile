import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/http_provider.dart';
import '../../../core/services/http_service.dart';
import '../models/user.dart';
import '../models/user_role.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';
import '../models/verify_account_request.dart';
import '../models/verify_account_response.dart';
import '../models/send_otp_request.dart';
import '../models/otp_validate_request.dart';
import '../models/otp_validate_response.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/forgot_password_request.dart';
import '../models/refresh_token_request.dart';
import '../models/refresh_token_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return AuthRepository(httpService: httpService);
});

/// Repository for authentication-related API calls
///
/// Handles registration, login, password reset, etc.
class AuthRepository {
  final HttpService httpService;

  AuthRepository({required this.httpService});

  /// Register new user
  ///
  /// Gọi API POST /api/auth/register
  /// Returns [RegisterResponse] với thông tin user đã tạo
  ///
  /// Throws [Exception] nếu đăng ký thất bại
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(
        '📝 Registering user: ${request.email} with role: ${request.role}',
      );
      debugPrint('📝 Request data: ${request.toJson()}');

      final response = await httpService.post(
        '/api/auth/register?role=${request.role}',
        data: request.toJson(),
      );

      debugPrint('✅ Registration successful');
      debugPrint('✅ Response type: ${response.data.runtimeType}');
      debugPrint('✅ Response: ${response.data}');

      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ Registration DioException: ${e.type}');
      debugPrint('❌ Error message: ${e.message}');
      debugPrint('❌ Response data: ${e.response?.data}');
      debugPrint('❌ Status code: ${e.response?.statusCode}');
      throw _handleError(e);
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error type: ${e.runtimeType}');
      debugPrint('❌ Unexpected error: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      throw Exception('Đăng ký thất bại. Vui lòng kiểm tra lại thông tin');
    }
  }

  /// Send OTP to email
  ///
  /// Gọi API POST /api/email/send-otp
  /// Gửi mã OTP qua email để xác thực tài khoản
  ///
  /// Throws [Exception] nếu gửi OTP thất bại
  Future<void> sendOtp(String email) async {
    try {
      debugPrint('📧 Sending OTP to: $email');

      final request = SendOtpRequest(email: email);
      final response = await httpService.post(
        '/api/email/send-otp',
        data: request.toJson(),
      );

      debugPrint('✅ OTP sent successfully');
      debugPrint('✅ Response: ${response.data}');
    } on DioException catch (e) {
      debugPrint('❌ Send OTP failed: ${e.message}');
      debugPrint('❌ Response: ${e.response?.data}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      rethrow;
    }
  }

  /// Verify account with OTP
  ///
  /// Gọi API POST /api/auth/verify-account
  /// Xác thực tài khoản với mã OTP và nhận token
  ///
  /// Returns [VerifyAccountResponse] với auth data và user info
  /// Throws [Exception] nếu verify thất bại
  Future<VerifyAccountResponse> verifyAccount(
    VerifyAccountRequest request,
  ) async {
    try {
      debugPrint('🔐 Verifying account: ${request.email}');
      debugPrint('🔐 Request data: ${request.toJson()}');

      final response = await httpService.post(
        '/api/auth/verify-account',
        data: request.toJson(),
      );

      debugPrint('✅ Account verified successfully');
      debugPrint('✅ Response: ${response.data}');

      final verifyResponse = VerifyAccountResponse.fromJson(response.data);

      // Save auth tokens if available
      if (verifyResponse.authData != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'access_token',
          verifyResponse.authData!.accessToken,
        );
        await prefs.setString(
          'refresh_token',
          verifyResponse.authData!.refreshToken,
        );
        await prefs.setString('user_id', verifyResponse.authData!.user.id);
        debugPrint('✅ Auth tokens saved to SharedPreferences');
      }

      return verifyResponse;
    } on DioException catch (e) {
      debugPrint('❌ Verify account failed: ${e.message}');
      debugPrint('❌ Response: ${e.response?.data}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      rethrow;
    }
  }

  /// Validate OTP for forgot password flow
  ///
  /// Gọi API POST /api/otp/validate
  /// Xác thực OTP trước khi cho phép đặt lại mật khẩu
  Future<OtpValidateResponse> validateOtp(OtpValidateRequest request) async {
    try {
      debugPrint('🔐 Validating OTP for email: ${request.email}');
      debugPrint('🔐 Request data: ${request.toJson()}');

      final response = await httpService.post(
        '/api/otp/validate',
        data: request.toJson(),
      );

      debugPrint('✅ OTP validated successfully');
      debugPrint('✅ Response: ${response.data}');

      return OtpValidateResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ Validate OTP failed: ${e.message}');
      debugPrint('❌ Response: ${e.response?.data}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      rethrow;
    }
  }

  /// Reset password in forgot password flow
  ///
  /// Gọi API POST /api/auth/forgot-password
  /// Trả về message thành công khi đặt lại mật khẩu hoàn tất
  Future<String> forgotPassword(ForgotPasswordRequest request) async {
    try {
      debugPrint('🔄 Resetting password for: ${request.email}');
      debugPrint('🔄 Request data: ${request.toJson()}');

      final response = await httpService.post(
        '/api/auth/forgot-password',
        data: request.toJson(),
      );

      final responseData = response.data as Map<String, dynamic>;
      final message =
          (responseData['message'] as String?) ?? 'Đặt lại mật khẩu thành công';

      debugPrint('✅ Forgot password success: $message');
      return message;
    } on DioException catch (e) {
      debugPrint('❌ Forgot password failed: ${e.message}');
      debugPrint('❌ Response: ${e.response?.data}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      rethrow;
    }
  }

  /// Login user
  ///
  /// Gọi API POST /api/auth/login
  /// Returns [LoginResponse] với tokens và user info
  ///
  /// Throws [Exception] nếu đăng nhập thất bại
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔐 Logging in user: ${request.email}');
      debugPrint('🔐 Request data: ${request.toJson()}');

      final response = await httpService.post(
        '/api/auth/login',
        data: request.toJson(),
      );

      debugPrint('✅ Login successful');
      debugPrint('✅ Response: ${response.data}');

      final loginResponse = LoginResponse.fromJson(response.data);

      // Save tokens and user data if login successful
      if (loginResponse.isSuccess && loginResponse.data != null) {
        await _saveSession(
          accessToken: loginResponse.data!.accessToken,
          refreshToken: loginResponse.data!.refreshToken,
          userId: loginResponse.data!.user.id,
        );
        debugPrint('✅ Session saved (tokens only)');
      }

      return loginResponse;
    } on DioException catch (e) {
      debugPrint('❌ Login DioException: ${e.type}');
      debugPrint('❌ Error message: ${e.message}');
      debugPrint('❌ Response data: ${e.response?.data}');
      throw _handleError(e);
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error type: ${e.runtimeType}');
      debugPrint('❌ Unexpected error: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      throw Exception('Email hoặc mật khẩu không đúng. Vui lòng kiểm tra lại');
    }
  }

  /// Refresh access token
  ///
  /// Gọi API POST /api/auth/refresh
  /// Returns [RefreshTokenResponse] với tokens mới
  ///
  /// Throws [Exception] nếu refresh thất bại
  Future<RefreshTokenResponse> refreshToken(RefreshTokenRequest request) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔄 Refreshing token for user: ${request.userId}');
      debugPrint('🔄 Request data: ${request.toJson()}');

      final response = await httpService.post(
        '/api/auth/refresh',
        data: request.toJson(),
      );

      debugPrint('✅ Token refreshed successfully');
      debugPrint('✅ Response: ${response.data}');

      final refreshResponse = RefreshTokenResponse.fromJson(response.data);

      // Save new tokens if refresh successful
      if (refreshResponse.isSuccess && refreshResponse.data != null) {
        await _saveSession(
          accessToken: refreshResponse.data!.accessToken,
          refreshToken: refreshResponse.data!.refreshToken,
          userId: refreshResponse.data!.user.id,
        );
        debugPrint('✅ New tokens saved');
      }

      return refreshResponse;
    } on DioException catch (e) {
      debugPrint('❌ Refresh token DioException: ${e.type}');
      debugPrint('❌ Error message: ${e.message}');
      debugPrint('❌ Response data: ${e.response?.data}');
      throw _handleError(e);
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error type: ${e.runtimeType}');
      debugPrint('❌ Unexpected error: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      throw Exception('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại');
    }
  }

  /// Save session data to local storage
  /// Saves tokens and expiry time only
  /// 🔥 Cached user is managed separately by auth_provider
  Future<void> _saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    debugPrint('💾 Saving session...');
    debugPrint('  - userId: $userId');

    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    await prefs.setString('user_id', userId);
    await prefs.setString(
      'auth_token',
      accessToken,
    ); // For backward compatibility

    // Lưu thời gian hết hạn (để refresh proactively)
    final expiryTime = DateTime.now().add(
      const Duration(minutes: 55),
    ); // Refresh trước 5 phút
    await prefs.setString('token_expiry', expiryTime.toIso8601String());

    debugPrint('✅ Session saved: userId=$userId');
    debugPrint('✅ Token expiry: $expiryTime');
  }

  /// Get saved session data
  Future<Map<String, String?>> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'access_token': prefs.getString('access_token'),
      'refresh_token': prefs.getString('refresh_token'),
      'user_id': prefs.getString('user_id'),
    };
  }

  /// Get cached user data (for offline access)
  /// Returns null if no cached data
  Future<User?> getCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('cached_user');

      if (cachedJson == null) return null;

      final userData = jsonDecode(cachedJson) as Map<String, dynamic>;

      // Convert cached data to User model
      return User(
        id: userData['id'] ?? '',
        email: userData['email'] ?? '',
        fullName: userData['fullName'] ?? '',
        phoneNumber: null,
        avatarUrl: userData['avatarUrl'],
        isActive: userData['isActive'] ?? true,
        role: _parseUserRole(userData['role'] ?? 'Member'),
        createdAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ Error loading cached user: $e');
      return null;
    }
  }

  /// Parse user role string to UserRole enum
  UserRole _parseUserRole(String roleString) {
    switch (roleString.toUpperCase()) {
      case 'MEMBER':
        return UserRole.member;
      case 'RESCUER':
        return UserRole.rescuer;
      case 'EXPERT':
        return UserRole.expert;
      default:
        return UserRole.member;
    }
  }

  /// Get current logged in user info
  ///
  /// Gọi API GET /api/auth/me để lấy thông tin user hiện tại
  /// Returns [User] nếu token hợp lệ
  /// Returns null nếu không có token hoặc token hết hạn
  ///
  /// Throws [Exception] nếu có lỗi không mong muốn
  Future<User?> getCurrentUser() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('👤 Getting current user info...');

      final response = await httpService.get('/api/auth/me');

      debugPrint('✅ Get current user successful');
      debugPrint('✅ Response: ${response.data}');

      if (response.data is Map<String, dynamic> &&
          response.data['data'] != null) {
        final userData = response.data['data'] as Map<String, dynamic>;
        final user = User.fromJson(userData);
        debugPrint('✅ User: ${user.email}, Role: ${user.role.name}');
        return user;
      }

      debugPrint('⚠️ Unexpected response format');
      return null;
    } on DioException catch (e) {
      debugPrint('❌ Get current user DioException: ${e.type}');
      debugPrint('❌ Status code: ${e.response?.statusCode}');

      // Token hết hạn hoặc không hợp lệ
      if (e.response?.statusCode == 401) {
        debugPrint('⚠️ Unauthorized - token expired or invalid');
        return null;
      }

      throw _handleError(e);
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      throw Exception('Không thể lấy thông tin người dùng');
    }
  }

  /// Logout user
  ///
  /// Gọi API POST /api/auth/logout
  /// Invalidate refresh token và logout khỏi hệ thống
  Future<void> logout() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🚪 Logging out user...');

      await httpService.post('/api/auth/logout');

      debugPrint('✅ Logout API successful');

      // Clear local session data
      await clearSession();

      debugPrint('✅ Logout completed');
    } on DioException catch (e) {
      debugPrint('❌ Logout DioException: ${e.type}');
      debugPrint('❌ Status code: ${e.response?.statusCode}');

      // Dù API thất bại, vẫn clear session local
      await clearSession();
      // 🔴 BUG FIX: KHÔNG throw exception - logout phải luôn thành công
      // User muốn logout → clear session local là đủ
      debugPrint('✅ Logout local successful despite API error');
      return;
    } catch (e) {
      debugPrint('❌ Unexpected error type: ${e.runtimeType}');
      debugPrint('❌ Unexpected error: $e');

      // Clear session dù có lỗi
      await clearSession();

      // 🔴 BUG FIX: KHÔNG throw - logout phải luôn thành công ở client
      debugPrint('✅ Logout local successful despite unexpected error');
      return;
    }
  }

  /// Update current user's FCM device token on backend.
  Future<void> updateDeviceToken(String token) async {
    final sanitizedToken = token.trim();
    if (sanitizedToken.isEmpty) return;

    try {
      await httpService.put(
        '/api/notifications/device-token',
        data: {'deviceToken': sanitizedToken},
      );
      debugPrint('✅ Device token synced to backend');
    } on DioException catch (e) {
      debugPrint('❌ Failed to sync device token: ${e.message}');
      rethrow;
    }
  }

  /// Clear current user's FCM device token on backend.
  Future<void> clearDeviceToken() async {
    try {
      await httpService.delete('/api/notifications/device-token');
      debugPrint('✅ Device token cleared on backend');
    } on DioException catch (e) {
      debugPrint('❌ Failed to clear device token: ${e.message}');
      rethrow;
    }
  }

  /// Clear session data (logout)
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_id');
    await prefs.remove('token_expiry');
    await prefs.remove('auth_token');
    await prefs.remove('cached_user'); // Clear cached user data
    debugPrint('🗑️ Session cleared (including cached user data)');
  }

  /// Handle API errors
  Exception _handleError(DioException e) {
    String errorMessage = 'Đã có lỗi xảy ra';
    final requestPath = e.requestOptions.path.toLowerCase();
    final isLoginEndpoint = requestPath.contains('/api/auth/login');
    final isVerifyOtpEndpoint = requestPath.contains(
      '/api/auth/verify-account',
    );
    final isValidateForgotOtpEndpoint = requestPath.contains(
      '/api/otp/validate',
    );
    final isForgotPasswordEndpoint = requestPath.contains(
      '/api/auth/forgot-password',
    );

    if (e.response != null) {
      final data = e.response?.data;

      // Xử lý error message từ backend
      if (data is Map<String, dynamic>) {
        errorMessage =
            data['message'] ?? data['error'] ?? data['title'] ?? errorMessage;

        // Nếu có validationErrors từ error object
        if (data['error'] is Map && data['error']['validationErrors'] != null) {
          final validationErrors =
              data['error']['validationErrors'] as Map<String, dynamic>;
          final errorList = validationErrors.values
              .expand((e) => e is List ? e : [e])
              .join('\n');
          errorMessage = errorList.isNotEmpty ? errorList : errorMessage;
        }
        // Nếu có errors array (validation errors)
        else if (data['errors'] != null) {
          if (data['errors'] is Map) {
            // Format: { "field": ["error1", "error2"] }
            final errors = data['errors'] as Map<String, dynamic>;
            final errorList = errors.values
                .expand((e) => e is List ? e : [e])
                .join('\n');
            errorMessage = errorList.isNotEmpty ? errorList : errorMessage;
          } else if (data['errors'] is List) {
            errorMessage = (data['errors'] as List).join('\n');
          }
        }
      } else if (data is String) {
        errorMessage = data;
      }

      // Xử lý theo status code
      switch (e.response?.statusCode) {
        case 400:
          // Lỗi dữ liệu không hợp lệ
          if (isVerifyOtpEndpoint || isValidateForgotOtpEndpoint) {
            if (errorMessage == 'Đã có lỗi xảy ra' ||
                errorMessage.toLowerCase().contains('invalid') ||
                errorMessage.toLowerCase().contains('incorrect')) {
              errorMessage =
                  'Mã OTP không hợp lệ hoặc đã hết hạn. Vui lòng kiểm tra lại';
            }
          } else if (isForgotPasswordEndpoint) {
            if (errorMessage == 'Đã có lỗi xảy ra' ||
                errorMessage.toLowerCase().contains('password')) {
              errorMessage =
                  'Mật khẩu mới không hợp lệ. Vui lòng kiểm tra lại thông tin';
            }
          } else if (isLoginEndpoint &&
              (errorMessage.toLowerCase().contains('invalid') ||
                  errorMessage.toLowerCase().contains('incorrect'))) {
            errorMessage = 'Email hoặc mật khẩu không chính xác';
          } else if (errorMessage == 'Đã có lỗi xảy ra') {
            errorMessage = 'Thông tin đăng nhập không hợp lệ';
          }
          break;
        case 401:
          // Unauthorized - thường là sai mật khẩu hoặc tài khoản
          if (isVerifyOtpEndpoint || isValidateForgotOtpEndpoint) {
            errorMessage =
                'Mã OTP không chính xác hoặc đã hết hạn. Vui lòng thử lại';
          } else if (isForgotPasswordEndpoint) {
            errorMessage =
                'Không thể đặt lại mật khẩu do OTP không hợp lệ hoặc đã hết hạn';
          } else if (isLoginEndpoint) {
            errorMessage =
                'Email hoặc mật khẩu không đúng. Vui lòng kiểm tra lại';
          }
          break;
        case 404:
          errorMessage = 'Tài khoản không tồn tại hoặc email chưa được đăng ký';
          break;
        case 409:
          errorMessage = 'Email đã được sử dụng';
          break;
        case 422:
          if (errorMessage == 'Đã có lỗi xảy ra') {
            errorMessage = 'Dữ liệu không hợp lệ';
          }
          break;
        case 500:
          errorMessage = 'Lỗi máy chủ, vui lòng thử lại sau';
          break;
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Kết nối timeout, vui lòng kiểm tra mạng';
    } else if (e.type == DioExceptionType.connectionError) {
      errorMessage = 'Không thể kết nối tới máy chủ';
    }

    return Exception(errorMessage);
  }
}
