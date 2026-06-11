import 'package:flutter/material.dart';

/// Si-LATORJANA app logo — exact replica of the web's AppLogo.tsx SVG.
/// Renders a rounded square with emerald gradient background,
/// an elegant 'S' letter, and two accent dots.
class AppLogo extends StatelessWidget {
  final double size;
  final double drawProgress;
  final double dotsOpacity;
  final bool showBackground;

  const AppLogo({
    super.key,
    this.size = 32,
    this.drawProgress = 1.0,
    this.dotsOpacity = 1.0,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _AppLogoPainter(
        drawProgress: drawProgress,
        dotsOpacity: dotsOpacity,
        showBackground: showBackground,
      ),
    );
  }
}

class _AppLogoPainter extends CustomPainter {
  final double drawProgress;
  final double dotsOpacity;
  final bool showBackground;

  _AppLogoPainter({
    required this.drawProgress,
    required this.dotsOpacity,
    required this.showBackground,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final scale = s / 512.0;

    // ── Background: rounded rect with gradient ──
    if (showBackground) {
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
    }

    // ── 'S' letter path with gradient stroke ──
    if (drawProgress > 0) {
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

      if (drawProgress >= 1.0) {
        canvas.drawPath(sPath, sPaint);
      } else {
        // Animate the path drawing
        final pathMetrics = sPath.computeMetrics();
        final animatedPath = Path();
        for (final metric in pathMetrics) {
          final extractLength = metric.length * drawProgress;
          animatedPath.addPath(metric.extractPath(0, extractLength), Offset.zero);
        }
        canvas.drawPath(animatedPath, sPaint);
      }
    }

    // ── Accent dots ──
    if (dotsOpacity > 0) {
      // Top-right dot: cx=384, cy=160, r=18
      canvas.drawCircle(
        Offset(384 * scale, 160 * scale),
        18 * scale,
        Paint()..color = const Color(0xFFA7F3D0).withValues(alpha: dotsOpacity),
      );
      // Bottom-left dot: cx=128, cy=352, r=18
      canvas.drawCircle(
        Offset(128 * scale, 352 * scale),
        18 * scale,
        Paint()..color = const Color(0xFF10B981).withValues(alpha: dotsOpacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AppLogoPainter oldDelegate) {
    return oldDelegate.drawProgress != drawProgress ||
        oldDelegate.dotsOpacity != dotsOpacity ||
        oldDelegate.showBackground != showBackground;
  }
}
