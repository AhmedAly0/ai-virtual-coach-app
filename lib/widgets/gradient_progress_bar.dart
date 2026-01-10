import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A custom gradient progress bar widget that displays progress with a
/// multi-color gradient from red to green.
class GradientProgressBar extends StatefulWidget {
  /// Current progress value (0.0 to 1.0)
  final double progress;

  /// Height of the progress bar
  final double height;

  /// Border radius for rounded corners
  final double borderRadius;

  /// Duration for progress animation
  final Duration animationDuration;

  const GradientProgressBar({
    super.key,
    required this.progress,
    this.height = 16.0,
    this.borderRadius = 4.0,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<GradientProgressBar> createState() => _GradientProgressBarState();
}

class _GradientProgressBarState extends State<GradientProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(GradientProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _previousProgress = _progressAnimation.value;
      _progressAnimation = Tween<double>(
        begin: _previousProgress,
        end: widget.progress,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: _GradientProgressPainter(
            progress: _progressAnimation.value.clamp(0.0, 1.0),
            borderRadius: widget.borderRadius,
          ),
        );
      },
    );
  }
}

/// Custom painter that draws a gradient progress bar with:
/// 1. Grey background for unfilled portion
/// 2. Multi-color gradient (red → purple → blue → teal → green) for filled portion
class _GradientProgressPainter extends CustomPainter {
  final double progress;
  final double borderRadius;

  // Gradient colors matching the design mockup
  static const List<Color> gradientColors = [
    Color(0xFFE53935), // Red
    Color(0xFFD32F2F), // Darker red
    Color(0xFF8E24AA), // Purple
    Color(0xFF5C6BC0), // Indigo
    Color(0xFF1E88E5), // Blue
    Color(0xFF00ACC1), // Cyan
    Color(0xFF00897B), // Teal
    Color(0xFF43A047), // Green
  ];

  _GradientProgressPainter({
    required this.progress,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    // Draw unfilled background (grey)
    final backgroundPaint = Paint()
      ..color = AppTheme.mediumGrey
      ..style = PaintingStyle.fill;
    canvas.drawRRect(backgroundRect, backgroundPaint);

    if (progress > 0) {
      // Calculate filled width
      final filledWidth = size.width * progress;

      // Create clipping path for filled portion
      final filledRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, filledWidth, size.height),
        Radius.circular(borderRadius),
      );

      // Create gradient shader
      final gradientPaint = Paint()
        ..shader = const LinearGradient(
          colors: gradientColors,
          stops: [0.0, 0.15, 0.3, 0.45, 0.6, 0.75, 0.85, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill;

      // Draw gradient filled portion
      canvas.drawRRect(filledRect, gradientPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GradientProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
