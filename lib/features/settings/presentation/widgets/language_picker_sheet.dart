import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/language_provider.dart';

/// Bottom sheet that lets the user pick the app language.
///
/// Pops with the selected language code (e.g. `'fa'`, `'en'`, `'ar'`),
/// or null on cancel.
class LanguagePickerSheet extends ConsumerWidget {
  const LanguagePickerSheet({super.key});

  /// Shows the picker and returns the selected language code (or null).
  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LanguagePickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currentLocale = ref.watch(currentLocaleProvider);
    final currentCode = currentLocale.languageCode;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.largeCardRadius),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  l10n.languageLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),

            _LanguageTile(
              label: l10n.languagePersian,
              selected: currentCode == AppConstants.languageCodeFa,
              enabled: true,
              onTap: () => Navigator.pop(context, AppConstants.languageCodeFa),
            ),
            _LanguageTile(
              label: l10n.languageEnglish,
              selected: currentCode == AppConstants.languageCodeEn,
              enabled: false,
              comingSoonLabel: l10n.comingSoon,
              onTap: null,
            ),
            _LanguageTile(
              label: l10n.languageArabic,
              selected: currentCode == AppConstants.languageCodeAr,
              enabled: false,
              comingSoonLabel: l10n.comingSoon,
              onTap: null,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
              child: Text(
                l10n.languageChangeHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
              child: SizedBox(
                width: double.infinity,
                height: AppConstants.financialButtonHeight,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.pillRadius),
                    ),
                  ),
                  child: Text(l10n.cancel),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
          ],
        ),
      ),
    );
  }
}

/// A single selectable language row inside [LanguagePickerSheet].
class _LanguageTile extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final String? comingSoonLabel;
  final VoidCallback? onTap;

  const _LanguageTile({
    required this.label,
    required this.selected,
    required this.enabled,
    this.comingSoonLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelColor = enabled
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withValues(alpha: 0.4);

    return ListTile(
      enabled: enabled,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: enabled
            ? (selected
                ? AppTheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.5))
            : theme.colorScheme.onSurface.withValues(alpha: 0.3),
      ),
      title: Text(label, style: TextStyle(color: labelColor)),
      trailing: !enabled && comingSoonLabel != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppConstants.pillRadius),
              ),
              child: Text(
                comingSoonLabel!,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}