import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/camera_setup_screen.dart';
import 'screens/recording_screen.dart';
import 'screens/processing_screen.dart';
import 'screens/results_screen.dart';
import 'screens/error_screen.dart';

import 'package:camera/camera.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint('Error: $e.code\nError Message: $e.message');
  }
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
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/setup': (context) => const CameraSetupScreen(),
        '/recording': (context) => const RecordingScreen(),
        '/processing': (context) => const ProcessingScreen(),
        '/results': (context) => const ResultsScreen(),
        '/error': (context) => const ErrorScreen(),
      },
    );
  }
}
