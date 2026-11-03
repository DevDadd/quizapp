import 'package:equatable/equatable.dart';

class UserwrongquestionControllerState extends Equatable {
  const UserwrongquestionControllerState({
    this.recorded,
    this.isRecording = false,
    this.errorMessage,
  });

  final bool? recorded;
  final bool isRecording;
  final String? errorMessage;

  UserwrongquestionControllerState copyWith({
    bool? recorded,
    bool? isRecording,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UserwrongquestionControllerState(
      recorded: recorded ?? this.recorded,
      isRecording: isRecording ?? this.isRecording,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [recorded, isRecording, errorMessage];
}
