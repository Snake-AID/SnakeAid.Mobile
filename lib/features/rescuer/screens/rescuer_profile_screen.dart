import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/rescuer_profile.dart';
import '../repository/rescuer_profile_repository.dart';
import '../../member/screens/payment_history_screen.dart';

/// Rescuer Profile Screen - Personal information and statistics for rescuer
class RescuerProfileScreen extends ConsumerStatefulWidget {
  const RescuerProfileScreen({super.key});

  @override
  ConsumerState<RescuerProfileScreen> createState() => _RescuerProfileScreenState();
}

class _RescuerProfileScreenState extends ConsumerState<RescuerProfileScreen> {
  bool _isOnline = false;
  RescuerProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ref.read(rescuerProfileRepositoryProvider).getMyProfile();
      if (mounted && profile != null) {
        setState(() {
          _profile = profile;
          _isOnline = profile.isOnline;
        });
      }
    } catch (_) {}
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Hồ Sơ Cứu Hộ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
      
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF2D2D2D)),
            onPressed: () {
              context.pushNamed('rescuer_settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Card
            _buildProfileCard(),
            const SizedBox(height: 16),

            // Rating Card
            _buildRatingCard(),
            const SizedBox(height: 16),

            // Menu Items
            _buildMenuItem(
              icon: Icons.checklist,
              title: 'Lịch Sử Cứu Hộ',
              subtitle: '${_profile?.completedMissions ?? 0} nhiệm vụ đã hoàn thành',
              onTap: () => context.pushNamed('rescuer_history'),
            ),
           
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.star,
              title: 'Đánh Giá & Phản Hồi',
              subtitle: '${_profile?.ratingCount ?? 0} đánh giá từ khách hàng',
              onTap: () => context.pushNamed('rescuer_feedback'),
            ),
            const SizedBox(height: 16),

            // Vacation Mode
            _buildVacationMode(),
            const SizedBox(height: 32),
          ],
        ),
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

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          // Avatar
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFF6B35),
                width: 4,
              ),
            ),
            child: ClipOval(
              child: _profile?.avatarUrl?.isNotEmpty == true
                  ? Image.network(
                      _profile!.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFFF6B35).withOpacity(0.1),
                        child: const Icon(
                          Icons.person,
                          size: 48,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
                    )
                  : Container(
                      color: const Color(0xFFFF6B35).withOpacity(0.1),
                      child: const Icon(
                        Icons.person,
                        size: 48,
                        color: Color(0xFFFF6B35),
                      ),
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
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 8),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shield,
                  size: 14,
                  color: Color(0xFFFF6B35),
                ),
                SizedBox(width: 6),
                Text(
                  'Cứu Hộ Viên Chuyên Nghiệp',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

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
            const SizedBox(height: 8),
          ],

          // isAvailable + type badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (_profile?.isAvailable ?? false)
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (_profile?.isAvailable ?? false)
                      ? 'Sẵn sàng'
                      : 'Không sẵn sàng',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: (_profile?.isAvailable ?? false)
                        ? const Color(0xFF10B981)
                        : Colors.grey,
                  ),
                ),
              ),
              if (_profile?.type != null) ...
                [
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFFF6B35).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _profile!.type!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                  ),
                ],
            ],
          ),
          const SizedBox(height: 4),

          // Join date
          Text(
            _profile?.createdAt != null
                ? 'Tham gia: ${_profile!.createdAt!.month.toString().padLeft(2, '0')}/${_profile!.createdAt!.year}'
                : 'Tham gia: ---',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(height: 20),

          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () {
                context.pushNamed('rescuer_edit_profile').then((_) => _loadProfile());
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFF6B35), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: const Color(0xFFFF6B35),
                overlayColor: const Color(0xFFFF6B35).withOpacity(0.1),
              ),
              child: const Text(
                'Chỉnh Sửa Hồ Sơ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B35),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          // Stars and Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(
                4,
                (index) => const Icon(
                  Icons.star,
                  color: Color(0xFFFFC107),
                  size: 24,
                ),
              ),
              const Icon(
                Icons.star_half,
                color: Color(0xFFFFC107),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '${_profile?.rating?.toStringAsFixed(1) ?? '-'}/5.0',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Divider and Stats
          Container(
            padding: const EdgeInsets.only(top: 20),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFF0F0F0), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${_profile?.ratingCount ?? 0} đánh giá',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(12),
          splashColor: const Color(0xFFFF6B35).withOpacity(0.1),
          highlightColor: const Color(0xFFFF6B35).withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFFFF6B35),
                size: 20,
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
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFCCCCCC),
              size: 20,
            ),
          ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVacationMode() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFF6B35), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),                foregroundColor: const Color(0xFFFF6B35),
                overlayColor: const Color(0xFFFF6B35).withOpacity(0.1),              ),
              child: const Text(
                'Chế Độ Nghỉ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B35),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tạm ngừng nhận yêu cầu mới',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}
