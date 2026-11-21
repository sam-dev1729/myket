import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/models/lab_test_models.dart';
import '../compare_provider.dart';

/// Exports a text report through the platform share sheet or saves it to a
/// user-selected file.
class ReportExporter {
  const ReportExporter._();

  /// Shares [text] using the platform share sheet.
  static Future<bool> shareText(String text, {String? subject}) async {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(text: text, subject: subject),
      );
      return result.status != ShareResultStatus.unavailable;
    } catch (_) {
      return false;
    }
  }

  /// Saves [text] as a plain-text file chosen by the user.
  static Future<bool> saveText(String text, {required String fileName}) async {
    try {
      final path = await FilePicker.saveFile(
        dialogTitle: fileName,
        fileName: fileName,
        bytes: Uint8List.fromList(utf8.encode(text)),
      );
      return path != null;
    } catch (_) {
      return false;
    }
  }

  /// Builds the plain-text version of the overall health report.
  static String buildHealthReportText({
    required AppLocalizations l10n,
    required HealthOverview overview,
    required String statusLabel,
    required String reportDate,
    required int analyzedTests,
    required List<HealthKeyMarker> markers,
  }) {
    final buffer = StringBuffer()
      ..writeln(l10n.healthReportTitle)
      ..writeln('${l10n.testTypeLabel}: ${l10n.bloodTestTitle}')
      ..writeln('${l10n.reportDateLabel}: $reportDate')
      ..writeln(
        '${l10n.reportAnalyzedTestsLabel}: ${l10n.reportAnalyzedTests(analyzedTests)}',
      )
      ..writeln('${l10n.overallHealth}: $statusLabel')
      ..writeln()
      ..writeln(l10n.importantParametersLabel);

    for (final marker in markers) {
      final range = (marker.refMin != null || marker.refMax != null)
          ? '${marker.refMin ?? '-'} - ${marker.refMax ?? '-'}'
          : '-';
      buffer.writeln(
        '- ${marker.name ?? marker.code ?? '-'}: ${marker.value ?? '-'} '
        '${marker.unit ?? ''} (${l10n.normalRangeLabel}: $range)',
      );
    }

    if (overview.advice != null && overview.advice!.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(l10n.doctorSuggestions)
        ..writeln(overview.advice);
    }

    return buffer.toString().trim();
  }

  /// Builds the plain-text version of one saved lab test.
  static String buildLabTestDetailText({
    required AppLocalizations l10n,
    required LabTestDetail detail,
    required String formattedDate,
  }) {
    final buffer = StringBuffer()
      ..writeln(l10n.labTestDetailTitle)
      ..writeln('${l10n.testTypeLabel}: ${l10n.bloodTestTitle}')
      ..writeln('${l10n.testDate}: $formattedDate')
      ..writeln('${l10n.doctorName}: ${detail.doctorName ?? l10n.noData}')
      ..writeln('${l10n.labName}: ${detail.labName ?? l10n.noData}');
    if ((detail.labAddress ?? '').isNotEmpty) {
      buffer.writeln('${l10n.labTestDetailLabAddress}: ${detail.labAddress}');
    }
    if ((detail.testNumber ?? '').isNotEmpty) {
      buffer.writeln('${l10n.labTestDetailTestNumber}: ${detail.testNumber}');
    }

    buffer
      ..writeln()
      ..writeln(l10n.extractedParametersLabel);
    for (final category in detail.categories) {
      buffer.writeln(category.name);
      for (final parameter in category.parameters) {
        final range = (parameter.refMin != null || parameter.refMax != null)
            ? '${parameter.refMin ?? '-'} - ${parameter.refMax ?? '-'}'
            : '-';
        buffer.writeln(
          '- ${parameter.name}: ${parameter.value} ${parameter.unit ?? ''} '
          '(${l10n.normalRangeLabel}: $range)',
        );
      }
    }
    return buffer.toString().trim();
  }

  /// Builds the plain-text version of a multi-test comparison.
  static String buildComparisonText({
    required AppLocalizations l10n,
    required LabComparison comparison,
  }) {
    final buffer = StringBuffer()..writeln(l10n.compareResultTitle(comparison.columns.length));
    for (final row in comparison.rows) {
      buffer.writeln(
        '- ${row.name}: ${row.values.entries.map((entry) => entry.value).join(' | ')} '
        '(${l10n.normalRangeLabel}: ${row.range})',
      );
    }
    return buffer.toString().trim();
  }
}
