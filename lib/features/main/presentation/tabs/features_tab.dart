import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/trailing_arrow.dart';
import '../../../../l10n/app_localizations.dart';

/// The "Features" tab listing every feature available in the app.
class FeaturesTab extends StatelessWidget {
  /// Creates a [FeaturesTab] instance.
  const FeaturesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopIconBar(
              onSupportTap: () => context.push(AppConstants.supportRoute),
              onSettingsTap: () => context.push(AppConstants.settingsRoute),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppConstants.paddingMedium),
                    _FeatureCard(
                      title: l10n.bloodAndUrineTest,
                      subtitle: l10n.activePackage,
                      subtitleColor: AppTheme.success,
                      icon: Icons.science_outlined,
                      iconColor: AppTheme.error,
                      backgroundColor: context.softBlueBg,
                      borderColor: AppTheme.info.withValues(alpha: 0.3),
                      onTap: () => context.push(AppConstants.uploadLabTestRoute),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    _FeatureCard(
                      title: l10n.geneticTest,
                      subtitle: l10n.noActivePackage,
                      subtitleColor: context.textTertiaryColor,
                      icon: Icons.biotech_outlined,
                      iconColor: AppTheme.info,
                      backgroundColor: context.surfaceVariantColor,
                      borderColor: Colors.transparent,
                      onTap: () => _showComingSoon(context, l10n),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    _FeatureCard(
                      title: l10n.geneticGenealogy,
                      subtitle: l10n.comingSoon,
                      subtitleColor: context.textTertiaryColor,
                      icon: Icons.people_outline,
                      iconColor: context.textTertiaryColor,
                      backgroundColor: context.surfaceVariantColor,
                      borderColor: Colors.transparent,
                      onTap: () => _showComingSoon(context, l10n),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    _FeatureCard(
                      title: l10n.drugInteraction,
                      subtitle: l10n.comingSoon,
                      subtitleColor: context.textTertiaryColor,
                      icon: Icons.medication_outlined,
                      iconColor: context.textTertiaryColor,
                      backgroundColor: context.surfaceVariantColor,
                      borderColor: Colors.transparent,
                      onTap: () => _showComingSoon(context, l10n),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    _FeatureCard(
                      title: l10n.aiDoctor,
                      subtitle: l10n.comingSoon,
                      subtitleColor: context.textTertiaryColor,
                      icon: Icons.medical_services_outlined,
                      iconColor: context.textTertiaryColor,
                      backgroundColor: context.surfaceVariantColor,
                      borderColor: Colors.transparent,
                      onTap: () => _showComingSoon(context, l10n),
                    ),
                    const SizedBox(height: AppConstants.paddingXLarge),
                    _FeatureCard(
                      title: l10n.blogTitle,
                      subtitle: l10n.seeAllPosts,
                      subtitleColor: context.textSecondaryColor,
                      icon: Icons.article_outlined,
                      iconColor: AppTheme.info,
                      backgroundColor: context.surfaceVariantColor,
                      borderColor: Colors.transparent,
                      onTap: () => context.push(AppConstants.blogListRoute),
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

  /// Displays a "coming soon" snackbar.
  void _showComingSoon(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
  }
}

/// The top icon bar of the features tab.
class _TopIconBar extends StatelessWidget {
  /// Called when the support icon is tapped.
  final VoidCallback onSupportTap;

  /// Called when the settings icon is tapped.
  final VoidCallback onSettingsTap;

  const _TopIconBar({required this.onSupportTap, required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.screenPadding,
        vertical: AppConstants.paddingMedium,
      ),
      child: Row(
        children: [
          _CircleIconButton(icon: Icons.headset_mic_outlined, onTap: onSupportTap),
          const SizedBox(width: AppConstants.paddingSmall),
          _CircleIconButton(icon: Icons.settings_outlined, onTap: onSettingsTap),
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
  /// The icon to display.
  final IconData icon;

  /// Called when the button is tapped.
  final VoidCallback onTap;

  /// Whether to display a small red badge in the top-end corner.
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
            Center(child: Icon(icon, color: context.iconColor, size: 20)),
            if (showBadge)
              PositionedDirectional(
                top: 8,
                end: 8,
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

/// A feature card with a leading arrow on the trailing side.
class _FeatureCard extends StatelessWidget {
  /// Card title.
  final String title;

  /// Card subtitle.
  final String subtitle;

  /// Subtitle color.
  final Color subtitleColor;

  /// Icon to display inside the icon container.
  final IconData icon;

  /// Accent color for the icon.
  final Color iconColor;

  /// Card background color.
  final Color backgroundColor;

  /// Card border color.
  final Color borderColor;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.subtitleColor,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          children: [
            // Trailing arrow (left in RTL, right in LTR).
            TrailingArrow(color: context.iconColor, size: 20),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingTiny),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: subtitleColor)),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Container(
              width: AppConstants.iconContainerSize,
              height: AppConstants.iconContainerSize,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
          ],
        ),
      ),
    );
  }
}
