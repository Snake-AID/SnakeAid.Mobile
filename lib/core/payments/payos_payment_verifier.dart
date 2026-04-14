import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../handlers/payment_deep_link_coordinator.dart';
import '../../features/wallet/repository/transaction_repository.dart'
    as wallet_tx;
import 'payos_pending_context.dart';

enum PayOsVerificationStatus {
  confirmed,
  cancelled,
  pendingBackendConfirmation,
  mismatch,
  notFound,
}

class PayOsVerificationResult {
  final PayOsVerificationStatus status;
  final wallet_tx.TransactionInfo? transaction;
  final String message;
  final bool shouldFallbackConfirm;

  const PayOsVerificationResult({
    required this.status,
    required this.message,
    this.transaction,
    this.shouldFallbackConfirm = false,
  });
}

final payOsPaymentVerifierProvider = Provider<PayOsPaymentVerifier>((ref) {
  return PayOsPaymentVerifier(
    ref.read(wallet_tx.transactionRepositoryProvider),
  );
});

class PayOsPaymentVerifier {
  final wallet_tx.TransactionRepository _transactionRepository;

  const PayOsPaymentVerifier(this._transactionRepository);

  Future<PayOsVerificationResult> verify({
    required PayOsPendingContext context,
    PaymentDeepLinkEvent? event,
    List<Duration> retryDelays = const [
      Duration(milliseconds: 500),
      Duration(seconds: 1),
      Duration(seconds: 2),
    ],
  }) async {
    if (event?.isCancelled == true) {
      return const PayOsVerificationResult(
        status: PayOsVerificationStatus.cancelled,
        message: 'Người dùng đã hủy thanh toán PayOS.',
      );
    }

    if (event != null &&
        context.orderCode != null &&
        event.orderCode != null &&
        event.orderCode != context.orderCode) {
      return PayOsVerificationResult(
        status: PayOsVerificationStatus.mismatch,
        message: 'orderCode không khớp với giao dịch PayOS đang chờ.',
      );
    }

    wallet_tx.TransactionInfo? lastTransaction;
    for (var attempt = 0; attempt <= retryDelays.length; attempt++) {
      try {
        lastTransaction = await _transactionRepository.getTransactionById(
          context.transactionId,
        );
      } catch (_) {
        lastTransaction = null;
      }

      if (_isConfirmed(lastTransaction, context)) {
        return PayOsVerificationResult(
          status: PayOsVerificationStatus.confirmed,
          transaction: lastTransaction,
          message: 'Giao dịch PayOS đã được backend xác nhận.',
        );
      }

      if (attempt < retryDelays.length) {
        await Future<void>.delayed(retryDelays[attempt]);
      }
    }

    if (lastTransaction == null) {
      return const PayOsVerificationResult(
        status: PayOsVerificationStatus.notFound,
        message: 'Chưa lấy được transaction detail từ backend.',
      );
    }

    final hasMatchingType = lastTransaction.matchesTransactionType(
      context.expectedTransactionType,
    );
    final hasMatchingPrefix = lastTransaction.matchesPrefix(
      context.expectedPrefix,
      context.orderCode,
    );

    if (!hasMatchingType || !hasMatchingPrefix) {
      return PayOsVerificationResult(
        status: PayOsVerificationStatus.mismatch,
        transaction: lastTransaction,
        message: 'Transaction trả về không khớp flow PayOS đang xử lý.',
      );
    }

    return PayOsVerificationResult(
      status: PayOsVerificationStatus.pendingBackendConfirmation,
      transaction: lastTransaction,
      message: 'Backend chưa phản ánh giao dịch PayOS hoàn tất.',
      shouldFallbackConfirm: true,
    );
  }

  bool _isConfirmed(
    wallet_tx.TransactionInfo? transaction,
    PayOsPendingContext context,
  ) {
    if (transaction == null) {
      return false;
    }

    return transaction.isPayOsPayment &&
        transaction.hasExternalTransactionId &&
        transaction.matchesTransactionType(context.expectedTransactionType) &&
        transaction.matchesPrefix(context.expectedPrefix, context.orderCode);
  }
}
