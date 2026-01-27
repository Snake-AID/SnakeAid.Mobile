import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/chat_screen.dart';
import 'payment_success_screen.dart';

/// Emergency Service Completion Screen - Payment & Rating
class EmergencyServiceCompletionScreen extends StatefulWidget {
  const EmergencyServiceCompletionScreen({super.key});

  @override
  State<EmergencyServiceCompletionScreen> createState() =>
      _EmergencyServiceCompletionScreenState();
}

class _EmergencyServiceCompletionScreenState
    extends State<EmergencyServiceCompletionScreen> {
  int _selectedRating = 4;
  String _selectedPaymentMethod = 'applepay';
  final Set<String> _selectedTags = {'Nhanh chóng', 'Nhiệt tình'};
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF191910)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('member_home');
            }
          },
        ),
        title: const Text(
          'Hoàn tất dịch vụ cấp cứu',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191910),
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF228B22).withOpacity(0.1),
                  const Color(0xFF1a6b1a).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Đã xử lý xong',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF228B22),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Success Banner
                _buildSuccessBanner(),
                const SizedBox(height: 20),

                // Rescuer Info Card
                _buildRescuerInfoCard(context),
                const SizedBox(height: 20),

                // Payment Details
                _buildPaymentDetails(),
                const SizedBox(height: 16),

                // Info Box
                _buildInfoBox(),
                const SizedBox(height: 20),

                // Payment Methods
                _buildPaymentMethods(),
                const SizedBox(height: 20),

                // Rating Section
                _buildRatingSection(),
              ],
            ),
          ),

          // Bottom Payment Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomPaymentButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF228B22).withOpacity(0.1),
            const Color(0xFF1a6b1a).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF228B22).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF228B22).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF228B22),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dịch vụ hoàn thành an toàn',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF191910),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Cảm ơn bạn đã tin tưởng SnakeAid.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRescuerInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with Rating Badge
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF228B22),
                      Color(0xFF1a6b1a),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Text(
                    '🚑',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF228B22),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Text(
                    '4.9 ★',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Rescuer Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Người phụ trách',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Nguyễn Văn A',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF191910),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Chuyên gia xử lý rắn',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF228B22),
                  ),
                ),
              ],
            ),
          ),

          // Chat Button
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F6),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.chat_rounded, color: Color(0xFF228B22)),
              onPressed: () {
                // TODO: Add chat route
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat feature coming soon')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Chi tiết thanh toán',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF191910),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Fee Items
              _buildFeeItem('Phí dịch vụ cơ bản', '200,000đ'),
              const SizedBox(height: 12),
              _buildFeeItem('Phụ phí ngoài giờ (Sau 22h)', '50,000đ'),
              const SizedBox(height: 12),
              _buildFeeItem('Di chuyển (15km)', '325,000đ'),
              const SizedBox(height: 16),

              // Divider
              Container(
                height: 1,
                color: const Color(0xFFE5E7EB),
              ),
              const SizedBox(height: 16),

              // Total
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Tổng cộng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF191910),
                    ),
                  ),
                  Text(
                    '575,000đ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF228B22),
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

  Widget _buildFeeItem(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF191910),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F0FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_rounded,
            color: Color(0xFF2563EB),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Phí khẩn cấp SOS được thanh toán SAU để bạn tập trung sơ cứu',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.blue[900],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Phương thức thanh toán',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF191910),
            ),
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildPaymentMethodCard(
                'applepay',
                'Apple Pay',
                'Đang chọn',
                Icons.smartphone_rounded,
                Colors.black,
              ),
              _buildPaymentMethodCard(
                'visa',
                'Visa •••• 4242',
                'Thẻ ghi nợ',
                Icons.credit_card_rounded,
                const Color(0xFF2563EB),
              ),
              _buildPaymentMethodCard(
                'cash',
                'Tiền mặt',
                'Thanh toán sau',
                Icons.payments_rounded,
                const Color(0xFF228B22),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(
    String id,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
  ) {
    final isSelected = _selectedPaymentMethod == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = id;
        });
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF228B22).withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF228B22)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF191910),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF228B22)
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF228B22),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          const Text(
            'Đánh giá đội cứu hộ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF191910),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ý kiến của bạn giúp chúng tôi cải thiện dịch vụ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Star Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _selectedRating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: const Color(0xFFF59E0B),
                  size: 40,
                ),
                onPressed: () {
                  setState(() {
                    _selectedRating = index + 1;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 20),

          // Quick Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildTag('Nhanh chóng'),
              _buildTag('Chuyên nghiệp'),
              _buildTag('Nhiệt tình'),
              _buildTag('An toàn'),
            ],
          ),
          const SizedBox(height: 20),

          // Comment TextArea
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _commentController,
              maxLines: 3,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF191910),
              ),
              decoration: InputDecoration(
                hintText: 'Nhập nhận xét chi tiết (không bắt buộc)...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    final isSelected = _selectedTags.contains(label);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedTags.remove(label);
          } else {
            _selectedTags.add(label);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xFF228B22),
                    Color(0xFF1a6b1a),
                  ],
                )
              : null,
          color: isSelected ? null : const Color(0xFFF8F8F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPaymentButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F6).withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE5E7EB).withOpacity(0.8),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Payment Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF228B22),
                    Color(0xFF1a6b1a),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF228B22).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    _processPayment(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Thanh toán & Gửi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '575,000đ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Report Link
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Báo cáo vấn đề / Khiếu nại'),
                    backgroundColor: Color(0xFF228B22),
                  ),
                );
              },
              child: Text(
                'Báo cáo vấn đề / Khiếu nại',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(seconds: 2),
                  builder: (context, value, child) {
                    return SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 4,
                        backgroundColor: const Color(0xFF228B22).withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF228B22),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Đang xử lý thanh toán...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF191910),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vui lòng đợi trong giây lát',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context).pop();

      // Navigate to success screen
      await Future.delayed(const Duration(milliseconds: 200));
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const PaymentSuccessScreen(),
          ),
        );
      }
    }
  }

  void _showPaymentSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF228B22).withOpacity(0.2),
                    const Color(0xFF1a6b1a).withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF228B22),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Thanh toán thành công!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF191910),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cảm ơn bạn đã đánh giá dịch vụ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF228B22),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Hoàn tất',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
