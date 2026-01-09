import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/session_models.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator to access localhost of the host machine
  // If running on a physical device, use your machine's local IP (e.g., 192.168.1.x)
  static const String _baseUrl = 'http://10.0.2.2:8000';

  Future<SessionResponse> analyzeSession(SessionRequest request) async {
    try {
      // Artifical delay for UX (since we might be mocking or it's too fast)
      await Future.delayed(const Duration(seconds: 2));

      // Uncomment to use real backend
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl/api/session/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return SessionResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to analyze session: ${response.statusCode}');
      }
      */

      // -- MOCK RESPONSE FOR DEVELOPMENT (Frontend only) --
      return _getMockResponse();
    } catch (e) {
      // Fallback for demo purposes if backend is unreachable
      print('API Error (using mock): $e');
      return _getMockResponse();
      // throw Exception('Network error: $e'); // In real app, rethrow
    }
  }

  SessionResponse _getMockResponse() {
    return SessionResponse(
      exercise: 'Squat',
      repsDetected: 12,
      scores: {
        'depth': 8.5,
        'back_angle': 7.0,
        'knees_in': 9.0,
        'tempo': 6.5,
        'stability': 8.0,
      },
      overallScore: 7.8,
      feedback: [
        'Great depth on most reps!',
        'Watch your back angle, try to keep it more upright.',
        'Good knee stability throughout the movement.',
      ],
    );
  }
}
