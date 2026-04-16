import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/http_service.dart';
import '../../../core/providers/http_provider.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.watch(httpServiceProvider));
});

/// Wallet info returned by GET /api/wallet/me
class WalletInfo {
  final String id;
  final String userId;
  final double balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletInfo({
    required this.id,
    required this.userId,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletInfo.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return WalletInfo(
      id: data['id'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'] as String)
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.parse(data['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}

/// Result from POST /api/wallet/topup — holds the fields needed for subsequent steps.
class TopupResult {
  final String transactionId;
  final String checkoutUrl;
  final int? orderCode;

  const TopupResult({
    required this.transactionId,
    required this.checkoutUrl,
    this.orderCode,
  });
}

class WalletRepository {
  final HttpService _httpService;

  WalletRepository(this._httpService);

  /// GET /api/wallet/me
  Future<WalletInfo> getWalletInfo() async {
    try {
      debugPrint('💰 GET /api/wallet/me');
      final response = await _httpService.get('/api/wallet/me');
      return WalletInfo.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('❌ getWalletInfo DioException: ${e.message}');
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('Không có quyền truy cập ví.');
      }
      throw Exception('Không thể tải thông tin ví. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// POST /api/wallet/topup — create PayOS top-up link.
  /// Returns [TopupResult] containing [transactionId] (for confirm-payment) and [checkoutUrl].
  Future<TopupResult> createTopupLink({
    required int amount,
    String description = 'Nạp tiền ví SnakeAidPay',
  }) async {
    try {
      debugPrint('——————————————————————————————————————————');
      debugPrint('💰 Topup: POST /api/wallet/topup  amount=$amount');
      final response = await _httpService.post(
        '/api/wallet/topup',
        data: {'amount': amount, 'description': description},
      );
      final data =
          (response.data as Map<String, dynamic>)['data']
              as Map<String, dynamic>?;
      final url = data?['checkoutUrl'] as String?;
      final transactionId = data?['transactionId'] as String?;
      final rawOrderCode = data == null ? null : data['orderCode'];
      final orderCode = rawOrderCode is int
          ? rawOrderCode
          : int.tryParse(data?['orderCode']?.toString() ?? '');
      if (url == null || url.isEmpty) {
        throw Exception('Không nhận được link thanh toán.');
      }
      if (transactionId == null || transactionId.isEmpty) {
        throw Exception('Không nhận được mã giao dịch.');
      }
      debugPrint('✅ Topup  transactionId=$transactionId  checkoutUrl=$url');
      return TopupResult(
        transactionId: transactionId,
        checkoutUrl: url,
        orderCode: orderCode,
      );
    } on DioException catch (e) {
      debugPrint('❌ createTopupLink DioException: ${e.message}');
      final msg = e.response?.data?['message'] as String?;
      throw Exception(
        msg ?? 'Không thể tạo yêu cầu nạp tiền. Vui lòng thử lại.',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// POST /api/v1/PayOs/confirm-payment — confirm PayOS top-up after returning from browser.
  /// [transactionId] is taken from [TopupResult.transactionId] returned by [createTopupLink].
  /// Returns [true] if the confirmation was successful.
  Future<bool> confirmPayment({required String transactionId}) async {
    try {
      debugPrint('——————————————————————————————————————————');
      debugPrint(
        '✅ Confirm payment: POST /api/v1/PayOs/confirm-payment  transactionId=$transactionId',
      );
      final response = await _httpService.post(
        '/api/v1/PayOs/confirm-payment',
        data: {'transactionId': transactionId},
      );
      debugPrint('✅ Payment confirmed');
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      debugPrint('❌ confirmPayment DioException: ${e.message}');
      debugPrint('📥 Response: ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('❌ confirmPayment error: $e');
      return false;
    }
  }

  /// POST /api/snakecatching/payment/wallet
  /// [transactionType] is 'CatchingDeposit' (đợt 1) or 'CatchingPayment' (đợt 2)
  /// Returns the [transactionId] from the response for subsequent status checks.
  Future<String> payWithWallet({
    required String snakeCatchingRequestId,
    required double amount,
    required String transactionType,
    String? description,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('💸 Wallet Payment: POST /api/snakecatching/payment/wallet');
      debugPrint(
        '   requestId: $snakeCatchingRequestId | amount: $amount | type: $transactionType',
      );
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _httpService.post(
        '/api/snakecatching/payment/wallet',
        data: {
          'snakeCatchingRequestId': snakeCatchingRequestId,
          'amount': amount.toInt(),
          'transactionType': transactionType,
          if (description != null) 'description': description,
        },
      );

      debugPrint('✅ Wallet payment response: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Thanh toán thất bại');
      }

      // Extract transactionId from response
      final respData = response.data as Map<String, dynamic>?;
      final dataMap = respData?['data'] as Map<String, dynamic>?;
      final transactionId =
          dataMap?['transactionId'] as String? ?? dataMap?['id'] as String?;
      if (transactionId == null || transactionId.isEmpty) {
        throw Exception('Không nhận được mã giao dịch từ máy chủ.');
      }
      debugPrint('✅ Wallet payment transactionId=$transactionId');
      return transactionId;
    } on DioException catch (e) {
      debugPrint('❌ Wallet Payment DioException: ${e.message}');
      debugPrint('📥 Response: ${e.response?.data}');
      final msg = e.response?.data?['message'] as String?;
      if (e.response?.statusCode == 400) {
        throw Exception(msg ?? 'Số dư không đủ hoặc yêu cầu không hợp lệ.');
      } else if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 403) {
        throw Exception('Không có quyền thực hiện thanh toán.');
      }
      throw Exception(msg ?? 'Thanh toán thất bại. Vui lòng thử lại.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Lỗi không xác định: $e');
    }
  }
}
