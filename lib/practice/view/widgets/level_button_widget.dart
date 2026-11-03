import 'package:flutter/material.dart';

class LevelButtonWidget extends StatelessWidget {
  const LevelButtonWidget({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      width: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(child: Text(title, style: TextStyle(fontSize: 12),)),
    );
  }
}