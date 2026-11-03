import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:quizapp/di.dart';
import 'package:quizapp/practice/controller/cubit/userwrongquestion_controller_state.dart';

class UserwrongquestionControllerCubit
    extends Cubit<UserwrongquestionControllerState> {
  UserwrongquestionControllerCubit()
    : super(const UserwrongquestionControllerState());

  final Dio _dio = getIt<Dio>();

  Future<void> recordWrong(String practiceId) async {
    emit(state.copyWith(isRecording: true, clearError: true));
    final url =
        'https://quiz-mobile-backend.onrender.com/practice/sessions/$practiceId/record-wrong/';

    try {
      debugPrint('POST $url');
      final response = await _dio.post<dynamic>(url);
      final dynamic responseData = response.data;
      if (responseData == null) {
        throw const FormatException('Record wrong response is empty.');
      }

      final dynamic recorded = responseData is Map
          ? responseData['data'] ?? responseData['recorded']
          : responseData;
      if (recorded is! bool) {
        throw const FormatException('Record wrong response must be a boolean.');
      }

      emit(state.copyWith(recorded: recorded, isRecording: false));
    } catch (error) {
      emit(
        state.copyWith(
          isRecording: false,
          errorMessage: error is DioException
              ? error.message ?? 'Không thể lưu câu sai. Vui lòng thử lại.'
              : error.toString(),
        ),
      );
    }
  }
}
