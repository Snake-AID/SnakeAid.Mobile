import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Expert Payment Screen - Payment and withdrawal policies for experts
class ExpertPaymentScreen extends ConsumerWidget {
  const ExpertPaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Chính Sách Thanh Toán',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C47C2), Color(0xFF4E2FA3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Quản Lý Thu Nhập',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Quy định về chi trả và rút tiền cho chuyên gia.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: '1. Ghi Nhận Thu Nhập',
              content:
                  'Thu nhập từ các phiên tư vấn sẽ được cộng vào ví SnakeAidPay của bạn ngay sau khi phiên tư vấn kết thúc và khách hàng xác nhận hoàn thành. Hệ thống sẽ tự động trừ phí hoa hồng 10% theo quy định.',
            ),
            _buildSectionCard(
              title: '2. Quy Trình Rút Tiền',
              content:
                  'Chuyên gia có thể thực hiện lệnh rút tiền về tài khoản ngân hàng bất kỳ lúc nào. Bạn cần đảm bảo thông tin tài khoản ngân hàng (Tên chủ thẻ, Số tài khoản, Ngân hàng) là chính xác và trùng khớp với thông tin định danh.',
            ),
            _buildSectionCard(
              title: '3. Thời Gian Xử Lý',
              content:
                  'Các yêu cầu rút tiền sẽ được bộ phận kế toán kiểm tra và xử lý trong vòng 1 đến 3 ngày làm việc (không tính Thứ 7, Chủ nhật và ngày lễ). Bạn sẽ nhận được thông báo sau khi lệnh chuyển tiền thành công.',
            ),
            _buildSectionCard(
              title: '4. Phí Rút Tiền',
              content:
                  'SnakeAid hỗ trợ miễn phí hoàn toàn các giao dịch rút tiền cho chuyên gia. Tuy nhiên, một số ngân hàng có thể thu phí chuyển khoản liên ngân hàng tùy theo chính sách của ngân hàng đó.',
            ),
            _buildSectionCard(
              title: '5. Bảo Mật Giao Dịch',
              content:
                  'Mọi giao dịch rút tiền đều yêu cầu xác thực OTP hoặc mã PIN để đảm bảo an toàn tối đa cho tài khoản của chuyên gia.',
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C47C2).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Phiên bản 1.0.0 • SnakeAid Expert',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4E2FA3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required String content}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              height: 1.7,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
