import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/trailing_arrow.dart';
import '../../../l10n/app_localizations.dart';
import 'providers/dark_mode_provider.dart';
import 'providers/language_provider.dart';
import 'widgets/about_dialog.dart';
import 'widgets/delete_account_dialog.dart';
import 'widgets/language_picker_sheet.dart';
import 'widgets/terms_dialog.dart';

/// The Settings screen.
///
/// Shows:
/// - Dark Mode toggle
/// - Language picker
/// - About dialog
/// - Terms dialog
/// - Refer to others (placeholder until share package is added)
/// - Delete Account (support-contact dialog only — no HTTP yet)
/// - App version footer
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = ref.watch(isDarkModeProvider);
    final currentLocale = ref.watch(currentLocaleProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
          children: [
            const SizedBox(height: AppConstants.paddingMedium),

            // ── Preferences ─────────────────────────────────
            _SettingsCard(
              children: [
                _SwitchTile(
                  title: l10n.darkModeLabel,
                  icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  value: isDarkMode,
                  onChanged: (v) => ref.read(darkModeProvider.notifier).setDarkMode(enabled: v),
                ),
                _ArrowTile(
                  title: l10n.languageLabel,
                  icon: Icons.language,
                  trailingLabel: _localeLabel(currentLocale, l10n),
                  onTap: () async {
                    final code = await LanguagePickerSheet.show(context);
                    if (code != null) {
                      await ref.read(languageProvider.notifier).setLanguage(code: code);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // ── About / Legal / Share ──────────────────────
            _SettingsCard(
              children: [
                _ArrowTile(
                  title: l10n.aboutUs,
                  icon: Icons.info_outline,
                  onTap: () => AboutDialogWidget.show(context),
                ),
                _ArrowTile(
                  title: l10n.termsAndConditions,
                  icon: Icons.description_outlined,
                  onTap: () => TermsDialogWidget.show(context),
                ),
                _ArrowTile(
                  title: l10n.referToOthers,
                  icon: Icons.share_outlined,
                  onTap: () => _onShare(context, l10n),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // ── Danger Zone ─────────────────────────────────
            _SettingsCard(
              children: [
                _ArrowTile(
                  title: l10n.deleteAccountButton,
                  icon: Icons.delete_outline,
                  iconColor: AppTheme.error,
                  onTap: () async {
                    final confirmed = await DeleteAccountDialog.show(context);
                    if (confirmed != true) return;
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.deleteAccountSupportMessage),
                        backgroundColor: AppTheme.warning,
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: AppConstants.paddingXLarge),
            const _VersionTile(version: AppConstants.appVersion),
            const SizedBox(height: AppConstants.paddingXLarge),
          ],
        ),
      ),
    );
  }

  /// Returns the localized language label for [locale].
  String _localeLabel(Locale locale, AppLocalizations l10n) {
    switch (locale.languageCode) {
      case AppConstants.languageCodeEn:
        return l10n.languageEnglish;
      case AppConstants.languageCodeAr:
        return l10n.languageArabic;
      default:
        return l10n.languagePersian;
    }
  }

  /// Share is not yet wired; shows a "coming soon" snackbar.
  void _onShare(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.referComingSoon)));
  }
}

// ─────────────────────────────────────────────────────────────
// Private building blocks
// ─────────────────────────────────────────────────────────────

/// A rounded card that groups a list of tiles with dividers between them.
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i < children.length - 1) {
        items.add(Divider(height: 1, color: theme.dividerColor));
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(children: items),
    );
  }
}

/// A tile with an icon, label, and a trailing [Switch].
class _SwitchTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
      title: Text(title),
      trailing: Switch(value: value, onChanged: onChanged, activeColor: AppTheme.primary),
    );
  }
}

/// A tile with an icon, label, optional trailing label, and a forward arrow.
class _ArrowTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? trailingLabel;

  /// Optional override for the leading icon color (e.g. [AppTheme.error]
  /// for destructive actions). Falls back to the theme's onSurface color.
  final Color? iconColor;

  final VoidCallback onTap;

  const _ArrowTile({
    required this.title,
    required this.icon,
    this.trailingLabel,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: iconColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.6)),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingLabel != null) ...[
            Text(
              trailingLabel!,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: AppConstants.paddingSmall),
          ],
          TrailingArrow(color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
        ],
      ),
      onTap: onTap,
    );
  }
}

/// Centered footer showing the app version and "up to date" hint.
class _VersionTile extends StatelessWidget {
  final String version;

  const _VersionTile({required this.version});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          Text(
            l10n.versionLabel(version),
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: AppConstants.paddingTiny),
          Text(
            l10n.appUpToDate,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
