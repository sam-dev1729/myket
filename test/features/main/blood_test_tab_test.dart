import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myket/core/theme/app_palette.dart';
import 'package:myket/core/theme/app_theme.dart';
import 'package:myket/features/lab_test/data/models/lab_test_models.dart';
import 'package:myket/features/lab_test/presentation/lab_test_list_controller.dart';
import 'package:myket/features/main/presentation/tabs/blood_test_tab.dart';
import 'package:myket/l10n/app_localizations.dart';

class _FakeLabTestListController extends LabTestListController {
  @override
  Future<List<LabTestHeader>> build() async {
    return const [
      LabTestHeader(
        id: 'test-1',
        testDate: '2024-05-20',
        doctorName: 'دکتر محمدی',
        labName: 'آزمایشگاه تخصصی سلامت فردا با نام بسیار طولانی',
      ),
    ];
  }
}

void main() {
  testWidgets('blood test card lays out RTL content without overflow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [labTestListControllerProvider.overrideWith(_FakeLabTestListController.new)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
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
          home: const BloodTestTab(showBackButton: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('آزمایش خون'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
