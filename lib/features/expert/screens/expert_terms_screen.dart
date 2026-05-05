import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Expert Terms Screen - Terms of service for experts
class ExpertTermsScreen extends ConsumerWidget {
  const ExpertTermsScreen({super.key});

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
          'Điều Khoản & Điều Kiện',
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
                    'Điều Khoản & Điều Kiện',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Những nguyên tắc và quyền hạn dành cho chuyên gia trên nền tảng SnakeAid.',
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
                  'Điều khoản này điều chỉnh việc sử dụng nền tảng SnakeAid (\"Nền tảng\") của bạn với tư cách là một chuyên gia ("Chuyên Gia", "Bạn"). Bằng cách đăng ký và sử dụng Nền tảng, bạn đồng ý tuân thủ các điều khoản này.',
            ),
            _buildSectionCard(
              title: '2. Tư Cách Đủ Điều Kiện',
              content:
                  'Để trở thành Chuyên Gia trên Nền tảng, bạn phải: (a) Đủ 18 tuổi trở lên; (b) Có pháp lý hành động đầy đủ; (c) Không bị cấm hoặc hạn chế trong việc cung cấp dịch vụ tư vấn; (d) Cung cấp thông tin xác thực và chính xác; (e) Có chuyên môn và kinh nghiệm thích hợp trong lĩnh vực bạn lựa chọn.',
            ),
            _buildSectionCard(
              title: '3. Nghĩa Vụ của Chuyên Gia',
              content:
                  'Bạn đồng ý: (a) Cung cấp tư vấn chính xác, chuyên nghiệp và đúng đạo đức; (b) Tuân thủ tất cả các luật pháp và quy định hiện hành; (c) Không phân biệt đối xử dựa trên chủng tộc, giới tính, tôn giáo, quốc tịch hoặc bất kỳ đặc điểm bảo vệ nào; (d) Duy trì bảo mật và bảo vệ thông tin khách hàng; (e) Tuân thủ các hướng dẫn và tiêu chuẩn chất lượng của Nền tảng.',
            ),
            _buildSection(
              title: '4. Giá Dịch Vụ',
              content:
                  'Bạn có quyền thiết lập giá tư vấn của mình. Nền tảng sẽ thu phí hoa hồng 20% trên mỗi giao dịch. Ví dụ: Nếu bạn tính giá 100,000 VNĐ, bạn sẽ nhận 90,000 VNĐ. Các thay đổi giá sẽ có hiệu lực trong vòng 24 giờ.',
            ),
            _buildSection(
              title: '5. Thanh Toán',
              content:
                  'Tiền từ tư vấn sẽ được cộng vào ví SnakeAidPay của bạn ngay sau khi phiên tư vấn kết thúc. Bạn có thể rút tiền vào tài khoản ngân hàng bất cứ lúc nào. Rút tiền miễn phí, không có yêu cầu tối thiểu. Chúng tôi sẽ xử lý rút tiền trong vòng 1-3 ngày làm việc.',
            ),
            _buildSection(
              title: '6. Hủy Và Không Tham Gia',
              content:
                  'Nếu bạn không tham gia vào phiên tư vấn đã lập lịch theo giờ, điều này sẽ được coi là \"No-show\". Bạn sẽ mất cơ hội kiếm thu nhập cho phiên đó, và khách hàng sẽ được hoàn tiền. Có quá nhiều \"No-show\" có thể dẫn đến bị tạm ngừng hoặc xóa tài khoản.',
            ),
            _buildSection(
              title: '7. Giới Hạn Trách Nhiệm',
              content:
                  'Nền tảng không chịu trách nhiệm về: (a) Kết luận, khuyến cáo hoặc dịch vụ của bạn; (b) Hành động hoặc bất hành động của khách hàng dựa trên tư vấn của bạn; (c) Tranh chấp giữa bạn và khách hàng; (d) Mất mát gián tiếp, ngẫu nhiên hoặc đặc biệt phát sinh từ việc sử dụng Nền tảng.',
            ),
            _buildSection(
              title: '8. Chấm Dứt',
              content:
                  'Chúng tôi có quyền chấm dứt tài khoản của bạn nếu: (a) Bạn vi phạm các điều khoản này; (b) Bạn có hành vi không chuyên nghiệp hoặc không đạo đức; (c) Bạn nhận được báo cáo phàn nàn từ nhiều khách hàng; (d) Bạn gây hại cho danh tiếng hoặc hoạt động của Nền tảng.',
            ),
            _buildSection(
              title: '9. Sửa Đổi Điều Khoản',
              content:
                  'Chúng tôi có thể sửa đổi các điều khoản này bất cứ lúc nào. Bạn sẽ được thông báo về những thay đổi đáng kể qua email hoặc trong ứng dụng. Việc tiếp tục sử dụng Nền tảng sau khi sửa đổi có nghĩa là bạn chấp nhận các điều khoản mới.',
            ),
            _buildSectionCard(
              title: '10. Liên Hệ',
              content:
                  'Nếu bạn có bất kỳ câu hỏi về các điều khoản này, vui lòng liên hệ với đội hỗ trợ của chúng tôi qua email: support@snakeaid.com hoặc gọi hotline: 1900 XXXX.',
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
