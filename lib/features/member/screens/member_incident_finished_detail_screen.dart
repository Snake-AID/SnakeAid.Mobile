import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../../emergency/models/detailed_incident_response.dart';
import '../../emergency/providers/detailed_incident_provider.dart';
import '../../emergency/repository/incident_repository.dart';
import '../../snake_catching/repository/wallet_repository.dart';

class MemberIncidentFinishedDetailScreen extends ConsumerStatefulWidget {
  final String incidentId;

  const MemberIncidentFinishedDetailScreen({
    super.key,
    required this.incidentId,
  });

  @override
  ConsumerState<MemberIncidentFinishedDetailScreen> createState() =>
      _MemberIncidentFinishedDetailScreenState();
}

class _MemberIncidentFinishedDetailScreenState
    extends ConsumerState<MemberIncidentFinishedDetailScreen>
    with WidgetsBindingObserver {
  bool _isProcessingPayment = false;
  bool _hasPaid = false;
  bool _isLoadingWallet = false;
  WalletInfo? _walletInfo;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _payOsCallbackSub;
  bool _isHandlingPayOsCallback = false;
  bool _isWaitingPayOsResult = false;
  bool _isShowingPaymentStatusDialog = false;
  DateTime? _pendingPayOsStartedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initPayOsCallbackListener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.incidentId.isNotEmpty) {
        ref
            .read(detailedIncidentProvider.notifier)
            .loadDetailedIncident(widget.incidentId);
      }
      _loadWallet();
    });
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
      _tryRefreshPendingPayOsOnResume();
    }
  }

  void _initPayOsCallbackListener() {
    _payOsCallbackSub = _appLinks.uriLinkStream.listen((uri) async {
      if (!mounted || !_isWaitingPayOsResult) return;

      final isSnakeaidPaymentLink =
          uri.scheme == 'snakeaid' && uri.host == 'payment';
      final isHttpPayOsCallback =
          (uri.scheme == 'https' || uri.scheme == 'http') &&
          (uri.host.contains('snakeaid') || uri.host.contains('payos')) &&
          (uri.path.contains('pay') ||
              uri.path.contains('payment') ||
              uri.path.contains('callback') ||
              uri.path.contains('return') ||
              uri.path.contains('cancel'));

      if (!isSnakeaidPaymentLink && !isHttpPayOsCallback) return;
      if (_isHandlingPayOsCallback) return;

      _isHandlingPayOsCallback = true;
      try {
        await _handlePayOsCallbackUri(uri);
      } finally {
        _isHandlingPayOsCallback = false;
      }
    });
  }

  Future<void> _handlePayOsCallbackUri(Uri uri) async {
    final status = uri.queryParameters['status']?.toUpperCase();
    final cancelParam = uri.queryParameters['cancel']?.toLowerCase() == 'true';
    final path = uri.path.toLowerCase();

    final isCancelled =
        cancelParam ||
        status == 'CANCELLED' ||
        status == 'CANCELED' ||
        status == 'FAILED' ||
        path.endsWith('/cancel');

    final isPaid =
        (status == 'PAID' || status == 'SUCCESS' || status == 'COMPLETED') ||
        path.endsWith('/return') ||
        path.endsWith('/success');

    if (isCancelled) {
      _clearPendingPayOsContext();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn đã hủy thanh toán PayOS.'),
          backgroundColor: Color(0xFFFF8F00),
        ),
      );
      return;
    }

    if (!isPaid) return;

    await _refreshIncidentAfterPayOsReturn(showSuccessMessage: true);
  }

  Future<void> _tryRefreshPendingPayOsOnResume() async {
    if (!mounted || !_isWaitingPayOsResult || _isHandlingPayOsCallback) return;

    final startedAt = _pendingPayOsStartedAt;
    if (startedAt != null &&
        DateTime.now().difference(startedAt) > const Duration(minutes: 30)) {
      _clearPendingPayOsContext();
      return;
    }

    _isHandlingPayOsCallback = true;
    try {
      await _refreshIncidentAfterPayOsReturn(showSuccessMessage: false);
    } finally {
      _isHandlingPayOsCallback = false;
    }
  }

  Future<void> _refreshIncidentAfterPayOsReturn({
    required bool showSuccessMessage,
  }) async {
    if (!mounted) return;

    _showPaymentStatusDialog();
    setState(() => _isProcessingPayment = true);

    try {
      for (var attempt = 0; attempt < 5; attempt++) {
        await ref
            .read(detailedIncidentProvider.notifier)
            .loadDetailedIncident(widget.incidentId, forceRefresh: true);

        final updatedIncident = ref.read(detailedIncidentProvider).incident;
        final paid = updatedIncident?.status == IncidentStatus.completed;

        if (paid) {
          if (!mounted) return;
          setState(() => _hasPaid = true);
          _clearPendingPayOsContext();
          if (showSuccessMessage) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thanh toán PayOS thành công.'),
                backgroundColor: Color(0xFF228B22),
              ),
            );
          }
          return;
        }

        if (attempt < 4) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      if (showSuccessMessage && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Đã quay lại ứng dụng. Hệ thống đang cập nhật trạng thái thanh toán.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Không thể cập nhật trạng thái thanh toán: ${e.toString()}',
            ),
          ),
        );
      }
    } finally {
      _hidePaymentStatusDialog();
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
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
                  'Hệ thống đang xác nhận trạng thái từ PayOS. Vui lòng đợi...',
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
    _isWaitingPayOsResult = false;
    _pendingPayOsStartedAt = null;
  }

  Future<void> _loadWallet() async {
    setState(() => _isLoadingWallet = true);
    try {
      final wallet = await ref.read(walletRepositoryProvider).getWalletInfo();
      if (mounted) {
        setState(() => _walletInfo = wallet);
      }
    } catch (_) {
      // T ignore và giữ _walletInfo là null
    } finally {
      if (mounted) setState(() => _isLoadingWallet = false);
    }
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(value);
  }

  double _getPaymentAmount(DetailedIncidentData incident) {
    final mission = incident.activeMission;
    return mission?.actualCost ?? mission?.price ?? 0.0;
  }

  bool _isFreePayment(DetailedIncidentData incident) {
    return _getPaymentAmount(incident) <= 0;
  }

  Future<void> _completeFreePayment(DetailedIncidentData incident) async {
    if (_isProcessingPayment || _hasPaid) return;

    setState(() => _isProcessingPayment = true);

    try {
      final repository = ref.read(incidentRepositoryProvider);
      final paymentResponse = await repository.paySnakebiteIncidentWithWallet(
        incidentId: incident.id,
        amount: 0,
        description: 'Hoàn tất thanh toán đơn miễn phí',
      );

      if (paymentResponse.status.toLowerCase() == 'paid' ||
          paymentResponse.status.toLowerCase() == 'completed') {
        setState(() => _hasPaid = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đơn 0đ đã được hoàn tất thành công.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hoàn tất đơn miễn phí chưa thành công: ${paymentResponse.status}',
            ),
          ),
        );
      }

      await ref
          .read(detailedIncidentProvider.notifier)
          .refreshDetailedIncident();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hoàn tất đơn miễn phí thất bại: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isProcessingPayment = false);
    }
  }

  Future<void> _payWithPayOs(DetailedIncidentData incident) async {
    if (_isProcessingPayment) return;

    final amount = _getPaymentAmount(incident);

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đơn 0đ không cần thanh toán qua PayOS.'),
        ),
      );
      return;
    }

    setState(() => _isProcessingPayment = true);

    try {
      final repository = ref.read(incidentRepositoryProvider);
      final paymentResponse = await repository
          .createSnakebiteIncidentPaymentLink(
            incidentId: incident.id,
            amount: amount,
            description: 'Thanh toán phí cứu hộ',
          );

      if (paymentResponse.checkoutUrl != null &&
          paymentResponse.checkoutUrl!.isNotEmpty) {
        final uri = Uri.tryParse(paymentResponse.checkoutUrl!);
        if (uri != null && await canLaunchUrl(uri)) {
          _isWaitingPayOsResult = true;
          _pendingPayOsStartedAt = DateTime.now();
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            const SnackBar(
              content: Text(
                'Đã mở PayOS. Vui lòng hoàn tất thanh toán và quay lại ứng dụng.',
              ),
            ),
          );
        } else {
          throw Exception('Liên kết thanh toán không hợp lệ');
        }
      } else {
        throw Exception('Không nhận được liên kết thanh toán từ PayOS');
      }
    } catch (e) {
      _clearPendingPayOsContext();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PayOS payment thất bại: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isProcessingPayment = false);
    }
  }

  Future<void> _payWithWallet(DetailedIncidentData incident) async {
    if (_isProcessingPayment || _hasPaid) return;

    final amount = _getPaymentAmount(incident);

    if (amount <= 0) {
      await _completeFreePayment(incident);
      return;
    }

    setState(() => _isProcessingPayment = true);

    try {
      final repository = ref.read(incidentRepositoryProvider);
      final paymentResponse = await repository.paySnakebiteIncidentWithWallet(
        incidentId: incident.id,
        amount: amount,
        description: 'Thanh toán bằng ví cho snakebite incident',
      );

      if (paymentResponse.status.toLowerCase() == 'paid') {
        setState(() => _hasPaid = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanh toán bằng ví thành công.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Thanh toán bằng ví chưa hoàn tất: ${paymentResponse.status}',
            ),
          ),
        );
      }

      await ref
          .read(detailedIncidentProvider.notifier)
          .refreshDetailedIncident();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thanh toán ví thất bại: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isProcessingPayment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailedIncidentState = ref.watch(detailedIncidentProvider);
    final incident = detailedIncidentState.incident;

    final alreadyPaid =
        incident != null &&
        (_hasPaid || incident.status == IncidentStatus.completed);
    final canPay =
        incident != null &&
        (incident.status == IncidentStatus.finished ||
            incident.status == IncidentStatus.completed);
    final showFooter = incident != null && canPay && !alreadyPaid;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text(
          'Chi Tiết Sự Cố',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
      ),
      bottomNavigationBar:
          showFooter ? SafeArea(child: _buildPaymentFooter(incident!)) : null,
      body: detailedIncidentState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF228B22)),
            )
          : detailedIncidentState.error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 56,
                      color: Color(0xFFDC3545),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Không tải được dữ liệu sự cố.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      detailedIncidentState.error!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () => ref
                          .read(detailedIncidentProvider.notifier)
                          .loadDetailedIncident(
                            widget.incidentId,
                            forceRefresh: true,
                          ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : incident == null
          ? const Center(child: Text('Không tìm thấy sự cố.'))
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(detailedIncidentProvider.notifier)
                    .loadDetailedIncident(
                      widget.incidentId,
                      forceRefresh: true,
                    );
              },
              color: const Color(0xFF228B22),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  top: 16,
                  bottom: showFooter ? 80 : 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStatusOverview(incident),
                    const SizedBox(height: 16),
                    _buildIncidentInfoCard(incident),
                    const SizedBox(height: 16),
                    _buildRescuerInfoCard(incident),
                    const SizedBox(height: 16),
                    _buildPaymentCard(incident),
                    const SizedBox(height: 16),
                    _buildMediaCard(incident),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPaymentFooter(DetailedIncidentData incident) {
    final isFreePayment = _isFreePayment(incident);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed:
            _isProcessingPayment ? null : () => _showPaymentSheet(incident),
        icon: _isProcessingPayment
            ? const SizedBox(
                width: 18,
                height: 18,
                child:
                    CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
              : Icon(isFreePayment ? Icons.check_circle_outline : Icons.payment),
        label: Text(
            _isProcessingPayment
                ? 'Đang xử lý...'
                : (isFreePayment ? 'Hoàn tất đơn miễn phí' : 'Thanh toán ngay'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF228B22),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  void _showPaymentSheet(DetailedIncidentData incident) {
    _loadWallet();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final amount = _getPaymentAmount(incident);
          final isFreePayment = amount <= 0;
          final balance = _walletInfo?.balance ?? 0.0;
          final hasSufficientBalance =
              isFreePayment || (_walletInfo != null && balance >= amount);

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
              MediaQuery.of(ctx).viewInsets.bottom +
                  MediaQuery.of(ctx).padding.bottom +
                  24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

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
                          'Thanh toán sự cố',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F1F1F),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isFreePayment
                              ? 'Đơn miễn phí, chỉ cần xác nhận hoàn tất'
                              : 'Chọn phương thức thanh toán phù hợp',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF228B22).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng thanh toán',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF555555),
                        ),
                      ),
                      Text(
                        isFreePayment ? 'Miễn phí' : _formatCurrency(amount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF228B22),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _buildPaymentMethodCard(
                  headerGradient: const [
                    Color(0xFF228B22),
                    Color(0xFF1A6B1A),
                  ],
                  headerIcon: Icons.account_balance_wallet,
                  title: 'Ví SnakeAidPay',
                  subtitle: isFreePayment
                      ? 'Xác nhận hoàn tất cho đơn miễn phí'
                      : 'Thanh toán tức thì, không phí giao dịch',
                  body: Column(
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
                                  isFreePayment
                                      ? 'Không trừ tiền'
                                      : _formatCurrency(balance),
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
                      if (!isFreePayment && !_isLoadingWallet && _walletInfo == null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFA000).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 14,
                                color: Color(0xFFFF8F00),
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Không lấy được thông tin ví. Vui lòng thử lại sau.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFFF8F00),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (!isFreePayment && !hasSufficientBalance && _walletInfo != null) ...[
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
                                  'Số dư không đủ. Cần nạp thêm ${_formatCurrency(amount - balance)}.',
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
                          onPressed: hasSufficientBalance
                              ? () async {
                                  Navigator.pop(ctx);
                                  await _payWithWallet(incident);
                                }
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
                            isFreePayment
                                ? 'Hoàn tất đơn miễn phí'
                                : hasSufficientBalance
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
                const SizedBox(height: 14),

                _buildPaymentMethodCard(
                  headerGradient: const [
                    Color(0xFF1565C0),
                    Color(0xFF0D47A1),
                  ],
                  headerIcon: Icons.credit_card_rounded,
                  title: 'PayOS',
                  subtitle: isFreePayment
                      ? 'Không cần dùng PayOS cho đơn miễn phí'
                      : 'Thẻ ngân hàng, QR code, Internet Banking',
                  body: Column(
                    children: [
                      if (isFreePayment)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Color(0xFF1565C0),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Đơn này không phát sinh phí nên không cần mở cổng thanh toán.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1565C0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _paymentFeatureChip(Icons.qr_code_2, 'QR Code'),
                            _paymentFeatureChip(Icons.credit_card, 'ATM / Visa'),
                            _paymentFeatureChip(
                              Icons.account_balance,
                              'Internet Banking',
                            ),
                          ],
                        ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: amount > 0
                              ? () async {
                                  Navigator.pop(ctx);
                                  await _payWithPayOs(incident);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
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
          );
        },
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required List<Color> headerGradient,
    required String title,
    required String subtitle,
    required IconData headerIcon,
    required Widget body,
  }) {
    return Container(
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: headerGradient,
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
                  child: Icon(headerIcon, color: Colors.white, size: 20),
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: body,
          ),
        ],
      ),
    );
  }

  Widget _paymentFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF1565C0)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1565C0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOverview(DetailedIncidentData incident) {
    final occurredAt = incident.incidentOccurredAt ?? DateTime.now();
    final elapsed = DateTime.now().difference(occurredAt);
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes % 60;

    final isFinished = incident.status == IncidentStatus.finished;
    final isCompleted = incident.status == IncidentStatus.completed;
    final isCancelled = incident.status == IncidentStatus.cancelled ||
        incident.status == IncidentStatus.falseAlarm ||
        incident.status == IncidentStatus.noRescuerFound;
    final isAssigned = incident.status == IncidentStatus.assigned ||
        incident.status == IncidentStatus.inProgress;

    final statusColor = isCompleted
        ? const Color(0xFF228B22)
        : isFinished
            ? const Color(0xFFFF6B35)
            : isCancelled
                ? const Color(0xFF9E9E9E)
                : isAssigned
                    ? const Color(0xFF2196F3)
                    : const Color(0xFF1565C0);

    final statusIcon = isCompleted
        ? Icons.check_circle_rounded
        : isFinished
            ? Icons.receipt_long_rounded
            : isCancelled
                ? Icons.cancel_rounded
                : isAssigned
                    ? Icons.directions_run_rounded
                    : Icons.local_hospital_rounded;

    final elapsedText = hours > 0
        ? 'Đã xảy ra $hours giờ $minutes phút trước'
        : 'Đã xảy ra $minutes phút trước';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Coloured banner ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor, statusColor.withOpacity(0.78)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TRẠNG THÁI SỰ CỐ',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white70,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        incident.status.displayText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status pill badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isCompleted
                        ? 'Hoàn tất'
                        : isFinished
                            ? 'Chờ TT'
                            : isCancelled
                                ? 'Đã đóng'
                                : 'Đang xử lý',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Elapsed time row ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 15,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 6),
                Text(
                  elapsedText,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd/MM/yyyy  HH:mm').format(occurredAt.toLocal()),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),

          // ── Coloured accent bottom strip ─────────────────────────
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor, statusColor.withOpacity(0.3)],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentInfoCard(DetailedIncidentData incident) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF228B22),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.description_outlined, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Chi Tiết Sự Cố',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _infoRowIcon(
                  Icons.medical_services_outlined,
                  'Mức độ',
                  incident.severityText,
                  const Color(0xFFDC3545),
                ),
                _infoRowIcon(
                  Icons.access_time,
                  'Thời gian',
                  DateFormat('dd/MM/yyyy  HH:mm').format(
                    (incident.incidentOccurredAt ?? DateTime.now()).toLocal(),
                  ),
                  const Color(0xFF2196F3),
                ),
                _infoRowIcon(
                  Icons.location_on,
                  'Địa chỉ',
                  incident.address ?? 'Chưa có',
                  const Color(0xFF228B22),
                ),
                _infoRowIcon(
                  Icons.gps_fixed,
                  'Tọa độ',
                  '${incident.locationCoordinates.latitude.toStringAsFixed(6)}, '
                      '${incident.locationCoordinates.longitude.toStringAsFixed(6)}',
                  Colors.grey,
                ),
                if (incident.symptomsReport?.isNotEmpty ?? false)
                  _infoRowIcon(
                    Icons.healing,
                    'Triệu chứng',
                    incident.symptomsReport!
                        .map((e) => e.symptomName)
                        .join(', '),
                    const Color(0xFFFF9800),
                  ),
                if (incident.identifiedSnakeSpecies != null)
                  _infoRowIcon(
                    Icons.pest_control,
                    'Loài rắn',
                    incident.identifiedSnakeSpecies!.commonName,
                    const Color(0xFF7B1FA2),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRescuerInfoCard(DetailedIncidentData incident) {
    final rescuer = incident.assignedRescuer;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF2196F3),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.assignment_ind, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Thông Tin Người Cứu Hộ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: rescuer != null
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFF4CAF50),
                        backgroundImage:
                            rescuer.account?.avatarUrl?.isNotEmpty == true
                            ? NetworkImage(rescuer.account!.avatarUrl!)
                            : null,
                        child:
                            rescuer.account?.avatarUrl == null ||
                                rescuer.account?.avatarUrl?.isEmpty == true
                            ? Text(
                                rescuer.account?.fullName?.isNotEmpty == true
                                    ? rescuer.account!.fullName!
                                          .substring(0, 1)
                                          .toUpperCase()
                                    : 'R',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rescuer.account?.fullName ?? 'Không có',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  rescuer.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ],
                            ),
                            if (rescuer.phoneNumber != null) ...[  
                              const SizedBox(height: 4),
                              Text(
                                rescuer.phoneNumber!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (rescuer.phoneNumber != null)
                        InkWell(
                          onTap: () async {
                            final uri = Uri(
                              scheme: 'tel',
                              path: rescuer.phoneNumber!,
                            );
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF228B22).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.phone,
                              color: Color(0xFF228B22),
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  )
                : Row(
                    children: [
                      Icon(
                        Icons.person_off_outlined,
                        color: Colors.grey[400],
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Chưa có nhân viên cứu hộ phân công.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(DetailedIncidentData incident) {
    final mission = incident.activeMission;
    final serviceFee = mission?.price ?? 0.0;
    final actualCost = mission?.actualCost;
    final transportFee = mission?.costFromCenter;
    final alreadyPaid =
        _hasPaid || incident.status == IncidentStatus.completed;
    final total = actualCost ?? serviceFee + (transportFee ?? 0);
    final headerColor =
        alreadyPaid ? const Color(0xFF228B22) : const Color(0xFF228B22);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  alreadyPaid ? Icons.check_circle : Icons.receipt_long_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  alreadyPaid ? 'Đã Thanh Toán' : 'Thanh Toán',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (alreadyPaid) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Hoàn tất',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Fee breakdown
                _payRow('Giá dịch vụ', _formatCurrency(serviceFee)),
                if (transportFee != null) ...[  
                  const SizedBox(height: 6),
                  _payRow(
                    'Chi phí di chuyển',
                    _formatCurrency(transportFee),
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1),
                ),
                _payRow(
                  'Tổng thanh toán',
                  _formatCurrency(total),
                  isTotal: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _payRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 13,
            fontWeight:
                isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? const Color(0xFF111827) : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal
                ? const Color(0xFF2F65E0)
                : const Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaCard(DetailedIncidentData incident) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF9C27B0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.photo_library_outlined, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Hình Ảnh Minh Chứng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: incident.media.isEmpty
                ? Row(
                    children: [
                      Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey[400],
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Chưa cung cấp hình ảnh minh chứng.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: incident.media.map((m) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 110,
                          height: 82,
                          child: m.mediaUrl.isNotEmpty
                              ? Image.network(
                                  m.mediaUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey[100],
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 28,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: Colors.grey[100],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 28,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _infoRowIcon(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
