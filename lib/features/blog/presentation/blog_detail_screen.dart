import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/utils/url_launcher_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../data/wordpress_models.dart';
import 'blog_controller.dart';

/// Blog detail screen — renders a single WordPress post's HTML content.
///
/// Uses `blogPostDetailProvider(postId)` (a `FutureProvider.family`) so
/// re-entering the same post hits the Riverpod cache.
class BlogDetailScreen extends ConsumerWidget {
  /// The WordPress post ID.
  final int postId;

  const BlogDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncPost = ref.watch(blogPostDetailProvider(postId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.blogDetailTitle),
        centerTitle: true,
        backgroundColor: AppTheme.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: asyncPost.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.screenPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text('${l10n.genericErrorPrefix}: $e', textAlign: TextAlign.center),
                  const SizedBox(height: AppConstants.paddingSmall),
                  TextButton(
                    onPressed: () => ref.invalidate(blogPostDetailProvider(postId)),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          ),
          data: (post) => _BlogPostBody(post: post, l10n: l10n),
        ),
      ),
    );
  }
}

/// Renders the post's featured image, title, metadata, and HTML content.
class _BlogPostBody extends StatelessWidget {
  final BlogPost post;
  final AppLocalizations l10n;

  const _BlogPostBody({required this.post, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.featuredImageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.cardRadius),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: post.featuredImageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: context.surfaceVariantColor),
                  errorWidget: (_, __, ___) => Container(
                    color: context.surfaceVariantColor,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: context.textTertiaryColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
          ],

          // Title
          Text(
            post.title,
            style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppConstants.paddingSmall),

          // Date + categories
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: context.textTertiaryColor),
              const SizedBox(width: 4),
              Text(
                _formatDate(post.date),
                style: TextStyle(fontSize: 12, color: context.textTertiaryColor),
              ),
            ],
          ),
          if (post.categories.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingSmall),
            Wrap(
              spacing: AppConstants.paddingSmall,
              runSpacing: 4,
              children: post.categories
                  .map(
                    (c) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        c.name,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],

          const Divider(height: AppConstants.paddingXLarge),

          // HTML content
          Html(
            data: post.content,
            style: {
              'body': Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                fontSize: FontSize(14),
                color: context.textPrimaryColor,
                lineHeight: const LineHeight(1.7),
              ),
              'p': Style(margin: Margins.only(bottom: 8)),
              'h1': Style(fontSize: FontSize(22), color: context.textPrimaryColor),
              'h2': Style(fontSize: FontSize(20), color: context.textPrimaryColor),
              'h3': Style(fontSize: FontSize(18), color: context.textPrimaryColor),
              'a': Style(color: AppTheme.info, textDecoration: TextDecoration.underline),
              'img': Style(width: Width(100, Unit.percent)),
              'blockquote': Style(
                margin: Margins.symmetric(vertical: 8),
                padding: HtmlPaddings.only(left: 12),
                border: Border(left: BorderSide(color: AppTheme.primary, width: 3)),
              ),
            },
            onLinkTap: (url, attributes, element) {
              if (url != null && url.isNotEmpty) {
                UrlLauncherHelper.openExternal(url);
              }
            },
          ),

          const SizedBox(height: AppConstants.paddingXLarge),
        ],
      ),
    );
  }

  /// Formats an ISO date string as a Jalali long date.
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
