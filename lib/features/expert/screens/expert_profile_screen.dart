import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../wallet/repository/wallet_repository.dart';
import '../../member/screens/withdraw_money_screen.dart';
import '../../member/screens/wallet_history_screen.dart';
import '../../member/screens/payment_history_screen.dart';
import '../models/expert_profile.dart';
import '../repository/expert_profile_repository.dart';

/// Expert Profile Screen - Personal information and statistics for expert
class ExpertProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback? onGoToHistory;
  const ExpertProfileScreen({super.key, this.onGoToHistory});

  @override
  ConsumerState<ExpertProfileScreen> createState() => _ExpertProfileScreenState();
}

class _ExpertProfileScreenState extends ConsumerState<ExpertProfileScreen> {
  WalletInfo? _walletInfo;
  bool _isLoadingWallet = true;
  Timer? _walletRefreshTimer;
  ExpertProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadWallet();
    _walletRefreshTimer = Timer.periodic(const Duration(minutes: 3), (_) => _loadWallet());
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ref.read(expertProfileRepositoryProvider).getMyProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _walletRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadWallet() async {
    try {
      final wallet = await ref.read(walletRepositoryProvider).getWalletInfo();
      if (mounted) setState(() { _walletInfo = wallet; _isLoadingWallet = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoadingWallet = false);
    }
  }

  String _formatBalance(double amount) {
    final f = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return '$f đ';
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Card
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: _buildProfileCard(),
                ),

                // Wallet Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildWalletCard(),
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
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PaymentHistoryScreen(
                              themeColor: Color(0xFF6C47C2),
                              title: 'Quản Lý Doanh Thu',
                              filterTypes: [
                                'consultation',
                                'system',
                              ],
                            ),
                          ),
                        ),
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
                        icon: Icons.document_scanner,
                        title: 'Xem Xét AI Nhận Diện',
                        onTap: () {
                          context.pushNamed('expert_ai_review_queue');
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        icon: Icons.settings,
                        title: 'Cài Đặt',
                        onTap: () {
                          context.pushNamed('expert_settings');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C47C2), Color(0xFF4e2fa3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C47C2).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.account_balance_wallet, color: Colors.white70, size: 20),
            SizedBox(width: 8),
            Text('Ví SnakeAidPay',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ]),
          const SizedBox(height: 16),
          const Text('Số dư',
              style: TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 4),
          if (_isLoadingWallet)
            const SizedBox(
              height: 40,
              child: Center(
                child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white54)),
              ),
            )
          else
            Text(_formatBalance(_walletInfo?.balance ?? 0),
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const WithdrawMoneyScreen(
                                themeColor: Color(0xFF6C47C2),
                              ))),
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  label: const Text('Rút tiền'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const WalletHistoryScreen(
                              themeColor: Color(0xFF6C47C2),
                              showTopup: false,
                            ))),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white70, width: 1.5),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Icon(Icons.history, size: 20),
              ),
            ],
          ),
        ],
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
                child: ClipOval(
                  child: _profile?.avatarUrl?.isNotEmpty == true
                      ? Image.network(
                          _profile!.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person,
                            size: 50,
                            color: Color(0xFF6C47C2),
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 50,
                          color: Color(0xFF6C47C2),
                        ),
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
          Text(
            _profile?.fullName ?? '---',
            style: const TextStyle(
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
                  decoration: BoxDecoration(
                    color: (_profile?.isActive ?? false)
                        ? const Color(0xFF6C47C2)
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    (_profile?.isActive ?? false)
                        ? Icons.check
                        : Icons.close,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  (_profile?.isActive ?? false)
                      ? 'CHUYÊN GIA ĐÃ XÁC MINH'
                      : 'CHƯА XÁC MINH',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: (_profile?.isActive ?? false)
                        ? const Color(0xFF6C47C2)
                        : Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Điểm uy tín
          if (_profile?.reputationPoints != null) ...[  
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _reputationColor(_profile?.reputationStatus).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _reputationColor(_profile?.reputationStatus).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.workspace_premium, size: 16, color: _reputationColor(_profile?.reputationStatus)),
                      const SizedBox(width: 6),
                      Text(
                        '${_profile!.reputationPoints} điểm uy tín',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _reputationColor(_profile?.reputationStatus)),
                      ),
                      if (_profile?.reputationStatus != null) ...[  
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _reputationColor(_profile?.reputationStatus),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _translateReputationStatus(_profile!.reputationStatus!),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Consultation Fees
          if (_profile?.scheduledConsultationFee != null ||
              _profile?.emergencyConsultationFee != null) ...
            [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C47C2).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    if (_profile?.scheduledConsultationFee != null)
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Tư vấn hẹn',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF888888)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_profile!.scheduledConsultationFee!.toStringAsFixed(0)}đ',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6C47C2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_profile?.scheduledConsultationFee != null &&
                        _profile?.emergencyConsultationFee != null)
                      Container(
                        width: 1,
                        height: 32,
                        color: const Color(0xFFDDDDDD),
                      ),
                    if (_profile?.emergencyConsultationFee != null)
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Tư vấn khẩn',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF888888)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_profile!.emergencyConsultationFee!.toStringAsFixed(0)}đ',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6C47C2),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

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
              Text(
                _profile?.rating?.toStringAsFixed(1) ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${_profile?.ratingCount ?? 0} đánh giá)',
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
                _profile?.createdAt != null
                    ? 'Thành viên từ tháng ${_profile!.createdAt!.month}/${_profile!.createdAt!.year}'
                    : 'Thành viên mới',
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
                context.pushNamed('expert_edit_profile').then((_) => _loadProfile());
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

  Color _reputationColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'excellent': return const Color(0xFFFFB300);
      case 'good': return const Color(0xFF10B981);
      case 'fair': return const Color(0xFFFF8800);
      case 'poor':
      case 'bad': return const Color(0xFFE53935);
      default: return const Color(0xFF9E9E9E);
    }
  }

  String _translateReputationStatus(String status) {
    switch (status.toLowerCase()) {
      case 'excellent': return 'Xuất Sắc';
      case 'good': return 'Tốt';
      case 'fair': return 'Trung Bình';
      case 'poor': return 'Kém';
      case 'bad': return 'Xấu';
      default: return status;
    }
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
