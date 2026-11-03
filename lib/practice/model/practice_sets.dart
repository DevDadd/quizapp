class PracticeSet {
  final int setId;
  final String title;
  final String? category;
  final int difficulty;
  final int timeLimitSeconds;
  final int questionCount;
  final bool? isActive;
  final DateTime? createdAt;

  const PracticeSet({
    required this.setId,
    required this.title,
    this.category,
    required this.difficulty,
    required this.timeLimitSeconds,
    required this.questionCount,
    this.isActive,
    this.createdAt,
  });

  factory PracticeSet.fromJson(Map<String, dynamic> json) {
    return PracticeSet(
      setId: json['set_id'] as int,
      title: json['title'] as String,
      category: json['category'] as String?,
      difficulty: json['difficulty'] as int,
      timeLimitSeconds: json['time_limit_seconds'] as int,
      questionCount: json['question_count'] as int,
      isActive: json['is_active'] as bool?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'set_id': setId,
      'title': title,
      'category': category,
      'difficulty': difficulty,
      'time_limit_seconds': timeLimitSeconds,
      'question_count': questionCount,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  PracticeSet copyWith({
    int? setId,
    String? title,
    String? category,
    int? difficulty,
    int? timeLimitSeconds,
    int? questionCount,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return PracticeSet(
      setId: setId ?? this.setId,
      title: title ?? this.title,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      questionCount: questionCount ?? this.questionCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
