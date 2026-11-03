import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizapp/authentication/controller/user_controller.dart';
import 'package:quizapp/authentication/view/pages/LoginPage.dart';
import 'package:quizapp/di.dart';
import 'package:quizapp/practice/controller/cubit/practice_session_controller.dart';
import 'package:quizapp/practice/controller/cubit/practice_item_controller.dart';
import 'package:quizapp/practice/controller/cubit/practice_sets_controller.dart';
import 'package:quizapp/practice/controller/cubit/questions_controller.dart';
import 'package:quizapp/practice/controller/cubit/userwrongquestion_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => UserControllerCubit()),
        BlocProvider(create: (context) => PracticeSetsControllerCubit()),
        BlocProvider(create: (context) => QuestionsControllerCubit()),
        BlocProvider(create: (context) => PracticeSessionControllerCubit()),
        BlocProvider(create: (context) => PracticeItemControllerCubit()),
        BlocProvider(create: (context) => UserwrongquestionControllerCubit()),
      ],
      child: MaterialApp(home: const Loginpage()),
    );
  }
}
