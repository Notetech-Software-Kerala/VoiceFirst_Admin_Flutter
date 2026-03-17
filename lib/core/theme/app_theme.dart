import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0xFF0D7FF2);
  static const bgLight = Color(0xFFF5F7F8);
  static const bgDark = Color(0xFF101922);
  static const cardLight = Color(0xFFFFFFFF);
  static const cardDark = Color(0xFF182634);

  static final ThemeData lightTheme = _buildTheme(
    brightness: Brightness.light,
    bg: bgLight,
    card: cardLight,
    primary: primaryColor,
    textSecondary: const Color(0xFF64748B),
    borderColor: Colors.grey[200]!,
  );

  static final ThemeData darkTheme = _buildTheme(
    brightness: Brightness.dark,
    bg: bgDark,
    card: cardDark,
    primary: primaryColor,
    textSecondary: const Color(0xFF90ADCB),
    borderColor: Colors.grey[800]!,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color bg,
    required Color card,
    required Color primary,
    required Color textSecondary,
    required Color borderColor,
  }) {
    final baseTheme = brightness == Brightness.light
        ? ThemeData.light()
        : ThemeData.dark();

    return baseTheme.copyWith(
      scaffoldBackgroundColor: bg,
      primaryColor: primary,
      cardColor: card,
      dividerColor: borderColor,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: primary,
        surface: card,
        outline: borderColor,
        onSurfaceVariant: textSecondary,
      ),
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme).apply(
        bodyColor: brightness == Brightness.light
            ? const Color(0xFF0F172A)
            : Colors.white,
        displayColor: brightness == Brightness.light
            ? const Color(0xFF0F172A)
            : Colors.white,
      ),
    );
  }
}
