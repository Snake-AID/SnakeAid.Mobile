import 'user_role.dart';

/// User model
/// Model người dùng trong hệ thống
class User {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    required this.role,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'],
      role: _getRoleFromInt(json['role']),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  /// Convert role int to UserRole enum
  static UserRole _getRoleFromInt(dynamic roleValue) {
    if (roleValue == null) return UserRole.member;
    
    int roleInt = roleValue is int ? roleValue : int.tryParse(roleValue.toString()) ?? 0;
    
    switch (roleInt) {
      case 0:
        return UserRole.member;
      case 1:
        return UserRole.rescuer;
      case 2:
        return UserRole.expert;
      default:
        return UserRole.member;
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': _roleToInt(role),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Convert UserRole to int
  static int _roleToInt(UserRole role) {
    switch (role) {
      case UserRole.member:
        return 0;
      case UserRole.rescuer:
        return 1;
      case UserRole.expert:
        return 2;
    }
  }

  @override
  String toString() => 
      'User(id: $id, email: $email, fullName: $fullName, role: ${role.displayName})';
}
