/// Validate OTP request model for forgot password flow
class OtpValidateRequest {
  final String email;
  final String otp;

  OtpValidateRequest({required this.email, required this.otp});

  Map<String, dynamic> toJson() {
    return {'email': email, 'otp': otp};
  }

  @override
  String toString() => 'OtpValidateRequest(email: $email, otp: $otp)';
}
