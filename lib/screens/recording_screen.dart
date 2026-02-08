import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:ui' as ui; // Needed for FontFeature
import 'package:ai_virtual_coach/theme/app_theme.dart';
import 'package:ai_virtual_coach/models/session_models.dart';
import 'package:ai_virtual_coach/services/pose_landmarker_service.dart';
import 'package:ai_virtual_coach/widgets/pose_overlay_painter.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  CameraController? _controller;
  bool _isInit = false;
  Timer? _timer;
  int _seconds = 0;

  // Pose data collection (ALL frames stored — no data loss)
  final List<List<List<double>>> _poseData = [];
  final PoseLandmarkerService _poseService = PoseLandmarkerService();

  // Overlay display (updated at throttled rate for smooth UI)
  List<List<double>>? _currentLandmarks;
  final bool _showOverlay = true;

  bool _isFrontCamera = false;

  // Camera sensor orientation for correct MediaPipe rotation
  int _sensorOrientation = 90;

  // UI throttling: decouple data collection from overlay rendering.
  // _poseData gets EVERY frame (no loss), but setState for the overlay
  // is limited to ~20fps to avoid excessive widget rebuilds.
  DateTime _lastUiUpdate = DateTime.now();
  static const Duration _uiUpdateInterval = Duration(milliseconds: 50); // ~20fps overlay

  // FPS tracking: count actual detected frames for accurate metadata
  int _detectedFrameCount = 0;
  DateTime? _firstFrameTime;
  DateTime? _lastFrameTime;

  // Debug logging counter (temporary — remove after confirming fix)
  int _debugLogCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['camera'] != null) {
        _initCamera(args['camera']);
      }
      _startTimer();
      _isInit = true;
    }
  }

  Future<void> _initCamera(CameraDescription camera) async {
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420, // Required for Android
    );

    // Determine if using front camera for mirroring logic
    _isFrontCamera = camera.lensDirection == CameraLensDirection.front;

    // Capture sensor orientation for correct rotation in pose detection
    // Typically: back camera = 90, front camera = 270
    _sensorOrientation = camera.sensorOrientation;
    debugPrint(
      '[PoseDebug] Camera: ${camera.lensDirection.name}, '
      'sensorOrientation: $_sensorOrientation',
    );

    await _controller!.initialize();
    await _poseService.initialize();
    _startPoseDetection();
    if (mounted) setState(() {});
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _seconds++);
    });
  }

  void _startPoseDetection() {
    if (_controller == null) return;

    _controller!.startImageStream((CameraImage image) async {
      // Pass actual sensorOrientation instead of hardcoded 90
      final landmarks = await _poseService.processFrame(
        image,
        rotation: _sensorOrientation,
      );

      if (!mounted) return;

      if (landmarks != null && landmarks.length == 33) {
        // ALWAYS store data — no frames lost for ML models
        _poseData.add(landmarks);

        // Track FPS timing
        final now = DateTime.now();
        _detectedFrameCount++;
        _firstFrameTime ??= now;
        _lastFrameTime = now;

        // Temporary debug logging: first 5 frames only
        if (_debugLogCount < 5) {
          _debugLogCount++;
          final sample = landmarks[11]; // left shoulder
          debugPrint(
            '[PoseDebug] Frame $_detectedFrameCount | '
            'rotation=$_sensorOrientation | '
            'front=$_isFrontCamera | '
            'L_shoulder=[${sample[0].toStringAsFixed(3)}, '
            '${sample[1].toStringAsFixed(3)}, '
            '${sample.length > 3 ? sample[3].toStringAsFixed(2) : "?"}]',
          );
        }

        // Throttle UI updates to ~20fps — overlay is purely visual,
        // no data is lost by skipping a setState call
        if (now.difference(_lastUiUpdate) >= _uiUpdateInterval) {
          _lastUiUpdate = now;
          setState(() {
            _currentLandmarks = landmarks;
          });
        }
      }
    });
  }

  Future<void> _finishExercise() async {
    _timer?.cancel();

    // 1. Stop the camera stream first to prevent new frames
    if (_controller != null && _controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
    }

    // 2. Safely close the pose service (waits for current frame processing)
    await _poseService.close();

    // 3. Dispose camera controller
    await _controller?.dispose();
    _controller = null;

    if (!mounted) return; // Lint fix: Check mounted before context access

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final view = args?['view'] ?? 'front';

    // Compute actual detection FPS from real frame timestamps
    double actualFps = 30.0; // fallback default
    if (_firstFrameTime != null &&
        _lastFrameTime != null &&
        _detectedFrameCount > 1) {
      final durationSec =
          _lastFrameTime!.difference(_firstFrameTime!).inMilliseconds / 1000.0;
      if (durationSec > 0) {
        actualFps = (_detectedFrameCount - 1) / durationSec;
      }
    }
    debugPrint(
      '[PoseDebug] Session complete: $_detectedFrameCount frames, '
      '${actualFps.toStringAsFixed(1)} fps, '
      '${_poseData.length} poses stored',
    );

    // Create session request with accurate FPS metadata
    final request = SessionRequest(
      exerciseView: view,
      poseSequence: _poseData,
      metadata: {
        'fps': double.parse(actualFps.toStringAsFixed(2)),
        'frame_count': _detectedFrameCount,
        'device': 'mobile',
      },
    );

    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        '/processing',
        arguments: request,
      );
    }
  }

  @override
  void dispose() {
    // If finishExercise wasn't called (e.g. back button), clean up here
    _poseService.dispose();
    _controller?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            // Black Outline Frame
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 8.0),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Camera Preview Layer
                if (_controller != null && _controller!.value.isInitialized)
                  ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller!.value.previewSize!.height,
                          height: _controller!.value.previewSize!.width,
                          child: Stack(
                            children: [
                              CameraPreview(_controller!),
                              if (_showOverlay)
                                CustomPaint(
                                  size: Size(
                                    _controller!.value.previewSize!.height,
                                    _controller!.value.previewSize!.width,
                                  ),
                                  painter: PoseOverlayPainter(
                                    landmarks: _currentLandmarks,
                                    isFrontCamera: _isFrontCamera,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const Center(
                    child: CircularProgressIndicator(color: AppTheme.accentRed),
                  ),

                // Timer (Top Right)
                Positioned(
                  top: 24,
                  right: 24,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppTheme.accentRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatTime(_seconds),
                          style: AppTheme.titleMedium.copyWith(
                            fontSize: 20,
                            fontFeatures: [
                              const ui.FontFeature.tabularFigures(),
                            ],
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Finish Button (Bottom)
                Positioned(
                  bottom: 32,
                  left: 24,
                  right: 24,
                  child: _buildFinishButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinishButton() {
    return GestureDetector(
      onTap: _finishExercise,
      child: SizedBox(
        height: 72,
        child: Stack(
          children: [
            // SHADOW (Fixed at Bottom Right)
            Positioned(
              top: 8,
              left: 6,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.zero,
                  border: Border.all(color: Colors.white),
                ),
              ),
            ),
            // BUTTON (Offset to Top Left)
            Positioned(
              top: 0,
              bottom: 8,
              left: 0,
              right: 6,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentRed,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'FINISH EXERCISE',
                      style: AppTheme.labelButton.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
