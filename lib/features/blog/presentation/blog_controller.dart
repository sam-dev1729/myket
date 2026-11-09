import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../data/wordpress_models.dart';
import '../data/wordpress_repository.dart';

// ─────────────────────────────────────────────────────────────
// Categories
// ─────────────────────────────────────────────────────────────

/// FutureProvider that loads the full category list once per session.
///
/// Invalidated by pull-to-refresh on the blog list screen.
final blogCategoriesProvider = FutureProvider<List<BlogCategory>>((ref) async {
  return ref.watch(wordpressRepositoryProvider).getCategories();
});



// ─────────────────────────────────────────────────────────────
// Posts
// ─────────────────────────────────────────────────────────────

/// Aggregated state for the paginated blog list.
class BlogPostsState {
  final List<BlogPost> items;
  final int page;
  final int totalPages;
  final int total;
  final bool isLoadingMore;

  /// The category this page belongs to (matches the request).
  final int? categoryId;

  const BlogPostsState({
    this.items = const [],
    required this.page,
    required this.totalPages,
    required this.total,
    this.isLoadingMore = false,
    this.categoryId,
  });

  bool get hasMore => page < totalPages;

  BlogPostsState copyWith({
    List<BlogPost>? items,
    int? page,
    int? totalPages,
    int? total,
    bool? isLoadingMore,
    int? categoryId,
  }) => BlogPostsState(
    items: items ?? this.items,
    page: page ?? this.page,
    totalPages: totalPages ?? this.totalPages,
    total: total ?? this.total,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    categoryId: categoryId ?? this.categoryId,
  );
}

/// Paginated controller for `GET /posts`.
///
/// Watches [selectedBlogCategoryProvider] — changing the category
/// auto-rebuilds the controller (page 1 for the new filter).
class BlogPostsController extends AsyncNotifier<BlogPostsState> {
  @override
  Future<BlogPostsState> build() async {
    final categoryId = ref.watch(selectedBlogCategoryProvider);
    return _loadFirstPage(categoryId);
  }

  Future<BlogPostsState> _loadFirstPage(int? categoryId) async {
    final page = await ref
        .watch(wordpressRepositoryProvider)
        .getPosts(page: 1, perPage: AppConstants.blogPostsPerPage, categoryId: categoryId);
    return BlogPostsState(
      items: page.items,
      page: page.page,
      totalPages: page.totalPages,
      total: page.total,
      categoryId: categoryId,
    );
  }

  /// Reloads page 1 for the current category.
  Future<void> refresh() async {
    final categoryId = state.value?.categoryId;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadFirstPage(categoryId));
  }

  /// Loads the next page and appends it.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));

    try {
      final next = await ref
          .read(wordpressRepositoryProvider)
          .getPosts(
            page: current.page + 1,
            perPage: AppConstants.blogPostsPerPage,
            categoryId: current.categoryId,
          );
      state = AsyncValue.data(
        current.copyWith(
          items: [...current.items, ...next.items],
          page: next.page,
          totalPages: next.totalPages,
          total: next.total,
          isLoadingMore: false,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.data(current.copyWith(isLoadingMore: false));
      Error.throwWithStackTrace(e, st);
    }
  }
}

/// Riverpod provider for [BlogPostsController].
final blogPostsControllerProvider = AsyncNotifierProvider<BlogPostsController, BlogPostsState>(
  BlogPostsController.new,
);

// ─────────────────────────────────────────────────────────────
// Detail
// ─────────────────────────────────────────────────────────────

/// FutureProvider family for a single blog post detail.
final blogPostDetailProvider = FutureProvider.family<BlogPost, int>((ref, id) async {
  return ref.watch(wordpressRepositoryProvider).getPost(id);
});

// ─────────────────────────────────────────────────────────────
// Selected category (replaces legacy StateProvider — removed in
// Riverpod 3 from the main exports)
// ─────────────────────────────────────────────────────────────

/// Notifier for the currently selected blog category.
///
/// `state == null` means "All categories".
class SelectedBlogCategoryNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  /// Sets the selected category (`null` = All).
  void select(int? categoryId) {
    state = categoryId;
  }

  /// Clears the filter (returns to "All").
  void clear() {
    state = null;
  }
}

/// Riverpod provider for [SelectedBlogCategoryNotifier].
final selectedBlogCategoryProvider = NotifierProvider<SelectedBlogCategoryNotifier, int?>(
  SelectedBlogCategoryNotifier.new,
);
