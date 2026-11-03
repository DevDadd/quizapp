import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:quizapp/module3/bot_game_controller.dart';
import 'package:quizapp/module3/match_dao.dart';
import 'package:quizapp/module3/models.dart';
import 'package:quizapp/module3/question_dao.dart';

class StubQuestionDAO extends QuestionDAO {
  const StubQuestionDAO();

  @override
  Future<List<Question>> pickQuestions(int count) async => List.generate(count, (i) => Question(
    questionId: i + 1,
    content: 'Câu ${i + 1}',
    category: 'Test',
    difficulty: 'easy',
    options: [
      QuestionOption(optionId: i * 2 + 1, questionId: i + 1,
        content: 'Sai', isCorrect: false, orderIndex: 0),
      QuestionOption(optionId: i * 2 + 2, questionId: i + 1,
        content: 'Đúng', isCorrect: true, orderIndex: 1),
    ],
  ));
}

class StubMatchDAO extends MatchDAO {
  const StubMatchDAO();

  @override
  Future<int> createMatch(Match match) async => 101;

  @override
  Future<bool> saveResult(Match match) async => match.status == 'finished';

  @override
  Future<bool> abandonMatch(Match match) async => match.status == 'ongoing';
}

class RetrySaveMatchDAO extends MatchDAO {
  int callCount = 0;
  @override
  Future<int> createMatch(Match match) async => 202;
  @override
  Future<bool> saveResult(Match match) async {
    callCount++;
    return callCount > 1;
  }
}

void main() {
  test('SQLite write failure is retryable without grading twice', () async {
    final dao = RetrySaveMatchDAO();
    final controller = BotGameController(
      questionDAO: const StubQuestionDAO(), matchDAO: dao,
      random: Random(2),
    );
    final match = await controller.startMatch('easy');
    for (var i = 0; i < 10; i++) {
      controller.selectAnswer(i, i * 2 + 2);
    }
    await expectLater(controller.finishMatch('submit'), throwsStateError);
    final counted = match.player.correctCount;
    final duration = match.player.durationSeconds;
    final result = await controller.finishMatch('submit');
    expect(result['saved'], true);
    expect(match.player.correctCount, counted);
    expect(match.player.durationSeconds, duration);
    expect(dao.callCount, 2);
  });
  test('Back xác nhận thoát: trận abandoned, không chấm và không cộng điểm', () async {
    final controller = BotGameController(
      questionDAO: const StubQuestionDAO(),
      matchDAO: const StubMatchDAO(),
      random: Random(3),
    );
    final match = await controller.startMatch('medium');
    controller.selectAnswer(0, 2);
    final saved = await controller.abandonMatch();
    expect(saved, true);
    expect(match.status, 'abandoned');
    expect(match.endedAt, isNotNull);
    expect(match.player.pointsEarned, 0.0);
    expect(match.bot.pointsEarned, 0.0);
    expect(match.player.result, 'abandoned');
    expect(match.bot.result, 'abandoned');
    expect(() => controller.selectAnswer(1, 4), throwsStateError);
    expect(() => controller.finishMatch('submit'), throwsStateError);

    // Returning to the setup screen should allow a new match.
    final nextMatch = await controller.startMatch('hard');
    expect(nextMatch.status, 'ongoing');
  });

  test('M03 chọn 10 câu, tạo trận, trả lời, lưu và trả kết quả 1 lần', () async {
    final controller = BotGameController(
      questionDAO: const StubQuestionDAO(),
      matchDAO: const StubMatchDAO(),
      random: Random(2),
    );
    final match = await controller.startMatch('easy');
    expect(match.localMatchId, 101);
    expect(match.questions.length, 10);
    expect(match.botAnswers.length, 10);
    for (var i = 0; i < 10; i++) {
      controller.selectAnswer(i, i * 2 + 2); // correct option
    }
    final first = await controller.finishMatch('submit');
    final second = await controller.finishMatch('timeout');
    expect((first['match'] as Match).status, 'finished');
    expect((first['match'] as Match).player.correctCount, 10);
    expect((first['match'] as Match).player.result, 'win');
    expect(first['saved'], true);
    expect(identical(first, second), true); // idempotent
  });
}
