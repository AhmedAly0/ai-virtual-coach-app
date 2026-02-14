import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/session_models.dart';

// ---------------------------------------------------------------------------
// Base URL Configuration
// ---------------------------------------------------------------------------
// For Android EMULATOR   → 'http://10.0.2.2:8000'
// For PHYSICAL DEVICE    → your computer's local IP,
//                           e.g. 'http://192.168.1.X:8000'
//   (run `ipconfig` on Windows to find your IPv4 address)
// For iOS SIMULATOR      → 'http://localhost:8000'
// ---------------------------------------------------------------------------
const String _baseUrl = 'http://192.168.1.198:8000';

/// Set to `true` to bypass the real backend and return mock data.
/// Useful for UI development when the backend is not running.
const bool _useMock = false;

/// Timeout duration for the analyze-session HTTP request.
const Duration _requestTimeout = Duration(seconds: 120);

class ApiService {
  final http.Client _client = http.Client();

  Future<SessionResponse> analyzeSession(SessionRequest request) async {
    // ── Mock mode for offline UI development ──────────────────────────────
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 2));
      return _getMockResponse();
    }

    // ── Real backend call ─────────────────────────────────────────────────
    try {
      final jsonBody = jsonEncode(request.toJson());
      final payloadKB = (jsonBody.length / 1024).toStringAsFixed(1);
      // ignore: avoid_print
      print(
        '[ApiService] Sending ${request.poseSequence.length} frames '
        '($payloadKB KB) to $_baseUrl/api/session/analyze',
      );

      final response = await _client
          .post(
            Uri.parse('$_baseUrl/api/session/analyze'),
            headers: {'Content-Type': 'application/json'},
            body: jsonBody,
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        return SessionResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }

      // ── Non-200: try to parse backend error response ──
      try {
        final errorJson =
            jsonDecode(response.body) as Map<String, dynamic>;
        final err = ErrorResponse.fromJson(errorJson);
        throw ApiException(
          err.message,
          errorCode: err.errorCode,
          statusCode: response.statusCode,
        );
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException(
          'Server error (${response.statusCode}). Please try again.',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException(
        'Analysis timed out. Your session may be too long, '
        'or the server is busy. Please try again.',
      );
    } on SocketException {
      throw ApiException(
        'Could not reach the server. Make sure the backend is running '
        'and your device is on the same network.',
      );
    } on Exception catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Mock response for offline UI development.
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

  /// Clean up the HTTP client when no longer needed.
  void dispose() {
    _client.close();
  }
}
