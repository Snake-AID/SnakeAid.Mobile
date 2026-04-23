import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snakeaid_mobile/features/emergency/models/detailed_incident_response.dart';
import '../../../core/services/http_service.dart';
import '../../../core/providers/http_provider.dart';
import '../models/snake_catching_request.dart';
import '../../emergency/models/media_upload_response.dart';
import '../../emergency/models/snake_detection_response.dart';

/// Provider for SnakeCatchingRepository
final snakeCatchingRepositoryProvider = Provider<SnakeCatchingRepository>((
  ref,
) {
  final httpService = ref.watch(httpServiceProvider);
  return SnakeCatchingRepository(httpService);
});

class SnakeCatchingRepository {
  final HttpService _httpService;

  SnakeCatchingRepository(this._httpService);

  /// Create a new snake catching request
  /// POST /api/snakecatching/requests
  Future<SnakeCatchingResponse> createRequest(
    SnakeCatchingRequest request,
  ) async {
    try {
      final body = request.toJson();
      final response = await _httpService.post(
        '/api/snakecatching/requests',
        data: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return SnakeCatchingResponse.fromJson(response.data);
      }
      throw Exception('Phản hồi không hợp lệ từ server');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception(
          'API endpoint chưa sẵn sàng. Vui lòng liên hệ admin để kích hoạt tính năng này.',
        );
      } else if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 403) {
        throw Exception('Bạn cần đăng nhập để tạo yêu cầu bắt rắn.');
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Dữ liệu không hợp lệ';
        throw Exception(message);
      }
      throw Exception('Không thể gửi yêu cầu. Vui lòng thử lại sau.');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Get all snake catching requests
  /// GET /api/snakecatching/requests
  /// Supported filters: userId, assignedRescuerId (AND filters, all optional)
  Future<SnakeCatchingListResponse> getRequests({
    String? userId,
    String? assignedRescuerId,
  }) async {
    try {
      final params = <String, dynamic>{
        if (userId != null) 'userId': userId,
        if (assignedRescuerId != null) 'assignedRescuerId': assignedRescuerId,
      };
      final response = await _httpService.get(
        '/api/snakecatching/requests',
        queryParameters: params.isNotEmpty ? params : null,
      );
      return SnakeCatchingListResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('API endpoint chưa sẵn sàng.');
      } else if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 403) {
        throw Exception('Bạn cần đăng nhập để xem danh sách yêu cầu.');
      }
      throw Exception('Không thể tải danh sách yêu cầu. Vui lòng thử lại sau.');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Get a specific snake catching request by ID
  /// GET /api/snakecatching/requests/{requestId}
  Future<SnakeCatchingResponse> getRequestById(String requestId) async {
    try {
      final response = await _httpService.get(
        '/api/snakecatching/requests/$requestId',
      );
      return SnakeCatchingResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy yêu cầu này.');
      } else if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 403) {
        throw Exception('Bạn không có quyền xem yêu cầu này.');
      }
      throw Exception('Không thể tải chi tiết yêu cầu. Vui lòng thử lại sau.');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Upload a snake report photo for AI identification
  ///
  /// POST /api/media/report
  /// type: SnakeCatchingRequest, purpose: SnakeIdentification, ReferenceId: null
  Future<MediaUploadResponse> uploadSnakeReportImage(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last.split('\\').last;
      debugPrint('📸 Uploading report image: $fileName');
      final formData = FormData.fromMap({
        'File': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _httpService.post(
        '/api/media/report',
        data: formData,
        queryParameters: {
          'type': MediaReferenceType.snakeCatchingRequest.value,
          'purpose': MediaPurpose.snakeIdentification.value,
        },
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      final result = MediaUploadResponse.fromJson(response.data);
      debugPrint(
        '📸 Upload result — isSuccess: ${result.isSuccess}, mediaId: ${result.data?.id}',
      );
      return result;
    } on DioException catch (e) {
      debugPrint(
        '❌ uploadSnakeReportImage failed [${e.response?.statusCode}]: ${e.response?.data}',
      );
      throw Exception('Không thể tải ảnh lên. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Detect snake species from an uploaded media ID
  ///
  /// POST /api/detection/detect/{reportMediaId}
  Future<SnakeDetectionResponse> detectSnakeFromMedia(String mediaId) async {
    try {
      debugPrint('🤖 Detecting snake from mediaId: $mediaId');
      final response = await _httpService.post(
        '/api/detection/detect/$mediaId',
      );
      final result = SnakeDetectionResponse.fromJson(response.data);
      debugPrint(
        '🤖 Detection result — isSuccess: ${result.isSuccess}, results count: ${result.data?.results.length}, first species: ${result.data?.results.firstOrNull?.snake.commonName} (id: ${result.data?.results.firstOrNull?.snake.id})',
      );
      return result;
    } on DioException catch (e) {
      debugPrint(
        '❌ detectSnakeFromMedia failed [${e.response?.statusCode}]: ${e.response?.data}',
      );
      throw Exception('Nhận diện rắn thất bại. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Upload evidence photo for a request
  /// POST /api/media/report?type=SnakeCatchingRequest&purpose=Evidence
  Future<void> uploadRequestEvidence(String requestId, File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'File': await MultipartFile.fromFile(imageFile.path, filename: fileName),
        'ReferenceId': requestId,
      });

      await _httpService.post(
        '/api/media/report',
        data: formData,
        queryParameters: {
          'type': 'SnakeCatchingRequest',
          'purpose': 'Evidence',
        },
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
    } on DioException catch (e) {
      throw Exception('Không thể tải ảnh lên. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Upload evidence photo for a mission
  /// POST /api/media/report
  Future<void> uploadMissionEvidence(String missionId, File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'File': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        'ReferenceId': missionId,
      });

      final response = await _httpService.post(
        '/api/media/report',
        data: formData,
        queryParameters: {
          'type': MediaReferenceType.snakeCatchingMission.value,
          'purpose': MediaPurpose.evidence.value,
        },
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
    } on DioException catch (e) {
      throw Exception('Không thể tải ảnh lên. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Uncomplete a mission after evidence is uploaded
  /// PATCH /api/snakecatching/missions/{missionId}/uncomplete
  Future<void> uncompleteMission(String missionId, String reason) async {
    try {
      await _httpService.patch(
        '/api/snakecatching/missions/$missionId/uncomplete',
        data: {'reason': reason},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy nhiệm vụ này.');
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Không thể báo cáo chưa hoàn thành nhiệm vụ';
        throw Exception(message);
      }
      throw Exception('Không thể báo cáo chưa hoàn thành nhiệm vụ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Mark mission as arrived
  /// PATCH /api/snakecatching/missions/{missionId}/arrived
  Future<void> arrivedMission(String missionId) async {
    try {
      final response = await _httpService.patch(
        '/api/snakecatching/missions/$missionId/arrived',
        data: {},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy nhiệm vụ này.');
      } else if (e.response?.statusCode == 400) {
        final message =
            e.response?.data['message'] ?? 'Không thể cập nhật trạng thái';
        throw Exception(message);
      }
      throw Exception('Không thể cập nhật trạng thái. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Start a mission after payment confirmed
  /// PATCH /api/snakecatching/missions/{missionId}/start
  Future<void> startMission(String missionId) async {
    try {
      final response = await _httpService.patch(
        '/api/snakecatching/missions/$missionId/start',
        data: {},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy nhiệm vụ này.');
      } else if (e.response?.statusCode == 400) {
        final message =
            e.response?.data['message'] ?? 'Không thể bắt đầu nhiệm vụ';
        throw Exception(message);
      }
      throw Exception('Không thể bắt đầu nhiệm vụ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Add a snake detail to a mission (immediately after rescuer confirms a snake)
  /// POST /api/catchingmission/details
  /// Returns the created mission detail ID.
  Future<String> addMissionDetail(
    String missionId,
    int snakeSpeciesId,
    int quantity,
  ) async {
    try {
      final response = await _httpService.post(
        '/api/catchingmission/details',
        data: {
          'snakeCatchingMissionId': missionId,
          'snakeSpeciesId': snakeSpeciesId,
          'quantity': quantity,
        },
      );
      final id = response.data?['data']?['id']?.toString() ?? '';
      return id;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Dữ liệu không hợp lệ';
        throw Exception(message);
      }
      throw Exception('Không thể thêm thông tin rắn. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Delete a snake detail from a mission
  /// DELETE /api/catchingmission/details/{id}
  Future<void> deleteMissionDetail(String detailId) async {
    try {
      await _httpService.delete('/api/catchingmission/details/$detailId');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy chi tiết này.');
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Không thể xóa';
        throw Exception(message);
      }
      throw Exception('Không thể xóa thông tin rắn. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Complete a mission — rescuer sends result to customer
  /// PATCH /api/snakecatching/missions/{missionId}/complete
  Future<void> completeMission(
    String missionId, {
    required String catchingEnvironmentId,
  }) async {
    try {
      final response = await _httpService.patch(
        '/api/snakecatching/missions/$missionId/complete',
        data: {'catchingEnvironmentId': catchingEnvironmentId},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy nhiệm vụ này.');
      } else if (e.response?.statusCode == 400) {
        final message =
            e.response?.data['message'] ?? 'Không thể hoàn thành nhiệm vụ';
        throw Exception(message);
      }
      throw Exception('Không thể hoàn thành nhiệm vụ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Abort (cancel) a mission after accepting
  /// PATCH /api/snakecatching/missions/{missionId}/abort
  Future<void> abortMission(String missionId, String reason) async {
    try {
      final response = await _httpService.patch(
        '/api/snakecatching/missions/$missionId/abort',
        data: {'reason': reason},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy nhiệm vụ này.');
      } else if (e.response?.statusCode == 400) {
        final errorCode = e.response?.data['error']?['errorCode'] as String?;
        if (errorCode == 'INTERNAL_SERVER_ERROR') {
          throw Exception(
            'Máy chủ gặp lỗi nội bộ khi hủy đơn. Vui lòng thử lại sau hoặc liên hệ hỗ trợ.',
          );
        }
        final message = e.response?.data['message'] ?? 'Không thể hủy nhiệm vụ';
        throw Exception(message);
      } else if (e.response?.statusCode == 403) {
        throw Exception('Bạn không có quyền hủy nhiệm vụ này.');
      }
      throw Exception('Không thể hủy nhiệm vụ. Vui lòng thử lại sau.');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Cancel a snake catching request
  /// PATCH /api/snakecatching/requests/cancel/{requestId}
  Future<void> cancelRequest(String requestId, String reason) async {
    try {
      final response = await _httpService.patch(
        '/api/snakecatching/requests/cancel/$requestId',
        data: {'reason': reason},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy yêu cầu này.');
      } else if (e.response?.statusCode == 400) {
        final errorCode = e.response?.data['error']?['errorCode'] as String?;
        if (errorCode == 'INTERNAL_SERVER_ERROR') {
          throw Exception(
            'Máy chủ gặp lỗi nội bộ khi hủy đơn. Vui lòng thử lại sau hoặc liên hệ hỗ trợ.',
          );
        }
        final message = e.response?.data['message'] ?? 'Không thể hủy yêu cầu';
        throw Exception(message);
      } else if (e.response?.statusCode == 403) {
        throw Exception('Bạn không có quyền hủy yêu cầu này.');
      }
      throw Exception('Không thể hủy yêu cầu. Vui lòng thử lại sau.');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Accept a snake catching request
  /// POST /api/snakecatching/requests/accept/{requestId}
  Future<SnakeCatchingResponse> acceptRequest(
    String requestId,
    double lat,
    double lng,
  ) async {
    try {
      final response = await _httpService.post(
        '/api/snakecatching/requests/accept/$requestId',
        data: {'lat': lat, 'lng': lng},
      );
      return SnakeCatchingResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy yêu cầu này.');
      } else if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 403) {
        throw Exception('Bạn không có quyền chấp nhận yêu cầu này.');
      } else if (e.response?.statusCode == 400) {
        final message =
            e.response?.data['message'] ?? 'Không thể chấp nhận yêu cầu';
        throw Exception(message);
      }
      throw Exception('Không thể chấp nhận yêu cầu. Vui lòng thử lại sau.');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }
}
