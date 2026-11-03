import 'package:flutter/material.dart';

import 'models.dart';

class BotResultPage extends StatelessWidget {
  final Match match;
  final bool saved;
  final VoidCallback? onReturnHome;

  const BotResultPage({super.key, required this.match, required this.saved, this.onReturnHome});

  /// A named constructor matches the showResult(match, saved) message in M03.
  const BotResultPage.showResult({super.key, required this.match, required this.saved, this.onReturnHome});

  void backToSetup(BuildContext context) => Navigator.of(context).pop();

  static String _points(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  @override
  Widget build(BuildContext context) {
    final outcome = switch (match.player.result) {
      'win' => 'Người chơi thắng', 'lose' => 'Người chơi thua', _ => 'Hòa',
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả ván đấu'), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(outcome, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text('Bạn: ${match.player.correctCount}/${match.questionCount}  •  '
              '${match.player.durationSeconds} giây  •  +${_points(match.player.pointsEarned)} điểm'),
          Text('BOT: ${match.bot.correctCount}/${match.questionCount}  •  '
              '${match.bot.durationSeconds} giây  •  +${_points(match.bot.pointsEarned)} điểm'),
          const SizedBox(height: 24),
          Text(saved ? 'Đã lưu kết quả trên thiết bị.' : 'Chưa lưu được kết quả trên thiết bị.'),
          const Text('Không cộng điểm vào BXH trực tuyến.'),
          const SizedBox(height: 24),
          FilledButton(onPressed: () => backToSetup(context),
            child: const Text('Về chọn độ khó')),
          const SizedBox(height: 12),
          // GD03 also shows a direct return to the application's home screen.
          OutlinedButton(
            onPressed: onReturnHome ?? () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text('Trang chủ'),
          ),
        ]),
      ),
    );
  }
}
