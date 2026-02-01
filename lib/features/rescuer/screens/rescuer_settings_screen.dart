import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/repository/auth_repository.dart';

class RescuerSettingsScreen extends ConsumerStatefulWidget {
  const RescuerSettingsScreen({super.key});

  @override
  ConsumerState<RescuerSettingsScreen> createState() => _RescuerSettingsScreenState();
}

class _RescuerSettingsScreenState extends ConsumerState<RescuerSettingsScreen> {
  // Work Mode Settings
  bool _autoOnline = true;
  bool _autoAcceptNearby = false;
  double _requestRadius = 20.0;
  int _maxConcurrentRequests = 3;
  bool _workHoursOnly = false;

  // Notification Settings
  bool _pushNotifications = true;
  bool _customerMessages = true;
  bool _expertMessages = false;
  bool _paymentNotifications = true;
  bool _equipmentReminders = true;
  bool _reviewNotifications = false;
  bool _vibration = true;
  String _notificationSound = 'Urgent';

  // Map Settings
  String _mapProvider = 'Google Maps';
  bool _showTraffic = true;
  bool _avoidHighways = false;
  bool _avoidTollRoads = true;
  String _voiceLanguage = 'Tiếng Việt';

  @override
  Widget build(BuildContext context) {
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
          'Cài Đặt',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF231A0F),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAccountSection(),
          const SizedBox(height: 16),
          _buildWorkModeSection(),
          const SizedBox(height: 16),
          _buildNotificationSection(),
          const SizedBox(height: 16),
          _buildMapSection(),
          const SizedBox(height: 16),
          _buildSupportSection(),
          const SizedBox(height: 24),
          _buildAccountActions(),
          const SizedBox(height: 16),
          _buildFooter(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            'Tài Khoản',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF231A0F),
            ),
          ),
        ),
        Container(
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
              _buildAccountRow(
                'Số Điện Thoại',
                '+84 987 654 321',
                trailing: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF28A745),
                  size: 20,
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildAccountRow('Email', 'rescuer@example.com'),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildAccountRow(
                'Mật Khẩu',
                '********',
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Đổi',
                    style: TextStyle(
                      color: Color(0xFF007AFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Trạng thái',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF666666),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF28A745).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Đã xác minh',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF28A745),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountRow(String label, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF666666),
            ),
          ),
          Row(
            children: [
              if (trailing == null)
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF231A0F),
                  ),
                ),
              if (trailing != null) trailing,
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkModeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            'Chế độ Làm Việc',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF231A0F),
            ),
          ),
        ),
        Container(
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
              _buildSwitchRow(
                'Chế độ Online tự động khi mở app',
                _autoOnline,
                (value) => setState(() => _autoOnline = value),
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildSwitchRow(
                'Tự động chấp nhận yêu cầu gần (<1km)',
                _autoAcceptNearby,
                (value) => setState(() => _autoAcceptNearby = value),
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bán kính nhận yêu cầu',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF231A0F),
                          ),
                        ),
                        Text(
                          '${_requestRadius.toInt()}km',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF8800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 8,
                        activeTrackColor: const Color(0xFFFF8800),
                        inactiveTrackColor: const Color(0xFFE5E5E5),
                        thumbColor: const Color(0xFFFF8800),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                        overlayColor: const Color(0xFFFF8800).withOpacity(0.2),
                      ),
                      child: Slider(
                        value: _requestRadius,
                        min: 5,
                        max: 50,
                        divisions: 9,
                        onChanged: (value) => setState(() => _requestRadius = value),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Số yêu cầu tối đa cùng lúc',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF231A0F),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _maxConcurrentRequests > 1
                              ? () => setState(() => _maxConcurrentRequests--)
                              : null,
                          icon: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.remove, size: 18, color: Color(0xFF666666)),
                          ),
                        ),
                        SizedBox(
                          width: 32,
                          child: Text(
                            '$_maxConcurrentRequests',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF231A0F),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _maxConcurrentRequests < 10
                              ? () => setState(() => _maxConcurrentRequests++)
                              : null,
                          icon: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.add, size: 18, color: Color(0xFF666666)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildSwitchRow(
                'Chỉ nhận yêu cầu trong giờ làm việc',
                _workHoursOnly,
                (value) => setState(() => _workHoursOnly = value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            'Thông Báo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF231A0F),
            ),
          ),
        ),
        Container(
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
              _buildSwitchRow(
                'Thông báo đẩy',
                _pushNotifications,
                (value) => setState(() => _pushNotifications = value),
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildLockedRow('Yêu cầu cứu hộ mới'),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildLockedRow('SOS khẩn cấp', hasRedDot: true),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildSwitchRow(
                'Tin nhắn từ khách hàng',
                _customerMessages,
                (value) => setState(() => _customerMessages = value),
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildSwitchRow(
                'Tin nhắn từ chuyên gia',
                _expertMessages,
                (value) => setState(() => _expertMessages = value),
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildSwitchRow(
                'Thanh toán & thu nhập',
                _paymentNotifications,
                (value) => setState(() => _paymentNotifications = value),
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildSwitchRow(
                'Nhắc nhở bảo dưỡng thiết bị',
                _equipmentReminders,
                (value) => setState(() => _equipmentReminders = value),
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildSwitchRow(
                'Đánh giá mới',
                _reviewNotifications,
                (value) => setState(() => _reviewNotifications = value),
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildDropdownRow('Âm thanh', _notificationSound),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildSwitchRow(
                'Rung',
                _vibration,
                (value) => setState(() => _vibration = value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            'Bản Đồ & Điều Hướng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF231A0F),
            ),
          ),
        ),
        Container(
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
              _buildDropdownRow('Bản đồ', _mapProvider),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildSwitchRow(
                'Hiển thị giao thông real-time',
                _showTraffic,
                (value) => setState(() => _showTraffic = value),
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildSwitchRow(
                'Tránh đường cao tốc',
                _avoidHighways,
                (value) => setState(() => _avoidHighways = value),
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildSwitchRow(
                'Tránh đường thu phí',
                _avoidTollRoads,
                (value) => setState(() => _avoidTollRoads = value),
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildDropdownRow('Giọng nói', _voiceLanguage),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            'Hỗ Trợ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF231A0F),
            ),
          ),
        ),
        Container(
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
              _buildNavigationRow('Hướng dẫn sử dụng', () {}),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildNavigationRow('Liên hệ hỗ trợ', () {}),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildNavigationRow('Báo cáo sự cố', () {}),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildNavigationRow('Câu hỏi thường gặp', () {}),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountActions() {
    return Column(
      children: [
        // Đăng Xuất Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              _showLogoutDialog();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF8800),
              side: const BorderSide(color: Color(0xFFFF8800), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.transparent,
            ),
            child: const Text(
              'Đăng Xuất',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Tạm ngừng hoạt động Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // Show pause confirmation dialog
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF666666),
              side: const BorderSide(color: Color(0xFFCCCCCC), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.transparent,
            ),
            child: const Text(
              'Tạm ngừng hoạt động',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Xóa tài khoản Button
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              // Show delete account warning dialog
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFDC3545),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.transparent,
            ),
            child: const Text(
              'Xóa tài khoản',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          'SnakeAid Rescuer v1.0.2 (Build 2025.12.10)',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF999999),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {},
              child: const Text(
                'Đánh giá ứng dụng',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF007AFF),
                ),
              ),
            ),
            const Text(
              '|',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFCCCCCC),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Chia sẻ',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF007AFF),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwitchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF231A0F),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFF8800),
            activeTrackColor: const Color(0xFFFF8800).withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedRow(String label, {bool hasRedDot = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Opacity(
        opacity: 0.6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF231A0F),
                  ),
                ),
                if (hasRedDot) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC3545),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            Row(
              children: [
                const Icon(Icons.lock, size: 16, color: Color(0xFF999999)),
                const SizedBox(width: 8),
                Switch(
                  value: true,
                  onChanged: null,
                  activeColor: const Color(0xFFFF8800),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF231A0F),
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF231A0F),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF666666),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRow(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF231A0F),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF999999),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Đăng xuất',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        content: const Text(
          'Bạn có chắc muốn đăng xuất khỏi tài khoản?',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Hủy',
              style: TextStyle(color: Color(0xFF888888)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF8800),
                  ),
                ),
              );
              
              try {
                // Call logout API
                final authRepository = ref.read(authRepositoryProvider);
                await authRepository.logout();
                
                if (mounted) {
                  // Close loading dialog
                  Navigator.of(context, rootNavigator: true).pop();
                  
                  // Small delay to ensure dialog is closed
                  await Future.delayed(const Duration(milliseconds: 100));
                  
                  // Navigate to role selection screen using GoRouter
                  if (mounted) {
                    GoRouter.of(context).goNamed('role_selection');
                  }
                }
              } catch (e) {
                if (mounted) {
                  // Close loading dialog
                  Navigator.of(context, rootNavigator: true).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8800),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
