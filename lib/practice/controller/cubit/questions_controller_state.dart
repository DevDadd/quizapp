part of 'questions_controller.dart';

class QuestionsControllerState extends Equatable {
  const QuestionsControllerState({
    this.options = const [],
    this.loadingQuestionIds = const {},
    this.questionErrors = const {},
  });

  final List<QuestionOption> options;
  final Set<int> loadingQuestionIds;
  final Map<int, String> questionErrors;

  QuestionsControllerState copyWith({
    List<QuestionOption>? options,
    Set<int>? loadingQuestionIds,
    Map<int, String>? questionErrors,
    int? clearQuestionErrorId,
  }) {
    final errors = Map<int, String>.from(questionErrors ?? this.questionErrors);
    if (clearQuestionErrorId != null) {
      errors.remove(clearQuestionErrorId);
    }
    return QuestionsControllerState(
      options: options ?? this.options,
      loadingQuestionIds: loadingQuestionIds ?? this.loadingQuestionIds,
      questionErrors: errors,
    );
  }

  @override
  List<Object?> get props => [options, loadingQuestionIds, questionErrors];
}
