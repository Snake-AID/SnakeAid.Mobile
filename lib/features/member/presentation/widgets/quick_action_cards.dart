import 'package:flutter/material.dart';

/// 3 Quick action cards (horizontal scrollable)
class QuickActionCards extends StatelessWidget {
  final VoidCallback onFirstAidPressed;
  final VoidCallback onHospitalPressed;
  final VoidCallback onTrackRescuerPressed;

  const QuickActionCards({
    super.key,
    required this.onFirstAidPressed,
    required this.onHospitalPressed,
    required this.onTrackRescuerPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _QuickCard(
            title: 'Hướng dẫn',
            subtitle: 'Sơ cứu ngay',
            onTap: onFirstAidPressed,
          ),
          const SizedBox(width: 16),
          _QuickCard(
            title: 'Bệnh viện',
            subtitle: 'Có huyết thanh',
            badge: '2.3 km',
            onTap: onHospitalPressed,
          ),
          const SizedBox(width: 16),
          _QuickCard(
            title: 'Theo dõi',
            subtitle: 'Cứu hộ real-time',
            hasStatusDot: true,
            onTap: onTrackRescuerPressed,
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badge;
  final bool hasStatusDot;
  final VoidCallback onTap;

  const _QuickCard({
    required this.title,
    required this.subtitle,
    this.badge,
    this.hasStatusDot = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF228B22),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            // Badge or status dot
            if (badge != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFC107),
                    ),
                  ),
                ),
              ),
            if (hasStatusDot)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
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
