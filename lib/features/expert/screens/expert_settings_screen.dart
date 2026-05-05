import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/repository/auth_repository.dart';
import 'expert_payment_screen.dart';

/// Expert Settings Screen - Minimalist design with only essential settings
class ExpertSettingsScreen extends ConsumerStatefulWidget {
  const ExpertSettingsScreen({super.key});

  @override
  ConsumerState<ExpertSettingsScreen> createState() =>
      _ExpertSettingsScreenState();
}

class _ExpertSettingsScreenState extends ConsumerState<ExpertSettingsScreen> {
  bool _pushNotifications = true;
  bool _consultationRequestNotifications = true;
  bool _autoOnline = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('expert_pushNotifications') ?? true;
      _consultationRequestNotifications =
          prefs.getBool('expert_consultationRequests') ?? true;
      _autoOnline = prefs.getBool('expert_autoOnline') ?? true;
    });
  }

  Future<void> _savePushNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('expert_pushNotifications', value);
    setState(() => _pushNotifications = value);
  }

  Future<void> _saveAutoOnline(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('expert_autoOnline', value);
    setState(() => _autoOnline = value);
  }

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

            // SECTION 2: System
            _buildSectionHeader('Chế Độ Làm Việc'),
            _buildCard(
              children: [
                _buildNotificationRow(
                  title: 'Tự động online khi mở lại app',
                  subtitle: 'Tự động kích hoạt online khi bạn mở lại ứng dụng',
                  value: _autoOnline,
                  onChanged: _saveAutoOnline,
                  isMandatory: false,
                ),
              ],
            ),

            const SizedBox(height: 32),

             // SECTION 1: Notifications
            _buildSectionHeader('Thông Báo'),
            _buildCard(
              children: [
                _buildNotificationRow(
                  title: 'Thông báo đẩy',
                  subtitle: 'Nhận thông báo từ ứng dụng',
                  value: _pushNotifications,
                  onChanged: _savePushNotifications,
                  isMandatory: false,
                ),
                const Divider(height: 1),
                _buildMandatoryNotificationRow(
                  title: 'Yêu cầu tư vấn mới',
                  subtitle: 'Bắt buộc để không bỏ lỡ các yêu cầu',
                ),
              ],
            ),

            const SizedBox(height: 32),

            // SECTION 3: Support & Documentation
            _buildSectionHeader('Hỗ Trợ & Tài Liệu'),
            _buildCard(
              children: [
                _buildSupportLink(
                  icon: Icons.description_outlined,
                  title: 'Hướng dẫn sử dụng',
                  subtitle: 'Cách thức hoạt động của nền tảng',
                  onTap: () {
                    context.pushNamed('expert_user_guide');
                  },
                ),
                const Divider(height: 1),
                _buildSupportLink(
                  icon: Icons.help_outline,
                  title: 'Câu hỏi thường gặp',
                  subtitle: 'Giải đáp những thắc mắc phổ biến',
                  onTap: () {
                    context.pushNamed('expert_faq');
                  },
                ),
                const Divider(height: 1),
                _buildSupportLink(
                  icon: Icons.support_agent,
                  title: 'Liên hệ hỗ trợ',
                  subtitle: 'Nhận trợ giúp nhanh chóng từ đội Expert',
                  onTap: () {
                    context.pushNamed('expert_contact_support');
                  },
                ),
                const Divider(height: 1),
                _buildSupportLink(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Chính sách thanh toán',
                  subtitle: 'Quy định về chi trả và rút tiền',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExpertPaymentScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildSupportLink(
                  icon: Icons.description,
                  title: 'Điều khoản & Điều kiện',
                  subtitle: 'Điều khoản sử dụng dịch vụ',
                  onTap: () {
                    context.pushNamed('expert_terms');
                  },
                ),
                const Divider(height: 1),
                _buildSupportLink(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Chính sách bảo mật',
                  subtitle: 'Cách chúng tôi bảo vệ dữ liệu của bạn',
                  onTap: () {
                    context.pushNamed('expert_privacy');
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // SECTION 3: Account Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showLogoutDialog();
                  },
                  icon: const Icon(Icons.logout, size: 20),
                  label: const Text(
                    'Đăng Xuất',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C47C2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Center(
              child: Text(
                'SnakeAid Expert • v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D2D2D),
        ),
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

  Widget _buildNotificationRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isMandatory,
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
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: isMandatory ? null : onChanged,
            activeThumbColor: const Color(0xFF6C47C2),
          ),
        ],
      ),
    );
  }

  Widget _buildMandatoryNotificationRow({
    required String title,
    required String subtitle,
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
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: true,
            onChanged: null,
            activeThumbColor: const Color(0xFF6C47C2),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportLink({
    required IconData icon,
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF6C47C2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF6C47C2), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey[300], size: 24),
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
              final navigator = Navigator.of(context);
              final router = GoRouter.of(context);

              navigator.pop();

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6C47C2)),
                ),
              );

              try {
                final authRepository = ref.read(authRepositoryProvider);
                await authRepository.logout();

                router.go('/role-selection');
              } catch (e) {
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
              backgroundColor: const Color(0xFF6C47C2),
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
