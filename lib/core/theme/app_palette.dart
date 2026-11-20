import 'package:flutter/material.dart';

/// Identifiers for every theme the user can pick from.
///
/// Four light palettes plus a single dark palette. The [storageValue] is
/// persisted in `SharedPreferences` and must stay stable.
enum AppThemeId {
  /// The app's original brand palette: neon green + purple.
  classic('classic'),

  /// The default palette: Vital Green & Visionary Purple.
  vital('vital'),

  /// Healing Blue & Dynamic Orange.
  healing('healing'),

  /// Supportive Teal & Creative Coral.
  teal('teal'),

  /// The dark palette.
  dark('dark');

  const AppThemeId(this.storageValue);

  /// Value persisted in preferences for this theme.
  final String storageValue;

  /// Whether this theme is a dark theme.
  bool get isDark => this == AppThemeId.dark;

  /// Resolves a persisted value, falling back to [AppThemeId.vital].
  static AppThemeId fromStorage(String? value) {
    for (final id in AppThemeId.values) {
      if (id.storageValue == value) return id;
    }
    return AppThemeId.vital;
  }
}

/// A complete, immutable color palette for one app theme.
///
/// Widgets should never read these values directly. They are consumed by
/// [AppTheme.themeFor] to build a `ThemeData`, and exposed to the UI through
/// the `AppColors` theme extension / `BuildContext` helpers.
@immutable
class AppPalette {
  const AppPalette({
    required this.id,
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.accent,
    required this.onAccent,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.divider,
  });

  /// Theme identifier for this palette.
  final AppThemeId id;

  /// Whether this palette is dark or light.
  final Brightness brightness;

  /// Main brand color (buttons, accents, navigation bar, highlights).
  final Color primary;

  /// Content color placed on top of [primary].
  final Color onPrimary;

  /// Supporting brand color (secondary actions, logo, checkboxes).
  final Color secondary;

  /// Content color placed on top of [secondary].
  final Color onSecondary;

  /// Accent color (badges, highlights, tertiary emphasis).
  final Color accent;

  /// Content color placed on top of [accent].
  final Color onAccent;

  /// Screen background behind all pages.
  final Color background;

  /// Card, sheet and app-bar surface.
  final Color surface;

  /// Slightly tinted surface used for neutral chips/boxes.
  final Color surfaceVariant;

  /// Primary text and icon color.
  final Color textPrimary;

  /// Secondary text color (descriptions, labels).
  final Color textSecondary;

  /// Tertiary text color (hints, placeholders).
  final Color textTertiary;

  /// Border and divider color.
  final Color divider;

  /// Whether this palette is dark.
  bool get isDark => brightness == Brightness.dark;

  /// The default palette of the app.
  static const AppPalette vital = AppPalette(
    id: AppThemeId.vital,
    brightness: Brightness.light,
    primary: Color(0xFF38A169),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF805AD5),
    onSecondary: Color(0xFFFFFFFF),
    accent: Color(0xFFF6E05E),
    onAccent: Color(0xFF1A202C),
    background: Color(0xFFF0FDF4),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF1A202C),
    textSecondary: Color(0xFF4A5568),
    textTertiary: Color(0xFF718096),
    divider: Color(0xFFE2E8F0),
  );

  /// Healing Blue & Dynamic Orange.
  static const AppPalette healing = AppPalette(
    id: AppThemeId.healing,
    brightness: Brightness.light,
    primary: Color(0xFF2B6CB0),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFFED8936),
    onSecondary: Color(0xFF1A202C),
    accent: Color(0xFF48BB78),
    onAccent: Color(0xFF1A202C),
    background: Color(0xFFF7FAFC),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF2D3748),
    textSecondary: Color(0xFF4A5568),
    textTertiary: Color(0xFF718096),
    divider: Color(0xFFE2E8F0),
  );

  /// Supportive Teal & Creative Coral.
  static const AppPalette teal = AppPalette(
    id: AppThemeId.teal,
    brightness: Brightness.light,
    primary: Color(0xFF319795),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFFFC8181),
    onSecondary: Color(0xFF1A202C),
    accent: Color(0xFF2C7A7B),
    onAccent: Color(0xFFFFFFFF),
    background: Color(0xFFFFFAF0),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF3EADC),
    textPrimary: Color(0xFF4A5568),
    textSecondary: Color(0xFF718096),
    textTertiary: Color(0xFFA0AEC0),
    divider: Color(0xFFEADFD0),
  );

  /// The original brand palette: neon green + purple.
  static const AppPalette classic = AppPalette(
    id: AppThemeId.classic,
    brightness: Brightness.light,
    primary: Color(0xFF00E676),
    onPrimary: Color(0xFF052E1A),
    secondary: Color(0xFF7B1FA2),
    onSecondary: Color(0xFFFFFFFF),
    accent: Color(0xFFFFD54F),
    onAccent: Color(0xFF1A1A1A),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF3F4F6),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF6B7280),
    textTertiary: Color(0xFF9CA3AF),
    divider: Color(0xFFE5E7EB),
  );

  /// Midnight dark palette.
  static const AppPalette dark = AppPalette(
    id: AppThemeId.dark,
    brightness: Brightness.dark,
    primary: Color(0xFF00E676),
    onPrimary: Color(0xFF052E1A),
    secondary: Color(0xFFB794F4),
    onSecondary: Color(0xFF1A202C),
    accent: Color(0xFFF6E05E),
    onAccent: Color(0xFF1A202C),
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    surfaceVariant: Color(0xFF2A2A2A),
    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFFB0B0B0),
    textTertiary: Color(0xFF808080),
    divider: Color(0xFF333333),
  );

  /// Light palettes, in the order they are shown in the picker.
  static const List<AppPalette> lightPalettes = [vital, healing, teal, classic];

  /// Dark palettes, in the order they are shown in the picker.
  static const List<AppPalette> darkPalettes = [dark];

  /// All palettes, light first and dark last.
  static const List<AppPalette> all = [vital, healing, teal, classic, dark];

  /// Returns the palette registered for [id].
  static AppPalette of(AppThemeId id) {
    switch (id) {
      case AppThemeId.vital:
        return vital;
      case AppThemeId.healing:
        return healing;
      case AppThemeId.teal:
        return teal;
      case AppThemeId.classic:
        return classic;
      case AppThemeId.dark:
        return dark;
    }
  }
}
