/// Send OTP request model
/// Model cho request gửi OTP qua email
class SendOtpRequest {
  final String email;

  SendOtpRequest({
    required this.email,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }

  @override
  String toString() => 'SendOtpRequest(email: $email)';
}
