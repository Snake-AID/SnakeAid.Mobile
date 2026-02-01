import 'package:flutter/material.dart';
import 'dart:math';
import 'package:go_router/go_router.dart';

/// Registration Success Screen
/// Màn hình đăng ký thành công với hiệu ứng confetti
class RegistrationSuccessScreen extends StatefulWidget {
  final String email;
  final String roleRoute; // Which login screen to return to
  final Color themeColor; // Role-specific color

  const RegistrationSuccessScreen({
    super.key,
    required this.email,
    required this.roleRoute,
    required this.themeColor,
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

            // Main Content - Centered
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success Icon with Animation
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.themeColor,
                              widget.themeColor.withOpacity(0.7),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.themeColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Title
                    const Text(
                      'Chúc Mừng!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    
                    // Subtitle
                    const Text(
                      'Đăng Ký Thành Công',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A4A4A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // Description
                    const Text(
                      'Tài khoản của bạn đã được tạo thành công. Bây giờ bạn có thể sử dụng đầy đủ các tính năng của SnakeAid.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B6B6B),
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Account Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.themeColor.withOpacity(0.1),
                            widget.themeColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: widget.themeColor.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: widget.themeColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.person_outline_rounded,
                              size: 28,
                              color: widget.themeColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tài khoản:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B6B6B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.email,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Primary Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          context.goNamed(widget.roleRoute);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.themeColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          shadowColor: widget.themeColor.withOpacity(0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Bắt Đầu Sử Dụng',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 12),
                            Icon(Icons.arrow_forward_rounded, size: 22),
                          ],
                        ),
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
