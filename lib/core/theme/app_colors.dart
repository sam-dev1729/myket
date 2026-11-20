import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Theme extension exposing every palette token that is not directly
/// available on [ColorScheme].
///
/// Registered by [AppTheme.themeFor], so `Theme.of(context).extension` and
/// the `context.*Color` helpers automatically follow the selected theme.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
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

  /// Builds an [AppColors] from a palette.
  factory AppColors.fromPalette(AppPalette palette) {
    return AppColors(
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      secondary: palette.secondary,
      onSecondary: palette.onSecondary,
      accent: palette.accent,
      onAccent: palette.onAccent,
      background: palette.background,
      surface: palette.surface,
      surfaceVariant: palette.surfaceVariant,
      textPrimary: palette.textPrimary,
      textSecondary: palette.textSecondary,
      textTertiary: palette.textTertiary,
      divider: palette.divider,
    );
  }

  /// Main brand color.
  final Color primary;

  /// Content color on top of [primary].
  final Color onPrimary;

  /// Supporting brand color.
  final Color secondary;

  /// Content color on top of [secondary].
  final Color onSecondary;

  /// Accent color.
  final Color accent;

  /// Content color on top of [accent].
  final Color onAccent;

  /// Screen background.
  final Color background;

  /// Card / sheet surface.
  final Color surface;

  /// Neutral tinted surface.
  final Color surfaceVariant;

  /// Primary text color.
  final Color textPrimary;

  /// Secondary text color.
  final Color textSecondary;

  /// Tertiary text color.
  final Color textTertiary;

  /// Border / divider color.
  final Color divider;

  @override
  AppColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? accent,
    Color? onAccent,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? divider,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      divider: divider ?? this.divider,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}
