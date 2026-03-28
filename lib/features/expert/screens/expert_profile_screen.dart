import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../consultation/repository/consultation_repository.dart';

/// Expert Profile Screen - Personal information and statistics for expert
class ExpertProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback? onGoToHistory;
  const ExpertProfileScreen({super.key, this.onGoToHistory});

  @override
  ConsumerState<ExpertProfileScreen> createState() => _ExpertProfileScreenState();
}

class _ExpertProfileScreenState extends ConsumerState<ExpertProfileScreen> {
  bool _isLoadingWallet = true;
  double? _walletBalance;
  String? _walletError;

  @override
  void initState() {
    super.initState();
    _loadWalletBalance();
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
        _walletError = 'Không thể tải số dư ví';
        _isLoadingWallet = false;
      });
    }
  }

  String _formatCurrency(double value) {
    final number = value.toInt();
    final formatted = number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$formatted VNĐ';
  }

  Future<void> _refreshProfile() async {
    await _loadWalletBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6F8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Hồ Sơ Chuyên Gia',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF6C47C2)),
            onPressed: () {
              context.pushNamed('expert_settings');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF6C47C2),
        onRefresh: _refreshProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                // Profile Card
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: _buildProfileCard(),
                ),

                // Activity Stats
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 16, 12),
                  child: const Text(
                    'Thống Kê Hoạt Động',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.verified_user,
                          value: '234',
                          label: 'Xác Minh\nHoàn Tất',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.chat_bubble,
                          value: '189',
                          label: 'Ca Tư Vấn',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.psychology,
                          value: '567',
                          label: 'Đóng Góp AI',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Revenue Summary
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildRevenueSummary(),
                ),
                const SizedBox(height: 20),

                // Menu List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.history_edu,
                        title: 'Lịch Sử Tư Vấn',
                        onTap: () {
                          if (widget.onGoToHistory != null) {
                            widget.onGoToHistory!();
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.payments,
                        title: 'Quản Lý Doanh Thu',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.star,
                        title: 'Đánh Giá & Phản Hồi',
                        onTap: () {
                          context.pushNamed('expert_feedback');
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.workspace_premium,
                        title: 'Chứng Chỉ & Bằng Cấp',
                        onTap: () {
                          context.pushNamed('expert_id_documents');
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.psychology_alt,
                        title: 'Chuyên Môn & Lĩnh Vực',
                        onTap: () {
                          context.pushNamed('expert_specialties');
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.calendar_month,
                        title: 'Cài Đặt Lịch Làm Việc',
                        onTap: () {
                          context.push('/expert-working-hours');
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.settings,
                        title: 'Cài Đặt',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6C47C2).withOpacity(0.1),
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Color(0xFF6C47C2),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C47C2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.photo_camera,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name & Badge
          const Text(
            'TS. Nguyễn Văn A',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6C47C2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Color(0xFF6C47C2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'CHUYÊN GIA ĐÃ XÁC MINH',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C47C2),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tags
          const Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _SpecialtyTag(label: 'Rắn Độc'),
              _SpecialtyTag(label: 'Huyết Thanh'),
              _SpecialtyTag(label: 'Y Khoa'),
            ],
          ),
          const SizedBox(height: 16),

          // Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.star,
                color: Color(0xFFFFA500),
                size: 20,
              ),
              const SizedBox(width: 6),
              const Text(
                '4.9',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(125 đánh giá)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Join Date
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_month,
                size: 16,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 6),
              Text(
                'Thành viên từ tháng 3/2024',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () {
                context.pushNamed('expert_edit_profile');
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF6C47C2), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: const Color(0xFF6C47C2),
                overlayColor: const Color(0xFF6C47C2).withOpacity(0.1),
              ),
              child: const Text(
                'Chỉnh Sửa Hồ Sơ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C47C2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6C47C2).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6C47C2),
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6C47C2),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueSummary() {
    final balanceText = _isLoadingWallet
        ? 'Đang tải...'
        : (_walletError ?? _formatCurrency(_walletBalance ?? 0));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ví SnakeAidPay',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C47C2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 14,
                      color: Color(0xFF6C47C2),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Số dư',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C47C2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            balanceText,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: _walletError == null
                  ? const Color(0xFF6C47C2)
                  : const Color(0xFFDC3545),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _walletError == null
                ? 'Số dư khả dụng hiện tại của chuyên gia'
                : 'Vui lòng thử lại để cập nhật số dư ví',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _loadWalletBalance,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Color(0xFF6C47C2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Làm Mới Số Dư Ví',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C47C2),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.refresh,
                    size: 18,
                    color: Color(0xFF6C47C2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C47C2).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF6C47C2),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[300],
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

}

// Specialty Tag Widget
class _SpecialtyTag extends StatelessWidget {
  final String label;

  const _SpecialtyTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6C47C2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6C47C2),
        ),
      ),
    );
  }
}
