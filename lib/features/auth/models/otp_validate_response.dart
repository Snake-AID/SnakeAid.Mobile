/// Validate OTP response model for forgot password flow
class OtpValidateResponse {
  final int statusCode;
  final String message;
  final bool isSuccess;
  final OtpValidateData? data;

  OtpValidateResponse({
    required this.statusCode,
    required this.message,
    required this.isSuccess,
    this.data,
  });

  factory OtpValidateResponse.fromJson(Map<String, dynamic> json) {
    return OtpValidateResponse(
      statusCode: json['status_code'] ?? 0,
      message: json['message'] ?? '',
      isSuccess: json['is_success'] ?? false,
      data: json['data'] != null
          ? OtpValidateData.fromJson(json['data'])
          : null,
    );
  }
}

class OtpValidateData {
  final bool success;
  final int attemptsLeft;
  final String message;

  OtpValidateData({
    required this.success,
    required this.attemptsLeft,
    required this.message,
  });

  factory OtpValidateData.fromJson(Map<String, dynamic> json) {
    return OtpValidateData(
      success: json['success'] ?? false,
      attemptsLeft: json['attemptsLeft'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}
