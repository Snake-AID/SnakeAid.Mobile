import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/http_provider.dart';
import '../../../core/services/http_service.dart';
import '../models/rescue_mission_response.dart';
import '../models/report_media_response.dart';
import '../models/report_tranfer_hospital_request.dart';
import '../models/hospital_transfer_pricing_response.dart';

/// Provider for RescueMissionRepository
final rescueMissionRepositoryProvider = Provider<RescueMissionRepository>((
  ref,
) {
  final httpService = ref.watch(httpServiceProvider);
  return RescueMissionRepository(httpService: httpService);
});

/// Repository for rescue mission-related API calls
///
/// Handles mission retrieval, status updates, and lifecycle management
class RescueMissionRepository {
  final HttpService httpService;

  RescueMissionRepository({required this.httpService});

  /// Get mission details with optional rescuer location for distance calculation
  ///
  /// Gọi API GET /api/rescue-missions/{missionId}
  /// Query params: rescuerLat, rescuerLng (optional)
  ///
  /// Returns [DetailRescueMissionResponse] với full mission data:
  /// - Mission info (status, price, timestamps)
  /// - Incident details (location, symptoms, severity, media)
  /// - User profile (name, contacts, underlying disease)
  /// - Rescuer profile
  /// - Distance from rescuer (if location provided)
  ///
  /// Used for: Mission detail screen before/during rescue
  Future<DetailRescueMissionResponse> getMissionDetail({
    required String missionId,
    double? rescuerLat,
    double? rescuerLng,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🎯 Getting mission details: $missionId');
      if (rescuerLat != null && rescuerLng != null) {
        debugPrint('📍 Rescuer location: $rescuerLat, $rescuerLng');
      }

      final queryParams = <String, dynamic>{};
      if (rescuerLat != null) queryParams['rescuerLat'] = rescuerLat;
      if (rescuerLng != null) queryParams['rescuerLng'] = rescuerLng;

      final response = await httpService.get(
        '/api/rescue-missions/$missionId',
        queryParameters: queryParams,
      );

      debugPrint('✅ Mission details retrieved successfully');

      final missionResponse = MissionDetailResponse.fromJson(response.data);
      debugPrint('📋 Status: ${missionResponse.data?.status}');
      debugPrint('💰 Price: ${missionResponse.data?.price}');

      if (!missionResponse.isSuccess || missionResponse.data == null) {
        throw Exception(missionResponse.message);
      }

      return missionResponse.data!;
    } on DioException catch (e) {
      debugPrint('❌ Get mission detail failed: ${e.message}');
      debugPrint('❌ Response: ${e.response?.data}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('Lỗi khi tải thông tin nhiệm vụ');
    }
  }

  /// Get rescuer mission list
  ///
  /// Gọi API GET /api/rescue-missions/rescuer/list
  /// Query params: status (optional)
  Future<RescueMissionListResponse> getRescuerMissionList({
    String? status,
  }) async {
    try {
      final response = await httpService.get(
        '/api/rescue-missions/rescuer/list',
        queryParameters: status != null ? {'status': status} : null,
      );
      return RescueMissionListResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ Get rescuer mission list failed: ${e.message}');
      debugPrint('❌ Response: ${e.response?.data}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('Lỗi khi tải danh sách nhiệm vụ cứu hộ');
    }
  }

  /// Start mission (Preparing → EnRoute)
  ///
  /// Gọi API PATCH /api/rescue-missions/{missionId}/start
  /// Rescuer begins heading to incident location
  Future<void> startMission(String missionId) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🚀 Starting mission: $missionId');

      await httpService.patch(
        '/api/rescue-missions/$missionId/start',
        data: {},
      );

      debugPrint('✅ Mission started - status: EnRoute');
    } on DioException catch (e) {
      debugPrint('❌ Start mission failed: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('Lỗi khi bắt đầu nhiệm vụ');
    }
  }

  /// Mark arrival at location (EnRoute → RescuerArrived)
  ///
  /// Gọi API PATCH /api/rescue-missions/{missionId}/arrive
  /// Rescuer has arrived at incident location
  Future<void> arriveAtLocation(String missionId) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('✅ Marking arrival: $missionId');

      await httpService.patch(
        '/api/rescue-missions/$missionId/arrive',
        data: {},
      );

      debugPrint('✅ Arrival marked - status: RescuerArrived');
    } on DioException catch (e) {
      debugPrint('❌ Mark arrival failed: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('Lỗi khi xác nhận đã đến nơi');
    }
  }

