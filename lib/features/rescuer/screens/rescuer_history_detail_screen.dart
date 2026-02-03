import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Rescuer History Detail Screen - Detailed view of a specific rescue mission
/// Màn hình chi tiết lịch sử cứu hộ
class RescuerHistoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> mission;

  const RescuerHistoryDetailScreen({
    super.key,
    required this.mission,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = mission['status'] == 'completed';
    final isCancelled = mission['status'] == 'cancelled';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(isCompleted, isCancelled),
            _buildInfoSection(),
            _buildSnakeSection(),
            _buildLocationSection(),
            if (isCompleted) ...[
              _buildRatingSection(),
              _buildIncomeSection(),
            ],
            if (isCancelled) _buildCancellationSection(),
            _buildTimelineSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF8F7F5),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1D150C)),
        onPressed: () => context.pop(),
      ),
      title: Text(
        mission['id'],
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1D150C),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Color(0xFF1D150C)),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chia sẻ - Đang phát triển')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusCard(bool isCompleted, bool isCancelled) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCompleted
              ? [const Color(0xFF10B981), const Color(0xFF059669)]
              : isCancelled
                  ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                  : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isCompleted
                ? Icons.check_circle
                : isCancelled
                    ? Icons.cancel
                    : Icons.schedule,
            color: Colors.white,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            isCompleted
                ? 'Nhiệm Vụ Hoàn Thành'
                : isCancelled
                    ? 'Nhiệm Vụ Đã Hủy'
                    : 'Đang Xử Lý',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${mission['date']} - ${mission['time']}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return _buildSection(
      title: 'Thông Tin Chung',
      child: Column(
        children: [
          _buildInfoRow(Icons.access_time, 'Thời gian', '${mission['date']} - ${mission['time']}'),
          const Divider(height: 24),
          _buildInfoRow(Icons.route, 'Khoảng cách', mission['distance']),
          const Divider(height: 24),
          _buildInfoRow(Icons.timer, 'Thời lượng', mission['duration']),
        ],
      ),
    );
  }

  Widget _buildSnakeSection() {
    return _buildSection(
      title: 'Thông Tin Rắn',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFE5E5E5),
              image: DecorationImage(
                image: NetworkImage(mission['snakeImage']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission['snakeName'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D150C),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Loại: Rắn độc',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kích thước: Trung bình (1.2m)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Mức độ nguy hiểm: Cao',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return _buildSection(
      title: 'Địa Điểm',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Color(0xFFFF8800),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mission['location'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1D150C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFE5E5E5),
            ),
            child: const Center(
              child: Icon(
                Icons.map,
                size: 64,
                color: Color(0xFF999999),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return _buildSection(
      title: 'Đánh Giá',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  size: 32,
                  color: index < mission['rating']
                      ? const Color(0xFFFFC107)
                      : const Color(0xFFE5E5E5),
                );
              }),
              const SizedBox(width: 12),
              Text(
                mission['rating'].toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D150C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E5E5)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nhận xét từ khách hàng:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF666666),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Cứu hộ viên rất chuyên nghiệp, đến nhanh và xử lý rất khéo léo. Cảm ơn anh rất nhiều!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1D150C),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeSection() {
    return _buildSection(
      title: 'Thu Nhập',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Phí dịch vụ',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
              ),
              Text(
                mission['income'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1D150C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phụ phí (xa, nguy hiểm)',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
              ),
              Text(
                '50,000 VNĐ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1D150C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phí nền tảng (10%)',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFEF4444),
                ),
              ),
              Text(
                '-25,000 VNĐ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng thu thực tế',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D150C),
                ),
              ),
              Text(
                mission['income'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationSection() {
    return _buildSection(
      title: 'Thông Tin Hủy',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Lý do hủy:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Khách hàng đã tự xử lý được và không cần hỗ trợ nữa.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF991B1B),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection() {
    return _buildSection(
      title: 'Tiến Trình',
      child: Column(
        children: [
          _buildTimelineItem(
            Icons.check_circle,
            'Nhận nhiệm vụ',
            '14:30',
            true,
          ),
          _buildTimelineItem(
            Icons.directions_car,
            'Đang di chuyển đến địa điểm',
            '14:35',
            true,
          ),
          _buildTimelineItem(
            Icons.location_on,
            'Đã đến nơi',
            '14:50',
            true,
          ),
          _buildTimelineItem(
            Icons.construction,
            'Đang xử lý',
            '14:55',
            true,
          ),
          _buildTimelineItem(
            Icons.check_circle_outline,
            'Hoàn thành',
            '15:15',
            true,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D150C),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF999999),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1D150C),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    IconData icon,
    String title,
    String time,
    bool isCompleted, {
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF10B981)
                      : const Color(0xFFE5E5E5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted
                        ? const Color(0xFF10B981)
                        : const Color(0xFFE5E5E5),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isCompleted
                          ? const Color(0xFF1D150C)
                          : const Color(0xFF999999),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
