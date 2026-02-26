import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/http_service.dart';
import '../../../core/providers/http_provider.dart';

/// Provider for TransactionRepository
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return TransactionRepository(httpService);
});

/// Transaction info model
class TransactionInfo {
  final String id;
  final String transactionType;
  final double amount;
  final String status;
  final String? snakeCatchingRequestId;
  final DateTime? createdAt;

  TransactionInfo({
    required this.id,
    required this.transactionType,
    required this.amount,
    required this.status,
    this.snakeCatchingRequestId,
    this.createdAt,
  });

  factory TransactionInfo.fromJson(Map<String, dynamic> json) {
    return TransactionInfo(
      id: json['id'] as String? ?? '',
      transactionType: json['transactionType'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? '',
      snakeCatchingRequestId: json['snakeCatchingRequestId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  /// Khách đã đặt cọc nếu transactionType == "CatchingDeposit"
  bool get isDeposited => transactionType == 'CatchingDeposit';

  /// Khách đã thanh toán cuối nếu transactionType == "CatchingPayment"
  bool get isCatchingPayment => transactionType == 'CatchingPayment';

  /// Giao dịch đã hoàn thành (BE đã xác nhận)
  bool get isPaid => status.toLowerCase() == 'paid';
}

class TransactionRepository {
  final HttpService _httpService;

  TransactionRepository(this._httpService);

  /// Check if the customer has paid for a snake catching request
  /// GET /api/transactions/snakecatchingrequest/{snakeCatchingRequestId}
  /// Returns null if no transaction found (customer hasn't paid yet)
  Future<TransactionInfo?> getTransactionByRequestId(String requestId) async {
    try {
      final response = await _httpService.get(
        '/api/transactions/snakecatchingrequest/$requestId',
      );

      debugPrint('✅ Transaction Response: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null) {
          return TransactionInfo.fromJson(data as Map<String, dynamic>);
        }
      }
      return null;
    } on DioException catch (e) {
      // 404 means no transaction found => customer hasn't paid
      if (e.response?.statusCode == 404) {
        debugPrint('ℹ️ No transaction found for request $requestId');
        return null;
      }
      debugPrint('❌ Transaction DioException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Transaction Exception: $e');
      rethrow;
    }
  }
}
