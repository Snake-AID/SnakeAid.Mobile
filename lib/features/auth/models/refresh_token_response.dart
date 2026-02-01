import 'login_response.dart';

/// Refresh token response model
/// Model cho response sau khi refresh token thành công
class RefreshTokenResponse {
  final int statusCode;
  final String message;
  final bool isSuccess;
  final LoginData? data;

  RefreshTokenResponse({
    required this.statusCode,
    required this.message,
    required this.isSuccess,
    this.data,
  });

  /// Create from JSON response
  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      statusCode: json['status_code'] ?? 0,
      message: json['message'] ?? '',
      isSuccess: json['is_success'] ?? false,
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
    );
  }

  @override
  String toString() => 'RefreshTokenResponse(isSuccess: $isSuccess, message: $message)';
}
