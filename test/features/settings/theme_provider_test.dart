import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myket/core/constants/app_constants.dart';
import 'package:myket/core/theme/app_palette.dart';
import 'package:myket/core/theme/app_theme.dart';
import 'package:myket/features/settings/presentation/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppThemeController', () {
    test('loads the persisted theme', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.prefKeyTheme: AppThemeId.teal.storageValue,
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(await container.read(appThemeProvider.future), AppThemeId.teal);
      expect(container.read(selectedThemeProvider), AppThemeId.teal);
      expect(container.read(isDarkThemeProvider), isFalse);
    });

    test('defaults to the default theme when nothing is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(await container.read(appThemeProvider.future), AppTheme.defaultThemeId);
    });

    test('migrates the legacy dark-mode flag to the dark theme', () async {
      SharedPreferences.setMockInitialValues({AppConstants.prefKeyDarkMode: true});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(await container.read(appThemeProvider.future), AppThemeId.dark);
      expect(container.read(isDarkThemeProvider), isTrue);
    });

    test('setTheme updates state and persists the selection', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(appThemeProvider.future);
      await container.read(appThemeProvider.notifier).setTheme(AppThemeId.dark);

      expect(container.read(selectedThemeProvider), AppThemeId.dark);
      expect(container.read(isDarkThemeProvider), isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AppConstants.prefKeyTheme), AppThemeId.dark.storageValue);

      await container.read(appThemeProvider.notifier).setTheme(AppThemeId.classic);
      expect(container.read(selectedThemeProvider), AppThemeId.classic);
      expect(prefs.getString(AppConstants.prefKeyTheme), AppThemeId.classic.storageValue);
    });
  });
}
