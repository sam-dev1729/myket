import 'package:json_annotation/json_annotation.dart';

part 'wordpress_models.g.dart';

/// A single blog post returned by `GET /wp-json/wp/v2/posts?_embed`.
///
/// WordPress returns `title`/`excerpt`/`content` as `{ rendered: "..." }`
/// objects, and embeds related data under `_embedded` when `_embed=1` is
/// passed. Both shapes are normalized here.
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.none)
class BlogPost {
  /// Post ID.
  final int id;

  /// Plain-text title (HTML stripped of any inline tags).
  final String title;

  /// Short plain-text summary (HTML stripped, trimmed to a reasonable size).
  final String excerpt;

  /// Full HTML content body (rendered by `flutter_html` in the detail screen).
  final String content;

  /// ISO-8601 publish date from WordPress (blog-local time).
  final String date;

  /// Featured image URL (from `_embedded['wp:featuredmedia']` or null).
  final String? featuredImageUrl;

  /// Category IDs attached to this post (from the main `categories` field).
  final List<int> categoryIds;

  /// Full category objects (only populated when `_embed=1` succeeded).
  final List<BlogCategory> categories;

  const BlogPost({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.date,
    this.featuredImageUrl,
    required this.categoryIds,
    required this.categories,
  });

  /// Custom parser for the WordPress post shape.
  ///
  /// Handles:
  /// - `title`/`excerpt`/`content` as `{rendered}` maps
  /// - `_embedded['wp:featuredmedia']` for the featured image (with
  ///   fallback to `media_details.sizes.full.source_url`)
  /// - `_embedded['wp:term']` for categories + tags (only categories
  ///   whose `taxonomy == 'category'` are kept)
  factory BlogPost.fromJson(Map<String, dynamic> json) {
    final categoryIds = (json['categories'] as List<dynamic>?)
            ?.whereType<num>()
            .map((e) => e.toInt())
            .toList() ??
        const <int>[];

    return BlogPost(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: _rendered(json['title']),
      excerpt: _stripHtml(_rendered(json['excerpt'])),
      content: _rendered(json['content']),
      date: json['date'] as String? ?? '',
      featuredImageUrl: _featuredImage(json),
      categoryIds: categoryIds,
      categories: _embeddedCategories(json),
    );
  }

  Map<String, dynamic> toJson() => _$BlogPostToJson(this);

  // ──────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────

  static String _rendered(dynamic field) {
    if (field is Map) {
      final rendered = field['rendered'];
      if (rendered is String) return rendered;
    }
    if (field is String) return field;
    return '';
  }

  /// Strips HTML tags and decodes common HTML entities for the excerpt.
  ///
  /// WP wraps excerpts in `<p>…</p>` and emits entities like `&#8211;`.
  /// This is a lightweight, dependency-free equivalent of `html.unescape`.
  static String _stripHtml(String html) {
    var text = html.replaceAll(RegExp(r'<[^>]*>'), '');
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&#8211;', '–')
        .replaceAll('&#8212;', '—')
        .replaceAll('&#8216;', '‘')
        .replaceAll('&#8217;', '’')
        .replaceAll('&#8220;', '“')
        .replaceAll('&#8221;', '”')
        .replaceAll('&#8230;', '…');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  static String? _featuredImage(Map<String, dynamic> json) {
    final embedded = json['_embedded'];
    if (embedded is! Map) return null;
    final media = embedded['wp:featuredmedia'];
    if (media is! List || media.isEmpty) return null;
    final first = media.first;
    if (first is! Map) return null;
    final direct = first['source_url'];
    if (direct is String && direct.isNotEmpty) return direct;
    final details = first['media_details'];
    if (details is Map) {
      final sizes = details['sizes'];
      if (sizes is Map) {
        final full = sizes['full'];
        if (full is Map) {
          final url = full['source_url'];
          if (url is String && url.isNotEmpty) return url;
        }
      }
    }
    return null;
  }

  static List<BlogCategory> _embeddedCategories(Map<String, dynamic> json) {
    final embedded = json['_embedded'];
    if (embedded is! Map) return const [];
    final terms = embedded['wp:term'];
    if (terms is! List) return const [];

    final result = <BlogCategory>[];
    for (final group in terms) {
      if (group is! List) continue;
      for (final t in group) {
        if (t is! Map) continue;
        if (t['taxonomy'] != 'category') continue;
        final id = (t['id'] as num?)?.toInt();
        final name = t['name'] as String?;
        if (id != null && name != null) {
          result.add(BlogCategory(id: id, name: name, count: 0));
        }
      }
    }
    return result;
  }
}

/// A single category returned by `GET /wp-json/wp/v2/categories`.
@JsonSerializable()
class BlogCategory {
  /// Category ID (WP term ID).
  final int id;

  /// Category display name.
  final String name;

  /// Number of posts published under this category.
  final int count;

  const BlogCategory({required this.id, required this.name, required this.count});

  factory BlogCategory.fromJson(Map<String, dynamic> json) => _$BlogCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$BlogCategoryToJson(this);

  /// Lightweight copy used by [BlogPost._embeddedCategories] (no count).
  BlogCategory copyWithCount(int newCount) => BlogCategory(id: id, name: name, count: newCount);
}

/// A page of blog posts with pagination metadata sourced from
/// `X-WP-TotalPages` / `X-WP-Total` headers.
class BlogPostsPage {
  final List<BlogPost> items;
  final int page;
  final int totalPages;
  final int total;

  const BlogPostsPage({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.total,
  });

  bool get hasMore => page < totalPages;
}