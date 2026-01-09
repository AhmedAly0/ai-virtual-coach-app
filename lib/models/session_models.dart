import 'package:json_annotation/json_annotation.dart';

part 'session_models.g.dart';

@JsonSerializable()
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

@JsonSerializable()
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
