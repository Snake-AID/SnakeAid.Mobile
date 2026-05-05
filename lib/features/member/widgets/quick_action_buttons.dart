import 'package:flutter/material.dart';

/// Two quick action buttons: AI Camera + Expert Consultation
class QuickActionButtons extends StatelessWidget {
  final VoidCallback onCameraPressed;
  final VoidCallback onConsultationPressed;
  final bool isLocationSupported;

  const QuickActionButtons({
    super.key,
    required this.onCameraPressed,
    required this.onConsultationPressed,
    this.isLocationSupported = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLocationSupported) {
      return _buildModernCard(
        onTap: onConsultationPressed,
        backgroundColor: Colors.white,
        icon: Icons.support_agent_rounded,
        iconBackgroundColor: const Color(0xFF228B22).withOpacity(0.1),
        iconColor: const Color(0xFF228B22),
        title: 'Tư vấn Chuyên gia',
        titleColor: const Color(0xFF228B22),
        subtitle: 'Kết nối ngay với chuyên gia rắn',
        subtitleColor: Colors.grey[600]!,
        shadowColor: Colors.black.withOpacity(0.05),
        borderColor: Colors.grey[200],
      );
    }

    return Row(
      children: [
        // AI Camera Button (Primary Action)
        Expanded(
          child: _buildModernCard(
            onTap: onCameraPressed,
            backgroundColor: const Color(0xFF228B22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2E9B2E), Color(0xFF1B6E1B)],
            ),
            icon: Icons.document_scanner_outlined,
            iconBackgroundColor: Colors.white.withOpacity(0.2),
            iconColor: Colors.white,
            title: 'Cần bắt rắn',
            titleColor: Colors.white,
            subtitle: 'Đặt dịch vụ bắt rắn',
            subtitleColor: Colors.white.withOpacity(0.85),
            shadowColor: const Color(0xFF228B22).withOpacity(0.4),
          ),
        ),
        const SizedBox(width: 16),
        // Consultation Button (Secondary Action)
        Expanded(
          child: _buildModernCard(
            onTap: onConsultationPressed,
            backgroundColor: Colors.white,
            icon: Icons.support_agent_rounded,
            iconBackgroundColor: const Color(0xFF228B22).withOpacity(0.1),
            iconColor: const Color(0xFF228B22),
            title: 'Tư vấn',
            titleColor: const Color(0xFF228B22),
            subtitle: 'Chuyên gia',
            subtitleColor: Colors.grey[600]!,
            shadowColor: Colors.black.withOpacity(0.05),
            borderColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  Widget _buildModernCard({
    required VoidCallback onTap,
    required Color backgroundColor,
    LinearGradient? gradient,
    required IconData icon,
    required Color iconBackgroundColor,
    required Color iconColor,
    required String title,
    required Color titleColor,
    required String subtitle,
    required Color subtitleColor,
    required Color shadowColor,
    Color? borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        border: borderColor != null ? Border.all(color: borderColor, width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: subtitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
