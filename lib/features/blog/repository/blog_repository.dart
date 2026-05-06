import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/http_provider.dart';
import '../../../core/services/http_service.dart';
import '../models/blog_model.dart';

final blogRepositoryProvider = Provider<BlogRepository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return BlogRepository(httpService: httpService);
});

class BlogRepository {
  final HttpService httpService;

  BlogRepository({required this.httpService});

  /// GET /api/blogs — list all blogs (server may accept optional query params)
  Future<List<BlogModel>> getBlogs({String? status}) async {
    try {
      debugPrint(
        '📰 Fetching blogs${status != null ? ' (status=$status)' : ''}',
      );
      final response = await httpService.get(
        '/api/blogs',
        queryParameters: status != null ? {'status': status} : null,
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'];
      if (data is List) {
        return data
            .map((e) => BlogModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data is Map<String, dynamic>) {
        // paginated response
        final items = data['items'] ?? data['data'] ?? [];
        if (items is List) {
          return items
              .map((e) => BlogModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      debugPrint('❌ getBlogs error: ${e.message}');
      rethrow;
    }
  }

  /// GET /api/blogs/{id}
  Future<BlogModel> getBlogById(String id) async {
    try {
      debugPrint('📰 Fetching blog #$id');
      final response = await httpService.get('/api/blogs/$id');
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return BlogModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint('❌ getBlogById error: ${e.message}');
      rethrow;
    }
  }

  /// POST /api/blogs — create blog
  Future<BlogModel> createBlog({
    required String title,
    required String content,
    required String thumbnailUrl,
    required BlogStatus status,
    required BlogCategory category,
    required List<BlogTag> tags,
    required int readingTime,
  }) async {
    try {
      debugPrint('📰 Creating blog: $title');
      final response = await httpService.post(
        '/api/blogs',
        data: {
          'title': title,
          'content': content,
          'thumbnailUrl': thumbnailUrl,
          'status': blogStatusToString(status),
          'category': blogCategoryToString(category),
          'tags': tags.map(blogTagToString).toList(),
          'readingTime': readingTime,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return BlogModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint('❌ createBlog error: ${e.message}');
      rethrow;
    }
  }

  /// PUT /api/blogs/{id} — update blog
  Future<BlogModel> updateBlog({
    required String id,
    required String title,
    required String content,
    required String thumbnailUrl,
    required BlogStatus status,
    required BlogCategory category,
    required List<BlogTag> tags,
    required int readingTime,
  }) async {
    try {
      debugPrint('📰 Updating blog #$id');
      final response = await httpService.put(
        '/api/blogs/$id',
        data: {
          'title': title,
          'content': content,
          'thumbnailUrl': thumbnailUrl,
          'status': blogStatusToString(status),
          'category': blogCategoryToString(category),
          'tags': tags.map(blogTagToString).toList(),
          'readingTime': readingTime,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return BlogModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint('❌ updateBlog error: ${e.message}');
      rethrow;
    }
  }

  /// DELETE /api/blogs/{id}
  Future<void> deleteBlog(String id) async {
    try {
      debugPrint('📰 Deleting blog #$id');
      await httpService.delete('/api/blogs/$id');
    } on DioException catch (e) {
      debugPrint('❌ deleteBlog error: ${e.message}');
      rethrow;
    }
  }

  /// PATCH /api/blogs/{id}/view — increment view count
  Future<void> incrementView(String id) async {
    try {
      await httpService.patch('/api/blogs/$id/view', data: {});
    } on DioException catch (e) {
      debugPrint('❌ incrementView error: ${e.message}');
      // Don't rethrow — non-critical
    }
  }

  /// PATCH /api/blogs/{id}/like — like a blog
  Future<void> likeBlog(String id) async {
    try {
      await httpService.patch('/api/blogs/$id/like', data: {});
    } on DioException catch (e) {
      debugPrint('❌ likeBlog error: ${e.message}');
      rethrow;
    }
  }

  /// PATCH /api/blogs/{id}/unlike — unlike a blog
  Future<void> unlikeBlog(String id) async {
    try {
      await httpService.patch('/api/blogs/$id/unlike', data: {});
    } on DioException catch (e) {
      debugPrint('❌ unlikeBlog error: ${e.message}');
      rethrow;
    }
  }

  /// Toggle like — calls like or unlike based on current state
  Future<void> toggleLike(String id, {required bool isCurrentlyLiked}) async {
    if (isCurrentlyLiked) {
      await unlikeBlog(id);
    } else {
      await likeBlog(id);
    }
  }

  /// PATCH /api/blogs/{id}/status — change status (e.g. Draft → PendingApproval)
  Future<void> updateStatus(String id, BlogStatus status) async {
    try {
      debugPrint(
        '📰 Updating blog #$id status → ${blogStatusToString(status)}',
      );
      await httpService.patch(
        '/api/blogs/$id/status',
        data: {'status': blogStatusToString(status)},
      );
    } on DioException catch (e) {
      debugPrint('❌ updateStatus error: ${e.message}');
      rethrow;
    }
  }
}
