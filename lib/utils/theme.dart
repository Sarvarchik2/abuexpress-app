import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Цвета для темной темы
  static const Color darkBackground = Color(0xFF0A0E27);
  static const Color darkCard = Color(0xFF1A1F3A);
  static const Color darkSecondary = Color(0xFF2A2F4A);
  static const Color darkText = Colors.white;
  static const Color darkTextSecondary = Colors.white70;
  static const Color gold = Color(0xFFFFD700);
  static const Color darkGold = Color(0xFFB8860B);

  // Цвета для светлой темы
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF5F5F5);
  static const Color lightSecondary = Color(0xFFE0E0E0);
  static const Color lightText = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightBorder = Color(0xFFE0E0E0);

  static ThemeData getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: gold,
      scaffoldBackgroundColor: darkBackground,
      textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme),
      fontFamily: GoogleFonts.manrope().fontFamily,
      cardColor: darkCard,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
      ),
    );
  }

  static ThemeData getLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: gold,
      scaffoldBackgroundColor: lightBackground,
      textTheme: GoogleFonts.manropeTextTheme(ThemeData.light().textTheme),
      fontFamily: GoogleFonts.manrope().fontFamily,
      cardColor: lightCard,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF212121)),
        titleTextStyle: TextStyle(
          color: Color(0xFF212121),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
      ),
    );
  }
}
