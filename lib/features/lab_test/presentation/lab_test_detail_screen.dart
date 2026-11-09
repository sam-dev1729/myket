import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/utils/url_launcher_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/lab_test_models.dart';
import 'lab_test_detail_controller.dart';

/// Screen that displays the full detail (header + files + categories) of a
/// saved lab test, plus edit and delete actions.
///
/// Uses [labTestDetailProvider] (a `FutureProvider.family`) instead of the
/// deprecated Riverpod-2 `FamilyAsyncNotifier`. Refresh is done via
/// `ref.invalidate`, and the delete action is handled by the helper
/// `deleteLabTestById` from the controller file.
///
/// The AppBar's edit action pushes `EditLabTestScreen` (added in PKG-002)
/// and invalidates [labTestDetailProvider] on return, so any mutations
/// made in the edit screen are reflected immediately.
class LabTestDetailScreen extends ConsumerWidget {
  /// The id of the lab test to display.
  final String id;

  const LabTestDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncDetail = ref.watch(labTestDetailProvider(id));

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text(l10n.labTestDetailTitle),
        centerTitle: true,
        backgroundColor: AppTheme.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: l10n.editButton,
            icon: Icon(Icons.edit_outlined, color: context.iconColor),
            onPressed: () async {
              await context.push(AppConstants.editLabTestRouteTemplate.replaceFirst(':id', id));
              // Refresh the detail after returning — the user may have
              // edited categories, parameters, or the header.
              if (context.mounted) {
                ref.invalidate(labTestDetailProvider(id));
              }
            },
          ),
          IconButton(
            tooltip: l10n.delete,
            icon: const Icon(Icons.delete_outline, color: AppTheme.error),
            onPressed: () => _confirmDelete(context, ref, l10n),
          ),
        ],
      ),
      body: SafeArea(
        child: asyncDetail.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                const SizedBox(height: AppConstants.paddingSmall),
                Text('${l10n.genericErrorPrefix}: $e', textAlign: TextAlign.center),
                const SizedBox(height: AppConstants.paddingSmall),
                TextButton(
                  onPressed: () => ref.invalidate(labTestDetailProvider(id)),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
          data: (detail) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(labTestDetailProvider(id));
              await ref.read(labTestDetailProvider(id).future);
            },
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.screenPadding),
              children: [
                _HeaderCard(detail: detail, l10n: l10n),
                if (detail.files.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.paddingLarge),
                  Text(
                    l10n.labTestDetailFiles,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  ...detail.files.map((f) => _FileTile(file: f, l10n: l10n)),
                ],
                const SizedBox(height: AppConstants.paddingLarge),
                ...detail.categories.map((c) => _CategoryCard(category: c, l10n: l10n)),
                const SizedBox(height: AppConstants.paddingXLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.labTestDeleteConfirmTitle),
        content: Text(l10n.labTestDeleteConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final ok = await deleteLabTestById(ref, id);

    if (!context.mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.labTestDeleted), backgroundColor: AppTheme.success),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.labTestDeleteFailed), backgroundColor: AppTheme.error),
      );
    }
  }
}

/// Header card that shows test date, doctor, lab, and optional address/number.
class _HeaderCard extends StatelessWidget {
  final LabTestDetail detail;
  final AppLocalizations l10n;

  const _HeaderCard({required this.detail, required this.l10n});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            icon: Icons.calendar_today,
            label: l10n.testDate,
            value: detail.testDate ?? l10n.noData,
          ),
          _InfoRow(
            icon: Icons.person_outline,
            label: l10n.doctorName,
            value: detail.doctorName ?? l10n.noData,
          ),
          _InfoRow(
            icon: Icons.local_hospital,
            label: l10n.labName,
            value: detail.labName ?? l10n.noData,
          ),
          if (detail.labAddress != null && detail.labAddress!.isNotEmpty)
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: l10n.labTestDetailLabAddress,
              value: detail.labAddress!,
            ),
          if (detail.testNumber != null && detail.testNumber!.isNotEmpty)
            _InfoRow(
              icon: Icons.confirmation_number_outlined,
              label: l10n.labTestDetailTestNumber,
              value: detail.testNumber!,
            ),
        ],
      ),
    );
  }
}

/// A single labeled row with a leading icon.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingTiny),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.textSecondaryColor),
          const SizedBox(width: AppConstants.paddingSmall),
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: context.textSecondaryColor, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

/// A single linked file with an "open" action.
class _FileTile extends StatelessWidget {
  final LabTestDetailFile file;
  final AppLocalizations l10n;

  const _FileTile({required this.file, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.error),
      title: Text(file.originalName ?? file.id),
      trailing: TextButton(
        onPressed: () => UrlLauncherHelper.openExternal(file.url),
        child: Text(l10n.labTestOpenFile),
      ),
    );
  }
}

/// A category card with an expandable list of parameters.
class _CategoryCard extends StatelessWidget {
  final LabTestDetailCategory category;
  final AppLocalizations l10n;

  const _CategoryCard({required this.category, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: context.appDividerColor),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
        children: category.parameters.map((p) => _ParameterRow(parameter: p, l10n: l10n)).toList(),
      ),
    );
  }
}

/// A single parameter row showing name, value, range, and H/L badge.
class _ParameterRow extends StatelessWidget {
  final LabTestDetailParameter parameter;
  final AppLocalizations l10n;

  const _ParameterRow({required this.parameter, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final (color, label) = _flagStyle(parameter.flag, l10n);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(parameter.name, style: const TextStyle(fontSize: 13))),
          Expanded(
            flex: 2,
            child: Text(
              parameter.value + (parameter.unit != null ? ' ${parameter.unit}' : ''),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _formatRange(parameter.refMin, parameter.refMax, l10n),
              style: TextStyle(fontSize: 11, color: context.textTertiaryColor),
            ),
          ),
          if (label != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color!.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppConstants.pillRadius),
              ),
              child: Text(
                label,
                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  /// Returns a (color, label) pair for the H/L flag, or (null, null) when
  /// the parameter is within range.
  (Color?, String?) _flagStyle(String? flag, AppLocalizations l10n) {
    switch (flag) {
      case 'H':
        return (AppTheme.error, l10n.labTestFlagHigh);
      case 'L':
        return (AppTheme.info, l10n.labTestFlagLow);
      default:
        return (null, null);
    }
  }

  /// Formats the reference range text using the localized template.
  String _formatRange(String? min, String? max, AppLocalizations l10n) {
    if (min == null && max == null) return '';
    return l10n.labTestParameterRange(min ?? '-', max ?? '-');
  }
}
