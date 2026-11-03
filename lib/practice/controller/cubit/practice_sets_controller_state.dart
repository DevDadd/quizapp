import 'package:equatable/equatable.dart';
import 'package:quizapp/practice/model/practice_sets.dart';
import 'package:quizapp/practice/model/question.dart';

class PracticeSetsControllerState extends Equatable {
  const PracticeSetsControllerState({
    this.practiceSets = const [],
    this.questions = const [],
    this.selectedOptionIds = const {},
    this.responseTimeMs = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  final List<PracticeSet> practiceSets;
  final List<Question> questions;
  final Map<int, int> selectedOptionIds;
  final Map<int, int> responseTimeMs;
  final bool isLoading;
  final String? errorMessage;

  PracticeSetsControllerState copyWith({
    List<PracticeSet>? practiceSets,
    List<Question>? questions,
    Map<int, int>? selectedOptionIds,
    Map<int, int>? responseTimeMs,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PracticeSetsControllerState(
      practiceSets: practiceSets ?? this.practiceSets,
      questions: questions ?? this.questions,
      selectedOptionIds: selectedOptionIds ?? this.selectedOptionIds,
      responseTimeMs: responseTimeMs ?? this.responseTimeMs,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    practiceSets,
    questions,
    selectedOptionIds,
    responseTimeMs,
    isLoading,
    errorMessage,
  ];
}
