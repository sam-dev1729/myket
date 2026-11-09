import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../financial/presentation/package_controller.dart';
import '../../../lab_test/data/models/lab_test_models.dart';
import '../../../lab_test/presentation/lab_test_list_controller.dart';
import '../../../profile/presentation/providers/profile_completeness_provider.dart';

/// The Blood Test tab showing saved lab tests and an upload CTA.
///
/// The upload CTA is gated:
/// 1. If the profile is incomplete → redirects to [MustFillProfileScreen].
/// 2. If the user has no active package → redirects to [EmptyPackageScreen].
class BloodTestTab extends ConsumerWidget {
  const BloodTestTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labTestsAsync = ref.watch(labTestListControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _TopIconBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(labTestListControllerProvider.notifier).refreshList(),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
                  children: [
                    const SizedBox(height: AppConstants.paddingMedium),
                    _UploadCard(
                      onTap: () async {
                        // 1. Profile completeness gate.
                        final completeness = ref.read(profileCompletenessProvider);
                        if (!completeness.isComplete) {
                          await context.push(
                            AppConstants.mustFillProfileRoute,
                            extra: AppConstants.uploadLabTestRoute,
                          );
                          return;
                        }
                        // 2. Active package gate.
                        bool hasPackage = false;
                        try {
                          final packages = await ref.read(activeUserPackagesProvider.future);
                          hasPackage = packages.isNotEmpty;
                        } catch (_) {
                          hasPackage = false;
                        }
                        if (!hasPackage) {
                          await context.push(AppConstants.emptyPackageRoute);
                          return;
                        }
                        // 3. Proceed to upload.
                        await context.push(AppConstants.uploadLabTestRoute);
                        ref.read(labTestListControllerProvider.notifier).refreshList();
                      },
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
          border: Border.all(color: AppTheme.divider),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Stack(
          children: [
            Center(child: Icon(icon, color: AppTheme.textPrimary, size: 20)),
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
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppConstants.paddingMedium),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.softRedBackground,
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
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                ),
              ),
              child: Text(
                l10n.reviewAndAnalyzeTest,
                style: const TextStyle(
                  color: AppTheme.black,
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
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        tooltip: l10n.moreOptions,
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert),
                      ),
                      Text(
                        l10n.labTestCardTitle(number),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  _infoRow(Icons.local_hospital, test.labName ?? l10n.noData),
                  const SizedBox(height: AppConstants.paddingTiny),
                  _infoRow(Icons.person, test.doctorName ?? l10n.noData),
                  const SizedBox(height: AppConstants.paddingTiny),
                  _infoRow(Icons.calendar_today, test.testDate ?? l10n.noData),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Container(
              width: AppConstants.notificationCardImageSize,
              height: AppConstants.notificationCardImageSize,
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: const Icon(Icons.description, size: 40, color: AppTheme.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(value, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(width: AppConstants.paddingTiny),
        Icon(icon, size: 16, color: AppTheme.textTertiary),
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
          const Icon(Icons.science_outlined, size: 60, color: AppTheme.textTertiary),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            l10n.noLabTestsFound,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
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
