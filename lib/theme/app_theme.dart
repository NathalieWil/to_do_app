import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF9F6FF),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF7E57C2), // Morado principal
      secondary: Color(0xFF9575CD), // Lila suave
      error: Color.fromARGB(255, 164, 110, 212),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF7E57C2),
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF7E57C2),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Color(0xFF9575CD)),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF9575CD)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF7E57C2),
      foregroundColor: Colors.white,
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.black87,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFB39DDB), // Morado claro para modo oscuro
      secondary: Color(0xFFD1C4E9), // Lila muy suave
      error: Color.fromARGB(255, 165, 94, 215),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2E2E2E),
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFB39DDB),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Color(0xFFD1C4E9)),
    ),
    iconTheme: const IconThemeData(color: Color(0xFFD1C4E9)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF9575CD),
      foregroundColor: Colors.white,
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.white10,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
  );
}
