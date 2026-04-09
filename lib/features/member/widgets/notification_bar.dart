import 'package:flutter/material.dart';

/// Notification/Alert bar
class NotificationBar extends StatelessWidget {
  final String message;
  final VoidCallback onViewDetails;

  const NotificationBar({
    super.key,
    required this.message,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onViewDetails,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          border: Border.all(color: const Color(0xFFFFC97A)),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFDC6A00).withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC97A).withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                color: Color(0xFFDC6A00),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cảnh báo mới',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF9A4E00),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: Color(0xFF5A3B00),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Text(
                        'Xem chi tiết',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDC6A00),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Color(0xFFDC6A00),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
