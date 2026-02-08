import 'package:json_annotation/json_annotation.dart';

part 'session_models.g.dart';

@JsonSerializable(createFactory: false)
class SessionRequest {
  @JsonKey(name: 'exercise_view')
  final String exerciseView;

  @JsonKey(name: 'pose_sequence')
  final List<List<List<double>>> poseSequence;

  final Map<String, dynamic> metadata;

  SessionRequest({
    required this.exerciseView,
    required this.poseSequence,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => _$SessionRequestToJson(this);
}

@JsonSerializable(createToJson: false)
class SessionResponse {
  final String exercise;

  @JsonKey(name: 'reps_detected')
  final int repsDetected;

  final Map<String, double> scores;

  @JsonKey(name: 'overall_score')
  final double overallScore;

  final List<String> feedback;

  SessionResponse({
    required this.exercise,
    required this.repsDetected,
    required this.scores,
    required this.overallScore,
    required this.feedback,
  });

  factory SessionResponse.fromJson(Map<String, dynamic> json) =>
      _$SessionResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class ErrorResponse {
  @JsonKey(name: 'error_code')
  final String errorCode;

  final String message;

  ErrorResponse({
    required this.errorCode,
    required this.message,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);
}

/// Custom exception for API errors carrying the backend's error message.
class ApiException implements Exception {
  final String message;
  final String? errorCode;
  final int? statusCode;

  ApiException(this.message, {this.errorCode, this.statusCode});

  @override
  String toString() =>
      'ApiException: $message (code: $errorCode, status: $statusCode)';
}
