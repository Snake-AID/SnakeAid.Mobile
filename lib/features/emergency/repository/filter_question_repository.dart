import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/http_service.dart';
import '../../../core/providers/http_provider.dart';
import '../models/filter_question.dart';
import '../models/filtered_snake.dart';

/// Filter Question Repository for Snake Identification Questionnaire
class FilterQuestionRepository {
  final HttpService httpService;

  FilterQuestionRepository({required this.httpService});

  /// Get all filter questions with options
  ///
  /// GET /api/filter-questions
  Future<FilterQuestionResponse> getFilterQuestions() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📋 Getting filter questions');

      final response = await httpService.get('/api/filter-questions');

      debugPrint('✅ Filter questions retrieved successfully');
      debugPrint('✅ Response: ${response.data}');

      return FilterQuestionResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ Get filter questions failed: ${e.message}');
      throw _handleError(e);
    }
  }

  /// Filter snakes by questionnaire answers
  ///
  /// POST /api/snake-species/filter-by-answers
  /// Body: { "selectedOptionIds": [1, 2, 3] }
  Future<FilteredSnakeResponse> filterSnakesByAnswers({
    required List<int> selectedOptionIds,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔍 Filtering snakes by answers');
      debugPrint('   Selected option IDs: $selectedOptionIds');

      final response = await httpService.post(
        '/api/snake-species/filter-by-answers',
        data: {'selectedOptionIds': selectedOptionIds},
      );

      debugPrint('✅ Snakes filtered successfully');
      debugPrint('✅ Response: ${response.data}');

      return FilteredSnakeResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ Filter snakes failed: ${e.message}');
      throw _handleError(e);
    }
  }

  /// Handle API errors
  Exception _handleError(DioException e) {
    String errorMessage = 'Đã có lỗi xảy ra';

    if (e.response != null) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        errorMessage =
            data['message'] ?? data['error'] ?? data['title'] ?? errorMessage;
      } else if (data is String) {
        errorMessage = data;
      }

      switch (e.response?.statusCode) {
        case 400:
          if (errorMessage == 'Đã có lỗi xảy ra') {
            errorMessage = 'Dữ liệu không hợp lệ';
          }
          break;
        case 401:
          errorMessage = 'Phiên đăng nhập hết hạn';
          break;
        case 404:
          errorMessage = 'Không tìm thấy thông tin';
          break;
        case 422:
          if (errorMessage == 'Đã có lỗi xảy ra') {
            errorMessage = 'Dữ liệu không hợp lệ';
          }
          break;
        case 500:
          errorMessage = 'Lỗi máy chủ, vui lòng thử lại sau';
          break;
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Kết nối timeout, vui lòng kiểm tra mạng';
    } else if (e.type == DioExceptionType.connectionError) {
      errorMessage = 'Không thể kết nối tới máy chủ';
    }

    return Exception(errorMessage);
  }
}

/// Provider for Filter Question Repository
final filterQuestionRepositoryProvider = Provider<FilterQuestionRepository>((
  ref,
) {
  final httpService = ref.watch(httpServiceProvider);
  return FilterQuestionRepository(httpService: httpService);
});
