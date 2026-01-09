// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionRequest _$SessionRequestFromJson(Map<String, dynamic> json) =>
    SessionRequest(
      exerciseView: json['exercise_view'] as String,
      poseSequence: (json['pose_sequence'] as List<dynamic>)
          .map(
            (e) => (e as List<dynamic>)
                .map(
                  (e) => (e as List<dynamic>)
                      .map((e) => (e as num).toDouble())
                      .toList(),
                )
                .toList(),
          )
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

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

Map<String, dynamic> _$SessionResponseToJson(SessionResponse instance) =>
    <String, dynamic>{
      'exercise': instance.exercise,
      'reps_detected': instance.repsDetected,
      'scores': instance.scores,
      'overall_score': instance.overallScore,
      'feedback': instance.feedback,
    };
