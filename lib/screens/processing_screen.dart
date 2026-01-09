import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/session_models.dart';
import '../services/api_service.dart';
import 'results_screen.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  final ApiService _apiService = ApiService();
  String _statusText = "ANALYZING YOUR FORM";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    // Get the arguments passed from RecordingScreen
    final args = ModalRoute.of(context)?.settings.arguments as SessionRequest?;

    if (args == null) {
      // Should not happen, but handle it
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, '/error');
      });
      return;
    }

    try {
      setState(() => _statusText = "AI is evaluating technique...");
      final response = await _apiService.analyzeSession(args);

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/results', arguments: response);
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom Loader (Stack of CircularProgressIndicators for multi-color effect)
            SizedBox(
              width: 100, // Size from Figma approx
              height: 100,
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 8,
                    color: AppTheme.mediumGrey,
                    value: 1.0,
                  ),
                  CircularProgressIndicator(
                    strokeWidth: 8,
                    color: AppTheme.accentBlue,
                    backgroundColor: Colors.transparent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            Text(
              _statusText.toUpperCase(),
              style: AppTheme.titleMedium.copyWith(
                fontSize: 24,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Crunching the biomechanics...",
              style: AppTheme.bodyMedium.copyWith(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
