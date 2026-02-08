// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$SessionRequestToJson(SessionRequest instance) =>
    <String, dynamic>{
      'exercise_view': instance.exerciseView,
      'pose_sequence': instance.poseSequence,
      'metadata': instance.metadata,
    };

SessionResponse _$SessionResponseFromJson(Map<String, dynamic> json) =>
    SessionResponse(
      exercise: json['exercise'] as String,
      repsDetected: (json['reps_detected'] as num).toInt(),
      scores: (json['scores'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      overallScore: (json['overall_score'] as num).toDouble(),
      feedback: (json['feedback'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) =>
    ErrorResponse(
      errorCode: json['error_code'] as String,
      message: json['message'] as String,
    );
