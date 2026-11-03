import 'dart:async';

import 'package:flutter/material.dart';

import 'bot_game_controller.dart';
import 'bot_result_page.dart';
import 'models.dart';

class BotQuizPage extends StatefulWidget {
  final BotGameController controller;
  final Match match;
  final VoidCallback? onReturnHome;
  const BotQuizPage({super.key, required this.controller, required this.match, this.onReturnHome});

  const BotQuizPage.showQuestions({super.key, required this.controller, required this.match, this.onReturnHome});

  @override
  State<BotQuizPage> createState() => _BotQuizPageState();
}

class _BotQuizPageState extends State<BotQuizPage> {
  Timer? _timer;
  int current = 0;
  int remaining = 60;
  bool finishing = false;
  bool _confirmingExit = false;
  bool _allowPop = false;
  bool _saveFailed = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    remaining = widget.controller.timeLeft(DateTime.now());
    if (remaining == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !finishing && !_confirmingExit) onTimeout();
      });
      return;
    }
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted || finishing || _confirmingExit) return;
      final next = widget.controller.timeLeft(DateTime.now());
      if (next != remaining) setState(() => remaining = next);
      if (next == 0) onTimeout();
    });
  }

  /// Android system Back and the AppBar back arrow both use this flow.
  /// Do not pop an ongoing match without recording its abandoned status.
  Future<void> _confirmExit() async {
    if (_confirmingExit || finishing || _allowPop) return;
    _confirmingExit = true;
    _timer?.cancel(); // Real elapsed time keeps running while the dialog is shown.

    final exitConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thoát trận đấu?'),
        content: const Text(
          'Trận chưa kết thúc. Nếu thoát, trận sẽ được ghi nhận là đã hủy '
          'và không được tính điểm. Thời gian vẫn đang chạy.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Ở lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Thoát trận'),
          ),
        ],
      ),
    );
    _confirmingExit = false;
    if (!mounted || finishing) return;

    // If the deadline passed while confirming, the existing timeout route wins.
    if (widget.controller.timeLeft(DateTime.now()) == 0) {
      await onTimeout();
      return;
    }
    if (exitConfirmed != true) {
      _startTimer();
      return;
    }

    setState(() => finishing = true);
    try {
      final saved = await widget.controller.abandonMatch();
      if (!mounted) return;
      if (!saved) throw StateError('Không lưu được trạng thái thoát trận.');
      setState(() => _allowPop = true);
      // PopScope updates its route disposition during the following build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => finishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chưa thể thoát trận: $e')),
      );
      _startTimer();
    }
  }

  void choose(int order, int optionId) {
    if (finishing || remaining == 0) return;
    try {
      widget.controller.selectAnswer(order, optionId);
      setState(() {});
    } on StateError {
      onTimeout();
    }
  }

  void showQuestions(Match match) {
    if (mounted) setState(() { current = 0; match.currentQuestionIndex = 0; });
  }

  Future<void> submit() => _finish('submit');
  Future<void> onTimeout() => _finish('timeout');

  Future<void> _finish(String reason) async {
    if (finishing) return;
    setState(() { finishing = true; _saveFailed = false; });
    _timer?.cancel();
    try {
      final result = await widget.controller.finishMatch(reason);
      if (!mounted) return;
      await showResult(result['match'] as Match, result['saved'] as bool);
    } catch (e) {
      if (!mounted) return;
      setState(() { finishing = false; _saveFailed = true; });
      if (widget.match.status == 'ongoing') _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi lưu/chấm: $e')));
    }
  }

  Future<void> showResult(Match match, bool saved) async {
    await Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => BotResultPage.showResult(
        match: match, saved: saved, onReturnHome: widget.onReturnHome),
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.match.questions[current];
    final selected = widget.match.playerAnswers[q.orderIndex]?.selectedOptionId;
    return PopScope(
      canPop: _allowPop,
      onPopInvoked: (didPop) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Thi đấu với máy')),
        body: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Câu ${current + 1}/${widget.match.questionCount}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${(remaining ~/ 60).toString().padLeft(2, '0')}:${(remaining % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 25),
              Text(q.question.content, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 18),
              for (final option in q.question.options)
                RadioListTile<int>(
                  title: Text('${String.fromCharCode(65 + option.orderIndex)}. ${option.content}'),
                  value: option.optionId,
                  groupValue: selected,
                  onChanged: finishing || remaining == 0 ? null : (v) => choose(q.orderIndex, v!),
                ),
              const Spacer(),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: current == 0 || finishing ? null : () => setState(() { current--; widget.match.currentQuestionIndex = current; }),
                  child: const Text('Câu trước'),
                )),
                const SizedBox(width: 10),
                Expanded(child: OutlinedButton(
                  onPressed: current >= widget.match.questions.length - 1 || finishing
                      ? null : () => setState(() { current++; widget.match.currentQuestionIndex = current; }),
                  child: const Text('Câu tiếp'),
                )),
              ]),
              const SizedBox(height: 10),
              FilledButton(onPressed: finishing ? null : submit,
                  child: Text(finishing ? 'Đang chấm...' : (_saveFailed ? 'Thử lưu kết quả' : 'Nộp bài'))),
            ],
          ),
        ),
      ),
    );
  }
}
