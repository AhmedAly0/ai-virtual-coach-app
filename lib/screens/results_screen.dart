import 'package:flutter/material.dart';
import 'package:ai_virtual_coach/theme/app_theme.dart';
import 'package:ai_virtual_coach/models/session_models.dart';

// Teal color for "Good" rating (70-84)
const Color _tealGood = Color(0xFF5AC8FA);

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the session response passed via arguments
    final response =
        ModalRoute.of(context)?.settings.arguments as SessionResponse?;

    // Fallback if no data (should not happen in normal flow)
    if (response == null) {
      return const Scaffold(body: Center(child: Text('No results available')));
    }

    // Hardcoded for preview: Change this to test different scenarios
    // 92 -> Excellent (Green), 78 -> Good (Teal), 60 -> Needs Improvement (Orange), 35 -> Poor (Red)
    final displayScore = 60.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Detected Exercise Banner (Blue)
              _buildHardShadowCard(
                backgroundColor: AppTheme.accentBlue,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                child: Column(
                  children: [
                    const Text(
                      'ANNOTATION: Detected Exercise',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      response.exercise.toUpperCase(),
                      style: AppTheme.titleLarge.copyWith(
                        fontSize: 36,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Overall Score Card (Dynamic Color)
              _buildHardShadowCard(
                backgroundColor: _getScoreColor(displayScore),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Text(
                      'ANNOTATION: Overall Form Score',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        // Trendy "Upward Trend" icon decoration
                        const Icon(
                          Icons.trending_up_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          displayScore.toStringAsFixed(0),
                          style: AppTheme.titleLarge.copyWith(
                            fontSize: 40,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          ' /100',
                          style: AppTheme.titleMedium.copyWith(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getMotivationalText(displayScore),
                      style: AppTheme.titleMedium.copyWith(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Aspect Scores (Grid)
              const Center(
                child: Text(
                  'ANNOTATION: Aspect Scores',
                  style: TextStyle(
                    color: AppTheme.darkGrey,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Using a Wrap or simple Row/Column combo for flexibility
              LayoutBuilder(
                builder: (context, constraints) {
                  // Create a 2-column grid, last item full-width if odd count
                  final keys = response.scores.keys.toList();
                  final isOddCount = keys.length % 2 != 0;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: keys.asMap().entries.map((entry) {
                      final index = entry.key;
                      final key = entry.value;
                      final isLastAndOdd =
                          isOddCount && index == keys.length - 1;
                      final width = isLastAndOdd
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 12) / 2;
                      return SizedBox(
                        width: width,
                        child: _buildAspectCard(key, response.scores[key]! * 10),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Coach Feedback
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: AppTheme.mediumGrey,
                    width: 2,
                    style: BorderStyle
                        .solid, // Or dashed if we implement a painter
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ANNOTATION: Coach Feedback',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGrey,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (response.feedback.isEmpty)
                      const Text('Great form! No specific corrections needed.')
                    else
                      ...response.feedback.map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                // Use different icons based on sentiment if possible, default to info
                                Icons.arrow_right_alt,
                                color: AppTheme.accentBlue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  f,
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.primaryBlack,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              _buildActionButton(
                context,
                label: 'RETRY EXERCISE',
                icon: Icons.refresh,
                color: AppTheme.accentBlue,
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/setup',
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                context,
                label: 'END SESSION',
                icon: Icons.exit_to_app,
                color: AppTheme.mediumGrey,
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: Hard Shadow Card
  Widget _buildHardShadowCard({
    required Widget child,
    required Color backgroundColor,
    required EdgeInsetsGeometry padding,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0),
        ],
      ),
      padding: padding,
      child: child,
    );
  }

  // Helper: Aspect Score Card
  Widget _buildAspectCard(String title, double score) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(2, 2), // Smaller shadow for smaller cards
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title.toUpperCase().replaceAll('_', ' '),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppTheme.darkGrey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            score.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: _getScoreColor(score),
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Action Button
  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    Color textColor = Colors.white,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTheme.labelButton.copyWith(
                color: textColor,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMotivationalText(double score) {
    if (score >= 85) return 'EXCELLENT FORM!';
    if (score >= 70) return 'GOOD JOB!';
    if (score >= 50) return 'KEEP IMPROVING';
    return 'FOCUS ON TECHNIQUE';
  }

  // Unified color mapping for scores
  Color _getScoreColor(double score) {
    if (score >= 85) return AppTheme.accentGreen; // Excellent: Green
    if (score >= 70) return _tealGood; // Good: Teal
    if (score >= 50) return AppTheme.warningOrange; // Needs Improvement: Orange
    return AppTheme.accentRed; // Poor: Red
  }
}
