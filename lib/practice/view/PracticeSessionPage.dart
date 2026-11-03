import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizapp/practice/controller/cubit/practice_sets_controller.dart';
import 'package:quizapp/practice/controller/cubit/practice_sets_controller_state.dart';
import 'package:quizapp/practice/model/practice_sets.dart';

class Practicesessionpage extends StatefulWidget {
  const Practicesessionpage({super.key, required this.practiceSet});
  final PracticeSet practiceSet;

  @override
  State<Practicesessionpage> createState() => _PracticesessionpageState();
}

class _PracticesessionpageState extends State<Practicesessionpage> {
  @override
  void initState() {
    super.initState();
    _loadQuestionsAndOptions();
  }

  Future<void> _loadQuestionsAndOptions() async {
    final cubit = context.read<PracticeSetsControllerCubit>();
    await cubit.getQuestions(widget.practiceSet.setId.toString());

    final questions = cubit.state.questions;
    await Future.wait(
      questions.map(
        (question) => cubit.getOptions(question.questionId.toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.practiceSet.title)),
      body:
          BlocBuilder<PracticeSetsControllerCubit, PracticeSetsControllerState>(
            builder: (context, state) {
              if (state.questions.isEmpty) {
                return const Center(child: Text('Chưa có câu hỏi'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.questions.length,
                itemBuilder: (context, index) {
                  final question = state.questions[index];
                  final options =
                      state.options
                          .where(
                            (option) =>
                                option.questionId == question.questionId,
                          )
                          .toList()
                        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${question.orderIndex}. ${question.content}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 2.5,
                            children: options
                                .map(
                                  (option) => Card(
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Text(
                                          option.content,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}
