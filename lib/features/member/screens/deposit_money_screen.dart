import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/handlers/payment_deep_link_coordinator.dart';
import '../../../core/payments/payos_payment_verifier.dart';
import '../../../core/payments/payos_pending_context.dart';
import '../../../core/payments/payos_pending_store.dart';
import '../../wallet/repository/wallet_repository.dart';

/// Deposit Money Screen — top up the SnakeAidPay wallet via PayOS.
class DepositMoneyScreen extends ConsumerStatefulWidget {
  const DepositMoneyScreen({super.key});

  @override
  ConsumerState<DepositMoneyScreen> createState() => _DepositMoneyScreenState();
}

class _DepositMoneyScreenState extends ConsumerState<DepositMoneyScreen> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  WalletInfo? _walletInfo;
  bool _isLoadingWallet = true;
  bool _isCreatingPayment = false;
  PayOsPendingContext? _pendingTopupContext;
  String? _pendingCheckoutUrl;

  static const _kPrefUrl = 'topup_pending_checkout_url';
  static const _pendingStore = PayOsPendingStore('payos_pending_topup_context');

  StreamSubscription<PaymentDeepLinkEvent>? _deepLinkSub;
  int? _lastHandledDeepLinkEventId;

  static const List<int> _quickAmounts = [
    50000,
    100000,
    200000,
    500000,
    1000000,
    2000000,
  ];

  @override
  void initState() {
    super.initState();
    _loadWallet();
    _loadPendingTopup();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _deepLinkSub?.cancel();
    super.dispose();
  }

  Future<void> _loadWallet() async {
    try {
      final wallet = await ref.read(walletRepositoryProvider).getWalletInfo();
      if (mounted)
        setState(() {
          _walletInfo = wallet;
          _isLoadingWallet = false;
        });
    } catch (_) {
      if (mounted) setState(() => _isLoadingWallet = false);
    }
  }

  Future<void> _loadPendingTopup() async {
    final pendingContext = await _pendingStore.load();
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(_kPrefUrl);
    if (pendingContext != null && url != null && mounted) {
      setState(() {
        _pendingTopupContext = pendingContext;
        _pendingCheckoutUrl = url;
      });
    }
  }

  Future<void> _savePendingTopup(
    PayOsPendingContext pendingContext,
    String url,
  ) async {
    await _pendingStore.save(pendingContext);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefUrl, url);
  }

  Future<void> _clearPendingTopup() async {
    await _pendingStore.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPrefUrl);
    if (mounted) {
      setState(() {
        _pendingTopupContext = null;
        _pendingCheckoutUrl = null;
      });
    }
  }

  void _initDeepLinks() {
    final coordinator = ref.read(paymentDeepLinkCoordinatorProvider);
    _deepLinkSub = coordinator.stream.listen(_handleDeepLinkEvent);

    final latest = coordinator.latestEvent;
    if (latest != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleDeepLinkEvent(latest);
      });
    }
  }

  Future<void> _handleDeepLinkEvent(PaymentDeepLinkEvent event) async {
    if (!mounted || _lastHandledDeepLinkEventId == event.eventId) return;
    _lastHandledDeepLinkEventId = event.eventId;
    final pendingContext = _pendingTopupContext;
    if (pendingContext == null) return;

    if (event.isCancelled) {
      await _clearPendingTopup();
      await _loadWallet();
      if (!mounted) return;
      _showResultDialog(
        success: false,
        title: 'Đã hủy thanh toán',
        message: 'Bạn đã hủy giao dịch nạp tiền PayOS.',
      );
      return;
    }

    if (!event.isSuccess) {
      return;
    }

    final verifier = ref.read(payOsPaymentVerifierProvider);
    var result = await verifier.verify(context: pendingContext, event: event);

    if (result.shouldFallbackConfirm) {
      final isConfirmed = await ref
          .read(walletRepositoryProvider)
          .confirmPayment(transactionId: pendingContext.transactionId);
      if (isConfirmed) {
        result = const PayOsVerificationResult(
          status: PayOsVerificationStatus.confirmed,
          message:
              'Số dư ví đã được cập nhật sau khi PayOS xác nhận giao dịch.',
        );
      } else {
        result = await verifier.verify(context: pendingContext);
      }
    }

    if (result.status == PayOsVerificationStatus.confirmed ||
        result.status == PayOsVerificationStatus.mismatch) {
      await _clearPendingTopup();
    }

    await _loadWallet();
    if (!mounted) return;
    switch (result.status) {
      case PayOsVerificationStatus.confirmed:
        _showResultDialog(
          success: true,
          title: 'Nạp tiền thành công',
          message:
              'Số dư ví đã được cập nhật sau khi PayOS xác nhận giao dịch.',
        );
        break;
      case PayOsVerificationStatus.mismatch:
        _showResultDialog(
          success: false,
          title: 'Không thể xác nhận giao dịch',
          message: result.message,
        );
        break;
      case PayOsVerificationStatus.pendingBackendConfirmation:
      case PayOsVerificationStatus.notFound:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Đã quay lại từ PayOS nhưng giao dịch chưa được backend xác nhận. Bạn có thể kiểm tra lại sau.',
            ),
          ),
        );
        break;
      case PayOsVerificationStatus.cancelled:
        break;
    }
  }

  Future<void> _onDeposit() async {
    // Block new order when a pending topup exists
    if (_pendingCheckoutUrl != null) {
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.pending_actions_rounded, color: Color(0xFFFF9800)),
              SizedBox(width: 8),
              Text(
                'Bạn có đơn chưa hoàn tất',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Vui lòng hoàn thành hoặc bỏ qua đơn nạp tiền hiện tại trước khi tạo đơn mới.',
            style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '§Óng',
                style: TextStyle(color: Color(0xFF888888)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final uri = Uri.parse(_pendingCheckoutUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Tiếp tục thanh toán'),
            ),
          ],
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    final raw = _amountController.text
        .replaceAll('.', '')
        .replaceAll(',', '')
        .trim();
    final amount = int.tryParse(raw) ?? 0;
    setState(() => _isCreatingPayment = true);
    try {
      final result = await ref
          .read(walletRepositoryProvider)
          .createTopupLink(amount: amount);
      if (!mounted) return;
      final pendingContext = PayOsPendingContext(
        flowType: PayOsFlowType.topup,
        transactionId: result.transactionId,
        orderCode: result.orderCode,
        startedAt: DateTime.now(),
      );
      _pendingTopupContext = pendingContext;
      _pendingCheckoutUrl = result.checkoutUrl;
      await _savePendingTopup(pendingContext, result.checkoutUrl);
      setState(() => _isCreatingPayment = false);
      final uri = Uri.parse(result.checkoutUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await Clipboard.setData(ClipboardData(text: result.checkoutUrl));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã sao chép link thanh toán vào clipboard.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCreatingPayment = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: const Color(0xFFDC3545),
          ),
        );
      }
    }
  }

  void _showResultDialog({
    required bool success,
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: success
                    ? const Color(0xFF228B22).withOpacity(0.1)
                    : const Color(0xFFDC3545).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                success ? Icons.check_circle : Icons.cancel,
                color: success
                    ? const Color(0xFF228B22)
                    : const Color(0xFFDC3545),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Color(0xFF888888)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (success) Navigator.of(context).pop();
            },
            child: Text(
              'Đóng',
              style: TextStyle(
                color: success
                    ? const Color(0xFF228B22)
                    : const Color(0xFFDC3545),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBalance(double amount) {
    final f = amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return '$f đ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // App Bar
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFDDDDDD), width: 1),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 56,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFF333333),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'Nạp Tiền',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF228B22), Color(0xFF1a6b1a)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF228B22).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white70,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Ví SnakeAidPay',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Số dư hiện tại',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (_isLoadingWallet)
                            const SizedBox(
                              height: 40,
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                            )
                          else
                            Text(
                              _formatBalance(_walletInfo?.balance ?? 0),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Pending topup banner
                    if (_pendingCheckoutUrl != null)
                      _PendingTopupBanner(
                        checkoutUrl: _pendingCheckoutUrl!,
                        onDismiss: _clearPendingTopup,
                      ),

                    // Amount input
                    const Text(
                      'Số tiền nạp',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF228B22),
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        suffixText: 'đ',
                        suffixStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF888888),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFDDDDDD),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF228B22),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        final v = int.tryParse(
                          (value ?? '').replaceAll('.', '').replaceAll(',', ''),
                        );
                        if (v == null || v <= 0) return 'Vui lòng nhập số tiền';
                        if (v < 2000) return 'Số tiền tối thiểu là 2.000đ';
                        if (v > 50000000)
                          return 'Số tiền tối đa là 50.000.000đ';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Quick amounts
                    const Text(
                      'Chọn nhanh',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _quickAmounts.map((amount) {
                        return _QuickAmountButton(
                          amount: amount,
                          onTap: () =>
                              _amountController.text = amount.toString(),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    // PayOS info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F8FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF228B22).withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            color: Color(0xFF228B22),
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Thanh toán qua PayOS',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Sau khi nhấn "Thanh Toán Qua PayOS", bạn sẽ được chuyển đến trang thanh toán. Quét mã QR hoặc dùng Internet Banking để hoàn tất.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF555555),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFFF9800),
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '• Số tiền tối thiểu: 2.000đ\n'
                              '• Số tiền tối đa: 50.000.000đ\n'
                              '• Tiền được cộng vào ví ngay sau khi giao dịch thành công',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF333333),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Bottom CTA
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFDDDDDD), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isCreatingPayment || _pendingCheckoutUrl != null)
                    ? null
                    : _onDeposit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pendingCheckoutUrl != null
                      ? const Color(0xFFFF9800)
                      : const Color(0xFF228B22),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: _pendingCheckoutUrl != null
                      ? const Color(0xFFFF9800).withOpacity(0.6)
                      : const Color(0xFF228B22).withOpacity(0.6),
                ),
                child: _isCreatingPayment
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _pendingCheckoutUrl != null
                            ? 'Có Đơn Nạp Tiền Chưa Hoàn Tất'
                            : 'Thanh Toán Qua PayOS',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── _PendingTopupBanner ──────────────────────────────────────────────────────

class _PendingTopupBanner extends StatelessWidget {
  final String checkoutUrl;
  final VoidCallback onDismiss;

  const _PendingTopupBanner({
    required this.checkoutUrl,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.pending_actions_rounded,
            color: Color(0xFFFF9800),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bạn có đơn nạp tiền chưa hoàn tất',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Nhấn "Tiếp tục" để quay lại trang thanh toán.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final uri = Uri.parse(checkoutUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Tiếp tục'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: onDismiss,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF888888),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: const Text('Bỏ qua'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── _QuickAmountButton ───────────────────────────────────────────────────────

class _QuickAmountButton extends StatelessWidget {
  final int amount;
  final VoidCallback onTap;

  const _QuickAmountButton({required this.amount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF228B22)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _fmt(amount),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF228B22),
          ),
        ),
      ),
    );
  }

  String _fmt(int v) {
    if (v >= 1000000) {
      return '${(v / 1000000).toStringAsFixed(v % 1000000 == 0 ? 0 : 1)}tr';
    }
    return '${(v / 1000).toInt()}k';
  }
}
