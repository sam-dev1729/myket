import 'package:flutter/material.dart';

/// Defines the application theme, colors, and typography.
///
/// Centralizes all color and typography definitions so that no raw
/// color or font size leaks into the UI layer.
class AppTheme {
  const AppTheme._();

  // ─────────────────────────────────────────────────────────────
  // Brand Colors
  // ─────────────────────────────────────────────────────────────

  /// The primary vibrant green brand color used across the app.
  static const Color primary = Color(0xFF00E676);

  /// The neon green background used in authentication screens.
  static const Color authBackground = Color(0xFF00FF00);

  /// The dark purple color used for the auth-screen logo.
  static const Color logoPurple = Color(0xFF7B1FA2);

  /// The primary black used for strong text.
  static const Color black = Color(0xFF000000);

  /// Pure white used for card surfaces and icons.
  static const Color white = Color(0xFFFFFFFF);

  /// The general screen background.
  static const Color background = Color(0xFFFFFFFF);

  /// A fully transparent color.
  static const Color transparent = Color(0x00000000);

  /// A common 87% black (Flutter's `Colors.black87`).
  static const Color black87 = Color(0xDD000000);

  /// A common 54% black (Flutter's `Colors.black54`).
  static const Color black54 = Color(0x8A000000);

  /// A subtle 12% black used for borders and dividers.
  static const Color black12 = Color(0x1F000000);

  /// A common 70% white (Flutter's `Colors.white70`).
  static const Color white70 = Color(0xB3FFFFFF);

  /// A common 54% white (Flutter's `Colors.white54`).
  static const Color white54 = Color(0x8AFFFFFF);

  // ─────────────────────────────────────────────────────────────
  // Text Colors
  // ─────────────────────────────────────────────────────────────

  /// Standard primary text color.
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// Secondary text color (medium grey).
  static const Color textSecondary = Color(0xFF6B7280);

  /// Tertiary text color (light grey).
  static const Color textTertiary = Color(0xFF9CA3AF);

  // ─────────────────────────────────────────────────────────────
  // Surface Colors
  // ─────────────────────────────────────────────────────────────

  /// Light grey background used for neutral feature cards.
  static const Color cardBackground = Color(0xFFF5F5F5);

  /// Soft red background used for the blood-test feature card.
  static const Color softRedBackground = Color(0xFFFFF0F0);

  /// Soft red border used for the blood-test feature card.
  static const Color softRedBorder = Color(0xFFFFCDD2);

  /// Soft blue background used for the genetic-test feature card.
  static const Color softBlueBackground = Color(0xFFF0F4FF);

  /// The soft teal used by the doctor suggestion banner.
  static const Color softTealBackground = Color(0xFFD4F1E8);

  // Dark variants of soft brand backgrounds (Sprint 9, PKG-009-001a).
  static const softRedBackgroundDark = Color(0xFF3A1F1F);
  static const softRedBorderDark = Color(0xFF5C2A2A);
  static const softBlueBackgroundDark = Color(0xFF1A2438);
  static const softTealBackgroundDark = Color(0xFF1A2E2A);

  /// Divider color used in lists and cards.
  static const Color divider = Color(0xFFE5E7EB);

  /// Background color used in the notifications list.
  static const Color notificationBackground = Color(0xFFF5F5F5);

  // ─────────────────────────────────────────────────────────────
  // Dark-Mode Colors
  // ─────────────────────────────────────────────────────────────

  /// Background color used in dark mode.
  static const Color darkBackground = Color(0xFF121212);

  /// Surface color used in dark mode (cards, sheets, app bar).
  static const Color darkSurface = Color(0xFF1E1E1E);

  /// Border/divider color used in dark mode.
  static const Color darkDivider = Color(0xFF3A3A3A);

  /// Secondary text color used in dark mode.
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  /// Tertiary text color used in dark mode.
  static const Color darkTextTertiary = Color(0xFF808080);

  // ─────────────────────────────────────────────────────────────
  // Semantic Colors
  // ─────────────────────────────────────────────────────────────

  /// Red used for destructive actions and negative states.
  static const Color error = Color(0xFFE53935);

  /// Green used for success states.
  static const Color success = Color(0xFF43A047);

  /// Amber used for warning states.
  static const Color warning = Color(0xFFF9A825);

  /// Blue used for informational states.
  static const Color info = Color(0xFF1E88E5);

  // ─────────────────────────────────────────────────────────────
  // Health Gauge Colors
  // ─────────────────────────────────────────────────────────────

  /// Green segment used in the health gauge (safe range).
  static const Color gaugeGreen = Color(0xFF00C853);

  /// Yellow segment used in the health gauge (warning range).
  static const Color gaugeYellow = Color(0xFFFFD600);

  /// Red segment used in the health gauge (danger range).
  static const Color gaugeRed = Color(0xFFD50000);

  /// Needle color used in the health gauge.
  static const Color gaugeNeedle = Color(0xFF4A148C);

  // ─────────────────────────────────────────────────────────────
  // Theme Construction
  // ─────────────────────────────────────────────────────────────

  /// Builds the application's light theme.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        surface: background,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: black,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
        bodySmall: TextStyle(fontSize: 12, color: textTertiary),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: primary,
        contentTextStyle: TextStyle(color: black),
        behavior: SnackBarBehavior.floating,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: black,
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: black,
          side: const BorderSide(color: divider),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Builds the application's dark theme.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        surface: darkSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: white),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: white),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: white),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: white),
        bodyLarge: TextStyle(fontSize: 16, color: white),
        bodyMedium: TextStyle(fontSize: 14, color: darkTextSecondary),
        bodySmall: TextStyle(fontSize: 12, color: darkTextTertiary),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: primary,
        contentTextStyle: TextStyle(color: black),
        behavior: SnackBarBehavior.floating,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: black,
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: white,
          side: const BorderSide(color: darkDivider),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
