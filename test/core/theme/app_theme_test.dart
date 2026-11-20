import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myket/core/theme/app_colors.dart';
import 'package:myket/core/theme/app_palette.dart';
import 'package:myket/core/theme/app_theme.dart';

void main() {
  group('AppPalette', () {
    test('exposes exactly four light themes and one dark theme', () {
      expect(AppPalette.lightPalettes, hasLength(4));
      expect(AppPalette.darkPalettes, hasLength(1));
      expect(AppPalette.all, hasLength(5));

      for (final palette in AppPalette.lightPalettes) {
        expect(palette.brightness, Brightness.light);
        expect(palette.isDark, isFalse);
      }
      expect(AppPalette.darkPalettes.single.brightness, Brightness.dark);
      expect(AppPalette.darkPalettes.single.isDark, isTrue);
    });

    test('of() resolves every theme id to a palette', () {
      for (final id in AppThemeId.values) {
        expect(AppPalette.of(id).id, id);
      }
    });
  });

  group('AppThemeId', () {
    test('round-trips persisted values', () {
      for (final id in AppThemeId.values) {
        expect(AppThemeId.fromStorage(id.storageValue), id);
      }
    });

    test('falls back to the default theme for unknown or missing values', () {
      expect(AppThemeId.fromStorage(null), AppTheme.defaultThemeId);
      expect(AppThemeId.fromStorage('nope'), AppTheme.defaultThemeId);
    });
  });

  group('AppTheme.themeFor', () {
    test('builds a theme for every palette', () {
      for (final palette in AppPalette.all) {
        final theme = AppTheme.themeFor(palette.id);

        expect(theme.brightness, palette.brightness);
        expect(theme.colorScheme.primary, palette.primary);
        expect(theme.colorScheme.onPrimary, palette.onPrimary);
        expect(theme.colorScheme.secondary, palette.secondary);
        expect(theme.colorScheme.tertiary, palette.accent);
        expect(theme.scaffoldBackgroundColor, palette.background);
        expect(theme.colorScheme.surface, palette.surface);
        expect(theme.dividerColor, palette.divider);
        expect(theme.appBarTheme.backgroundColor, palette.background);
      }
    });

    test('registers the AppColors extension matching the palette', () {
      final palette = AppPalette.teal;
      final theme = AppTheme.themeFor(palette.id);
      final colors = theme.extension<AppColors>();

      expect(colors, isNotNull);
      expect(colors!.primary, palette.primary);
      expect(colors.textPrimary, palette.textPrimary);
      expect(colors.textSecondary, palette.textSecondary);
      expect(colors.surfaceVariant, palette.surfaceVariant);
      expect(colors.divider, palette.divider);
    });

    test('light themes keep the light text color, dark theme uses light text', () {
      final light = AppTheme.themeFor(AppThemeId.healing);
      final dark = AppTheme.themeFor(AppThemeId.dark);

      expect(light.textTheme.bodyLarge?.color, AppPalette.healing.textPrimary);
      expect(dark.textTheme.bodyLarge?.color, AppPalette.dark.textPrimary);
      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
    });
  });
}
