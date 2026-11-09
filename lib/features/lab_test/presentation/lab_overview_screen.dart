import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/lab_test_models.dart';
import 'lab_overview_provider.dart';

/// Screen that shows the results overview:
/// - overall health status badge
/// - paginated list of the latest mapped parameters
/// - search filter
///
/// Uses [labOverviewParametersControllerProvider] for the list and
/// [labOverviewProvider] for the top status header.
///
/// The AppBar chart action navigates to [AnalyteSeriesScreen] — the same
/// entry point described in `02_SCENARIOS.md` (scenario 9).
class LabOverviewScreen extends ConsumerStatefulWidget {
  const LabOverviewScreen({super.key});

  @override
  ConsumerState<LabOverviewScreen> createState() => _LabOverviewScreenState();
}

class _LabOverviewScreenState extends ConsumerState<LabOverviewScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - AppConstants.infiniteScrollThreshold) {
      ref.read(labOverviewParametersControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final asyncState = ref.watch(labOverviewParametersControllerProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text(l10n.labOverviewTitle),
        centerTitle: true,
        backgroundColor: AppTheme.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: l10n.analyteSeriesTitle,
            icon: Icon(Icons.show_chart, color: context.iconColor),
            onPressed: () => context.push(AppConstants.analyteSeriesRoute),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.screenPadding),
              child: TextField(
                controller: _searchController,
                onSubmitted: (q) =>
                    ref.read(labOverviewParametersControllerProvider.notifier).search(q),
                decoration: InputDecoration(
                  hintText: l10n.labOverviewSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: context.surfaceVariantColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: asyncState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _ErrorView(
                  onRetry: () =>
                      ref.read(labOverviewParametersControllerProvider.notifier).refresh(),
                ),
                data: (data) {
                  if (data.items.isEmpty) {
                    return Center(child: Text(l10n.labOverviewEmpty));
                  }
                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(labOverviewParametersControllerProvider.notifier).refresh(),
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
                      itemCount: data.items.length + 1 + (data.hasMore ? 1 : 0),
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppConstants.paddingSmall),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                            child: _StatusBadge(status: data.overallStatus, l10n: l10n),
                          );
                        }
                        if (index > data.items.length) {
                          return const Padding(
                            padding: EdgeInsets.all(AppConstants.paddingLarge),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return _ParameterTile(parameter: data.items[index - 1], l10n: l10n);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top status badge (green / orange / red) shown above the parameter list.
class _StatusBadge extends StatelessWidget {
  final String? status;
  final AppLocalizations l10n;

  const _StatusBadge({required this.status, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final (color, label) = _resolve(context, status, l10n);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  (Color, String) _resolve(BuildContext context, String? status, AppLocalizations l10n) {
    switch (status?.toLowerCase()) {
      case 'green':
        return (AppTheme.gaugeGreen, l10n.gaugeStatusHealthy);
      case 'orange':
        return (AppTheme.gaugeYellow, l10n.gaugeStatusWarning);
      case 'red':
        return (AppTheme.gaugeRed, l10n.gaugeStatusDanger);
      default:
        return (context.textTertiaryColor, l10n.noData);
    }
  }
}

/// A single parameter row: name, value+unit, range, last test date, lab name.
class _ParameterTile extends StatelessWidget {
  final LabOverviewParameter parameter;
  final AppLocalizations l10n;

  const _ParameterTile({required this.parameter, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context, parameter.status);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: context.appDividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Expanded(
                child: Text(
                  parameter.name ?? l10n.noData,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Text(
                '${parameter.value ?? '-'}'
                '${parameter.unit != null ? ' ${parameter.unit}' : ''}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          if ((parameter.refMin != null || parameter.refMax != null)) ...[
            const SizedBox(height: AppConstants.paddingTiny),
            Text(
              l10n.labTestParameterRange(parameter.refMin ?? '-', parameter.refMax ?? '-'),
              style: TextStyle(fontSize: 11, color: context.textTertiaryColor),
            ),
          ],
          if (parameter.lastTestDate != null || parameter.labName != null) ...[
            const SizedBox(height: AppConstants.paddingTiny),
            Wrap(
              spacing: AppConstants.paddingSmall,
              children: [
                if (parameter.lastTestDate != null)
                  Text(
                    parameter.lastTestDate!,
                    style: TextStyle(fontSize: 11, color: context.textTertiaryColor),
                  ),
                if (parameter.labName != null)
                  Text(
                    parameter.labName!,
                    style: TextStyle(fontSize: 11, color: context.textTertiaryColor),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(BuildContext context, String? status) {
    switch (status?.toLowerCase()) {
      case 'green':
        return AppTheme.gaugeGreen;
      case 'orange':
        return AppTheme.gaugeYellow;
      case 'red':
        return AppTheme.gaugeRed;
      default:
        return context.textTertiaryColor;
    }
  }
}

/// Error state with a retry button.
class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

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