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

  /// POST /api/wallet/topup — create PayOS top-up link
  /// Returns a checkout URL to open in the browser.
  Future<String> createTopupLink({
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
      if (url == null || url.isEmpty) {
        throw Exception('Không nhận được link thanh toán.');
      }
      debugPrint('✅ Topup checkout URL: $url');
      return url;
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

  /// POST /api/wallet/payment
  /// [transactionType] is 'CatchingDeposit' (đợt 1) or 'CatchingPayment' (đợt 2)
  Future<void> payWithWallet({
    required String snakeCatchingRequestId,
    required double amount,
    required String transactionType,
    String? description,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('💸 Wallet Payment: POST /api/wallet/payment');
      debugPrint(
        '   requestId: $snakeCatchingRequestId | amount: $amount | type: $transactionType',
      );
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _httpService.post(
        '/api/wallet/payment',
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
