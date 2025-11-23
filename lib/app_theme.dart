import 'package:flutter/material.dart';

class AppTheme {
  // Theme B (soft / light purple)
  static const Color primary = Color(0xFFB39DDB); // light purple
  static const Color primaryDark = Color(0xFF7B4BB1);
  static const Color bg = Color(0xFFF6F3FB);

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: bg,
    brightness: Brightness.light,
    primaryColor: primary,
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontFamily: 'TwCen', fontSize: 28, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontFamily: 'TwCen', fontSize: 20),
      bodyLarge: TextStyle(fontFamily: 'TwCen', fontSize: 16),
      bodyMedium: TextStyle(fontFamily: 'TwCen', fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
