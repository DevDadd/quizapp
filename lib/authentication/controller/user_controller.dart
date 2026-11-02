import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizapp/authentication/model/users.dart';
import 'package:quizapp/authentication/view/cubit/user_controller_state.dart';
import 'package:quizapp/di.dart';

class UserControllerCubit extends Cubit<UserControllerState> {
  UserControllerCubit() : super(const UserControllerState());

  final Dio _dio = getIt<Dio>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    final response = await _dio.post<Map<String, dynamic>>(
      'https://quiz-mobile-backend.onrender.com/auth/login/',
      data: {
        'username': usernameController.text,
        'password': passwordController.text,
      },
    );

    final responseData = response.data;
    if (responseData == null) {
      throw const FormatException('Login response is empty.');
    }

    final responsePayload = responseData['data'];
    final userValue = responsePayload is Map
        ? responsePayload['user']
        : responseData['user'];
    if (userValue is! Map) {
      throw const FormatException(
        'Login response does not contain a valid user.',
      );
    }
    final userData = Map<String, dynamic>.from(userValue);

    final user = User(
      userId: (userData['user_id'] as num).toInt(),
      username: userData['username'] as String,
      displayName: userData['display_name'] as String?,
      totalScore: (userData['total_score'] as num).toDouble(),
    );

    emit(UserControllerState(user: user));
  }
}
