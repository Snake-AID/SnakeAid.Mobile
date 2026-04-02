import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/http_service.dart';
import '../../../core/providers/http_provider.dart';

/// Provider for PayosRepository
final payosRepositoryProvider = Provider<PayosRepository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return PayosRepository(httpService);
});

/// Response from PayOS create-payment-link
class PaymentLinkResponse {
  final String paymentLinkId;
  final String checkoutUrl;
  final String? qrCode;
  final int? orderCode;

  PaymentLinkResponse({
    required this.paymentLinkId,
    required this.checkoutUrl,
    this.qrCode,
    this.orderCode,
  });

  factory PaymentLinkResponse.fromJson(Map<String, dynamic> json) {
    // Response may be nested under 'data'
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return PaymentLinkResponse(
      paymentLinkId: data['paymentLinkId'] as String? ?? '',
      checkoutUrl: data['checkoutUrl'] as String? ?? '',
      qrCode: data['qrCode'] as String?,
      orderCode: data['orderCode'] as int?,
    );
  }
}

class PayosRepository {
  final HttpService _httpService;

  PayosRepository(this._httpService);

  /// Create a PayOS payment link
  /// POST /api/snakecatching/create-link
  Future<PaymentLinkResponse> createPaymentLink({
    required String snakeCatchingRequestId,
    required double amount,
    String description = 'Catching deposit 1',
    String transactionType = 'CatchingDeposit',
    String returnUrl = 'snakeaid://payment/return',
    String cancelUrl = 'snakeaid://payment/cancel',
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('💳 Creating PayOS Payment Link');
      debugPrint('📍 Endpoint: /api/snakecatching/create-link');
      debugPrint('📦 requestId: $snakeCatchingRequestId | amount: $amount | type: $transactionType');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _httpService.post(
        '/api/snakecatching/create-link',
        data: {
          'snakeCatchingRequestId': snakeCatchingRequestId,
          'amount': amount.toInt(),
          'description': description,
          'transactionType': transactionType,
          'returnUrl': returnUrl,
          'cancelUrl': cancelUrl,
        },
      );

      debugPrint('✅ PayOS Response: ${response.statusCode}');
      debugPrint('📥 Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PaymentLinkResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      throw Exception('Không thể tạo link thanh toán');
    } on DioException catch (e) {
      debugPrint('❌ PayOS DioException: ${e.message}');
      debugPrint('📥 Response: ${e.response?.data}');

      if (e.response?.statusCode == 400) {
        final msg = e.response?.data['message'] ?? 'Dữ liệu không hợp lệ';
        throw Exception(msg);
      } else if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('Bạn cần đăng nhập để thanh toán.');
      }
      throw Exception('Không thể kết nối dịch vụ thanh toán. Vui lòng thử lại.');
    } catch (e) {
      debugPrint('❌ PayOS Exception: $e');
      rethrow;
    }
  }

  /// Transfer final payment to rescuer wallet after customer pays
  /// POST /api/snakecatching/transfer-to-rescuer
  /// Non-fatal — logs and returns silently on any error (BE bug should be fixed server-side).
  Future<void> transferToRescuer(String snakeCatchingRequestId) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('💸 Transferring to rescuer wallet');
      debugPrint('📍 Endpoint: /api/snakecatching/transfer-to-rescuer');
      debugPrint('📦 requestId: $snakeCatchingRequestId');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _httpService.post(
        '/api/snakecatching/transfer-to-rescuer',
        data: {'snakeCatchingRequestId': snakeCatchingRequestId},
      );

      debugPrint('✅ Transfer response: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('❌ Transfer DioException: ${e.message}');
      debugPrint('📥 Response: ${e.response?.data}');
      // Non-fatal — BE bug, do not rethrow
    } catch (e) {
      debugPrint('❌ Transfer Exception: $e');
      // Non-fatal — do not rethrow
    }
  }
}
