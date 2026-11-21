import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/trailing_arrow.dart';
import '../../../../l10n/app_localizations.dart';

/// The analysis destinations reachable from the blood-test list.
enum AnalysisAction { report, compare, trend }

/// Bottom sheet shown by the "بررسی و تحلیل آزمایش" button.
///
/// Offers three destinations: the overall health report, the multi-test
/// comparison, and the parameter trend chart.
class AnalysisActionsSheet extends StatelessWidget {
  const AnalysisActionsSheet({super.key});

  /// Opens the analysis sheet and navigates to the selected destination.
  static Future<void> show(BuildContext context) async {
    final action = await showModalBottomSheet<AnalysisAction>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => const AnalysisActionsSheet(),
    );
    if (action == null || !context.mounted) return;

    switch (action) {
      case AnalysisAction.report:
        await context.push(AppConstants.healthReportRoute);
      case AnalysisAction.compare:
        await context.push(AppConstants.compareTestsRoute);
      case AnalysisAction.trend:
        await context.push(AppConstants.analyteSeriesRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppConstants.screenPadding,
              0,
              AppConstants.screenPadding,
              AppConstants.paddingSmall,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.analysisActionsTitle,
                    style: context.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: l10n.close,
                  icon: Icon(Icons.close, color: context.textSecondaryColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          _ActionTile(
            icon: Icons.favorite_border,
            label: l10n.analysisReportAction,
            onTap: () => Navigator.of(context).pop(AnalysisAction.report),
          ),
          Divider(height: 1, color: context.appDividerColor),
          _ActionTile(
            icon: Icons.copy_all_outlined,
            label: l10n.analysisCompareAction,
            onTap: () => Navigator.of(context).pop(AnalysisAction.compare),
          ),
          Divider(height: 1, color: context.appDividerColor),
          _ActionTile(
            icon: Icons.show_chart,
            label: l10n.analysisTrendAction,
            onTap: () => Navigator.of(context).pop(AnalysisAction.trend),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
        ],
      ),
    );
  }
}

/// A single row in the analysis sheet.
class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
      leading: Icon(icon, color: context.colorScheme.primary),
      title: Text(label, style: context.textTheme.titleMedium),
      trailing: TrailingArrow(color: context.textTertiaryColor),
      onTap: onTap,
    );
  }
}
