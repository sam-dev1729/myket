import 'package:flutter_test/flutter_test.dart';
import 'package:myket/features/lab_test/data/models/lab_test_models.dart';
import 'package:myket/features/lab_test/presentation/compare_provider.dart';

void main() {
  group('buildLabComparison', () {
    test('merges parameters by name across tests', () {
      final first = _detail('t1', '2024-05-20', [
        _parameter('Glucose', '95', 'mg/dL', '70', '100'),
        _parameter('Cholesterol', '180', 'mg/dL', '120', '200', flag: 'H'),
      ]);
      final second = _detail('t2', '2024-06-01', [
        _parameter('glucose', '105', 'mg/dL', '70', '100', flag: 'H'),
        _parameter('HDL', '55', 'mg/dL', '40', '60'),
      ]);

      final comparison = buildLabComparison([first, second]);

      expect(comparison.columns, hasLength(2));
      expect(comparison.rows, hasLength(3));
      expect(comparison.rows[0].name, 'Glucose');
      expect(comparison.rows[0].values['t1'], '95');
      expect(comparison.rows[0].values['t2'], '105');
      expect(comparison.rows[0].flags['t2'], 'H');
      expect(comparison.rows[1].name, 'Cholesterol');
      expect(comparison.rows[1].values['t2'], '-');
      expect(comparison.rows[1].range, '120 - 200');
    });

    test('uses the first non-empty unit and range', () {
      final first = _detail('t1', '2024-05-20', [
        _parameter('WBC', '6.5', '', null, null),
      ]);
      final second = _detail('t2', '2024-06-01', [
        _parameter('WBC', '7.2', 'x10^3/uL', '4.5', '11.0'),
      ]);

      final comparison = buildLabComparison([first, second]);

      expect(comparison.rows.single.unit, 'x10^3/uL');
      expect(comparison.rows.single.range, '4.5 - 11.0');
    });

    test('ignores blank parameter names', () {
      final detail = _detail('t1', '2024-05-20', [_parameter('  ', '1', '-', null, null)]);

      final comparison = buildLabComparison([detail]);

      expect(comparison.rows, isEmpty);
      expect(comparison.isEmpty, isTrue);
    });
  });
}

LabTestDetail _detail(String id, String date, List<LabTestDetailParameter> parameters) {
  return LabTestDetail(
    id: id,
    testDate: date,
    files: const [],
    categories: [
      LabTestDetailCategory(
        id: 'c1',
        name: 'Blood Sugar',
        parameters: parameters,
      ),
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
