import 'package:flutter_test/flutter_test.dart';
import 'package:myket/features/lab_test/data/models/lab_test_models.dart';
import 'package:myket/features/lab_test/presentation/utils/health_assistant.dart';
import 'package:myket/l10n/app_localizations_fa.dart';

void main() {
  final l10n = AppLocalizationsFa();

  HealthOverview overviewWithMarkers() {
    return const HealthOverview(
      overallStatus: 'green',
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
      advice: 'کاهش مصرف قند و چربی\nافزایش فعالیت بدنی',
    );
  }

  test('answers with the matching marker value and range', () {
    final reply = buildAssistantReply(
      question: 'قند خون من چقدر است؟',
      overview: overviewWithMarkers(),
      l10n: l10n,
    );

    expect(reply, contains('95'));
    expect(reply, contains('70 - 100'));
  });

  test('answers overall-status questions with the abnormal count', () {
    final reply = buildAssistantReply(
      question: 'وضعیت کلی سلامت من چطور است؟',
      overview: overviewWithMarkers(),
      l10n: l10n,
    );

    expect(reply, contains(l10n.gaugeStatusHealthy));
    expect(reply, contains('1'));
  });

  test('returns advice bullets for advice questions', () {
    final reply = buildAssistantReply(
      question: 'چه توصیه‌ای برای تغذیه دارید؟',
      overview: overviewWithMarkers(),
      l10n: l10n,
    );

    expect(reply, contains('کاهش مصرف قند'));
    expect(reply, contains('•'));
  });

  test('falls back and lists available markers for unknown questions', () {
    final reply = buildAssistantReply(
      question: 'سلام',
      overview: overviewWithMarkers(),
      l10n: l10n,
    );

    expect(reply, contains('Glucose'));
    expect(reply, isNot(contains(l10n.noData)));
  });

  test('greeting includes the status label', () {
    final greeting = buildAssistantGreeting(overview: overviewWithMarkers(), l10n: l10n);

    expect(greeting, contains(l10n.gaugeStatusHealthy));
    expect(greeting, contains(l10n.aiGreeting));
  });

  test('splitAdviceLines strips bullets and blank lines', () {
    final lines = splitAdviceLines('- One\n\n• Two\n* Three');

    expect(lines, ['One', 'Two', 'Three']);
  });
}
