import 'package:flutter/material.dart';
import 'package:ai_virtual_coach/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Removed unused size

    return Scaffold(
      backgroundColor: Colors.white, // Step 1: White background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Outer margin
          child: Container(
            // Step 2: Black Outline Frame
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black, // Stark black frame
                width: 8.0, // Thick border
              ),
            ),
            child: Stack(
              children: [
                // Top-right screen size indicator (mockup detail from screenshot, optional but keeping accurate to request)
                // Actually user said "screenshot... notice black outline... title moved up".
                // I will skip the "Screen 1: Home" green badge unless requested, as that looks like a Figma annotation.
                // But the user said "notice how the background is white... black outline inside the main frame".
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60), // Space from top
                      // Step 3: App Title (Moved Up)
                      Container(
                        // Optional: Title box border if requested, but screenshot shows text inside a box?
                        // Screenshot shows "ANNOTATION: App Title" box.
                        // The actual design likely just wants the text.
                        // But the screenshot had a box AROUND "AI COACH".
                        // "notice... kind of a black outline inside the main frame" - that's the main container.
                        // The title "AI COACH" in the screenshot has a box around it.
                        // I will add a border around the title to match the wireframe explicitly.
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 4),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'AI COACH',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                color: Colors.black, // Black text on white
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.normal, // San-serif bold
                                letterSpacing: -1.0,
                              ),
                        ),
                      ),

                      // Spacer for the "Motivational Text" design
                      Expanded(
                        child: Center(
                          // Placeholder dotted box as per screenshot annotation
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 24),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.5),
                                width: 2,
                                style: BorderStyle
                                    .solid, // Dotted not easily available without custom painter, using grey solid for now or Dashed if I added a package. Keeping simple.
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '"Train smarter, not harder."',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.grey[800],
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Get real-time form analysis and personalized coaching feedback.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Step 4: Red Button with Hard Shadow
                      // Custom implementation for the "Retro 3D" feel
                      GestureDetector(
                        onTapDown: (_) => setState(() => _isPressed = true),
                        onTapUp: (_) => setState(() => _isPressed = false),
                        onTapCancel: () => setState(() => _isPressed = false),
                        onTap: () {
                          Navigator.pushNamed(context, '/setup');
                        },
                        child: MouseRegion(
                          onEnter: (_) => setState(() => _isHovering = true),
                          onExit: (_) => setState(() => _isHovering = false),
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
                                      color: Colors.black,
                                      borderRadius: BorderRadius.zero,
                                      border: Border.all(
                                        color: Colors.black,
                                      ), // Ensure fill
                                    ),
                                  ),
                                ),
                                // BUTTON (Moves from Top-Left to Bottom-Right)
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 100),
                                  curve: Curves.easeInOut,
                                  top: _isPressed ? 8 : 0,
                                  bottom: _isPressed ? 0 : 8,
                                  left: _isPressed ? 6 : 0,
                                  right: _isPressed ? 0 : 6,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _isHovering
                                          ? AppTheme.accentRed.withOpacity(0.9)
                                          : AppTheme.accentRed,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 3,
                                      ), // Thicker border
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'START WORKOUT',
                                      style: AppTheme.labelButton.copyWith(
                                        color: Colors.white,
                                        fontSize:
                                            28, // Matches screenshot size better
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 48), // Bottom padding
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
}
