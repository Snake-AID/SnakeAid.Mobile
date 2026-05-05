import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/handlers/payment_deep_link_coordinator.dart';
import '../../../../core/payments/payos_payment_verifier.dart';
import '../../../../core/payments/payos_pending_context.dart';
import '../../providers/expert_detail_provider.dart';
import '../../providers/consultation_bookings_provider.dart';
import '../../models/consultation_payment_response.dart';
import '../../repository/consultation_repository.dart';
import '../../../wallet/repository/wallet_repository.dart';
import 'emergency_request_waiting_screen.dart';

// Primary color constant - Green for member flow (consultation)
const Color _primaryColor = Color(0xFF228B22);
const Color _backgroundColor = Color(0xFFF6F8F6);

/// Payment method enum
enum PaymentMethod { payos, snakeaidPay }

/// Payment Confirmation Screen
/// Allows users to review consultation details and complete payment
class PaymentConfirmationScreen extends ConsumerStatefulWidget {
  final String expertId;
  final String? consultationType;
  final String? selectedDate;
  final String? selectedTime;
  final String? duration;
  final String? price;
  final String? problemDescription;
  final String? questions;

  /// Booking ID for payment API call
  final String? bookingId;

  /// Real consultation ID from createBooking response
  final String? consultationId;

  /// Expert name from createBooking response
  final String? expertName;

  const PaymentConfirmationScreen({
    super.key,
    required this.expertId,
    this.consultationType,
    this.selectedDate,
    this.selectedTime,
    this.duration,
    this.price,
    this.problemDescription,
    this.questions,
    this.bookingId,
    this.consultationId,
    this.expertName,
  });

  @override
  ConsumerState<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState
    extends ConsumerState<PaymentConfirmationScreen>
    with WidgetsBindingObserver {
  static const String _instantRequestCachePrefix =
      'last_emergency_request_for_expert_';

  PaymentMethod _selectedPaymentMethod = PaymentMethod.payos;
  PaymentMethod? _lockedPaymentMethod;
  bool _agreedToTerms = false;
  bool _isPaymentLoading = false;
  double? _walletBalance;
  bool _isLoadingWallet = true;
  StreamSubscription<PaymentDeepLinkEvent>? _payOsCallbackSub;
  bool _isHandlingPayOsCallback = false;
  bool _isShowingPaymentStatusDialog = false;
  int? _lastHandledPayOsEventId;
  int? _pendingPayOsOrderCode;
  String? _pendingPayOsTransactionId;
  String? _pendingEmergencyRequestId;
  String? _pendingBookingId;
  String? _pendingWalletTopupTransactionId;
  int? _pendingWalletTopupOrderCode;
  DateTime? _pendingWalletTopupStartedAt;

  Future<void> _cacheLastEmergencyRequestId(String requestId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_instantRequestCachePrefix${widget.expertId}',
      requestId,
    );
  }

