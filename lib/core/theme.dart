import 'dart:ui';
import 'package:flutter/material.dart';

class AppTheme {
  // ── Color Palette ──
  static const Color gold = Color(0xFFD4AF37);
  static const Color parchment = Color(0xFFFFFdd0);
  static const Color deepRed = Color(0xFF8B0000);

  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: Colors.transparent,
      primaryColor: gold,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: parchment,
          fontSize: 64,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(offset: Offset(0, 4), blurRadius: 8.0, color: Colors.black87),
          ],
        ),
        displayMedium: TextStyle(
          color: parchment,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(offset: Offset(0, 2), blurRadius: 4.0, color: Colors.black87),
          ],
        ),
        titleLarge: TextStyle(
          color: parchment,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: parchment,
          fontSize: 24,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withOpacity(0.5),
        labelStyle: const TextStyle(color: gold, fontSize: 24),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: gold, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: gold, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: parchment, width: 3),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepRed,
          foregroundColor: parchment,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
          textStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          elevation: 8,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.black.withOpacity(0.6),
        labelStyle: const TextStyle(color: gold, fontSize: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: gold, width: 1.5),
        ),
      ),
    );
  }

  /// Glassmorphic card decoration for the question panels.
  static BoxDecoration glassCard({double opacity = 0.30}) {
    return BoxDecoration(
      color: Colors.black.withOpacity(opacity),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: gold.withOpacity(0.35),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 30,
          spreadRadius: 2,
        ),
      ],
    );
  }

  /// Frosted‐glass clip widget (wrap content with this).
  static Widget frostedGlass({
    required Widget child,
    double opacity = 0.30,
    EdgeInsetsGeometry padding = const EdgeInsets.all(32),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: glassCard(opacity: opacity),
          padding: padding,
          child: child,
        ),
      ),
    );
  }

  /// Chip / suggestion card decoration (selected variant).
  static BoxDecoration selectedChipDecoration() {
    return BoxDecoration(
      color: gold.withOpacity(0.20),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: gold, width: 2.5),
      boxShadow: [
        BoxShadow(
          color: gold.withOpacity(0.35),
          blurRadius: 14,
          spreadRadius: 1,
        ),
      ],
    );
  }

  /// Chip / suggestion card decoration (unselected).
  static BoxDecoration unselectedChipDecoration() {
    return BoxDecoration(
      color: Colors.black.withOpacity(0.35),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: gold.withOpacity(0.4), width: 1.5),
    );
  }
}
