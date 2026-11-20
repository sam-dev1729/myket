import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_theme.dart';

/// Controller for the selected app theme.
///
/// Loads the persisted theme at startup (migrating the legacy dark-mode
/// boolean on first run) and persists every change.
class AppThemeController extends AsyncNotifier<AppThemeId> {
  @override
  Future<AppThemeId> build() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(AppConstants.prefKeyTheme);
    if (stored != null) {
      return AppThemeId.fromStorage(stored);
    }

    // Legacy installs only had a dark-mode switch.
    final legacyDarkMode = prefs.getBool(AppConstants.prefKeyDarkMode) ?? false;
    return legacyDarkMode ? AppThemeId.dark : AppTheme.defaultThemeId;
  }

  /// Selects [id] and persists it.
  Future<void> setTheme(AppThemeId id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefKeyTheme, id.storageValue);
    state = AsyncData(id);
  }
}

/// Riverpod provider for [AppThemeController].
final appThemeProvider = AsyncNotifierProvider<AppThemeController, AppThemeId>(
  AppThemeController.new,
);

/// Synchronous view of the selected theme (default while loading).
final selectedThemeProvider = Provider<AppThemeId>((ref) {
  return ref.watch(appThemeProvider).value ?? AppTheme.defaultThemeId;
});

/// Whether the selected theme is the dark theme.
final isDarkThemeProvider = Provider<bool>((ref) {
  return ref.watch(selectedThemeProvider).isDark;
});
