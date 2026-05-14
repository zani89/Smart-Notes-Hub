import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors from the E8 Markets aesthetic
  static const Color primaryTeal = Color(0xFF00BFA5);
  static const Color secondaryPurple = Color(0xFF9C27B0);
  static const Color backgroundDark = Color(0xFF0A0E12);
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color cardDark = Color(0xFF1C222D);
  static const Color textMain = Color(0xFFE6EDF3);
  static const Color textDim = Color(0xFF8B949E);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        brightness: Brightness.dark,
        primary: primaryTeal,
        secondary: secondaryPurple,
        surface: surfaceDark,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: textMain,
        displayColor: textMain,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textMain),
        iconTheme: IconThemeData(color: textMain),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF30363D), width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryTeal,
        unselectedItemColor: textDim,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        hintStyle: const TextStyle(color: textDim),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF30363D)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF30363D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryTeal),
        ),
      ),
    );
  }

  static ThemeData get lightTheme => darkTheme; // Fixed syntax error
}
