import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:ai_virtual_coach/main.dart';
import 'package:ai_virtual_coach/theme/app_theme.dart';

class CameraSetupScreen extends StatefulWidget {
  const CameraSetupScreen({super.key});

  @override
  State<CameraSetupScreen> createState() => _CameraSetupScreenState();
}

class _CameraSetupScreenState extends State<CameraSetupScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  String _selectedView = 'front'; // 'front' or 'side'

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) return;

    // Use the first available back camera
    final camera = cameras.firstWhere(
      (description) => description.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    } on CameraException catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: AppTheme.primaryBlack,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.accentRed),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      extendBodyBehindAppBar: true, // Make UI overlay camera
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent for HUD feel
        elevation: 0,
        title: Text(
          'CAMERA SETUP',
          style: AppTheme.titleMedium.copyWith(
            shadows: [const Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_controller!),
                // Overlay Grid
                CustomPaint(painter: GridPainter()),
                // Instruction Gradient Overlay
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 120,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ALIGN BODY IN GRID',
                        style: AppTheme.labelButton.copyWith(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: AppTheme.primaryBlack,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // View Toggles (Segmented Style)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.mediumGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildViewToggle('FRONT', 'front')),
                      Expanded(child: _buildViewToggle('SIDE', 'side')),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Start Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/recording',
                        arguments: {
                          'view': _selectedView,
                          'camera': _controller!.description,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGreen, // Go Green
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'START RECORDING',
                      style: AppTheme.labelButton.copyWith(
                        color: AppTheme.primaryBlack,
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

  Widget _buildViewToggle(String label, String value) {
    final isSelected = _selectedView == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedView = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryBlack : Colors.white60,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;

    // Draw vertical lines
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(2 * size.width / 3, 0),
      Offset(2 * size.width / 3, size.height),
      paint,
    );

    // Draw horizontal lines
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      paint,
    );
    canvas.drawLine(
      Offset(0, 2 * size.height / 3),
      Offset(size.width, 2 * size.height / 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
