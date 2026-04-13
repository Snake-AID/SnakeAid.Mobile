import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snakeaid_mobile/core/handlers/payment_deep_link_coordinator.dart';
import 'package:snakeaid_mobile/core/payments/payos_payment_verifier.dart';
import 'package:snakeaid_mobile/core/payments/payos_pending_store.dart';
import 'package:snakeaid_mobile/features/wallet/repository/wallet_repository.dart';

class GlobalPaymentDeepLinkListener extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalPaymentDeepLinkListener({super.key, required this.child});

  @override
  ConsumerState<GlobalPaymentDeepLinkListener> createState() =>
      _GlobalPaymentDeepLinkListenerState();
}

class _GlobalPaymentDeepLinkListenerState
    extends ConsumerState<GlobalPaymentDeepLinkListener> {
  static const _kPrefUrl = 'topup_pending_checkout_url';
  static const _pendingStore = PayOsPendingStore('payos_pending_topup_context');

  StreamSubscription<PaymentDeepLinkEvent>? _sub;
  int? _lastHandledEventId;

  @override
  void initState() {
    super.initState();
    final coordinator = ref.read(paymentDeepLinkCoordinatorProvider);
    _sub = coordinator.stream.listen(_handleEvent);

    final latest = coordinator.latestEvent;
    if (latest != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleEvent(latest);
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _handleEvent(PaymentDeepLinkEvent event) async {
    if (!mounted || _lastHandledEventId == event.eventId) {
      return;
    }

    _lastHandledEventId = event.eventId;
    final pendingTopupContext = await _pendingStore.load();

    if (pendingTopupContext == null ||
        pendingTopupContext.transactionId.isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    if (event.isCancelled) {
      await _clearPendingTopup(prefs);
      if (!mounted) return;
      _showSnackBar('Bạn đã hủy thanh toán.', const Color(0xFFFF8F00));
      return;
    }

    if (!event.isSuccess) {
      if (!mounted || event.reason == null || event.reason!.isEmpty) return;
      _showSnackBar(
        'Thanh toán đã quay về app nhưng chưa xác nhận xong. Vui lòng kiểm tra lại.',
        const Color(0xFFDC3545),
      );
      return;
    }

    final verifier = ref.read(payOsPaymentVerifierProvider);
    var result = await verifier.verify(
      context: pendingTopupContext,
      event: event,
    );

    if (result.shouldFallbackConfirm) {
      await ref
          .read(walletRepositoryProvider)
          .confirmPayment(transactionId: pendingTopupContext.transactionId);
      result = await verifier.verify(context: pendingTopupContext);
    }

    if (result.status == PayOsVerificationStatus.confirmed ||
        result.status == PayOsVerificationStatus.mismatch) {
      await _clearPendingTopup(prefs);
    }

    if (!mounted) return;
    if (result.status == PayOsVerificationStatus.confirmed) {
      _showSnackBar(
        'Đã quay lại từ PayOS. Số dư ví sẽ được cập nhật ngay.',
        const Color(0xFF228B22),
      );
      return;
    }

    if (result.status == PayOsVerificationStatus.mismatch) {
      _showSnackBar(result.message, const Color(0xFFDC3545));
      return;
    }

    _showSnackBar(
      'Đã quay lại từ PayOS nhưng backend chưa xác nhận xong giao dịch.',
      const Color(0xFFFF8F00),
    );
  }

  Future<void> _clearPendingTopup(SharedPreferences prefs) async {
    await _pendingStore.clear();
    await prefs.remove(_kPrefUrl);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
