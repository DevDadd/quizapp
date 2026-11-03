import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:quizapp/di.dart';
import 'package:quizapp/practice/controller/cubit/practice_sets_controller_state.dart';
import 'package:quizapp/practice/model/practice_sets.dart';
import 'package:quizapp/practice/model/question.dart';
import 'package:quizapp/practice/model/question_options.dart';

class PracticeSetsControllerCubit extends Cubit<PracticeSetsControllerState> {
  PracticeSetsControllerCubit() : super(PracticeSetsControllerState());

  final Dio _dio = getIt<Dio>();
  Future<void> getPracticeSets(String difficulty) async {
    final response = await _dio.get(
      'https://quiz-mobile-backend.onrender.com/practice/sets',
    );

    final sets = (response.data as List)
        .map((json) => PracticeSet.fromJson(json))
        .toList();

    final difficultyValue = switch (difficulty.toLowerCase()) {
      'dễ' => 1,
      'trung bình' => 2,
      'khó' => 3,
      _ => null,
    };

    final filteredSets = difficultyValue == null
        ? sets
        : sets.where((e) => e.difficulty == difficultyValue).toList();

    emit(PracticeSetsControllerState(practiceSets: filteredSets));
  }

  Future<void> getQuestions(String setId) async {
    final response = await _dio.get(
      'https://quiz-mobile-backend.onrender.com/practice/sets/$setId/questions/',
    );

    final responseData = response.data;
    if (responseData == null) {
      throw const FormatException('Questions response is empty.');
    }

    final dynamic data = responseData is Map
        ? responseData['data']
        : responseData;
    if (data is! List) {
      throw const FormatException('Questions response must contain a list.');
    }

    final questions = data
        .map(
          (json) => Question.fromJson(Map<String, dynamic>.from(json as Map)),
        )
        .toList();

    emit(
      PracticeSetsControllerState(
        practiceSets: state.practiceSets,
        questions: questions,
        options: const [],
      ),
    );
  }

  Future<void> getOptions(String question_id) async {
    final response = await _dio.get(
      'https://quiz-mobile-backend.onrender.com/practice/questions/$question_id/options/',
    );

    final responseData = response.data;
    if (responseData == null) {
      throw const FormatException('Options response is empty.');
    }

    final dynamic data = responseData is Map
        ? responseData['data']
        : responseData;
    if (data is! List) {
      throw const FormatException('Options response must contain a list.');
    }

    final requestedQuestionId = int.parse(question_id);
    final fetchedOptions = data
        .map(
          (json) => QuestionOption.fromJson(
            Map<String, dynamic>.from(json as Map),
            questionId: requestedQuestionId,
          ),
        )
        .toList();

    final options = [
      ...state.options.where(
        (option) => option.questionId != requestedQuestionId,
      ),
      ...fetchedOptions,
    ];

    emit(
      PracticeSetsControllerState(
        practiceSets: state.practiceSets,
        questions: state.questions,
        options: options,
      ),
    );
  }
}
