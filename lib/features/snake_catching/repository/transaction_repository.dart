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

  /// GET /api/transactions?referenceId={requestId}
  /// Returns the paid CatchingDeposit transaction for a snake catching request.
  /// Returns null if none found or not yet paid.
  Future<TransactionInfo?> getDepositTransactionByRequestId(
    String requestId,
  ) async {
    try {
      debugPrint('🔍 GET /api/transactions?referenceId=$requestId');
      final response = await _httpService.get(
        '/api/transactions',
        queryParameters: {'referenceId': requestId},
      );
      debugPrint('✅ Transactions list response: ${response.statusCode}');
      if (response.statusCode == 200 && response.data != null) {
        final raw = response.data['data'];
        List<dynamic> items = [];
        if (raw is List) {
          items = raw;
        } else if (raw is Map && raw['items'] is List) {
          items = raw['items'] as List;
        }
        // Only return a CatchingDeposit that has been confirmed paid by BE.
        final paidDeposit = items
            .map((e) => TransactionInfo.fromJson(e as Map<String, dynamic>))
            .where((tx) => tx.transactionType == 'CatchingDeposit' && tx.isPaid)
            .toList();
        debugPrint('🔍 CatchingDeposit paid count: ${paidDeposit.length}');
        if (paidDeposit.isNotEmpty) return paidDeposit.first;
      }
      return null;
    } on DioException catch (e) {
      debugPrint('❌ Transactions DioException: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('❌ Transactions Exception: $e');
      return null;
    }
  }

  /// GET /api/transactions/{transactionId}
  /// Returns null if 404 (transaction not found).
  Future<TransactionInfo?> getTransactionById(String transactionId) async {
    try {
      debugPrint('🔍 GET /api/transactions/$transactionId');
      final response = await _httpService.get(
        '/api/transactions/$transactionId',
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
      if (e.response?.statusCode == 404) {
        debugPrint('ℹ️ Transaction $transactionId not found');
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
