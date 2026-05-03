import 'package:flutter/material.dart';

class RescuerFaqScreen extends StatefulWidget {
  const RescuerFaqScreen({super.key});

  @override
  State<RescuerFaqScreen> createState() => _RescuerFaqScreenState();
}

class _RescuerFaqScreenState extends State<RescuerFaqScreen> {
  int _expandedIndex = -1;

  final List<Map<String, dynamic>> _faqs = [
    {
      'category': 'Bắt Đầu',
      'question': 'Tôi cần những gì để bắt đầu?',
      'items': [
        'Smartphone chạy Android 10.0 trở lên',
        'Kết nối internet ổn định (4G/WiFi)',
        'Bật GPS trên thiết bị',
        'Tài khoản đội cứu hộ đã được trung tâm xác minh và cấp quyền',
        'Vị trí hiện tại để nhận các yêu cầu gần nhất',
      ],
    },
    {
      'category': 'Bắt Đầu',
      'question': 'Làm cách nào để chuyển từ OFFLINE sang ONLINE?',
      'items': [
        'Mở ứng dụng SnakeAid',
        'Tìm nút chuyển đổi OFFLINE/ONLINE trên màn hình chính',
        'Nhấp vào nút để bật chế độ cứu hộ',
        'Ứng dụng sẽ kiểm tra GPS',
        'Khi GPS sẵn sàng, bạn sẽ ONLINE',
      ],
    },
    {
      'category': 'Bắt Đầu',
      'question': 'Tại sao GPS của tôi không sẵn sàng?',
      'items': [
        'Kiểm tra GPS có được bật trong cài đặt thiết bị',
        'Đảm bảo có ít nhất 5 vệ tinh được kết nối',
        'Tránh ở trong nhà hoặc khu vực che phủ',
        'Di chuyển ra ngoài và chờ 30 giây',
        'Khởi động lại ứng dụng nếu vấn đề vẫn tiếp tục',
      ],
    },
    {
      'category': 'Yêu Cầu',
      'question': 'Tôi không nhận được yêu cầu mới. Tại sao?',
      'items': [
        'Kiểm tra trạng thái ONLINE của bạn',
        'Kiểm tra khoảng cách (phạm vi > 30km có thể không được chọn)',
        'Đội cứu hộ khác có thể đã chấp nhận các yêu cầu',
        'Có thể không có yêu cầu mới trong khu vực của bạn',
        'Đảm bảo thông báo đẩy được bật',
      ],
    },
    {
      'category': 'Yêu Cầu',
      'question': 'Tôi có thể từ chối một yêu cầu không?',
      'items': [
        'Nhấp "Để Sau" trong hộp thoại yêu cầu',
        'Yêu cầu sẽ được gửi đến đội cứu hộ khác',
        'Không có hình phạt cho một lần từ chối',
        'Lưu ý: Quá nhiều lần từ chối có thể ảnh hưởng đến đánh giá',
      ],
    },
    {
      'category': 'Yêu Cầu',
      'question': 'Tôi chấp nhận yêu cầu nhưng không thể đến. Có được không?',
      'items': [
        'Bạn có thể hủy trong 2 phút đầu tiên',
        'Hủy sau 2 phút sẽ ảnh hưởng đến đánh giá',
        'Tốt hơn là từ chối sớm thay vì hủy sau',
        'Quá nhiều lần hủy sẽ dẫn đến hạn chế tính năng',
      ],
    },
    {
      'category': 'Quy Trình Trung Tâm',
      'question': 'Đội cứu hộ có cần thao tác thanh toán trên ứng dụng không?',
      'items': [
        'Không. Đội cứu hộ chỉ nhận đơn và thực hiện nhiệm vụ hiện trường.',
        'Mọi khoản thanh toán do trung tâm quản lý và đối soát.',
        'Ứng dụng đội cứu hộ không có chức năng ví hoặc nhận tiền trực tiếp.',
        'Nếu cần xác nhận công việc, hãy hoàn thành báo cáo và gửi về trung tâm.',
        'Mọi thắc mắc về công nợ/chi trả liên hệ điều phối hoặc quản lý trung tâm.',
      ],
    },
    {
      'category': 'Kỹ Thuật',
      'question': 'Ứng dụng của tôi bị giật/chậm. Tôi nên làm gì?',
      'items': [
        'Đóng tất cả ứng dụng khác đang chạy',
        'Xóa bộ đệm (Cài Đặt > Ứng Dụng > SnakeAid > Xóa Bộ Đệm)',
        'Khởi động lại thiết bị',
        'Cập nhật ứng dụng lên phiên bản mới nhất',
        'Kiểm tra dung lượng lưu trữ có đủ không',
      ],
    },
    {
      'category': 'Kỹ Thuật',
      'question': 'Tôi không nhận được thông báo. Tại sao?',
      'items': [
        'Kiểm tra thông báo đẩy có được bật không',
        'Pin tiết kiệm có làm vô hiệu hóa thông báo không',
        'Ứng dụng có được cấp quyền thông báo không',
        'Âm thanh hoặc rung có bị tắt không',
        'Thử gỡ cài đặt và cài đặt lại ứng dụng',
      ],
    },
    {
      'category': 'Kỹ Thuật',
      'question': 'Vị trí của tôi không cập nhật chính xác. Tại sao?',
      'items': [
        'GPS có thể không chính xác (lỗi hệ thống)',
        'Bạn ở trong nhà hoặc khu vực tín hiệu yếu',
        'Quyền vị trí có thể không được cấp đầy đủ',
        'Kiểm tra: Cài Đặt > Ứng Dụng > SnakeAid > Quyền',
        'Di chuyển ra ngoài và chờ GPS khóa đúng',
      ],
    },
    {
      'category': 'Tài Khoản',
      'question': 'Làm cách nào để cập nhật thông tin cá nhân?',
      'items': [
        'Mở ứng dụng SnakeAid Đội Cứu Hộ',
        'Nhấp tab "Cá Nhân"',
        'Nhấp vào hình ảnh hồ sơ hoặc tên',
        'Chỉnh sửa thông tin cần thiết',
        'Nhấp "Lưu" để cập nhật',
      ],
    },
    {
      'category': 'Tài Khoản',
      'question': 'Tôi quên mật khẩu. Làm cách nào để đặt lại?',
      'items': [
        'Trên màn hình đăng nhập, nhấp "Quên Mật Khẩu?"',
        'Nhập số điện thoại hoặc email',
        'Chọn phương thức xác nhận (SMS hoặc Email)',
        'Nhập mã xác nhận nhận được',
        'Tạo mật khẩu mới và xác nhận',
      ],
    },
    {
      'category': 'An Toàn',
      'question': 'Dữ liệu cá nhân của tôi có an toàn không?',
      'items': [
        'Tất cả dữ liệu cá nhân được mã hóa',
        'Tuân thủ quy định bảo vệ dữ liệu',
        'Không chia sẻ thông tin với bên thứ ba',
        'Kiểm tra bảo mật định kỳ',
        'Cập nhật chứng chỉ bảo mật thường xuyên',
      ],
    },
    {
      'category': 'An Toàn',
      'question': 'Tôi nên làm gì khi xử lý rắn nguy hiểm?',
      'items': [
        'Mang dụng cụ bảo vệ chuẩn (kính, găng tay)',
        'Không chạm trực tiếp vào rắn',
        'Gọi chuyên gia nếu không chắc chắn',
        'Ghi lại tất cả chi tiết (loại rắn, vị trí, hành động)',
        'Báo cáo bất kỳ sự cố nào ngay lập tức',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final groupedFaqs = <String, List<Map<String, dynamic>>>{};
    for (var faq in _faqs) {
      final category = faq['category'] as String;
      groupedFaqs.putIfAbsent(category, () => []).add(faq);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F5),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF231A0F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Câu Hỏi Thường Gặp',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF231A0F),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupedFaqs.length,
        itemBuilder: (context, categoryIndex) {
          final categories = groupedFaqs.keys.toList();
          final category = categories[categoryIndex];
          final faqs = groupedFaqs[category]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFF6B35).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF6B35),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...faqs.asMap().entries.map((entry) {
                final faq = entry.value;
                final globalIndex = _faqs.indexOf(faq);

                return _buildFaqItem(
                  globalIndex,
                  faq['question'] as String,
                  faq['items'] as List<String>,
                );
              }),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFaqItem(int index, String question, List<String> items) {
    final isExpanded = _expandedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedIndex = isExpanded ? -1 : index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF231A0F),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFFFF6B35),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            items[i],
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF666666),
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (i < items.length - 1) const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
