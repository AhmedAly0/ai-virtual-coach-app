import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:math';
import 'package:ai_virtual_coach/theme/app_theme.dart';
import 'package:ai_virtual_coach/models/session_models.dart';

import 'dart:ui';

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
  List<List<List<double>>> _mockPoseData = [];
  Timer? _mockDataTimer;

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
      _startMockDataCollection();
      _isInit = true;
    }
  }

  Future<void> _initCamera(CameraDescription camera) async {
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _seconds++);
    });
  }

  void _startMockDataCollection() {
    // Collect mock pose data (33 landmarks, 3 coordinates) at 30fps
    _mockDataTimer = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      // Mock random movement
      final frame = List.generate(
        33,
        (index) => [
          Random().nextDouble(),
          Random().nextDouble(),
          Random().nextDouble(),
        ],
      );
      _mockPoseData.add(frame);
    });
  }

  void _finishExercise() {
    _timer?.cancel();
    _mockDataTimer?.cancel();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final view = args?['view'] ?? 'front';

    // Create session request
    final request = SessionRequest(
      exerciseView: view,
      poseSequence: _mockPoseData,
      metadata: {'fps': 30, 'device': 'mobile'},
    );

    Navigator.pushReplacementNamed(context, '/processing', arguments: request);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _timer?.cancel();
    _mockDataTimer?.cancel();
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
                          child: CameraPreview(_controller!),
                        ),
                      ),
                    ),
                  )
                else
                  const Center(
                    child: CircularProgressIndicator(color: AppTheme.accentRed),
                  ),

                // Center Status Text (Overlay)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.videocam_outlined,
                        size: 64,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Recording in Progress',
                        style: AppTheme.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            const Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '(Full screen camera view)',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          shadows: [
                            const Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                            fontFeatures: [const FontFeature.tabularFigures()],
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
    // Robust Hard Shadow Button Implementation
    // Using simple boolean for touch state locally if needed,
    // but here we just need the look. We'll wrap in GestureDetector.

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
