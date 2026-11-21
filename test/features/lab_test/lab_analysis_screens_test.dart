import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myket/core/theme/app_palette.dart';
import 'package:myket/core/theme/app_theme.dart';
import 'package:myket/features/lab_test/data/lab_test_repository.dart';
import 'package:myket/features/lab_test/data/models/lab_test_models.dart';
import 'package:myket/features/lab_test/presentation/ai_assistant_screen.dart';
import 'package:myket/features/lab_test/presentation/compare_result_screen.dart';
import 'package:myket/features/lab_test/presentation/health_overview_provider.dart';
import 'package:myket/features/lab_test/presentation/health_report_screen.dart';
import 'package:myket/features/lab_test/presentation/lab_test_list_controller.dart';
import 'package:myket/l10n/app_localizations.dart';

/// Empty lab-test list so the report screen doesn't hit the network in tests.
class _EmptyLabTestListController extends LabTestListController {
  @override
  Future<List<LabTestHeader>> build() async => const [];
}

void main() {
  const overview = HealthOverview(
    overallStatus: 'orange',
    keyMarkers: [
      HealthKeyMarker(
        code: 'fbs',
        name: 'Glucose',
        value: '95',
        unit: 'mg/dL',
        refMin: '70',
        refMax: '100',
        status: 'green',
      ),
      HealthKeyMarker(
        code: 'chol',
        name: 'Cholesterol',
        value: '210',
        unit: 'mg/dL',
        refMin: '120',
        refMax: '200',
        status: 'orange',
      ),
    ],
    advice: 'کاهش مصرف قند و چربی',
  );

  Widget wrap(ProviderContainer container, Widget child) {
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
        home: child,
      ),
    );
  }

  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [
        healthOverviewProvider.overrideWith((ref) async => overview),
        labTestListControllerProvider.overrideWith(_EmptyLabTestListController.new),
      ],
    );
  }

  testWidgets('health report shows the gauge and key markers', (tester) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = buildContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(wrap(container, const HealthReportScreen()));
    await tester.pumpAndSettle();

    expect(find.text('گزارش کلی سلامت'), findsOneWidget);
    expect(find.text('پارامترهای مهم'), findsOneWidget);
    expect(find.text('Glucose'), findsOneWidget);
    expect(find.text('95'), findsOneWidget);
    expect(find.text('210'), findsOneWidget);
    expect(find.text('دانلود گزارش'), findsOneWidget);
  });

  testWidgets('AI assistant answers a marker question', (tester) async {
    final container = buildContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(wrap(container, const AiAssistantScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'قند خون من چقدر است؟');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.textContaining('95'), findsOneWidget);
    expect(find.textContaining('70 - 100'), findsOneWidget);
  });

  testWidgets('compare result renders one column per selected test', (tester) async {
    tester.view.physicalSize = const Size(1400, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _FakeLabTestRepository({
      't1': _detail('t1', '2024-05-20', [
        _parameter('Glucose', '95', 'mg/dL', '70', '100'),
        _parameter('Cholesterol', '180', 'mg/dL', '120', '200'),
      ]),
      't2': _detail('t2', '2024-06-01', [
        _parameter('Glucose', '105', 'mg/dL', '70', '100', flag: 'H'),
      ]),
    });

    final container = ProviderContainer(
      overrides: [labTestRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      wrap(container, const CompareResultScreen(testIds: ['t1', 't2'])),
    );
    await tester.pumpAndSettle();

    expect(find.text('مقایسه 2 آزمایش'), findsOneWidget);
    expect(find.text('Glucose'), findsOneWidget);
    expect(find.text('95'), findsOneWidget);
    expect(find.text('105'), findsOneWidget);
    expect(find.text('Cholesterol'), findsOneWidget);
  });
}

/// Fake repository exposing only [getLabTestDetail] for the comparison test.
class _FakeLabTestRepository implements LabTestRepository {
  _FakeLabTestRepository(this._details);

  final Map<String, LabTestDetail> _details;

  @override
  Future<LabTestDetail> getLabTestDetail(String id) async => _details[id]!;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

LabTestDetail _detail(String id, String date, List<LabTestDetailParameter> parameters) {
  return LabTestDetail(
    id: id,
    testDate: date,
    files: const [],
    categories: [
      LabTestDetailCategory(id: 'c1', name: 'Blood Sugar', parameters: parameters),
    ],
  );
}

LabTestDetailParameter _parameter(
  String name,
  String value,
  String? unit,
  String? min,
  String? max, {
  String? flag,
}) {
  return LabTestDetailParameter(
    id: 'p-$name-$value',
    categoryId: 'c1',
    name: name,
    value: value,
    unit: unit,
    refMin: min,
    refMax: max,
    flag: flag,
  );
}
