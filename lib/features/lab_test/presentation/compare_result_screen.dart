import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../l10n/app_localizations.dart';
import 'compare_provider.dart';
import 'utils/lab_date_format.dart';
import 'utils/report_exporter.dart';
import 'widgets/export_actions_bar.dart';

/// Side-by-side comparison of the lab tests selected by the user.
class CompareResultScreen extends ConsumerWidget {
  const CompareResultScreen({super.key, required this.testIds});

  /// Ids of the tests to compare, in display order.
  final List<String> testIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final idsKey = testIds.join(',');
    final comparisonAsync = ref.watch(labComparisonProvider(idsKey));

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text(l10n.compareResultTitle(testIds.length)),
        centerTitle: true,
        backgroundColor: AppTheme.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.iconColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: comparisonAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(labComparisonProvider(idsKey)),
              child: Text(l10n.retry),
            ),
          ),
          data: (comparison) {
            if (comparison.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.screenPadding),
                  child: Text(
                    l10n.compareNoCommonParameters,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.textSecondaryColor),
                  ),
                ),
              );
            }

            final reportText = ReportExporter.buildComparisonText(
              l10n: l10n,
              comparison: comparison,
            );

            return Column(
              children: [
                Expanded(child: _ComparisonTable(comparison: comparison)),
                ExportActionsBar(
                  text: reportText,
                  fileName: 'lab-comparison.txt',
                  shareSubject: l10n.compareTestsTitle,
                  l10n: l10n,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Scrollable comparison table (vertical + horizontal).
class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable({required this.comparison});

  final LabComparison comparison;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tableWidth = AppConstants.compareParameterColumnWidth +
        AppConstants.compareRangeColumnWidth +
        comparison.columns.length * AppConstants.compareTestColumnWidth;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
        child: SizedBox(
          width: tableWidth,
          child: Column(
            children: [
              _HeaderRow(comparison: comparison, l10n: l10n),
              for (var index = 0; index < comparison.rows.length; index++)
                _ComparisonRowView(
                  row: comparison.rows[index],
                  columns: comparison.columns,
                  shaded: index.isOdd,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header row with test names, dates and lab names.
class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.comparison, required this.l10n});

  final LabComparison comparison;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final headerStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: context.textSecondaryColor,
    );

    return Container(
      color: context.surfaceVariantColor,
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppConstants.compareParameterColumnWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingTiny),
              child: Text(l10n.parameterNameLabel, style: headerStyle),
            ),
          ),
          SizedBox(
            width: AppConstants.compareRangeColumnWidth,
            child: Text(
              l10n.normalRangeLabel,
              textAlign: TextAlign.center,
              style: headerStyle,
            ),
          ),
          for (var index = 0; index < comparison.columns.length; index++)
            SizedBox(
              width: AppConstants.compareTestColumnWidth,
              child: Column(
                children: [
                  Text(
                    l10n.labTestCardTitle('${index + 1}'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatLabTestDate(
                      context,
                      comparison.columns[index].date,
                      fallback: l10n.noData,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 9, color: context.textSecondaryColor),
                  ),
                  if ((comparison.columns[index].labName ?? '').isNotEmpty)
                    Text(
                      comparison.columns[index].labName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 9, color: context.textTertiaryColor),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// One parameter row across all selected tests.
class _ComparisonRowView extends StatelessWidget {
  const _ComparisonRowView({
    required this.row,
    required this.columns,
    required this.shaded,
  });

  final CompareRow row;
  final List<CompareColumn> columns;
  final bool shaded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: shaded ? context.surfaceVariantColor.withValues(alpha: 0.35) : null,
        border: Border(bottom: BorderSide(color: context.appDividerColor, width: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: AppConstants.compareParameterColumnWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingTiny),
              child: Text(
                row.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          SizedBox(
            width: AppConstants.compareRangeColumnWidth,
            child: Text(
              row.range,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: context.textSecondaryColor),
            ),
          ),
          for (final column in columns)
            SizedBox(
              width: AppConstants.compareTestColumnWidth,
              child: Text(
                row.values[column.testId] ?? '-',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _valueColor(context, row.flags[column.testId]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _valueColor(BuildContext context, String? flag) {
    if (flag == 'H') return AppTheme.error;
    if (flag == 'L') return AppTheme.info;
    return context.textPrimaryColor;
  }
}
