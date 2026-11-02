import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:quizapp/authentication/controller/user_controller.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerFactory<UserControllerCubit>(() => UserControllerCubit());
}
