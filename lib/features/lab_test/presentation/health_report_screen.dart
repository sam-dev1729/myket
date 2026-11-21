import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/trailing_arrow.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/lab_test_models.dart';
import 'health_overview_provider.dart';
import 'lab_test_list_controller.dart';
import 'utils/health_status.dart';
import 'utils/lab_date_format.dart';
import 'utils/report_exporter.dart';
import 'widgets/export_actions_bar.dart';
import 'widgets/health_gauge.dart';

/// Purely presentational "Overall health report" screen.
///
/// Combines the AI health overview (status, key markers, advice) with the
/// saved lab tests (count + latest date) and lets the user download or share
/// a plain-text version of the report.
class HealthReportScreen extends ConsumerWidget {
  const HealthReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final overviewAsync = ref.watch(healthOverviewProvider);
    final testsAsync = ref.watch(labTestListControllerProvider);
    final tests = testsAsync.value ?? const <LabTestHeader>[];

    final reportDate = tests.isNotEmpty
        ? formatLabTestDate(context, tests.first.testDate, fallback: l10n.noData)
        : l10n.noData;

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text(l10n.healthReportTitle),
        centerTitle: true,
        backgroundColor: AppTheme.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: l10n.close,
          icon: Icon(Icons.close, color: context.iconColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorView(
            onRetry: () => ref.invalidate(healthOverviewProvider),
          ),
          data: (overview) {
            final statusLabel = healthStatusLabel(overview.overallStatus, l10n);
            final statusColor = healthStatusColor(context, overview.overallStatus);
            final reportText = ReportExporter.buildHealthReportText(
              l10n: l10n,
              overview: overview,
              statusLabel: statusLabel,
              reportDate: reportDate,
              analyzedTests: tests.length,
              markers: overview.keyMarkers,
            );

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(healthOverviewProvider);
                      await ref.read(healthOverviewProvider.future);
                    },
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.screenPadding,
                        vertical: AppConstants.paddingMedium,
                      ),
                      children: [
                        _ReportInfoCard(
                          reportDate: reportDate,
                          analyzedTests: tests.length,
                          l10n: l10n,
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        _GaugeCard(
                          gaugeValue: healthStatusGaugeValue(overview.overallStatus),
                          statusLabel: statusLabel,
                          statusColor: statusColor,
                          l10n: l10n,
                        ),
                        const SizedBox(height: AppConstants.paddingLarge),
                        Text(
                          l10n.importantParametersLabel,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        _ImportantParametersHint(text: l10n.importantParametersHint),
                        const SizedBox(height: AppConstants.paddingSmall),
                        _ImportantParametersTable(
                          markers: overview.keyMarkers,
                          l10n: l10n,
                        ),
                        const SizedBox(height: AppConstants.paddingLarge),
                        _AdviceSection(
                          advice: overview.advice,
                          l10n: l10n,
                          onViewAll: () => context.push(AppConstants.doctorAdviceRoute),
                        ),
                        const SizedBox(height: AppConstants.paddingLarge),
                        _ReadMoreSection(l10n: l10n),
                        const SizedBox(height: AppConstants.paddingXLarge),
                      ],
                    ),
                  ),
                ),
                ExportActionsBar(
                  text: reportText,
                  fileName: 'health-report.txt',
                  shareSubject: l10n.healthReportTitle,
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

/// Header card with the report metadata.
class _ReportInfoCard extends StatelessWidget {
  const _ReportInfoCard({
    required this.reportDate,
    required this.analyzedTests,
    required this.l10n,
  });

  final String reportDate;
  final int analyzedTests;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: context.appDividerColor),
      ),
      child: Column(
        children: [
          _InfoRow(label: l10n.testTypeLabel, value: l10n.bloodTestTitle),
          _InfoRow(label: l10n.reportDateLabel, value: reportDate),
          _InfoRow(
            label: l10n.reportAnalyzedTestsLabel,
            value: l10n.reportAnalyzedTests(analyzedTests),
          ),
        ],
      ),
    );
  }
}

