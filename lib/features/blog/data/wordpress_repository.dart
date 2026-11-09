import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import 'wordpress_models.dart';

/// Repository for the WordPress blog REST API.
class WordPressRepository {
  final Dio _dio;

  WordPressRepository(this._dio);

  /// Fetches a page of blog posts.
  Future<BlogPostsPage> getPosts({
    int page = 1,
    int perPage = AppConstants.blogPostsPerPage,
    int? categoryId,
  }) async {
    final response = await _dio.get<dynamic>(
      // 👈 dynamic برای جلوگیری از کرش
      'posts',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        '_embed': 1,
        'orderby': 'date',
        'order': 'desc',
        if (categoryId != null) 'categories': categoryId,
      },
      options: Options(validateStatus: (s) => s != null && s < 500),
    );

    if (response.statusCode == 400) {
      return BlogPostsPage(items: const [], page: page, totalPages: 0, total: 0);
    }
    if (response.statusCode != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }

    final raw = response.data;

    // 👈 چک کردن اینکه پاسخ واقعاً یک لیست است یا نه (مثلاً HTML نباشد)
    if (raw is! List) {
      debugPrint('WP Posts Error: Expected List, got ${raw.runtimeType}');
      debugPrint(
        'Response body (first 100 chars): ${raw.toString().substring(0, raw.toString().length > 100 ? 100 : raw.toString().length)}',
      );

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error:
            'پاسخ وردپرس به جای لیست، از نوع ${raw.runtimeType} بود. احتمالاً آدرس API اشتباه است یا REST API غیرفعال است.',
      );
    }

    final items = raw
        .whereType<Map<String, dynamic>>()
        .map(BlogPost.fromJson)
        .toList(growable: false);

    final totalPages =
        _readIntHeader(response.headers, 'x-wp-totalpages') ?? (page == 1 ? 1 : page);
    final total = _readIntHeader(response.headers, 'x-wp-total') ?? items.length;

    return BlogPostsPage(items: items, page: page, totalPages: totalPages, total: total);
  }

  /// Fetches the single detail of a post.
  Future<BlogPost> getPost(int id) async {
    final response = await _dio.get<dynamic>('posts/$id', queryParameters: {'_embed': 1});
    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw StateError('پاسخ وردپرس برای جزئیات پست معتبر نیست.');
    }
    return BlogPost.fromJson(data);
  }

  /// Fetches all categories with at least one published post.
  Future<List<BlogCategory>> getCategories() async {
    final response = await _dio.get<dynamic>(
      // 👈 dynamic
      'categories',
      queryParameters: {
        'per_page': AppConstants.blogCategoriesPerPage,
        'hide_empty': true,
        'orderby': 'name',
        'order': 'asc',
      },
    );
    final raw = response.data ?? const <dynamic>[];

    if (raw is! List) {
      debugPrint('WP Categories Error: Expected List, got ${raw.runtimeType}');
      return const []; // در صورت خطا، لیست خالی برگردان تا UI کرش نکند
    }

    return raw.whereType<Map<String, dynamic>>().map(BlogCategory.fromJson).toList(growable: false);
  }

  int? _readIntHeader(Headers headers, String name) {
    final raw = headers.value(name);
    if (raw == null) return null;
    return int.tryParse(raw);
  }
}

/// Dedicated Dio provider for WordPress.
final wordpressDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      // ⚠️ مطمئن شوید این آدرس دقیقاً درست است (احتمالاً باید /blog/ حذف شود)
      baseUrl: AppConstants.wordpressBaseUrl,
      connectTimeout: const Duration(seconds: AppConstants.apiTimeoutSeconds),
      receiveTimeout: const Duration(seconds: AppConstants.apiTimeoutSeconds),
      headers: {
        AppConstants.headerAccept: AppConstants.contentTypeJson,
        AppConstants.headerContentType: AppConstants.contentTypeJson,
      },
    ),
  );
});

/// Riverpod provider for [WordPressRepository].
final wordpressRepositoryProvider = Provider<WordPressRepository>((ref) {
  return WordPressRepository(ref.watch(wordpressDioProvider));
});
