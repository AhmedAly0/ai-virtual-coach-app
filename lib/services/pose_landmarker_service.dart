import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter_pose_detection/flutter_pose_detection.dart';

/// Service class for real-time pose landmark detection using MediaPipe.
class PoseLandmarkerService {
  NpuPoseDetector? _detector;
  bool _isProcessing = false;
  bool _isClosed = false;
  String? _accelerationMode;

  /// Initialize the pose detector.
  /// Returns the acceleration mode (gpu, npu, or cpu).
  Future<String> initialize() async {
    _detector = NpuPoseDetector(config: PoseDetectorConfig.realtime());
    final mode = await _detector!.initialize();
    _accelerationMode = mode.name;
    return _accelerationMode!;
  }

  /// Process a single camera frame and return landmarks.
  /// Returns null if no pose is detected or if already processing.
  /// [rotation] should be the camera's sensorOrientation (typically 90 for back, 270 for front).
  Future<List<List<double>>?> processFrame(
    CameraImage image, {
    int rotation = 90,
  }) async {
    if (_detector == null || _isProcessing || _isClosed) return null;

    _isProcessing = true;
    try {
      final planes = image.planes
          .map(
            (p) => {
              'bytes': p.bytes,
              'bytesPerRow': p.bytesPerRow,
              'bytesPerPixel': p.bytesPerPixel ?? 1,
            },
          )
          .toList();

      final result = await _detector!.processFrame(
        planes: planes,
        width: image.width,
        height: image.height,
        format: 'yuv420',
        rotation: rotation,
      );

      // Check again if closed during processing
      if (_isClosed) return null;

      if (result.hasPoses) {
        final pose = result.firstPose!;
        // Convert to [x, y, z, visibility] format for each of 33 landmarks
        // MediaPipe returns normalized coordinates [0.0, 1.0]
        // visibility: 0.0 = not detected, 1.0 = fully visible
        return pose.landmarks
            .map((lm) => [lm.x, lm.y, lm.z, lm.visibility])
            .toList();
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Pose detection error: $e');
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  /// Get current acceleration mode
  String? get accelerationMode => _accelerationMode;

  /// Safely close the service, waiting for any active processing to complete.
  Future<void> close() async {
    _isClosed = true;

    // Wait for current processing to finish (simple spin-wait or timeout)
    int retries = 0;
    while (_isProcessing && retries < 10) {
      await Future.delayed(const Duration(milliseconds: 50));
      retries++;
    }

    _detector?.dispose();
    _detector = null;
  }

  /// Dispose of the detector immediately (use close() for safer shutdown)
  void dispose() {
    _isClosed = true;
    _detector?.dispose();
    _detector = null;
  }
}
