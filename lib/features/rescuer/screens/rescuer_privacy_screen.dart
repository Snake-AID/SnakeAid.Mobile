import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rescuer Privacy Screen - Privacy policy for rescuers
class RescuerPrivacyScreen extends ConsumerWidget {
  const RescuerPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF231A0F)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Chính Sách Bảo Mật',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF231A0F),
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
                  colors: [Color(0xFFFF8800), Color(0xFFFF6B00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Chính Sách Bảo Mật',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cách chúng tôi thu thập và bảo mật dữ liệu đội cứu hộ.',
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
              title: '1. Thu Thập Vị Trí GPS',
              content:
                  'Để điều phối cứu hộ hiệu quả, chúng tôi thu thập vị trí chính xác của bạn ngay cả khi ứng dụng đang chạy nền (khi bạn đang ở chế độ ONLINE). Điều này giúp hệ thống xác định người cứu hộ gần nhất với sự cố.',
            ),
            _buildSectionCard(
              title: '2. Thông Tin Hoạt Động',
              content:
                  'Chúng tôi lưu lại lịch sử di chuyển trong nhiệm vụ, thời gian phản hồi, và kết quả xử lý sự cố để đảm bảo chất lượng dịch vụ và tính minh bạch trong việc thanh toán thu nhập.',
            ),
            _buildSectionCard(
              title: '3. Chia Sẻ Thông Tin Nhiệm Vụ',
              content:
                  'Khi bạn chấp nhận nhiệm vụ, tên và số điện thoại của bạn sẽ được chia sẻ với khách hàng (Member) và Điều phối viên (Operator) để liên lạc trong quá trình cứu hộ.',
            ),
            _buildSectionCard(
              title: '4. Bảo Mật Dữ Liệu Cá Nhân',
              content:
                  'Thông tin định danh (CCCD/ID) và thông tin thanh toán của bạn được mã hóa và chỉ sử dụng cho mục đích xác thực danh tính và chi trả thu nhập, tuyệt đối không chia sẻ cho bên thứ ba.',
            ),
            _buildSectionCard(
              title: '5. Quyền Hạn Của Bạn',
              content:
                  'Bạn có quyền yêu cầu trích xuất dữ liệu hoạt động cá nhân, yêu cầu chỉnh sửa thông tin hoặc xóa tài khoản (kèm theo yêu cầu xóa dữ liệu) bất cứ lúc nào thông qua đội ngũ hỗ trợ.',
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Phiên bản 1.0.0 • SnakeAid Rescuer',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
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
            blurRadius: 10,
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
              fontWeight: FontWeight.bold,
              color: Color(0xFF231A0F),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
