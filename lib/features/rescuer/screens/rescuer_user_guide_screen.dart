import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/rescuer_services_and_terms.dart';
import '../providers/rescuer_services_and_terms_provider.dart';

class RescuerUserGuideScreen extends ConsumerStatefulWidget {
  const RescuerUserGuideScreen({super.key});

  @override
  ConsumerState<RescuerUserGuideScreen> createState() =>
      _RescuerUserGuideScreenState();
}

class _RescuerUserGuideScreenState
    extends ConsumerState<RescuerUserGuideScreen> {
  int _expandedIndex = -1;

  List<RescuerUsageGuideItem> _fallbackGuide() {
    return const [
      RescuerUsageGuideItem(
        stepNumber: 1,
        title: 'Bắt Đầu Chế Độ Cứu Hộ',
        description: 'Cách kích hoạt và quản lý chế độ cứu hộ',
        details: [
          'Mở ứng dụng SnakeAid Đội Cứu Hộ',
          'Trên màn hình chính, tìm mục "OFFLINE" hoặc "ONLINE"',
          'Nhấp vào nút chuyển đổi để bật chế độ cứu hộ',
          'Ứng dụng sẽ kiểm tra GPS và vị trí của bạn',
          'Nếu GPS sẵn sàng, bạn sẽ chuyển sang trạng thái "ONLINE"',
          'Khi ONLINE, bạn sẽ nhận được các yêu cầu cứu hộ từ điều phối viên',
        ],
      ),
      RescuerUsageGuideItem(
        stepNumber: 2,
        title: 'Nhận Và Xác Nhận Yêu Cầu',
        description: 'Quy trình xử lý các yêu cầu cứu hộ mới',
        details: [
          'Khi có yêu cầu mới, ứng dụng sẽ phát cảnh báo âm thanh',
          'Một hộp thoại sẽ xuất hiện với thông tin yêu cầu từ điều phối viên',
          'Nhấp "Xem Chi Tiết" để xem đầy đủ thông tin (địa chỉ, mô tả rắn...)',
          'Kiểm tra khoảng cách và tính khả thi của yêu cầu',
          'Nhấp "Chấp Nhận" nếu bạn sẵn sàng xử lý',
          'Nhấp "Từ Chối" nếu bạn không thể hỗ trợ',
          'Sau khi chấp nhận, bạn sẽ được dẫn đến màn hình theo dõi',
        ],
      ),
      RescuerUsageGuideItem(
        stepNumber: 3,
        title: 'Theo Dõi Vị Trí',
        description: 'Cách điều hướng đến vị trí yêu cầu',
        details: [
          'Sau khi chấp nhận yêu cầu, bạn sẽ thấy bản đồ với vị trí khách hàng',
          'Nhấp vào "Bắt đầu di chuyển" để có thể điều hướng qua map',
          'Thông tin khách hàng sẽ hiển thị ở phần trên (tên, số điện thoại)',
          'Bạn có thể gọi khách hàng trực tiếp từ ứng dụng',
          'Khi tới nơi, nhấp "Đã Tới Nơi" để cập nhật trạng thái',
          'Duy trì GPS bật để cập nhật vị trí chính xác',
        ],
      ),
      RescuerUsageGuideItem(
        stepNumber: 4,
        title: 'Hoàn Thành Nhiệm Vụ',
        description: 'Cách kết thúc và báo cáo công việc',
        details: [
          'Sau khi xử lý xong vụ việc (bắt rắn, xác nhận an toàn...)',
          'Nhấp nút "Hoàn Thành" trên màn hình',
          'Điền thông tin chi tiết: loại rắn, địa điểm, mô tả sự cố',
          'Tải lên ảnh/video chứng minh (nếu có)',
          'Thêm ghi chú nếu cần thiết',
          'Nhấp "Xác Nhận" để gửi báo cáo',
          'Bạn sẽ nhận được xác nhận hoàn thành từ hệ thống',
        ],
      ),
      RescuerUsageGuideItem(
        stepNumber: 5,
        title: 'Cài Đặt Thông Báo',
        description: 'Tùy chỉnh cảnh báo và thông báo',
        details: [
          'Mở "Cài Đặt" từ tab "Cá Nhân"',
          'Chọn mục "Thông Báo"',
          'Bật "Thông báo đẩy" để nhận cảnh báo yêu cầu mới',
          'Bật "Âm thanh đọc rắn cắn" để nghe cảnh báo khi có SOS',
          'Bật "Âm thanh đọc đơn bắt rắn" để nghe cảnh báo khi có đơn bắt rắn',
          'Bật "Rung" để cảm nhận rung mạnh khi có yêu cầu khẩn cấp',
          'Chọn giọng nói thích hợp (Hệ thống mặc định)',
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final termsAsync = ref.watch(rescuerServicesAndTermsProvider);

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
          'Hướng Dẫn Sử Dụng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF231A0F),
          ),
        ),
      ),
      body: termsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _buildGuideList(_fallbackGuide()),
        data: (terms) {
          final guide = terms.usageGuide.isNotEmpty
              ? terms.usageGuide
              : _fallbackGuide();
          return _buildGuideList(guide);
        },
      ),
    );
  }

  Widget _buildGuideList(List<RescuerUsageGuideItem> guide) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final item = guide[index];
        return _buildGuideSection(
          index,
          item.stepNumber > 0 ? item.stepNumber : index + 1,
          item.title,
          item.description,
          item.details,
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: guide.length,
    );
  }

  Widget _buildGuideSection(
    int index,
    int displayNumber,
    String title,
    String subtitle,
    List<String> steps,
  ) {
    final isExpanded = _expandedIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '$displayNumber',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF231A0F),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < steps.length; i++) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF6B35),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            steps[i],
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF666666),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (i < steps.length - 1) const SizedBox(height: 12),
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
