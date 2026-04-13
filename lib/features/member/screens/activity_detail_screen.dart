import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/handlers/payment_deep_link_coordinator.dart';
import '../../snake_catching/repository/snake_catching_repository.dart';
import '../../snake_catching/repository/snake_species_repository.dart';
import '../../snake_catching/repository/payos_repository.dart';
import '../../snake_catching/repository/transaction_repository.dart';
import '../../wallet/repository/wallet_repository.dart';
import '../../snake_catching/repository/feedback_repository.dart';
import '../../snake_catching/models/snake_catching_request.dart';
import '../../snake_catching/models/snake_species.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:intl/intl.dart';

/// Activity Detail Screen - Shows detailed information of a snake catching request
class ActivityDetailScreen extends ConsumerStatefulWidget {
  final String requestId;

  const ActivityDetailScreen({
    super.key,
    required this.requestId,
  });

  @override
  ConsumerState<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends ConsumerState<ActivityDetailScreen> {
  bool _isLoading = true;
  SnakeCatchingRequestData? _request;
  String? _errorMessage;
  Map<int, SnakeSpecies> _speciesDetailsMap = {};
  Set<int> _loadingSpeciesIds = {};
  Timer? _refreshTimer;

  // Deposit payment state (status == Assigned)
  TransactionInfo? _transaction;
  String? _depositTransactionId;   // set from wallet/PayOS response
  bool _isCheckingPayment = false;
  bool _isCreatingPayment = false;
  Timer? _paymentTimer;

  // Final payment state (status == Finished)
  TransactionInfo? _finalTransaction;
  String? _finalTransactionId;     // set from wallet/PayOS response
  bool _isCreatingFinalPayment = false;
  Timer? _finalPaymentTimer;
  bool _hasTransferredToRescuer = false;

  // True when round-1 CatchingDeposit is confirmed (set from mission presence or transaction check)
  bool _depositPaid = false;

  // Wallet
  WalletInfo? _walletInfo;
  bool _isPayingWithWallet = false;
  bool _isPayingFinalWithWallet = false;

  // Cancel
  bool _isCancelling = false;

  // Feedback
  bool _isSubmittingFeedback = false;

  // Scroll
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _paymentCardKey = GlobalKey();

  // Deep link
  StreamSubscription<PaymentDeepLinkEvent>? _deepLinkSub;
  int? _lastHandledDeepLinkEventId;

  @override
  void initState() {
    super.initState();
    _loadRequestDetail();
    _initDeepLinks();
    // Auto-refresh every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _silentRefresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _paymentTimer?.cancel();
    _finalPaymentTimer?.cancel();
    _scrollController.dispose();
    _deepLinkSub?.cancel();
    super.dispose();
  }

  /// Listen for PayOS callback deep link
  /// Handles both snakeaid://payment/return and https://snakeaid-dev.duykhiem.id.vn/payos/return
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

  void _handlePaymentDeepLinkEvent(PaymentDeepLinkEvent event) {
    if (!mounted || _lastHandledDeepLinkEventId == event.eventId) return;
    _lastHandledDeepLinkEventId = event.eventId;

    if (event.isSuccess && !event.isCancelled) {
      _checkPaymentStatus();
      _checkFinalPaymentStatus();
    } else if (event.isCancelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn đã hủy thanh toán. Vui lòng thử lại khi cần.'),
          backgroundColor: Color(0xFFFF8F00),
        ),
      );
    }
  }

  /// Smoothly scrolls to the payment card after the frame is rendered.
  void _scrollToPaymentCard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _paymentCardKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          alignment: 0.1, // a little from top so the card header is visible
        );
      }
    });
  }

  Future<void> _loadRequestDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(snakeCatchingRepositoryProvider);
      final response = await repository.getRequestById(widget.requestId);

      if (mounted && response.data != null) {
        setState(() {
          _request = response.data;
          _isLoading = false;
          // Mission only exists after deposit is confirmed — use as proxy for paid state
          if (response.data!.mission != null) _depositPaid = true;
        });

        // Load species details for each species in the request
        _loadSpeciesDetails();

        // Load wallet balance for payment options
        _loadWallet();
      } else {
        throw Exception('Không tìm thấy dữ liệu yêu cầu');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSpeciesDetails() async {
    if (_request == null) return;

    final speciesRepository = ref.read(snakeSpeciesRepositoryProvider);

    // Get unique species IDs from both reported details AND mission details
    final speciesIds = {
      ..._request!.details.map((d) => d.snakeSpeciesId),
      ...(_request!.mission?.missionDetails ?? []).map((d) => d.snakeSpeciesId),
    }.toList();

    for (final speciesId in speciesIds) {
      // Skip if already loaded
      if (_speciesDetailsMap.containsKey(speciesId)) continue;

      setState(() {
        _loadingSpeciesIds.add(speciesId);
      });

      try {
        final speciesDetail = await speciesRepository.getSnakeSpeciesById(speciesId);
        
        if (mounted && speciesDetail != null) {
          setState(() {
            _speciesDetailsMap[speciesId] = speciesDetail;
            _loadingSpeciesIds.remove(speciesId);
          });
        }
      } catch (e) {
        // Silently fail - just won't show the detailed info
        if (mounted) {
          setState(() {
            _loadingSpeciesIds.remove(speciesId);
          });
        }
      }
    }
  }

  /// Silent refresh without showing loading indicator
  Future<void> _silentRefresh() async {
    try {
      final repository = ref.read(snakeCatchingRepositoryProvider);
      final response = await repository.getRequestById(widget.requestId);

      if (mounted && response.data != null) {
        setState(() {
          _request = response.data;
          _errorMessage = null;
          if (response.data!.mission != null) _depositPaid = true;
        });

        // Load any new species details
        _loadSpeciesDetails();

        // If newly in deposit status, check payment
        const depositStatuses = {'Pending', 'Confirmed', 'Assigned'};
        if (depositStatuses.contains(_request!.status) && !_isCheckingPayment) {
          _checkPaymentStatus();
        } else if (_request!.status == 'Finished' && !_isCreatingFinalPayment) {
          _checkFinalPaymentStatus(silent: true);
        } else if (_request!.status == 'Completed') {
          // Request already moved to Completed — cancel all timers
          _finalPaymentTimer?.cancel();
          _paymentTimer?.cancel();
        }
      }
    } catch (e) {
      // Silently fail - don't show error on background refresh
    }
  }

  /// Check deposit payment status via GET /api/transactions/{id}.
  /// Only runs when [_depositTransactionId] has been set from a payment response.
  Future<void> _checkPaymentStatus({bool silent = false, bool scrollIfUnpaid = false}) async {
    if (!mounted) return;
    final tid = _depositTransactionId;
    if (tid == null) return;
    if (!silent) setState(() => _isCheckingPayment = true);
    try {
      final repo = ref.read(transactionRepositoryProvider);
      final tx = await repo.getTransactionById(tid);
      if (!mounted) return;
      setState(() {
        _transaction = tx;
        _isCheckingPayment = false;
        if (tx != null && tx.isPaid) _depositPaid = true;
      });
      if (scrollIfUnpaid && (tx == null || !tx.isPaid)) {
        _scrollToPaymentCard();
      }
      // Poll until BE confirms payment
      if (tx == null || !tx.isPaid) {
        _paymentTimer?.cancel();
        _paymentTimer = Timer.periodic(const Duration(seconds: 5), (_) {
          if (_depositTransactionId != null &&
              {'Pending', 'Confirmed', 'Assigned'}.contains(_request?.status)) {
            _checkPaymentStatus(silent: true);
          } else {
            _paymentTimer?.cancel();
          }
        });
      } else {
        _paymentTimer?.cancel();
      }
    } catch (_) {
      if (mounted) setState(() => _isCheckingPayment = false);
    }
  }

  Future<void> _loadWallet() async {
    try {
      final wallet = await ref.read(walletRepositoryProvider).getWalletInfo();
      if (mounted) setState(() => _walletInfo = wallet);
    } catch (_) {}
  }

  // ──────────────────────────────────────────────────────────────────
  // Feedback
  // ──────────────────────────────────────────────────────────────────
  void _showFeedbackSheet() {
    final request = _request;
    if (request == null) return;
    final rescuer = request.assignedRescuer;
    if (rescuer == null) return;

    int selectedRating = 0;
    final commentController = TextEditingController();

    // Check if already submitted
    final currentUser = ref.read(currentUserProvider);
    final alreadyReviewed = currentUser != null &&
        request.feedbacks.any((f) =>
            f.raterId == currentUser.id &&
            f.targetUserId == rescuer.accountId &&
            f.referenceId == request.id);
    if (alreadyReviewed) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 20),

                  // Avatar + name
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundImage: rescuer.avatarUrl != null
                            ? NetworkImage(rescuer.avatarUrl!)
                            : null,
                        backgroundColor: const Color(0xFFFF6B35).withOpacity(0.15),
                        child: rescuer.avatarUrl == null
                            ? const Icon(Icons.person, color: Color(0xFFFF6B35))
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Đánh giá cứu hộ viên',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F1F1F))),
                            const SizedBox(height: 2),
                            Text(
                              rescuer.fullName ?? 'Cứu hộ viên',
                              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Star row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () => setSheet(() => selectedRating = i + 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            i < selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
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
                      ['', 'Rất tệ', 'Tệ', 'Bình thường', 'Tốt', 'Tuyệt vời!'][selectedRating],
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selectedRating >= 4
                              ? const Color(0xFF228B22)
                              : selectedRating == 3
                                  ? Colors.orange
                                  : const Color(0xFFDC3545)),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Comment field
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    maxLength: 300,
                    decoration: InputDecoration(
                      hintText: 'Chia sẻ trải nghiệm của bạn (không bắt buộc)...',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFFF6F8F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(14),
                      counterStyle: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('Để sau',
                              style: TextStyle(color: Colors.grey[600])),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: selectedRating == 0 || _isSubmittingFeedback
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
                                borderRadius: BorderRadius.circular(12)),
                            disabledBackgroundColor: Colors.grey[200],
                          ),
                          child: _isSubmittingFeedback
                              ? const SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Gửi đánh giá',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
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
    if (_request == null) return;
    setState(() => _isSubmittingFeedback = true);
    try {
      await ref.read(feedbackRepositoryProvider).submitFeedback(
            FeedbackRequest(
              targetUserId: targetUserId,
              referenceId: _request!.id,
              type: 'Catching',
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      _silentRefresh();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmittingFeedback = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: const Color(0xFFDC3545),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget _buildFeedbackCard(SnakeCatchingRequestData request) {
    final currentUser = ref.read(currentUserProvider);
    final rescuer = request.assignedRescuer;
    if (rescuer == null) return const SizedBox.shrink();

    // Check if current member already left a feedback for this rescuer
    final existing = currentUser != null
        ? request.feedbacks
            .where((f) =>
                f.raterId == currentUser.id &&
                f.targetUserId == rescuer.accountId &&
                f.referenceId == request.id)
            .firstOrNull
        : null;

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
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB300).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star_rounded,
                      color: Color(0xFFFFB300), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Đánh giá dịch vụ',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F1F1F))),
                      Text(
                        rescuer.fullName ?? 'Cứu hộ viên',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            if (existing != null) ...[
              // ── Show submitted feedback ──
              Row(
                children: List.generate(5, (i) => Icon(
                  i < existing.rating ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 22,
                  color: i < existing.rating ? const Color(0xFFFFB300) : Colors.grey[300],
                )),
              ),
              if (existing.comments != null && existing.comments!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '"${existing.comments!}"',
                  style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[700]),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 14, color: const Color(0xFF228B22)),
                  const SizedBox(width: 5),
                  Text('Đã gửi đánh giá',
                      style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF228B22),
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ] else ...[
              // ── Prompt to leave feedback ──
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
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // Cancel Request
  // ──────────────────────────────────────────────────────────────────
  void _showCancelSheet() {
    const reasons = [
      'Không cần hỗ trợ nữa',
      'Đã tự xử lý được',
      'Chọn nhầm địa chỉ / thông tin sai',
      'Chờ quá lâu, không có cứu hộ viên',
      'Thay đổi kế hoạch',
      'Lý do khác',
    ];
    String? selectedReason;
    final otherController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(ctx).padding.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC3545).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.cancel_outlined, color: Color(0xFFDC3545), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Hủy Đơn',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Vui lòng cho chúng tôi biết lý do bạn muốn hủy đơn.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                // Reason options
                ...reasons.map((r) => GestureDetector(
                  onTap: () => setSheetState(() => selectedReason = r),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: selectedReason == r
                          ? const Color(0xFFDC3545).withOpacity(0.07)
                          : const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selectedReason == r
                            ? const Color(0xFFDC3545)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selectedReason == r
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 18,
                          color: selectedReason == r
                              ? const Color(0xFFDC3545)
                              : Colors.grey[400],
                        ),
                        const SizedBox(width: 10),
                        Text(
                          r,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: selectedReason == r
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: selectedReason == r
                                ? const Color(0xFFDC3545)
                                : const Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
                // Free-text field when "Lý do khác" is selected
                if (selectedReason == 'Lý do khác') ...[  
                  const SizedBox(height: 4),
                  TextField(
                    controller: otherController,
                    autofocus: true,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Nhập lý do của bạn...',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFFF8F8F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFDC3545), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onChanged: (_) => setSheetState(() {}),
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 8),
                // Warning note for Assigned status
                if (_request?.status == 'Assigned')
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFE082)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Color(0xFFFF8F00), size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Cứu hộ viên đã được phân công. Việc hủy lúc này có thể ảnh hưởng đến uy tín của bạn.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF7B5800)),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Confirm button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: selectedReason == null
                        ? null
                        : selectedReason == 'Lý do khác' && otherController.text.trim().isEmpty
                            ? null
                            : () {
                                final reason = selectedReason == 'Lý do khác'
                                    ? otherController.text.trim()
                                    : selectedReason!;
                                Navigator.pop(ctx);
                                _executeCancelRequest(reason);
                              },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC3545),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[200],
                      disabledForegroundColor: Colors.grey[400],
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'XÁC NHẬN HỦY ĐƠN',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _executeCancelRequest(String reason) async {
    setState(() => _isCancelling = true);
    try {
      await ref.read(snakeCatchingRepositoryProvider).cancelRequest(widget.requestId, reason);
      if (!mounted) return;
      setState(() => _isCancelling = false);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cancel, color: Colors.grey, size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'Đơn đã được hủy',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F)),
              ),
              const SizedBox(height: 8),
              Text(
                'Yêu cầu của bạn đã được hủy thành công.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/member-home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF228B22),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: const Text('Về Danh Sách', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCancelling = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceAll('Exception: ', '')),
        backgroundColor: const Color(0xFFDC3545),
      ));
    }
  }

  String _formatCurrencyVnd(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ';
  }

  /// Pay round-1 deposit using SnakeAidPay wallet
  Future<void> _payWithWallet() async {
    if (_request == null) return;
    final amount = _request!.estimatedPrice ?? _request!.mission?.estimatedCost;
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có thông tin giá để thanh toán')),
      );
      return;
    }
    setState(() => _isPayingWithWallet = true);
    try {
      final transactionId = await ref.read(walletRepositoryProvider).payWithWallet(
        snakeCatchingRequestId: _request!.id,
        amount: amount,
        transactionType: 'CatchingDeposit',
        description: 'Catching deposit 1',
      );
      if (!mounted) return;
      setState(() {
        _isPayingWithWallet = false;
        _depositTransactionId = transactionId;
        _depositPaid = true;
      });
      final depositAmount = _request!.estimatedPrice ?? _request!.mission?.estimatedCost ?? 0;
      await _showPaymentSuccessDialog(
        title: 'Thanh Toán Thành Công!',
        subtitle: 'Đặt cọc phí di chuyển đã được xác nhận.',
        amount: depositAmount,
        method: 'Ví SnakeAidPay',
      );
      _loadWallet();
      _checkPaymentStatus();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPayingWithWallet = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  /// Pay round-2 service fee using SnakeAidPay wallet
  Future<void> _payFinalWithWallet() async {
    if (_request == null) return;
    final double finalAmount = (_request!.mission?.actualCost ?? 0).toDouble();
    if (finalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có thông tin giá để thanh toán')),
      );
      return;
    }
    setState(() => _isPayingFinalWithWallet = true);
    try {
      final transactionId = await ref.read(walletRepositoryProvider).payWithWallet(
        snakeCatchingRequestId: _request!.id,
        amount: finalAmount,
        transactionType: 'CatchingPayment',
        description: 'Catching payment',
      );
      if (!mounted) return;
      setState(() {
        _isPayingFinalWithWallet = false;
        _finalTransactionId = transactionId;
      });
      await _showPaymentSuccessDialog(
        title: 'Thanh Toán Thành Công!',
        subtitle: 'Thanh toán dịch vụ bắt rắn đã được xác nhận.',
        amount: finalAmount,
        method: 'Ví SnakeAidPay',
      );
      // Prompt feedback right after payment
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 300));
        _showFeedbackSheet();
      }
      _loadWallet();
      if (!_hasTransferredToRescuer) {
        _hasTransferredToRescuer = true;
      }
      _checkFinalPaymentStatus();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPayingFinalWithWallet = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  /// Create PayOS payment link and open checkout URL
  Future<void> _openPayment() async {
    if (_request == null) return;
    final amount = _request!.estimatedPrice ?? _request!.mission?.estimatedCost;
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có thông tin giá để thanh toán')),
      );
      return;
    }

    setState(() => _isCreatingPayment = true);
    try {
      final repo = ref.read(payosRepositoryProvider);
      final link = await repo.createPaymentLink(
        snakeCatchingRequestId: _request!.id,
        amount: amount,
        description: 'Catching deposit 1',
      );
      if (!mounted) return;
      setState(() {
        _isCreatingPayment = false;
        if (link.transactionId != null) _depositTransactionId = link.transactionId;
      });

      final uri = Uri.parse(link.checkoutUrl);
      // externalApplication + App Links (assetlinks.json on server) = auto-return to app.
      // Falls back to manual browser close if assetlinks.json not yet deployed.
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      // If App Links didn't trigger deep link, still check on resume
      if (mounted) _checkPaymentStatus();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCreatingPayment = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  /// Check final payment (CatchingPayment) status via GET /api/transactions/{id}.
  /// Only runs when [_finalTransactionId] has been set from a payment response.
  Future<void> _checkFinalPaymentStatus({bool silent = false, bool scrollIfUnpaid = false}) async {
    if (!mounted) return;
    final tid = _finalTransactionId;
    if (tid == null) return;
    try {
      final repo = ref.read(transactionRepositoryProvider);
      final tx = await repo.getTransactionById(tid);
      if (!mounted) return;

      final requestIsPaid = (_request?.status == 'Completed');
      final txIsFinalPayment = (tx?.isCatchingPayment == true);

      setState(() {
        _finalTransaction = (txIsFinalPayment || requestIsPaid) ? tx : null;
      });

      if (scrollIfUnpaid && _finalTransaction == null) _scrollToPaymentCard();

      if (_finalTransaction == null) {
        // Transaction not yet a confirmed CatchingPayment — poll every 5s
        _finalPaymentTimer?.cancel();
        _finalPaymentTimer = Timer.periodic(const Duration(seconds: 5), (_) {
          if (_finalTransactionId != null && _request?.status == 'Finished') {
            _checkFinalPaymentStatus(silent: true);
          } else {
            _finalPaymentTimer?.cancel();
          }
        });
      } else if (requestIsPaid || (txIsFinalPayment && _finalTransaction!.isPaid)) {
        // Payment confirmed
        _finalPaymentTimer?.cancel();
        _hasTransferredToRescuer = true;
      } else {
        // Transaction exists but not confirmed yet — poll every 3s
        _finalPaymentTimer?.cancel();
        _finalPaymentTimer = Timer.periodic(const Duration(seconds: 3), (_) {
          _checkFinalPaymentStatus(silent: true);
        });
      }
    } catch (_) {}
  }

  /// Create PayOS final payment link (CatchingPayment) and open checkout
  Future<void> _openFinalPayment() async {
    if (_request == null) return;
    final mission = _request!.mission;
    // Round-2 payment = actualCost (base + snake + env fees; travel already paid in round 1)
    final double finalAmount = (mission?.actualCost ?? 0).toDouble();
    if (finalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có thông tin giá để thanh toán')),
      );
      return;
    }

    setState(() => _isCreatingFinalPayment = true);
    try {
      final repo = ref.read(payosRepositoryProvider);
      final link = await repo.createPaymentLink(
        snakeCatchingRequestId: _request!.id,
        amount: finalAmount,
        description: 'Catching payment',
        transactionType: 'CatchingPayment',
      );
      if (!mounted) return;
      setState(() {
        _isCreatingFinalPayment = false;
        if (link.transactionId != null) _finalTransactionId = link.transactionId;
      });
      await launchUrl(Uri.parse(link.checkoutUrl), mode: LaunchMode.externalApplication);
      if (mounted) _checkFinalPaymentStatus();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCreatingFinalPayment = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        title: const Text(
          'Chi Tiết Yêu Cầu',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.go('/member-home'),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _request != null
                  ? _buildDetailView()
                  : _buildNotFoundView(),
      bottomSheet: _request != null ? _buildStickyFooter(_request!) : null,
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFDC3545),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRequestDetail,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử Lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF228B22),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không Tìm Thấy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yêu cầu này không tồn tại hoặc đã bị xóa.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF228B22),
                foregroundColor: Colors.white,
              ),
              child: const Text('Quay Lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailView() {
    final request = _request!;
    final dateFormat = DateFormat('dd/MM/yyyy, HH:mm');
    final effectiveStatus = _getEffectiveStatus(request);
    final statusColor = _getStatusColor(effectiveStatus);

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          
          // Status Icon & Title
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(effectiveStatus),
                size: 60,
                color: statusColor,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          Center(
            child: Text(
              _getStatusText(effectiveStatus),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),

          // Sub-status label when mission is En_Route or Arrived
          if (effectiveStatus == 'en_route' || effectiveStatus == 'arrived') ...[          
            const SizedBox(height: 6),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  effectiveStatus == 'en_route'
                  ? 'Tài xế đang trên đường đến'
                  : 'Tài xế đã đến nơi',                  
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 24),

          // ── Status Progress Stepper ───────────────────────────────
          _buildStatusStepper(effectiveStatus, request.status),

          const SizedBox(height: 24),

          // Summary Card
          Container(
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
                // Green Header
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
                      Icon(Icons.description, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Thông Tin Yêu Cầu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Info Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.access_time,
                        'Thời gian gửi',
                        dateFormat.format(request.requestDate.toLocal()),
                      ),
                      
                      if (request.priority != 'Normal') ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.priority_high,
                          'Mức độ ưu tiên',
                          _getPriorityText(request.priority),
                          valueColor: _getPriorityColor(request.priority),
                        ),
                      ],
                      
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.location_on,
                        'Địa điểm',
                        request.address,
                        maxLines: 3,
                      ),

                      if (request.distanceKm != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.route,
                          'Khoảng cách',
                          '${request.distanceKm!.toStringAsFixed(1)} km',
                          valueColor: const Color(0xFF2196F3),
                        ),
                      ],
                      
                      if (request.preferredTime != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.schedule,
                          'Thời gian mong muốn',
                          DateFormat('HH:mm').format(request.preferredTime!.toLocal()),
                        ),
                      ],
                      
                      if (request.assignedRescuerId != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.person,
                          'Trạng thái nhiệm vụ',
                          request.mission != null
                              ? _getStatusText(_getEffectiveStatus(request))
                              : 'Đã được phân công',
                          valueColor: _getStatusColor(_getEffectiveStatus(request)),
                        ),
                        if (request.assignedAt != null) ...[
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 32),
                            child: Text(
                              'Phân công lúc: ${dateFormat.format(request.assignedAt!.toLocal())}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Rescuer Info Card (when Assigned, Finished, Paid, or Completed) ──
          if (request.status == 'Assigned' || request.status == 'Finished' ||
              request.status == 'Paid' || request.status == 'Completed') ...[
            const SizedBox(height: 16),
            _buildRescuerInfoCard(request),
          ],

          // ── Payment Card (Pending / Confirmed / Assigned — unpaid or already paid) ──
          if (const {'Pending', 'Confirmed', 'Assigned'}.contains(request.status)) ...[            
            const SizedBox(height: 16),
            _buildPaymentCard(request),
          ],

          // ── Final Payment Card (when Finished, Paid, or Completed) ──
          if (request.status == 'Finished' || request.status == 'Paid' ||
              request.status == 'Completed') ...[
            const SizedBox(height: 16),
            _buildFinishedPaymentCard(request),
          ],

          // Species Section — caught snakes when Finished/Paid/Completed; reported snakes otherwise
          if ((request.status == 'Finished' || request.status == 'Paid' ||
               request.status == 'Completed')) ...[
            Builder(builder: (_) {
              final missionDetails = request.mission?.missionDetails ?? [];
              // Prefer missionDetails (rescuer-confirmed catches); fall back to request.details
              if (missionDetails.isNotEmpty) {
                final int total = missionDetails.fold(0, (s, d) => s + d.quantity);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Rắn Đã Bắt Được ($total)',
                        style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8, runSpacing: 8,
                        children: missionDetails.map(_buildMissionSpeciesChip).toList(),
                      ),
                    ),
                  ],
                );
              } else if (request.details.isNotEmpty) {
                final int total = request.details.fold(0, (s, d) => s + d.quantity);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Rắn Đã Bắt Được ($total)',
                        style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8, runSpacing: 8,
                        children: request.details.map((d) => _buildSpeciesChip(d)).toList(),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
          ] else if (request.details.isNotEmpty) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Loài Rắn Gặp Phải (${request.details.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: request.details.map((detail) => _buildSpeciesChip(detail)).toList(),
              ),
            ),
          ],

          // Additional Details
          if (request.additionalDetails != null && request.additionalDetails!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F8FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFF2196F3), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Ghi Chú Địa Chỉ',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    request.additionalDetails!,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Notes
          if (request.notes != null && request.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFFFF9800), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Thông Tin Bổ Sung',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    request.notes!,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // ── Feedback card (Paid / Completed) ─────────────────────
          if (request.status == 'Paid' ||
              request.status == 'Completed' ||
              request.status == 'Finished')
            _buildFeedbackCard(request),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // Sticky Footer
  // ──────────────────────────────────────────────────────────────────
  Widget _buildStickyFooter(SnakeCatchingRequestData request) {
    // Deposit payment is allowed at Pending, Confirmed, Assigned statuses
    const depositStatuses = {'Pending', 'Confirmed', 'Assigned'};
    final bool needPayment = depositStatuses.contains(request.status) && !_depositPaid;
    final bool needFinalPayment = request.status == 'Finished' &&
        _finalTransaction == null;
    final bool isAnyLoading = _isCreatingPayment || _isCreatingFinalPayment ||
        _isPayingWithWallet || _isPayingFinalWithWallet;

    // Cancel is allowed: Pending (any time) or Assigned only when mission is still Preparing
    final bool canCancel = !_isCancelling &&
        (request.status == 'Pending' ||
            (request.status == 'Assigned' &&
                (request.mission == null || request.mission!.status == 'Preparing')));

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (needPayment || needFinalPayment) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isAnyLoading
                    ? null
                    : () => _showPaymentSheet(isFinalPayment: needFinalPayment),
                icon: isAnyLoading
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.payment_rounded, size: 20),
                label: Text(
                  isAnyLoading
                      ? 'Đang xử lý...'
                      : (needFinalPayment ? 'THANH TOÁN DỊCH VỤ' : 'THANH TOÁN PHÍ DI CHUYỂN'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF228B22),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              // Cancel button (small, left)
              if (canCancel) ...[  
                SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: _isCancelling ? null : _showCancelSheet,
                    icon: _isCancelling
                        ? const SizedBox(width: 14, height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFDC3545)))
                        : const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Hủy đơn', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC3545),
                      side: const BorderSide(color: Color(0xFFDC3545)),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () => context.go('/member-home'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF228B22),
                      side: const BorderSide(color: Color(0xFF228B22)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Quay Lại',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // Payment Method Bottom Sheet
  // ──────────────────────────────────────────────────────────────────
  void _showPaymentSheet({required bool isFinalPayment}) {
    // Refresh wallet before opening
    _loadWallet();

    // Compute final-payment amount the same way the UI card does:
    // prefer actualCost, fall back to baseFee + snakeFee + envFee
    double _finalAmount() {
      final m = _request!.mission;
      if (m?.actualCost != null && m!.actualCost! > 0) return m.actualCost!.toDouble();
      final base  = m?.price ?? 0;
      final snake = (m?.missionDetails ?? []).fold<double>(0, (s, d) => s + d.price);
      final env   = m?.catchingEnvironment?.price ?? 0;
      return (base + snake + env).toDouble();
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _PaymentMethodSheet(
        isFinalPayment: isFinalPayment,
        walletInfo: _walletInfo,
        amount: isFinalPayment
            ? _finalAmount()
            : (_request!.estimatedPrice ?? _request!.mission?.estimatedCost ?? 0).toDouble(),
        onPayOS: () {
          Navigator.pop(ctx);
          if (isFinalPayment) {
            _openFinalPayment();
          } else {
            _openPayment();
          }
        },
        onWallet: () {
          Navigator.pop(ctx);
          if (isFinalPayment) {
            _payFinalWithWallet();
          } else {
            _payWithWallet();
          }
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // Payment Success Dialog
  // ──────────────────────────────────────────────────────────────────
  Future<void> _showPaymentSuccessDialog({
    required String title,
    required String subtitle,
    required double amount,
    required String method,
  }) async {
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
                    // Amount row
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
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
                                fontSize: 14, color: Color(0xFF666666)),
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
                    // Method row
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_wallet,
                              size: 18, color: Color(0xFF228B22)),
                          const SizedBox(width: 10),
                          const Text(
                            'Phương thức',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF666666)),
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
                    // Time row
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 18, color: Color(0xFF888888)),
                          const SizedBox(width: 10),
                          const Text(
                            'Thời gian',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF666666)),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat('HH:mm — dd/MM/yyyy')
                                .format(DateTime.now()),
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
                    // Done button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF228B22),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Hoàn Tất',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
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

  // ──────────────────────────────────────────────────────────────────
  // Rescuer Info Card
  // ──────────────────────────────────────────────────────────────────
  Widget _buildRescuerInfoCard(SnakeCatchingRequestData request) {
    final rescuer = request.assignedRescuer;
    final name = rescuer?.fullName ?? 'Người cứu hộ';
    final phone = rescuer?.phoneNumber;
    final rating = rescuer?.rating;
    final ratingCount = rescuer?.ratingCount ?? 0;
    final avatarUrl = rescuer?.avatarUrl;

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
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.3), width: 2),
                  ),
                  child: avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              size: 36,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                        )
                      : const Icon(Icons.person, size: 36, color: Color(0xFF2196F3)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (rating != null && rating > 0)
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              const star = Color(0xFFFFC107);
                              return Icon(
                                i < rating.round() ? Icons.star : Icons.star_border,
                                color: star,
                                size: 16,
                              );
                            }),
                            const SizedBox(width: 4),
                            Text(
                              '${rating.toStringAsFixed(1)}${ratingCount > 0 ? ' ($ratingCount đánh giá)' : ''}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        )
                      else
                        const Text(
                          'Chưa có đánh giá',
                          style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                        ),
                      if (request.assignedAt != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 12, color: Color(0xFF999999)),
                            const SizedBox(width: 4),
                            Text(
                              'Nhận đơn: ${DateFormat('HH:mm dd/MM').format(request.assignedAt!.toLocal())}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Phone call button
          if (phone != null && phone.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final uri = Uri(scheme: 'tel', path: phone);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  icon: const Icon(Icons.call, size: 18, color: Color(0xFF2196F3)),
                  label: Text(
                    'Gọi $phone',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2196F3)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // Payment Card
  // ──────────────────────────────────────────────────────────────────
  Widget _buildPaymentCard(SnakeCatchingRequestData request) {
    final paid = _depositPaid;
    final amount = request.estimatedPrice ?? request.mission?.estimatedCost;

    return Container(
      key: _paymentCardKey,
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
              color: paid ? const Color(0xFF28A745) : const Color(0xFFFF8F00),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  paid ? Icons.check_circle : Icons.payments_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  paid ? 'Đã Thanh Toán Phí Di Chuyển' : 'Thanh Toán Phí Di Chuyển',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (_isCheckingPayment) ...[
                  const Spacer(),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                ],
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Deposit amount (round 1) ──
                if (amount != null) ...[
                  _buildPayRow(
                    'Phí di chuyển (đang thanh toán):',
                    _formatCurrency(amount),
                    icon: Icons.directions_car,
                    valueColor: const Color(0xFF28A745),
                  ),
                  if (request.distanceKm != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 28, top: 2),
                      child: Text(
                        'Khoảng cách: ${request.distanceKm!.toStringAsFixed(1)} km',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],

                // ── Round-2 cost preview ──
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.receipt_long, size: 15, color: Color(0xFF888888)),
                          SizedBox(width: 6),
                          Text(
                            'Chi phí sẽ thanh toán sau khi hoàn thành',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                                color: Color(0xFF666666)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Base fee
                      if (request.mission?.price != null)
                        _buildPayRow(
                          'Phí dịch vụ cơ bản:',
                          _formatCurrency(request.mission!.price!),
                          icon: Icons.miscellaneous_services,
                        ),
                      // Snake catching fee from missionDetails (if available)
                      if ((request.mission?.missionDetails ?? []).isNotEmpty) ...[  
                        const SizedBox(height: 6),
                        _buildPayRow(
                          'Phí bắt rắn:',
                          _formatCurrency((request.mission!.missionDetails
                              .fold(0.0, (s, d) => s + d.price))),
                          icon: Icons.pest_control,
                        ),
                        ...request.mission!.missionDetails.map((d) => Padding(
                              padding: const EdgeInsets.only(top: 4, left: 28),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('· ${d.snakeSpeciesName} × ${d.quantity}',
                                      style: const TextStyle(fontSize: 12,
                                          color: Color(0xFF888888))),
                                  Text(_formatCurrency(d.price),
                                      style: const TextStyle(fontSize: 12,
                                          color: Color(0xFF888888))),
                                ],
                              ),
                            )),
                      ] else ...[  
                        const SizedBox(height: 6),
                        const Row(
                          children: [
                            Icon(Icons.pest_control, size: 14, color: Color(0xFFAAAAAA)),
                            SizedBox(width: 6),
                            Text('Phí bắt rắn: xác nhận sau khi hoàn thành',
                                style: TextStyle(fontSize: 12, color: Color(0xFFAAAAAA),
                                    fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ],
                      // Environment fee
                      if (request.mission?.catchingEnvironment != null) ...[  
                        const SizedBox(height: 6),
                        _buildPayRow(
                          'Phụ phí khu vực (${request.mission!.catchingEnvironment!.name}):',
                          _formatCurrency(request.mission!.catchingEnvironment!.price),
                          icon: Icons.home_work_outlined,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),


                if (paid) ...[
                  // Paid state
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: Color(0xFF28A745), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Thanh toán thành công!',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF28A745),
                                ),
                              ),
                              if (_transaction?.amount != null)
                                Text(
                                  'Đã thanh toán: ${_formatCurrency(_transaction!.amount)}',
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF4CAF50)),
                                ),
                              const SizedBox(height: 2),
                              const Text(
                                'Người cứu hộ đang trên đường đến',
                                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Not paid state
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFE082)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFFFF8F00), size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Vui lòng thanh toán đặt cọc để người cứu hộ bắt đầu di chuyển đến địa điểm của bạn.',
                            style: TextStyle(fontSize: 13, color: Color(0xFF795548), height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.refresh, size: 12, color: Color(0xFF999999)),
                      SizedBox(width: 4),
                      Text(
                        'Tự động kiểm tra mỗi 5 giây',
                        style: TextStyle(fontSize: 11, color: Color(0xFF999999)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // Finished Payment Card (CatchingPayment)
  // Two separate cards: Round 1 (done) + Round 2 (pending/done)
  // ──────────────────────────────────────────────────────────────────
  Widget _buildFinishedPaymentCard(SnakeCatchingRequestData request) {
    final mission = request.mission;

    final double baseFee   = mission?.price ?? 0;
    final double travelFee = mission?.estimatedCost ?? 0;
    final double snakeFee  = (mission?.missionDetails ?? [])
        .fold(0.0, (sum, d) => sum + d.price);
    final double envFee    = mission?.catchingEnvironment?.price ?? 0;
    final String? envName  = mission?.catchingEnvironment?.name;
    final double round2Amount = mission?.actualCost ?? (baseFee + snakeFee + envFee);
    final double totalPaid = travelFee + round2Amount;

    final bool round2Paid = _finalTransaction != null ||
        request.status == 'Paid' ||
        request.status == 'Completed';

    // Evidence photos
    final missionMedia = request.mission?.media ?? [];
    final evidencePhotos = missionMedia.isNotEmpty
        ? missionMedia.where((m) => m.purpose == 'Evidence').toList()
        : request.media.where((m) => m.purpose == 'Evidence' || m.url.isNotEmpty).toList();

    Widget _card({required Widget child}) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: child,
        );

    Widget _cardHeader(String title, Color color, IconData icon) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ]),
        );

    // ── Card 1: Round 1 — travel fee (always done by this point) ────
    final round1Card = _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            'Đợt 1 — Phí Di Chuyển (Đã Thanh Toán)',
            const Color(0xFF28A745),
            Icons.check_circle,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildPayRow(
                  'Phí di chuyển:',
                  _formatCurrency(travelFee),
                  icon: Icons.directions_car,
                  valueColor: const Color(0xFF28A745),
                ),
                if (request.distanceKm != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Khoảng cách: ${request.distanceKm!.toStringAsFixed(1)} km',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, color: Color(0xFF28A745), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Đã thanh toán ${_formatCurrency(travelFee)}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF28A745)),
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

    // ── Card 2: Round 2 — service payment ───────────────────────────
    final round2Card = _card(
      child: Column(
        key: _paymentCardKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            round2Paid ? 'Đợt 2 — Thanh Toán Dịch Vụ (Đã Thanh Toán)' : 'Đợt 2 — Thanh Toán Dịch Vụ',
            round2Paid ? const Color(0xFF28A745) : const Color(0xFFFF6B35),
            round2Paid ? Icons.check_circle : Icons.payments_outlined,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chi tiết đợt 2:',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF555555))),
                const SizedBox(height: 10),

                // Base fee
                _buildPayRow('Phí dịch vụ cơ bản:', _formatCurrency(baseFee),
                    icon: Icons.miscellaneous_services),

                // Snake fee
                if (snakeFee > 0) ...[
                  const SizedBox(height: 8),
                  _buildPayRow('Phí bắt rắn:', _formatCurrency(snakeFee),
                      icon: Icons.pest_control),
                  ...(mission?.missionDetails ?? []).map((d) => Padding(
                        padding: const EdgeInsets.only(top: 4, left: 28),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${d.snakeSpeciesName} × ${d.quantity}',
                                style: const TextStyle(
                                    fontSize: 13, color: Color(0xFF888888))),
                            Text(_formatCurrency(d.price),
                                style: const TextStyle(
                                    fontSize: 13, color: Color(0xFF888888))),
                          ],
                        ),
                      )),
                ],

                // Environment fee
                if (envFee > 0) ...[
                  const SizedBox(height: 8),
                  _buildPayRow(
                    'Phụ phí khu vực${envName != null ? ' ($envName)' : ''}:',
                    _formatCurrency(envFee),
                    icon: Icons.home_work_outlined,
                  ),
                ],

                const Divider(height: 24, color: Color(0xFFE0E0E0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      round2Paid ? 'Đã thanh toán:' : 'Số tiền cần thanh toán:',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333)),
                    ),
                    Text(
                      _formatCurrency(round2Amount),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: round2Paid
                              ? const Color(0xFF28A745)
                              : const Color(0xFFFF6B35)),
                    ),
                  ],
                ),

                // ── Evidence photos (shown in round-2 card) ──
                if (evidencePhotos.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Ảnh bằng chứng nhiệm vụ',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333))),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: evidencePhotos.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final photo = evidencePhotos[i];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            photo.url,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 90,
                              height: 90,
                              color: const Color(0xFFF0F0F0),
                              child: const Icon(Icons.image_not_supported,
                                  color: Color(0xFFCCCCCC)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // ── Payment status ──
                if (round2Paid) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: Color(0xFF28A745), size: 22),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Thanh toán đợt 2 thành công!',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF28A745)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFE082)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFFFF8F00), size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Người cứu hộ đã hoàn thành nhiệm vụ. Vui lòng thanh toán để xác nhận dịch vụ.',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF795548), height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.refresh, size: 12, color: Color(0xFF999999)),
                      SizedBox(width: 4),
                      Text('Tự động kiểm tra mỗi 5 giây',
                          style: TextStyle(fontSize: 11, color: Color(0xFF999999))),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    // ── Card 3: Total summary (only when fully paid) ─────────────────
    final totalCard = round2Paid
        ? Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF28A745), Color(0xFF20C85A)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF28A745).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long, color: Colors.white, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tổng đã thanh toán',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(totalPaid),
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Đợt 1: ${_formatCurrency(travelFee)}',
                        style: const TextStyle(fontSize: 12, color: Colors.white70)),
                    const SizedBox(height: 2),
                    Text('Đợt 2: ${_formatCurrency(round2Amount)}',
                        style: const TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          )
        : const SizedBox.shrink();

    return Column(
      children: [
        round1Card,
        const SizedBox(height: 12),
        round2Card,
        if (round2Paid) ...[
          const SizedBox(height: 12),
          totalCard,
        ],
      ],
    );
  }


  Widget _buildPayRow(String label, String value, {
    IconData? icon,
    Color? valueColor,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: const Color(0xFF6C757D)),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
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
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double value) {
    final formatted = value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$formatted VNĐ';
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    int maxLines = 2,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF228B22)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  color: valueColor ?? const Color(0xFF333333),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMissionSpeciesChip(MissionDetailItem md) {
    final speciesDetail = _speciesDetailsMap[md.snakeSpeciesId];
    final isLoading = _loadingSpeciesIds.contains(md.snakeSpeciesId);
    return InkWell(
      onTap: speciesDetail != null ? () => _showSpeciesDetailModal(speciesDetail, md.quantity) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (speciesDetail?.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  speciesDetail!.imageUrl!,
                  width: 80, height: 80, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                  loadingBuilder: (_, child, progress) =>
                      progress == null ? child : _buildImagePlaceholder(),
                ),
              )
            else if (isLoading)
              _buildImagePlaceholder()
            else
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.pest_control, color: Color(0xFFFF9800), size: 40),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          md.snakeSpeciesName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (speciesDetail?.isVenomous == true) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('ĐỘC',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (speciesDetail?.scientificName.isNotEmpty == true)
                    Text(
                      speciesDetail!.scientificName,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (speciesDetail != null) ...[
                        _buildRiskLevelBadge(speciesDetail.riskLevel),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF228B22).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'SL: ${md.quantity}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF228B22)),
                        ),
                      ),
                    ],
                  ),
                  if (speciesDetail != null) ...[
                    const SizedBox(height: 8),
                    Text('Nhấn để xem chi tiết',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500], fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeciesChip(SnakeSpeciesDetail detail, {int? quantityOverride}) {
    final speciesDetail = _speciesDetailsMap[detail.snakeSpeciesId];
    final isLoading = _loadingSpeciesIds.contains(detail.snakeSpeciesId);
    final int displayQty = quantityOverride ?? detail.quantity;

    return InkWell(
      onTap: speciesDetail != null ? () => _showSpeciesDetailModal(speciesDetail, displayQty) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Species Image
            if (speciesDetail?.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  speciesDetail!.imageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildImagePlaceholder();
                  },
                ),
              )
            else if (isLoading)
              _buildImagePlaceholder()
            else
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFFF9800),
                  size: 40,
                ),
              ),
            const SizedBox(width: 12),
            // Species Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Badges
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          detail.snakeSpeciesName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (speciesDetail?.isVenomous == true) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ĐỘC',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Scientific Name
                  Text(
                    detail.snakeSpeciesScientificName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Risk Level and Quantity
                  Row(
                    children: [
                      if (speciesDetail != null) ...[
                        _buildRiskLevelBadge(speciesDetail.riskLevel),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF228B22).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'SL: $displayQty',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF228B22),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (speciesDetail != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Nhấn để xem chi tiết',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF228B22)),
        ),
      ),
    );
  }

  Widget _buildRiskLevelBadge(double riskLevel) {
    Color badgeColor;
    String riskText;
    
    if (riskLevel >= 8.0) {
      badgeColor = Colors.red;
      riskText = 'CỰC KỲ NGUY HIỂM';
    } else if (riskLevel >= 6.0) {
      badgeColor = Colors.orange;
      riskText = 'NGUY HIỂM';
    } else if (riskLevel >= 4.0) {
      badgeColor = Colors.amber;
      riskText = 'TRUNG BÌNH';
    } else {
      badgeColor = Colors.green;
      riskText = 'ÍT NGUY HIỂM';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, color: badgeColor, size: 12),
          const SizedBox(width: 4),
          Text(
            riskLevel.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showSpeciesDetailModal(SnakeSpecies species, int quantity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Species Image
                      if (species.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            species.imageUrl!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      // Species Name
                      Text(
                        species.commonName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        species.scientificName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Badges Row
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildRiskLevelBadge(species.riskLevel),
                          if (species.isVenomous)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.dangerous, color: Colors.red, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'RẮN ĐỘC',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF228B22).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Số lượng: $quantity',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF228B22),
                              ),
                            ),
                          ),
                          if (species.primaryVenomType != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                species.primaryVenomType!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Description
                      if (species.description != null) ...[
                        _buildSection(
                          icon: Icons.description,
                          title: 'Mô Tả',
                          content: species.description!,
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Identification Summary
                      if (species.identificationSummary != null) ...[
                        _buildSection(
                          icon: Icons.search,
                          title: 'Nhận Diện',
                          content: species.identificationSummary!,
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Physical Traits
                      if (species.identification?.physicalTraits.isNotEmpty == true) ...[
                        _buildListSection(
                          icon: Icons.straighten,
                          title: 'Đặc Điểm Vật Lý',
                          items: species.identification!.physicalTraits,
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Behaviors
                      if (species.identification?.behaviors.isNotEmpty == true) ...[
                        _buildListSection(
                          icon: Icons.pets,
                          title: 'Hành Vi',
                          items: species.identification!.behaviors,
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Habitat
                      if (species.identification?.habitat.isNotEmpty == true) ...[
                        _buildSection(
                          icon: Icons.terrain,
                          title: 'Môi Trường Sống',
                          content: species.identification!.habitat,
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Symptoms By Time
                      if (species.symptomsByTime?.isNotEmpty == true) ...[
                        _buildSymptomsSection(species.symptomsByTime!),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF228B22)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF555555),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListSection({
    required IconData icon,
    required String title,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF228B22)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 14, color: Color(0xFF228B22))),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF555555),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomsSection(List<SymptomByTime> symptoms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.medical_services, size: 20, color: Color(0xFF228B22)),
            SizedBox(width: 8),
            Text(
              'Triệu Chứng Theo Thời Gian',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...symptoms.map((symptom) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: symptom.isCritical 
                    ? Colors.red.withOpacity(0.05)
                    : const Color(0xFFF6F8F6),
                borderRadius: BorderRadius.circular(8),
                border: symptom.isCritical
                    ? Border.all(color: Colors.red.withOpacity(0.3))
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (symptom.isCritical)
                        const Icon(Icons.error, color: Colors.red, size: 16),
                      if (symptom.isCritical) const SizedBox(width: 4),
                      Text(
                        symptom.timeRange,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: symptom.isCritical ? Colors.red : const Color(0xFF228B22),
                        ),
                      ),
                      if (symptom.isCritical) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'NGUY CẤP',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...symptom.signs.map((sign) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: TextStyle(
                                fontSize: 14,
                                color: symptom.isCritical ? Colors.red : const Color(0xFF228B22),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                sign,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF555555),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            )),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // Status Progress Stepper
  // ──────────────────────────────────────────────────────────────────
  Widget _buildStatusStepper(String effectiveStatus, String requestStatus) {
    // Steps in order (using effective status keys)
    const steps = [
      ('pending',   Icons.schedule,          'Chờ\nduyệt'),
      ('confirmed', Icons.check_circle_outline, 'Đã\nduyệt'),
      ('assigned',  Icons.assignment_ind,    'Phân\ncông'),
      ('deposited', Icons.payments_rounded,  'Đặt\ncọc'),
      ('en_route',  Icons.directions_car,    'Đang\nđến'),
      ('arrived',   Icons.location_on,       'Đến\nnơi'),
      ('finished',  Icons.payments_outlined, 'Thanh\ntoán'),
      ('completed', Icons.check_circle,      'Hoàn\nthành'),
    ];

    // Determine effective index
    final activeKey = effectiveStatus.toLowerCase();
    // Map cancelled/expired/paid/dispute to nearest visible step
    final displayKey = {
      'paid': 'completed',
      'dispute': 'finished',
    }[activeKey] ?? activeKey;

    final activeIndex = steps.indexWhere((s) => s.$1 == displayKey);
    // If not found (e.g. cancelled/expired), skip drawing stepper
    if (activeIndex < 0 && requestStatus.toLowerCase() != 'cancelled' && requestStatus.toLowerCase() != 'expired') {
      return const SizedBox.shrink();
    }
    if (requestStatus.toLowerCase() == 'cancelled' || requestStatus.toLowerCase() == 'expired') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cancel, color: Colors.grey[500], size: 18),
              const SizedBox(width: 8),
              Text(
                requestStatus.toLowerCase() == 'cancelled' ? 'Yêu cầu đã bị hủy' : 'Yêu cầu đã hết hạn',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final activeColor = _getStatusColor(steps[activeIndex].$1);
    final activeLabel = steps[activeIndex].$3.replaceAll('\n', ' ');
    final activeIcon  = steps[activeIndex].$2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Active step badge ─────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: activeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Bước ${activeIndex + 1}/${steps.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: activeColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(activeIcon, size: 14, color: activeColor),
                const SizedBox(width: 4),
                Text(
                  activeLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: activeColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Stepper: each step is Expanded so layout is uniform ─
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(steps.length, (idx) {
                final step     = steps[idx];
                final isDone   = idx < activeIndex;
                final isActive = idx == activeIndex;
                final isFirst  = idx == 0;
                final isLast   = idx == steps.length - 1;
                final color    = _getStatusColor(step.$1);

                // Left connector color: based on whether THIS step is done/active
                final leftLineDone  = isDone || isActive;
                // Right connector color: based on whether NEXT step is reached
                final rightLineDone = idx < activeIndex;

                return Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Circle row with connectors on each side
                      Row(
                        children: [
                          // Left connector (invisible for first step)
                          Expanded(
                            child: Container(
                              height: 2.5,
                              color: isFirst
                                  ? Colors.transparent
                                  : (leftLineDone
                                      ? _getStatusColor(steps[idx - 1].$1)
                                      : Colors.grey[200]),
                            ),
                          ),
                          // Circle
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive
                                  ? color
                                  : isDone
                                      ? color
                                      : Colors.grey[100],
                              border: Border.all(
                                color: isActive || isDone ? color : Colors.grey[300]!,
                                width: 1.5,
                              ),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.4),
                                        blurRadius: 7,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: isDone
                                  ? const Icon(Icons.check_rounded,
                                      size: 13, color: Colors.white)
                                  : isActive
                                      ? Icon(step.$2,
                                          size: 13, color: Colors.white)
                                      : Icon(step.$2,
                                          size: 12, color: Colors.grey[400]),
                            ),
                          ),
                          // Right connector (invisible for last step)
                          Expanded(
                            child: Container(
                              height: 2.5,
                              color: isLast
                                  ? Colors.transparent
                                  : (rightLineDone
                                      ? color
                                      : Colors.grey[200]),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Label — explicit newlines keep each word on its own line
                      SizedBox(
                        height: 30,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              step.$3,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontSize: 8.5,
                                height: 1.35,
                                fontWeight:
                                    isActive ? FontWeight.bold : FontWeight.normal,
                                color: isActive
                                    ? color
                                    : isDone
                                        ? Colors.grey[600]
                                        : Colors.grey[400],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _getPriorityText(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'Cao';
      case 'medium':
        return 'Trung bình';
      default:
        return 'Bình thường';
    }
  }

  /// Returns a display-level status key that reflects mission sub-statuses
  /// (En_Route / Arrived) when the request is still in 'Assigned' state.
  String _getEffectiveStatus(SnakeCatchingRequestData request) {
    if (request.status == 'Assigned') {
      // Mission sub-statuses take priority (En_Route / Arrived)
      if (request.mission != null) {
        final ms = request.mission!.status.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
        if (ms == 'en_route' || ms == 'enroute') return 'en_route';
        if (ms == 'arrived') return 'arrived';
      }
      // Deposit paid (regardless of whether mission object is present yet)
      if (_depositPaid) return 'deposited';
    }
    return request.status;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFD4A017); // golden amber
      case 'assigned':
        return const Color(0xFF2196F3);
      case 'confirmed':
        return const Color(0xFF28A745);
      case 'deposited':
        return const Color(0xFF28A745);
      case 'en_route':
        return const Color(0xFF1565C0); // deep blue
      case 'arrived':
        return const Color(0xFF00BCD4);
      case 'finished':
        return const Color(0xFFD81B60); // deep pink
      case 'paid':
        return const Color(0xFF17A2B8);
      case 'completed':
        return const Color(0xFF228B22);
      case 'dispute':
        return const Color(0xFFDC3545);
      case 'cancelled':
      case 'expired':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'assigned':
        return Icons.assignment_ind;
      case 'deposited':
        return Icons.payments_rounded;
      case 'en_route':
        return Icons.directions_car;
      case 'arrived':
        return Icons.location_on;
      case 'finished':
        return Icons.payments_outlined;
      case 'paid':
        return Icons.payments;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'completed':
        return Icons.check_circle;
      case 'dispute':
        return Icons.gavel;
      case 'cancelled':
        return Icons.cancel;
      case 'expired':
        return Icons.timer_off;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ Xử Lý';
      case 'assigned':
        return 'Đã Phân Công';
      case 'deposited':
        return 'Đã Đặt Cọc';
      case 'en_route':
        return 'Đang Trên Đường';
      case 'arrived':
        return 'Đã Đến Nơi';
      case 'finished':
        return 'Cần Thanh Toán';
      case 'paid':
        return 'Đã Thanh Toán';
      case 'completed':
        return 'Hoàn Thành';
      case 'dispute':
        return 'Đang Tranh Chấp';
      case 'cancelled':
        return 'Đã Hủy';
      case 'expired':
        return 'Hết Hạn';
      default:
        return status;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFDC3545);
      case 'medium':
        return const Color(0xFFFFA500);
      default:
        return const Color(0xFF228B22);
    }
  }
}
// ──────────────────────────────────────────────────────────────────────────────
// Payment Method Bottom Sheet
// ──────────────────────────────────────────────────────────────────────────────
class _PaymentMethodSheet extends StatelessWidget {
  final bool isFinalPayment;
  final WalletInfo? walletInfo;
  final double amount;
  final VoidCallback onPayOS;
  final VoidCallback onWallet;

  const _PaymentMethodSheet({
    required this.isFinalPayment,
    required this.walletInfo,
    required this.amount,
    required this.onPayOS,
    required this.onWallet,
  });

  String _fmt(double v) {
    final s = v.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$s đ';
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSufficientBalance =
        walletInfo != null && walletInfo!.balance >= amount;
    final double balance = walletInfo?.balance ?? 0;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF6F8F6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 24),
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
                child: const Icon(Icons.payment_rounded,
                    color: Color(0xFF228B22), size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFinalPayment
                        ? 'Thanh toán dịch vụ'
                        : 'Thanh toán đặt cọc',
                    style: const TextStyle(
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF228B22).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isFinalPayment ? 'Đợt 2 — Dịch vụ' : 'Đợt 1 — Đặt cọc',
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF555555)),
                ),
                Text(
                  _fmt(amount),
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
                      horizontal: 16, vertical: 14),
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
                            size: 20),
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
                                  fontSize: 11, color: Colors.white70),
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
                          Text('Số dư hiện tại',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[600])),
                          walletInfo == null
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF228B22)),
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
                      if (!hasSufficientBalance && walletInfo != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC3545).withOpacity(0.06),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  size: 14, color: Color(0xFFDC3545)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Số dư không đủ. Cần nạp thêm ${_fmt(amount - balance)}.',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFDC3545)),
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
                          onPressed: hasSufficientBalance ? onWallet : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF228B22),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[200],
                            disabledForegroundColor: Colors.grey[400],
                            padding:
                                const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: Text(
                            hasSufficientBalance
                                ? 'Thanh toán bằng ví'
                                : 'Số dư không đủ',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
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
                      horizontal: 16, vertical: 14),
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
                        child: const Icon(Icons.credit_card_rounded,
                            color: Colors.white, size: 20),
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
                                  fontSize: 11, color: Colors.white70),
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
                          _featureChip(Icons.account_balance,
                              'Internet Banking'),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onPayOS,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Thanh toán qua PayOS',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
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
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF1565C0)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF1565C0),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
