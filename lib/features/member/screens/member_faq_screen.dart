import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class MemberFaqScreen extends StatefulWidget {
  const MemberFaqScreen({super.key});

  @override
  State<MemberFaqScreen> createState() => _MemberFaqScreenState();
}

class _MemberFaqScreenState extends State<MemberFaqScreen> {
  final List<Map<String, String>> faqs = [
    {
      'question': 'Làm thế nào để gọi cứu hộ bắt rắn?',
      'answer':
          'Trên màn hình chính, chọn "Cần bắt rắn", sau đó xác nhận vị trí của bạn trên bản đồ. Một chuyên gia gần nhất sẽ nhận đơn và di chuyển đến ngay lập tức.'
    },
    {
      'question': 'Tôi phải làm gì khi bị rắn cắn?',
      'answer':
          'Hãy nhấn nút SOS màu đỏ trên màn hình chính ngay lập tức. Giữ bình tĩnh, hạn chế vận động vùng bị cắn và làm theo hướng dẫn sơ cứu trong mục "Thư viện & Sơ cứu" trong khi chờ đội cứu hộ đến.'
    },
    {
      'question': 'Có mất phí nếu chuyên gia không tìm thấy rắn không?',
      'answer':
          'Theo chính sách của chúng tôi, nếu chuyên gia đã đến hiện trường nhưng không tìm thấy rắn, bạn sẽ không phải thanh toán phí dịch vụ bắt rắn, tuy nhiên khoản phí đặt cọc di chuyển nhỏ sẽ được sử dụng để hỗ trợ chi phí xăng xe cho chuyên gia.'
    },
    {
      'question': 'Làm cách nào để nạp tiền vào ví SnakeAidPay?',
      'answer':
          'Bạn vào mục "Hồ sơ" -> chọn "Nạp tiền". Bạn có thể nạp tiền qua chuyển khoản ngân hàng hoặc các ví điện tử được tích hợp sẵn.'
    },
    {
      'question': 'Ứng dụng hỗ trợ ở những khu vực nào?',
      'answer':
          'Hiện tại SnakeAid đang hỗ trợ tốt nhất tại khu vực TP. Hồ Chí Minh, Thủ Đức, Bình Dương, Đồng Nai và Bà Rịa - Vũng Tàu. Chúng tôi đang mở rộng ra các tỉnh thành khác trong thời gian tới.'
    },
    {
      'question': 'Làm sao để biết rắn có độc hay không?',
      'answer':
          'Bạn có thể sử dụng tính năng "Tư vấn ngay" để gửi hình ảnh cho chuyên gia xác định, hoặc tra cứu trong mục "Thư viện loài rắn" trên ứng dụng.'
    },
  ];

  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1B5E20)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Câu Hỏi Thường Gặp',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final isExpanded = _expandedIndex == index;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isExpanded ? AppTheme.primaryGreen : const Color(0xFFF0F0F0),
                width: isExpanded ? 1.5 : 1,
              ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  faqs[index]['question']!,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isExpanded ? FontWeight.bold : FontWeight.w600,
                    color: isExpanded ? AppTheme.primaryGreen : const Color(0xFF333333),
                  ),
                ),
                trailing: Icon(
                  isExpanded ? Icons.remove_circle_outline : Icons.add_circle_outline,
                  color: isExpanded ? AppTheme.primaryGreen : Colors.grey,
                ),
                onExpansionChanged: (expanded) {
                  setState(() {
                    _expandedIndex = expanded ? index : null;
                  });
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                    child: Text(
                      faqs[index]['answer']!,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
