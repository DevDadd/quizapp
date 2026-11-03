import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizapp/authentication/controller/user_controller.dart';
import 'package:quizapp/practice/controller/cubit/practice_session_controller.dart';
import 'package:quizapp/practice/controller/cubit/practice_session_controller_state.dart';
import 'package:quizapp/practice/controller/cubit/practice_item_controller.dart';
import 'package:quizapp/practice/controller/cubit/practice_item_controller_state.dart';
import 'package:quizapp/practice/controller/cubit/practice_sets_controller.dart';
import 'package:quizapp/practice/controller/cubit/practice_sets_controller_state.dart';
import 'package:quizapp/practice/controller/cubit/questions_controller.dart';
import 'package:quizapp/practice/controller/cubit/userwrongquestion_controller.dart';
import 'package:quizapp/practice/model/practice_sets.dart';
import 'package:quizapp/practice/model/question.dart';
import 'package:quizapp/practice/model/question_options.dart';
import 'package:quizapp/practice/view/ResultPage.dart';

class Practicesessionpage extends StatefulWidget {
  const Practicesessionpage({super.key, required this.practiceSet});

  final PracticeSet practiceSet;

  @override
  State<Practicesessionpage> createState() => _PracticesessionpageState();
}

class _PracticesessionpageState extends State<Practicesessionpage> {
  late int _remainingSeconds;
  Timer? _countdownTimer;
  bool _isFinishing = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.practiceSet.timeLimitSeconds;
    _startSessionAndLoadQuestions();
  }

  void _startCountdown() {
    if (_remainingSeconds <= 0) return;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _countdownTimer = null;
        setState(() => _remainingSeconds = 0);
        _submitOnTimeExpired();
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  Future<void> _submitOnTimeExpired() async {
    if (!mounted || _isFinishing) return;
    await _submitAndGrade(context.read<PracticeSetsControllerCubit>().state);
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _startSessionAndLoadQuestions() async {
    final userId = context.read<UserControllerCubit>().state.user?.userId;
    if (userId != null) {
      try {
        await context.read<PracticeSessionControllerCubit>().startSession(
          userId.toString(),
          'SET',
          widget.practiceSet.setId.toString(),
        );
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể bắt đầu phiên: $error')),
          );
        }
      }
    }
    await _loadQuestionsAndOptions();
    if (mounted &&
        context.read<PracticeSessionControllerCubit>().state.practiceSession !=
            null) {
      _startCountdown();
    }
  }

  Future<void> _loadQuestionsAndOptions() async {
    final practiceCubit = context.read<PracticeSetsControllerCubit>();
    await practiceCubit.getQuestions(widget.practiceSet.setId.toString());
    if (!mounted || practiceCubit.state.errorMessage != null) return;

    final questions = practiceCubit.state.questions;
    final questionsCubit = context.read<QuestionsControllerCubit>();
    await Future.wait(
      questions.map(
        (question) => questionsCubit.getOptions(question.questionId.toString()),
      ),
    );
  }

  Future<void> _submitAndGrade(
    PracticeSetsControllerState practiceState,
  ) async {
    if (_isFinishing || !mounted) return;
    _isFinishing = true;
    final sessionCubit = context.read<PracticeSessionControllerCubit>();
    final didSubmit = await sessionCubit.submit(
      questions: practiceState.questions,
      selectedOptionIds: practiceState.selectedOptionIds,
      responseTimeMs: practiceState.responseTimeMs,
    );
    if (!didSubmit || !mounted) {
      _isFinishing = false;
      return;
    }
    _countdownTimer?.cancel();
    _countdownTimer = null;

    final practiceId = sessionCubit.state.practiceSession?.practiceId;
    if (practiceId != null) {
      final graded = await context.read<PracticeItemControllerCubit>().grade(
        practiceId.toString(),
      );
      if (graded && mounted) {
        final result = await sessionCubit.calculateResult(
          practiceId.toString(),
        );
        if (result != null && mounted) {
          await context.read<UserwrongquestionControllerCubit>().recordWrong(
            practiceId.toString(),
          );
          if (mounted) {
            await Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const Resultpage()),
            );
          }
        }
      }
    } else {
      _isFinishing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.practiceSet.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                _formattedTime,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _remainingSeconds <= 60
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
      body:
          BlocBuilder<PracticeSetsControllerCubit, PracticeSetsControllerState>(
            builder: (context, practiceState) {
              if (practiceState.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (practiceState.errorMessage != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          practiceState.errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _loadQuestionsAndOptions,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (practiceState.questions.isEmpty) {
                return const Center(child: Text('Bộ đề chưa có câu hỏi.'));
              }

              return BlocBuilder<
                QuestionsControllerCubit,
                QuestionsControllerState
              >(
                builder: (context, questionsState) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: practiceState.questions.length,
                    itemBuilder: (context, index) {
                      final question = practiceState.questions[index];
                      final options =
                          questionsState.options
                              .where(
                                (option) =>
                                    option.questionId == question.questionId,
                              )
                              .toList()
                            ..sort(
                              (a, b) => a.orderIndex.compareTo(b.orderIndex),
                            );

                      return _QuestionCard(
                        question: question,
                        options: options,
                        isLoadingOptions: questionsState.loadingQuestionIds
                            .contains(question.questionId),
                        optionsError:
                            questionsState.questionErrors[question.questionId],
                        selectedOptionId: practiceState
                            .selectedOptionIds[question.questionId],
                        onRetryOptions: () => context
                            .read<QuestionsControllerCubit>()
                            .getOptions(question.questionId.toString()),
                        onOptionSelected: (option) {
                          context
                              .read<PracticeSetsControllerCubit>()
                              .selectOption(
                                questionId: question.questionId,
                                optionId: option.optionId,
                              );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
      bottomNavigationBar:
          BlocBuilder<PracticeSetsControllerCubit, PracticeSetsControllerState>(
            builder: (context, practiceState) {
              return BlocBuilder<
                PracticeSessionControllerCubit,
                PracticeSessionControllerState
              >(
                builder: (context, sessionState) {
                  return BlocBuilder<
                    PracticeItemControllerCubit,
                    PracticeItemControllerState
                  >(
                    builder: (context, itemState) {
                      final isWorking =
                          sessionState.isSubmitting ||
                          sessionState.isCalculatingResult ||
                          itemState.isGrading;
                      final canSubmit =
                          practiceState.questions.isNotEmpty &&
                          practiceState.selectedOptionIds.isNotEmpty &&
                          sessionState.practiceSession != null &&
                          sessionState.submissionStatus != 'finished' &&
                          !isWorking;

                      return SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (sessionState.errorMessage != null ||
                                  itemState.errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    sessionState.errorMessage ??
                                        itemState.errorMessage!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                ),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: canSubmit
                                      ? () => _submitAndGrade(practiceState)
                                      : null,
                                  child: isWorking
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          sessionState.submissionStatus ==
                                                  'finished'
                                              ? 'Đã nộp bài'
                                              : 'Nộp bài',
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.options,
    required this.isLoadingOptions,
    required this.optionsError,
    required this.selectedOptionId,
    required this.onRetryOptions,
    required this.onOptionSelected,
  });

  final Question question;
  final List<QuestionOption> options;
  final bool isLoadingOptions;
  final String? optionsError;
  final int? selectedOptionId;
  final VoidCallback onRetryOptions;
  final ValueChanged<QuestionOption> onOptionSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${question.orderIndex}. ${question.content}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (isLoadingOptions)
              const Center(child: CircularProgressIndicator())
            else if (optionsError != null)
              Row(
                children: [
                  Expanded(child: Text(optionsError!)),
                  IconButton(
                    onPressed: onRetryOptions,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Tải lại đáp án',
                  ),
                ],
              )
            else if (options.isEmpty)
              const Text('Câu hỏi này chưa có lựa chọn.')
            else
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.2,
                children: options.map((option) {
                  final isSelected = option.optionId == selectedOptionId;
                  final colorScheme = Theme.of(context).colorScheme;

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onOptionSelected(option),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primaryContainer
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : Theme.of(context).dividerColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        option.content,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : null,
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : null,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
