import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A custom animated loader widget with two intersecting rotating arcs (red and blue)
/// on horizontally offset circles that intersect as they rotate.
class IntersectingCirclesLoader extends StatefulWidget {
  /// Size of the loader widget (width and height)
  final double size;

  /// Stroke width of the arcs and background circle
  final double strokeWidth;

  /// Duration for one complete rotation (default: 2.5 seconds)
  final Duration rotationDuration;

  const IntersectingCirclesLoader({
    super.key,
    this.size = 120.0,
    this.strokeWidth = 8.0,
    this.rotationDuration = const Duration(milliseconds: 2500),
  });

  @override
  State<IntersectingCirclesLoader> createState() =>
      _IntersectingCirclesLoaderState();
}

class _IntersectingCirclesLoaderState extends State<IntersectingCirclesLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.rotationDuration,
    )..repeat(); // Continuous rotation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _IntersectingCirclesPainter(
            progress: _controller.value,
            strokeWidth: widget.strokeWidth,
          ),
        );
      },
    );
  }
}

/// Custom painter that draws:
/// 1. A grey background circle (full ring, centered)
/// 2. A red partial arc on a circle offset to the LEFT
/// 3. A blue partial arc on a circle offset to the RIGHT
/// Both colored circles have the same radius as the grey ring.
/// The horizontal offset creates intersection points as they rotate.
class _IntersectingCirclesPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _IntersectingCirclesPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Horizontal offset for red and blue circles (creates intersection)
    final horizontalOffset = size.width * 0.08;

    // Paint for background grey circle (full ring)
    final backgroundPaint = Paint()
      ..color =
          const Color(0xFFE0E0E0) // Light grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Paint for red arc
    final redPaint = Paint()
      ..color = AppTheme.accentRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Paint for blue arc
    final bluePaint = Paint()
      ..color = AppTheme.accentBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background circle (full grey ring, centered)
    canvas.drawCircle(center, radius, backgroundPaint);

    // Calculate rotation angle based on animation progress
    final rotationAngle = 2 * math.pi * progress;

    // Arc sweep angle (~90 degrees = π/2 radians)
    const sweepAngle = math.pi / 2;

    // RED arc - center offset to the LEFT
    final redCenter = Offset(center.dx - horizontalOffset, center.dy);
    final redRect = Rect.fromCircle(center: redCenter, radius: radius);
    // Red arc rotates clockwise from starting position
    final redStartAngle = -math.pi / 2 + rotationAngle; // Start from top
    canvas.drawArc(redRect, redStartAngle, sweepAngle, false, redPaint);

    // BLUE arc - center offset to the RIGHT
    final blueCenter = Offset(center.dx + horizontalOffset, center.dy);
    final blueRect = Rect.fromCircle(center: blueCenter, radius: radius);
    // Blue arc rotates clockwise, offset by 180 degrees from red
    final blueStartAngle = math.pi / 2 + rotationAngle; // Start from bottom
    canvas.drawArc(blueRect, blueStartAngle, sweepAngle, false, bluePaint);
  }

  @override
  bool shouldRepaint(covariant _IntersectingCirclesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
