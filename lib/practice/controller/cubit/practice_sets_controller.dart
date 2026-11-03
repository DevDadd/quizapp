import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:quizapp/di.dart';
import 'package:quizapp/practice/controller/cubit/practice_sets_controller_state.dart';
import 'package:quizapp/practice/model/practice_sets.dart';
import 'package:quizapp/practice/model/question.dart';

class PracticeSetsControllerCubit extends Cubit<PracticeSetsControllerState> {
  PracticeSetsControllerCubit() : super(const PracticeSetsControllerState());

  final Dio _dio = getIt<Dio>();
  final Map<int, DateTime> _questionStartedAt = {};

  Future<void> getPracticeSets(String difficulty) async {
    final response = await _dio.get(
      'https://quiz-mobile-backend.onrender.com/practice/sets',
    );

    final sets = (response.data as List)
        .map((json) => PracticeSet.fromJson(json))
        .toList();
    final difficultyValue = switch (difficulty.trim().toLowerCase()) {
      'dễ' => 1,
      'trung bình' => 2,
      'khó' => 3,
      _ => int.tryParse(difficulty.trim()),
    };
    final filteredSets = difficultyValue == null
        ? sets
        : sets.where((set) => set.difficulty == difficultyValue).toList();

    emit(state.copyWith(practiceSets: filteredSets));
  }

  Future<void> getQuestions(String setId) async {
    emit(
      state.copyWith(
        questions: const [],
        selectedOptionIds: const {},
        responseTimeMs: const {},
        isLoading: true,
        clearError: true,
      ),
    );

    try {
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
      _questionStartedAt
        ..clear()
        ..addEntries(
          questions.map(
            (question) => MapEntry(question.questionId, DateTime.now()),
          ),
        );
      emit(
        state.copyWith(
          questions: questions,
          isLoading: false,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(isLoading: false, errorMessage: _errorMessage(error)),
      );
    }
  }

  void selectOption({required int questionId, required int optionId}) {
    final selected = Map<int, int>.from(state.selectedOptionIds)
      ..[questionId] = optionId;
    final responseTimes = Map<int, int>.from(state.responseTimeMs)
      ..[questionId] = DateTime.now()
          .difference(_questionStartedAt[questionId] ?? DateTime.now())
          .inMilliseconds;
    emit(
      state.copyWith(
        selectedOptionIds: selected,
        responseTimeMs: responseTimes,
      ),
    );
  }

  String _errorMessage(Object error) {
    if (error is DioException) {
      return error.message ?? 'Không thể tải dữ liệu. Vui lòng thử lại.';
    }
    return error.toString();
  }
}
