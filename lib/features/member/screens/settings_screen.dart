import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/repository/auth_repository.dart';
import 'member_contact_support_screen.dart';
import 'member_faq_screen.dart';
/// Settings Screen - App settings and preferences
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          // Top App Bar
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 56,
                child: Stack(
                  children: [
                    Positioned(
                      left: 4,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFF1F1F1F),
                          size: 20,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'Cài Đặt',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                _buildSectionHeader('Thông báo'),
                _buildNotificationToggle(),
                
                const SizedBox(height: 28),
                
                _buildSectionHeader('Chính sách & Hỗ trợ'),
                _buildPolicyList(),
                
                const SizedBox(height: 32),
                
                // Logout Button
                Center(
                  child: TextButton.icon(
                    onPressed: _showLogoutDialog,
                    icon: const Icon(
                      Icons.logout,
                      size: 20,
                      color: Color(0xFFE53935),
                    ),
                    label: const Text(
                      'Đăng xuất',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE53935),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color(0xFFE53935).withOpacity(0.08),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Phiên bản 1.0.0',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[400],
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF888888),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: SwitchListTile(
          value: _pushNotificationsEnabled,
          onChanged: (value) {
            setState(() {
              _pushNotificationsEnabled = value;
            });
          },
          activeColor: const Color(0xFF228B22),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: const Text(
            'Thông báo đẩy',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F1F1F),
            ),
          ),
          subtitle: const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Nhận thông báo về tiến độ xử lý yêu cầu, tin nhắn, và cảnh báo khẩn cấp',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF666666),
                height: 1.4,
              ),
            ),
          ),
          secondary: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF228B22).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active,
              color: Color(0xFF228B22),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPolicyItem(
            icon: Icons.menu_book_rounded,
            iconColor: const Color(0xFF2196F3),
            title: 'Hướng dẫn sử dụng',
            subtitle: 'Cách dùng các tính năng',
            onTap: _showUserGuide,
          ),
          const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFEEEEEE)),
          _buildPolicyItem(
            icon: Icons.shield_rounded,
            iconColor: const Color(0xFFFF8F00),
            title: 'Chính sách bảo mật',
            subtitle: 'Bảo vệ thông tin cá nhân',
            onTap: _showPrivacyPolicy,
          ),
          const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFEEEEEE)),
          _buildPolicyItem(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: const Color(0xFF228B22),
            title: 'Chính sách thanh toán',
            subtitle: 'Quy định giao dịch, nạp/rút tiền',
            onTap: _showPaymentPolicy,
          ),
          const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFEEEEEE)),
          _buildPolicyItem(
            icon: Icons.help_outline_rounded,
            iconColor: const Color(0xFF673AB7),
            title: 'Câu hỏi thường gặp',
            subtitle: 'Giải đáp thắc mắc phổ biến',
            onTap: _showFaq,
          ),
          const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFEEEEEE)),
          _buildPolicyItem(
            icon: Icons.support_agent_rounded,
            iconColor: const Color(0xFFE91E63),
            title: 'Liên hệ hỗ trợ',
            subtitle: 'Gửi yêu cầu trợ giúp trực tiếp',
            onTap: _showContactSupport,
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFCCCCCC),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPolicySheet(
        'Hướng dẫn sử dụng',
        Icons.menu_book_rounded,
        const Color(0xFF2196F3),
        [
          _buildGuideCard(
            icon: Icons.sos_rounded,
            iconColor: const Color(0xFFE53935),
            title: 'Cấp cứu rắn cắn (SOS)',
            description: 'Hỗ trợ y tế khẩn cấp cho người bị rắn cắn.',
            bulletPoints: [
              'Chỉ hỗ trợ khu vực: Tp.HCM, Thủ Đức, Bình Dương, Đồng Nai, Vũng Tàu.',
              'Nhấn nút SOS > Cung cấp hình ảnh/mô tả tình trạng.',
              'Đội ngũ y tế / chuyên gia sẽ liên hệ hoặc đến hỗ trợ ngay lập tức.',
            ],
          ),
          _buildGuideCard(
            icon: Icons.catching_pokemon_rounded,
            iconColor: const Color(0xFFFF8F00),
            title: 'Yêu cầu bắt rắn',
            description: 'Gọi chuyên gia đến bắt rắn an toàn tại nhà.',
            bulletPoints: [
              'Chỉ hỗ trợ khu vực: Tp.HCM, Thủ Đức, Bình Dương, Đồng Nai, Vũng Tàu.',
              'Nhấn "Cần bắt rắn" > Chọn vị trí > Điền thông tin.',
              'Chuyên gia gần nhất sẽ nhận đơn và di chuyển đến vị trí của bạn.',
            ],
          ),
          _buildGuideCard(
            icon: Icons.support_agent_rounded,
            iconColor: const Color(0xFF2196F3),
            title: 'Tư vấn khẩn cấp & Tư vấn ngay',
            description: 'Liên hệ trực tiếp với chuyên gia mọi lúc mọi nơi.',
            bulletPoints: [
              'Nhận lời khuyên xử lý khi gặp rắn hoặc cần xác định loài rắn.',
              'Hỗ trợ qua gọi điện, nhắn tin trực tiếp.',
            ],
          ),
          _buildGuideCard(
            icon: Icons.map_rounded,
            iconColor: const Color(0xFF8E24AA),
            title: 'Báo cáo cộng đồng',
            description: 'Chung tay xây dựng bản đồ an toàn.',
            bulletPoints: [
              'Đánh dấu vị trí bạn nhìn thấy rắn.',
              'Cảnh báo những người dùng khác trong khu vực để họ đề phòng.',
            ],
          ),
          _buildGuideCard(
            icon: Icons.library_books_rounded,
            iconColor: const Color(0xFF228B22),
            title: 'Thư viện & Sơ cứu',
            description: 'Kiến thức an toàn thiết yếu.',
            bulletPoints: [
              'Tra cứu đặc điểm nhận dạng của các loài rắn phổ biến.',
              'Xem hướng dẫn sơ cứu chuẩn y tế khi bị rắn cắn.',
            ],
          ),
          _buildGuideCard(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: const Color(0xFF00897B),
            title: 'Nạp/Rút tiền',
            description: 'Quản lý ví SnakeAidPay.',
            bulletPoints: [
              'Nạp tiền: Mở "Hồ sơ" > "Nạp tiền" > Chuyển khoản theo cú pháp.',
              'Rút tiền: Mở "Hồ sơ" > "Rút tiền" > Nhập tài khoản > Hệ thống sẽ duyệt tự động.',
            ],
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPolicySheet(
        'Chính sách bảo mật',
        Icons.shield_rounded,
        const Color(0xFFFF8F00),
        [
          _buildPolicySection(
            'Cam kết chung',
            'SnakeAid cam kết bảo vệ tuyệt đối thông tin cá nhân và dữ liệu vị trí của người dùng. Mọi dữ liệu thu thập chỉ phục vụ cho một mục đích duy nhất: điều phối chuyên gia và đội cứu hộ nhanh nhất có thể.',
          ),
          _buildPolicySection(
            'Quyền truy cập vị trí',
            'Thông tin vị trí chỉ được thu thập khi bạn chủ động sử dụng các tính năng liên quan đến bản đồ (như Báo cáo cộng đồng) và các tính năng yêu cầu cứu hộ khẩn cấp (SOS/Bắt rắn).',
          ),
          _buildPolicySection(
            'Bảo mật thông tin',
            'Dữ liệu cá nhân của bạn sẽ không bao giờ được chia sẻ cho bất kỳ bên thứ ba nào vì mục đích thương mại hay quảng cáo.',
          ),
        ],
      ),
    );
  }

  void _showPaymentPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPolicySheet(
        'Chính sách thanh toán',
        Icons.account_balance_wallet_rounded,
        const Color(0xFF228B22),
        [
          _buildPolicySection(
            '1. Thanh toán đặt cọc',
            'Dịch vụ Bắt rắn sẽ yêu cầu bạn thanh toán một khoản đặt cọc nhỏ thông qua ví SnakeAidPay trước khi chuyên gia xuất phát. Việc này giúp hệ thống hạn chế các đơn yêu cầu giả mạo.\n\nĐặc biệt: Số tiền này sẽ được hoàn trả đầy đủ vào ví của bạn nếu chuyên gia không đến hoặc đơn bị hủy bởi hệ thống.',
          ),
          _buildPolicySection(
            '2. Phí dịch vụ chuyên gia',
            'Phí dịch vụ cuối cùng được tính toán tự động dựa trên:\n• Mức độ nguy hiểm của loài rắn\n• Thời gian xử lý\n• Quãng đường di chuyển của chuyên gia',
          ),
          _buildPolicySection(
            '3. Nạp và Rút tiền',
            'Số dư trong ví SnakeAidPay là của bạn. Bạn hoàn toàn có thể rút về tài khoản ngân hàng cá nhân bất kỳ lúc nào với các hạn mức quy định theo từng hạng thành viên của ứng dụng.',
          ),
        ],
      ),
    );
  }

  void _showFaq() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MemberFaqScreen()),
    );
  }

  void _showContactSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MemberContactSupportScreen()),
    );
  }

  Widget _buildPolicySheet(String title, IconData titleIcon, Color titleColor, List<Widget> children) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF9F9F9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: titleColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(titleIcon, color: titleColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF228B22), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF555555),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required List<String> bulletPoints,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          // Body
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAFA),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Column(
              children: bulletPoints.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle, size: 6, color: Color(0xFFCCCCCC)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        point,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF444444),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Đăng xuất',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F1F1F),
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
                builder: (dialogContext) => WillPopScope(
                  onWillPop: () async => false,
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF228B22)),
                  ),
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
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
