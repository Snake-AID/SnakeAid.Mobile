import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/http_provider.dart';
import '../../../core/services/http_service.dart';
import '../models/sos_incident_request.dart';
import '../models/sos_incident_response.dart';
import '../models/detailed_incident_response.dart';

/// Provider for IncidentRepository
final incidentRepositoryProvider = Provider<IncidentRepository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return IncidentRepository(httpService: httpService);
});

/// Repository for emergency incident-related API calls
///
/// Handles SOS incident creation, updates, and tracking
class IncidentRepository {
  final HttpService httpService;

  IncidentRepository({required this.httpService});

  /// Create SOS incident
  ///
  /// Gọi API POST /api/incidents/sos
  /// Returns [SosIncidentResponse] với incident data
  ///
  /// Throws [Exception] nếu tạo incident thất bại
  Future<SosIncidentResponse> createSosIncident(
    SosIncidentRequest request,
  ) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🆘 Creating SOS incident...');
      debugPrint('📍 Location: lng=${request.lng}, lat=${request.lat}');
      debugPrint('📋 Request data: ${request.toJson()}');

      final response = await httpService.post(
        '/api/incidents/sos',
        data: request.toJson(),
      );

      debugPrint('✅ SOS incident created successfully');
      debugPrint('✅ Response: ${response.data}');

      return SosIncidentResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ Create SOS incident DioException: ${e.type}');
      debugPrint('❌ Error message: ${e.message}');
      debugPrint('❌ Response data: ${e.response?.data}');
      debugPrint('❌ Status code: ${e.response?.statusCode}');
      throw _handleError(e);
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error type: ${e.runtimeType}');
      debugPrint('❌ Unexpected error: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      throw Exception('Tạo yêu cầu SOS thất bại. Vui lòng thử lại');
    }
  }

  /// Get incident by ID
  ///
  /// Gọi API GET /api/incidents/{id}
  /// Returns [SosIncidentResponse] với incident data
  Future<SosIncidentResponse> getIncident(String incidentId) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📋 Getting incident: $incidentId');

      final response = await httpService.get('/api/incidents/$incidentId');

      debugPrint('✅ Get incident successful');
      debugPrint('✅ Response: ${response.data}');

      return SosIncidentResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ Get incident failed: ${e.message}');
      throw _handleError(e);
    }
  }

  /// Get detailed incident with all relations (user, rescuer, mission, media)
  ///
  /// Gọi API GET /api/incidents/{id}
  /// Returns [DetailedIncidentResponse] với full incident data including:
  /// - User profile & emergency contacts
  /// - Assigned rescuer profile
  /// - Rescue mission details
  /// - Media & AI detection results
  ///
  /// Used for: Rescue request modal, mission detail screen
  Future<DetailedIncidentResponse> getDetailedIncident(
    String incidentId,
  ) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📋 Getting detailed incident: $incidentId');

      final response = await httpService.get('/api/incidents/$incidentId');

      debugPrint('✅ Get detailed incident successful');
      debugPrint('✅ Has user data: ${response.data['data']?['user'] != null}');
      debugPrint(
        '✅ Has rescuer data: ${response.data['data']?['assignedRescuer'] != null}',
      );
      debugPrint(
        '✅ Has mission data: ${response.data['data']?['rescueMission'] != null}',
      );
      debugPrint(
        '✅ Media count: ${(response.data['data']?['media'] as List?)?.length ?? 0}',
      );

      return DetailedIncidentResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ Get detailed incident failed: ${e.message}');
      throw _handleError(e);
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error parsing detailed incident: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      throw Exception('Không thể tải thông tin chi tiết sự cố');
    }
  }

  /// Handle API errors
  Exception _handleError(DioException e) {
    String errorMessage = 'Đã có lỗi xảy ra';

    if (e.response != null) {
      final data = e.response?.data;

      // Xử lý error message từ backend
      if (data is Map<String, dynamic>) {
        errorMessage =
            data['message'] ?? data['error'] ?? data['title'] ?? errorMessage;

        // Nếu có validationErrors từ error object
        if (data['error'] is Map && data['error']['validationErrors'] != null) {
          final validationErrors =
              data['error']['validationErrors'] as Map<String, dynamic>;
          final errorList = validationErrors.values
              .expand((e) => e is List ? e : [e])
              .join('\n');
          errorMessage = errorList.isNotEmpty ? errorList : errorMessage;
        }
        // Nếu có errors array (validation errors)
        else if (data['errors'] != null) {
          if (data['errors'] is Map) {
            final errors = data['errors'] as Map<String, dynamic>;
            final errorList = errors.values
                .expand((e) => e is List ? e : [e])
                .join('\n');
            errorMessage = errorList.isNotEmpty ? errorList : errorMessage;
          } else if (data['errors'] is List) {
            errorMessage = (data['errors'] as List).join('\n');
          }
        }
      } else if (data is String) {
        errorMessage = data;
      }

      // Xử lý theo status code
      switch (e.response?.statusCode) {
        case 400:
          if (errorMessage == 'Đã có lỗi xảy ra') {
            errorMessage = 'Thông tin vị trí không hợp lệ';
          }
          break;
        case 401:
          errorMessage = 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại';
          break;
        case 404:
          errorMessage = 'Không tìm thấy thông tin yêu cầu';
          break;
        case 409:
          errorMessage = 'Bạn đang có yêu cầu SOS đang xử lý';
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
