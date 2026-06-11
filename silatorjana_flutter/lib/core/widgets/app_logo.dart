import 'package:flutter/material.dart';

/// Si-LATORJANA app logo — exact replica of the web's AppLogo.tsx SVG.
/// Renders a rounded square with emerald gradient background,
/// an elegant 'S' letter, and two accent dots.
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _AppLogoPainter(),
    );
  }
}

class _AppLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final scale = s / 512.0;

    // ── Background: rounded rect with gradient ──
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, s, s),
      Radius.circular(128 * scale),
    );
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF064E3B), Color(0xFF047857)],
      ).createShader(Rect.fromLTWH(0, 0, s, s));
    canvas.drawRRect(bgRect, bgPaint);

    // ── 'S' letter path with gradient stroke ──
    final sPath = Path();
    // M 312 160
    sPath.moveTo(312 * scale, 160 * scale);
    // H 224 (line to)
    sPath.lineTo(224 * scale, 160 * scale);
    // A 48 48 0 0 0 176 208 (arc: left semicircle top)
    sPath.arcToPoint(
      Offset(176 * scale, 208 * scale),
      radius: Radius.circular(48 * scale),
      largeArc: false,
      clockwise: false,
    );
    // A 48 48 0 0 0 224 256 (arc: left semicircle bottom)
    sPath.arcToPoint(
      Offset(224 * scale, 256 * scale),
      radius: Radius.circular(48 * scale),
      largeArc: false,
      clockwise: false,
    );
    // H 288 (line to middle right)
    sPath.lineTo(288 * scale, 256 * scale);
    // A 48 48 0 0 1 336 304 (arc: right semicircle top)
    sPath.arcToPoint(
      Offset(336 * scale, 304 * scale),
      radius: Radius.circular(48 * scale),
      largeArc: false,
      clockwise: true,
    );
    // A 48 48 0 0 1 288 352 (arc: right semicircle bottom)
    sPath.arcToPoint(
      Offset(288 * scale, 352 * scale),
      radius: Radius.circular(48 * scale),
      largeArc: false,
      clockwise: true,
    );
    // H 200
    sPath.lineTo(200 * scale, 352 * scale);

    final sPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 60 * scale
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        begin: Alignment(
          (176 - 256) / 256, // normalized
          (160 - 256) / 256,
        ),
        end: Alignment(
          (336 - 256) / 256,
          (352 - 256) / 256,
        ),
        colors: const [Color(0xFFA7F3D0), Color(0xFF34D399), Color(0xFF10B981)],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(176 * scale, 160 * scale, 160 * scale, 192 * scale));

    canvas.drawPath(sPath, sPaint);

    // ── Accent dots ──
    // Top-right dot: cx=384, cy=160, r=18
    canvas.drawCircle(
      Offset(384 * scale, 160 * scale),
      18 * scale,
      Paint()..color = const Color(0xFFA7F3D0),
    );
    // Bottom-left dot: cx=128, cy=352, r=18
    canvas.drawCircle(
      Offset(128 * scale, 352 * scale),
      18 * scale,
      Paint()..color = const Color(0xFF10B981),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
