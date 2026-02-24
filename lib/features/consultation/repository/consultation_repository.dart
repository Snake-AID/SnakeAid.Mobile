import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/http_provider.dart';
import '../../../core/services/http_service.dart';
import '../models/expert_model.dart';
import '../models/expert_list_response.dart';
import '../models/expert_detail_model.dart';

/// Provider for ConsultationRepository
final consultationRepositoryProvider = Provider<ConsultationRepository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return ConsultationRepository(httpService: httpService);
});

/// Repository for consultation-related API calls
/// Handles fetching experts, creating consultations, etc.
class ConsultationRepository {
  final HttpService httpService;

  ConsultationRepository({required this.httpService});

  /// Get list of experts with optional filters
  /// 
  /// Parameters:
  /// - specialty: Filter by specialty/expertise
  /// - onlineOnly: Show only online experts
  /// - sortBy: Sort by 'rating', 'fee', 'reviews'
  /// 
  /// Returns [ExpertListResponse] with list of experts
  Future<ExpertListResponse> getExperts({
    String? specialty,
    bool onlineOnly = false,
    String? sortBy,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📋 Fetching experts list');
      debugPrint('   Specialty: $specialty');
      debugPrint('   Online only: $onlineOnly');
      debugPrint('   Sort by: $sortBy');
      debugPrint('   Page: $page, Size: $pageSize');

      // Build query parameters
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };

      if (specialty != null && specialty.isNotEmpty) {
        queryParams['specialty'] = specialty;
      }

      if (onlineOnly) {
        queryParams['onlineOnly'] = true;
      }

      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
      }

      final response = await httpService.get(
        '/api/experts',
        queryParameters: queryParams,
      );

      debugPrint('✅ Experts fetched successfully');
      debugPrint('   Response type: ${response.data.runtimeType}');

      return ExpertListResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ Failed to fetch experts: ${e.message}');
      debugPrint('   Error type: ${e.type}');
      debugPrint('   Status code: ${e.response?.statusCode}');

      // Return error response
      return ExpertListResponse(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['message'] ?? 'Không thể tải danh sách chuyên gia',
        isSuccess: false,
        error: e.message,
      );
    } catch (e) {
      debugPrint('❌ Unexpected error fetching experts: $e');
      return ExpertListResponse(
        statusCode: 500,
        message: 'Lỗi không xác định khi tải danh sách chuyên gia',
        isSuccess: false,
        error: e.toString(),
      );
    }
  }

  /// Get expert detail by ID
  /// 
  /// Returns [ExpertModel] or null if not found
  Future<ExpertModel?> getExpertById(String expertId) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📋 Fetching expert detail: $expertId');

      final response = await httpService.get('/api/experts/$expertId');

      debugPrint('✅ Expert detail fetched successfully');

      // Handle response structure
      if (response.data['is_success'] == true && response.data['data'] != null) {
        return ExpertModel.fromJson(response.data['data']);
      }

      return null;
    } on DioException catch (e) {
      debugPrint('❌ Failed to fetch expert detail: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('❌ Unexpected error fetching expert detail: $e');
      return null;
    }
  }

  /// Get list of available specialties
  /// 
  /// Returns list of specialty names
  Future<List<String>> getSpecialties() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📋 Fetching specialties list');

      final response = await httpService.get('/api/experts/specialties');

      debugPrint('✅ Specialties fetched successfully');

      if (response.data['is_success'] == true && response.data['data'] != null) {
        return List<String>.from(response.data['data']);
      }

      // Return default specialties if API fails
      return _getDefaultSpecialties();
    } catch (e) {
      debugPrint('❌ Failed to fetch specialties: $e');
      // Return default specialties
      return _getDefaultSpecialties();
    }
  }

  /// Get default specialties (fallback)
  List<String> _getDefaultSpecialties() {
    return [
      'Tất cả chuyên môn',
      'Rắn Độc Việt Nam',
      'Rắn Cảnh',
      'Rắn Nước',
      'Rắn Không Độc',
      'Xử lý vết cắn',
      'Cứu hộ rắn',
      'Nghiên cứu rắn',
    ];
  }

  /// Get expert detail by ID
  /// 
  /// Parameters:
  /// - expertId: The ID of the expert
  /// 
  /// Returns [ExpertDetailModel] with detailed information
  Future<ExpertDetailModel> getExpertDetail(String expertId) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📋 Fetching expert detail: $expertId');

      final response = await httpService.get('/api/experts/$expertId');

      debugPrint('✅ Expert detail fetched successfully');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return ExpertDetailModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ DioException fetching expert detail: ${e.message}');
      debugPrint('   Status Code: ${e.response?.statusCode}');
      debugPrint('   Response: ${e.response?.data}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error fetching expert detail: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      rethrow;
    }
  }
}
