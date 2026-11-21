import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/lab_test_repository.dart';
import '../data/models/lab_test_models.dart';

/// One lab test column in a comparison table.
class CompareColumn {
  const CompareColumn({required this.testId, required this.date, this.labName});

  /// Backend id of the test.
  final String testId;

  /// ISO test date (may be empty).
  final String date;

  /// Lab name, when available.
  final String? labName;
}

/// One parameter row in a comparison table.
class CompareRow {
  const CompareRow({
    required this.name,
    required this.unit,
    required this.range,
    required this.values,
    required this.flags,
  });

  /// Display name of the parameter.
  final String name;

  /// Canonical unit (first non-empty unit wins).
  final String unit;

  /// Normal range formatted as `min - max`.
  final String range;

  /// Value per test id; `-` when the test doesn't include the parameter.
  final Map<String, String> values;

  /// Flag (`H`, `L` or null) per test id.
  final Map<String, String?> flags;
}

/// Result of merging the selected lab tests into one side-by-side table.
class LabComparison {
  const LabComparison({required this.columns, required this.rows});

  /// Test columns, in the order the user selected them.
  final List<CompareColumn> columns;

  /// Merged parameter rows.
  final List<CompareRow> rows;

  /// Whether there is nothing to show.
  bool get isEmpty => rows.isEmpty;
}

/// Merges [details] into a single comparison by parameter name.
///
/// Parameters are matched case-insensitively on the trimmed name; the row
/// order follows the first test that introduced the parameter. Tests that do
/// not contain a parameter keep a `-` placeholder.
LabComparison buildLabComparison(List<LabTestDetail> details) {
  final columns = <CompareColumn>[
    for (final detail in details)
      CompareColumn(testId: detail.id, date: detail.testDate ?? '', labName: detail.labName),
  ];

  final order = <String>[];
  final builders = <String, _RowBuilder>{};

  for (final detail in details) {
    for (final category in detail.categories) {
      for (final parameter in category.parameters) {
        final trimmedName = parameter.name.trim();
        if (trimmedName.isEmpty) continue;
        final key = trimmedName.toLowerCase();
        final builder = builders.putIfAbsent(key, () {
          order.add(key);
          return _RowBuilder(trimmedName);
        });
        if (builder.unit.isEmpty && (parameter.unit ?? '').isNotEmpty) {
          builder.unit = parameter.unit!;
        }
        final parameterRange = _formatRange(parameter);
        if (parameterRange != '-' && (builder.range.isEmpty || builder.range == '-')) {
          builder.range = parameterRange;
        }
        builder.values[detail.id] = parameter.value;
        builder.flags[detail.id] = parameter.flag;
      }
    }
  }

  final rows = <CompareRow>[
    for (final key in order)
      CompareRow(
        name: builders[key]!.name,
        unit: builders[key]!.unit,
        range: builders[key]!.range,
        values: {
          for (final column in columns) column.testId: builders[key]!.values[column.testId] ?? '-',
        },
        flags: builders[key]!.flags,
      ),
  ];

  return LabComparison(columns: columns, rows: rows);
}

/// Formats the reference range of [parameter].
String _formatRange(LabTestDetailParameter parameter) {
  if (parameter.refMin == null && parameter.refMax == null) return '-';
  return '${parameter.refMin ?? '-'} - ${parameter.refMax ?? '-'}';
}

/// Loads the selected tests and builds their comparison.
///
/// The family argument is the comma-separated list of test ids. Using a
/// string keeps the provider cache stable for a given selection.
final labComparisonProvider = FutureProvider.family<LabComparison, String>((ref, idsKey) async {
  final ids = idsKey.split(',').where((id) => id.isNotEmpty).toList();
  if (ids.isEmpty) {
    return const LabComparison(columns: [], rows: []);
  }

  final repository = ref.read(labTestRepositoryProvider);
  final details = <LabTestDetail>[];
  for (final id in ids) {
    details.add(await repository.getLabTestDetail(id));
  }
  return buildLabComparison(details);
});

/// Mutable helper used while merging rows.
class _RowBuilder {
  _RowBuilder(this.name);

  final String name;
  String unit = '';
  String range = '';
  final Map<String, String> values = {};
  final Map<String, String?> flags = {};
}
