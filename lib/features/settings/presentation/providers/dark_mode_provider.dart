import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';

/// Controller for the app's dark-mode preference.
///
/// Loads the persisted preference once at startup, then exposes a
/// [setDarkMode] toggle that persists the change.
class DarkModeController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.prefKeyDarkMode) ?? false;
  }

  /// Toggles the dark mode and persists the change.
  Future<void> setDarkMode({required bool enabled}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefKeyDarkMode, enabled);
    state = AsyncData(enabled);
  }

  /// Toggles the current value.
  Future<void> toggle() async {
    final current = state.value ?? false;
    await setDarkMode(enabled: !current);
  }
}

/// Riverpod provider for [DarkModeController].
final darkModeProvider = AsyncNotifierProvider<DarkModeController, bool>(DarkModeController.new);

/// Synchronous view of the dark-mode preference (false while loading).
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(darkModeProvider).value ?? false;
});
