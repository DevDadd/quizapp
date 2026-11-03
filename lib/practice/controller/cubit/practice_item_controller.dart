import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:quizapp/di.dart';
import 'package:quizapp/practice/controller/cubit/practice_item_controller_state.dart';

class PracticeItemControllerCubit extends Cubit<PracticeItemControllerState> {
  PracticeItemControllerCubit() : super(const PracticeItemControllerState());

  final Dio _dio = getIt<Dio>();

  Future<bool> grade(String practiceId) async {
    emit(state.copyWith(isGrading: true, clearError: true));
    final url =
        'https://quiz-mobile-backend.onrender.com/practice/sessions/$practiceId/grade/';

    try {
      debugPrint('POST $url');
      final response = await _dio.post<dynamic>(url);
      final dynamic responseData = response.data;
      if (responseData == null) {
        throw const FormatException('Grade response is empty.');
      }

      final dynamic gradeResult = responseData is Map
          ? responseData['data'] ?? responseData['graded']
          : responseData;
      if (gradeResult is! bool) {
        throw const FormatException('Grade response must be a boolean.');
      }

      emit(state.copyWith(gradeResult: gradeResult, isGrading: false));
      return gradeResult;
    } catch (error) {
      emit(
        state.copyWith(
          isGrading: false,
          errorMessage: error is DioException
              ? error.message ?? 'Không thể chấm bài. Vui lòng thử lại.'
              : error.toString(),
        ),
      );
      return false;
    }
  }
}
