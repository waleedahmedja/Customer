import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: const Color(0xFF4CAF50), // Green
      secondaryHeaderColor: const Color(0xFFFFC107), // Amber
      scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Light Gray
      cardColor: const Color(0xFFFFFFFF), // White
      errorColor: const Color(0xFFF44336), // Red
      textTheme: const TextTheme(
        bodyText1: TextStyle(color: Colors.black87, fontSize: 16),
        bodyText2: TextStyle(color: Colors.black54, fontSize: 14),
        headline6: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          primary: const Color(0xFF4CAF50), // Button color
          onPrimary: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
    );
  }
}
