import 'package:chess_puzzle_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppTheme is buildable', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: Text('hello')),
    ));
    expect(find.text('hello'), findsOneWidget);
  });
}
