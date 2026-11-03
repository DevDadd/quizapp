import 'package:equatable/equatable.dart';

class PracticeItemControllerState extends Equatable {
  const PracticeItemControllerState({
    this.gradeResult,
    this.isGrading = false,
    this.errorMessage,
  });

  final bool? gradeResult;
  final bool isGrading;
  final String? errorMessage;

  PracticeItemControllerState copyWith({
    bool? gradeResult,
    bool? isGrading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PracticeItemControllerState(
      gradeResult: gradeResult ?? this.gradeResult,
      isGrading: isGrading ?? this.isGrading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [gradeResult, isGrading, errorMessage];
}
