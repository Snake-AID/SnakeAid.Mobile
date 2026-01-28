import 'package:flutter/material.dart';

/// Expert Settings Screen
class ExpertSettingsScreen extends StatefulWidget {
  const ExpertSettingsScreen({super.key});

  @override
  State<ExpertSettingsScreen> createState() => _ExpertSettingsScreenState();
}

class _ExpertSettingsScreenState extends State<ExpertSettingsScreen> {
  // Schedule toggles
  final Map<String, bool> _scheduleEnabled = {
    'Thứ 2': true,
    'Thứ 3': true,
    'Thứ 4': true,
    'Thứ 5': false,
    'Thứ 6': true,
    'Thứ 7': false,
    'Chủ Nhật': false,
  };

  final Map<String, String> _scheduleTimes = {
    'Thứ 2': '8:00 - 17:00',
    'Thứ 3': '8:00 - 17:00',
    'Thứ 4': '9:00 - 18:00',
    'Thứ 5': '',
    'Thứ 6': '8:00 - 12:00',
    'Thứ 7': '',
    'Chủ Nhật': '',
  };

  // Notification toggles
  bool _notifyNewConsultation = true;
  bool _notifySOS = true;
  bool _notifyRescuerSupport = true;
  bool _notifyNewMessage = true;
  bool _notifyPayment = true;
  bool _notifyNewReview = true;
  bool _notifyMarketing = false;

  // Privacy toggles
  bool _publicProfile = true;
  bool _allowDirectCall = false;

