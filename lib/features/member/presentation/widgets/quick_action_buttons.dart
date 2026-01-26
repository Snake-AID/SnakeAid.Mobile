import 'package:flutter/material.dart';

/// Two quick action buttons: AI Camera + Call 115
class QuickActionButtons extends StatelessWidget {
  final VoidCallback onCameraPressed;
  final VoidCallback onCall115Pressed;

  const QuickActionButtons({
    super.key,
    required this.onCameraPressed,
    required this.onCall115Pressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // AI Camera Button
        Expanded(
          child: InkWell(
            onTap: onCameraPressed,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xFF228B22),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Cần bắt rắn',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF228B22),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Nhận dạng rắn',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Call 115 Button
        Expanded(
          child: InkWell(
            onTap: onCall115Pressed,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFDC3545),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Gọi 115',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Cấp cứu ngay',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
