import 'package:flutter/material.dart';

/// Màn hình hiển thị trạng thái nhiệm vụ đã hoàn thành và đang chờ khách hàng thanh toán
class RescuerMissionSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> requestData;
  final int photoCount;
  
  const RescuerMissionSuccessScreen({
    super.key,
    required this.requestData,
    this.photoCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8F6).withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF343A40)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chờ Thanh Toán',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF343A40),
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Mission Completion Card
                  _buildMissionCompletionCard(),
                  
                  const SizedBox(height: 24),
                  
                  // Payment Status Card
                  _buildPaymentStatusCard(),
                  
                  const SizedBox(height: 24),
                  
                  // Expected Payment Card
                  _buildExpectedPaymentCard(),
                  
                  const SizedBox(height: 24),
                  
                  // Mission Summary Card
                  _buildMissionSummaryCard(),
                  
                  const SizedBox(height: 24),
                  
                  // Info Card
                  _buildInfoCard(),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  _buildQuickActions(context),
                ],
              ),
            ),
          ),
          
          // Bottom Action Button
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildMissionCompletionCard() {
    return Column(
      children: [
        const Icon(
          Icons.check_circle,
          color: Color(0xFF28A745),
          size: 60,
        ),
        const SizedBox(height: 8),
        const Text(
          'Nhiệm vụ hoàn thành',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF28A745),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.send, size: 16, color: Color(0xFF6C757D)),
            SizedBox(width: 6),
            Text(
              'Đã gửi thông tin đến Nguyễn Văn A',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6C757D),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentStatusCard() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFD7E14).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.schedule, size: 16, color: Color(0xFFFD7E14)),
              SizedBox(width: 6),
              Text(
                'Đang chờ khách hàng thanh toán',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFD7E14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.timer, size: 16, color: Color(0xFF6C757D)),
            SizedBox(width: 6),
            Text(
              'Chờ từ: 2 phút trước',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6C757D),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpectedPaymentCard() {
    final price = requestData['price'] ?? '200,000';
    final priceInt = int.parse(price.replaceAll(',', '').replaceAll('.', ''));
    final rescuerCut = (priceInt * 0.85).toInt();
    final platformFee = (priceInt * 0.10).toInt();
    final insuranceFund = (priceInt * 0.05).toInt();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  'Bạn sẽ nhận:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6C757D),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_formatCurrency(rescuerCut)} VNĐ',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF28A745),
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildFeeRow('Phí cứu hộ:', '${_formatCurrency(priceInt)} VNĐ'),
                const SizedBox(height: 8),
                _buildFeeRow('Phí nền tảng:', '-${_formatCurrency(platformFee)} VNĐ'),
                const SizedBox(height: 8),
                _buildFeeRow('Quỹ bảo hiểm:', '-${_formatCurrency(insuranceFund)} VNĐ'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6C757D),
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6C757D),
          ),
        ),
      ],
    );
  }

  Widget _buildMissionSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow(Icons.pest_control, '${requestData['title'] ?? 'Rắn Hổ Mang'} - Có độc'),
          const SizedBox(height: 16),
          _buildSummaryRow(Icons.hourglass_top, 'Thời gian: 15 phút'),
          const SizedBox(height: 16),
          _buildSummaryRow(Icons.location_on, requestData['address'] ?? '123 Nguyễn Văn Linh'),
          const SizedBox(height: 16),
          _buildSummaryRow(Icons.photo_camera, '$photoCount ảnh đã ghi nhận'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF6C757D), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF343A40),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D6EFD).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info, color: Color(0xFF0D6EFD), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Chúng tôi đã gửi yêu cầu thanh toán đến khách hàng. Bạn sẽ nhận thông báo khi thanh toán thành công.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6C757D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            // TODO: View mission details
          },
          child: const Text(
            'Xem chi tiết nhiệm vụ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D6EFD),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            // TODO: Message customer
          },
          child: const Text(
            'Nhắn tin với khách hàng',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D6EFD),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFFD7E14),
            side: const BorderSide(color: Color(0xFFFD7E14), width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Về Trang Chủ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
