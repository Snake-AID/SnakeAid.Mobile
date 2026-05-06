import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snakeaid_mobile/features/emergency/models/detailed_incident_response.dart';
import 'dart:io';
import '../../../core/services/http_service.dart';
import '../../../core/providers/http_provider.dart';
import '../models/media_upload_response.dart';
import '../models/snake_detection_response.dart';
import '../models/snake_identification_response.dart';
import '../models/first_aid_recommendation_response.dart';

/// Snake AI Repository
class SnakeAiRepository {
  final HttpService httpService;

  SnakeAiRepository({required this.httpService});

  /// Upload snake image for identification
  ///
  /// POST /api/media/report
  /// - Type: SnakebiteIncident
  /// - Purpose: SnakeIdentification
  /// - ReferenceId: incident ID
  /// - File: image file
  Future<MediaUploadResponse> uploadSnakeImage({
    required String incidentId,
    required File imageFile,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📸 Uploading snake image for incident: $incidentId');

      // Create form data
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'File': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        'ReferenceId': incidentId,
      });

      final response = await httpService.post(
        '/api/media/report',
        data: formData,
        queryParameters: {
          'type':
              MediaReferenceType.snakebiteIncident.value, // "SnakebiteIncident"
          'purpose': MediaPurpose
              .snakeIdentification
              .value, // "SnakeIdentification" (AI processing)
        },
      );

      debugPrint('✅ Image uploaded successfully');
      debugPrint('✅ Response: ${response.data}');

      return MediaUploadResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ Upload image failed: ${e.message}');
      throw _handleError(e);
    }
  }

  /// Detect snake from uploaded image
  ///
  /// POST /api/detection/detect/{reportMediaId}
  Future<SnakeDetectionResponse> detectSnake({
    required String reportMediaId,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🤖 Detecting snake from media: $reportMediaId');

      final response = await httpService.post(
        '/api/detection/detect/$reportMediaId',
      );

      debugPrint('✅ Detection completed successfully');
      debugPrint('✅ Response: ${response.data}');

      return SnakeDetectionResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ Detection failed: ${e.message}');
      throw _handleError(e);
    }
  }

  /// Get detection result by recognition result ID
  ///
  /// GET /api/detection/{id}
  /// Returns the same structure as detectSnake
  Future<SnakeDetectionResponse> getDetectionResult({
    required String recognitionResultId,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔍 Getting detection result: $recognitionResultId');

      final response = await httpService.get(
        '/api/detection/$recognitionResultId',
      );

      debugPrint('✅ Detection result retrieved successfully');
      debugPrint('✅ Response: ${response.data}');

      return SnakeDetectionResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ Get detection result failed: ${e.message}');
      throw _handleError(e);
    }
  }

  /// Confirm AI identification and save to incident
  ///
  /// POST /api/incidents/{incidentId}/identify/ai
  /// Body: { "recognitionResultId": "uuid" }
  /// Returns: IdentifySnakeResponse
  Future<IdentifySnakeResponse> confirmAIIdentification({
    required String incidentId,
    required String recognitionResultId,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('✅ Confirming AI identification for incident: $incidentId');
      debugPrint('   Recognition Result ID: $recognitionResultId');

      final response = await httpService.post(
        '/api/incidents/$incidentId/identify/ai',
        data: {'recognitionResultId': recognitionResultId},
      );

      debugPrint('✅ Identification confirmed successfully');
      debugPrint('✅ Full Response: ${response.data}');

      // Backend response structure: {status_code, message, is_success, data: {...}}
      final data = response.data['data'] as Map<String, dynamic>;

      return IdentifySnakeResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('❌ Confirm identification failed: ${e.message}');
      throw _handleError(e);
    }
  }

  /// Get first aid recommendation for incident
  ///
  /// GET /api/first-aid-guidelines/recommendation/incident/{incidentId}
  /// Returns: FirstAidRecommendationResponse with snake, guideline, source
  Future<FirstAidRecommendationResponse> getFirstAidRecommendation({
    required String incidentId,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(
        '🩺 Getting first aid recommendation for incident: $incidentId',
      );

      final response = await httpService.get(
        '/api/first-aid-guidelines/recommendation/incident/$incidentId',
      );

      // Backend response structure: {status_code, message, is_success, data: {...}}
      final data = response.data['data'] as Map<String, dynamic>;

      debugPrint('✅ First aid recommendation retrieved successfully');
      debugPrint('   Source: ${data['source']}');
      debugPrint('   Guideline: ${data['guidelineName']}');

      return FirstAidRecommendationResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('❌ Get first aid recommendation failed: ${e.message}');
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
            errorMessage = 'Hình ảnh không hợp lệ';
          }
          break;
        case 401:
          errorMessage = 'Phiên đăng nhập hết hạn';
          break;
        case 404:
          errorMessage = 'Không tìm thấy thông tin';
          break;
        case 413:
          errorMessage = 'Hình ảnh quá lớn. Vui lòng chọn ảnh nhỏ hơn';
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

  /// Upload image for community report AI snake detection (no incident ID required)
  ///
  /// POST /api/media/report?type=CommunityReport&purpose=SnakeIdentification
  Future<MediaUploadResponse> uploadImageForCommunityDetection({
    required File imageFile,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📸 Uploading image for community AI detection');

      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'File': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        'ReferenceId': '',
      });

      final response = await httpService.post(
        '/api/media/report',
        data: formData,
        queryParameters: {
          'type': MediaReferenceType.communityReport.value,
          'purpose': MediaPurpose.snakeIdentification.value,
        },
      );

      debugPrint('✅ Community image uploaded successfully');
      debugPrint('✅ Response: ${response.data}');

      return MediaUploadResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ Community upload failed: ${e.message}');
      throw _handleError(e);
    }
  }
}

/// Provider for Snake AI Repository
final snakeAiRepositoryProvider = Provider<SnakeAiRepository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return SnakeAiRepository(httpService: httpService);
});
