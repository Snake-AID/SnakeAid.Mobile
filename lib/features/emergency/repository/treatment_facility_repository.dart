import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snakeaid_mobile/features/emergency/models/hospital_response.dart';
import '../../../core/services/http_service.dart';
import '../../../core/providers/http_provider.dart';

class TreatmentFacilityRepository {
  final HttpService httpService;

  TreatmentFacilityRepository({required this.httpService});

  Future<HospitalApiResponse> getNearestHospital({
    required double lat,
    required double lng,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('Get hospital nearest: $lat, $lng');

      final response = await httpService.get(
        '/api/treatment-facilities/find-hospital',
        queryParameters: {'latitude': lat, 'longitude': lng},
      );

      debugPrint('✅ Nearest hospital retrieved successfully');
      debugPrint('✅ Response: ${response.data}');

      return HospitalApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ Get nearest hospital failed: ${e.message}');
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
            errorMessage = 'Yêu cầu không hợp lệ';
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

/// Provider for Treatment Facility Repository
final treatmentFacilityRepositoryProvider =
    Provider<TreatmentFacilityRepository>((ref) {
      final httpService = ref.watch(httpServiceProvider);
      return TreatmentFacilityRepository(httpService: httpService);
    });
