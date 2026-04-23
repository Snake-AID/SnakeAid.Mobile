/// Forgot password request model
class ForgotPasswordRequest {
  final String email;
  final String otp;
  final String newPassword;
  final String confirmPassword;

  ForgotPasswordRequest({
    required this.email,
    required this.otp,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }

  @override
  String toString() =>
      'ForgotPasswordRequest(email: $email, otp: $otp, newPassword: ***, confirmPassword: ***)';
}
