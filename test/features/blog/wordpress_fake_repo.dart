import 'package:dio/dio.dart';
import 'package:myket/features/blog/data/wordpress_models.dart';
import 'package:myket/features/blog/data/wordpress_repository.dart';

/// Hand-rolled fake of [WordPressRepository].
///
/// Configurable via public fields; never touches Dio or any platform channel.
class FakeWordPressRepository extends WordPressRepository {
  FakeWordPressRepository() : super(Dio());

  // ── Posts ──
  BlogPostsPage? postsPage1;
  BlogPostsPage? postsPage2;

  /// Optional category-scoped overrides: key is `categoryId` (null = All).
  Map<int?, BlogPostsPage>? byCategory;

  Exception? throwOnGetPosts;

  // ── Single post ──
  BlogPost? post;
  Exception? throwOnGetPost;

  // ── Categories ──
  List<BlogCategory>? categories;
  Exception? throwOnGetCategories;

  // ── Spy state ──
  int? lastCategoryId;
  int? lastPage;
  int? lastPerPage;

  @override
  Future<BlogPostsPage> getPosts({int page = 1, int perPage = 10, int? categoryId}) async {
    lastCategoryId = categoryId;
    lastPage = page;
    lastPerPage = perPage;

    if (throwOnGetPosts != null) throw throwOnGetPosts!;

    if (byCategory != null && byCategory!.containsKey(categoryId)) {
      return byCategory![categoryId]!;
    }
    if (page == 1 && postsPage1 != null) return postsPage1!;
    if (page == 2 && postsPage2 != null) return postsPage2!;
    throw UnimplementedError(
      'FakeWordPressRepository: unexpected page=$page categoryId=$categoryId',
    );
  }

  @override
  Future<BlogPost> getPost(int id) async {
    if (throwOnGetPost != null) throw throwOnGetPost!;
    if (post == null) {
      throw UnimplementedError('FakeWordPressRepository: post not configured');
    }
    return post!;
  }

  @override
  Future<List<BlogCategory>> getCategories() async {
    if (throwOnGetCategories != null) throw throwOnGetCategories!;
    return categories ?? const [];
  }
}
