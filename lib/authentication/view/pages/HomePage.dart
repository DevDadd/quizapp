import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizapp/app_config.dart';
import 'package:quizapp/authentication/controller/user_controller.dart';
import 'package:quizapp/module2/leaderboard_api.dart';
import 'package:quizapp/module2/leaderboard_page.dart';
import 'package:quizapp/module3/bot_game_controller.dart';
import 'package:quizapp/module3/bot_setup_page.dart';
import 'package:quizapp/practice/view/PracticePage.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  Future<void> _openRanking(BuildContext context) async {
    final api = LeaderboardApi(baseUrl: AppConfig.apiBaseUrl);
    try {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => LeaderboardPage(api: api),
      ));
    } finally {
      api.close();
    }
  }

  Future<void> _openBot(BuildContext context) async {
    final homeRoute = ModalRoute.of(context);
    final userId = context.read<UserControllerCubit>().state.user?.userId;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BotSetupPage(
        controller: BotGameController(),
        playerUserId: userId,
        onReturnHome: homeRoute == null ? null : () {
          if (!context.mounted) return;
          Navigator.of(context).popUntil((route) => route == homeRoute);
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Practicepage(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: const Center(
                    child: Text("Luyện tập", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: const Center(
                  child: Text(
                    "Danh sách người chơi",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _openRanking(context),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: const Center(
                    child: Text("M02 - Bảng xếp hạng", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _openBot(context),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: const Center(
                    child: Text("M03 - Thi đấu với máy", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
