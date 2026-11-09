import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/user_profile.dart';
import 'profile_controller.dart';

/// Full read-only view of every field on [UserProfile], grouped into three
/// sections (identity / vitals / medical), with an edit action that navigates
/// to [EditProfileScreen].
///
/// After returning from the edit screen, [profileControllerProvider] is
/// refreshed so the displayed data is up to date.
class PersonalInfoScreen extends ConsumerWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncProfile = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.personalInfoFullTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: l10n.editButton,
            icon: Icon(Icons.edit_outlined, color: context.iconColor),
            onPressed: () => _openEdit(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: asyncProfile.when(
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
                  onPressed: () => ref.read(profileControllerProvider.notifier).refreshProfile(),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
          data: (profile) => RefreshIndicator(
            onRefresh: () => ref.read(profileControllerProvider.notifier).refreshProfile(),
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.screenPadding),
              children: [
                _SectionCard(
                  title: l10n.profileSectionIdentity,
                  icon: Icons.badge_outlined,
                  children: [
                    _InfoRow(label: l10n.firstNameField, value: profile.firstName ?? l10n.noData),
                    _InfoRow(label: l10n.lastNameField, value: profile.lastName ?? l10n.noData),
                    _InfoRow(label: l10n.mobileLabel, value: profile.mobile),
                    _InfoRow(
                      label: l10n.birthDateLabel,
                      value: _formatBirthDate(profile.birthDate, context, l10n),
                    ),
                    _InfoRow(
                      label: l10n.genderLabel,
                      value: profile.isMale == null
                          ? l10n.noData
                          : (profile.isMale! ? l10n.male : l10n.female),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                _SectionCard(
                  title: l10n.profileSectionVitals,
                  icon: Icons.monitor_weight_outlined,
                  children: [
                    _InfoRow(
                      label: l10n.heightLabel,
                      value: profile.height != null ? '${profile.height} ${l10n.cm}' : l10n.noData,
                    ),
                    _InfoRow(
                      label: l10n.weightLabel,
                      value: profile.weight != null ? '${profile.weight} ${l10n.kg}' : l10n.noData,
                    ),
                    _InfoRow(
                      label: l10n.bloodTypeLabel,
                      value: _bloodTypeLabel(profile.bloodType, l10n),
                    ),
                    if (profile.isMale == false)
                      _InfoRow(
                        label: l10n.isPregnantLabel,
                        value: profile.isPregnant == true ? l10n.yesLabel : l10n.noLabel,
                      ),
                    _InfoRow(label: l10n.selectCityLabel, value: profile.city?.name ?? l10n.noData),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                _SectionCard(
                  title: l10n.profileSectionMedical,
                  icon: Icons.medical_information_outlined,
                  children: [
                    _ListRow(
                      label: l10n.allergiesLabel,
                      items:
                          profile.allergies
                              ?.map((e) => e.allergy?.name ?? '')
                              .where((s) => s.isNotEmpty)
                              .toList() ??
                          const [],
                    ),
                    _ListRow(
                      label: l10n.underlyingDiseasesLabel,
                      items:
                          profile.underlyingDiseases
                              ?.map((e) => e.underlyingDisease?.name ?? '')
                              .where((s) => s.isNotEmpty)
                              .toList() ??
                          const [],
                    ),
                    _ListRow(
                      label: l10n.medicalHistoryLabel,
                      items:
                          profile.medicalHistories
                              ?.map((e) => e.medicalHistory?.name ?? '')
                              .where((s) => s.isNotEmpty)
                              .toList() ??
                          const [],
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                SizedBox(
                  height: AppConstants.financialButtonHeight,
                  child: ElevatedButton.icon(
                    onPressed: () => _openEdit(context, ref),
                    icon: Icon(Icons.edit_outlined, color: context.iconColor),
                    label: Text(
                      l10n.editPersonalInfoCta,
                      style: TextStyle(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingXLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openEdit(BuildContext context, WidgetRef ref) async {
    await context.push(AppConstants.editProfileRoute);
    if (!context.mounted) return;
    await ref.read(profileControllerProvider.notifier).refreshProfile();
  }

  String _formatBirthDate(String? iso, BuildContext context, AppLocalizations l10n) {
    if (iso == null || iso.isEmpty) return l10n.noData;
    try {
      final dt = DateTime.parse(iso);
      final locale = Localizations.localeOf(context);
      if (locale.languageCode == 'fa') {
        final j = Jalali.fromDateTime(dt);
        return '${j.day} ${j.formatter.mN} ${j.year}';
      }
      return iso;
    } catch (_) {
      return iso;
    }
  }

  String _bloodTypeLabel(String? code, AppLocalizations l10n) {
    if (code == null) return l10n.noData;
    switch (code) {
      case 'A_POSITIVE':
        return l10n.bloodTypeAPositive;
      case 'A_NEGATIVE':
        return l10n.bloodTypeANegative;
      case 'B_POSITIVE':
        return l10n.bloodTypeBPositive;
      case 'B_NEGATIVE':
        return l10n.bloodTypeBNegative;
      case 'AB_POSITIVE':
        return l10n.bloodTypeABPositive;
      case 'AB_NEGATIVE':
        return l10n.bloodTypeABNegative;
      case 'O_POSITIVE':
        return l10n.bloodTypeOPositive;
      case 'O_NEGATIVE':
        return l10n.bloodTypeONegative;
      default:
        return code;
    }
  }
}

/// Card that groups a titled list of rows.
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.icon, required this.children});

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
          Row(
            children: [
              Icon(icon, color: context.textSecondaryColor, size: 22),
              const SizedBox(width: AppConstants.paddingSmall),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          ...children,
        ],
      ),
    );
  }
}

/// Label + value row, direction-aware.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 13, color: context.textSecondaryColor),
            ),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.start,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Label + chips row for list-type fields.
class _ListRow extends StatelessWidget {
  final String label;
  final List<String> items;

  const _ListRow({required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: context.textSecondaryColor)),
          const SizedBox(height: AppConstants.paddingTiny),
          if (items.isEmpty)
            Text(l10n.noData, style: const TextStyle(fontSize: 14))
          else
            Wrap(
              spacing: AppConstants.paddingSmall,
              runSpacing: AppConstants.paddingTiny,
              children: items
                  .map(
                    (it) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.surfaceVariantColor,
                        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                      ),
                      child: Text(it, style: const TextStyle(fontSize: 12)),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}
