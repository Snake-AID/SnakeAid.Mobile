import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/http_service.dart';
import '../../../core/providers/http_provider.dart';
import '../models/snake_catching_request.dart';

/// Provider for SnakeCatchingRepository
final snakeCatchingRepositoryProvider = Provider<SnakeCatchingRepository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return SnakeCatchingRepository(httpService);
});

class SnakeCatchingRepository {
  final HttpService _httpService;

  SnakeCatchingRepository(this._httpService);

  /// Create a new snake catching request
  /// POST /api/snakecatching/requests
  Future<SnakeCatchingResponse> createRequest(SnakeCatchingRequest request) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🐍 Creating Snake Catching Request');
      debugPrint('🌐 Base URL: ${_httpService.dio.options.baseUrl}');
      debugPrint('📍 Endpoint: /api/snakecatching/requests');
      debugPrint('📦 Request Data:');
      debugPrint('   Address: ${request.address}');
      debugPrint('   Location: ${request.lat}, ${request.lng}');
      debugPrint('   Species Count: ${request.snakeSpeciesList.length}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      final response = await _httpService.post(
        '/api/snakecatching/requests',
        data: request.toJson(),
      );
      
      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📥 Response Data: ${response.data}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return SnakeCatchingResponse.fromJson(response.data);
      }
      
      throw Exception('Phản hồi không hợp lệ từ server');
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.message}');
      debugPrint('📥 Response: ${e.response?.data}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('API endpoint chưa sẵn sàng. Vui lòng liên hệ admin để kích hoạt tính năng này.');
      } else if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('Bạn cần đăng nhập để tạo yêu cầu bắt rắn.');
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Dữ liệu không hợp lệ';
        throw Exception(message);
      }
      throw Exception('Không thể gửi yêu cầu. Vui lòng thử lại sau.');
    } catch (e) {
      debugPrint('❌ Exception: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Get all snake catching requests for current member
  /// GET /api/snakecatching/requests
  Future<SnakeCatchingListResponse> getRequests() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📋 Getting Snake Catching Requests List');
      debugPrint('📍 Endpoint: /api/snakecatching/requests');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      final response = await _httpService.get('/api/snakecatching/requests');
      
      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📥 Requests Count: ${response.data['data']?.length ?? 0}');
      
      return SnakeCatchingListResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.message}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('API endpoint chưa sẵn sàng.');
      } else if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('Bạn cần đăng nhập để xem danh sách yêu cầu.');
      }
      throw Exception('Không thể tải danh sách yêu cầu. Vui lòng thử lại sau.');
    } catch (e) {
      debugPrint('❌ Exception: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Get a specific snake catching request by ID
  /// GET /api/snakecatching/requests/{requestId}
  Future<SnakeCatchingResponse> getRequestById(String requestId) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔍 Getting Snake Catching Request Detail');
      debugPrint('📍 Endpoint: /api/snakecatching/requests/$requestId');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      final response = await _httpService.get('/api/snakecatching/requests/$requestId');
      
      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📥 Request ID: $requestId');
      
      return SnakeCatchingResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.message}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy yêu cầu này.');
      } else if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('Bạn không có quyền xem yêu cầu này.');
      }
      throw Exception('Không thể tải chi tiết yêu cầu. Vui lòng thử lại sau.');
    } catch (e) {
      debugPrint('❌ Exception: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Upload evidence photo for a mission
  /// POST /api/media/report
  Future<void> uploadMissionEvidence(String missionId, File imageFile) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📸 Uploading mission evidence for: $missionId');

      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'File': await MultipartFile.fromFile(imageFile.path, filename: fileName),
        'ReferenceId': missionId,
      });

      final response = await _httpService.post(
        '/api/media/report',
        data: formData,
        queryParameters: {
          'type': 'SnakeCatchingMission',
          'purpose': 'Evidence',
        },
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      debugPrint('✅ Evidence uploaded: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('❌ Upload evidence failed: ${e.message}');
      debugPrint('📥 Response: ${e.response?.data}');
      throw Exception('Không thể tải ảnh lên. Vui lòng thử lại.');
    } catch (e) {
      debugPrint('❌ Exception: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Mark mission as arrived
  /// PATCH /api/snakecatching/missions/{missionId}/arrived
  Future<void> arrivedMission(String missionId) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📍 Marking Mission Arrived');
      debugPrint('📍 Endpoint: /api/snakecatching/missions/$missionId/arrived');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _httpService.patch(
        '/api/snakecatching/missions/$missionId/arrived',
        data: {},
      );
      debugPrint('✅ Arrived Mission Response: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.message}');
      debugPrint('📥 Response: ${e.response?.data}');
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy nhiệm vụ này.');
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Không thể cập nhật trạng thái';
        throw Exception(message);
      }
      throw Exception('Không thể cập nhật trạng thái. Vui lòng thử lại.');
    } catch (e) {
      debugPrint('❌ Exception: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Start a mission after payment confirmed
  /// PATCH /api/snakecatching/missions/{missionId}/start
  Future<void> startMission(String missionId) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🚀 Starting Mission');
      debugPrint('📍 Endpoint: /api/snakecatching/missions/$missionId/start');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _httpService.patch(
        '/api/snakecatching/missions/$missionId/start',
        data: {},
      );
      debugPrint('✅ Start Mission Response: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.message}');
      debugPrint('📥 Response: ${e.response?.data}');
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy nhiệm vụ này.');
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Không thể bắt đầu nhiệm vụ';
        throw Exception(message);
      }
      throw Exception('Không thể bắt đầu nhiệm vụ. Vui lòng thử lại.');
    } catch (e) {
      debugPrint('❌ Exception: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Add a snake detail to a mission (immediately after rescuer confirms a snake)
  /// POST /api/catchingmission/details
  Future<void> addMissionDetail(String missionId, int snakeSpeciesId, int quantity) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🐍 Adding Mission Detail');
      debugPrint('📍 Endpoint: /api/catchingmission/details');
      debugPrint('   missionId: $missionId, speciesId: $snakeSpeciesId, qty: $quantity');

      final response = await _httpService.post(
        '/api/catchingmission/details',
        data: {
          'snakeCatchingMissionId': missionId,
          'snakeSpeciesId': snakeSpeciesId,
          'quantity': quantity,
        },
      );
      debugPrint('✅ Mission Detail Added: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.message}');
      debugPrint('📥 Response: ${e.response?.data}');
      if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Dữ liệu không hợp lệ';
        throw Exception(message);
      }
      throw Exception('Không thể thêm thông tin rắn. Vui lòng thử lại.');
    } catch (e) {
      debugPrint('❌ Exception: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Complete a mission — rescuer sends result to customer
  /// PATCH /api/snakecatching/missions/{missionId}/complete
  Future<void> completeMission(String missionId) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('✅ Completing Mission');
      debugPrint('📍 Endpoint: /api/snakecatching/missions/$missionId/complete');

      final response = await _httpService.patch(
        '/api/snakecatching/missions/$missionId/complete',
        data: {},
      );
      debugPrint('✅ Mission Completed: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.message}');
      debugPrint('📥 Response: ${e.response?.data}');
      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy nhiệm vụ này.');
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Không thể hoàn thành nhiệm vụ';
        throw Exception(message);
      }
      throw Exception('Không thể hoàn thành nhiệm vụ. Vui lòng thử lại.');
    } catch (e) {
      debugPrint('❌ Exception: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Accept a snake catching request
  /// POST /api/snakecatching/requests/accept/{requestId}
  Future<SnakeCatchingResponse> acceptRequest(String requestId, double lat, double lng) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('✅ Accepting Snake Catching Request');
      debugPrint('📍 Endpoint: /api/snakecatching/requests/accept/$requestId');
      debugPrint('📍 Location: lat=$lat, lng=$lng');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _httpService.post(
        '/api/snakecatching/requests/accept/$requestId',
        data: {'lat': lat, 'lng': lng},
      );

      debugPrint('✅ Accept Response Status: ${response.statusCode}');

      return SnakeCatchingResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.message}');
      debugPrint('📥 Response: ${e.response?.data}');

      if (e.response?.statusCode == 404) {
        throw Exception('Không tìm thấy yêu cầu này.');
      } else if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('Bạn không có quyền chấp nhận yêu cầu này.');
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? 'Không thể chấp nhận yêu cầu';
        throw Exception(message);
      }
      throw Exception('Không thể chấp nhận yêu cầu. Vui lòng thử lại sau.');
    } catch (e) {
      debugPrint('❌ Exception: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }
}