  // Data toggles
  bool _offlineSync = true;

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
          'Cài Đặt',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // SECTION 1: Account
            _buildSectionHeader('Tài Khoản'),
            _buildCard(
              children: [
                _buildAccountRow(
                  label: 'Số điện thoại',
                  value: '0912 345 678',
                  verified: true,
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildAccountRow(
                  label: 'Email',
                  value: 'expert@example.com',
                  verified: true,
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildAccountRow(
                  label: 'Mật khẩu',
                  value: '••••••••',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildAccountRow(
                  label: 'Trạng thái xác minh',
                  value: 'Đã xác minh đầy đủ',
                  statusIcon: Icons.check_circle,
                  onTap: () {},
                ),
              ],
            ),

            // SECTION 2: Work Schedule
            _buildSectionHeader(
              'Lịch Làm Việc',
              subtitle: 'Đặt thời gian sẵn sàng nhận tư vấn đặt lịch',
            ),
            _buildCard(
              children: [
                ..._scheduleEnabled.keys.map((day) {
                  final isLast = day == 'Chủ Nhật';
                  return Column(
                    children: [
                      _buildScheduleRow(day),
                      if (!isLast) const Divider(height: 1),
                    ],
                  );
                }).toList(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                'Thời gian theo múi giờ ICT (GMT+7)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),

            // SECTION 3: Consultation Fees
            _buildSectionHeader('Phí Tư Vấn'),
            _buildCard(
              children: [
                _buildFeeRow(
                  title: 'Tư vấn đặt lịch (Patient)',
                  subtitle: 'Bạn nhận: 270,000 VNĐ (90%)',
                  amount: '300,000 VNĐ',
                  editable: true,
                ),
                const Divider(height: 1),
                _buildFeeRow(
                  title: 'Tư vấn khẩn cấp (SOS)',
                  subtitle: 'Bạn nhận: 450,000 VNĐ (90%)',
                  amount: '500,000 VNĐ',
                  info: true,
                ),
                const Divider(height: 1),
                _buildFeeRow(
                  title: 'Hỗ trợ Rescuer',
                  subtitle: 'Từ phần chia sẻ của Rescuer',
                  amount: '50,000 VNĐ',
                  info: true,
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C47C2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info,
                        color: Color(0xFF6C47C2),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Phí nền tảng 10% áp dụng cho tất cả dịch vụ để duy trì hệ thống SnakeAid.',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF6C47C2),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),

            // SECTION 4: Notifications
            _buildSectionHeader('Thông Báo'),
            _buildCard(
              children: [
                _buildNotificationRow(
                  title: 'Yêu cầu tư vấn mới',
                  subtitle: 'Nhận thông báo khi có lịch hẹn mới',
                  value: _notifyNewConsultation,
                  onChanged: (v) => setState(() => _notifyNewConsultation = v),
                ),
                const Divider(height: 1),
                _buildNotificationRow(
                  title: 'Tư vấn SOS khẩn cấp',
                  subtitle: 'Thông báo ưu tiên cao',
                  value: _notifySOS,
                  onChanged: (v) => setState(() => _notifySOS = v),
                ),
                const Divider(height: 1),
                _buildNotificationRow(
                  title: 'Hỗ trợ Rescuer',
                  subtitle: 'Yêu cầu hỗ trợ định danh loài rắn',
                  value: _notifyRescuerSupport,
                  onChanged: (v) => setState(() => _notifyRescuerSupport = v),
                ),
                const Divider(height: 1),
                _buildNotificationRow(
                  title: 'Tin nhắn mới',
                  subtitle: 'Tin nhắn từ bệnh nhân',
                  value: _notifyNewMessage,
                  onChanged: (v) => setState(() => _notifyNewMessage = v),
                ),
                const Divider(height: 1),
                _buildNotificationRow(
                  title: 'Thanh toán',
                  subtitle: 'Thông báo nhận tiền',
                  value: _notifyPayment,
                  onChanged: (v) => setState(() => _notifyPayment = v),
                ),
                const Divider(height: 1),
                _buildNotificationRow(
                  title: 'Đánh giá mới',
                  subtitle: 'Khi có review từ người dùng',
                  value: _notifyNewReview,
                  onChanged: (v) => setState(() => _notifyNewReview = v),
                ),
                const Divider(height: 1),
                _buildNotificationRow(
                  title: 'Email marketing',
                  subtitle: 'Tin tức và khuyến mãi',
                  value: _notifyMarketing,
                  onChanged: (v) => setState(() => _notifyMarketing = v),
                ),
              ],
            ),

            // SECTION 5: Payment Methods
            _buildSectionHeader(
              'Phương Thức Thanh Toán',
              subtitle: 'Tài khoản nhận tiền tư vấn',
            ),
            _buildCard(
              children: [
                InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Tài khoản ngân hàng',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Vietcombank - •••• 6789',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C47C2).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Chính',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6C47C2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Thêm Tài Khoản Ngân Hàng',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6C47C2),
                  side: const BorderSide(color: Color(0xFF6C47C2)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // SECTION 6: Privacy & Security
            _buildSectionHeader('Quyền Riêng Tư & Bảo Mật'),
            _buildCard(
              children: [
                _buildNotificationRow(
                  title: 'Hiển thị hồ sơ công khai',
                  subtitle: 'Người dùng có thể tìm thấy bạn',
                  value: _publicProfile,
                  onChanged: (v) => setState(() => _publicProfile = v),
                ),
                const Divider(height: 1),
                _buildNotificationRow(
                  title: 'Cho phép gọi trực tiếp',
                  subtitle: 'Nhận cuộc gọi ngoài lịch hẹn',
                  value: _allowDirectCall,
                  onChanged: (v) => setState(() => _allowDirectCall = v),
                ),
                const Divider(height: 1),
                _buildSimpleRow(
                  label: 'Điều khoản sử dụng',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildSimpleRow(
                  label: 'Chính sách quyền riêng tư',
                  onTap: () {},
                ),
              ],
            ),

            // SECTION 7: Options
            _buildSectionHeader('Tùy Chọn'),
            _buildCard(
              children: [
                _buildOptionRow(
                  label: 'Ngôn ngữ',
                  value: 'Tiếng Việt',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildOptionRow(
                  label: 'Giao diện',
                  value: 'Sáng (Light)',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildOptionRow(
                  label: 'Múi giờ',
                  value: 'ICT (GMT+7)',
                  onTap: () {},
                ),
              ],
            ),

            // SECTION 8: Data Management
            _buildSectionHeader('Quản Lý Dữ Liệu'),
            _buildCard(
              children: [
                _buildDataRow(
                  title: 'Xuất dữ liệu',
                  subtitle: 'Tải xuống hồ sơ tư vấn',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildDataRow(
                  title: 'Xóa bộ nhớ đệm',
                  subtitle: 'Giải phóng 234 MB',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildNotificationRow(
                  title: 'Đồng bộ offline',
                  subtitle: 'Tự động tải dữ liệu mới',
                  value: _offlineSync,
                  onChanged: (v) => setState(() => _offlineSync = v),
                ),
              ],
            ),

            // SECTION 9: Support
            _buildSectionHeader('Hỗ Trợ'),
            _buildCard(
              children: [
                _buildSimpleRow(
                  label: 'Hướng dẫn sử dụng',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildDataRow(
                  title: 'Liên hệ hỗ trợ',
                  subtitle: 'Chat với đội ngũ admin',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildSimpleRow(
                  label: 'Báo cáo sự cố',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildSimpleRow(
                  label: 'Câu hỏi thường gặp (FAQ)',
                  onTap: () {},
                ),
              ],
            ),

            // SECTION 10: App Info
            _buildSectionHeader('Thông Tin Ứng Dụng'),
            _buildCard(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Phiên bản',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ),
                      Text(
                        '1.2.5 (Build 125)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF28A745).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Mới nhất',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF28A745),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                _buildSimpleRow(
                  label: 'Đánh giá ứng dụng',
                  icon: Icons.star,
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildSimpleRow(
                  label: 'Chia sẻ ứng dụng',
                  icon: Icons.share,
                  onTap: () {},
                ),
              ],
            ),

            // SECTION 11: Account Actions
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildActionButton(
                    label: 'Đăng xuất',
                    color: const Color(0xFF6C47C2),
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    label: 'Tạm ngừng hoạt động',
                    subtitle: 'Hồ sơ của bạn sẽ ẩn khỏi danh sách tìm kiếm',
                    color: const Color(0xFFFFA500),
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    label: 'Xóa tài khoản',
                    subtitle: 'Hành động này không thể hoàn tác',
                    color: const Color(0xFFDC3545),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Column(children: children),
    );
  }

  Widget _buildAccountRow({
    required String label,
    required String value,
    bool verified = false,
    IconData? statusIcon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            if (verified || statusIcon != null) ...[
              const SizedBox(width: 6),
              Icon(
                statusIcon ?? Icons.verified,
                color: const Color(0xFF28A745),
                size: 18,
              ),
            ],
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleRow(String day) {
    final enabled = _scheduleEnabled[day] ?? false;
    final time = _scheduleTimes[day] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ),
          if (enabled && time.isNotEmpty) ...[
            Text(
              time,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6C47C2),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Switch(
            value: enabled,
            onChanged: (value) {
              setState(() {
                _scheduleEnabled[day] = value;
              });
            },
            activeColor: const Color(0xFF6C47C2),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow({
    required String title,
    required String subtitle,
    required String amount,
    bool editable = false,
    bool info = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6C47C2),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            editable ? Icons.edit : Icons.info,
            color: Colors.grey[400],
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6C47C2),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleRow({
    required String label,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ),
            if (icon != null) ...[
              Icon(icon, color: Colors.grey[400], size: 20),
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    String? subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
