import 'package:flutter/material.dart';
import 'package:ai_virtual_coach/theme/app_theme.dart';
import 'package:ai_virtual_coach/models/session_models.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final response =
        ModalRoute.of(context)?.settings.arguments as SessionResponse?;

    if (response == null) {
      return const Scaffold(body: Center(child: Text('No results available')));
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      appBar: AppBar(
        title: Text('SESSION RESULTS', style: AppTheme.titleMedium),
        backgroundColor: AppTheme.primaryBlack,
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Exercise & Reps
            Text(
              response.exercise.toUpperCase(),
              style: AppTheme.titleLarge.copyWith(fontSize: 32),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${response.repsDetected} REPS COMPLETED',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.accentRed,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Overall Score Circle
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: response.overallScore / 10.0,
                      strokeWidth: 12,
                      backgroundColor: AppTheme.mediumGrey,
                      valueColor: AlwaysStoppedAnimation(
                        _getScoreColor(response.overallScore),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        response.overallScore.toStringAsFixed(1),
                        style: AppTheme.titleLarge.copyWith(
                          fontSize: 56,
                          color: _getScoreColor(response.overallScore),
                        ),
                      ),
                      Text(
                        'OVERALL',
                        style: AppTheme.bodyMedium.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Aspect Scores
            Text(
              'FORM BREAKDOWN',
              style: AppTheme.labelButton.copyWith(color: AppTheme.darkGrey),
            ),
            const Divider(color: AppTheme.mediumGrey),
            const SizedBox(height: 16),
            ...response.scores.entries.map(
              (entry) => _buildScoreRow(context, entry.key, entry.value),
            ),

            const SizedBox(height: 32),

            // Feedback
            Text(
              'COACH FEEDBACK',
              style: AppTheme.labelButton.copyWith(color: AppTheme.darkGrey),
            ),
            const Divider(color: AppTheme.mediumGrey),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.mediumGrey,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: response.feedback
                    .map(
                      (text) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: AppTheme.accentGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(text, style: AppTheme.bodyMedium),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 32),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/setup',
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.accentBlue),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'RETRY',
                      style: TextStyle(
                        color: AppTheme.accentBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkGrey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: const Text(
                      'END SESSION',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8.0) return AppTheme.accentGreen;
    if (score >= 5.0) return AppTheme.accentBlue;
    return AppTheme.accentRed;
  }

  Widget _buildScoreRow(BuildContext context, String aspect, double score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                aspect.toUpperCase().replaceAll('_', ' '),
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                score.toString(),
                style: TextStyle(
                  color: _getScoreColor(score),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 10.0,
              backgroundColor: AppTheme.mediumGrey,
              valueColor: AlwaysStoppedAnimation(_getScoreColor(score)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
