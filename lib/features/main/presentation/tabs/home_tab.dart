import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/trailing_arrow.dart';
import '../../../../l10n/app_localizations.dart';

/// The home tab showing the two main diagnostic features (blood & urine,
/// genetic) plus a preview of the latest blog posts.
class HomeTab extends StatelessWidget {
  /// Creates a [HomeTab] instance.
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopIconBar(
              onNotificationsTap: () => context.push(AppConstants.notificationsRoute),
              onSupportTap: () => context.push(AppConstants.supportRoute),
              onSettingsTap: () => context.push(AppConstants.settingsRoute),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppConstants.paddingMedium),
                    _FeatureCard(
                      title: l10n.bloodAndUrineTest,
                      subtitle: l10n.noActivePackage,
                      icon: Icons.science_outlined,
                      iconColor: AppTheme.error,
                      backgroundColor: context.softRedBg,
                      borderColor: context.softRedBd,
                      isActive: false,
                      onTap: () => context.push(AppConstants.uploadLabTestRoute),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    _FeatureCard(
                      title: l10n.geneticTest,
                      subtitle: l10n.noActivePackage,
                      icon: Icons.biotech_outlined,
                      iconColor: AppTheme.info,
                      backgroundColor: context.surfaceVariantColor,
                      borderColor: Colors.transparent,
                      isActive: false,
                      onTap: () => _showComingSoon(context, l10n),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _SeeAllRow(
                      label: l10n.seeAllFeatures,
                      onTap: () => _showComingSoon(context, l10n),
                    ),
                    const SizedBox(height: AppConstants.paddingXLarge),
                    _SectionTitle(title: l10n.blog, alignment: Alignment.centerRight),
                    const SizedBox(height: AppConstants.paddingMedium),
                    _BlogCard(
                      title: 'تشخیص داروی شیمی درمانی موثر برای مبتلایان به سرطان',
                      date: '',
                      tags: '',
                      description: 'جدیدترین مقالات سلامت را در وبلاگ مدیک متاورس ببینید.',
                      imageColor: AppTheme.info,
                      onTap: () => context.push(AppConstants.blogListRoute),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    _BlogCard(
                      title: 'آخرین یافته‌های علمی در حوزه سلامت',
                      date: '',
                      tags: '',
                      description: 'برای مشاهده همه مطالب روی این کارت بزنید.',
                      imageColor: AppTheme.warning,
                      onTap: () => context.push(AppConstants.blogListRoute),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),

                    _SeeAllRow(
                      label: l10n.seeAllPosts,
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

  /// Displays a "coming soon" snackbar for placeholder features.
  void _showComingSoon(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
  }
}

/// The top icon bar of the home tab.
class _TopIconBar extends StatelessWidget {
  /// Called when the notifications icon is tapped.
  final VoidCallback onNotificationsTap;

  /// Called when the support icon is tapped.
  final VoidCallback onSupportTap;

  /// Called when the settings icon is tapped.
  final VoidCallback onSettingsTap;

  const _TopIconBar({
    required this.onNotificationsTap,
    required this.onSupportTap,
    required this.onSettingsTap,
  });

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
            onTap: onNotificationsTap,
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

/// A large feature card.
class _FeatureCard extends StatelessWidget {
  /// Card title.
  final String title;

  /// Card subtitle.
  final String subtitle;

  /// Leading icon (currently unused but kept for future expansion).
  final IconData icon;

  /// Accent color for the icon container.
  final Color iconColor;

  /// Card background color.
  final Color backgroundColor;

  /// Card border color.
  final Color borderColor;

  /// Whether the feature is currently active.
  final bool isActive;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.isActive,
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
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingTiny),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isActive ? AppTheme.success : context.textTertiaryColor,
                    ),
                  ),
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
              child: Icon(icon, color: iconColor, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}

/// A right-aligned "see all" link using [TrailingArrow].
class _SeeAllRow extends StatelessWidget {
  /// Text to display.
  final String label;

  /// Called when the row is tapped.
  final VoidCallback onTap;

  const _SeeAllRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.start,
              style: TextStyle(fontWeight: FontWeight.bold, color: context.textPrimaryColor),
            ),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          TrailingArrow(color: context.textPrimaryColor, size: 20),
        ],
      ),
    );
  }
}

/// A right-aligned section title.
class _SectionTitle extends StatelessWidget {
  /// Text to display.
  final String title;

  /// Alignment of the title within its parent.
  final Alignment alignment;

  const _SectionTitle({required this.title, required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: context.textPrimaryColor,
        ),
      ),
    );
  }
}

class _BlogCard extends StatelessWidget {
  final String title;
  final String date;
  final String tags;
  final String description;
  final Color imageColor;
  final VoidCallback onTap;

  const _BlogCard({
    required this.title,
    required this.date,
    required this.tags,
    required this.description,
    required this.imageColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              width: AppConstants.blogCardImageSize,
              height: AppConstants.blogCardImageSize,
              decoration: BoxDecoration(
                color: imageColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Icon(Icons.image_outlined, color: imageColor, size: 32),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: context.textPrimaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.paddingTiny),
                  Text(
                    '$date . $tags',
                    style: TextStyle(color: context.textTertiaryColor, fontSize: 11),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    description,
                    textAlign: TextAlign.right,
                    style: TextStyle(color: context.textSecondaryColor, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
