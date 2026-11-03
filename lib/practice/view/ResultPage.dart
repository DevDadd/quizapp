import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizapp/practice/controller/cubit/practice_session_controller.dart';
import 'package:quizapp/practice/controller/cubit/practice_session_controller_state.dart';
import 'package:quizapp/practice/controller/cubit/questions_controller.dart';
import 'package:quizapp/practice/model/question_options.dart';

class Resultpage extends StatelessWidget {
  const Resultpage({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF1B1B1B);
    const foregroundColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        centerTitle: true,
        title: const Text('Kết quả'),
      ),
      body:
          BlocBuilder<
            PracticeSessionControllerCubit,
            PracticeSessionControllerState
          >(
            builder: (context, sessionState) {
              if (sessionState.isCalculatingResult) {
                return const Center(child: CircularProgressIndicator());
              }
              if (sessionState.errorMessage != null) {
                return Center(
                  child: Text(
                    sessionState.errorMessage!,
                    style: const TextStyle(color: foregroundColor),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final result = sessionState.result;
              if (result == null || result.answers.isEmpty) {
                return const Center(
                  child: Text(
                    'Không có dữ liệu kết quả.',
                    style: TextStyle(color: foregroundColor),
                  ),
                );
              }

              return BlocBuilder<
                QuestionsControllerCubit,
                QuestionsControllerState
              >(
                builder: (context, questionsState) {
                  final answers = [...result.answers]
                    ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.sizeOf(context).width - 24,
                      ),
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingTextStyle: const TextStyle(
                            color: foregroundColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          dataTextStyle: const TextStyle(
                            color: foregroundColor,
                            fontSize: 16,
                          ),
                          dividerThickness: 1,
                          columns: const [
                            DataColumn(label: Text('Câu hỏi')),
                            DataColumn(label: Text('Bạn chọn')),
                            DataColumn(label: Text('Đáp án đúng')),
                            DataColumn(label: Text('Kết quả')),
                          ],
                          rows: answers.map((answer) {
                            final selectedOption = _findOption(
                              questionsState.options,
                              answer.questionId,
                              answer.selectedOptionId,
                            );
                            final correctOption = _findOption(
                              questionsState.options,
                              answer.questionId,
                              answer.correctOptionId,
                            );

                            return DataRow(
                              cells: [
                                DataCell(Text(answer.content)),
                                DataCell(
                                  Text(
                                    answer.selectedOptionId == null
                                        ? 'Chưa trả lời'
                                        : _optionLabel(
                                            selectedOption,
                                            answer.selectedOptionId,
                                          ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    _optionLabel(
                                      correctOption,
                                      answer.correctOptionId,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    answer.selectedOptionId == null
                                        ? 'Chưa trả lời'
                                        : answer.isCorrect
                                        ? 'Đúng'
                                        : 'Sai',
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
    );
  }

  QuestionOption? _findOption(
    List<QuestionOption> options,
    int questionId,
    int? optionId,
  ) {
    if (optionId == null) return null;
    for (final option in options) {
      if (option.questionId == questionId && option.optionId == optionId) {
        return option;
      }
    }
    return null;
  }

  String _optionLabel(QuestionOption? option, int? optionId) {
    if (option == null) return optionId == null ? '—' : 'Đáp án $optionId';
    final label = String.fromCharCode(65 + option.orderIndex);
    return '$label. ${option.content}';
  }
}
