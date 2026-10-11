import 'package:flutter/material.dart';

class OrbitTheme {
  // Deep space palette
  static const Color voidBlack = Color(0xFF07090E);
  static const Color deepSpace = Color(0xFF0D111A);
  static const Color orbitCard = Color(0xFF151B28);
  static const Color orbitCardBorder = Color(0xFF263248);
  static const Color cosmicSurface = Color(0xFF1A2234);

  // Starlight & text
  static const Color starWhite = Color(0xFFF1F5F9);
  static const Color starlightMuted = Color(0xFF94A3B8);
  static const Color starlightDark = Color(0xFF64748B);

  // Accent Planetary Colors
  static const Color earthCyan = Color(0xFF00E5FF);
  static const Color marsCrimson = Color(0xFFFF5252);
  static const Color jupiterViolet = Color(0xFFB388FF);
  static const Color saturnGold = Color(0xFFFFD700);
  static const Color neptuneEmerald = Color(0xFF00E676);
  static const Color multiAgentPlasma = Color(0xFFFF4081);

  static ThemeData get darkTheme {
    return ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: voidBlack,
      primaryColor: earthCyan,
      colorScheme: const ColorScheme.dark(
        primary: earthCyan,
        secondary: jupiterViolet,
        surface: deepSpace,
        error: marsCrimson,
        onPrimary: voidBlack,
        onSurface: starWhite,
      ),
      cardTheme: const CardThemeData(
        color: orbitCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: orbitCardBorder, width: 1),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: deepSpace,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: starWhite),
        titleTextStyle: TextStyle(
          color: starWhite,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: orbitCard,
        hintStyle: const TextStyle(color: starlightDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: orbitCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: orbitCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: earthCyan, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: earthCyan,
          foregroundColor: voidBlack,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}
