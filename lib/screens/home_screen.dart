import 'package:flutter/material.dart';
import 'package:ai_virtual_coach/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Tech Grid (Subtle)
          CustomPaint(painter: _BackgroundGridPainter()),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),

                  // Boxed Title with Glow effect
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.primaryWhite,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryWhite.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    child: Text(
                      'AI COACH',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppTheme.primaryWhite,
                        fontStyle: FontStyle.italic, // Athletic feel
                      ),
                    ),
                  ),

                  const SizedBox(height: 64),

                  // Motivational Text
                  Text(
                    'MASTER YOUR FORM',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.accentBlue,
                      letterSpacing: 2.0,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Precision analysis for elite performance.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryWhite.withOpacity(0.7),
                    ),
                  ),

                  const Spacer(),

                  // Start Button (Full width, bold)
                  SizedBox(
                    height: 64, // Taller button
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/setup');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentRed,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            2,
                          ), // Sharp/Sports look
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('START WORKOUT'),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
          .withOpacity(0.03) // Very subtle
      ..strokeWidth = 1;

    // Draw grid
    const double step = 40;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
