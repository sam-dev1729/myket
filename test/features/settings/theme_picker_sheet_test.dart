import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myket/core/theme/app_palette.dart';
import 'package:myket/core/theme/app_theme.dart';
import 'package:myket/features/settings/presentation/providers/theme_provider.dart';
import 'package:myket/features/settings/presentation/widgets/theme_picker_sheet.dart';
import 'package:myket/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget buildApp(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.themeFor(AppThemeId.vital),
        locale: const Locale('fa', 'IR'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('fa', 'IR')],
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => ThemePickerSheet.show(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('picker lists four light themes and one dark theme', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(buildApp(container));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('تم ظاهری'), findsOneWidget);
    expect(find.text('تم‌های روشن'), findsOneWidget);
    expect(find.text('تم تیره'), findsOneWidget);
    expect(find.text('سبز حیات و بنفش رویایی'), findsOneWidget);
    expect(find.text('آبی شفا و نارنجی پویا'), findsOneWidget);
    expect(find.text('فیروزه‌ای حامی و مرجانی خلاق'), findsOneWidget);
    expect(find.text('کلاسیک نئون'), findsOneWidget);
    expect(find.text('شبانه'), findsOneWidget);
  });

  testWidgets('tapping a theme selects and persists it', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(buildApp(container));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('آبی شفا و نارنجی پویا'));
    await tester.pumpAndSettle();

    expect(container.read(selectedThemeProvider), AppThemeId.healing);
    expect(container.read(isDarkThemeProvider), isFalse);
    expect(find.text('تم ظاهری'), findsNothing); // sheet closed
  });
}
