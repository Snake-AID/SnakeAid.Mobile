import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snakeaid_mobile/features/auth/models/user_role.dart';

/// Welcome Screen - Role Selection
/// Màn hình chọn vai trò trước khi đăng nhập/đăng ký
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo Container - Lớn hơn và nổi bật
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF228B22).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.asset(
                            'assets/images/logo/snakeaid_logo.png',
                            width: 105,
                            height: 105,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.health_and_safety,
                                size: 60,
                                color: Color(0xFF228B22),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Welcome Text
                  const Text(
                    'Chào mừng đến với',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // App Name - Đảm bảo màu #228B22
                  const Text(
                    'SnakeAid',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF228B22),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Instruction Text
                  const Text(
                    'Bạn là ai?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vui lòng chọn vai trò của bạn để tiếp tục',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              
              // Role Cards
              Expanded(
                child: ListView(
                  children: [
                    _RoleCard(
                      role: UserRole.member,
                      icon: Icons.person,
                      onTap: () => _navigateToAuth(context, UserRole.member),
                    ),
                    const SizedBox(height: 16),
                    
                    _RoleCard(
                      role: UserRole.rescuer,
                      icon: Icons.local_hospital,
                      onTap: () => _navigateToAuth(context, UserRole.rescuer),
                    ),
                    const SizedBox(height: 16),
                    
                    _RoleCard(
                      role: UserRole.expert,
                      icon: Icons.verified,
                      onTap: () => _navigateToAuth(context, UserRole.expert),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAuth(BuildContext context, UserRole role) {
    // Navigate to login screen based on role
    if (role == UserRole.member) {
      context.goNamed('member_login');
    } else if (role == UserRole.rescuer) {
      context.goNamed('rescuer_login');
    } else if (role == UserRole.expert) {
      context.goNamed('expert_login');
    }
  }
}

/// Role Card Widget
/// Widget thẻ chọn vai trò
class _RoleCard extends StatelessWidget {
  final UserRole role;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.icon,
    required this.onTap,
  });

  Color _getRoleColor() {
    switch (role) {
      case UserRole.member:
        return const Color(0xFF228B22); // Xanh lá
      case UserRole.rescuer:
        return const Color(0xFFFF8800); // Cam
      case UserRole.expert:
        return const Color(0xFF6C47C2); // Tím
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor();
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 28,
                color: roleColor,
              ),
            ),
            const SizedBox(width: 16),
            
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: roleColor,
            ),
          ],
        ),
      ),
    );
  }
}
