import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/http_service.dart';
import '../../../core/providers/http_provider.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(httpServiceProvider));
});

// ── Transaction Type helpers ────────────────────────────────────────────────

/// Map: TransactionType string → integer value for query param
const Map<String, int> kTransTypeValues = {
  'ConsultationPayment': 0,
  'ExpertPayout': 1,
  'ConsultationRefund': 2,
  'MissionDonation': 10,
  'RescuerReward': 11,
  'CatchingPayment': 20,
  'CatcherPayout': 21,
  'CatchingRefund': 22,
  'CatchingDeposit': 23,
  'SnakebiteIncidentPayment': 40,
  'SnakebiteIncidentRefund': 41,
  'PlatformFee': 30,
  'WalletTopup': 31,
  'WalletWithdraw': 32,
  'AdminAdjustment': 33,
};

/// Vietnamese labels — kept in sync with backend enum
const Map<String, String> kTransTypeLabels = {
  'ConsultationPayment': 'Thanh toán tư vấn',
  'ExpertPayout': 'Chi trả chuyên gia',
  'ConsultationRefund': 'Hoàn tiền tư vấn',
  'MissionDonation': 'Quyên góp nhiệm vụ',
  'RescuerReward': 'Thưởng cứu hộ',
  'CatchingPayment': 'Thanh toán bắt rắn',
  'CatcherPayout': 'Chi trả người bắt rắn',
  'CatchingRefund': 'Hoàn tiền bắt rắn',
  'CatchingDeposit': 'Đặt cọc bắt rắn',
  'SnakebiteIncidentPayment': 'Thanh toán sự cố rắn cắn',
  'SnakebiteIncidentRefund': 'Hoàn tiền sự cố rắn cắn',
  'PlatformFee': 'Phí nền tảng',
  'WalletTopup': 'Nạp ví',
  'WalletWithdraw': 'Rút ví',
  'AdminAdjustment': 'Điều chỉnh admin',
  'WithdrawalInitiated': 'Khởi tạo rút tiền',
};

/// Whether a transaction type is a credit (money in) from the user's perspective
const Set<String> kCreditTypes = {
  'ExpertPayout',
  'RescuerReward',
  'CatcherPayout',
  'ConsultationRefund',
  'CatchingRefund',
  'SnakebiteIncidentRefund',
  'WalletTopup',
  'AdminAdjustment',
};

bool isCredit(String transactionType) => kCreditTypes.contains(transactionType);

String transTypeLabel(String type) => kTransTypeLabels[type] ?? type;

// ── Model ──────────────────────────────────────────────────────────────────

class TransactionInfo {
  final String id;
  final String userName;
  final String fullName;
  final String referenceId;
  final double amount;
  final String currency;
  final String status;
  final String transactionType;
  final String description;
  final String paymentMethod;
  final String externalTransactionId;
  final DateTime createdAt;

  TransactionInfo({
    required this.id,
    required this.userName,
    required this.fullName,
    required this.referenceId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.transactionType,
    required this.description,
    required this.paymentMethod,
    required this.externalTransactionId,
    required this.createdAt,
  });

  factory TransactionInfo.fromJson(Map<String, dynamic> json) {
    return TransactionInfo(
      id: json['id'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      referenceId: json['referenceId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'VND',
      status: json['status'] as String? ?? '',
      transactionType: json['transactionType'] as String? ?? '',
      description: json['description'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? '',
      externalTransactionId: json['externalTransactionId'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  bool get hasExternalTransactionId => externalTransactionId.trim().isNotEmpty;

  bool get isPaid => status.trim().toLowerCase() == 'paid';

  bool get isPayOsPayment => paymentMethod.trim().toUpperCase() == 'PAYOS';

  bool matchesPrefix(String prefix, int? orderCode) {
    if (orderCode == null) {
      return true;
    }

    return description.startsWith('$prefix$orderCode');
  }

  bool matchesTransactionType(String expectedType) {
    return transactionType == expectedType;
  }
}

// ── Repository ─────────────────────────────────────────────────────────────

class TransactionRepository {
  final HttpService _httpService;

  TransactionRepository(this._httpService);

  /// GET /api/transactions
  Future<List<TransactionInfo>> getTransactions({
    String? userId,
    String? transType,
    String? referenceId,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final params = <String, dynamic>{
        'PageNumber': pageNumber,
        'PageSize': pageSize,
      };
      if (userId != null) params['UserId'] = userId;
      if (transType != null) params['TransType'] = transType;
      if (referenceId != null) params['ReferenceId'] = referenceId;

      debugPrint(
        '💳 GET /api/transactions  page=$pageNumber size=$pageSize'
        '${transType != null ? " type=$transType" : ""}',
      );
      final response = await _httpService.get(
        '/api/transactions',
        queryParameters: params,
      );
      final body = response.data as Map<String, dynamic>;
      // Support both wrapped (data.items / data as list) and bare list
      final dynamic raw = body['data'];
      List<dynamic> list;
      if (raw is List) {
        list = raw;
      } else if (raw is Map && raw['items'] is List) {
        list = raw['items'] as List;
      } else {
        list = [];
      }
      return list
          .map((e) => TransactionInfo.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('❌ getTransactions: ${e.message}');
      throw Exception('Không thể tải lịch sử giao dịch. Vui lòng thử lại.');
    }
  }

  /// GET /api/transactions/{id}
  Future<TransactionInfo> getTransactionById(String id) async {
    try {
      debugPrint('🔍 GET /api/transactions/$id');
      final response = await _httpService.get('/api/transactions/$id');
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? body;
      return TransactionInfo.fromJson(data);
    } on DioException catch (e) {
      debugPrint('❌ getTransactionById: ${e.message}');
      throw Exception('Không tìm thấy giao dịch.');
    }
  }
}
