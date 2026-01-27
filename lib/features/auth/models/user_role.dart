/// User role enum for SnakeAid application
/// Định nghĩa các vai trò người dùng trong hệ thống
enum UserRole {
  member('member', 'Người Dùng', 'Người dùng cần hỗ trợ'),
  rescuer('rescuer', 'Người Cứu Hộ', 'Chuyên viên cứu hộ rắn'),
  expert('expert', 'Chuyên Gia', 'Chuyên gia tư vấn về rắn');

  final String value;
  final String displayName;
  final String description;

  const UserRole(this.value, this.displayName, this.description);

  /// Get UserRole from string value
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.member,
    );
  }
}
