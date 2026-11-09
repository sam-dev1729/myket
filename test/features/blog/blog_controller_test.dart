import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myket/features/blog/data/wordpress_models.dart';
import 'package:myket/features/blog/data/wordpress_repository.dart';
import 'package:myket/features/blog/presentation/blog_controller.dart';

import '../../helpers/test_channel_mocks.dart';
import 'wordpress_fake_repo.dart';

void main() {
  setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());
  setUp(TestChannelMocks.installAll);
  tearDown(TestChannelMocks.removeAll);

  // ─────────────────────────────────────────────────────────────
  // BlogPostsController
  // ─────────────────────────────────────────────────────────────

  group('blogPostsControllerProvider', () {
    test('initial state loads page 1 with no category', () async {
      // 3 posts on page 1, and exactly 3 pages total — matches the
      // assertions below (`totalPages == 3`, `hasMore == true`).
      final fake = FakeWordPressRepository()..postsPage1 = _page(1, 3, 3);
      final container = _container(fake);
      addTearDown(container.dispose);

      await container.read(blogPostsControllerProvider.future);

      final state = container.read(blogPostsControllerProvider).value!;
      expect(state.items, hasLength(3));
      expect(state.page, 1);
      expect(state.totalPages, 3);
      expect(state.hasMore, isTrue);
      expect(state.categoryId, isNull);
      expect(fake.lastCategoryId, isNull);
      expect(fake.lastPage, 1);
    });

    test('loadMore appends page 2', () async {
      // Page 1 has 10 posts, page 2 has 5 posts, and there are exactly
      // 2 pages total → `hasMore` must become `false` after loadMore.
      final fake = FakeWordPressRepository()
        ..postsPage1 = _page(1, 10, 2)
        ..postsPage2 = _page(2, 5, 2);
      final container = _container(fake);
      addTearDown(container.dispose);

      await container.read(blogPostsControllerProvider.future);
      await container.read(blogPostsControllerProvider.notifier).loadMore();

      final state = container.read(blogPostsControllerProvider).value!;
      expect(state.items, hasLength(15));
      expect(state.page, 2);
      expect(state.totalPages, 2);
      expect(state.hasMore, isFalse);
    });

    test('loadMore is a no-op when no more pages', () async {
      final fake = FakeWordPressRepository()..postsPage1 = _page(1, 3, 1);
      final container = _container(fake);
      addTearDown(container.dispose);

      await container.read(blogPostsControllerProvider.future);
      await container.read(blogPostsControllerProvider.notifier).loadMore();

      // No new page requested — fake would have thrown otherwise.
      final state = container.read(blogPostsControllerProvider).value!;
      expect(state.items, hasLength(3));
      expect(state.page, 1);
    });

    test('refresh reloads page 1 for the current category', () async {
      final fake = FakeWordPressRepository()..postsPage1 = _page(1, 5, 10);
      final container = _container(fake);
      addTearDown(container.dispose);

      await container.read(blogPostsControllerProvider.future);
      await container.read(blogPostsControllerProvider.notifier).refresh();

      final state = container.read(blogPostsControllerProvider).value!;
      expect(state.items, hasLength(5));
      expect(state.page, 1);
      expect(fake.lastPage, 1);
    });

    test('changing category rebuilds controller with new categoryId', () async {
      final fake = FakeWordPressRepository()..postsPage1 = _page(1, 3, 20);
      final container = _container(fake);
      addTearDown(container.dispose);

      // Initial load (All categories).
      await container.read(blogPostsControllerProvider.future);
      expect(container.read(blogPostsControllerProvider).value!.categoryId, isNull);
      expect(fake.lastCategoryId, isNull);

      // Switch to category 42 and wait for the rebuild.
      final completer = Completer<void>();
      final sub = container.listen<AsyncValue<BlogPostsState>>(blogPostsControllerProvider, (
        prev,
        next,
      ) {
        if (next is AsyncData && next.value?.categoryId == 42 && !completer.isCompleted) {
          completer.complete();
        }
      });
      addTearDown(sub.close);

      container.read(selectedBlogCategoryProvider.notifier).select(42);

      await completer.future.timeout(
        TestChannelConstants.providerSettleTimeout,
        onTimeout: () => fail(
          'Provider did not rebuild with categoryId=42. '
          'Current state: ${container.read(blogPostsControllerProvider)}',
        ),
      );

      final newState = container.read(blogPostsControllerProvider).value!;
      expect(newState.categoryId, 42);
      expect(fake.lastCategoryId, 42);
    });

    test('error from repository → AsyncError', () async {
      final fake = FakeWordPressRepository()..throwOnGetPosts = Exception('network down');
      final container = _container(fake);
      addTearDown(container.dispose);

      await expectLater(
        container.read(blogPostsControllerProvider.future),
        throwsA(isA<Exception>()),
      );
      expect(container.read(blogPostsControllerProvider), isA<AsyncError>());
    });
  });

  // ─────────────────────────────────────────────────────────────
  // SelectedBlogCategoryNotifier
  // ─────────────────────────────────────────────────────────────

  group('selectedBlogCategoryProvider', () {
    test('starts with null (All)', () {
      final container = _container(FakeWordPressRepository());
      addTearDown(container.dispose);

      expect(container.read(selectedBlogCategoryProvider), isNull);
    });

    test('select updates the state', () {
      final container = _container(FakeWordPressRepository());
      addTearDown(container.dispose);

      container.read(selectedBlogCategoryProvider.notifier).select(7);
      expect(container.read(selectedBlogCategoryProvider), 7);
    });

    test('clear returns to null', () {
      final container = _container(FakeWordPressRepository());
      addTearDown(container.dispose);

      container.read(selectedBlogCategoryProvider.notifier).select(7);
      container.read(selectedBlogCategoryProvider.notifier).clear();
      expect(container.read(selectedBlogCategoryProvider), isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // blogPostDetailProvider
  // ─────────────────────────────────────────────────────────────

  group('blogPostDetailProvider', () {
    test('loads a single post by id', () async {
      final fake = FakeWordPressRepository()..post = _singlePost(id: 101, title: 'Detail Title');
      final container = _container(fake);
      addTearDown(container.dispose);

      final post = await container.read(blogPostDetailProvider(101).future);

      expect(post.id, 101);
      expect(post.title, 'Detail Title');
    });

    test('error from repository → AsyncError', () async {
      final fake = FakeWordPressRepository()..throwOnGetPost = Exception('not found');
      final container = _container(fake);
      addTearDown(container.dispose);

      await expectLater(
        container.read(blogPostDetailProvider(1).future),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ─────────────────────────────────────────────────────────────
  // blogCategoriesProvider
  // ─────────────────────────────────────────────────────────────

  group('blogCategoriesProvider', () {
    test('loads the categories list', () async {
      final fake = FakeWordPressRepository()
        ..categories = const [
          BlogCategory(id: 1, name: 'سلامت', count: 10),
          BlogCategory(id: 2, name: 'پزشکی', count: 5),
        ];
      final container = _container(fake);
      addTearDown(container.dispose);

      final cats = await container.read(blogCategoriesProvider.future);

      expect(cats, hasLength(2));
      expect(cats.first.name, 'سلامت');
    });

    test('empty categories list is allowed', () async {
      final fake = FakeWordPressRepository()..categories = const [];
      final container = _container(fake);
      addTearDown(container.dispose);

      final cats = await container.read(blogCategoriesProvider.future);

      expect(cats, isEmpty);
    });
  });
}

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────

ProviderContainer _container(FakeWordPressRepository fake) => ProviderContainer(
  overrides: [wordpressRepositoryProvider.overrideWithValue(fake)],
  retry: TestChannelMocks.disabledRetry,
);

BlogPostsPage _page(int page, int count, int totalPages) {
  return BlogPostsPage(
    items: List.generate(
      count,
      (i) => BlogPost(
        id: page * 100 + i,
        title: 'Post $page-$i',
        excerpt: 'Excerpt $page-$i',
        content: '<p>Content $page-$i</p>',
        date: '2026-01-15T10:00:00',
        categoryIds: const [],
        categories: const [],
      ),
    ),
    page: page,
    totalPages: totalPages,
    total: count * totalPages,
  );
}

BlogPost _singlePost({required int id, required String title}) => BlogPost(
  id: id,
  title: title,
  excerpt: 'Excerpt',
  content: '<p>Content</p>',
  date: '2026-01-15T10:00:00',
  categoryIds: const [],
  categories: const [],
);
