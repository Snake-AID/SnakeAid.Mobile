import 'package:flutter/material.dart';
import 'dart:math';
import 'package:go_router/go_router.dart';

/// Registration Success Screen
/// Màn hình đăng ký thành công với hiệu ứng confetti
class RegistrationSuccessScreen extends StatefulWidget {
  final String email;

  const RegistrationSuccessScreen({
    super.key,
    required this.email,
  });

  @override
  State<RegistrationSuccessScreen> createState() => _RegistrationSuccessScreenState();
}

class _RegistrationSuccessScreenState extends State<RegistrationSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Confetti Background
            ..._buildConfetti(),

            // Main Content
            Column(
              children: [
                // Top Section with Success Icon
                Expanded(
                  child: Center(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          color: const Color(0xFF228B22).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(64),
                        ),
                        child: Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFF228B22),
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Middle Section with Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const Text(
                        'Chúc Mừng!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF228B22),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Đăng Ký Thành Công',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tài khoản của bạn đã được tạo thành công. Bây giờ bạn có thể sử dụng đầy đủ các tính năng của SnakeAid.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Account Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 24,
                              color: Color(0xFF666666),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tài khoản:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.email,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Bottom Section with Buttons
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Primary Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Navigate to home screen
                            // For now, go back to role selection
                            context.goNamed('role_selection');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF228B22),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Bắt Đầu Sử Dụng',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Secondary Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            // TODO: Navigate to profile completion screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tính năng hoàn thiện hồ sơ đang phát triển'),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF228B22),
                            side: const BorderSide(
                              color: Color(0xFF228B22),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Hoàn Thiện Hồ Sơ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildConfetti() {
    final random = Random(42); // Fixed seed for consistent positions
    final confettiWidgets = <Widget>[];

    // Regular confetti circles
    final confettiColors = [
      const Color(0xFFA7E0A7), // Light green
      const Color(0xFFF0E68C), // Yellow
      const Color(0xFFADD8E6), // Light blue
    ];

    for (int i = 0; i < 15; i++) {
      confettiWidgets.add(
        Positioned(
          top: random.nextDouble() * 100, // 0-100%
          left: random.nextDouble() * 100,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: confettiColors[i % 3],
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    // Star-shaped confetti
    for (int i = 0; i < 6; i++) {
      confettiWidgets.add(
        Positioned(
          top: random.nextDouble() * 100,
          left: random.nextDouble() * 100,
          child: CustomPaint(
            size: const Size(10, 10),
            painter: StarPainter(confettiColors[i % 3]),
          ),
        ),
      );
    }

    return confettiWidgets;
  }
}

/// Custom painter for star-shaped confetti
class StarPainter extends CustomPainter {
  final Color color;

  StarPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius / 2.5;

    for (int i = 0; i < 10; i++) {
      final angle = (i * 36 - 90) * pi / 180;
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
