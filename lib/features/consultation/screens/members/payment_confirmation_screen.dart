import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/expert_detail_provider.dart';
import '../../providers/consultation_bookings_provider.dart';
import '../../repository/consultation_repository.dart';

// Primary color constant
const Color _primaryColor = Color(0xFF228B22);
const Color _backgroundColor = Color(0xFFF6F8F6);

/// Payment method enum
enum PaymentMethod {
  payos,
  snakeaidPay,
}

/// Payment Confirmation Screen
/// Allows users to review consultation details and complete payment
class PaymentConfirmationScreen extends ConsumerStatefulWidget {
  final String expertId;
  final String? consultationType;
  final String? selectedDate;
  final String? selectedTime;
  final String? duration;
  final String? price;
  final bool hasDocuments;
  final int uploadedImagesCount;
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
    this.hasDocuments = false,
    this.uploadedImagesCount = 0,
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
    extends ConsumerState<PaymentConfirmationScreen> {
  static const String _instantRequestCachePrefix =
      'last_emergency_request_for_expert_';

  PaymentMethod _selectedPaymentMethod = PaymentMethod.payos;
  bool _agreedToTerms = false;
  bool _isPaymentLoading = false;
  double? _walletBalance;
  bool _isLoadingWallet = true;

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
    _fetchWallet();
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

  Future<void> _handlePayment() async {
    if (widget.consultationType == 'instant') {
      if (_selectedPaymentMethod == PaymentMethod.snakeaidPay) {
        final confirmed = await _showWalletPaymentDialog();
        if (confirmed != true) return;
      }

      setState(() => _isPaymentLoading = true);
      String? requestId;

      try {
        final repo = ref.read(consultationRepositoryProvider);
        final req = await repo.createEmergencyRequest(expertId: widget.expertId);
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
          : 'PayOS';
      final resolvedRequestId = requestId;
      if (resolvedRequestId.isEmpty) {
        if (mounted) {
          setState(() => _isPaymentLoading = false);
        }
        return;
      }

      try {
        final repo = ref.read(consultationRepositoryProvider);
        await repo.payEmergencyRequest(
          resolvedRequestId,
          paymentMethod: paymentMethod,
        );

        if (!mounted) return;
        setState(() => _isPaymentLoading = false);
        context.go(
          '/emergency-request-waiting/$resolvedRequestId',
          extra: {
            'expertId': widget.expertId,
            'expertName': widget.expertName ?? 'Chuyên gia',
          },
        );
      } catch (e) {
        if (!mounted) return;
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

    if (widget.bookingId == null || widget.bookingId!.isEmpty) {
      context.go('/consultation-home');
      return;
    }

    // If SnakeAid Pay is selected, show confirmation dialog first
    if (_selectedPaymentMethod == PaymentMethod.snakeaidPay) {
      final confirmed = await _showWalletPaymentDialog();
      if (confirmed != true) return;
    }

    setState(() => _isPaymentLoading = true);
    try {
      final repo = ref.read(consultationRepositoryProvider);
      await repo.payBooking(widget.bookingId!);
      ref.invalidate(consultationBookingsProvider);
      if (!mounted) return;
      context.go(
        '/consultation-home',
        extra: {'newConsultationId': widget.bookingId},
      );
    } catch (e) {
      if (!mounted) return;
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

  /// Show wallet payment confirmation dialog
  Future<bool?> _showWalletPaymentDialog() async {
    final priceAmount = _getPriceAmount();
    final price = int.tryParse(priceAmount) ?? 0;
    final theme = Theme.of(context);
    
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Xác nhận thanh toán',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
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
                                    ? _formatPrice(_walletBalance!.toInt().toString())
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
                                    ? _formatPrice(((_walletBalance! - price).toInt()).toString())
                                    : 'Không có dữ liệu',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _walletBalance != null && _walletBalance! >= price
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
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Hủy',
              style: TextStyle(color: Colors.grey),
            ),
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
    return '${number.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )} VNĐ';
  }

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
                                context, state.expert!, theme),
                            const SizedBox(height: 16),

                            // Payment Details Section
                            _buildPaymentDetails(theme),
                            const SizedBox(height: 16),

                            // Payment Method Section
                            _buildPaymentMethods(theme),
                            const SizedBox(height: 16),

                            // Security Info Box
                            _buildSecurityInfo(theme),
                            const SizedBox(height: 24),
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

  /// Build consultation summary card
  Widget _buildConsultationSummary(
      BuildContext context, expert, ThemeData theme) {
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
          // Expert info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with verified badge
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
                                  expert.avatarUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: expert.avatarUrl == null
                          ? Colors.grey[300]
                          : null,
                    ),
                    child: expert.avatarUrl == null
                        ? Icon(Icons.person,
                            size: 32, color: Colors.grey[600])
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
                          color: Color(0xFF8A2BE2), // Purple verified badge
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

              // Expert details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expert.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Consultation type badge
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

                    // Date & Time (for scheduled)
                    if (widget.selectedDate != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.selectedDate!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],

                    // Duration
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.duration ?? '30 phút',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Documents info (if uploaded)
          if (widget.hasDocuments) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.image,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Tài liệu đã tải lên (${widget.uploadedImagesCount} ảnh)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Show document details
                  },
                  child: const Text(
                    'Xem chi tiết',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ],
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Phí nền tảng (đã bao gồm)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '0 VNĐ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

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
              
              // Wallet balance
              const SizedBox(height: 16),
              Divider(color: Colors.grey.shade200),
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Số dư ví hiện tại',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
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
                              ? _formatPrice(_walletBalance!.toInt().toString())
                              : 'Không có dữ liệu',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _walletBalance != null &&
                                    _walletBalance! >= int.parse(priceAmount)
                                ? _primaryColor
                                : Colors.red,
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

  /// Build payment methods section
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
        const SizedBox(height: 8),

        // PayOS
        _buildPaymentMethodOption(
          PaymentMethod.payos,
          'PayOS',
          'assets/images/logo/payosicon.png',
          theme,
          subtitle: 'Thanh toán qua QR / Internet Banking',
        ),
        const SizedBox(height: 12),

        // SnakeAid Pay
        _buildPaymentMethodOption(
          PaymentMethod.snakeaidPay,
          'SnakeAid Pay',
          null,
          theme,
          subtitle: 'Thanh toán từ ví SnakeAid của bạn',
        ),
      ],
    );
  }

