import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'edit_profile_screen.dart';
import '../models/member_profile.dart';
import '../repository/member_profile_repository.dart';
import 'payment_history_screen.dart';
import 'medical_records_screen.dart';
import 'id_documents_screen.dart';
import 'deposit_money_screen.dart';
import 'withdraw_money_screen.dart';
import 'wallet_history_screen.dart';
import 'settings_screen.dart';
import '../../auth/repository/auth_repository.dart';
import '../../wallet/repository/wallet_repository.dart';

/// Member Profile Screen
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  WalletInfo? _walletInfo;
  bool _isLoadingWallet = true;
  bool _isRefreshingWallet = false;
  Timer? _walletRefreshTimer;
  MemberProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadWallet();
    _walletRefreshTimer = Timer.periodic(const Duration(minutes: 3), (_) {
      _silentRefreshWallet();
    });
  }

  @override
  void dispose() {
    _walletRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    try {
      final profile = await ref
          .read(memberProfileRepositoryProvider)
          .getMyProfile();
      if (mounted) setState(() => _profile = profile);
    } catch (_) {}
  }

  Future<void> _loadWallet() async {
    try {
      final wallet = await ref.read(walletRepositoryProvider).getWalletInfo();
      if (mounted)
        setState(() {
          _walletInfo = wallet;
          _isLoadingWallet = false;
        });
    } catch (_) {
      if (mounted) setState(() => _isLoadingWallet = false);
    }
  }

  Future<void> _silentRefreshWallet() async {
    try {
      final wallet = await ref.read(walletRepositoryProvider).getWalletInfo();
      if (mounted) setState(() => _walletInfo = wallet);
    } catch (_) {}
  }

  Future<void> _refreshWalletOnTap() async {
    if (_isRefreshingWallet) return;
    setState(() => _isRefreshingWallet = true);
    try {
      final wallet = await ref.read(walletRepositoryProvider).getWalletInfo();
      if (mounted)
        setState(() {
          _walletInfo = wallet;
          _isRefreshingWallet = false;
        });
    } catch (_) {
      if (mounted) setState(() => _isRefreshingWallet = false);
    }
  }

  Future<void> _refreshProfile() async {
    await Future.wait([_loadUserInfo(), _loadWallet()]);
  }

  Color _reputationColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'excellent':
        return const Color(0xFFFFB300);
      case 'good':
        return const Color(0xFF10B981);
      case 'fair':
        return const Color(0xFFFF8800);
      case 'poor':
      case 'bad':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _translateReputationStatus(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
        return 'Xuất Sắc';
      case 'good':
        return 'Tốt';
      case 'fair':
        return 'Trung Bình';
      case 'poor':
        return 'Kém';
      case 'bad':
        return 'Xấu';
      default:
        return status;
    }
  }

  String _formatBalance(double amount) {
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return '$formatted đ';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Bar
        Container(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      'Hồ Sơ Cá Nhân',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: Color(0xFF1F1F1F),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Content
        Expanded(
          child: Container(
            color: Colors.white,
            child: RefreshIndicator(
              color: const Color(0xFF228B22),
              onRefresh: _refreshProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Profile Header Card
                    Container(
                      padding: const EdgeInsets.all(24),
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
                          // Avatar
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 2,
                              ),
                              image: DecorationImage(
                                image: NetworkImage(
                                  _profile?.avatarUrl?.isNotEmpty == true
                                      ? _profile!.avatarUrl!
                                      : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_profile?.fullName ?? 'User')}&background=228B22&color=fff&size=200',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Name
                          Text(
                            _profile?.fullName ?? '---',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F1F1F),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Active Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: (_profile?.isActive ?? true)
                                  ? const Color(0xFF228B22).withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  (_profile?.isActive ?? true)
                                      ? Icons.verified
                                      : Icons.cancel_outlined,
                                  size: 16,
                                  color: (_profile?.isActive ?? true)
                                      ? const Color(0xFF228B22)
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  (_profile?.isActive ?? true)
                                      ? 'Tài khoản đã xác minh'
                                      : 'Tài khoản chưa xác minh',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: (_profile?.isActive ?? true)
                                        ? const Color(0xFF228B22)
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Edit Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const EditProfileScreen(),
                                      ),
                                    )
                                    .then((_) => _refreshProfile());
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF228B22),
                                  width: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Chỉnh Sửa Hồ Sơ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF228B22),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info Card: reputation
                    Container(
                      padding: const EdgeInsets.all(20),
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
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.workspace_premium_rounded,
                                    size: 20,
                                    color: _reputationColor(
                                      _profile?.reputationStatus,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_profile?.reputationPoints ?? 0}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: _reputationColor(
                                        _profile?.reputationStatus,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if (_profile?.reputationStatus != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _reputationColor(
                                      _profile?.reputationStatus,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _translateReputationStatus(
                                      _profile!.reputationStatus!,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  'Uy tín',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                            ],
                          ),
                          // Has Underlying Disease
                          if (_profile?.hasUnderlyingDisease == true) ...[
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.medical_services,
                                  size: 16,
                                  color: Color(0xFFD32F2F),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Có bệnh nền',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFD32F2F),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Emergency Contacts Card
                    if (_profile != null &&
                        _profile!.emergencyContacts.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Liên Lạc Khẩn Cấp',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F1F1F),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ..._profile!.emergencyContacts.map(
                              (c) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.phone_in_talk,
                                      size: 16,
                                      color: Color(0xFF228B22),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      c,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // SnakeAidPay Wallet Card
                    GestureDetector(
                      onTap: _refreshWalletOnTap,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF228B22), Color(0xFF1a6b1a)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF228B22).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Ví SnakeAidPay',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Số dư',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _isLoadingWallet || _isRefreshingWallet
                                ? const SizedBox(
                                    height: 40,
                                    child: Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ),
                                  )
                                : Text(
                                    _formatBalance(_walletInfo?.balance ?? 0),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const DepositMoneyScreen(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      size: 20,
                                    ),
                                    label: const Text('Nạp tiền'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF228B22),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const WithdrawMoneyScreen(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      size: 20,
                                    ),
                                    label: const Text('Rút tiền'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const WalletHistoryScreen(),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(
                                      color: Colors.white70,
                                      width: 1.5,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Icon(Icons.history, size: 20),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    _MenuItem(
                      icon: Icons.wallet,
                      title: 'Lịch Sử Thanh Toán',
                      subtitle: '',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PaymentHistoryScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _MenuItem(
                      icon: Icons.health_and_safety_outlined,
                      title: 'Hướng dẫn sơ cứu',
                      subtitle: '',
                      onTap: () {
                        context.push('/snake-first-aid-guide');
                      },
                    ),
                    const SizedBox(height: 8),
                    _MenuItem(
                      icon: Icons.menu_book_outlined,
                      title: 'Thư viện loài rắn',
                      subtitle: '',
                      onTap: () {
                        context.push('/snake-species');
                      },
                    ),
                    const SizedBox(height: 8),
                    _MenuItem(
                      icon: Icons.warning_amber_rounded,
                      title: 'Cảnh báo khu vực',
                      subtitle: '',
                      onTap: () {
                        context.pushNamed('community_alert_map');
                      },
                    ),
                    const SizedBox(height: 24),

                    const SizedBox(height: 24), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF228B22).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF228B22), size: 24),
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
                  const SizedBox(height: 2),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }
}
