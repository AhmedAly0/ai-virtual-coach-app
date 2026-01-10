import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
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

  // Interaction states for buttons
  bool _isFrontBtnPressed = false;
  bool _isSideBtnPressed = false;
  bool _isStartBtnPressed = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Lazy-load available cameras
    List<CameraDescription> cameras = [];
    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
      debugPrint('Camera error: $e');
      return;
    }

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
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.accentGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Outer margin
          child: Container(
            // Black Outline Frame
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 8.0),
            ),
            child: Column(
              children: [
                // Top Header area? Or just Camera?
                // PRD/Screenshot implies "SCREEN 1: HOME" badge style or similar.
                // We'll keep it simple: Camera area -> Controls area.

                // Camera Viewfinder Area
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16), // Inner spacing
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 4,
                      ), // Frame the camera too?
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CameraPreview(_controller!),
                        // Overlay Grid
                        CustomPaint(painter: GridPainter()),

                        // "Align Body" pill
                        Positioned(
                          top: 24,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentBlue,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black,
                                    offset: Offset(2, 2), // Tiny hard shadow
                                  ),
                                ],
                              ),
                              child: Text(
                                'ALIGN BODY IN GRID',
                                style: AppTheme.labelButton.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Controls Area
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // View Toggles
                      Row(
                        children: [
                          Expanded(
                            child: _buildHardShadowButton(
                              label: 'FRONT VIEW',
                              icon: Icons.person_outline,
                              isSelected: _selectedView == 'front',
                              isPressed: _isFrontBtnPressed,
                              onTap: () =>
                                  setState(() => _selectedView = 'front'),
                              onPressChange: (v) =>
                                  setState(() => _isFrontBtnPressed = v),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildHardShadowButton(
                              label: 'SIDE VIEW',
                              icon: Icons.person,
                              isSelected: _selectedView == 'side',
                              isPressed: _isSideBtnPressed,
                              onTap: () =>
                                  setState(() => _selectedView = 'side'),
                              onPressChange: (v) =>
                                  setState(() => _isSideBtnPressed = v),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Start Button (Green)
                      _buildHardShadowButton(
                        label: 'START RECORDING',
                        color: AppTheme.accentGreen,
                        isLarge: true,
                        isSelected: true, // Always "active" visual style
                        isPressed: _isStartBtnPressed,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/recording',
                            arguments: {
                              'view': _selectedView,
                              'camera': _controller!.description,
                            },
                          );
                        },
                        onPressChange: (v) =>
                            setState(() => _isStartBtnPressed = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHardShadowButton({
    required String label,
    IconData? icon,
    bool isSelected = false,
    bool isPressed = false,
    bool isLarge = false,
    Color? color,
    required VoidCallback onTap,
    required Function(bool) onPressChange,
  }) {
    final double height = isLarge ? 64 : 56;
    final double fontSize = isLarge ? 24 : 16;
    final double shadowOffsetH = 6;
    final double shadowOffsetV = 6;

    final Color bgColor =
        color ?? (isSelected ? AppTheme.accentBlue : Colors.white);

    final Color finalTextColor = (color != null || isSelected)
        ? Colors.white
        : Colors.black;

    return GestureDetector(
      onTapDown: (_) => onPressChange(true),
      onTapUp: (_) => onPressChange(false),
      onTapCancel: () => onPressChange(false),
      onTap: onTap,
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            // Shadow
            Positioned(
              top: shadowOffsetV,
              left: shadowOffsetH,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
            // Button
            AnimatedPositioned(
              duration: const Duration(milliseconds: 50),
              top: isPressed ? shadowOffsetV : 0,
              bottom: isPressed ? 0 : shadowOffsetV,
              left: isPressed ? shadowOffsetH : 0,
              right: isPressed ? 0 : shadowOffsetH,
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(
                    color: Colors.black,
                    width: 3,
                  ), // Thicker border
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                ), // Prevent text touching edge
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 24, color: finalTextColor),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: AppTheme.labelButton.copyWith(
                          color: finalTextColor,
                          fontSize: fontSize,
                          // AppTheme.labelButton now uses Archivo Black
                        ),
                      ),
                    ],
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

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2;

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