  /// Complete mission (RescuerArrived → MissionCompleted)
  ///
  /// Gọi API PATCH /api/rescue-missions/{missionId}/complete
  /// Body: { evidenceMediaIds: [...], completionNotes: "..." }
  ///
  /// Automatically updates incident status to Finished
  ///
  /// Requirements:
  /// - Mission must be in RescuerArrived status
  /// - At least 1 evidence photo required
  /// - All media must belong to this mission with Purpose=Evidence
  Future<void> completeMission({
    required String missionId,
    required List<String> evidenceMediaIds,
    String? completionNotes,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('✔️ Completing mission: $missionId');
      debugPrint('📸 Evidence photos: ${evidenceMediaIds.length}');
      if (completionNotes != null) {
        debugPrint('📝 Notes: $completionNotes');
      }

      final request = CompleteMissionRequest(
        evidenceMediaIds: evidenceMediaIds,
        completionNotes: completionNotes,
      );

      await httpService.patch(
        '/api/rescue-missions/$missionId/complete',
        data: request.toJson(),
      );

      debugPrint('✅ Mission completed - incident marked as finished');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } on DioException catch (e) {
      debugPrint('❌ Complete mission failed: ${e.message}');
      debugPrint('❌ Response: ${e.response?.data}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('Lỗi khi hoàn thành nhiệm vụ');
    }
  }

  /// Abort mission by rescuer (Preparing/EnRoute → MissionAborted)
  ///
  /// Gọi API PATCH /api/rescue-missions/{missionId}/abort
  /// Creates new session with increased radius for finding another rescuer
  /// Incident is reset to Pending
  Future<void> abortMission({
    required String missionId,
    required String reason,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ Aborting mission: $missionId');
      debugPrint('📝 Reason: $reason');

      final request = CancelMissionRequest(cancellationReason: reason);

      await httpService.patch(
        '/api/rescue-missions/$missionId/abort',
        data: request.toJson(),
      );

      debugPrint('✅ Mission aborted - new session created');
    } on DioException catch (e) {
      debugPrint('❌ Abort mission failed: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('Lỗi khi hủy nhiệm vụ');
    }
  }

  /// Cancel mission by user (Preparing → Cancelled)
  ///
  /// Gọi API PATCH /api/rescue-missions/{missionId}/cancel
  /// Only allowed during Preparing phase before rescuer starts
  /// No new session is created
  Future<void> cancelMission({
    required String missionId,
    required String reason,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🚫 User cancelling mission: $missionId');
      debugPrint('📝 Reason: $reason');

      final request = CancelMissionRequest(cancellationReason: reason);

      await httpService.patch(
        '/api/rescue-missions/$missionId/cancel',
        data: request.toJson(),
      );

      debugPrint('✅ Mission cancelled by user');
    } on DioException catch (e) {
      debugPrint('❌ Cancel mission failed: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('Lỗi khi hủy nhiệm vụ');
    }
  }

  /// Report hospital transfer
  ///
  /// Gọi API PATCH /api/rescue-missions/{missionId}/hospital-transfer
  Future<HospitalTransferPricingResponse> reportTransferToHospital({
    required String missionId,
    required int hospitalId,
    String? note,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🏥 Reporting transfer to hospital: $missionId');
      debugPrint('   Hospital ID: $hospitalId');
      if (note != null) {
        debugPrint('   Note: $note');
      }

      final request = ReportTranferHospitalRequest(
        hospitalId: hospitalId,
        notes: note,
      );

      final response = await httpService.patch(
        '/api/rescue-missions/$missionId/hospital-transfer',
        data: request.toJson(),
      );

      debugPrint('response: ${response.data}');

      final pricingResponse = HospitalTransferPricingApiResponse.fromJson(
        response.data,
      );

      if (!pricingResponse.isSuccess || pricingResponse.data == null) {
        throw Exception(pricingResponse.message);
      }

      debugPrint('✅ Hospital transfer reported');
      debugPrint('   Hospital: ${pricingResponse.data!.hospitalName}');
      debugPrint(
        '   Requires hospitalization: ${pricingResponse.data!.requiresHospitalization}',
      );
      debugPrint('   Updated at: ${pricingResponse.data!.updatedAt}');

      return pricingResponse.data!;
    } on DioException catch (e) {
      debugPrint('❌ Report hospital transfer failed: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('Lỗi khi báo cáo chuyển viện');
    }
  }

  /// Report no need hospital transfer
  ///
  /// Gọi API PATCH /api/rescue-missions/{missionId}/no-need-hospital-transfer
  Future<bool> reportNoNeedTransferToHospital({
    required String missionId,
    String? note,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🏥 Reporting no-need hospital transfer: $missionId');
      if (note != null) {
        debugPrint('   Note: $note');
      }

      final response = await httpService.patch(
        '/api/rescue-missions/$missionId/no-need-hospital-transfer',
        data: note != null ? {'notes': note} : {},
      );

      debugPrint('response: ${response.data}');

      final body = response.data as Map<String, dynamic>;
      final isSuccess = body['isSuccess'] == true || body['is_success'] == true;
      final result = body['data'];

      if (!isSuccess || result is! bool) {
        throw Exception(body['message'] ?? 'Yêu cầu không hợp lệ');
      }

      debugPrint('✅ Reported no-need hospital transfer');
      return result;
    } on DioException catch (e) {
      debugPrint('❌ Report no-need hospital transfer failed: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('Lỗi khi báo cáo không cần chuyển viện');
    }
  }

  /// Handle Dio errors and provide user-friendly messages
  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Kết nối mạng bị gián đoạn. Vui lòng thử lại');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? e.response?.data;

        if (statusCode == 404) {
          return Exception('Không tìm thấy nhiệm vụ');
        } else if (statusCode == 400) {
          return Exception(message ?? 'Yêu cầu không hợp lệ');
        } else if (statusCode == 401) {
          return Exception('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại');
        } else if (statusCode == 403) {
          return Exception('Bạn không có quyền thực hiện thao tác này');
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
