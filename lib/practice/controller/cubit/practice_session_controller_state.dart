import 'package:equatable/equatable.dart';
import 'package:quizapp/practice/model/practice_result.dart';
import 'package:quizapp/practice/model/practice_sessions.dart';

class PracticeSessionControllerState extends Equatable {
  const PracticeSessionControllerState({
    this.practiceSession,
    this.submitted,
    this.submissionStatus,
    this.isSubmitting = false,
    this.isCalculatingResult = false,
    this.errorMessage,
    this.result,
  });

  final PracticeSession? practiceSession;
  final bool? submitted;
  final String? submissionStatus;
  final bool isSubmitting;
  final bool isCalculatingResult;
  final String? errorMessage;
  final PracticeResult? result;

  PracticeSessionControllerState copyWith({
    PracticeSession? practiceSession,
    bool? submitted,
    String? submissionStatus,
    bool? isSubmitting,
    bool? isCalculatingResult,
    String? errorMessage,
    PracticeResult? result,
    bool clearSubmissionResult = false,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return PracticeSessionControllerState(
      practiceSession: practiceSession ?? this.practiceSession,
      submitted: clearSubmissionResult ? null : submitted ?? this.submitted,
      submissionStatus: clearSubmissionResult
          ? null
          : submissionStatus ?? this.submissionStatus,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isCalculatingResult: isCalculatingResult ?? this.isCalculatingResult,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      result: clearResult ? null : result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [
    practiceSession,
    submitted,
    submissionStatus,
    isSubmitting,
    isCalculatingResult,
    errorMessage,
    result,
  ];
}
