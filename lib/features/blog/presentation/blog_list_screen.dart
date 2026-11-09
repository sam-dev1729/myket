import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../data/wordpress_models.dart';
import 'blog_controller.dart';

/// Blog list screen — posts with a horizontal category chip filter.
///
/// Wiring:
/// - `blogCategoriesProvider` → chip list
/// - `selectedBlogCategoryProvider` → selected chip
/// - `blogPostsControllerProvider` → paginated posts list
class BlogListScreen extends ConsumerStatefulWidget {
  const BlogListScreen({super.key});

  @override
  ConsumerState<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends ConsumerState<BlogListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - AppConstants.infiniteScrollThreshold) {
      ref.read(blogPostsControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(blogCategoriesProvider);
    final selectedCategory = ref.watch(selectedBlogCategoryProvider);
    final postsAsync = ref.watch(blogPostsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.blogScreenTitle),
        centerTitle: true,
        backgroundColor: AppTheme.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Category chips ──
            SizedBox(
              height: 52,
              child: categoriesAsync.when(
                loading: () => const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (categories) => ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.screenPadding,
                    vertical: AppConstants.paddingSmall,
                  ),
                  itemCount: categories.length + 1,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppConstants.paddingSmall),
                  itemBuilder: (context, index) {
                    // Index 0 = "All" chip.
                    final isAll = index == 0;
                    final cat = isAll ? null : categories[index - 1];
                    final id = cat?.id;
                    final label = isAll ? l10n.blogAllCategories : cat!.name;
                    final isSelected = selectedCategory == id;

                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) {
                        ref.read(selectedBlogCategoryProvider.notifier).select(id);

                      },
                      selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppTheme.primary : context.textPrimaryColor,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primary : context.appDividerColor,
                      ),
                      showCheckmark: false,
                    );
                  },
                ),
              ),
            ),

            // ── Posts list ──
            Expanded(
              child: postsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _ErrorView(
                  message: e.toString(),
                  onRetry: () => ref.read(blogPostsControllerProvider.notifier).refresh(),
                ),
                data: (data) {
                  if (data.items.isEmpty) {
                    return Center(
                      child: Text(
                        selectedCategory == null
                            ? l10n.blogPostEmpty
                            : l10n.blogCategoryEmpty,
                        style: TextStyle(color: context.textSecondaryColor),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(blogCategoriesProvider);
                      await ref.read(blogPostsControllerProvider.notifier).refresh();
                    },
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(AppConstants.screenPadding),
                      itemCount: data.items.length + (data.hasMore ? 1 : 0),
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppConstants.paddingMedium),
                      itemBuilder: (context, index) {
                        if (index >= data.items.length) {
                          return const Padding(
                            padding: EdgeInsets.all(AppConstants.paddingLarge),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final post = data.items[index];
                        return _BlogPostCard(
                          post: post,
                          onTap: () => context.push(
                            AppConstants.blogDetailRouteTemplate
                                .replaceFirst(':id', post.id.toString()),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single blog post card in the list.
class _BlogPostCard extends StatelessWidget {
  final BlogPost post;
  final VoidCallback onTap;

  const _BlogPostCard({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          border: Border.all(color: context.appDividerColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (post.featuredImageUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: post.featuredImageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: context.surfaceVariantColor,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: context.surfaceVariantColor,
                    child: Icon(Icons.image_not_supported_outlined,
                        color: context.textTertiaryColor),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.categories.isNotEmpty)
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
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  if (post.categories.isNotEmpty)
                    const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    post.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (post.excerpt.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      post.excerpt,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                    ),
                  ],
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    _formatDate(post.date),
                    style: TextStyle(fontSize: 11, color: context.textTertiaryColor),
                  ),
                ],
              ),
            ),
          ],
        ),
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

/// Error state with a retry button.
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
            const SizedBox(height: AppConstants.paddingSmall),
            Text('${l10n.genericErrorPrefix}: $message', textAlign: TextAlign.center),
            const SizedBox(height: AppConstants.paddingSmall),
            TextButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}