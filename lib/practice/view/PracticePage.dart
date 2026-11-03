import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizapp/practice/controller/cubit/practice_sets_controller.dart';
import 'package:quizapp/practice/controller/cubit/practice_sets_controller_state.dart';
import 'package:quizapp/practice/model/practice_sets.dart';
import 'package:quizapp/practice/view/PracticeSessionPage.dart';
import 'package:quizapp/practice/view/widgets/level_button_widget.dart';

class Practicepage extends StatefulWidget {
  const Practicepage({super.key});

  @override
  State<Practicepage> createState() => _PracticepageState();
}

class _PracticepageState extends State<Practicepage> {
  String difficult = "all";

  @override
  void initState() {
    super.initState();
    context.read<PracticeSetsControllerCubit>().getPracticeSets("all");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("Độ khó", style: TextStyle(fontSize: 18)),
              SizedBox(height: 16),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      difficult = "all";
                      context
                          .read<PracticeSetsControllerCubit>()
                          .getPracticeSets(difficult);
                    },
                    child: LevelButtonWidget(title: "Tất cả"),
                  ),
                  SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      difficult = "dễ";
                      context
                          .read<PracticeSetsControllerCubit>()
                          .getPracticeSets(difficult);
                    },
                    child: LevelButtonWidget(title: "Dễ"),
                  ),
                  SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      difficult = "khó";
                      context
                          .read<PracticeSetsControllerCubit>()
                          .getPracticeSets(difficult);
                    },
                    child: LevelButtonWidget(title: "Khó"),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child:
                    BlocBuilder<
                      PracticeSetsControllerCubit,
                      PracticeSetsControllerState
                    >(
                      builder: (context, state) {
                        return _PracticeSetsTable(
                          sets: state.practiceSets,
                          onTap: (practiceSet) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Practicesessionpage(
                                  practiceSet: practiceSet,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PracticeSetsTable extends StatelessWidget {
  const _PracticeSetsTable({
    required this.sets,
    required this.onTap,
  });

  final List<PracticeSet> sets;
  final Function(PracticeSet) onTap;

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: Colors.black, fontSize: 17);
    const headerStyle = TextStyle(
      color: Colors.black,
      fontSize: 17,
      fontWeight: FontWeight.bold,
    );

    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width - 16,
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.25),
              1: FlexColumnWidth(0.85),
              2: FlexColumnWidth(1.15),
            },
            border: const TableBorder(
              horizontalInside: BorderSide(color: Color(0xFF3A3A3A)),
            ),
            children: [
              const TableRow(
                children: [
                  _TableCell('Tên đề', style: headerStyle),
                  _TableCell('Độ khó', style: headerStyle),
                  _TableCell('Mô tả', style: headerStyle),
                ],
              ),
              ...sets.map(
                (set) => TableRow(
                  children: [
                    _buildCell(set.title, textStyle, set),
                    _buildCell(
                      _difficultyLabel(set.difficulty),
                      textStyle,
                      set,
                    ),
                    _buildCell(set.category ?? '', textStyle, set),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCell(
    String text,
    TextStyle style,
    PracticeSet set,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(set),
      child: _TableCell(text, style: style),
    );
  }

  String _difficultyLabel(int difficulty) => switch (difficulty) {
    1 => 'Dễ',
    2 => 'Trung bình',
    3 => 'Khó',
    _ => 'Không xác định',
  };
}

class _TableCell extends StatelessWidget {
  const _TableCell(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(text, style: style),
    );
  }
}
