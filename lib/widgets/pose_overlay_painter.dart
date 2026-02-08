import 'package:flutter/material.dart';

/// Custom painter to draw pose skeleton overlay on camera preview.
class PoseOverlayPainter extends CustomPainter {
  final List<List<double>>? landmarks;
  final bool isFrontCamera;

  PoseOverlayPainter({required this.landmarks, this.isFrontCamera = false});

  // MediaPipe pose connections (simplified for visualization)
  // Indices based on standard MediaPipe Pose 33 landmarks
  static const List<List<int>> connections = [
    // Torso
    [11, 12], [11, 23], [12, 24], [23, 24],
    // Left arm
    [11, 13], [13, 15],
    // Right arm
    [12, 14], [14, 16],
    // Left leg
    [23, 25], [25, 27], [27, 29], [29, 31],
    // Right leg
    [24, 26], [26, 28], [28, 30], [30, 32],
  ];

  // Minimum visibility confidence to draw a landmark or connection.
  // Landmarks below this threshold are likely undetected (default coords 0,0)
  // and would cause erratic lines shooting to the top-left corner.
  static const double _minVisibility = 0.5;

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks == null || landmarks!.length != 33) return;

    final pointPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final linePaint = Paint()
      ..color = Colors.greenAccent.withValues(alpha: 0.7)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Scale factors
    // MediaPipe landmarks are normalized [0..1]
    final double w = size.width;
    final double h = size.height;

    // Draw connections — only when BOTH endpoints have sufficient visibility
    for (final conn in connections) {
      final lm1 = landmarks![conn[0]];
      final lm2 = landmarks![conn[1]];

      // Skip if either landmark has low visibility (likely undetected at 0,0)
      if (lm1.length > 3 && lm1[3] < _minVisibility) continue;
      if (lm2.length > 3 && lm2[3] < _minVisibility) continue;

      final p1 = _transformPoint(lm1);
      final p2 = _transformPoint(lm2);
      canvas.drawLine(
        Offset(p1[0] * w, p1[1] * h),
        Offset(p2[0] * w, p2[1] * h),
        linePaint,
      );
    }

    // Draw landmarks — only when visible
    for (final lm in landmarks!) {
      if (lm.length > 3 && lm[3] < _minVisibility) continue;

      final p = _transformPoint(lm);
      canvas.drawCircle(Offset(p[0] * w, p[1] * h), 4, pointPaint);
    }
  }

  // Handle coordinate transformation and mirroring
  List<double> _transformPoint(List<double> point) {
    double x = point[0];
    double y = point[1];

    // Mirror X if using front camera
    if (isFrontCamera) {
      x = 1.0 - x;
    }

    return [x, y, (point.length > 2) ? point[2] : 0.0];
  }

  @override
  bool shouldRepaint(covariant PoseOverlayPainter oldDelegate) {
    return oldDelegate.landmarks != landmarks ||
        oldDelegate.isFrontCamera != isFrontCamera;
  }
}
