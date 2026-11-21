import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/trailing_arrow.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../blog/data/wordpress_models.dart';
import '../../../blog/presentation/blog_controller.dart';

/// The home tab showing the two main diagnostic features (blood & urine,
/// genetic) plus a preview of the latest blog posts.
class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final postsAsync = ref.watch(blogPostsControllerProvider);

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
                      onTap: () => context.push(AppConstants.bloodTestsRoute),
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

                    // 👇 نمایش داینامیک مطالب بلاگ با اسکلتون لودینگ
                    postsAsync.when(
                      loading: () =>
                          const Column(children: [_SkeletonBlogCard(), _SkeletonBlogCard()]),
                      error: (e, _) => Center(
                        child: Text(
                          l10n.blogLoadMoreFailed,
                          style: TextStyle(color: context.textSecondaryColor),
                        ),
                      ),
                      data: (data) {
                        if (data.items.isEmpty) {
                          return Center(
                            child: Text(
                              l10n.blogPostEmpty,
                              style: TextStyle(color: context.textSecondaryColor),
                            ),
                          );
                        }

                        final latestPosts = data.items.take(2).toList();

                        return Column(
                          children: latestPosts.map((post) {
                            return _BlogCard(
                              post: post,
                              onTap: () => context.push(
                                AppConstants.blogDetailRouteTemplate.replaceFirst(
                                  ':id',
                                  post.id.toString(),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
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

  void _showComingSoon(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
  }
}

/// ... (کلاس‌های _TopIconBar, _CircleIconButton, _FeatureCard, _SeeAllRow, _SectionTitle بدون تغییر هستند) ...

class _TopIconBar extends StatelessWidget {
  final VoidCallback onNotificationsTap;
  final VoidCallback onSupportTap;
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

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final bool isActive;
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
            Container(
              width: AppConstants.iconContainerSize,
              height: AppConstants.iconContainerSize,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
            TrailingArrow(color: context.iconColor, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SeeAllRow extends StatelessWidget {
  final String label;
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

class _SectionTitle extends StatelessWidget {
  final String title;
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

/// A blog post card that displays real data from the WordPress API.
class _BlogCard extends StatelessWidget {
  final BlogPost post;
  final VoidCallback onTap;

  const _BlogCard({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
              width: AppConstants.blogCardImageSize,
              height: AppConstants.blogCardImageSize,
              decoration: BoxDecoration(
                color: context.surfaceVariantColor,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              clipBehavior: Clip.antiAlias,

              child: post.featuredImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: post.featuredImageUrl!,
                      fit: BoxFit.cover,
                      memCacheWidth: 300, // بهینه‌سازی
                      fadeInDuration: const Duration(milliseconds: 400),
                      fadeOutDuration: const Duration(milliseconds: 400),
                      placeholder: (_, _) => Container(color: context.surfaceVariantColor),
                      errorWidget: (_, _, _) => Icon(
                        Icons.image_not_supported_outlined,
                        color: context.textTertiaryColor,
                      ),
                    )
                  : Icon(Icons.article_outlined, color: context.textTertiaryColor, size: 32),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    post.title,
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
                    _formatDate(post.date),
                    style: TextStyle(color: context.textTertiaryColor, fontSize: 11),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    post.excerpt,
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

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final j = Jalali.fromDateTime(dt);
      return '${j.day} ${j.formatter.mN} ${j.year}';
    } catch (_) {
      return iso;
    }
  }
}

/// 👇 اسکلتون لودینگ با انیمیشن پالسی (Pulse) برای حالت لودینگ
class _SkeletonBlogCard extends StatefulWidget {
  const _SkeletonBlogCard();

  @override
  State<_SkeletonBlogCard> createState() => _SkeletonBlogCardState();
}

class _SkeletonBlogCardState extends State<_SkeletonBlogCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: AppConstants.blogCardImageSize,
                height: AppConstants.blogCardImageSize,
                decoration: BoxDecoration(
                  color: context.surfaceVariantColor.withValues(
                    alpha: 0.5 + (_controller.value * 0.5),
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              );
            },
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final color = context.surfaceVariantColor.withValues(
                      alpha: 0.5 + (_controller.value * 0.5),
                    );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(height: 16, width: double.infinity, color: color),
                        const SizedBox(height: 8),
                        Container(height: 16, width: 150, color: color),
                        const SizedBox(height: 8),
                        Container(height: 12, width: 80, color: color),
                        const SizedBox(height: 8),
                        Container(height: 12, width: double.infinity, color: color),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
