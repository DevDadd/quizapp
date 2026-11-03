class Question {
  final int questionId;
  final int orderIndex;
  final String content;
  final String? category;
  final int? difficulty;
  final DateTime? createdAt;

  const Question({
    required this.questionId,
    required this.orderIndex,
    required this.content,
    this.category,
    this.difficulty,
    this.createdAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionId: (json['question_id'] as num).toInt(),
      orderIndex: (json['order_index'] as num).toInt(),
      content: json['content'] as String,
      category: json['category'] as String?,
      difficulty: (json['difficulty'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'order_index': orderIndex,
      'content': content,
      'category': category,
      'difficulty': difficulty,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}