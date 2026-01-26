import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom Navigation Bar - Reusable across screens
class BottomNavBar extends StatelessWidget {
  final String currentRoute;

  const BottomNavBar({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home,
                label: 'Trang chủ',
                isActive: currentRoute == '/',
                onTap: () => context.go('/'),
              ),
              _NavItem(
                icon: Icons.local_hospital_outlined,
                label: 'Bệnh viện',
                isActive: currentRoute == '/hospital',
                onTap: () {
                  // TODO: Navigate to hospital
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bệnh viện - Đang phát triển')),
                  );
                },
              ),
              _NavItem(
                icon: Icons.forum_outlined,
                label: 'Tư vấn',
                hasNotification: true,
                isActive: currentRoute == '/consultation',
                onTap: () {
                  // TODO: Navigate to consultation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tư vấn - Đang phát triển')),
                  );
                },
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: 'Cá nhân',
                isActive: currentRoute == '/profile',
                onTap: () => context.go('/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool hasNotification;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.hasNotification = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF228B22) : Colors.grey[600];

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: isActive
              ? const Border(
                  top: BorderSide(
                    color: Color(0xFF228B22),
                    width: 3,
                  ),
                )
              : null,
        ),
        padding: const EdgeInsets.only(top: 4),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            if (hasNotification)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
