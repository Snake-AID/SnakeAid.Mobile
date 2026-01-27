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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD),
          border: Border.all(
            color: const Color(0xFFFFC107),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Text(
              '⚠️',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF856404),
                  ),
                  children: [
                    TextSpan(text: message),
                    const TextSpan(
                      text: ' Xem chi tiết',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
