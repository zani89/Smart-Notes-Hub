import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeonTheme {
  // Colors - Cyberpunk/Neon Palette
  static const Color neonBlue = Color(0xFF00BFA5);
  static const Color neonPurple = Color(0xFFBC13FE);
  static const Color neonPink = Color(0xFFFF00E0);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color darkBg = Color(0xFF0B0E11);
  static const Color surfaceBg = Color(0xFF1C222D);
  static const Color borderCol = Color(0xFF30363D);

  static ThemeData get darkNeonTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: ColorScheme.dark(
        primary: neonBlue,
        secondary: neonPurple,
        surface: surfaceBg,
        onSurface: Colors.white,
        outline: borderCol,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonBlue,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 8,
          shadowColor: neonBlue.withValues(alpha: 0.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderCol, width: 1),
        ),
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderCol)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderCol)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: neonBlue, width: 2)),
      ),
    );
  }

  static ThemeData get softLightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF6366F1),
        secondary: const Color(0xFF8B5CF6),
        surface: Colors.white,
        onSurface: const Color(0xFF1F2937),
        outline: const Color(0xFFE5E7EB),
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
    );
  }
}

class GlassBox extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? color;

  const GlassBox({
    super.key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.1,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: (color ?? Colors.white).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ColorFilter.mode((color ?? Colors.white).withValues(alpha: opacity), BlendMode.srcOver),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
