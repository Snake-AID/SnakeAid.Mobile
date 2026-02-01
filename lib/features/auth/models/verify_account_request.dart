/// Verify account request model
/// Model cho request xác thực tài khoản với OTP
class VerifyAccountRequest {
  final String email;
  final String otp;

  VerifyAccountRequest({
    required this.email,
    required this.otp,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }

  @override
  String toString() => 'VerifyAccountRequest(email: $email, otp: $otp)';
}