  Future<String?> _getCachedEmergencyRequestId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_instantRequestCachePrefix${widget.expertId}');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initPayOsCallbackListener();
    _fetchWallet();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _payOsCallbackSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _tryAutoFinalizePendingPayOs();
      _tryRefreshPendingWalletTopup();
    }
  }

  bool get _hasBookingId =>
      widget.bookingId != null && widget.bookingId!.trim().isNotEmpty;

  bool get _isInstantFlow {
    if (_hasBookingId) return false;
    final normalized = (widget.consultationType ?? '').trim().toLowerCase();
    return normalized == 'instant';
  }

  Future<void> _fetchWallet() async {
    try {
      final repo = ref.read(consultationRepositoryProvider);
      final walletData = await repo.getMyWallet();
      if (mounted) {
        setState(() {
          _walletBalance = (walletData['balance'] as num?)?.toDouble();
          _isLoadingWallet = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch wallet: $e');
      if (mounted) {
        setState(() {
          _isLoadingWallet = false;
        });
      }
    }
  }

  void _initPayOsCallbackListener() {
    final coordinator = ref.read(paymentDeepLinkCoordinatorProvider);
    _payOsCallbackSub = coordinator.stream.listen(_dispatchPayOsCallbackEvent);

    final latest = coordinator.latestEvent;
    if (latest != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dispatchPayOsCallbackEvent(latest);
      });
    }
  }

  Future<void> _dispatchPayOsCallbackEvent(PaymentDeepLinkEvent event) async {
    if (!mounted || _lastHandledPayOsEventId == event.eventId) return;
    _lastHandledPayOsEventId = event.eventId;

    final hasPendingConsultationPayment =
        _pendingPayOsTransactionId != null &&
        _pendingPayOsTransactionId!.isNotEmpty;
    final hasPendingWalletTopup =
        _pendingWalletTopupTransactionId != null &&
        _pendingWalletTopupTransactionId!.isNotEmpty;

    if (!hasPendingConsultationPayment && !hasPendingWalletTopup) return;
    if (hasPendingConsultationPayment &&
        _pendingPayOsOrderCode != null &&
        event.orderCode != _pendingPayOsOrderCode) {
      return;
    }
    if (_isHandlingPayOsCallback) return;
    _isHandlingPayOsCallback = true;

    try {
      if (hasPendingConsultationPayment) {
        await _handlePayOsCallbackEvent(event);
      } else {
        await _handleWalletTopupCallbackEvent(event);
      }
    } finally {
      _isHandlingPayOsCallback = false;
    }
  }

  Future<void> _handleWalletTopupCallbackEvent(
    PaymentDeepLinkEvent event,
  ) async {
    if (event.isCancelled) {
      _clearPendingWalletTopupContext();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn đã hủy nạp tiền vào ví.'),
          backgroundColor: Color(0xFFFF8F00),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!event.isSuccess) return;

    final txId = _pendingWalletTopupTransactionId;
    if (txId == null || txId.isEmpty) {
      return;
    }

    final verifier = ref.read(payOsPaymentVerifierProvider);
    var result = await verifier.verify(
      context: PayOsPendingContext(
        flowType: PayOsFlowType.topup,
        transactionId: txId,
        orderCode: _pendingWalletTopupOrderCode,
        startedAt: _pendingWalletTopupStartedAt ?? DateTime.now(),
      ),
      event: event,
    );

    if (result.shouldFallbackConfirm) {
      final isConfirmed = await ref
          .read(walletRepositoryProvider)
          .confirmPayment(transactionId: txId);
      if (isConfirmed) {
        result = const PayOsVerificationResult(
          status: PayOsVerificationStatus.confirmed,
          message: 'Số dư ví đã được cập nhật sau khi PayOS xác nhận giao dịch.',
        );
      } else {
        result = await verifier.verify(
          context: PayOsPendingContext(
            flowType: PayOsFlowType.topup,
            transactionId: txId,
            orderCode: _pendingWalletTopupOrderCode,
            startedAt: _pendingWalletTopupStartedAt ?? DateTime.now(),
          ),
        );
      }
    }

    if (result.status == PayOsVerificationStatus.confirmed) {
      _clearPendingWalletTopupContext();
      await _fetchWallet();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nạp tiền vào ví đã được xác nhận.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (result.status == PayOsVerificationStatus.mismatch) {
      _clearPendingWalletTopupContext();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Topup đã quay về app nhưng backend chưa xác nhận xong.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handlePayOsCallbackEvent(PaymentDeepLinkEvent event) async {
    if (event.isCancelled) {
      if (!mounted) return;
      setState(() {
        _isPaymentLoading = false;
      });
      _clearPendingPayOsContext();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn đã hủy thanh toán PayOS.'),
          backgroundColor: Color(0xFFFF8F00),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!event.isSuccess) return;

    final txId = _pendingPayOsTransactionId;
    if (txId == null || txId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isPaymentLoading = false;
      });
      _clearPendingPayOsContext();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thiếu transactionId để xác nhận thanh toán.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _isPaymentLoading = true;
    });
    _showPaymentStatusDialog();

    try {
      final verifier = ref.read(payOsPaymentVerifierProvider);
      final pendingContext = PayOsPendingContext(
        flowType: PayOsFlowType.consultation,
        transactionId: txId,
        orderCode: _pendingPayOsOrderCode,
        startedAt: DateTime.now(),
      );
      var result = await verifier.verify(context: pendingContext, event: event);

      if (result.shouldFallbackConfirm) {
        await _confirmConsultationPayOs(txId);
        result = await verifier.verify(context: pendingContext);
      }

      if (result.status != PayOsVerificationStatus.confirmed) {
        throw Exception(result.message);
      }

      ref.invalidate(consultationBookingsProvider);
      final emergencyRequestId = _pendingEmergencyRequestId;
      final bookingId = _pendingBookingId;
      _clearPendingPayOsContext();

      if (!mounted) return;
      setState(() {
        _isPaymentLoading = false;
      });

      if (emergencyRequestId != null && emergencyRequestId.isNotEmpty) {
        showEmergencyRequestModal(
          context,
          requestId: emergencyRequestId,
          expertId: widget.expertId,
          expertName: widget.expertName ?? 'Chuyên gia',
          initialStatus: 'PendingExpertResponse',
        );
      } else {
        context.go(
          '/consultation-home',
          extra: {'newConsultationId': bookingId},
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPaymentLoading = false;
      });
      _clearPendingPayOsContext();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      _hidePaymentStatusDialog();
    }
  }

  Future<ConsultationPaymentResponse> _confirmConsultationPayOs(
    String transactionId,
  ) async {
    final repo = ref.read(consultationRepositoryProvider);
    return repo.confirmConsultationPayment(transactionId);
  }

  Future<void> _tryAutoFinalizePendingPayOs() async {
    final txId = _pendingPayOsTransactionId;
    if (!mounted || txId == null || txId.isEmpty) return;
    if (_isHandlingPayOsCallback) return;

    _isHandlingPayOsCallback = true;
    _showPaymentStatusDialog();
    try {
      final verifier = ref.read(payOsPaymentVerifierProvider);
      final pendingContext = PayOsPendingContext(
        flowType: PayOsFlowType.consultation,
        transactionId: txId,
        orderCode: _pendingPayOsOrderCode,
        startedAt: DateTime.now(),
      );
      var result = await verifier.verify(context: pendingContext);

      if (!mounted) return;
      if (result.shouldFallbackConfirm) {
        await _confirmConsultationPayOs(txId);
        result = await verifier.verify(context: pendingContext);
      }

      if (result.status != PayOsVerificationStatus.confirmed) {
        return;
      }

      ref.invalidate(consultationBookingsProvider);

      final emergencyRequestId = _pendingEmergencyRequestId;
      final bookingId = _pendingBookingId;
      _clearPendingPayOsContext();

      if (!mounted) return;
      setState(() {
        _isPaymentLoading = false;
      });

      if (emergencyRequestId != null && emergencyRequestId.isNotEmpty) {
        showEmergencyRequestModal(
          context,
          requestId: emergencyRequestId,
          expertId: widget.expertId,
          expertName: widget.expertName ?? 'Chuyên gia',
          initialStatus: 'PendingExpertResponse',
        );
      } else {
        context.go(
          '/consultation-home',
          extra: {'newConsultationId': bookingId},
        );
      }
    } catch (e) {
      // No snackbar here to avoid noisy errors while status may still be processing.
      debugPrint('PayOS auto-confirm on resume failed: $e');
    } finally {
      _hidePaymentStatusDialog();
      _isHandlingPayOsCallback = false;
    }
  }

  Future<void> _tryRefreshPendingWalletTopup() async {
    final txId = _pendingWalletTopupTransactionId;
    if (!mounted || txId == null || txId.isEmpty) return;

    final startedAt = _pendingWalletTopupStartedAt;
    if (startedAt != null &&
        DateTime.now().difference(startedAt) > const Duration(hours: 2)) {
      _clearPendingWalletTopupContext();
      return;
    }

    final verifier = ref.read(payOsPaymentVerifierProvider);
    var result = await verifier.verify(
      context: PayOsPendingContext(
        flowType: PayOsFlowType.topup,
        transactionId: txId,
        orderCode: _pendingWalletTopupOrderCode,
        startedAt: startedAt ?? DateTime.now(),
      ),
    );

    if (result.shouldFallbackConfirm) {
      final isConfirmed = await ref
          .read(walletRepositoryProvider)
          .confirmPayment(transactionId: txId);
      if (isConfirmed) {
        result = const PayOsVerificationResult(
          status: PayOsVerificationStatus.confirmed,
          message: 'Số dư ví đã được cập nhật sau khi PayOS xác nhận giao dịch.',
        );
      } else {
        result = await verifier.verify(
          context: PayOsPendingContext(
            flowType: PayOsFlowType.topup,
            transactionId: txId,
            orderCode: _pendingWalletTopupOrderCode,
            startedAt: startedAt ?? DateTime.now(),
          ),
        );
      }
    }

    if (result.status == PayOsVerificationStatus.confirmed) {
      _clearPendingWalletTopupContext();
    }

    await _fetchWallet();
  }

  void _showPaymentStatusDialog() {
    if (!mounted || _isShowingPaymentStatusDialog) return;
    _isShowingPaymentStatusDialog = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Đang kiểm tra thanh toán'),
          content: const Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.6),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Hệ thống đang xác nhận trạng thái từ PayOS. Vui lòng đợi... ',
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      _isShowingPaymentStatusDialog = false;
    });
  }

  void _hidePaymentStatusDialog() {
    if (!mounted || !_isShowingPaymentStatusDialog) return;
    Navigator.of(context, rootNavigator: true).pop();
    _isShowingPaymentStatusDialog = false;
  }

  void _clearPendingPayOsContext() {
    _pendingPayOsOrderCode = null;
    _pendingPayOsTransactionId = null;
    _pendingEmergencyRequestId = null;
    _pendingBookingId = null;
  }

  void _clearPendingWalletTopupContext() {
    _pendingWalletTopupTransactionId = null;
    _pendingWalletTopupOrderCode = null;
    _pendingWalletTopupStartedAt = null;
  }

  Future<void> _startWalletTopup() async {
    final price = int.tryParse(_getPriceAmount()) ?? 0;
    final shortfall = price - (_walletBalance?.toInt() ?? 0);
    final suggestedAmount = shortfall > 0 ? shortfall : 1000;
    final amount = suggestedAmount.clamp(1000, 10000000).toDouble();

    try {
      final repo = ref.read(consultationRepositoryProvider);
      final topup = await repo.createWalletTopup(
        amount: amount,
        description: 'Nap tien vi tu consultation payment',
      );

      final checkoutUrl = topup['checkoutUrl']?.toString() ?? '';
      final topupTransactionId = topup['transactionId']?.toString() ?? '';
      final topupOrderCode = topup['orderCode'] is int
          ? topup['orderCode'] as int
          : int.tryParse(topup['orderCode']?.toString() ?? '');
      if (checkoutUrl.isEmpty) {
        throw Exception('Topup khong tra ve checkoutUrl');
      }

      final uri = Uri.tryParse(checkoutUrl);
      if (uri == null) {
        throw Exception('checkoutUrl topup khong hop le');
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw Exception('Khong the mo cong thanh toan topup');
      }

      _pendingWalletTopupTransactionId = topupTransactionId.isEmpty
          ? null
          : topupTransactionId;
      _pendingWalletTopupOrderCode = topupOrderCode;
      _pendingWalletTopupStartedAt = DateTime.now();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Da mo PayOS de nap ${_formatPrice(amount.toInt().toString())}. Thanh toan xong hay quay lai de tai lai so du.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await _fetchWallet();
    } catch (e) {
      _clearPendingWalletTopupContext();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handlePayment() async {
    // Booking flow has priority: when bookingId exists, never call emergency APIs.
    if (!_hasBookingId && _isInstantFlow) {
      setState(() => _isPaymentLoading = true);
      String? requestId;

      try {
        final repo = ref.read(consultationRepositoryProvider);
        final req = await repo.createEmergencyRequest(
          expertId: widget.expertId,
        );
        requestId = req.requestId;
        await _cacheLastEmergencyRequestId(requestId);
      } catch (e) {
        if (!mounted) return;

        final raw = e.toString().toLowerCase();
        final isActiveRequestConflict =
            raw.contains('active emergency request already exists') ||
            raw.contains('already exists for this expert') ||
            raw.contains('conflict');

        if (isActiveRequestConflict) {
          requestId = await _getCachedEmergencyRequestId();
          if (!mounted) return;
        }

        if (requestId == null || requestId.isEmpty) {
          setState(() => _isPaymentLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isActiveRequestConflict
                    ? 'Bạn đã có yêu cầu tư vấn ngay đang chờ chuyên gia. Vui lòng vào lại màn chờ.'
                    : e.toString().replaceFirst('Exception: ', ''),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }

      final paymentMethod = _selectedPaymentMethod == PaymentMethod.snakeaidPay
          ? 'WalletBalance'
          : 'PayOs';
      final resolvedRequestId = requestId;
      if (resolvedRequestId.isEmpty) {
        if (mounted) {
          setState(() => _isPaymentLoading = false);
        }
        return;
      }

      try {
        final repo = ref.read(consultationRepositoryProvider);
        final payment = await repo.payEmergencyRequest(
          resolvedRequestId,
          paymentMethod: paymentMethod,
        );

        if (_selectedPaymentMethod == PaymentMethod.payos) {
          await _handlePayOsFlow(
            payment,
            emergencyRequestId: resolvedRequestId,
          );
          if (!mounted) return;
          setState(() => _isPaymentLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Đã mở PayOS. Vui lòng hoàn tất thanh toán và quay lại ứng dụng.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        if (!mounted) return;
        setState(() => _isPaymentLoading = false);
        showEmergencyRequestModal(
          context,
          requestId: resolvedRequestId,
          expertId: widget.expertId,
          expertName: widget.expertName ?? 'Chuyên gia',
          initialStatus: 'PendingExpertResponse',
        );
      } catch (e) {
        if (!mounted) return;
        final raw = e.toString().toLowerCase();
        final likelyMethodLockedByBackend =
            raw.contains('already been paid') ||
            raw.contains('already paid') ||
            raw.contains('đã được trả') ||
            raw.contains('đã thanh toán');
        if (_selectedPaymentMethod == PaymentMethod.snakeaidPay &&
            likelyMethodLockedByBackend) {
          setState(() {
            _lockedPaymentMethod = PaymentMethod.payos;
            _selectedPaymentMethod = PaymentMethod.payos;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Yêu cầu này đã được khởi tạo thanh toán bằng PayOS. Vui lòng tiếp tục với PayOS.',
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Color(0xFFFF8F00),
            ),
          );
        }
        setState(() => _isPaymentLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (!_hasBookingId) {
      context.go('/consultation-home');
      return;
    }

    setState(() => _isPaymentLoading = true);
    try {
      final repo = ref.read(consultationRepositoryProvider);
      final paymentMethod = _selectedPaymentMethod == PaymentMethod.snakeaidPay
          ? 'WalletBalance'
          : 'PayOs';
      final payment = await repo.payBooking(
        widget.bookingId!,
        paymentMethod: paymentMethod,
      );
      if (_selectedPaymentMethod == PaymentMethod.payos) {
        await _handlePayOsFlow(payment, bookingId: widget.bookingId);
        if (!mounted) return;
        setState(() => _isPaymentLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Đã mở PayOS. Vui lòng hoàn tất thanh toán và quay lại ứng dụng.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      ref.invalidate(consultationBookingsProvider);
      if (!mounted) return;
      context.go(
        '/consultation-home',
        extra: {'newConsultationId': widget.bookingId},
      );
    } catch (e) {
      if (!mounted) return;
      final raw = e.toString().toLowerCase();
      final likelyMethodLockedByBackend =
          raw.contains('already been paid') ||
          raw.contains('already paid') ||
          raw.contains('đã được trả') ||
          raw.contains('đã thanh toán');
      if (_selectedPaymentMethod == PaymentMethod.snakeaidPay &&
          likelyMethodLockedByBackend) {
        setState(() {
          _lockedPaymentMethod = PaymentMethod.payos;
          _selectedPaymentMethod = PaymentMethod.payos;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Đơn này đã được khởi tạo thanh toán bằng PayOS. Vui lòng tiếp tục với PayOS.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFFFF8F00),
          ),
        );
      }
      setState(() => _isPaymentLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handlePayOsFlow(
    ConsultationPaymentResponse payment, {
    String? emergencyRequestId,
    String? bookingId,
  }) async {
    if (payment.isEscrowed) {
      return;
    }

    final checkoutUrl = (payment.checkoutUrl ?? '').toString();
    final transactionId = payment.transactionId.toString();
    if (checkoutUrl.isEmpty) {
      throw Exception('Thiếu checkoutUrl cho PayOS');
    }
    if (transactionId.isEmpty) {
      throw Exception('Thiếu transactionId cho PayOS');
    }

    final uri = Uri.tryParse(checkoutUrl);
    if (uri == null) {
      throw Exception('checkoutUrl không hợp lệ');
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      throw Exception('Không thể mở cổng thanh toán PayOS');
    }

    setState(() {
      _pendingPayOsTransactionId = transactionId;
      _pendingPayOsOrderCode = payment.orderCode;
      _pendingEmergencyRequestId = emergencyRequestId;
      _pendingBookingId = bookingId;
      _lockedPaymentMethod = PaymentMethod.payos;
      _selectedPaymentMethod = PaymentMethod.payos;
    });
  }

  /// Show wallet payment confirmation dialog
  Future<bool?> _showWalletPaymentDialog() async {
    final priceAmount = _getPriceAmount();
    final price = int.tryParse(priceAmount) ?? 0;
    final theme = Theme.of(context);

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Xác nhận thanh toán',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  children: [
                    // Current balance
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet,
                              size: 18,
                              color: Color(0xFF228B22),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Số dư hiện tại',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                        _isLoadingWallet
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _walletBalance != null
                                    ? _formatPrice(
                                        _walletBalance!.toInt().toString(),
                                      )
                                    : 'Không có dữ liệu',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF228B22),
                                ),
                              ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Amount to deduct
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Số tiền thanh toán',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF374151),
                          ),
                        ),
                        Text(
                          '-${_formatPrice(priceAmount)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Color(0xFFBBF7D0)),
                    ),

                    // Balance after payment
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Số dư sau thanh toán',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        _isLoadingWallet
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _walletBalance != null
                                    ? _formatPrice(
                                        ((_walletBalance! - price).toInt())
                                            .toString(),
                                      )
                                    : 'Không có dữ liệu',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _walletBalance != null &&
                                          _walletBalance! >= price
                                      ? const Color(0xFF228B22)
                                      : Colors.red,
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),

              // Insufficient balance warning
              if (_walletBalance != null && _walletBalance! < price) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Số dư không đủ. Vui lòng nạp thêm tiền vào ví.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _startWalletTopup,
                    icon: const Icon(Icons.add_card, size: 18),
                    label: const Text('Nạp ví ngay'),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _startWalletTopup,
                    icon: const Icon(Icons.add_card, size: 18),
                    label: const Text('Nạp ví ngay'),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: _walletBalance != null && _walletBalance! >= price
                ? () => Navigator.of(context).pop(true)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF228B22),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Xác nhận thanh toán',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCancel() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy thanh toán'),
        content: const Text('Bạn có chắc muốn hủy thanh toán?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Go back to previous screen
            },
            child: const Text('Có'),
          ),
        ],
      ),
    );
  }

  String _getConsultationTypeLabel() {
    if (widget.consultationType == 'instant') {
      return 'Tư vấn ngay';
    } else if (widget.consultationType == 'scheduled') {
      return 'Tư vấn đặt lịch';
    }
    return 'Tư vấn';
  }

  String _getPriceAmount() {
    if (widget.price != null) {
      // Extract number from price string like "200,000 VNĐ"
      final priceStr = widget.price!.replaceAll(RegExp(r'[^\d]'), '');
      if (priceStr.isEmpty) {
        return '0';
      }
      return priceStr;
    }
    return '150000';
  }

  String _formatPrice(String amount) {
    // Format number with thousands separator
    final number = int.tryParse(amount) ?? 0;
    return '${number.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ';
  }

  String _formatBalance(double balance) =>
      _formatPrice(balance.toInt().toString());

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expertDetailProvider(widget.expertId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Xác Nhận & Thanh Toán',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.expert == null
          ? const Center(child: Text('Không tìm thấy chuyên gia'))
          : Column(
              children: [
                // Main content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Consultation Summary Card
                        _buildConsultationSummary(
                          context,
                          state.expert!,
                          theme,
                        ),
                        const SizedBox(height: 16),

                        // Payment Details Section
                        _buildPaymentDetails(theme),
                        const SizedBox(height: 16),

                        // Security Info Box
                        _buildSecurityInfo(theme),
                        const SizedBox(height: 12),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Area
                _buildBottomActions(theme),
              ],
            ),
    );
  }

  Widget _buildConsultationSummary(
    BuildContext context,
    dynamic expert,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: expert.avatarUrl != null
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(
                                expert.avatarUrl!,
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: expert.avatarUrl == null ? Colors.grey[300] : null,
                    ),
                    child: expert.avatarUrl == null
                        ? Icon(Icons.person, size: 32, color: Colors.grey[600])
                        : null,
                  ),
                  if (expert.isVerified)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFF8A2BE2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expert.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8A2BE2).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getConsultationTypeLabel(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF8A2BE2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.selectedDate != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.selectedDate!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.duration ?? '30 phút',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build payment details section
  Widget _buildPaymentDetails(ThemeData theme) {
    final priceAmount = _getPriceAmount();
    final formattedPrice = _formatPrice(priceAmount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chi Tiết Thanh Toán',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Consultation fee
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Phí tư vấn (${widget.duration ?? "30 phút"})',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    formattedPrice,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Platform fee
              Divider(color: Colors.grey.shade200),
              const SizedBox(height: 12),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng Cộng',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    formattedPrice,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                ],
              ),

              // Insufficient balance warning
              if (_walletBalance != null &&
                  _walletBalance! < int.parse(priceAmount)) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: Colors.red.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Số dư không đủ. Vui lòng nạp thêm tiền vào ví.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Build payment methods section - Only shown after confirming terms
  Widget _buildPaymentMethodsSection(ThemeData theme) {
    return _buildPaymentMethods(theme);
  }

  /// Show payment methods in bottom sheet (similar to rescuer flow)
  Widget _buildPaymentMethods(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phương Thức Thanh Toán',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // ── Card 1: SnakeAidPay ────────────────────────────────────────
        _buildPaymentMethodCard(
          method: PaymentMethod.snakeaidPay,
          title: 'Ví SnakeAidPay',
          subtitle: 'Thanh toán tức thì, không phí giao dịch',
          icon: Icons.account_balance_wallet,
          headerGradient: const LinearGradient(
            colors: [Color(0xFF228B22), Color(0xFF1a6b1a)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          buttonColor: const Color(0xFF228B22),
          child: _buildSnakeAidPayContent(),
        ),
        const SizedBox(height: 12),

        // ── Card 2: PayOS ─────────────────────────────────────────────
        _buildPaymentMethodCard(
          method: PaymentMethod.payos,
          title: 'PayOS',
          subtitle: 'Thẻ ngân hàng, QR code, Internet Banking',
          icon: Icons.credit_card_rounded,
          headerGradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          buttonColor: const Color(0xFF1565C0),
          child: _buildPayOsContent(),
        ),

        if (_lockedPaymentMethod != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.5)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: Color(0xFFB45309)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Đơn này đã được khởi tạo thanh toán bằng PayOS. Vui lòng tiếp tục với PayOS.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF92400E),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Build modern payment method card
  Widget _buildPaymentMethodCard({
    required PaymentMethod method,
    required String title,
    required String subtitle,
    required IconData icon,
    required LinearGradient headerGradient,
    required Color buttonColor,
    required Widget child,
  }) {
    final isSelected = _selectedPaymentMethod == method;
    final isLockedToOther = _lockedPaymentMethod != null && _lockedPaymentMethod != method;
    final isEnabled = !isLockedToOther;

    return InkWell(
      onTap: isEnabled
          ? () {
              setState(() {
                _selectedPaymentMethod = method;
              });
            }
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Phương thức thanh toán của đơn này đã được khóa theo PayOS.',
                  ),
                  backgroundColor: Color(0xFFFF8F00),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.6,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isSelected ? Border.all(color: _primaryColor, width: 2) : null,
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? _primaryColor.withOpacity(0.2)
                    : Colors.black.withOpacity(0.06),
                blurRadius: isSelected ? 16 : 12,
                offset: Offset(0, isSelected ? 4 : 3),
              ),
            ],
          ),
        child: Column(
          children: [
            // Card header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: isEnabled ? headerGradient : LinearGradient(
                  colors: [Colors.grey[400]!, Colors.grey[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: isEnabled ? buttonColor : Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
            // Card body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  child,
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (isSelected && _agreedToTerms && isEnabled)
                          ? _handlePayment
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEnabled ? buttonColor : Colors.grey[300],
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[200],
                        disabledForegroundColor: Colors.grey[400],
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        method == PaymentMethod.snakeaidPay
                            ? 'Thanh toán bằng ví'
                            : 'Thanh toán qua PayOS',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  /// Build SnakeAid Pay card content
  Widget _buildSnakeAidPayContent() {
    final hasSufficientBalance = _walletBalance != null &&
        _walletBalance! >= (int.tryParse(_getPriceAmount()) ?? 0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Số dư hiện tại',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            _isLoadingWallet
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF228B22),
                    ),
                  )
                : Text(
                    _formatBalance(_walletBalance ?? 0),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: hasSufficientBalance
                          ? const Color(0xFF228B22)
                          : const Color(0xFFDC3545),
                    ),
                  ),
          ],
        ),
        if (!hasSufficientBalance && _walletBalance != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFDC3545).withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: Color(0xFFDC3545)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Số dư không đủ. Cần nạp thêm ${_formatPrice(((int.tryParse(_getPriceAmount()) ?? 0) - (_walletBalance?.toInt() ?? 0)).toString())}.',
                    style: const TextStyle(fontSize: 12, color: Color(0xFFDC3545)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Build PayOS card content with feature chips
  Widget _buildPayOsContent() {
    return Row(
      children: [
        _featureChip(Icons.qr_code_2, 'QR Code'),
        const SizedBox(width: 8),
        _featureChip(Icons.credit_card, 'ATM / Visa'),
        const SizedBox(width: 8),
        _featureChip(Icons.account_balance, 'Internet Banking'),
      ],
    );
  }

  /// Build feature chip for PayOS
  Widget _featureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF1565C0).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF1565C0)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1565C0),
            ),
          ),
        ],
      ),
    );
  }



  /// Build security info box
  Widget _buildSecurityInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: Colors.amber.shade400, width: 4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.security, color: Colors.amber.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tiền sẽ được giữ an toàn và chỉ chuyển cho chuyên gia sau khi hoàn thành tư vấn.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build bottom actions
  Widget _buildBottomActions(ThemeData theme) {
    final canProceed = !_isPaymentLoading;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor.withOpacity(0.8),
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Confirm button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _isPaymentLoading
                    ? null
                    : _showPaymentMethodsSheet,
                style: FilledButton.styleFrom(
                  backgroundColor: canProceed
                      ? _primaryColor
                      : Colors.grey.shade400,
                  disabledBackgroundColor: Colors.grey.shade400,
                  disabledForegroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isPaymentLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Xác Nhận & Thanh Toán',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel button
            TextButton(
              onPressed: _handleCancel,
              child: Text(
                'Hủy',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show payment methods in a modern bottom sheet
  void _showPaymentMethodsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _PaymentMethodsSheet(
        walletBalance: _walletBalance,
        amount: double.tryParse(_getPriceAmount()) ?? 0,
        onPayOS: () async {
          Navigator.of(context).pop();
          setState(() {
            _selectedPaymentMethod = PaymentMethod.payos;
          });
          await _handlePayment();
        },
        onWallet: () async {
          Navigator.of(context).pop();
          setState(() {
            _selectedPaymentMethod = PaymentMethod.snakeaidPay;
          });
          await _handlePayment();
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Payment Methods Bottom Sheet Widget
// ──────────────────────────────────────────────────────────────────────────────
class _PaymentMethodsSheet extends StatefulWidget {
  final double? walletBalance;
  final double amount;
  final VoidCallback onPayOS;
  final VoidCallback onWallet;

  const _PaymentMethodsSheet({
    required this.walletBalance,
    required this.amount,
    required this.onPayOS,
    required this.onWallet,
  });

  @override
  State<_PaymentMethodsSheet> createState() => _PaymentMethodsSheetState();
}

class _PaymentMethodsSheetState extends State<_PaymentMethodsSheet> {
  bool _agreedToTerms = false;

  String _fmt(double v) {
    final s = v
        .toInt()
        .toString()
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return '$s đ';
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSufficientBalance =
        widget.walletBalance != null && widget.walletBalance! >= widget.amount;
    final double balance = widget.walletBalance ?? 0;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF6F8F6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ────────────────────────────────────────────────
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // ── Header ────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF228B22).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payment_rounded,
                  color: Color(0xFF228B22),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thanh toán tư vấn',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Chọn phương thức thanh toán',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Amount pill ───────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF228B22).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Phí tư vấn',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF555555),
                  ),
                ),
                Text(
                  _fmt(widget.amount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF228B22),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Terms & Conditions ────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFB300).withOpacity(0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _agreedToTerms,
                    onChanged: (val) {
                      setState(() {
                        _agreedToTerms = val ?? false;
                      });
                    },
                    activeColor: const Color(0xFFFF8F00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'Tôi đã hiểu và đồng ý với ',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF424242),
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: 'Chính sách thanh toán',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF8F00),
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _showPaymentTermsDialog(context),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Card 1: SnakeAidPay ───────────────────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Card header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF228B22), Color(0xFF1a6b1a)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ví SnakeAidPay',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Thanh toán tức thì, không phí giao dịch',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Card body
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Số dư hiện tại',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          widget.walletBalance == null
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF228B22),
                                  ),
                                )
                              : Text(
                                  _fmt(balance),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: hasSufficientBalance
                                        ? const Color(0xFF228B22)
                                        : const Color(0xFFDC3545),
                                  ),
                                ),
                        ],
                      ),
                      if (!hasSufficientBalance && widget.walletBalance != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC3545).withOpacity(0.06),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 14,
                                color: Color(0xFFDC3545),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Số dư không đủ. Cần nạp thêm ${_fmt(widget.amount - balance)}.',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFDC3545),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (hasSufficientBalance && _agreedToTerms)
                              ? widget.onWallet
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF228B22),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[200],
                            disabledForegroundColor: Colors.grey[400],
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            hasSufficientBalance
                                ? 'Thanh toán bằng ví'
                                : 'Số dư không đủ',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Card 2: PayOS ─────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Card header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.credit_card_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PayOS',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Thẻ ngân hàng, QR code, Internet Banking',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Card body
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _featureChip(Icons.qr_code_2, 'QR Code'),
                          const SizedBox(width: 8),
                          _featureChip(Icons.credit_card, 'ATM / Visa'),
                          const SizedBox(width: 8),
                          _featureChip(
                            Icons.account_balance,
                            'Internet Banking',
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _agreedToTerms ? widget.onPayOS : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[200],
                            disabledForegroundColor: Colors.grey[400],
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Thanh toán qua PayOS',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureChip(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF90CAF9)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF1565C0)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1565C0),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentTermsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header - full-width professional style
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF228B22), Color(0xFF1a6b1a)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFF196619)),
                ),
                child: const Center(
                  child: Text(
                    'Chính Sách Thanh Toán',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vui lòng đọc kỹ các điều khoản sau đây trước khi thanh toán:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildPolicyBullet(
                        Icons.lock_outlined,
                        'Sau khi thanh toán thành công, không thể tự hủy đơn tư vấn.',
                      ),
                      _buildPolicyBullet(
                        Icons.check_circle,
                        'Thanh toán an toàn và bảo mật với các phương thức được kiểm chứng.',
                      ),
                      _buildPolicyBullet(
                        Icons.visibility,
                        'Không có phí ẩn. Tất cả chi phí đã được hiển thị rõ ràng.',
                      ),
                      _buildPolicyBullet(
                        Icons.receipt,
                        'Hoàn tiền nếu dịch vụ không thực hiện.',
                      ),
                      _buildSubBullet(
                        'Vui lòng liên hệ hotline: 0787171699 để được hỗ trợ.',
                      ),
                      const SizedBox(height: 16),
                      _buildPolicyBullet(
                        Icons.gavel,
                        'Tuân thủ các quy định pháp luật về thanh toán điện tử.',
                      ),
                    ],
                  ),
                ),
              ),
              // Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF228B22),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Đã hiểu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPolicyBullet(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF228B22).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF228B22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 44),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
