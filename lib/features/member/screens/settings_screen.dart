import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/repository/auth_repository.dart';

/// Settings Screen - App settings and preferences
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _emergencyAlertsEnabled = true;
  bool _appUpdatesEnabled = false;
  bool _shareLocationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Top App Bar
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 56,
                child: Stack(
                  children: [
                    // Back button
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFF333333),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    // Title - centered
                    const Center(
                      child: Text(
                        'Cài Đặt',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // Tài Khoản Section
                  _SectionHeader(title: 'Tài Khoản'),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _SettingsItem(
                          icon: Icons.person_outline,
                          title: 'Chỉnh sửa hồ sơ',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Chỉnh sửa hồ sơ - Đang phát triển')),
                            );
                          },
                        ),
                        Divider(height: 1, indent: 56, color: Colors.grey.shade200),
                        _SettingsItem(
                          icon: Icons.lock_outline,
                          title: 'Đổi mật khẩu',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đổi mật khẩu - Đang phát triển')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Thông Báo Section
                  _SectionHeader(title: 'Thông Báo'),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _SettingsSwitchItem(
                          icon: Icons.notifications_active_outlined,
                          title: 'Cảnh báo khẩn cấp',
                          value: _emergencyAlertsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _emergencyAlertsEnabled = value;
                            });
                          },
                        ),
                        Divider(height: 1, indent: 56, color: Colors.grey.shade200),
                        _SettingsSwitchItem(
                          icon: Icons.campaign_outlined,
                          title: 'Cập nhật ứng dụng',
                          value: _appUpdatesEnabled,
                          onChanged: (value) {
                            setState(() {
                              _appUpdatesEnabled = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Vị Trí Section
                  _SectionHeader(title: 'Vị Trí'),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _SettingsItem(
                          icon: Icons.location_on_outlined,
                          title: 'Dịch vụ định vị',
                          trailing: const Icon(
                            Icons.open_in_new,
                            size: 20,
                            color: Color(0xFF888888),
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Dịch vụ định vị - Đang phát triển')),
                            );
                          },
                        ),
                        Divider(height: 1, indent: 56, color: Colors.grey.shade200),
                        _SettingsSwitchItem(
                          icon: Icons.my_location_outlined,
                          title: 'Chia sẻ khi khẩn cấp',
                          value: _shareLocationEnabled,
                          onChanged: (value) {
                            setState(() {
                              _shareLocationEnabled = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quyền Riêng Tư Section
                  _SectionHeader(title: 'Quyền Riêng Tư'),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _SettingsItem(
                          icon: Icons.shield_outlined,
                          title: 'Chính sách bảo mật',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Chính sách bảo mật - Đang phát triển')),
                            );
                          },
                        ),
                        Divider(height: 1, indent: 56, color: Colors.grey.shade200),
                        _SettingsItem(
                          icon: Icons.gavel_outlined,
                          title: 'Điều khoản dịch vụ',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Điều khoản dịch vụ - Đang phát triển')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tùy Chọn Ứng Dụng Section
                  _SectionHeader(title: 'Tùy Chọn Ứng Dụng'),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _SettingsItem(
                          icon: Icons.language_outlined,
                          title: 'Ngôn ngữ',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Tiếng Việt',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF888888),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right,
                                size: 20,
                                color: Color(0xFF888888),
                              ),
                            ],
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ngôn ngữ - Đang phát triển')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Account Actions Section
                  _SectionHeader(title: 'Tài Khoản'),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _SettingsItem(
                          icon: Icons.logout,
                          title: 'Đăng xuất',
                          titleColor: const Color(0xFF228B22),
                          iconColor: const Color(0xFF228B22),
                          onTap: () {
                            _showLogoutDialog();
                          },
                        ),
                        Divider(height: 1, indent: 56, color: Colors.grey.shade200),
                        _SettingsItem(
                          icon: Icons.delete_outline,
                          title: 'Xóa tài khoản',
                          titleColor: const Color(0xFFD32F2F),
                          iconColor: const Color(0xFFD32F2F),
                          onTap: () {
                            _showDeleteAccountDialog();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Footer
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: const Text(
                        'SnakeAid phiên bản 1.0.0',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Xóa bộ nhớ đệm',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        content: const Text(
          'Bạn có chắc muốn xóa toàn bộ bộ nhớ đệm? Điều này sẽ giải phóng dung lượng nhưng có thể làm chậm ứng dụng lần đầu sử dụng lại.',
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
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa bộ nhớ đệm')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF228B22),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Xóa'),
          ),
        ],
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
              // Lấy navigator và router trước khi async operations
              final navigator = Navigator.of(context);
              final router = GoRouter.of(context);
              
              // Đóng dialog xác nhận
              navigator.pop();
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => WillPopScope(
                  onWillPop: () async => false,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF228B22),
                    ),
                  ),
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
              backgroundColor: const Color(0xFF228B22),
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

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Xóa tài khoản',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFD32F2F),
          ),
        ),
        content: const Text(
          'Cảnh báo: Hành động này không thể hoàn tác! Tất cả dữ liệu của bạn sẽ bị xóa vĩnh viễn.\n\nBạn có chắc chắn muốn xóa tài khoản?',
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
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Xóa tài khoản - Đang phát triển'),
                  backgroundColor: Color(0xFFD32F2F),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

// Section Header Widget
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF666666),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
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
        children: children,
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? titleColor;
  final Color? iconColor;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor?.withOpacity(0.1) ?? const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor ?? const Color(0xFF228B22),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: titleColor ?? const Color(0xFF333333),
                ),
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Color(0xFFBBBBBB),
                ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF228B22),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF333333),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF228B22),
          ),
        ],
      ),
    );
  }
}
