import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizapp/authentication/controller/user_controller.dart';
import 'package:quizapp/authentication/view/pages/HomePage.dart';

class Loginpage extends StatelessWidget {
  const Loginpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Đăng nhập",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: context
                    .read<UserControllerCubit>()
                    .usernameController,
                decoration: InputDecoration(
                  labelText: "Tên đăng nhập",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: context
                    .read<UserControllerCubit>()
                    .passwordController,
                decoration: InputDecoration(
                  labelText: "Mật khẩu",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  try {
                    await context.read<UserControllerCubit>().login();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Homepage()),
                    );
                  } on DioException catch (error) {
                    if (!context.mounted) return;
                    final statusCode = error.response?.statusCode;
                    final responseBody = error.response?.data;
                    final message = responseBody is Map
                        ? responseBody['message']?.toString()
                        : responseBody?.toString();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          message ??
                              'Đăng nhập thất bại${statusCode == null ? '' : ' (HTTP $statusCode)'}.',
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Center(child: Text("Đăng nhập")),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Chưa có tài khoản? Đăng ký",
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
