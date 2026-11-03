import 'package:flutter_test/flutter_test.dart';
import 'package:quizapp/module3/models.dart';

String r(int p, int b, int ps, int bs) => resolveMatchOutcome(
    questionCount: 10, playerCorrect: p, botCorrect: b, playerSeconds: ps, botSeconds: bs);

void main() {
  group('M03 - luật thắng/hòa/thua', () {
    test('đúng nhiều câu hơn thì thắng', () {
      expect(r(8, 6, 40, 20), 'win');
      expect(r(1, 0, 60, 10), 'win');
      expect(r(10, 9, 25, 31), 'win');
    });
    test('đúng ít câu hơn thì thua', () {
      expect(r(0, 9, 9, 34), 'lose');
    });
    test('bằng số câu đúng thì nhanh hơn thắng', () {
      expect(r(7, 7, 30, 40), 'win');
      expect(r(7, 7, 45, 40), 'lose');
    });
    test('bằng cả số câu và thời gian thì hòa', () {
      expect(r(5, 5, 30, 30), 'draw');
    });
  });
}
