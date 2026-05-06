import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/http_service.dart';
import '../../../core/providers/http_provider.dart';

final withdrawalRepositoryProvider = Provider<WithdrawalRepository>((ref) {
  return WithdrawalRepository(ref.watch(httpServiceProvider));
});

// ── Models ─────────────────────────────────────────────────────────────────

class BankInfo {
  final String? key;
  final String? code;
  final String shortName;
  final String bin;
  final String name;
  final String vietQrStatus;
  final bool lookupSupported;
  final String? swiftCode;
  final String logoUrl;

  BankInfo({
    this.key,
    this.code,
    required this.shortName,
    required this.bin,
    required this.name,
    required this.vietQrStatus,
    required this.lookupSupported,
    this.swiftCode,
    required this.logoUrl,
  });

  factory BankInfo.fromJson(Map<String, dynamic> json) {
    final k = json['key'] as String? ?? '';
    final logo = json['logo'] as String? ?? '';
    return BankInfo(
      key: k.isEmpty ? null : k,
      code: json['code'] as String?,
      shortName: json['shortName'] as String? ?? '',
      bin: json['bin'] as String? ?? '',
      name: json['name'] as String? ?? '',
      vietQrStatus: json['vietQrStatus'] as String? ?? '',
      lookupSupported: json['lookupSupported'] as bool? ?? false,
      swiftCode: json['swiftCode'] as String?,
      logoUrl: logo, // will be replaced by VietQR API logo after fetch
    );
  }

  BankInfo copyWith({String? logoUrl}) => BankInfo(
    key: key,
    code: code,
    shortName: shortName,
    bin: bin,
    name: name,
    vietQrStatus: vietQrStatus,
    lookupSupported: lookupSupported,
    swiftCode: swiftCode,
    logoUrl: logoUrl ?? this.logoUrl,
  );
}

class WithdrawalInfo {
  final String id;
  final String userId;
  final double amount;
  final String bankAccount; // may be masked
  final String bankName;
  final String accountHolderName;
  final String? bankBin;
  final String status; // Pending/Approved/Rejected/Completed/Failed
  final DateTime? processedAt;
  final String? rejectionReason;
  final String? vietQrPayload;
  final String? vietQrImageBase64;
  final DateTime createdAt;

  WithdrawalInfo({
    required this.id,
    required this.userId,
    required this.amount,
    required this.bankAccount,
    required this.bankName,
    required this.accountHolderName,
    this.bankBin,
    required this.status,
    this.processedAt,
    this.rejectionReason,
    this.vietQrPayload,
    this.vietQrImageBase64,
    required this.createdAt,
  });

  factory WithdrawalInfo.fromJson(Map<String, dynamic> json) {
    final d = json['data'] as Map<String, dynamic>? ?? json;
    return WithdrawalInfo(
      id: d['id'] as String? ?? '',
      userId: d['userId'] as String? ?? '',
      amount: (d['amount'] as num?)?.toDouble() ?? 0,
      bankAccount: d['bankAccount'] as String? ?? '',
      bankName: d['bankName'] as String? ?? '',
      accountHolderName: d['accountHolderName'] as String? ?? '',
      bankBin: d['bankBin'] as String?,
      status: d['status'] as String? ?? '',
      processedAt: d['processedAt'] != null
          ? DateTime.tryParse(d['processedAt'] as String)
          : null,
      rejectionReason: d['rejectionReason'] as String?,
      vietQrPayload: d['vietQrPayload'] as String?,
      vietQrImageBase64: d['vietQrImageBase64'] as String?,
      createdAt: d['createdAt'] != null
          ? DateTime.parse(d['createdAt'] as String)
          : DateTime.now(),
    );
  }
}

// ── Repository ─────────────────────────────────────────────────────────────

class WithdrawalRepository {
  final HttpService _httpService;

  WithdrawalRepository(this._httpService);

  // Cache so VietQR is only fetched once per session
  static Map<String, String>? _vietQRLogoCache;

