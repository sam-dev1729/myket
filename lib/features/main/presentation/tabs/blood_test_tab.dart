import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../financial/presentation/package_controller.dart';
import '../../../lab_test/data/models/lab_test_models.dart';
import '../../../lab_test/presentation/lab_test_list_controller.dart';
import '../../../lab_test/presentation/utils/lab_date_format.dart';
import '../../../lab_test/presentation/widgets/analysis_actions_sheet.dart';
import '../../../profile/presentation/providers/profile_completeness_provider.dart';

/// The Blood Test tab showing saved lab tests and an upload CTA.
///
/// The upload CTA is gated:
/// 1. If the profile is incomplete → redirects to [MustFillProfileScreen].
/// 2. If the user has no active package → redirects to [EmptyPackageScreen].
class BloodTestTab extends ConsumerWidget {
  const BloodTestTab({super.key, this.showBackButton = false});

  /// Whether to show an app bar with a back button (when pushed as a route)
  /// instead of the tab's icon bar.
  final bool showBackButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final labTestsAsync = ref.watch(labTestListControllerProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: showBackButton
          ? AppBar(
              title: Text(l10n.bloodAndUrineTest),
              centerTitle: true,
              backgroundColor: AppTheme.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: context.iconColor),
                onPressed: () => context.pop(),
              ),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (!showBackButton) const _TopIconBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(labTestListControllerProvider.notifier).refreshList(),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
                  children: [
                    const SizedBox(height: AppConstants.paddingMedium),
                    _UploadCard(
                      onTap: () => AnalysisActionsSheet.show(context),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    labTestsAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(AppConstants.paddingXLarge),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => _ErrorWidget(
                        onRetry: () =>
                            ref.read(labTestListControllerProvider.notifier).refreshList(),
                      ),
                                            data: (labTests) {
                        if (labTests.isEmpty) {
                          return const _EmptyWidget();
                        }
                        return Column(
                          children: labTests.asMap().entries.map((entry) {
                            final index = entry.key;
                            final test = entry.value;
                            return _LabTestCard(
                              number: '${index + 1}',
                              test: test,
                              onTap: () async {
                                await context.push(
                                  AppConstants.labTestDetailRouteTemplate.replaceFirst(
                                    ':id',
                                    test.id,
                                  ),
                                );
                                ref.read(labTestListControllerProvider.notifier).refreshList();
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    _AddTestButton(onTap: () => _startUploadFlow(context, ref)),
                    const SizedBox(height: AppConstants.paddingXLarge),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top icon bar used by tab screens.
class _TopIconBar extends StatelessWidget {
  const _TopIconBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.screenPadding,
        vertical: AppConstants.paddingMedium,
      ),
      child: Row(
        children: [
          _CircleIconButton(icon: Icons.headset_mic_outlined, onTap: () {}),
          const SizedBox(width: AppConstants.paddingSmall),
          _CircleIconButton(icon: Icons.settings_outlined, onTap: () {}),
          const SizedBox(width: AppConstants.paddingSmall),
          _CircleIconButton(
            icon: Icons.notifications_none,
            onTap: () => context.push(AppConstants.notificationsRoute),
            showBadge: true,
          ),
        ],
      ),
    );
  }
}

/// A round icon button with an optional notification badge.
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;

  const _CircleIconButton({required this.icon, required this.onTap, this.showBadge = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: context.appDividerColor),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Stack(
          children: [
            Center(child: Icon(icon, color: context.textPrimaryColor, size: 20)),
            if (showBadge)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: AppTheme.error, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The upload CTA card with a placeholder test-tube illustration.
class _UploadCard extends StatelessWidget {
  final VoidCallback onTap;

  const _UploadCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: context.appDividerColor),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppConstants.paddingMedium),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: context.softRedBg,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: const Icon(Icons.science, size: 60, color: AppTheme.error),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          SizedBox(
            width: double.infinity,
            height: AppConstants.buttonHeight,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                ),
              ),
              child: Text(
                l10n.reviewAndAnalyzeTest,
                style: TextStyle(
                  color: context.colorScheme.onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
        ],
      ),
    );
  }
}

/// A saved lab-test card with a document placeholder on the right.
/// A saved lab-test card that navigates to its detail screen on tap.
class _LabTestCard extends StatelessWidget {
  final String number;
  final LabTestHeader test;
  final VoidCallback onTap;

  const _LabTestCard({required this.number, required this.test, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          border: Border.all(color: context.appDividerColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: AppConstants.notificationCardImageSize,
              height: AppConstants.notificationCardImageSize,
              decoration: BoxDecoration(
                color: context.surfaceVariantColor,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Icon(Icons.description, size: 40, color: context.textTertiaryColor),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.labTestCardTitle(number),
                          textAlign: TextAlign.start,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.moreOptions,
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  _infoRow(context, Icons.local_hospital, test.labName ?? l10n.noData),
                  const SizedBox(height: AppConstants.paddingTiny),
                  _infoRow(context, Icons.person, test.doctorName ?? l10n.noData),
                  const SizedBox(height: AppConstants.paddingTiny),
                  _infoRow(
                    context,
                    Icons.calendar_today,
                    formatLabTestDate(context, test.testDate, fallback: l10n.noData),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.textTertiaryColor),
        const SizedBox(width: AppConstants.paddingTiny + 2),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            style: TextStyle(color: context.textSecondaryColor, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
/// Empty state shown when no lab tests exist.
class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingXLarge),
      child: Column(
        children: [
          Icon(Icons.science_outlined, size: 60, color: context.textTertiaryColor),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            l10n.noLabTestsFound,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: context.textSecondaryColor),
          ),
        ],
      ),
    );
  }
}

/// Error state with a retry button.
class _ErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorWidget({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingXLarge),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 60, color: AppTheme.error),
          const SizedBox(height: AppConstants.paddingMedium),
          TextButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}

/// Applies the profile/package gates and opens the upload screen.
///
/// The file itself is picked inside [UploadLabTestScreen] so the selected
/// file can be kept there across failures.
Future<void> _startUploadFlow(BuildContext context, WidgetRef ref) async {
  final completeness = ref.read(profileCompletenessProvider);
  if (!completeness.isComplete) {
    await context.push(
      AppConstants.mustFillProfileRoute,
      extra: AppConstants.uploadLabTestRoute,
    );
    return;
  }

  bool hasPackage = false;
  try {
    final packages = await ref.read(activeUserPackagesProvider.future);
    hasPackage = packages.isNotEmpty;
  } catch (_) {
    hasPackage = false;
  }
  if (!context.mounted) return;
  if (!hasPackage) {
    await context.push(AppConstants.emptyPackageRoute);
    return;
  }

  await context.push(AppConstants.uploadLabTestRoute);
  if (!context.mounted) return;
  ref.read(labTestListControllerProvider.notifier).refreshList();
}

/// Dashed "add lab test" button shown below the saved tests.
class _AddTestButton extends StatelessWidget {
  const _AddTestButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        child: Container(
          height: AppConstants.financialButtonHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
            border: Border.all(color: context.appDividerColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: context.colorScheme.primary),
              const SizedBox(width: AppConstants.paddingSmall),
              Text(
                l10n.addLabTestButton,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
