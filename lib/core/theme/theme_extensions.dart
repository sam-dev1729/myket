import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Theme-aware color helpers on [BuildContext].
///
/// Instead of hardcoded [AppTheme] constants (which are light-mode only),
/// use `context.surfaceColor`, `context.textPrimaryColor`, etc. These
/// automatically follow the current brightness (light/dark).
///
/// Example:
/// ```dart
/// // ❌ Before (light-only)
/// Container(color: AppTheme.white)
///
/// // ✅ After (light + dark)
/// Container(color: context.surfaceColor)
/// ```
extension ThemeX on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;

  Color get surfaceColor => colorScheme.surface;
  Color get surfaceVariantColor => colorScheme.surfaceContainerHighest;
  Color get scaffoldColor => theme.scaffoldBackgroundColor;

  Color get textPrimaryColor => colorScheme.onSurface;
  Color get textSecondaryColor => colorScheme.onSurface.withValues(alpha: 0.6);
  Color get textTertiaryColor => colorScheme.onSurface.withValues(alpha: 0.4);

  Color get appDividerColor => theme.dividerColor;
  Color get iconColor => colorScheme.onSurface;

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
