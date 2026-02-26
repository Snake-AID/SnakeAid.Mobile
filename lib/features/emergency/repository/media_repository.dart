import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../core/providers/http_provider.dart';
import '../../../core/services/http_service.dart';
import '../models/report_media_response.dart';
import '../models/detailed_incident_response.dart';

/// Provider for MediaRepository
final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return MediaRepository(httpService: httpService);
});

/// Repository for media upload operations
///
/// Handles uploading evidence photos for rescue missions
class MediaRepository {
  final HttpService httpService;

  MediaRepository({required this.httpService});

  /// Upload evidence photo for rescue mission
  ///
  /// Returns media ID (Guid string) to be used in completeMission
  Future<String> uploadEvidencePhoto({
    required File imageFile,
    required String missionId,
  }) async {
    return await _uploadWithRetry(
      imageFile: imageFile,
      missionId: missionId,
      retryCount: 0,
    );
  }

  /// Internal upload method with retry logic for 401 errors
  Future<String> _uploadWithRetry({
    required File imageFile,
    required String missionId,
    required int retryCount,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📸 Uploading evidence photo for mission: $missionId');
      if (retryCount > 0) {
        debugPrint('🔄 Retry attempt: $retryCount');
      }
      debugPrint('📁 File: ${imageFile.path}');
      debugPrint('📏 Size: ${imageFile.lengthSync()} bytes');

      // Get file name
      final fileName = imageFile.path.split(Platform.pathSeparator).last;

      // Create FRESH form data (cannot reuse FormData)
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        'referenceId': missionId,
      });

      // Upload with query parameters using enum values
      final response = await httpService.post(
        '/api/media/report',
        data: formData,
        queryParameters: {
          'type': MediaReferenceType.rescueMission.value, // "RescueMission"
          'purpose':
              MediaPurpose.evidence.value, // "Evidence" (NO AI processing)
        },
      );

      // Parse response
      final apiResponse = ReportMediaApiResponse.fromJson(response.data);

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw Exception(apiResponse.message);
      }

      debugPrint('✅ Evidence photo uploaded successfully');

      final mediaId = apiResponse.data!.id;
      debugPrint('🆔 Media ID: $mediaId');
      debugPrint('🔗 Media URL: ${apiResponse.data!.mediaUrl}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return mediaId;
    } on DioException catch (e) {
      // Retry once on 401 (token was refreshed by interceptor)
      if (e.response?.statusCode == 401 && retryCount == 0) {
        debugPrint(
          '🔄 Got 401, token was refreshed. Retrying with new token...',
        );
        await Future.delayed(const Duration(milliseconds: 500));
        return await _uploadWithRetry(
          imageFile: imageFile,
          missionId: missionId,
          retryCount: retryCount + 1,
        );
      }

      debugPrint('❌ Upload evidence photo failed: ${e.message}');
      debugPrint('❌ Response: ${e.response?.data}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('Lỗi khi upload ảnh bằng chứng');
    }
  }

  /// Handle Dio errors
  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Kết nối mạng bị gián đoạn. Vui lòng thử lại');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? e.response?.data;

        if (statusCode == 400) {
          return Exception(message ?? 'Hình ảnh không hợp lệ');
        } else if (statusCode == 401) {
          return Exception('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại');
        } else if (statusCode == 413) {
          return Exception('Hình ảnh quá lớn. Vui lòng chọn ảnh nhỏ hơn 10MB');
        } else if (statusCode == 422) {
          return Exception(message ?? 'Dữ liệu không hợp lệ');
        }
        return Exception(message ?? 'Có lỗi xảy ra. Vui lòng thử lại');

      case DioExceptionType.cancel:
        return Exception('Yêu cầu đã bị hủy');

      case DioExceptionType.unknown:
        return Exception('Không có kết nối mạng. Vui lòng kiểm tra internet');

      default:
        return Exception('Có lỗi xảy ra. Vui lòng thử lại');
    }
  }
}
