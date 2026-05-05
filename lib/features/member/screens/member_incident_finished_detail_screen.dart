import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/handlers/payment_deep_link_coordinator.dart';
import '../../../core/payments/payos_payment_verifier.dart';
import '../../../core/payments/payos_pending_context.dart';
import '../../emergency/models/detailed_incident_response.dart';
import '../../emergency/providers/detailed_incident_provider.dart';
import '../../emergency/repository/incident_repository.dart';
import '../../snake_catching/repository/feedback_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../../wallet/repository/wallet_repository.dart';

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
  bool _isConfirmingPayOs = false;
  bool _isSubmittingFeedback = false;
  bool _hasPaid = false;
  int? _pendingPayOsOrderCode;
  String? _pendingPayOsTransactionId;
  bool _isAwaitingPayOsReturn = false;
  bool _isShowingPaymentStatusDialog = false;
  int? _lastHandledDeepLinkEventId;
  StreamSubscription<PaymentDeepLinkEvent>? _deepLinkSub;

  void _handleBackNavigation() {
    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }
    context.goNamed('member_home');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDeepLinks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.incidentId.isNotEmpty) {
        ref
            .read(detailedIncidentProvider.notifier)
            .loadDetailedIncident(widget.incidentId);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    if (state == AppLifecycleState.resumed) {
      _tryAutoFinalizePendingPayOs();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _deepLinkSub?.cancel();
    super.dispose();
  }

  void _initDeepLinks() {
    final coordinator = ref.read(paymentDeepLinkCoordinatorProvider);
    _deepLinkSub = coordinator.stream.listen(_handlePaymentDeepLinkEvent);

    final latest = coordinator.latestEvent;
    if (latest != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handlePaymentDeepLinkEvent(latest);
      });
    }
  }

  Future<void> _handlePaymentDeepLinkEvent(PaymentDeepLinkEvent event) async {
    if (!mounted || _lastHandledDeepLinkEventId == event.eventId) return;
    if (!_isAwaitingPayOsReturn && _pendingPayOsOrderCode == null) return;
    if (_pendingPayOsOrderCode != null &&
        event.orderCode != _pendingPayOsOrderCode) {
      return;
    }

    _lastHandledDeepLinkEventId = event.eventId;

    if (event.isCancelled) {
      _clearPendingPayOsContext();
      if (mounted) {
        setState(() {
          _isConfirmingPayOs = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn đã hủy thanh toán PayOS.'),
          backgroundColor: Color(0xFFFF8F00),
        ),
      );
      return;
    }

    await _confirmPendingPayOsPayment(event: event);
  }

  Future<void> _confirmPendingPayOsPayment({
    PaymentDeepLinkEvent? event,
    bool showStatusDialog = true,
  }) async {
    final transactionId = _pendingPayOsTransactionId;
    if (transactionId == null || transactionId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isAwaitingPayOsReturn = false;
        _isConfirmingPayOs = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thiếu transactionId để xác nhận thanh toán.'),
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _isConfirmingPayOs = true;
    });
    if (showStatusDialog) {
      _showPaymentStatusDialog();
    }

    try {
      final verifier = ref.read(payOsPaymentVerifierProvider);
      final result = await verifier.verify(
        context: PayOsPendingContext(
          flowType: PayOsFlowType.snakebiteIncident,
          transactionId: transactionId,
          orderCode: _pendingPayOsOrderCode ?? event?.orderCode,
          referenceId: widget.incidentId,
          startedAt: DateTime.now(),
        ),
        event: event,
      );

      if (!mounted) return;

      if (result.status == PayOsVerificationStatus.confirmed &&
          result.transaction != null) {
        setState(() {
          _hasPaid = true;
          _isConfirmingPayOs = false;
        });
        _clearPendingPayOsContext();

        await ref
            .read(detailedIncidentProvider.notifier)
            .refreshDetailedIncident();
        if (!mounted) return;
        await _showPaymentSuccessDialog(
          title: 'Thanh Toán Thành Công',
          subtitle: 'Thanh toán qua PayOS đã được xác nhận.',
          amount: result.transaction!.amount,
          method: 'PayOS',
        );
        if (mounted) {
          await _showFeedbackSheet();
        }
        return;
      }

      if (!mounted) return;
      await ref
          .read(detailedIncidentProvider.notifier)
          .refreshDetailedIncident();
      final refreshedIncident = ref.read(detailedIncidentProvider).incident;
      final completedFromIncident =
          refreshedIncident?.status == IncidentStatus.completed;

      setState(() {
        _isConfirmingPayOs = false;
        if (completedFromIncident) {
          _hasPaid = true;
        }
      });
      if (completedFromIncident) {
        _clearPendingPayOsContext();
      }

      if (!mounted) return;
      if (completedFromIncident) {
        await _showPaymentSuccessDialog(
          title: 'Thanh Toán Thành Công',
          subtitle: 'Thanh toán qua PayOS đã được xác nhận.',
          amount: _getPaymentAmount(
            ref.read(detailedIncidentProvider).incident!,
          ),
          method: 'PayOS',
        );
        if (mounted) {
          await _showFeedbackSheet();
        }
        return;
      }

      if (event != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              event.reason == null || event.reason!.isEmpty
                  ? 'Thanh toán đã quay lại app nhưng backend chưa xác nhận xong.'
                  : 'Thanh toán chưa được xác nhận: ${event.reason}',
            ),
          ),
        );
      }
    } finally {
      _hidePaymentStatusDialog();
    }
  }

  Future<void> _tryAutoFinalizePendingPayOs() async {
    final txId = _pendingPayOsTransactionId;
    if (!mounted || txId == null || txId.isEmpty) return;
    if (_isConfirmingPayOs) return;

    await _confirmPendingPayOsPayment(showStatusDialog: true);
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
    _pendingPayOsOrderCode = null;
    _pendingPayOsTransactionId = null;
    _isAwaitingPayOsReturn = false;
  }

  Future<void> _showFeedbackSheet() async {
    final incident = ref.read(detailedIncidentProvider).incident;
    if (incident == null) return;
    final rescuer = incident.assignedRescuer;
    if (rescuer == null) return;

    int selectedRating = 0;
    final commentController = TextEditingController();

    final currentUser = ref.read(currentUserProvider);
    final alreadyReviewed =
        currentUser != null &&
        incident.feedbacks.any(
          (f) =>
              f.raterId == currentUser.id &&
              f.targetUserId == rescuer.accountId &&
              f.referenceId == incident.id,
        );
    if (alreadyReviewed) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
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
                      CircleAvatar(
                        radius: 26,
                        backgroundImage: rescuer.account!.avatarUrl != null
                            ? NetworkImage(rescuer.account!.avatarUrl!)
                            : null,
                        backgroundColor: const Color(
                          0xFFFF6B35,
                        ).withOpacity(0.15),
                        child: rescuer.account!.avatarUrl == null
                            ? const Icon(Icons.person, color: Color(0xFFFF6B35))
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Đánh giá cứu hộ viên',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F1F1F),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              rescuer.account?.fullName ?? 'Cứu hộ viên',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () => setSheet(() => selectedRating = i + 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            i < selectedRating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 40,
                            color: i < selectedRating
                                ? const Color(0xFFFFB300)
                                : Colors.grey[300],
                          ),
                        ),
                      );
                    }),
                  ),
                  if (selectedRating > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      [
                        '',
                        'Rất tệ',
                        'Tệ',
                        'Bình thường',
                        'Tốt',
                        'Tuyệt vời!',
                      ][selectedRating],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: selectedRating >= 4
                            ? const Color(0xFF228B22)
                            : selectedRating == 3
                            ? Colors.orange
                            : const Color(0xFFDC3545),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    maxLength: 300,
                    decoration: InputDecoration(
                      hintText:
                          'Chia sẻ trải nghiệm của bạn (không bắt buộc)...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[400],
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF6F8F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(14),
                      counterStyle: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            'Để sau',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed:
                              selectedRating == 0 || _isSubmittingFeedback
                              ? null
                              : () async {
                                  Navigator.pop(ctx);
                                  await _submitFeedback(
                                    targetUserId: rescuer.accountId,
                                    targetUserRole: 'Rescuer',
                                    rating: selectedRating,
                                    comments: commentController.text.trim(),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF228B22),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: Colors.grey[200],
                          ),
                          child: _isSubmittingFeedback
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Gửi đánh giá',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitFeedback({
    required String targetUserId,
    required String targetUserRole,
    required int rating,
    required String comments,
  }) async {
    final incident = ref.read(detailedIncidentProvider).incident;
    if (incident == null) return;
    setState(() => _isSubmittingFeedback = true);

    try {
      await ref
          .read(feedbackRepositoryProvider)
          .submitFeedback(
            FeedbackRequest(
              targetUserId: targetUserId,
              referenceId: incident.id,
              type: 'Emergency',
              rating: rating,
              comments: comments.isEmpty ? null : comments,
              targetUserRole: targetUserRole,
            ),
          );
      if (!mounted) return;
      setState(() => _isSubmittingFeedback = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Cảm ơn bạn đã đánh giá!'),
            ],
          ),
          backgroundColor: const Color(0xFF228B22),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      await ref
          .read(detailedIncidentProvider.notifier)
          .refreshDetailedIncident();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmittingFeedback = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: const Color(0xFFDC3545),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget _buildFeedbackCard(DetailedIncidentData incident) {
    final currentUser = ref.read(currentUserProvider);
    final rescuer = incident.assignedRescuer;
    if (rescuer == null) return const SizedBox.shrink();

    final existingReviews = currentUser != null
        ? incident.feedbacks.where(
            (f) =>
                f.raterId == currentUser.id &&
                f.targetUserId == rescuer.accountId &&
                f.referenceId == incident.id,
          )
        : const <FeedbackItem>[];
    final existing = existingReviews.isNotEmpty ? existingReviews.first : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB300).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFB300),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Đánh giá dịch vụ',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      Text(
                        rescuer.account?.fullName ?? 'Cứu hộ viên',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (existing != null) ...[
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < existing.rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 22,
                    color: i < existing.rating
                        ? const Color(0xFFFFB300)
                        : Colors.grey[300],
                  ),
                ),
              ),
              if (existing.comments != null &&
                  existing.comments!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '"${existing.comments!}"',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 14,
                    color: const Color(0xFF228B22),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Đã gửi đánh giá',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF228B22),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                'Chia sẻ trải nghiệm của bạn với cứu hộ viên này.',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showFeedbackSheet,
                  icon: const Icon(Icons.rate_review_outlined, size: 18),
                  label: const Text('Đánh giá ngay'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF228B22),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(value);
  }

  Future<void> _showPaymentSuccessDialog({
    required String title,
    required String subtitle,
    required double amount,
    required String method,
  }) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Green top banner ──────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF228B22), Color(0xFF2ecc71)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // ── Details ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F9F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Số tiền',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                          ),
                          Text(
                            _formatCurrency(amount),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF228B22),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet,
                            size: 18,
                            color: Color(0xFF228B22),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Phương thức',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF666666),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            method,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 18,
                            color: Color(0xFF888888),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Thời gian',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF666666),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat(
                              'HH:mm — dd/MM/yyyy',
                            ).format(DateTime.now()),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF228B22),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Hoàn Tất',
                          style: TextStyle(
                            fontSize: 15,
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
        await _showPaymentSuccessDialog(
          title: 'Hoàn Tất Thành Công',
          subtitle: 'Đơn cứu hộ của bạn đã được xác nhận hoàn tất.',
          amount: 0,
          method: 'Miễn phí',
        );
        if (mounted) {
          await _showFeedbackSheet();
        }
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
        SnackBar(
          content: Text('Hoàn tất đơn miễn phí thất bại: ${e.toString()}'),
        ),
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
        const SnackBar(content: Text('Đơn 0đ không cần thanh toán qua PayOS.')),
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

      setState(() {
        _pendingPayOsOrderCode = paymentResponse.orderCode;
        _pendingPayOsTransactionId = paymentResponse.transactionId;
        _isAwaitingPayOsReturn = true;
      });

      if (paymentResponse.checkoutUrl != null &&
          paymentResponse.checkoutUrl!.isNotEmpty) {
        final uri = Uri.tryParse(paymentResponse.checkoutUrl!);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Mở PayOS checkout...')));
        } else {
          throw Exception('Liên kết thanh toán không hợp lệ');
        }
      } else {
        throw Exception('Không nhận được liên kết thanh toán từ PayOS');
      }

      // After redirect and webhook, refresh UI state
      await ref
          .read(detailedIncidentProvider.notifier)
          .refreshDetailedIncident();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConfirmingPayOs = false;
        });
      }
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
        await _showPaymentSuccessDialog(
          title: 'Thanh Toán Thành Công',
          subtitle: 'Phí cứu hộ đã được thanh toán qua ví SnakeAidPay.',
          amount: amount,
          method: 'SnakeAidPay',
        );
        if (mounted) {
          await _showFeedbackSheet();
        }
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

    return PopScope(
      canPop: Navigator.of(context).canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black87,
              size: 20,
            ),
            onPressed: _handleBackNavigation,
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: const Color(0xFFE5E7EB), height: 1),
          ),
        ),
        bottomNavigationBar: showFooter
            ? SafeArea(child: _buildPaymentFooter(incident))
            : null,
        body: Stack(
          children: [
            detailedIncidentState.isLoading
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
                          _buildFeedbackCard(incident),
                          const SizedBox(height: 16),
                          _buildPaymentCard(incident),
                          const SizedBox(height: 16),
                          _buildMediaCard(incident),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
          ],
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
        onPressed: _isProcessingPayment
            ? null
            : () => _showPaymentSheet(incident),
        icon: _isProcessingPayment
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
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
    final amount = _getPaymentAmount(incident);
    final isFreePayment = amount <= 0;
    var isLoadingWallet = !isFreePayment;
    WalletInfo? walletInfo;
    var walletLoadStarted = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          if (!walletLoadStarted && !isFreePayment) {
            walletLoadStarted = true;
            Future<void>(() async {
              final wallet = await ref
                  .read(walletRepositoryProvider)
                  .getWalletInfo();
              if (!mounted) return;
              setSheetState(() {
                walletInfo = wallet;
                isLoadingWallet = false;
              });
            }).catchError((_) {
              if (!mounted) return;
              setSheetState(() {
                walletInfo = null;
                isLoadingWallet = false;
              });
            });
          }

          final balance = walletInfo?.balance ?? 0.0;
          final hasSufficientBalance =
              isFreePayment || (walletInfo != null && balance >= amount);

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                  headerGradient: const [Color(0xFF228B22), Color(0xFF1A6B1A)],
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
                          isLoadingWallet
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
                      if (!isFreePayment &&
                          !isLoadingWallet &&
                          walletInfo == null) ...[
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
                      if (!isFreePayment &&
                          !hasSufficientBalance &&
                          walletInfo != null) ...[
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
                  headerGradient: const [Color(0xFF1565C0), Color(0xFF0D47A1)],
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
                            _paymentFeatureChip(
                              Icons.credit_card,
                              'ATM / Visa',
                            ),
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
          Padding(padding: const EdgeInsets.all(16), child: body),
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
    final days = elapsed.inDays;
    final hours = elapsed.inHours % 24;
    final minutes = elapsed.inMinutes % 60;

    final isFinished = incident.status == IncidentStatus.finished;
    final isCompleted = incident.status == IncidentStatus.completed;
    final isCancelled =
        incident.status == IncidentStatus.cancelled ||
        incident.status == IncidentStatus.falseAlarm ||
        incident.status == IncidentStatus.noRescuerFound;
    final isAssigned =
        incident.status == IncidentStatus.assigned ||
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

    final elapsedText = days > 0
        ? 'Đã xảy ra $days ngày $hours giờ trước'
        : (hours > 0
              ? 'Đã xảy ra $hours giờ $minutes phút trước'
              : 'Đã xảy ra $minutes phút trước');

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
                        ? 'Chờ Thanh toán'
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
    final mission = incident.activeMission;
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
                _infoRowIcon('Mức độ', incident.severityText),
                _infoRowIcon(
                  'Thời gian',
                  DateFormat('dd/MM/yyyy  HH:mm').format(
                    (incident.incidentOccurredAt ?? DateTime.now()).toLocal(),
                  ),
                ),
                _infoRowIcon('Địa chỉ', incident.address ?? 'Chưa có'),
                _infoRowIcon(
                  'Tọa độ',
                  '${incident.locationCoordinates.latitude.toStringAsFixed(6)}, '
                      '${incident.locationCoordinates.longitude.toStringAsFixed(6)}',
                ),
                if (incident.symptomsReport?.isNotEmpty ?? false)
                  _infoRowIcon(
                    'Triệu chứng',
                    incident.symptomsReport!
                        .map((e) => e.symptomName)
                        .join('; '),
                  ),
                if (incident.identifiedSnakeSpecies != null)
                  _infoRowIcon(
                    'Loài rắn',
                    incident.identifiedSnakeSpecies!.commonName,
                  ),
                if (mission != null)
                  _infoRowIcon(
                    'Cần nhập viện',
                    mission.requiresHospitalization == true ? 'Có' : 'Không',
                  ),
                if (mission?.hospital != null)
                  _infoRowIcon(
                    'Bệnh viện chuyển đến',
                    mission!.hospital?.hospitalName ?? 'Chưa có',
                  ),
                if (incident.operatorNotes != null &&
                    incident.operatorNotes!.isNotEmpty)
                  _infoRowIcon(
                    'Ghi chú của điều phối viên',
                    incident.operatorNotes!,
                  ),
                if (incident.cancellationReason != null &&
                    incident.cancellationReason!.isNotEmpty)
                  _infoRowIcon('Lý do hủy', incident.cancellationReason!),
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
                            if (rescuer.phoneNumber != null &&
                                incident.status !=
                                    IncidentStatus.completed) ...[
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
                      if (rescuer.phoneNumber != null &&
                          incident.status != IncidentStatus.completed)
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
    final alreadyPaid = _hasPaid || incident.status == IncidentStatus.completed;
    final total = actualCost ?? serviceFee + (transportFee ?? 0);
    final headerColor = alreadyPaid
        ? const Color(0xFF228B22)
        : const Color(0xFF228B22);

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
                  alreadyPaid
                      ? Icons.check_circle
                      : Icons.receipt_long_outlined,
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
                  _payRow('Chi phí di chuyển', _formatCurrency(transportFee)),
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
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? const Color(0xFF111827) : Colors.grey[700],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal
                  ? const Color(0xFF2F65E0)
                  : const Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaCard(DetailedIncidentData incident) {
    final snakeMedia = incident.snakeIdentificationMedia;
    final evidenceGroups = incident.rescueMissionMedia
        .map(
          (group) => _MissionEvidenceGroupView(
            missionId: group.missionId,
            missionStatusText: group.missionStatus.displayText,
            mediaUrls: group.media
                .where((m) => m.purpose == MediaPurpose.evidence)
                .map((m) => m.mediaUrl)
                .where((url) => url.isNotEmpty)
                .toList(),
          ),
        )
        .where((group) => group.mediaUrls.isNotEmpty)
        .toList();
    final hasAnyMedia = snakeMedia.isNotEmpty || evidenceGroups.isNotEmpty;

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
                Icon(
                  Icons.photo_library_outlined,
                  color: Colors.white,
                  size: 20,
                ),
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
            child: !hasAnyMedia
                ? _buildEmptyMediaState('Chưa có ảnh rắn hoặc ảnh bằng chứng.')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMediaSectionTitle(
                        icon: Icons.pest_control,
                        color: const Color(0xFF7B1FA2),
                        title: 'Ảnh rắn từ báo cáo',
                        count: snakeMedia.length,
                      ),
                      const SizedBox(height: 10),
                      snakeMedia.isEmpty
                          ? _buildEmptyMediaState(
                              'Chưa có ảnh rắn được cung cấp.',
                            )
                          : _buildMediaGrid(
                              snakeMedia
                                  .map((media) => media.mediaUrl)
                                  .where((url) => url.isNotEmpty)
                                  .toList(),
                            ),
                      const SizedBox(height: 16),
                      _buildMediaSectionTitle(
                        icon: Icons.fact_check_outlined,
                        color: const Color(0xFF1565C0),
                        title: 'Ảnh bằng chứng cứu hộ',
                        count: evidenceGroups.fold<int>(
                          0,
                          (sum, group) => sum + group.mediaUrls.length,
                        ),
                      ),
                      const SizedBox(height: 10),
                      evidenceGroups.isEmpty
                          ? _buildEmptyMediaState(
                              'Chưa có ảnh bằng chứng từ nhiệm vụ cứu hộ.',
                            )
                          : Column(
                              children: evidenceGroups.map((group) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF1565C0,
                                              ).withOpacity(0.08),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      _buildMediaGrid(group.mediaUrls),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSectionTitle({
    required IconData icon,
    required Color color,
    required String title,
    required int count,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyMediaState(String text) {
    return Row(
      children: [
        Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey[400],
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaGrid(List<String> urls) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: urls.map((url) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 110,
            height: 82,
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[100],
                child: const Icon(
                  Icons.broken_image,
                  size: 28,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _infoRowIcon(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 2,
            height: 24,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
          ),
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
                const SizedBox(height: 4),
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
}

class _MissionEvidenceGroupView {
  final String missionId;
  final String missionStatusText;
  final List<String> mediaUrls;

  _MissionEvidenceGroupView({
    required this.missionId,
    required this.missionStatusText,
    required this.mediaUrls,
  });

  String get shortMissionId {
    final compact = missionId.replaceAll('-', '');
    if (compact.isEmpty) return 'N/A';
    return compact.length > 6
        ? compact.substring(compact.length - 6).toUpperCase()
        : compact.toUpperCase();
  }
}
