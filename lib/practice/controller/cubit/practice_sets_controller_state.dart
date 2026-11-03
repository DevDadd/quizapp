import 'package:equatable/equatable.dart';
import 'package:quizapp/practice/model/practice_sets.dart';
import 'package:quizapp/practice/model/question.dart';
import 'package:quizapp/practice/model/question_options.dart';

class PracticeSetsControllerState extends Equatable {
  const PracticeSetsControllerState({
    this.practiceSets = const [],
    this.questions = const [],
    this.options = const [],
  });
  final List<PracticeSet> practiceSets;
  final List<Question> questions;
  final List<QuestionOption> options;
  @override
  List<Object?> get props => [practiceSets, questions, options];
}
