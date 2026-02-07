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
  bool _isError = false; // Track initialization errors
  String _selectedView = 'front'; // 'front' or 'side'

  // Interaction states for buttons
  bool _isFrontBtnPressed = false;
  bool _isSideBtnPressed = false;
  bool _isStartBtnPressed = false;

  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera({int retryCount = 0}) async {
    const maxRetries = 3;
    const retryDelayMs = 500;

    setState(() {
      _isError = false;
      _isCameraInitialized = false;
    });

    // Add a small delay on retry to allow camera resources to be released
    if (retryCount > 0) {
      await Future.delayed(Duration(milliseconds: retryDelayMs * retryCount));
    }

    try {
      _cameras = await availableCameras();
    } on CameraException catch (e) {
      debugPrint('Camera error: $e');
      if (retryCount < maxRetries) {
        debugPrint(
          'Retrying camera initialization (${retryCount + 1}/$maxRetries)...',
        );
        return _initializeCamera(retryCount: retryCount + 1);
      }
      _handleError();
      return;
    }

    if (_cameras.isEmpty) {
      _handleError();
      return;
    }

    // Default to the first available front camera
    int frontCameraIndex = _cameras.indexWhere(
      (description) => description.lensDirection == CameraLensDirection.front,
    );

    _selectedCameraIndex = frontCameraIndex != -1 ? frontCameraIndex : 0;

    final success = await _startCamera(_cameras[_selectedCameraIndex]);

    // Retry if camera failed to start
    if (!success && retryCount < maxRetries) {
      debugPrint(
        'Retrying camera initialization (${retryCount + 1}/$maxRetries)...',
      );
      return _initializeCamera(retryCount: retryCount + 1);
    }
  }

  Future<bool> _startCamera(CameraDescription camera) async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      // Add timeout to prevent indefinite hang
      await _controller!.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Camera initialization timed out');
        },
      );
      if (!mounted) return false;
      setState(() {
        _isCameraInitialized = true;
        _isError = false;
      });
      return true;
    } on CameraException catch (e) {
      debugPrint('Camera error: $e');
      _handleError();
      return false;
    } catch (e) {
      debugPrint('Generic camera error: $e');
      _handleError();
      return false;
    }
  }

  void _handleError() {
    if (!mounted) return;
    setState(() {
      _isError = true;
      _isCameraInitialized = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to access camera. Please try again.'),
      ),
    );
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2) return;

    setState(() {
      _isCameraInitialized = false;
      _isError = false;
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    });

    await _startCamera(_cameras[_selectedCameraIndex]);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppTheme.accentRed,
              ),
              const SizedBox(height: 16),
              const Text(
                'Camera Error',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _initializeCamera,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlack,
                  foregroundColor: Colors.white,
                ),
                child: const Text('RETRY CAMERA'),
              ),
            ],
          ),
        ),
      );
    }

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
                        // Camera Preview Layer
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
                        ),

                        // Overlay Grid
                        CustomPaint(painter: GridPainter()),

                        // Camera Toggle Button
                        if (_cameras.length > 1)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Material(
                              color: Colors.black.withOpacity(0.5),
                              shape: const CircleBorder(),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.flip_camera_ios,
                                  color: Colors.white,
                                ),
                                onPressed: _toggleCamera,
                              ),
                            ),
                          ),

                        // "Align Body" pill
                        Positioned(
                          bottom: 24, // Moved to bottom to avoid conflict
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
                        onTap: () async {
                          // Store camera description before disposing
                          final cameraDescription = _controller!.description;
                          final view = _selectedView;

                          // CRITICAL: Dispose camera before navigation to release resources
                          // This allows RecordingScreen to initialize the camera without conflicts
                          await _controller?.dispose();
                          _controller = null;

                          if (!mounted) return;

                          Navigator.pushReplacementNamed(
                            context,
                            '/recording',
                            arguments: {
                              'view': view,
                              'camera': cameraDescription,
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
