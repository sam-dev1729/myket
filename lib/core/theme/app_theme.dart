import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';

/// Defines the application's themes, semantic colors and typography.
///
/// All brand colors live in [AppPalette]; widgets must read them through
/// `Theme.of(context)` (or the `context.*Color` helpers in
/// `theme_extensions.dart`) so that switching the theme repaints the UI.
class AppTheme {
  const AppTheme._();

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

  /// A fully transparent color.
  static const Color transparent = Color(0x00000000);

  // ─────────────────────────────────────────────────────────────
  // Soft Feature-Card Colors
  // ─────────────────────────────────────────────────────────────

  /// Soft red background used for the blood-test feature card.
  static const Color softRedBackground = Color(0xFFFFF0F0);

  /// Soft red border used for the blood-test feature card.
  static const Color softRedBorder = Color(0xFFFFCDD2);

  /// Soft blue background used for the genetic-test feature card.
  static const Color softBlueBackground = Color(0xFFF0F4FF);

  /// The soft teal used by the doctor suggestion banner.
  static const Color softTealBackground = Color(0xFFD4F1E8);

  /// Dark variant of [softRedBackground].
  static const Color softRedBackgroundDark = Color(0xFF3A1F1F);

  /// Dark variant of [softRedBorder].
  static const Color softRedBorderDark = Color(0xFF5C2A2A);

  /// Dark variant of [softBlueBackground].
  static const Color softBlueBackgroundDark = Color(0xFF1A2438);

  /// Dark variant of [softTealBackground].
  static const Color softTealBackgroundDark = Color(0xFF1A2E2A);

  // ─────────────────────────────────────────────────────────────
  // Theme Construction
  // ─────────────────────────────────────────────────────────────

  /// Theme applied when nothing has been persisted yet.
  static const AppThemeId defaultThemeId = AppThemeId.vital;

  /// Builds the complete [ThemeData] for [id].
  static ThemeData themeFor(AppThemeId id) {
    final palette = AppPalette.of(id);
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.primary,
      brightness: palette.brightness,
      surface: palette.surface,
    ).copyWith(
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      secondary: palette.secondary,
      onSecondary: palette.onSecondary,
      tertiary: palette.accent,
      onTertiary: palette.onAccent,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      onSurfaceVariant: palette.textSecondary,
      surfaceContainerHighest: palette.surfaceVariant,
      outline: palette.divider,
      outlineVariant: palette.divider,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: palette.brightness,
      colorScheme: scheme,
      disabledColor: palette.textTertiary,
    );

    return base.copyWith(
      primaryColor: palette.primary,
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      dividerColor: palette.divider,
      iconTheme: IconThemeData(color: palette.textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: palette.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: palette.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: palette.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: palette.textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: palette.textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: palette.textSecondary),
        bodySmall: TextStyle(fontSize: 12, color: palette.textTertiary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.primary,
        contentTextStyle: TextStyle(color: palette.onPrimary),
        actionTextColor: palette.onPrimary,
        behavior: SnackBarBehavior.floating,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          disabledBackgroundColor: palette.divider,
          disabledForegroundColor: palette.textTertiary,
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.textPrimary,
          side: BorderSide(color: palette.divider),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return palette.onPrimary;
          return palette.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return palette.primary;
          return palette.surfaceVariant;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: palette.primary),
      dividerTheme: DividerThemeData(color: palette.divider, thickness: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        modalBackgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
      ),
      extensions: <ThemeExtension<dynamic>>[AppColors.fromPalette(palette)],
    );
  }
}
