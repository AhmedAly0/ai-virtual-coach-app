import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/camera_setup_screen.dart';
import 'screens/recording_screen.dart';
import 'screens/processing_screen.dart';
import 'screens/results_screen.dart';
import 'screens/error_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AiCoachApp()));
}

class AiCoachApp extends StatelessWidget {
  const AiCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Virtual Coach',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home:
          const SplashScreen(), // Use home instead of initialRoute for better reliability
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/setup': (context) => const CameraSetupScreen(),
        '/recording': (context) => const RecordingScreen(),
        '/processing': (context) => const ProcessingScreen(),
        '/results': (context) => const ResultsScreen(),
        '/error': (context) => const ErrorScreen(),
      },
    );
  }
}