  /// Build fallback icon for payment method
  Widget _buildFallbackIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.payos:
        return Container(
          width: 72,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF0C6EF2),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: const Text(
            'PayOS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        );
      case PaymentMethod.snakeaidPay:
        return Container(
          width: 72,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF228B22),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: const Text(
            'S·Pay',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        );
    }
  }

  /// Build payment method option
  Widget _buildPaymentMethodOption(
    PaymentMethod method,
    String label,
    String? logoUrl,
    ThemeData theme, {
    String? subtitle,
  }) {
    final isSelected = _selectedPaymentMethod == method;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _primaryColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _primaryColor : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Logo or icon (fixed width container for alignment)
            SizedBox(
              width: 72,
              height: 36,
              child: logoUrl != null
                  ? (logoUrl.startsWith('assets/')
                      ? Image.asset(
                          logoUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildFallbackIcon(method);
                          },
                        )
                      : CachedNetworkImage(
                          imageUrl: logoUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            return _buildFallbackIcon(method);
                          },
                        ))
                  : _buildFallbackIcon(method),
            ),
            const SizedBox(width: 16),

            // Label + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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

  /// Build security info box
  Widget _buildSecurityInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: Colors.amber.shade400,
            width: 4,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.security,
            color: Colors.amber.shade600,
            size: 20,
          ),
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

  /// Build terms checkbox
  Widget _buildTermsCheckbox(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreedToTerms,
          onChanged: (value) {
            setState(() {
              _agreedToTerms = value ?? false;
            });
          },
          activeColor: _primaryColor,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                children: [
                  const TextSpan(text: 'Tôi đồng ý với '),
                  TextSpan(
                    text: 'Điều khoản dịch vụ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' và '),
                  TextSpan(
                    text: 'Chính sách hoàn tiền',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build bottom actions
  Widget _buildBottomActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor.withOpacity(0.8),
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
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
                onPressed: _isPaymentLoading ? null : _handlePayment,
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryColor,
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
}
