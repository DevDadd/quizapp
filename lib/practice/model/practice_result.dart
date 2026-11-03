class PracticeResult {
  final int totalQuestions;
  final int answeredCount;
  final int correctCount;
  final int wrongCount;
  final int skippedCount;
  final int totalResponseTimeMs;
  final String? status;
  final String? mode;
  final List<PracticeResultAnswer> answers;

  const PracticeResult({
    this.totalQuestions = 0,
    this.answeredCount = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.skippedCount = 0,
    this.totalResponseTimeMs = 0,
    this.status,
    this.mode,
    this.answers = const [],
  });

  factory PracticeResult.fromJson(Map<String, dynamic> json) {
    final answersJson = json['answers'] as List? ?? const [];
    return PracticeResult(
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 0,
      answeredCount: (json['answered_count'] as num?)?.toInt() ?? 0,
      correctCount: (json['correct_count'] as num?)?.toInt() ?? 0,
      wrongCount: (json['wrong_count'] as num?)?.toInt() ?? 0,
      skippedCount: (json['skipped_count'] as num?)?.toInt() ?? 0,
      totalResponseTimeMs:
          (json['total_response_time_ms'] as num?)?.toInt() ?? 0,
      status: json['status'] as String?,
      mode: json['mode'] as String?,
      answers: answersJson
          .map(
            (answer) => PracticeResultAnswer.fromJson(
              Map<String, dynamic>.from(answer as Map),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> resultToJson() {
    return {
      'total_questions': totalQuestions,
      'answered_count': answeredCount,
      'correct_count': correctCount,
      'wrong_count': wrongCount,
      'skipped_count': skippedCount,
      'total_response_time_ms': totalResponseTimeMs,
      'status': status,
      'mode': mode,
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }
}

class PracticeResultAnswer {
  final int orderIndex;
  final int questionId;
  final String content;
  final int? selectedOptionId;
  final int? correctOptionId;
  final bool isCorrect;

  const PracticeResultAnswer({
    required this.orderIndex,
    required this.questionId,
    required this.content,
    this.selectedOptionId,
    this.correctOptionId,
    required this.isCorrect,
  });

  factory PracticeResultAnswer.fromJson(Map<String, dynamic> json) {
    return PracticeResultAnswer(
      orderIndex: (json['order_index'] as num).toInt(),
      questionId: (json['question_id'] as num).toInt(),
      content: json['content'] as String,
      selectedOptionId: (json['selected_option_id'] as num?)?.toInt(),
      correctOptionId: (json['correct_option_id'] as num?)?.toInt(),
      isCorrect: json['is_correct'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_index': orderIndex,
      'question_id': questionId,
      'content': content,
      'selected_option_id': selectedOptionId,
      'correct_option_id': correctOptionId,
      'is_correct': isCorrect,
    };
  }
}
