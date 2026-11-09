import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/profile_completeness_provider.dart';

/// Screen that gates profile-dependent flows behind a complete profile.
///
/// When the caller passes [nextRoute], the screen auto-navigates there as
/// soon as [profileCompletenessProvider] reports a complete profile (e.g.
/// after the user finishes editing and returns from [EditProfileScreen]).
class MustFillProfileScreen extends ConsumerWidget {
  /// Route the caller wants to reach after completing the profile.
  final String? nextRoute;

  const MustFillProfileScreen({super.key, this.nextRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final completeness = ref.watch(profileCompletenessProvider);

    // Auto-navigate when the profile becomes complete.
    ref.listen<ProfileCompleteness>(profileCompletenessProvider, (previous, next) {
      if (next.isComplete && nextRoute != null && nextRoute!.isNotEmpty) {
        context.go(nextRoute!);
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(l10n.mustFillProfileTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                decoration: BoxDecoration(
                  color: AppTheme.softTealBackground,
                  borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.person_outline, size: 64, color: AppTheme.success),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      l10n.mustFillProfileHeading,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      l10n.mustFillProfileDescription,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              Text(
                l10n.mustFillProfileMissingFields,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              ...completeness.missingFields.map(
                (field) => Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppTheme.warning, size: 20),
                      const SizedBox(width: AppConstants.paddingSmall),
                      Expanded(child: Text(_localizedFieldName(field, l10n))),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                height: AppConstants.financialButtonHeight,
                child: ElevatedButton(
                  onPressed: () async {
                    await context.push(AppConstants.editProfileRoute);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                    ),
                  ),
                  child: Text(
                    l10n.mustFillProfileCta,
                    style: const TextStyle(
                      color: AppTheme.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _localizedFieldName(String key, AppLocalizations l10n) {
    switch (key) {
      case MandatoryProfileFields.birthDate:
        return l10n.birthDateLabel;
      case MandatoryProfileFields.bloodType:
        return l10n.bloodTypeLabel;
      case MandatoryProfileFields.isMale:
        return l10n.genderLabel;
      default:
        return key;
    }
  }
}
