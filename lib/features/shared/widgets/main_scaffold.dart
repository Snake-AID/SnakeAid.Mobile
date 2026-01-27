import 'package:flutter/material.dart';
import '../../member/screens/home_screen.dart';
import '../../member/screens/profile_screen.dart';

/// Main scaffold with IndexedStack for instant tab switching
/// This keeps all screens alive and switches between them without rebuild
class MainScaffold extends StatefulWidget {
  final int initialIndex;

  const MainScaffold({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    if (index == 1 || index == 2) {
      // Hospital and Consultation - show coming soon
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(index == 1 ? 'Bệnh viện - Đang phát triển' : 'Tư vấn - Đang phát triển'),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          MemberHomeScreen(),
          SizedBox.shrink(), // Hospital placeholder
          SizedBox.shrink(), // Consultation placeholder
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
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
                isActive: _currentIndex == 0,
                onTap: () => _onTabTapped(0),
              ),
              _NavItem(
                icon: Icons.local_hospital_outlined,
                label: 'Bệnh viện',
                isActive: _currentIndex == 1,
                onTap: () => _onTabTapped(1),
              ),
              _NavItem(
                icon: Icons.forum_outlined,
                label: 'Tư vấn',
                hasNotification: true,
                isActive: _currentIndex == 2,
                onTap: () => _onTabTapped(2),
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: 'Cá nhân',
                isActive: _currentIndex == 3,
                onTap: () => _onTabTapped(3),
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
