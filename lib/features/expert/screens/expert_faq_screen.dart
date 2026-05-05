import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Expert FAQ Screen - Frequently asked questions for experts
class ExpertFaqScreen extends ConsumerStatefulWidget {
  const ExpertFaqScreen({super.key});

  @override
  ConsumerState<ExpertFaqScreen> createState() => _ExpertFaqScreenState();
}

class _ExpertFaqScreenState extends ConsumerState<ExpertFaqScreen> {
  int? _expandedIndex;

  final List<FaqCategory> categories = [
    FaqCategory(
      title: 'Bắt Đầu',
      icon: Icons.lightbulb_outline,
      faqs: [
        Faq(
          question: 'Làm thế nào để kích hoạt tư vấn trên nền tảng?',
          answer:
              'Sau khi đăng ký và xác minh, hãy vào hồ sơ của bạn và chọn "Kích hoạt tư vấn". Bạn cần hoàn thành thông tin cơ bản và xác minh danh tính trước khi kích hoạt.',
        ),
        Faq(
          question: 'Tư vấn ngay và đặt lịch khác nhau như thế nào?',
          answer:
              'Tư vấn ngay: Khách hàng yêu cầu tư vấn ngay lập tức, bạn có 2 phút để chấp nhận. Đặt lịch: Khách hàng chọn khung giờ từ lịch của bạn, bạn có thể chuẩn bị trước.',
        ),
        Faq(
          question: 'Tôi có thể đặt giá tư vấn của mình không?',
          answer:
              'Có, bạn có thể đặt giá khác nhau cho tư vấn ngay và đặt lịch. Vào "Cài đặt" > "Phí tư vấn" để cập nhật giá. Hóa đơn sẽ được tính trên giá bạn đặt.',
        ),
      ],
    ),
    FaqCategory(
      title: 'Tư Vấn Ngay',
      icon: Icons.flash_on,
      faqs: [
        Faq(
          question: 'Tôi có thể từ chối yêu cầu tư vấn ngay không?',
          answer:
              'Có, nếu bạn bận rộn hoặc không thể tư vấn, hãy nhấp "Từ chối". Khách hàng sẽ được kết nối với chuyên gia khác. Từ chối quá nhiều có thể ảnh hưởng đến xếp hạng của bạn.',
        ),
        Faq(
          question: 'Thời gian tối đa cho một phiên tư vấn là bao lâu?',
          answer:
              'Không có giới hạn thời gian cụ thể, nhưng tính cước được tính theo từng phút. Khách hàng có thể kết thúc cuộc họp bất cứ lúc nào. Hãy cố gắng giải quyết vấn đề trong thời gian hợp lý.',
        ),
        Faq(
          question: 'Nếu kết nối bị mất, điều gì sẽ xảy ra?',
          answer:
              'Nếu kết nối video bị gián đoạn, hệ thống sẽ cố gắng kết nối lại trong vòng 30 giây. Nếu không thành công, phiên sẽ kết thúc. Khách hàng sẽ được hoàn tiền một phần dựa trên thời gian tư vấn thực tế.',
        ),
      ],
    ),
    FaqCategory(
      title: 'Đặt Lịch',
      icon: Icons.calendar_today,
      faqs: [
        Faq(
          question:
              'Tôi có thể thay đổi lịch làm việc của mình bất cứ lúc nào không?',
          answer:
              'Có, bạn có thể cập nhật lịch làm việc bất cứ lúc nào. Tuy nhiên, các lịch đã đặt sẽ không bị hủy. Nếu thay đổi sẽ ảnh hưởng đến lịch đã đặt, vui lòng thông báo cho khách hàng.',
        ),
        Faq(
          question: 'Khách hàng có thể hủy cuộc hẹn không?',
          answer:
              'Có, khách hàng có thể hủy lịch trước khi cuộc hẹn diễn ra. Nếu hủy trong vòng 24 giờ, họ sẽ bị tính phí hủy 10%. Nếu hủy trong vòng 1 giờ, phí hủy là 20%.',
        ),
        Faq(
          question: 'Tôi nên làm gì nếu khách hàng không tham gia đúng giờ?',
          answer:
              'Hãy chờ tối đa 15 phút. Nếu khách hàng vẫn không tham gia, bạn có thể kết thúc phiên. Khách hàng sẽ bị tính phí "No-show". Bạn sẽ nhận được toàn bộ thanh toán.',
        ),
      ],
    ),
    FaqCategory(
      title: 'Thanh Toán & Doanh Thu',
      icon: Icons.payments_outlined,
      faqs: [
        Faq(
          question: 'Tôi nhận tiền vào tài khoản ngân hàng như thế nào?',
          answer:
              'Tiền sẽ được gộp vào ví SnakeAidPay của bạn. Vào mục "Quản lý doanh thu" để xem chi tiết. Bạn có thể rút tiền vào tài khoản ngân hàng trong phần "Ví SnakeAidPay".',
        ),
        Faq(
          question: 'Nền tảng lấy bao nhiêu phí hoa hồng?',
          answer:
              'Nền tảng lấy 20% phí hoa hồng trên mỗi giao dịch. Ví dụ: Nếu bạn tính giá 100,000 VNĐ, bạn sẽ nhận 80,000 VNĐ sau khi trừ phí.',
        ),
        Faq(
          question: 'Khi nào tôi nhận được tiền từ tư vấn?',
          answer:
              'Tiền được cộng vào ví của bạn ngay sau khi phiên tư vấn kết thúc. Bạn có thể rút tiền bất cứ lúc nào không có phí rút tiền tối thiểu.',
        ),
      ],
    ),
    FaqCategory(
      title: 'Kỹ Thuật & Hỗ Trợ',
      icon: Icons.troubleshoot,
      faqs: [
        Faq(
          question: 'Yêu cầu về camera và microphone là gì?',
          answer:
              'Bạn cần camera và microphone hoạt động tốt. Khuyến nghị sử dụng máy tính hoặc điện thoại thông minh với kết nối Internet tốc độ cao (ít nhất 4 Mbps). Hãy kiểm tra thiết bị trước khi tư vấn.',
        ),
        Faq(
          question: 'Phần mềm hoặc ứng dụng nào mà tôi cần cài đặt?',
          answer:
              'Bạn chỉ cần sử dụng ứng dụng SnakeAid hoặc truy cập trang web trên trình duyệt. Không cần cài đặt phần mềm bổ sung. Hãy đảm bảo ứng dụng/trình duyệt của bạn được cập nhật.',
        ),
        Faq(
          question: 'Tôi gặp sự cố kết nối video, tôi phải làm gì?',
          answer:
              'Kiểm tra kết nối Internet của bạn, tắt các ứng dụng khác, khởi động lại ứng dụng. Nếu vấn đề vẫn tiếp tục, hãy liên hệ hỗ trợ. Khách hàng sẽ được hoàn tiền nếu sự cố là do phía bạn.',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
          'Câu Hỏi Thường Gặp',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            categories.length,
            (categoryIndex) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Header
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C47C2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          categories[categoryIndex].icon,
                          color: const Color(0xFF6C47C2),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        categories[categoryIndex].title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // FAQ Items
                  Column(
                    children: List.generate(
                      categories[categoryIndex].faqs.length,
                      (faqIndex) {
                        final globalIndex =
                            categories
                                .take(categoryIndex)
                                .fold(0, (sum, cat) => sum + cat.faqs.length) +
                            faqIndex;

                        return _buildFaqItem(
                          faq: categories[categoryIndex].faqs[faqIndex],
                          isExpanded: _expandedIndex == globalIndex,
                          onTap: () {
                            setState(() {
                              _expandedIndex = _expandedIndex == globalIndex
                                  ? null
                                  : globalIndex;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem({
    required Faq faq,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isExpanded
                    ? const Color(0xFF6C47C2)
                    : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          faq.question,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D2D2D),
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: const Color(0xFF6C47C2),
                        size: 20,
                      ),
                    ],
                  ),

                  // Answer (Expanded)
                  if (isExpanded) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C47C2).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        faq.answer,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.6,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FaqCategory {
  final String title;
  final IconData icon;
  final List<Faq> faqs;

  FaqCategory({required this.title, required this.icon, required this.faqs});
}

class Faq {
  final String question;
  final String answer;

  Faq({required this.question, required this.answer});
}
