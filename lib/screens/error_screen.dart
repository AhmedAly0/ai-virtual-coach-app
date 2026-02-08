import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final errorMessage = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Large Error Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.accentRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 80,
                  color: AppTheme.accentRed,
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'OOPS!',
                style: AppTheme.titleLarge.copyWith(color: AppTheme.accentRed),
              ),
              const SizedBox(height: 16),
              Text(
                'SOMETHING WENT WRONG',
                style: AppTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage ??
                    'Unable to analyze exercise.\nPossible reasons: Camera obstructed, no internet, or backend error.',
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Actions
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/setup',
                    (route) => false,
                  ),
                  child: Text('RETRY SESSION', style: AppTheme.labelButton),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  ),
                  child: Text(
                    'RETURN TO HOME',
                    style: AppTheme.labelButton.copyWith(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
