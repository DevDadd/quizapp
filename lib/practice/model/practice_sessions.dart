import 'package:quizapp/practice/model/practice_result.dart';

class PracticeSession extends PracticeResult {
  final int practiceId;
  final int? userId;
  final String? mode;
  final int? setId;
  final int? timeLimitSeconds;
  final String? status;
  final DateTime? startedAt;
  final DateTime? endedAt;

  PracticeSession({
    required this.practiceId,
    this.userId,
    this.mode,
    this.setId,
    this.timeLimitSeconds,
    this.status,
    this.startedAt,
    this.endedAt,
    super.totalQuestions,
    super.answeredCount,
    super.correctCount,
    super.wrongCount,
    super.totalResponseTimeMs,
  });

  factory PracticeSession.fromJson(Map<String, dynamic> json) {
    return PracticeSession(
      practiceId: (json['practice_id'] as num).toInt(),
      userId: (json['user_id'] as num?)?.toInt(),
      mode: json['mode'] as String?,
      setId: (json['set_id'] as num?)?.toInt(),
      timeLimitSeconds: (json['time_limit_seconds'] as num?)?.toInt(),
      status: json['status'] as String?,
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 0,
      answeredCount: (json['answered_count'] as num?)?.toInt() ?? 0,
      correctCount: (json['correct_count'] as num?)?.toInt() ?? 0,
      wrongCount: (json['wrong_count'] as num?)?.toInt() ?? 0,
      totalResponseTimeMs:
          (json['total_response_time_ms'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...resultToJson(),
      'practice_id': practiceId,
      'user_id': userId,
      'mode': mode,
      'set_id': setId,
      'time_limit_seconds': timeLimitSeconds,
      'status': status,
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
    };
  }
}
