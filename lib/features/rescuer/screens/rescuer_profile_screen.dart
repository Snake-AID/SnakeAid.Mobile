import 'package:flutter/material.dart';

/// Rescuer Profile Screen - Personal information and statistics for rescuer
class RescuerProfileScreen extends StatefulWidget {
  const RescuerProfileScreen({super.key});

  @override
  State<RescuerProfileScreen> createState() => _RescuerProfileScreenState();
}

class _RescuerProfileScreenState extends State<RescuerProfileScreen> {
  bool _isOnline = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Hồ Sơ Cứu Hộ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isOnline = !_isOnline;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _isOnline ? const Color(0xFF10B981) : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _isOnline ? 'On' : 'Off',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _isOnline ? const Color(0xFF10B981) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF2D2D2D)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Card
            _buildProfileCard(),
            const SizedBox(height: 16),

            // Rating Card
            _buildRatingCard(),
            const SizedBox(height: 16),

            // Stats Card
            _buildStatsCard(),
            const SizedBox(height: 16),

            // Revenue Card
            _buildRevenueCard(),
            const SizedBox(height: 16),

            // Menu Items
            _buildMenuItem(
              icon: Icons.checklist,
              title: 'Lịch Sử Cứu Hộ',
              subtitle: '87 nhiệm vụ đã hoàn thành',
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.wallet,
              title: 'Quản Lý Thu Nhập',
              subtitle: 'Xem báo cáo tài chính',
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.star,
              title: 'Đánh Giá & Phản Hồi',
              subtitle: '125 đánh giá từ khách hàng',
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.construction,
              title: 'Trang Thiết Bị',
              subtitle: 'Danh sách dụng cụ cứu hộ',
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.badge,
              title: 'Chứng Chỉ & Giấy Tờ',
              subtitle: 'CMND, BHYT',
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.pin_drop,
              title: 'Khu Vực Hoạt Động',
              subtitle: 'Quận 1, 3, 5, 10',
            ),
            const SizedBox(height: 16),

            // Vacation Mode
            _buildVacationMode(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFF6B35),
                width: 4,
              ),
            ),
            child: ClipOval(
              child: Container(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                child: const Icon(
                  Icons.person,
                  size: 48,
                  color: Color(0xFFFF6B35),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          const Text(
            'Trần Văn Cường',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 8),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shield,
                  size: 14,
                  color: Color(0xFFFF6B35),
                ),
                SizedBox(width: 6),
                Text(
                  'Cứu Hộ Viên Chuyên Nghiệp',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Phone
          const Text(
            '+84 987 654 321',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 4),

          // Join date
          const Text(
            'Tham gia: 01/2024',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(height: 20),

          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFF6B35), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: const Color(0xFFFF6B35),
                overlayColor: const Color(0xFFFF6B35).withOpacity(0.1),
              ),
              child: const Text(
                'Chỉnh Sửa Hồ Sơ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B35),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Stars and Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(
                4,
                (index) => const Icon(
                  Icons.star,
                  color: Color(0xFFFFC107),
                  size: 24,
                ),
              ),
              const Icon(
                Icons.star_half,
                color: Color(0xFFFFC107),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '4.8/5.0',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Divider and Stats
          Container(
            padding: const EdgeInsets.only(top: 20),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFF0F0F0), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: const [
                      Text(
                        '125 đánh giá',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: const Color(0xFFF0F0F0),
                ),
                Expanded(
                  child: Column(
                    children: const [
                      Text(
                        '98%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tỷ lệ phản hồi',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: const Color(0xFFF0F0F0),
                ),
                Expanded(
                  child: Column(
                    children: const [
                      Text(
                        '< 3 phút',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Thời gian phản hồi',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: const [
                Text(
                  '87',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Ca hoàn thành',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFFF0F0F0),
          ),
          Expanded(
            child: Column(
              children: const [
                Text(
                  '12',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Ca tháng này',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFFF0F0F0),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  '95%',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Thành công',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: Color(0xFFFF6B35), width: 4),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Thu nhập tháng này',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '4,250,000 VNĐ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tổng tích lũy: 52,800,000 VNĐ',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Xem Chi Tiết',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2196F3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          splashColor: const Color(0xFFFF6B35).withOpacity(0.1),
          highlightColor: const Color(0xFFFF6B35).withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFFFF6B35),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 2),
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
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFCCCCCC),
              size: 20,
            ),
          ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVacationMode() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFF6B35), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),                foregroundColor: const Color(0xFFFF6B35),
                overlayColor: const Color(0xFFFF6B35).withOpacity(0.1),              ),
              child: const Text(
                'Chế Độ Nghỉ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B35),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tạm ngừng nhận yêu cầu mới',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}
