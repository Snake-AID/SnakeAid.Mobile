import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/consultation_booking_response.dart';
import '../../providers/consultation_bookings_provider.dart';
import '../../providers/expert_detail_provider.dart';
import '../../repository/consultation_repository.dart';

// Primary color constant
const Color _primaryColor = Color(0xFF228B22);
const Color _backgroundColor = Color(0xFFF6F8F6);

/// Consultation Documents Screen
/// Captures consultation details from users, including
/// problem description.
class ConsultationDocumentsScreen extends ConsumerStatefulWidget {
  final String expertId;
  final String? consultationType; // 'instant' or 'scheduled'
  final String? selectedDate; // For scheduled consultations
  final String? selectedTime; // For scheduled consultations
  final String? duration; // For scheduled consultations
  final String? price; // Consultation price
  final String? timeSlotId; // Real slot ID from backend

  const ConsultationDocumentsScreen({
    super.key,
    required this.expertId,
    this.consultationType,
    this.selectedDate,
    this.selectedTime,
    this.duration,
    this.price,
    this.timeSlotId,
  });

  @override
  ConsumerState<ConsultationDocumentsScreen> createState() =>
      _ConsultationDocumentsScreenState();
}

class _ConsultationDocumentsScreenState
    extends ConsumerState<ConsultationDocumentsScreen> {
  final TextEditingController _problemController = TextEditingController();
  final int _maxProblemChars = 500;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    // Validate required fields
    if (_problemController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng mô tả vấn đề của bạn')),
      );
      return;
    }

    // Instant consultation flow: proceed to payment first.
    // Emergency request will be created only after payment confirmation.
    if (widget.consultationType == 'instant') {
      final expertState = ref.read(expertDetailProvider(widget.expertId));
      final expertName = expertState.expert?.displayName ?? 'Chuyên gia';

      context.push(
        '/payment-confirmation/${widget.expertId}',
        extra: {
          'consultationType': 'instant',
          'price': widget.price,
          'problemDescription': _problemController.text.trim(),
          'expertName': expertName,
        },
      );
      return;
    }

    // If we have a real timeSlotId, call the createBooking API
    if (widget.timeSlotId != null && widget.timeSlotId!.isNotEmpty) {
      setState(() => _isSubmitting = true);
      try {
        final repository = ref.read(consultationRepositoryProvider);
        final booking = await repository.createBooking(
          CreateConsultationBookingRequest(
            timeSlotId: widget.timeSlotId!,
            problemDescription: _problemController.text.trim(),
          ),
        );
        // Invalidate bookings list so home screen refreshes later
        ref.invalidate(consultationBookingsProvider);

        if (!mounted) return;
        setState(() => _isSubmitting = false);

        // Format price from booking response
        final priceStr = booking.feeCost > 0
            ? '${booking.feeCost.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} VNĐ'
            : widget.price ?? '150,000 VNĐ';

        // Navigate to payment screen with real bookingId & consultationId
        context.push(
          '/payment-confirmation/${widget.expertId}',
          extra: {
            'bookingId': booking.id,
            'consultationId': booking.consultationId ?? '',
            'expertName': booking.expertName,
            'consultationType': 'scheduled',
            'selectedDate': widget.selectedDate ?? '',
            'selectedTime': widget.selectedTime ?? '',
            'duration': '30 phút',
            'price': priceStr,
            'problemDescription': _problemController.text.trim(),
          },
        );
        return;
      } catch (e) {
        if (!mounted) return;
        final msg = e.toString().contains('409')
            ? 'Khung giờ này vừa được đặt bởi người khác. Vui lòng chọn giờ khác.'
            : 'Không thể tạo lịch tư vấn. Vui lòng thử lại.';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
        setState(() => _isSubmitting = false);
        return;
      }
    }

    // Fallback: no real timeSlotId — navigate to payment screen (placeholder flow)
    context.push(
      '/payment-confirmation/${widget.expertId}',
      extra: {
        'consultationType': widget.consultationType,
        'selectedDate': widget.selectedDate,
        'selectedTime': widget.selectedTime,
        'duration': widget.duration,
        'price': widget.price,
        'problemDescription': _problemController.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expertDetailProvider(widget.expertId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Tài Liệu Tư Vấn',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Bước 2/3',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.expert == null
              ? const Center(child: Text('Không tìm thấy chuyên gia'))
              : Column(
                  children: [
                    // Main scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Consultation Summary Card
                            _buildConsultationSummary(
                                context, state.expert!, theme),
                            const SizedBox(height: 24),

                            // Problem Description Section
                            _buildProblemDescriptionSection(theme),
                            const SizedBox(height: 24),

                            // Info Box
                            _buildInfoBox(theme),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                    // Footer Actions
                    _buildFooter(),
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
        borderRadius: BorderRadius.circular(8),
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
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: expert.avatarUrl != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(expert.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: expert.avatarUrl == null ? Colors.grey[300] : null,
            ),
            child: expert.avatarUrl == null
                ? Icon(Icons.person, size: 24, color: Colors.grey[600])
                : null,
          ),
          const SizedBox(width: 16),

          // Expert info
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
                const SizedBox(height: 8),

                // Date & Time (for scheduled) or Type (for instant)
                if (widget.consultationType == 'scheduled' &&
                    widget.selectedDate != null) ...[
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

                // Time and Price
                Row(
                  children: [
                    if (widget.selectedTime != null) ...[
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.selectedTime!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Icon(
                      Icons.paid,
                      size: 14,
                      color: _primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.price ?? '150,000 VNĐ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _primaryColor,
                      ),
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

  /// Build problem description section
  Widget _buildProblemDescriptionSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            children: const [
              TextSpan(text: 'Mô Tả Vấn Đề '),
              TextSpan(
                text: '*',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _problemController,
          maxLength: _maxProblemChars,
          maxLines: 4,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _primaryColor, width: 1.5),
            ),
            hintText: 'Ví dụ: Con rắn xuất hiện trong vườn nhà tôi, dài khoảng 1m...',
            counterText: '',
            contentPadding: const EdgeInsets.all(14),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${_problemController.text.length}/$_maxProblemChars',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  /// Build info box
  Widget _buildInfoBox(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info,
            color: Colors.blue.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Thông tin càng chi tiết, tư vấn càng hiệu quả',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build footer with action buttons
  Widget _buildFooter() {
    final hasRealSlot = widget.timeSlotId != null && widget.timeSlotId!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Continue button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _isSubmitting ? null : _handleContinue,
              style: FilledButton.styleFrom(
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(
                      hasRealSlot ? 'Xác Nhận Đặt Lịch' : 'Tiếp Tục Thanh Toán',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
