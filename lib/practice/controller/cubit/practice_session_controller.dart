import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:quizapp/di.dart';
import 'package:quizapp/practice/controller/cubit/practice_session_controller_state.dart';
import 'package:quizapp/practice/model/practice_sessions.dart';
import 'package:quizapp/practice/model/question.dart';
import 'package:quizapp/practice/model/practice_result.dart';

class PracticeSessionControllerCubit
    extends Cubit<PracticeSessionControllerState> {
  PracticeSessionControllerCubit()
    : super(const PracticeSessionControllerState());

  final Dio _dio = getIt<Dio>();

  Future<void> startSession(String userId, String mode, String setId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'https://quiz-mobile-backend.onrender.com/practice/sessions/',
      data: {
        'user_id': int.parse(userId),
        'mode': mode,
        'set_id': int.parse(setId),
      },
    );

    final responseData = response.data;
    if (responseData == null) {
      throw const FormatException('Practice session response is empty.');
    }

    final dynamic responsePayload = responseData['data'] ?? responseData;
    if (responsePayload is! Map || responsePayload['practice_id'] == null) {
      throw const FormatException(
        'Practice session response does not contain practice_id.',
      );
    }

    final practiceSession = PracticeSession.fromJson(
      Map<String, dynamic>.from(responsePayload),
    );
    emit(
      state.copyWith(
        practiceSession: practiceSession,
        clearSubmissionResult: true,
        clearResult: true,
        clearError: true,
      ),
    );
  }

  Future<void> submit({
    required List<Question> questions,
    required Map<int, int> selectedOptionIds,
    required Map<int, int> responseTimeMs,
  }) async {
    final practiceId = state.practiceSession?.practiceId;
    if (practiceId == null) {
      emit(
        state.copyWith(
          errorMessage: 'Chưa có phiên làm bài để nộp.',
          clearSubmissionResult: true,
        ),
      );
      return;
    }

    final answers = questions
        .where((question) => selectedOptionIds.containsKey(question.questionId))
        .map(
          (question) => {
            'order_index': question.orderIndex,
            'selected_option_id': selectedOptionIds[question.questionId],
            'response_time_ms': responseTimeMs[question.questionId] ?? 0,
          },
        )
        .toList();

    emit(
      state.copyWith(
        isSubmitting: true,
        clearSubmissionResult: true,
        clearError: true,
      ),
    );

    try {
      final url =
          'https://quiz-mobile-backend.onrender.com/practice/sessions/$practiceId/submit/';
      final payload = {'answers': answers};
      debugPrint('POST $url');
      debugPrint('Request body: ${jsonEncode(payload)}');

      final response = await _dio.post<Map<String, dynamic>>(
        url,
        data: payload,
      );
      final responseData = response.data;
      if (responseData == null) {
        throw const FormatException('Submit response is empty.');
      }

      final dynamic responsePayload = responseData['data'] ?? responseData;
      if (responsePayload is! Map) {
        throw const FormatException('Submit response must be an object.');
      }

      emit(
        state.copyWith(
          submitted: responsePayload['submitted'] as bool?,
          submissionStatus: responsePayload['status'] as String?,
          isSubmitting: false,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: error is DioException
              ? error.message ?? 'Không thể nộp bài. Vui lòng thử lại.'
              : error.toString(),
        ),
      );
    }
  }

  Future<PracticeResult?> calculateResult(String practiceId) async {
    emit(
      state.copyWith(
        isCalculatingResult: true,
        clearError: true,
        clearResult: true,
      ),
    );

    try {
      final url =
          'https://quiz-mobile-backend.onrender.com/practice/sessions/$practiceId/result/';
      debugPrint('GET $url');
      final response = await _dio.get<dynamic>(url);
      final responseData = response.data;
      if (responseData == null) {
        throw const FormatException('Practice result response is empty.');
      }

      final dynamic resultData =
          responseData is Map && responseData['data'] is Map
          ? responseData['data']
          : responseData;
      if (resultData is! Map) {
        throw const FormatException(
          'Practice result response must be an object.',
        );
      }

      final result = PracticeResult.fromJson(
        Map<String, dynamic>.from(resultData),
      );
      emit(
        state.copyWith(
          result: result,
          isCalculatingResult: false,
          clearError: true,
        ),
      );
      return result;
    } catch (error) {
      emit(
        state.copyWith(
          isCalculatingResult: false,
          errorMessage: error is DioException
              ? error.message ?? 'Không thể tải kết quả. Vui lòng thử lại.'
              : error.toString(),
        ),
      );
      return null;
    }
  }
}
