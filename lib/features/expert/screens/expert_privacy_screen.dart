import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Expert Privacy Screen - Privacy policy for experts
class ExpertPrivacyScreen extends ConsumerWidget {
  const ExpertPrivacyScreen({super.key});

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
          'Chính Sách Bảo Mật',
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
                    'Chính Sách Bảo Mật',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cách chúng tôi thu thập và bảo vệ dữ liệu chuyên gia.',
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
              title: '1. Giới Thiệu',
              content:
                  'SnakeAid (\"Công ty\") cam kết bảo vệ quyền riêng tư của bạn. Chính sách bảo mật này giải thích cách chúng tôi thu thập, sử dụng, công khai, và bảo vệ thông tin của bạn khi sử dụng nền tảng SnakeAid (\"Dịch vụ\").',
            ),
            _buildSectionCard(
              title: '2. Thông Tin Chúng Tôi Thu Thập',
              content:
                  'Chúng tôi thu thập: (a) Thông tin cá nhân: Tên, email, số điện thoại, địa chỉ; (b) Thông tin chuyên nghiệp: Bằng cấp, chứng chỉ, kinh nghiệm; (c) Thông tin thanh toán: Tài khoản ngân hàng, lịch sử giao dịch; (d) Dữ liệu hoạt động: Phiên tư vấn, thời gian sử dụng, tương tác với khách hàng; (e) Dữ liệu kỹ thuật: Địa chỉ IP, loại thiết bị, trình duyệt, thông tin cookie.',
            ),
            _buildSectionCard(
              title: '3. Cách Chúng Tôi Sử Dụng Thông Tin',
              content:
                  'Chúng tôi sử dụng thông tin của bạn để: (a) Cung cấp, duy trì và cải thiện Dịch vụ; (b) Xử lý thanh toán và quản lý tài khoản; (c) Liên lạc với bạn về các bản cập nhật hoặc vấn đề; (d) Tuân thủ các yêu cầu pháp lý; (e) Ngăn chặn gian lận và lạm dụng; (f) Phân tích và cải thiện hiệu suất Dịch vụ.',
            ),
            _buildSection(
              title: '4. Chia Sẻ Thông Tin',
              content:
                  'Chúng tôi không bán hoặc chia sẻ thông tin cá nhân của bạn với bên thứ ba, ngoại trừ: (a) Với các nhà cung cấp dịch vụ đáng tin cậy giúp chúng tôi vận hành Dịch vụ (xử lý thanh toán, lưu trữ dữ liệu); (b) Khi được pháp luật yêu cầu hoặc để bảo vệ quyền pháp lý của chúng tôi; (c) Với sự đồng ý rõ ràng của bạn.',
            ),
            _buildSection(
              title: '5. Bảo Vệ Dữ Liệu',
              content:
                  'Chúng tôi sử dụng mã hóa SSL/TLS để bảo vệ dữ liệu của bạn trong quá trình truyền. Mật khẩu của bạn được mã hóa một chiều. Chúng tôi giới hạn quyền truy cập vào thông tin cá nhân chỉ cho những nhân viên cần thiết. Tuy nhiên, không có hệ thống an ninh nào hoàn toàn an toàn 100%.',
            ),
            _buildSection(
              title: '6. Quyền Của Bạn',
              content:
                  'Bạn có quyền: (a) Truy cập: Yêu cầu xem thông tin cá nhân mà chúng tôi lưu trữ; (b) Sửa đổi: Yêu cầu sửa chữa thông tin không chính xác; (c) Xóa: Yêu cầu xóa thông tin cá nhân (với một số trường hợp ngoại lệ); (d) Phản đối: Phản đối cách chúng tôi xử lý dữ liệu của bạn; (e) Rút lại: Rút lại sự đồng ý đối với một số loại xử lý.',
            ),
            _buildSection(
              title: '7. Thời Gian Lưu Trữ Dữ Liệu',
              content:
                  'Chúng tôi lưu trữ dữ liệu cá nhân của bạn chỉ trong khoảng thời gian cần thiết để cung cấp Dịch vụ. Thông tin thanh toán được giữ lại cho 7 năm để tuân thủ quy định thuế. Bạn có thể yêu cầu xóa tài khoản của mình bất cứ lúc nào, nhưng một số dữ liệu có thể được giữ lại cho các mục đích pháp lý.',
            ),
            _buildSection(
              title: '8. Cookies Và Công Nghệ Theo Dõi',
              content:
                  'Chúng tôi sử dụng cookies để: (a) Nhớ sở thích của bạn; (b) Theo dõi hoạt động của bạn để cải thiện Dịch vụ; (c) Cung cấp quảng cáo được cá nhân hóa. Bạn có thể vô hiệu hóa cookies trong cài đặt trình duyệt, nhưng điều này có thể ảnh hưởng đến chức năng của Dịch vụ.',
            ),
            _buildSection(
              title: '9. Liên Lạc Tiếp Thị',
              content:
                  'Chúng tôi có thể gửi cho bạn email về các tính năng mới, cập nhật Dịch vụ, hoặc các lời mời khác. Bạn có thể hủy đăng ký bất cứ lúc nào bằng cách nhấp \"Hủy đăng ký\" trong email hoặc điều chỉnh cài đặt thông báo của bạn.',
            ),
            _buildSection(
              title: '10. Khiếu Nại Và Liên Hệ',
              content:
                  'Nếu bạn có bất kỳ lo ngại nào về cách chúng tôi xử lý thông tin cá nhân của bạn, vui lòng liên hệ: Email: privacy@snakeaid.com | Địa chỉ: [Địa chỉ Công ty]. Bạn cũng có quyền nộp đơn khiếu nại với cơ quan bảo vệ dữ liệu địa phương.',
            ),
            _buildSectionCard(
              title: '11. Thay Đổi Chính Sách',
              content:
                  'Chúng tôi có thể cập nhật chính sách này từ thời gian này sang thời gian khác. Chúng tôi sẽ thông báo cho bạn về những thay đổi đáng kể qua email hoặc trong ứng dụng. Việc tiếp tục sử dụng Dịch vụ sau khi các thay đổi có nghĩa là bạn chấp nhận chính sách mới.',
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                margin: const EdgeInsets.only(top: 8),
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
            const SizedBox(height: 20),
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

  Widget _buildSection({required String title, required String content}) {
    return _buildSectionCard(title: title, content: content);
  }
}
