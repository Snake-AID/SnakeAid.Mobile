/// Login response model
/// Model cho response sau khi đăng nhập thành công
class LoginResponse {
  final int statusCode;
  final String message;
  final bool isSuccess;
  final LoginData? data;

  LoginResponse({
    required this.statusCode,
    required this.message,
    required this.isSuccess,
    this.data,
  });

  /// Create from JSON response
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      statusCode: json['status_code'] ?? 0,
      message: json['message'] ?? '',
      isSuccess: json['is_success'] ?? false,
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
    );
  }

  @override
  String toString() => 'LoginResponse(isSuccess: $isSuccess, message: $message)';
}

/// Login data containing tokens and user info
class LoginData {
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAt;
  final DateTime refreshTokenExpiresAt;
  final UserData user;

  LoginData({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    required this.refreshTokenExpiresAt,
    required this.user,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      accessTokenExpiresAt: json['accessTokenExpiresAt'] != null
          ? DateTime.parse(json['accessTokenExpiresAt'])
          : DateTime.now(),
      refreshTokenExpiresAt: json['refreshTokenExpiresAt'] != null
          ? DateTime.parse(json['refreshTokenExpiresAt'])
          : DateTime.now(),
      user: UserData.fromJson(json['user'] ?? {}),
    );
  }
}

/// User data from login response
class UserData {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String role;
  final bool isActive;

  UserData({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    required this.role,
    required this.isActive,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      avatarUrl: json['avatarUrl'],
      role: json['role'] ?? 'Member',
      isActive: json['isActive'] ?? false,
    );
  }
}
