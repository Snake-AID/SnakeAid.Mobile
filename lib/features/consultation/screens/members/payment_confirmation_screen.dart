import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  PaymentMethod _selectedPaymentMethod = PaymentMethod.payos;
  bool _agreedToTerms = false;
  bool _isPaymentLoading = false;

  Future<void> _handlePayment() async {
    if (widget.bookingId == null || widget.bookingId!.isEmpty) {
      context.go('/consultation-home');
      return;
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
