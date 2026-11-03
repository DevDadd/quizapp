import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:quizapp/di.dart';
import 'package:quizapp/practice/model/question_options.dart';

part 'questions_controller_state.dart';

class QuestionsControllerCubit extends Cubit<QuestionsControllerState> {
  QuestionsControllerCubit() : super(const QuestionsControllerState());

  final Dio _dio = getIt<Dio>();

  Future<List<QuestionOption>> getOptions(String questionId) async {
    final id = int.tryParse(questionId);
    if (id == null) {
      throw FormatException('Invalid question id: $questionId');
    }

    emit(
      state.copyWith(
        loadingQuestionIds: {...state.loadingQuestionIds, id},
        clearQuestionErrorId: id,
      ),
    );

    try {
      final response = await _dio.get(
        'https://quiz-mobile-backend.onrender.com/practice/questions/$questionId/options/',
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

      final fetchedOptions = data
          .map(
            (json) => QuestionOption.fromJson(
              Map<String, dynamic>.from(json as Map),
              questionId: id,
            ),
          )
          .toList();
      final options = [
        ...state.options.where((option) => option.questionId != id),
        ...fetchedOptions,
      ];
      final loadingQuestionIds = {...state.loadingQuestionIds}..remove(id);
      emit(
        state.copyWith(
          options: options,
          loadingQuestionIds: loadingQuestionIds,
          clearQuestionErrorId: id,
        ),
      );
      return fetchedOptions;
    } catch (error) {
      final loadingQuestionIds = {...state.loadingQuestionIds}..remove(id);
      final errors = Map<int, String>.from(state.questionErrors)
        ..[id] = _errorMessage(error);
      emit(
        state.copyWith(
          loadingQuestionIds: loadingQuestionIds,
          questionErrors: errors,
        ),
      );
      return const [];
    }
  }

  String _errorMessage(Object error) {
    if (error is DioException) {
      return error.message ?? 'Không thể tải đáp án. Vui lòng thử lại.';
    }
    return error.toString();
  }
}