/// A label/value row inside the report header.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 13, color: context.textSecondaryColor),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card containing the health gauge and status label.
class _GaugeCard extends StatelessWidget {
  const _GaugeCard({
    required this.gaugeValue,
    required this.statusLabel,
    required this.statusColor,
    required this.l10n,
  });

  final double gaugeValue;
  final String statusLabel;
  final Color statusColor;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.largeCardRadius),
        border: Border.all(color: context.appDividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.overallHealth,
            style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Center(
            child: HealthGauge(
              value: gaugeValue,
              tickColor: context.textTertiaryColor,
            ),
          ),
          Center(
            child: Text(
              statusLabel,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Warning banner explaining the key-marker freshness caveat.
class _ImportantParametersHint extends StatelessWidget {
  const _ImportantParametersHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.access_time, size: 20, color: AppTheme.warning),
        const SizedBox(width: AppConstants.paddingSmall),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 11, height: 1.6, color: context.textSecondaryColor),
          ),
        ),
      ],
    );
  }
}

/// Table with the important (key) parameters.
class _ImportantParametersTable extends StatelessWidget {
  const _ImportantParametersTable({required this.markers, required this.l10n});

  final List<HealthKeyMarker> markers;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (markers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: context.surfaceVariantColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Text(
          l10n.noData,
          textAlign: TextAlign.center,
          style: TextStyle(color: context.textSecondaryColor),
        ),
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: context.appDividerColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            color: context.surfaceVariantColor,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(l10n.parameterNameLabel, style: _headerStyle(context)),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    l10n.parameterValueLabel,
                    textAlign: TextAlign.center,
                    style: _headerStyle(context),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    l10n.parameterUnitLabel,
                    textAlign: TextAlign.center,
                    style: _headerStyle(context),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    l10n.normalRangeLabel,
                    textAlign: TextAlign.center,
                    style: _headerStyle(context),
                  ),
                ),
              ],
            ),
          ),
          for (final marker in markers) _KeyMarkerRow(marker: marker),
        ],
      ),
    );
  }

  TextStyle _headerStyle(BuildContext context) {
    return TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.textSecondaryColor);
  }
}

/// One key-marker row in the report table.
class _KeyMarkerRow extends StatelessWidget {
  const _KeyMarkerRow({required this.marker});

  final HealthKeyMarker marker;

  @override
  Widget build(BuildContext context) {
    final color = healthStatusColor(context, marker.status);
    final range = (marker.refMin != null || marker.refMax != null)
        ? '${marker.refMin ?? '-'} - ${marker.refMax ?? '-'}'
        : '-';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.appDividerColor, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              marker.name ?? marker.code ?? '-',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              marker.value ?? '-',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              marker.unit ?? '-',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              range,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Teal doctor-advice banner with a link to the full advice screen.
class _AdviceSection extends StatelessWidget {
  const _AdviceSection({
    required this.advice,
    required this.l10n,
    required this.onViewAll,
  });

  final String? advice;
  final AppLocalizations l10n;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final preview = (advice != null && advice!.trim().isNotEmpty)
        ? advice!.trim()
        : l10n.doctorSuggestionsDescription;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: context.softTealBg,
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.doctorSuggestions,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppConstants.paddingTiny),
                    Text(
                      preview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, height: 1.6, color: context.textSecondaryColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: const Icon(Icons.medical_services_outlined, color: AppTheme.success, size: 30),
              ),
            ],
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: onViewAll,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TrailingArrow(color: context.colorScheme.primary),
                const SizedBox(width: AppConstants.paddingTiny),
                Text(l10n.viewAllAdvice),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// "Read more" links to the health blog.
class _ReadMoreSection extends StatelessWidget {
  const _ReadMoreSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final links = [l10n.healthAdvice1, l10n.healthAdvice2, l10n.healthAdvice3];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.readMore,
          style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.paddingTiny),
        Text(
          l10n.readMoreDescription,
          style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        for (final link in links)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: AppConstants.paddingTiny),
            child: GestureDetector(
              onTap: () => context.push(AppConstants.blogListRoute),
              child: Text(
                link,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Error state with retry.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
          const SizedBox(height: AppConstants.paddingSmall),
          TextButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
