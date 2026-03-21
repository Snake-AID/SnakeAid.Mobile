import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/http_service.dart';
import '../../../core/providers/http_provider.dart';
import '../models/lesson.dart';

final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return LessonRepository(httpService);
});

class LessonRepository {
  final HttpService _httpService;

  LessonRepository(this._httpService);

  /// GET /api/lessons
  /// Optional [category]: 'FirstAid' | 'Catching' | 'Safety'
  Future<LessonListResponse> getLessons({String? category}) async {
    try {
      final params = <String, dynamic>{
        if (category != null) 'category': category,
      };
      final response = await _httpService.get(
        '/api/lessons',
        queryParameters: params.isNotEmpty ? params : null,
      );
      // Handle both wrapped { isSuccess, data: [...] } and raw list responses
      final body = response.data;
      if (body is List) {
        final items = body
            .whereType<Map<String, dynamic>>()
            .map(LessonData.fromJson)
            .toList();
        return LessonListResponse(isSuccess: true, message: '', data: items);
      }
      return LessonListResponse.fromJson(body as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('Bạn cần đăng nhập để xem bài học.');
      }
      throw Exception('Không thể tải danh sách bài học. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// GET /api/lessons/{id}
  Future<LessonResponse> getLessonById(String id) async {
    try {
      final response = await _httpService.get('/api/lessons/$id');
      final body = response.data;
      if (body is Map<String, dynamic> && body.containsKey('data')) {
        return LessonResponse.fromJson(body);
      }
      // Raw lesson object
      return LessonResponse(
        isSuccess: true,
        message: '',
        data: LessonData.fromJson(body as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy bài học này.');
      }
      throw Exception('Không thể tải bài học. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }
}
