/// Register request model
/// Model cho request đăng ký tài khoản mới
class RegisterRequest {
  final String email;
  final String password;
  final String fullName;
  final String phoneNumber;
  final String role; // MEMBER, RESCUER, EXPERT
  final String? type; // For RESCUER: "Emergency", "SnakeCatching", "Both" (hoặc null cho MEMBER/EXPERT)
  final String? biography; // For EXPERT (null cho MEMBER/RESCUER)

  RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    this.type,
    this.biography,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'type': type,
      'biography': biography,
    };
  }

  @override
  String toString() => 
      'RegisterRequest(email: $email, fullName: $fullName, phoneNumber: $phoneNumber, role: $role, type: $type, biography: $biography)';
}
