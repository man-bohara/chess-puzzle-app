import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Palette tuned to match `BoardTheme.brown` from the squares package.
  static const Color boardLight = Color(0xFFF0D9B5);
  static const Color boardDark = Color(0xFFB58863);
  static const Color woodDeep = Color(0xFF5C3A1E);
  static const Color woodAccent = Color(0xFF8B5A3C);
  static const Color cream = Color(0xFFFFF8EC);
  static const Color hintAmber = Color(0xFFB8860B);

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: woodAccent,
      primary: woodDeep,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: cream,
    appBarTheme: const AppBarTheme(
      backgroundColor: woodDeep,
      foregroundColor: cream,
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: woodAccent,
      brightness: Brightness.dark,
    ),
  );
}
