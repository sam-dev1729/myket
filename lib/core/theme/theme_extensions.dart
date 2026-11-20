import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';
import 'app_theme.dart';

/// Theme-aware color helpers on [BuildContext].
///
/// Prefer these over hardcoded colors so every screen follows the active
/// theme (light palette or dark). The values come from the `AppColors`
/// extension registered by `AppTheme.themeFor`.
///
/// ```dart
/// Container(color: context.surfaceColor)
/// Text('...', style: TextStyle(color: context.textSecondaryColor))
/// ```
extension ThemeX on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;

  /// Full palette extension of the active theme.
  AppColors get appColors =>
      theme.extension<AppColors>() ?? AppColors.fromPalette(AppPalette.vital);

  Color get surfaceColor => appColors.surface;
  Color get surfaceVariantColor => appColors.surfaceVariant;
  Color get scaffoldColor => appColors.background;

  Color get primaryColor => appColors.primary;
  Color get onPrimaryColor => appColors.onPrimary;
  Color get secondaryColor => appColors.secondary;
  Color get accentColor => appColors.accent;

  Color get textPrimaryColor => appColors.textPrimary;
  Color get textSecondaryColor => appColors.textSecondary;
  Color get textTertiaryColor => appColors.textTertiary;

  Color get appDividerColor => appColors.divider;
  Color get iconColor => appColors.textPrimary;

  Color get softRedBg => theme.brightness == Brightness.dark
      ? AppTheme.softRedBackgroundDark
      : AppTheme.softRedBackground;

  Color get softRedBd =>
      theme.brightness == Brightness.dark ? AppTheme.softRedBorderDark : AppTheme.softRedBorder;

  Color get softBlueBg => theme.brightness == Brightness.dark
      ? AppTheme.softBlueBackgroundDark
      : AppTheme.softBlueBackground;

  Color get softTealBg => theme.brightness == Brightness.dark
      ? AppTheme.softTealBackgroundDark
      : AppTheme.softTealBackground;
}
