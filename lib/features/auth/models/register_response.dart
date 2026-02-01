/// Register response model
/// Model cho response sau khi đăng ký thành công
class RegisterResponse {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final int role; // 0 = Member
  final DateTime createdAt;
  final String? message;

  RegisterResponse({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    required this.role,
    required this.createdAt,
    this.message,
  });

  /// Create from JSON response
  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      id: json['id'] ?? json['userId'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'],
      role: json['role'] ?? 0, // Default MEMBER = 0
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      message: json['message'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'message': message,
    };
  }

  @override
  String toString() => 
      'RegisterResponse(id: $id, email: $email, fullName: $fullName, role: $role)';
}
