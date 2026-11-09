import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';

/// Controller for the app's language preference.
///
/// Currently only Persian (`fa`) is fully supported. The infrastructure
/// is ready for `en` and `ar` once their `.arb` files are added.
class LanguageController extends AsyncNotifier<Locale> {
  @override
  Future<Locale> build() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(AppConstants.prefKeyLanguage) ?? AppConstants.defaultLanguageCode;
    return _localeFromCode(code);
  }

  /// Sets the app language and persists the change.
  ///
  /// Note: the actual app-locale switch happens in `main.dart` via
  /// `MaterialApp.locale`. Because only `fa` is compiled today, switching
  /// to `en`/`ar` won't change the UI strings yet — but the preference
  /// is saved for when the `.arb` files land.
  Future<void> setLanguage({required String code}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefKeyLanguage, code);
    state = AsyncData(_localeFromCode(code));
  }

  Locale _localeFromCode(String code) {
    switch (code) {
      case AppConstants.languageCodeEn:
        return const Locale('en', 'US');
      case AppConstants.languageCodeAr:
        return const Locale('ar', 'SA');
      case AppConstants.languageCodeFa:
      default:
        return const Locale('fa', 'IR');
    }
  }
}

/// Riverpod provider for [LanguageController].
final languageProvider = AsyncNotifierProvider<LanguageController, Locale>(LanguageController.new);

/// Synchronous view of the language preference.
final currentLocaleProvider = Provider<Locale>((ref) {
  return ref.watch(languageProvider).value ?? const Locale('fa', 'IR');
});
