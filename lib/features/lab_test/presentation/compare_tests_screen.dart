import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/lab_test_models.dart';
import 'lab_test_list_controller.dart';
import 'utils/lab_date_format.dart';

/// Screen that lets the user pick 2–3 saved lab tests to compare.
class CompareTestsScreen extends ConsumerStatefulWidget {
  const CompareTestsScreen({super.key});

  @override
  ConsumerState<CompareTestsScreen> createState() => _CompareTestsScreenState();
}

class _CompareTestsScreenState extends ConsumerState<CompareTestsScreen> {
  final Set<String> _selectedIds = {};

  void _toggle(String id) {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else if (_selectedIds.length >= AppConstants.compareMaxTests) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.compareMaxSelection),
            backgroundColor: AppTheme.warning,
          ),
        );
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _openComparison() {
    if (_selectedIds.length < AppConstants.compareMinTests) return;
    final ids = _selectedIds.toList(growable: false);
    context.push(AppConstants.compareResultRoute, extra: ids);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final testsAsync = ref.watch(labTestListControllerProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text(l10n.compareTestsTitle),
        centerTitle: true,
        backgroundColor: AppTheme.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.iconColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: testsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: TextButton(
                    onPressed: () =>
                        ref.read(labTestListControllerProvider.notifier).refreshList(),
                    child: Text(l10n.retry),
                  ),
                ),
                data: (tests) {
                  if (tests.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.noLabTestsFound,
                        style: TextStyle(color: context.textSecondaryColor),
                      ),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.screenPadding,
                      vertical: AppConstants.paddingMedium,
                    ),
                    children: [
                      Text(
                        l10n.compareSelectionTitle,
                        style: context.textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppConstants.paddingTiny),
                      Text(
                        l10n.compareSelectionHint,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.6,
                          color: context.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      for (var index = 0; index < tests.length; index++)
                        _SelectableTestCard(
                          test: tests[index],
                          number: index + 1,
                          selected: _selectedIds.contains(tests[index].id),
                          onTap: () => _toggle(tests[index].id),
                        ),
                    ],
                  );
                },
              ),
            ),
            _CompareButton(
              enabled: _selectedIds.length >= AppConstants.compareMinTests,
              label: l10n.compareAction,
              onPressed: _openComparison,
            ),
          ],
        ),
      ),
    );
  }
}

/// Selectable lab-test card.
class _SelectableTestCard extends StatelessWidget {
  const _SelectableTestCard({
    required this.test,
    required this.number,
    required this.selected,
    required this.onTap,
  });

  final LabTestHeader test;
  final int number;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          child: AnimatedContainer(
            duration: AppConstants.themeSelectAnimation,
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: selected
                  ? context.colorScheme.primary.withValues(alpha: 0.06)
                  : context.surfaceColor,
              borderRadius: BorderRadius.circular(AppConstants.cardRadius),
              border: Border.all(
                color: selected ? context.colorScheme.primary : context.appDividerColor,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: selected ? context.colorScheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: selected ? context.colorScheme.primary : context.appDividerColor,
                      width: 1.5,
                    ),
                  ),
                  child: selected
                      ? Icon(Icons.check, size: 16, color: context.colorScheme.onPrimary)
                      : null,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.labTestCardTitle('$number'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: AppConstants.paddingTiny),
                      _TestInfoRow(
                        icon: Icons.local_hospital,
                        text: test.labName ?? l10n.noData,
                      ),
                      _TestInfoRow(
                        icon: Icons.person_outline,
                        text: test.doctorName ?? l10n.noData,
                      ),
                      _TestInfoRow(
                        icon: Icons.calendar_today,
                        text: formatLabTestDate(
                          context,
                          test.testDate,
                          fallback: l10n.noData,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One icon + text row inside a selectable test card.
class _TestInfoRow extends StatelessWidget {
  const _TestInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Icon(icon, size: 16, color: context.textSecondaryColor),
          const SizedBox(width: AppConstants.paddingTiny + 2),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sticky bottom "compare" button.
class _CompareButton extends StatelessWidget {
  const _CompareButton({
    required this.enabled,
    required this.label,
    required this.onPressed,
  });

  final bool enabled;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.screenPadding),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(top: BorderSide(color: context.appDividerColor)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: AppConstants.financialButtonHeight,
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.pillRadius),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
