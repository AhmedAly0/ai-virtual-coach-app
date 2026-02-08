import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/session_models.dart';
import '../services/api_service.dart';
import '../widgets/intersecting_circles_loader.dart';
import '../widgets/gradient_progress_bar.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  final ApiService _apiService = ApiService();
  String _statusText = "ANALYZING YOUR FORM";
  String _subtitleText = "AI is evaluating your exercise technique...";
  final String _motivationalText = '"Stay focused. Results incoming."';
  double _progress = 0.0;
  bool _analysisStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_analysisStarted) {
      _analysisStarted = true;
      _startAnalysis();
    }
  }

  Future<void> _startAnalysis() async {
    // Get the arguments passed from RecordingScreen
    final args = ModalRoute.of(context)?.settings.arguments as SessionRequest?;

    if (args == null) {
      // Should not happen, but handle it
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/error');
        }
      });
      return;
    }

    try {
      // Start with initial progress
      setState(() {
        _progress = 0.1;
        _statusText = "ANALYZING YOUR FORM";
        _subtitleText = "AI is evaluating your exercise technique...";
      });

      // Simulate progress updates while waiting for API
      _simulateProgressUpdates();

      final response = await _apiService.analyzeSession(args);

      if (!mounted) return;

      // Complete the progress before navigating
      setState(() => _progress = 1.0);

      // Small delay to show completion
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/results', arguments: response);
    } on ApiException catch (e) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/error',
        arguments: e.message,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/error',
        arguments: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  void _simulateProgressUpdates() async {
    // Update progress in stages to give user feedback
    final progressStages = [
      (0.25, "Processing video frames..."),
      (0.45, "Detecting body keypoints..."),
      (0.65, "Analyzing movement patterns..."),
      (0.85, "Generating feedback..."),
    ];

    for (final stage in progressStages) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() {
        _progress = stage.$1;
        _subtitleText = stage.$2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      body: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryWhite,
          border: Border.all(color: AppTheme.primaryBlack, width: 3),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              children: [
                // Top section - Intersecting Circles Loader
                const SizedBox(height: 32),
                const IntersectingCirclesLoader(size: 120, strokeWidth: 8),
                const SizedBox(height: 48),

                // Middle section - Status text
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _statusText.toUpperCase(),
                        style: AppTheme.titleMedium.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: AppTheme.primaryBlack,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _subtitleText,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryBlack.withAlpha(180),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _motivationalText,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryBlack.withAlpha(140),
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Bottom section - Progress bar and info
                Column(
                  children: [
                    // Gradient Progress Bar
                    SizedBox(
                      width: double.infinity,
                      child: GradientProgressBar(
                        progress: _progress,
                        height: 16,
                        borderRadius: 4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Processing: ~${(_progress * 100).toInt()}%",
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryBlack.withAlpha(180),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Behavior notice
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFFFF9C4,
                        ), // Light yellow background
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFFD54F), // Yellow border
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFF57C00), // Orange warning icon
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "BEHAVIOR: All interactions disabled during processing",
                                  style: AppTheme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppTheme.primaryBlack,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Auto-navigates to Results when complete",
                                  style: AppTheme.bodyMedium.copyWith(
                                    fontSize: 12,
                                    color: AppTheme.primaryBlack.withAlpha(180),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
