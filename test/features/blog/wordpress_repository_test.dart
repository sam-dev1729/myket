import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myket/features/blog/data/wordpress_repository.dart';

void main() {
  // ─────────────────────────────────────────────────────────────
  // getPosts
  // ─────────────────────────────────────────────────────────────

  group('WordPressRepository.getPosts — parsing', () {
    test('parses a full post with _embed (title, image, categories)', () async {
      final repo = _repoWith((options) {
        if (options.path == 'posts') {
          return _jsonArray(
            200,
            [_fullPostJson()],
            headers: {'x-wp-totalpages': '3', 'x-wp-total': '25'},
          );
        }
        return _jsonArray(404, []);
      });

      final page = await repo.getPosts();

      expect(page.items, hasLength(1));
      final post = page.items.first;
      expect(post.id, 101);
      expect(post.title, 'سلامت قلب');
      expect(post.excerpt, 'نکات مهم برای سلامت قلب');
      expect(post.content, contains('محتوای کامل'));
      expect(post.featuredImageUrl, 'https://cdn.example.com/hero.jpg');
      expect(post.categoryIds, [5, 7]);
      expect(post.categories, hasLength(2));
      expect(post.categories.map((c) => c.name), ['قلب', 'تغذیه']);

      expect(page.page, 1);
      expect(page.totalPages, 3);
      expect(page.total, 25);
      expect(page.hasMore, isTrue);
    });

    test('parses a minimal post without _embed gracefully', () async {
      final repo = _repoWith((options) {
        if (options.path == 'posts') {
          return _jsonArray(200, [_minimalPostJson()]);
        }
        return _jsonArray(404, []);
      });

      final page = await repo.getPosts();

      expect(page.items, hasLength(1));
      final post = page.items.first;
      expect(post.featuredImageUrl, isNull);
      expect(post.categories, isEmpty);
      expect(post.categoryIds, [5]);
      expect(post.title, 'No Embed Post');
    });

    test('falls back to media_details.sizes.full when source_url missing', () async {
      final repo = _repoWith((options) {
        if (options.path == 'posts') {
          return _jsonArray(200, [_postWithDeepImage()]);
        }
        return _jsonArray(404, []);
      });

      final page = await repo.getPosts();

      expect(page.items.first.featuredImageUrl, 'https://cdn.example.com/full.jpg');
    });

    test('decodes HTML entities in excerpt', () async {
      final repo = _repoWith((options) {
        if (options.path == 'posts') {
          return _jsonArray(200, [_postWithExcerpt('Hello&nbsp;world &amp; friends &#8211; test')]);
        }
        return _jsonArray(404, []);
      });

      final page = await repo.getPosts();

      expect(page.items.first.excerpt, 'Hello world & friends – test');
    });

    test('strips HTML tags from excerpt', () async {
      final repo = _repoWith((options) {
        if (options.path == 'posts') {
          return _jsonArray(200, [_postWithExcerpt('<p>Real <strong>text</strong> here</p>')]);
        }
        return _jsonArray(404, []);
      });

      final page = await repo.getPosts();

      expect(page.items.first.excerpt, 'Real text here');
    });

    test('uses default totalPages when header missing', () async {
      final repo = _repoWith((options) {
        if (options.path == 'posts') {
          return _jsonArray(200, [_minimalPostJson()]); // no headers
        }
        return _jsonArray(404, []);
      });

      final page = await repo.getPosts();

      expect(page.totalPages, 1);
      expect(page.total, 1);
      expect(page.hasMore, isFalse);
    });
  });

  group('WordPressRepository.getPosts — behaviour', () {
    test('WordPress 400 (invalid page) returns empty page, not error', () async {
      final repo = _repoWith((options) {
        return _jsonArray(400, [
          {'code': 'rest_post_invalid_page_number', 'message': 'Invalid page'},
        ]);
      });

      final page = await repo.getPosts(page: 99);

      expect(page.items, isEmpty);
      expect(page.totalPages, 0);
      expect(page.hasMore, isFalse);
    });

    test('500 throws DioException', () async {
      final repo = _repoWith((options) {
        return _jsonArray(500, [
          {'error': 'server down'},
        ]);
      });

      await expectLater(repo.getPosts(), throwsA(isA<DioException>()));
    });

    test('passes categoryId as ?categories= query param', () async {
      Object? capturedCategories;
      final repo = _repoWith((options) {
        if (options.path == 'posts') {
          capturedCategories = options.queryParameters['categories'];
          return _jsonArray(200, [_minimalPostJson()]);
        }
        return _jsonArray(404, []);
      });

      await repo.getPosts(categoryId: 42);

      expect(capturedCategories, 42);
    });

    test('passes per_page and _embed query params', () async {
      Map<String, dynamic>? capturedQuery;
      final repo = _repoWith((options) {
        if (options.path == 'posts') {
          capturedQuery = options.queryParameters;
          return _jsonArray(200, [_minimalPostJson()]);
        }
        return _jsonArray(404, []);
      });

      await repo.getPosts(page: 2, perPage: 5);

      expect(capturedQuery?['page'], 2);
      expect(capturedQuery?['per_page'], 5);
      expect(capturedQuery?['_embed'], 1);
      expect(capturedQuery?['categories'], isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // getPost
  // ─────────────────────────────────────────────────────────────

  group('WordPressRepository.getPost', () {
    test('returns a single parsed post', () async {
      final repo = _repoWith((options) {
        if (options.path == 'posts/101') {
          return _jsonObject(200, _fullPostJson());
        }
        return _jsonArray(404, []);
      });

      final post = await repo.getPost(101);

      expect(post.id, 101);
      expect(post.title, 'سلامت قلب');
      expect(post.featuredImageUrl, 'https://cdn.example.com/hero.jpg');
    });
  });

  // ─────────────────────────────────────────────────────────────
  // getCategories
  // ─────────────────────────────────────────────────────────────

  group('WordPressRepository.getCategories', () {
    test('parses the categories list', () async {
      final repo = _repoWith((options) {
        if (options.path == 'categories') {
          return _jsonArray(200, [
            {'id': 1, 'name': 'سلامت', 'count': 10},
            {'id': 2, 'name': 'پزشکی', 'count': 5},
          ]);
        }
        return _jsonArray(404, []);
      });

      final cats = await repo.getCategories();

      expect(cats, hasLength(2));
      expect(cats.first.id, 1);
      expect(cats.first.name, 'سلامت');
      expect(cats.first.count, 10);
      expect(cats.last.name, 'پزشکی');
    });

    test('returns empty list when no categories', () async {
      final repo = _repoWith((options) => _jsonArray(200, []));

      final cats = await repo.getCategories();

      expect(cats, isEmpty);
    });
  });
}

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────

/// Builds a [WordPressRepository] backed by a canned Dio handler.
WordPressRepository _repoWith(ResponseBody Function(RequestOptions) handler) {
  final dio = Dio(BaseOptions(baseUrl: 'http://fake.invalid/'));
  dio.httpClientAdapter = _CannedAdapter(handler);
  return WordPressRepository(dio);
}

/// A minimal [HttpClientAdapter] that delegates every request to a handler.
class _CannedAdapter implements HttpClientAdapter {
  _CannedAdapter(this._handler);

  final ResponseBody Function(RequestOptions) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

/// Returns a JSON array response.
ResponseBody _jsonArray(int status, List<dynamic> body, {Map<String, String>? headers}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
      ...?headers?.map((k, v) => MapEntry(k, [v])),
    },
  );
}

/// Returns a JSON object response.
ResponseBody _jsonObject(int status, Map<String, dynamic> body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

// ── Sample JSON payloads (mirror real WordPress shapes) ──

Map<String, dynamic> _fullPostJson() => {
  'id': 101,
  'date': '2026-01-15T10:30:00',
  'title': {'rendered': 'سلامت قلب'},
  'excerpt': {'rendered': '<p>نکات مهم برای <strong>سلامت قلب</strong></p>'},
  'content': {'rendered': '<p>محتوای کامل مطلب اینجا…</p>'},
  'categories': [5, 7],
  '_embedded': {
    'wp:featuredmedia': [
      {'source_url': 'https://cdn.example.com/hero.jpg'},
    ],
    'wp:term': [
      [
        {'id': 5, 'name': 'قلب', 'taxonomy': 'category'},
        {'id': 7, 'name': 'تغذیه', 'taxonomy': 'category'},
      ],
      [
        {'id': 20, 'name': 'tag1', 'taxonomy': 'post_tag'},
      ],
    ],
  },
};

Map<String, dynamic> _minimalPostJson() => {
  'id': 202,
  'date': '2026-02-20T08:00:00',
  'title': {'rendered': 'No Embed Post'},
  'excerpt': {'rendered': '<p>Body</p>'},
  'content': {'rendered': '<p>Content</p>'},
  'categories': [5],
};

Map<String, dynamic> _postWithDeepImage() => {
  'id': 303,
  'date': '2026-03-01T00:00:00',
  'title': {'rendered': 'Deep Image'},
  'excerpt': {'rendered': ''},
  'content': {'rendered': ''},
  'categories': <int>[],
  '_embedded': {
    'wp:featuredmedia': [
      {
        'media_details': {
          'sizes': {
            'full': {'source_url': 'https://cdn.example.com/full.jpg'},
          },
        },
      },
    ],
  },
};

Map<String, dynamic> _postWithExcerpt(String rawExcerpt) => {
  'id': 404,
  'date': '2026-04-01T00:00:00',
  'title': {'rendered': 'Excerpt Test'},
  'excerpt': {'rendered': rawExcerpt},
  'content': {'rendered': ''},
  'categories': <int>[],
};
