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
      backgroundColor: AppTheme.primaryBlack,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            CameraPreview(_controller!)
          else
            const Center(child: CircularProgressIndicator()),

          // Recording overlay
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top bar
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppTheme.accentRed,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentRed.withOpacity(0.5),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatTime(_seconds),
                        style: AppTheme.titleMedium.copyWith(
                          fontSize: 20,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Button
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: _finishExercise,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        'FINISH EXERCISE',
                        style: AppTheme.labelButton,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
