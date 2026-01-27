import 'package:flutter/material.dart';

/// Secondary menu grid (2x3) - Professional design
class SecondaryMenuGrid extends StatelessWidget {
  const SecondaryMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _MenuItem(
                icon: Icons.support_agent,
                label: 'Tư vấn\nchuyên gia',
                hasStatusDot: true,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _MenuItem(
                icon: Icons.monitor_heart,
                label: 'Theo dõi\ntriệu chứng',
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _MenuItem(
                icon: Icons.menu_book,
                label: 'Thư viện\nloài rắn',
                badge: '250+',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MenuItem(
                icon: Icons.warning,
                label: 'Cảnh báo\nkhu vực',
                badge: '3',
                badgeColor: Color(0xFFDC3545),
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _MenuItem(
                icon: Icons.receipt_long,
                label: 'Thanh toán\n& lịch sử',
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _MenuItem(
                icon: Icons.play_lesson,
                label: 'Video\nhướng dẫn',
                badge: '12',
                badgeColor: Color(0xFF0D6EFD),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final Color? badgeColor;
  final bool hasStatusDot;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.badge,
    this.badgeColor,
    this.hasStatusDot = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 110,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon with background
                    Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF228B22).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(
                            icon,
                            size: 22,
                            color: const Color(0xFF228B22),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Label
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // Badge
                if (badge != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor ?? const Color(0xFF6C757D),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 16,
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                // Status dot
                if (hasStatusDot)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF228B22),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
