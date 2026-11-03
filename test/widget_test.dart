import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizapp/authentication/view/pages/HomePage.dart';

void main() {
  testWidgets('Trang chu gom day du cac nut', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Homepage()));
    expect(find.text('Luyện tập'), findsOneWidget);
    expect(find.text('Danh sách người chơi'), findsOneWidget);
    expect(find.text('M02 - Bảng xếp hạng'), findsOneWidget);
    expect(find.text('M03 - Thi đấu với máy'), findsOneWidget);
  });
}
