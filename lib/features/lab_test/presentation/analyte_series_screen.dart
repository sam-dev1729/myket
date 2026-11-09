import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/lab_test_models.dart';
import 'series_controller.dart';
import 'widgets/analyte_picker_sheet.dart';

/// Screen that plots the time series of one or more analytes over all of the
/// user's saved lab tests.
///
/// Navigated from [LabOverviewScreen]'s AppBar chart action. The screen
/// itself has no AppBar action — analyte selection is done via the
/// "change analytes" button inside the body (see [AnalytePickerSheet]).
class AnalyteSeriesScreen extends ConsumerStatefulWidget {
  const AnalyteSeriesScreen({super.key});

  @override
  ConsumerState<AnalyteSeriesScreen> createState() => _AnalyteSeriesScreenState();
}

class _AnalyteSeriesScreenState extends ConsumerState<AnalyteSeriesScreen> {
  List<String> _selectedIds = const [];

  Future<void> _pickAnalytes() async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.transparent,
      builder: (_) => AnalytePickerSheet(initialSelection: _selectedIds),
    );
    if (result != null) {
      setState(() => _selectedIds = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = _selectedIds.isEmpty
        ? const AsyncValue<LabSeriesResponse>.data(LabSeriesResponse())
        : ref.watch(labSeriesProvider(_selectedIds));

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text(l10n.analyteSeriesTitle),
        centerTitle: true,
        backgroundColor: AppTheme.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(labSeriesProvider(_selectedIds)),
              child: Text(l10n.retry),
            ),
          ),
          data: (data) {
            if (_selectedIds.isEmpty) {
              return _EmptyState(onPick: _pickAnalytes, l10n: l10n);
            }
            if (data.series.isEmpty) {
              return Center(child: Text(l10n.analyteSeriesNoData));
            }
            return ListView(
              padding: const EdgeInsets.all(AppConstants.screenPadding),
              children: [
                if (_selectedIds.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                    child: OutlinedButton.icon(
                      onPressed: _pickAnalytes,
                      icon: const Icon(Icons.tune, size: 18),
                      label: Text(l10n.analyteSeriesChangeAnalytes),
                    ),
                  ),
                SizedBox(
                  height: AppConstants.chartHeight,
                  child: _MultiLineChart(series: data.series),
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                _Legend(series: data.series),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Empty state shown when no analytes have been picked yet.
class _EmptyState extends StatelessWidget {
  final VoidCallback onPick;
  final AppLocalizations l10n;

  const _EmptyState({required this.onPick, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.show_chart, size: 80, color: context.textTertiaryColor),
            const SizedBox(height: AppConstants.paddingLarge),
            Text(
              l10n.analyteSeriesEmptyTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              l10n.analyteSeriesEmptyDescription,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: context.textSecondaryColor),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            ElevatedButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.add, color: AppTheme.black),
              label: Text(
                l10n.analyteSeriesPickTooltip,
                style: const TextStyle(color: AppTheme.black, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                minimumSize: const Size(0, AppConstants.financialButtonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Multi-line chart that plots every series against a shared day-index axis.
class _MultiLineChart extends StatelessWidget {
  final List<LabSeries> series;

  const _MultiLineChart({required this.series});

  static const List<Color> _palette = [
    AppTheme.info,
    AppTheme.success,
    AppTheme.warning,
    AppTheme.logoPurple,
    AppTheme.error,
  ];

  @override
  Widget build(BuildContext context) {
    // Merge all distinct dates to build a shared X axis.
    final allDates = <String>{};
    for (final s in series) {
      for (final p in s.points) {
        if (p.date != null) allDates.add(p.date!);
      }
    }
    final sortedDates = allDates.toList()..sort();

    final bars = <LineChartBarData>[];
    for (var i = 0; i < series.length; i++) {
      final s = series[i];
      final color = _palette[i % _palette.length];
      final spots = <FlSpot>[];
      for (final p in s.points) {
        if (p.date == null) continue;
        final x = sortedDates.indexOf(p.date!);
        final y = p.plotValue;
        if (x < 0 || y == null) continue;
        spots.add(FlSpot(x.toDouble(), y.toDouble()));
      }
      if (spots.isEmpty) continue;

      bars.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        ),
      );
    }

    if (bars.isEmpty) {
      return const Center(child: Text('-'));
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (sortedDates.length - 1).clamp(0, double.infinity).toDouble(),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: sortedDates.length <= AppConstants.chartMaxXLabels
                  ? 1
                  : (sortedDates.length / AppConstants.chartMaxXLabels),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= sortedDates.length) {
                  return const SizedBox.shrink();
                }
                final raw = sortedDates[idx];
                // Show only month/day to save space.
                final short = raw.length >= 10 ? raw.substring(5) : raw;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(short, style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
        ),
      ),
    );
  }
}

/// Legend that maps each series color to its analyte name + unit.
class _Legend extends StatelessWidget {
  final List<LabSeries> series;

  const _Legend({required this.series});

  @override
  Widget build(BuildContext context) {
    final colors = _MultiLineChart._palette;
    return Wrap(
      spacing: AppConstants.paddingMedium,
      runSpacing: AppConstants.paddingSmall,
      children: [
        for (var i = 0; i < series.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Text(
                '${series[i].analyteName ?? '-'}'
                '${series[i].unit != null ? ' (${series[i].unit})' : ''}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
      ],
    );
  }
}