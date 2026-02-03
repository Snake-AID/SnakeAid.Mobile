/// Verify account response model
/// Model cho response sau khi verify account thành công
class VerifyAccountResponse {
  final int statusCode;
  final String message;
  final bool isSuccess;
  final AuthData? authData;
  final ErrorData? error;

  VerifyAccountResponse({
    required this.statusCode,
    required this.message,
    required this.isSuccess,
    this.authData,
    this.error,
  });

  /// Create from JSON response
  factory VerifyAccountResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    
    return VerifyAccountResponse(
      statusCode: json['status_code'] ?? 0,
      message: json['message'] ?? '',
      isSuccess: json['is_success'] ?? false,
      authData: data != null && data['authData'] != null
          ? AuthData.fromJson(data['authData'])
          : null,
      error: json['error'] != null 
          ? ErrorData.fromJson(json['error']) 
          : null,
    );
  }

  @override
  String toString() => 
      'VerifyAccountResponse(isSuccess: $isSuccess, message: $message)';
}

/// Auth data from verify response
class AuthData {
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAt;
  final DateTime refreshTokenExpiresAt;
  final UserInfo user;

  AuthData({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    required this.refreshTokenExpiresAt,
    required this.user,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      accessTokenExpiresAt: json['accessTokenExpiresAt'] != null
          ? DateTime.parse(json['accessTokenExpiresAt'])
          : DateTime.now(),
      refreshTokenExpiresAt: json['refreshTokenExpiresAt'] != null
          ? DateTime.parse(json['refreshTokenExpiresAt'])
          : DateTime.now(),
      user: UserInfo.fromJson(json['user'] ?? {}),
    );
  }
}

/// User info from verify response
class UserInfo {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String role;
  final bool isActive;

  UserInfo({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    required this.role,
    required this.isActive,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      avatarUrl: json['avatarUrl'],
      role: json['role'] ?? 'Member',
      isActive: json['isActive'] ?? false,
    );
  }
}

/// Error data from response
class ErrorData {
  final String? errorCode;
  final DateTime? timestamp;
  final Map<String, List<String>>? validationErrors;

  ErrorData({
    this.errorCode,
    this.timestamp,
    this.validationErrors,
  });

  factory ErrorData.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>>? validationErrors;
    if (json['validationErrors'] != null) {
      validationErrors = {};
      final errors = json['validationErrors'] as Map<String, dynamic>;
      errors.forEach((key, value) {
        if (value is List) {
          validationErrors![key] = value.map((e) => e.toString()).toList();
        }
      });
    }

    return ErrorData(
      errorCode: json['errorCode'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
      validationErrors: validationErrors,
    );
  }
}
