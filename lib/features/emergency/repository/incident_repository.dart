import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snakeaid_mobile/features/emergency/models/list_incident_response.dart';
import '../../../core/providers/http_provider.dart';
import '../../../core/services/http_service.dart';
import '../models/sos_incident_request.dart';
import '../models/sos_incident_response.dart';
import '../models/detailed_incident_response.dart';

/// Response model for snakebite incident payment operations
class SnakebiteIncidentPaymentResponse {
  final String snakebiteIncidentId;
  final String? transactionId;
  final int? orderCode;
  final double amount;
  final String currency;
  final String status;
  final String provider;
  final String? checkoutUrl;
  final String? paymentLinkId;
  final DateTime? expiresAt;
  final String? externalTransactionId;
  final DateTime? paidAt;

  SnakebiteIncidentPaymentResponse({
    required this.snakebiteIncidentId,
    this.transactionId,
    this.orderCode,
    required this.amount,
    required this.currency,
    required this.status,
    required this.provider,
    this.checkoutUrl,
    this.paymentLinkId,
    this.expiresAt,
    this.externalTransactionId,
    this.paidAt,
  });

  factory SnakebiteIncidentPaymentResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return SnakebiteIncidentPaymentResponse(
      snakebiteIncidentId:
          (data['snakebiteIncidentId'] ?? data['id'] ?? '') as String,
      transactionId: data['transactionId'] as String?,
      orderCode: data['orderCode'] is int
          ? data['orderCode'] as int
          : (data['orderCode'] is String
                ? int.tryParse(data['orderCode'] as String)
                : null),
      amount: (data['amount'] is num
          ? (data['amount'] as num).toDouble()
          : 0.0),
      currency: data['currency'] as String? ?? 'VND',
      status: data['status'] as String? ?? '',
      provider: data['provider'] as String? ?? '',
      checkoutUrl: data['checkoutUrl'] as String?,
      paymentLinkId: data['paymentLinkId'] as String?,
      expiresAt: data['expiresAt'] != null
          ? DateTime.tryParse(data['expiresAt'] as String)
          : null,
      externalTransactionId: data['externalTransactionId'] as String?,
      paidAt: data['paidAt'] != null
          ? DateTime.tryParse(data['paidAt'] as String)
          : null,
    );
  }
}

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

  Future<PagedIncidentListData> getUserIncidentList(
    String userId, {
    IncidentStatus? status,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(
        '📋 Getting user incident list: $userId (status=${status?.value}, page=$page, pageSize=$pageSize)',
      );

      final queryParameters = <String, dynamic>{
        if (status != null) 'status': status.value,
        'page': page,
        'pageSize': pageSize,
      };

      final response = await httpService.get(
        '/api/incidents/user/$userId',
        queryParameters: queryParameters,
      );

      debugPrint('✅ Get user incident list successful');

      // Map API response with data/meta into typed model
      final pagedResponse = PagedIncidentListResponse.fromJson(response.data);
      if (pagedResponse.data != null) {
        return pagedResponse.data!;
      }

      // Fallback for older format (data is array)
      final data = response.data['data'];
      if (data is List) {
        final items = data
            .map((e) => ListIncidentData.fromJson(e as Map<String, dynamic>))
            .toList();
        return PagedIncidentListData(
          items: items,
          meta: PaginationMeta(
            page: page,
            pageSize: pageSize,
            totalItems: items.length,
            totalPages: 1,
          ),
        );
      }

      throw Exception('Dữ liệu phản hồi không hợp lệ từ máy chủ');
    } on DioException catch (e) {
      debugPrint('❌ Get user incident list failed: ${e.message}');
      throw _handleError(e);
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error parsing detailed incident: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      throw Exception('Không thể tải danh sách sự cố');
    }
  }

  /// Create a PayOS payment link for a snakebite incident
  /// POST /api/incidents/{incidentId}/payment/payos
  Future<SnakebiteIncidentPaymentResponse> createSnakebiteIncidentPaymentLink({
    required String incidentId,
    required double amount,
    String? description,
    String transactionType = 'SnakebiteIncidentPayment',
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('💳 Creating snakebite incident PayOS payment link');
      debugPrint('📍 Endpoint: /api/incidents/$incidentId/payment/payos');
      debugPrint(
        '📦 incidentId: $incidentId | amount: $amount | type: $transactionType',
      );
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await httpService.post(
        '/api/incidents/$incidentId/payment/payos',
        data: {
          'snakebiteIncidentId': incidentId,
          'amount': amount,
          'transactionType': transactionType,
          if (description != null) 'description': description,
        },
      );

      debugPrint('✅ PayOS incident payment response: ${response.statusCode}');
      debugPrint('📥 Data: ${response.data}');

      return SnakebiteIncidentPaymentResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint('❌ PayOS incident payment DioException: ${e.message}');
      debugPrint('📥 Response: ${e.response?.data}');
      throw _handleError(e);
    } catch (e, stackTrace) {
      debugPrint('❌ PayOS incident payment error: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      throw Exception(
        'Không thể tạo đường dẫn thanh toán. Vui lòng thử lại sau.',
      );
    }
  }

  /// Pay a snakebite incident with in-app wallet
  /// POST /api/incidents/{incidentId}/payment/wallet
  Future<SnakebiteIncidentPaymentResponse> paySnakebiteIncidentWithWallet({
    required String incidentId,
    required double amount,
    String? description,
    String transactionType = 'SnakebiteIncidentPayment',
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('💰 Wallet payment for snakebite incident');
      debugPrint('📍 Endpoint: /api/incidents/$incidentId/payment/wallet');
      debugPrint(
        '📦 incidentId: $incidentId | amount: $amount | type: $transactionType',
      );
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await httpService.post(
        '/api/incidents/$incidentId/payment/wallet',
        data: {
          'snakebiteIncidentId': incidentId,
          'amount': amount,
          'transactionType': transactionType,
          if (description != null) 'description': description,
        },
      );

      debugPrint('✅ Wallet incident payment response: ${response.statusCode}');
      debugPrint('📥 Data: ${response.data}');

      return SnakebiteIncidentPaymentResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint('❌ Wallet incident payment DioException: ${e.message}');
      debugPrint('📥 Response: ${e.response?.data}');
      throw _handleError(e);
    } catch (e, stackTrace) {
      debugPrint('❌ Wallet incident payment error: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      throw Exception('Không thể thanh toán bằng ví. Vui lòng thử lại sau.');
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
