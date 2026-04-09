import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/repository/auth_repository.dart';
import '../../consultation/repository/consultation_repository.dart';

/// Expert Settings Screen
class ExpertSettingsScreen extends ConsumerStatefulWidget {
  const ExpertSettingsScreen({super.key});

  @override
  ConsumerState<ExpertSettingsScreen> createState() => _ExpertSettingsScreenState();
}

class _ExpertSettingsScreenState extends ConsumerState<ExpertSettingsScreen> {
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

  // Consultation fee
  double _consultationFee = 300000;
  bool _isSavingFee = false;

  // Biography
  String _biography = '';
  bool _isSavingBio = false;

  // Profile loading
  bool _isLoadingProfile = true;
  bool _isLoadingWallet = true;
  String? _walletError;
  double? _walletBalance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExpertProfile();
      _loadWalletBalance();
    });
  }

  Future<void> _loadWalletBalance() async {
    setState(() {
      _isLoadingWallet = true;
      _walletError = null;
    });

    try {
      final repo = ref.read(consultationRepositoryProvider);
      final wallet = await repo.getMyWallet();
      if (!mounted) return;
      setState(() {
        _walletBalance = (wallet['balance'] as num?)?.toDouble() ?? 0;
        _isLoadingWallet = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingWallet = false;
        _walletError = 'Không thể tải số dư ví';
      });
    }
  }

  String _formatCurrency(double value) {
    final amount = value.round().toString();
    final withSeparator = amount.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$withSeparator VNĐ';
  }

  Future<void> _loadExpertProfile() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (mounted) setState(() => _isLoadingProfile = false);
      return;
    }
    try {
      final repo = ref.read(consultationRepositoryProvider);
      final expert = await repo.getExpertDetail(user.id);
      if (mounted) {
        setState(() {
          _biography = expert.bio ?? '';
          _consultationFee = expert.consultationFee > 0 ? expert.consultationFee : 300000;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _saveBiography(String bio) async {
    setState(() => _isSavingBio = true);
    try {
      final repo = ref.read(consultationRepositoryProvider);
      await repo.updateExpertSettings(biography: bio);
      if (mounted) {
        setState(() => _biography = bio);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật giới thiệu')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingBio = false);
    }
  }

  void _showEditBioDialog() {
    final controller = TextEditingController(text: _biography);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Giới thiệu bản thân',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
        ),
        content: TextField(
          controller: controller,
          maxLines: 5,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Mô tả kinh nghiệm, chuyên môn của bạn...',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF888888))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C47C2),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final text = controller.text.trim();
              Navigator.of(ctx).pop();
              _saveBiography(text);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveConsultationFee(double fee) async {
    setState(() => _isSavingFee = true);
    try {
      final repo = ref.read(consultationRepositoryProvider);
      await repo.updateExpertSettings(consultationFee: fee);
      if (mounted) {
        setState(() => _consultationFee = fee);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật phí tư vấn')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingFee = false);
    }
  }

  void _showEditFeeDialog() {
    final controller = TextEditingController(
      text: _consultationFee.toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Phí tư vấn đặt lịch',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            suffixText: 'VNĐ',
            hintText: 'Nhập phí tư vấn',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF888888))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C47C2),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value == null || value <= 0) return;
              Navigator.of(ctx).pop();
              _saveConsultationFee(value);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
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

            // SECTION 2: Profile
            _buildSectionHeader('Hồ Sơ Tư Vấn'),
            _buildCard(
              children: [
                InkWell(
                  onTap: _showEditBioDialog,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Giới thiệu',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                              const SizedBox(height: 6),
                              _isLoadingProfile
                                  ? const SizedBox(
                                      height: 14,
                                      width: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : _isSavingBio
                                  ? const Text(
                                      'Đang lưu...',
                                      style: TextStyle(fontSize: 13, color: Colors.grey),
                                    )
                                  : Text(
                                      _biography.isEmpty
                                          ? 'Chưa có giới thiệu — nhấn để thêm'
                                          : _biography,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _biography.isEmpty
                                            ? Colors.grey
                                            : const Color(0xFF555555),
                                        height: 1.5,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.edit, color: Colors.grey[400], size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // SECTION 3: Wallet
            _buildSectionHeader('Ví SnakeAid'),
            _buildCard(
              children: [
                Padding(
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
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Color(0xFF6C47C2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Số dư ví hiện tại',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ),
                      if (_isLoadingWallet)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Text(
                          _walletError ?? _formatCurrency(_walletBalance ?? 0),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _walletError != null
                                ? Colors.red
                                : const Color(0xFF16A34A),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                _buildSimpleRow(
                  label: 'Làm mới số dư',
                  icon: Icons.refresh,
                  onTap: _loadWalletBalance,
                ),
              ],
            ),

            // SECTION 4: Consultation Fees
            _buildSectionHeader('Phí Tư Vấn'),
            _buildCard(
              children: [
                _buildFeeRow(
                  title: 'Tư vấn đặt lịch (Patient)',
                  subtitle: 'Bạn nhận: ${((_consultationFee * 0.9)).toStringAsFixed(0)} VNĐ (90%)',
                  amount: _isLoadingProfile
                      ? '...'
                      : _isSavingFee
                          ? 'Đang lưu...'
                          : '${_consultationFee.toStringAsFixed(0)} VNĐ',
                  editable: true,
                  onEdit: _showEditFeeDialog,
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
                    onTap: () {
                      _showLogoutDialog();
                    },
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
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

  Widget _buildFeeRow({
    required String title,
    required String subtitle,
    required String amount,
    bool editable = false,
    bool info = false,
    VoidCallback? onEdit,
  }) {
    return InkWell(
      onTap: editable ? onEdit : null,
      child: Padding(
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                amount,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C47C2),
                ),
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
            activeThumbColor: const Color(0xFF6C47C2),
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                builder: (loadingContext) => const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF6C47C2),
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

