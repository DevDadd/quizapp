import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizapp/authentication/view/pages/HomePage.dart';

void main() {
  testWidgets('Trang chu gom loi vao M02 M03', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Homepage()));
    expect(find.text('M02 - Bảng xếp hạng'), findsOneWidget);
    expect(find.text('M03 - Thi đấu với máy'), findsOneWidget);
    expect(find.text('Luyện tập'), findsOneWidget);
  });
}
