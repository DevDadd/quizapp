class QuestionOption {
  final int optionId;
  final int? questionId;
  final String content;
  final bool? isCorrect;
  final int orderIndex;

  const QuestionOption({
    required this.optionId,
    this.questionId,
    required this.content,
    this.isCorrect,
    required this.orderIndex,
  });

  factory QuestionOption.fromJson(
    Map<String, dynamic> json, {
    int? questionId,
  }) {
    return QuestionOption(
      optionId: (json['option_id'] as num).toInt(),
      questionId: (json['question_id'] as num?)?.toInt() ?? questionId,
      content: json['content'] as String,
      isCorrect: json['is_correct'] as bool?,
      orderIndex: (json['order_index'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'option_id': optionId,
      'question_id': questionId,
      'content': content,
      'is_correct': isCorrect,
      'order_index': orderIndex,
    };
  }
}
