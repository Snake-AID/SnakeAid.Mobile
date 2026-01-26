import 'package:flutter/material.dart';

/// Giant SOS button - Emergency-first design
/// 
/// Long-press 3 seconds to activate SOS call
class SosButton extends StatefulWidget {
  final VoidCallback onActivate;
  
  const SosButton({
    super.key,
    required this.onActivate,
  });

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isPressed = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() => _isPressed = true);
    // Animate progress over 2 seconds with smooth 60fps animation
    Future.delayed(Duration.zero, () async {
      const totalFrames = 60; // 60 frames for 2 seconds = 60fps
      const frameDuration = Duration(milliseconds: 33); // ~30fps (smoother)
      
      for (int i = 0; i <= totalFrames; i++) {
        if (!_isPressed) break;
        await Future.delayed(frameDuration);
        if (mounted) {
          setState(() => _progress = i / totalFrames);
        }
        if (i == totalFrames) {
          widget.onActivate();
        }
      }
    });
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    setState(() {
      _isPressed = false;
      _progress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onLongPressStart: _onLongPressStart,
          onLongPressEnd: _onLongPressEnd,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDC3545), Color(0xFFFF0000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFDC3545).withOpacity(
                        0.3 + (_pulseController.value * 0.2),
                      ),
                      blurRadius: 20 + (_pulseController.value * 10),
                      spreadRadius: 5 + (_pulseController.value * 5),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Progress ring when pressed with smooth animation
                    if (_isPressed)
                      SizedBox(
                        width: 240,
                        height: 240,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: _progress),
                          duration: const Duration(milliseconds: 33),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return CircularProgressIndicator(
                              value: value,
                              strokeWidth: 6,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    // SOS text
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'SOS',
                          style: TextStyle(
                            fontSize: _isPressed ? 36 : 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Cấp cứu rắn cắn',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Giữ 2 giây để kích hoạt',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Gửi GPS + gọi đội cứu hộ gần nhất',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF228B22),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