  /// Fetch bin→logoUrl map from VietQR public API.
  Future<Map<String, String>> _fetchVietQRLogosByBin() async {
    if (_vietQRLogoCache != null) return _vietQRLogoCache!;
    try {
      debugPrint('🖼️ GET https://api.vietqr.io/v2/banks (logos)');
      final dio = Dio();
      final response = await dio.get(
        'https://api.vietqr.io/v2/banks',
        options: Options(
          receiveTimeout: const Duration(seconds: 6),
          sendTimeout: const Duration(seconds: 6),
        ),
      );
      final list = (response.data['data'] as List<dynamic>?) ?? [];
      _vietQRLogoCache = {
        for (final item in list)
          if ((item['bin'] as String?)?.isNotEmpty == true &&
              (item['logo'] as String?)?.isNotEmpty == true)
            item['bin'] as String: item['logo'] as String,
      };
      debugPrint('✅ VietQR logos loaded: ${_vietQRLogoCache!.length} banks');
      return _vietQRLogoCache!;
    } catch (e) {
      debugPrint('⚠️ VietQR logo fetch failed: $e');
      return {};
    }
  }

  /// GET /api/wallet/banks (enriched with VietQR logos)
  Future<List<BankInfo>> getBanks() async {
    try {
      debugPrint('🏦 GET /api/wallet/banks');
      final response = await _httpService.get('/api/wallet/banks');
      final body = response.data as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>? ?? [];
      final banks = list
          .map((e) => BankInfo.fromJson(e as Map<String, dynamic>))
          .toList();

      // Enrich with VietQR confirmed logo URLs
      final logoMap = await _fetchVietQRLogosByBin();
      if (logoMap.isNotEmpty) {
        return banks.map((b) {
          final logo = logoMap[b.bin];
          return logo != null ? b.copyWith(logoUrl: logo) : b;
        }).toList();
      }
      return banks;
    } on DioException catch (e) {
      debugPrint('❌ getBanks: ${e.message}');
      throw Exception('Không thể tải danh sách ngân hàng.');
    }
  }

  /// POST /api/withdrawals/create
  Future<WithdrawalInfo> createWithdrawal({
    required double amount,
    required String bankAccount,
    required String bankName,
    required String accountHolderName,
    required String bankBin,
  }) async {
    try {
      debugPrint('💸 POST /api/withdrawals/create  amount=$amount');
      final response = await _httpService.post(
        '/api/withdrawals/create',
        data: {
          'amount': amount.toInt(),
          'bankAccount': bankAccount,
          'bankName': bankName,
          'accountHolderName': accountHolderName,
          'bankBin': bankBin,
        },
      );
      return WithdrawalInfo.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('❌ createWithdrawal: ${e.message}');
      final data = e.response?.data;
      final errorMap = data is Map ? data['error'] as Map? : null;
      final code = errorMap?['code'] as String?;
      final msg = data is Map ? data['message'] as String? : null;
      if (code == 'WITHDRAWAL_INSUFFICIENT_BALANCE') {
        throw Exception('Số dư không đủ để thực hiện rút tiền.');
      }
      if (code == 'WITHDRAWAL_DAILY_LIMIT_EXCEEDED') {
        throw Exception('Đã vượt hạn mức rút tiền trong ngày (10.000.000đ).');
      }
      throw Exception(
        msg ?? 'Tạo yêu cầu rút tiền thất bại. Vui lòng thử lại.',
      );
    }
  }

  /// GET /api/withdrawals/me
  Future<List<WithdrawalInfo>> getMyWithdrawals() async {
    try {
      debugPrint('📋 GET /api/withdrawals/me');
      final response = await _httpService.get('/api/withdrawals/me');
      final body = response.data as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => WithdrawalInfo.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('❌ getMyWithdrawals: ${e.message}');
      throw Exception('Không thể tải lịch sử rút tiền.');
    }
  }

  /// GET /api/withdrawals/{id}
  Future<WithdrawalInfo> getWithdrawalById(String id) async {
    try {
      debugPrint('🔍 GET /api/withdrawals/$id');
      final response = await _httpService.get('/api/withdrawals/$id');
      return WithdrawalInfo.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('❌ getWithdrawalById: ${e.message}');
      throw Exception('Không tìm thấy yêu cầu rút tiền.');
    }
  }

  /// POST /api/withdrawals/{id}/cancel
  Future<WithdrawalInfo> cancelWithdrawal(String id) async {
    try {
      debugPrint('🚫 POST /api/withdrawals/$id/cancel');
      final response = await _httpService.post(
        '/api/withdrawals/$id/cancel',
        data: {},
      );
      return WithdrawalInfo.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('❌ cancelWithdrawal: ${e.message}');
      final data = e.response?.data;
      final msg = data is Map ? data['message'] as String? : null;
      throw Exception(msg ?? 'Hủy yêu cầu rút tiền thất bại.');
    }
  }
}
