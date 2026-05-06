import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Renders the snake-warning sign image as a map marker.
///
/// Save the provided PNG to: assets/images/snake_warning.png
/// (assets/images/ is already registered in pubspec.yaml).
///
/// Risk level drives a glow ring around the marker:
///   Extreme  → dark-red glow + pulse dot
///   Critical → red glow + pulse dot
///   High / venomous → orange glow + pulse dot
///   Medium   → yellow (same as base sign, no dot)
///   Low      → subtle shadow only
class SnakeWarningMarker extends StatelessWidget {
  final String? riskLevel;
  final bool isVenomous;
  final double size;

  /// If provided, the marker shows the actual snake species photo in a
  /// circular badge instead of the generic warning sign image.
  final String? imageUrl;

  const SnakeWarningMarker({
    super.key,
    this.riskLevel,
    this.isVenomous = false,
    this.size = 46,
    this.imageUrl,
  });

  Color get _glowColor {
    switch (riskLevel) {
      case 'Extreme':
        return const Color(0xFFB71C1C);
      case 'Critical':
        return const Color(0xFFDC3545);
      case 'High':
        return const Color(0xFFF5A623);
      case 'Medium':
        return const Color(0xFFFFD700);
      default:
        if (isVenomous) return const Color(0xFFF5A623);
        return Colors.transparent;
    }
  }

  bool get _isDangerous =>
      riskLevel == 'Extreme' ||
      riskLevel == 'Critical' ||
      riskLevel == 'High' ||
      isVenomous;

  @override
  Widget build(BuildContext context) {
    final glow = _glowColor;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Coloured glow / ring behind the marker
          if (glow != Colors.transparent)
            Container(
              width: size * 0.78,
              height: size * 0.78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: glow.withOpacity(0.55),
                    blurRadius: 12,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),

          // ── Species photo badge (when imageUrl is provided) ──────────
          if (imageUrl != null)
            Container(
              width: size * 0.90,
              height: size * 0.90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: glow != Colors.transparent
                      ? glow
                      : Colors.grey.shade400,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (glow != Colors.transparent ? glow : Colors.black)
                        .withOpacity(0.30),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Image.asset(
                    'assets/images/snake_warning.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            )
          // ── Generic warning sign (fallback when no imageUrl) ─────────
          else
            Image.asset(
              'assets/images/snake_warning.png',
              width: size,
              height: size,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _FallbackMarker(
                size: size,
                riskLevel: riskLevel,
                isVenomous: isVenomous,
              ),
            ),

          // Animated pulse dot for dangerous sightings
          if (_isDangerous)
            Positioned(right: 0, bottom: 0, child: _PulseDot(color: glow)),
        ],
      ),
    );
  }
}

// ── Animated pulse dot ─────────────────────────────────────────────────────

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(color: widget.color.withOpacity(0.6), blurRadius: 4),
          ],
        ),
      ),
    );
  }
}

// ── Fallback drawn marker (if PNG asset missing) ───────────────────────────

class _FallbackMarker extends StatelessWidget {
  final double size;
  final String? riskLevel;
  final bool isVenomous;

  const _FallbackMarker({
    required this.size,
    this.riskLevel,
    this.isVenomous = false,
  });

  Color get _fill {
    switch (riskLevel) {
      case 'Extreme':
      case 'Critical':
        return const Color(0xFFDC3545);
      case 'High':
        return const Color(0xFFF5A623);
      default:
        return isVenomous ? const Color(0xFFF5A623) : const Color(0xFFFFD700);
    }
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(size, size * 0.866),
    painter: _TrianglePainter(fill: _fill),
  );
}

class _TrianglePainter extends CustomPainter {
  final Color fill;
  const _TrianglePainter({required this.fill});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bw = w * 0.07;
    final path = Path()
      ..moveTo(w / 2, bw)
      ..lineTo(w - bw, h - bw)
      ..lineTo(bw, h - bw)
      ..close();
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF1A1A1A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = bw
        ..strokeJoin = StrokeJoin.round,
    );
    final cx = w / 2;
    final sp = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(cx, h * 0.18)
        ..cubicTo(
          cx + w * 0.26,
          h * 0.28,
          cx + w * 0.24,
          h * 0.44,
          cx,
          h * 0.54,
        )
        ..cubicTo(
          cx - w * 0.22,
          h * 0.64,
          cx - w * 0.16,
          h * 0.74,
          cx + w * 0.08,
          h * 0.82,
        ),
      sp,
    );
    canvas.drawCircle(
      Offset(cx, h * 0.13),
      w * 0.08,
      Paint()..color = const Color(0xFF1A1A1A),
    );
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter old) => old.fill != fill;
}
