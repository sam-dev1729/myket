import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:myket/features/blog/data/wordpress_models.dart';
import 'package:myket/features/blog/data/wordpress_repository.dart';
import 'package:myket/features/blog/presentation/blog_list_screen.dart';
import 'package:myket/l10n/app_localizations.dart';

import '../../helpers/test_channel_mocks.dart';
import 'wordpress_fake_repo.dart';

void main() {
  setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());
  setUp(TestChannelMocks.installAll);
  tearDown(TestChannelMocks.removeAll);

  // ─────────────────────────────────────────────────────────────
  // Rendering
  // ─────────────────────────────────────────────────────────────

  group('BlogListScreen — rendering', () {
    testWidgets('renders category chips + post cards', (tester) async {
      final fake = FakeWordPressRepository()
        ..postsPage1 = _page(1, 3, 1)
        ..categories = const [
          BlogCategory(id: 1, name: 'سلامت', count: 10),
          BlogCategory(id: 2, name: 'پزشکی', count: 5),
        ];

      await tester.pumpWidget(_app(fake));
      await tester.pumpAndSettle();

      // Category chips (including the "All" chip).
      expect(
        find.descendant(of: find.byType(ChoiceChip), matching: find.text('همه')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byType(ChoiceChip), matching: find.text('سلامت')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byType(ChoiceChip), matching: find.text('پزشکی')),
        findsOneWidget,
      );

      // Post cards.
      expect(find.text('Post 1-0'), findsOneWidget);
      expect(find.text('Post 1-1'), findsOneWidget);
      expect(find.text('Post 1-2'), findsOneWidget);
    });

    testWidgets('renders empty state when no posts exist', (tester) async {
      final fake = FakeWordPressRepository()
        ..postsPage1 = _emptyPage()
        ..categories = const [];

      await tester.pumpWidget(_app(fake));
      await tester.pumpAndSettle();

      expect(find.text('هنوز مطلبی منتشر نشده'), findsOneWidget);
      expect(find.text('Post 1-0'), findsNothing);
    });

    testWidgets('shows loading spinner on the first frame', (tester) async {
      final slow = _SlowFakeWordPressRepository();

      await tester.pumpWidget(_app(slow));

      // First frame — both repository futures are pending → spinner visible.
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      // Complete them so teardown is clean.
      slow.complete(_page(1, 1, 1), const []);
      await tester.pumpAndSettle();
    });
  });

  // ─────────────────────────────────────────────────────────────
  // Category filter
  // ─────────────────────────────────────────────────────────────

  group('BlogListScreen — category filter', () {
    testWidgets('tapping a category chip reloads posts for that category', (tester) async {
      final fake = FakeWordPressRepository()
        ..postsPage1 = _page(1, 3, 1)
        ..categories = const [BlogCategory(id: 1, name: 'سلامت', count: 1)]
        ..byCategory = {
          1: BlogPostsPage(
            items: [_postWithTitle(id: 501, title: 'Cardio Health Post')],
            page: 1,
            totalPages: 1,
            total: 1,
          ),
        };

      await tester.pumpWidget(_app(fake));
      await tester.pumpAndSettle();

      // Initially: "All" → 3 default posts.
      expect(find.text('Post 1-0'), findsOneWidget);
      expect(find.text('Cardio Health Post'), findsNothing);

      // Tap the "سلامت" chip.
      await tester.tap(find.descendant(of: find.byType(ChoiceChip), matching: find.text('سلامت')));
      await tester.pumpAndSettle();

      // Category 1 → only the "Cardio Health Post" is visible.
      expect(find.text('Post 1-0'), findsNothing);
      expect(find.text('Cardio Health Post'), findsOneWidget);
      expect(fake.lastCategoryId, 1);
    });

    testWidgets('tapping "همه" clears the filter back to all posts', (tester) async {
      final fake = FakeWordPressRepository()
        ..postsPage1 = _page(1, 2, 1)
        ..categories = const [BlogCategory(id: 1, name: 'سلامت', count: 1)]
        ..byCategory = {
          1: BlogPostsPage(
            items: [_postWithTitle(id: 501, title: 'Category Only Post')],
            page: 1,
            totalPages: 1,
            total: 1,
          ),
        };

      await tester.pumpWidget(_app(fake));
      await tester.pumpAndSettle();

      // Select category 1 first.
      await tester.tap(find.descendant(of: find.byType(ChoiceChip), matching: find.text('سلامت')));
      await tester.pumpAndSettle();
      expect(find.text('Category Only Post'), findsOneWidget);
      expect(find.text('Post 1-0'), findsNothing);

      // Tap "همه" to clear the filter.
      await tester.tap(find.descendant(of: find.byType(ChoiceChip), matching: find.text('همه')));
      await tester.pumpAndSettle();

      // Back to the default posts.
      expect(find.text('Post 1-0'), findsOneWidget);
      expect(find.text('Category Only Post'), findsNothing);
      expect(fake.lastCategoryId, isNull);
    });

    testWidgets('"همه" chip is selected by default', (tester) async {
      final fake = FakeWordPressRepository()
        ..postsPage1 = _page(1, 1, 1)
        ..categories = const [BlogCategory(id: 1, name: 'سلامت', count: 1)];

      await tester.pumpWidget(_app(fake));
      await tester.pumpAndSettle();

      final allChip = tester.widget<ChoiceChip>(
        find.ancestor(of: find.text('همه'), matching: find.byType(ChoiceChip)).first,
      );
      expect(allChip.selected, isTrue);

      final categoryChip = tester.widget<ChoiceChip>(
        find.ancestor(of: find.text('سلامت'), matching: find.byType(ChoiceChip)).first,
      );
      expect(categoryChip.selected, isFalse);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // Navigation
  // ─────────────────────────────────────────────────────────────

  group('BlogListScreen — navigation', () {
    testWidgets('tapping a post navigates to the detail route', (tester) async {
      final fake = FakeWordPressRepository()
        ..postsPage1 = _page(1, 3, 1)
        ..categories = const [];

      await tester.pumpWidget(_app(fake));
      await tester.pumpAndSettle();

      // Tap the first post (id=100).
      await tester.tap(find.text('Post 1-0'));
      await tester.pumpAndSettle();

      // Should be on the stubbed detail route.
      expect(find.text('DETAIL_SCREEN'), findsOneWidget);
      expect(find.text('post_id=100'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // Error
  // ─────────────────────────────────────────────────────────────

  group('BlogListScreen — error', () {
    testWidgets('shows error view with retry when repository throws', (tester) async {
      final fake = FakeWordPressRepository()
        ..categories = const []
        ..throwOnGetPosts = Exception('network down');

      await tester.pumpWidget(_app(fake));
      await tester.pumpAndSettle();

      // The retry button is shown by _ErrorView.
      expect(find.text('تلاش مجدد'), findsOneWidget);
      expect(find.text('Post 1-0'), findsNothing);
    });

    testWidgets('tapping retry reloads posts', (tester) async {
      final fake = FakeWordPressRepository()
        ..categories = const []
        ..throwOnGetPosts = Exception('network down');

      await tester.pumpWidget(_app(fake));
      await tester.pumpAndSettle();
      expect(find.text('تلاش مجدد'), findsOneWidget);

      // Clear the error and configure a successful response.
      fake.throwOnGetPosts = null;
      fake.postsPage1 = _page(1, 2, 1);

      await tester.tap(find.text('تلاش مجدد'));
      await tester.pumpAndSettle();

      expect(find.text('تلاش مجدد'), findsNothing);
      expect(find.text('Post 1-0'), findsOneWidget);
      expect(find.text('Post 1-1'), findsOneWidget);
    });
  });
}

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────

/// Builds a `MaterialApp.router` with a test router that maps
/// `/blog` → [BlogListScreen] and `/blog/:id` → a stub detail page.
Widget _app(FakeWordPressRepository fake) {
  final router = GoRouter(
    initialLocation: '/blog',
    routes: [
      GoRoute(path: '/blog', builder: (_, __) => const BlogListScreen()),
      GoRoute(
        path: '/blog/:id',
        builder: (_, state) => Scaffold(
          appBar: AppBar(title: const Text('DETAIL_SCREEN')),
          body: Text('post_id=${state.pathParameters['id']}'),
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [wordpressRepositoryProvider.overrideWithValue(fake)],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('fa', 'IR'),
    ),
  );
}

BlogPostsPage _page(int page, int count, int totalPages) {
  return BlogPostsPage(
    items: List.generate(count, (i) => _postWithTitle(id: page * 100 + i, title: 'Post $page-$i')),
    page: page,
    totalPages: totalPages,
    total: count * totalPages,
  );
}

BlogPostsPage _emptyPage() => const BlogPostsPage(items: [], page: 1, totalPages: 1, total: 0);

BlogPost _postWithTitle({required int id, required String title}) => BlogPost(
  id: id,
  title: title,
  excerpt: 'Excerpt $id',
  content: '<p>Content $id</p>',
  date: '2026-01-15T10:00:00',
  categoryIds: const [],
  categories: const [],
);

/// Fake repository whose futures stay pending until [complete] is called.
/// Used to test the initial loading spinner.
class _SlowFakeWordPressRepository extends FakeWordPressRepository {
  final Completer<BlogPostsPage> _postsCompleter = Completer();
  final Completer<List<BlogCategory>> _catsCompleter = Completer();

  void complete(BlogPostsPage posts, List<BlogCategory> categories) {
    if (!_postsCompleter.isCompleted) _postsCompleter.complete(posts);
    if (!_catsCompleter.isCompleted) _catsCompleter.complete(categories);
  }

  @override
  Future<BlogPostsPage> getPosts({int page = 1, int perPage = 10, int? categoryId}) {
    return _postsCompleter.future;
  }

  @override
  Future<List<BlogCategory>> getCategories() {
    return _catsCompleter.future;
  }
}
