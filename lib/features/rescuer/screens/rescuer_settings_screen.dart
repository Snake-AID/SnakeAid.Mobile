import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/repository/auth_repository.dart';
import 'rescuer_user_guide_screen.dart';
import 'rescuer_contact_support_screen.dart';
import 'rescuer_faq_screen.dart';

class RescuerSettingsScreen extends ConsumerStatefulWidget {
  const RescuerSettingsScreen({super.key});

  @override
  ConsumerState<RescuerSettingsScreen> createState() =>
      _RescuerSettingsScreenState();
}

class _RescuerSettingsScreenState extends ConsumerState<RescuerSettingsScreen> {
  // Work Mode Settings
  bool _autoOnline = true;

  // Notification Settings
  bool _pushNotifications = true;
  bool _sosReadAloud = true;
  bool _catchingReadAloud = true;
  bool _vibration = true;
  final String _notificationSound = 'Nam';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoOnline = prefs.getBool('rescuer_autoOnline') ?? true;
      _pushNotifications = prefs.getBool('rescuer_pushNotifications') ?? true;
      _sosReadAloud = prefs.getBool('rescuer_sosReadAloud') ?? true;
      _catchingReadAloud = prefs.getBool('rescuer_catchingReadAloud') ?? true;
      _vibration = prefs.getBool('rescuer_vibration') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rescuer_autoOnline', _autoOnline);
    await prefs.setBool('rescuer_pushNotifications', _pushNotifications);
    await prefs.setBool('rescuer_sosReadAloud', _sosReadAloud);
    await prefs.setBool('rescuer_catchingReadAloud', _catchingReadAloud);
    await prefs.setBool('rescuer_vibration', _vibration);
  }

  Future<void> _setSettingAndSave(void Function() updateState) async {
    setState(() {
      updateState();
    });
    await _saveSettings();
  }

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
          _buildWorkModeSection(),
          const SizedBox(height: 16),
          _buildNotificationSection(),
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
                      style: TextStyle(fontSize: 15, color: Color(0xFF666666)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
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
            style: const TextStyle(fontSize: 15, color: Color(0xFF666666)),
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
                (value) => _setSettingAndSave(() => _autoOnline = value),
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
                (value) => _setSettingAndSave(() => _pushNotifications = value),
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildSwitchRow(
                'Âm thanh đọc yêu cầu rắn cắn',
                _sosReadAloud,
                (value) => _setSettingAndSave(() => _sosReadAloud = value),
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildSwitchRow(
                'Âm thanh đọc yêu cầu bắt rắn',
                _catchingReadAloud,
                (value) => _setSettingAndSave(() => _catchingReadAloud = value),
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildDropdownRow('Giọng nói', _notificationSound),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildSwitchRow(
                'Rung',
                _vibration,
                (value) => _setSettingAndSave(() => _vibration = value),
              ),
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
              _buildNavigationRow('Hướng dẫn sử dụng', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RescuerUserGuideScreen(),
                  ),
                );
              }),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildNavigationRow('Liên hệ hỗ trợ', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RescuerContactSupportScreen(),
                  ),
                );
              }),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              _buildNavigationRow('Câu hỏi thường gặp', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RescuerFaqScreen()),
                );
              }),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          'SnakeAid Rescuer v1.0.0 (Build 2025.12.25)',
          style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
        ),
      ],
    );
  }

  Widget _buildSwitchRow(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Color(0xFF231A0F)),
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFFFF8800),
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
                  activeThumbColor: const Color(0xFFFF8800),
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
            style: const TextStyle(fontSize: 15, color: Color(0xFF231A0F)),
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
              const Icon(Icons.arrow_drop_down, color: Color(0xFF666666)),
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
              style: const TextStyle(fontSize: 15, color: Color(0xFF231A0F)),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF999999)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Đăng xuất',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        content: const Text(
          'Bạn có chắc muốn đăng xuất khỏi tài khoản?',
          style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
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
              // Lấy navigator và router trước khi async operations
              final navigator = Navigator.of(context);
              final router = GoRouter.of(context);

              // Đóng dialog xác nhận
              navigator.pop();

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF8800)),
                ),
              );

              try {
                // Call logout API
                final authRepository = ref.read(authRepositoryProvider);
                await authRepository.logout();

                // Navigate sử dụng router đã lấy trước đó
                router.go('/role-selection');
              } catch (e) {
                // Close loading dialog nếu có lỗi
                if (mounted) {
                  navigator.pop();

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
