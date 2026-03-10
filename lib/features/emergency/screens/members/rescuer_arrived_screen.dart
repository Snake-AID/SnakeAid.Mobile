import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/chat_screen.dart';
import '../../providers/incident_provider.dart';

class RescuerArrivedScreen extends ConsumerStatefulWidget {
  const RescuerArrivedScreen({super.key});

  @override
  ConsumerState<RescuerArrivedScreen> createState() => _RescuerArrivedScreenState();
}

class _RescuerArrivedScreenState extends ConsumerState<RescuerArrivedScreen> {
  int _tapCount = 0;
  DateTime? _lastTapTime;

  @override
  Widget build(BuildContext context) {
    // Get incident from provider
    final incidentState = ref.watch(activeIncidentProvider);
    final incident = incidentState.incident;
    final hasRescuer = incident?.assignedRescuerId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF191910)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('emergency_tracking');
            }
          },
        ),
        title: const Text(
          'Đội Cứu Hộ Đã Đến',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191910),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                TimeOfDay.now().format(context),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF228B22),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE5E7EB).withOpacity(0.8),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          final now = DateTime.now();
          if (_lastTapTime != null &&
              now.difference(_lastTapTime!).inMilliseconds < 500) {
            _tapCount++;
            if (_tapCount >= 2) {
              // Navigate to completion screen on double tap
              context.goNamed('emergency_completion');
              _tapCount = 0;
            }
          } else {
            _tapCount = 1;
          }
          _lastTapTime = now;
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Success Banner
              _buildSuccessBanner(),
              const SizedBox(height: 16),

              // Main Status Card, mission
              _buildMainStatusCard(),
              const SizedBox(height: 16),

              // Rescuer Information Card
              if (hasRescuer) _buildRescuerInfoCard(context),
              const SizedBox(height: 24),

              // Section Header
              const Text(
                'Điều Cần Làm',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191910),
                ),
              ),
              const SizedBox(height: 16),

              // Instructions Card
              _buildInstructionsCard(),
              const SizedBox(height: 32),

              // Footer Action
              _buildFooterAction(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD4EDDA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF155724).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF155724),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Đội cứu hộ đã có mặt tại vị trí của bạn',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF155724),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStatusCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Shield Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF228B22).withOpacity(0.15),
                  const Color(0xFF228B22).withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              size: 52,
              color: Color(0xFF228B22),
            ),
          ),
          const SizedBox(height: 20),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2563EB).withOpacity(0.1),
                  const Color(0xFF3B82F6).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF2563EB).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.autorenew_rounded,
                  size: 18,
                  color: Color(0xFF2563EB),
                ),
                SizedBox(width: 8),
                Text(
                  'Đang Xử Lý',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Status Text
          Text(
            'Đội cứu hộ đang an toàn bắt rắn',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRescuerInfoCard(BuildContext context) {
    // Member side only has rescuer ID, not full profile
    // Display generic rescuer info
    const rescuerName = 'Đội Cứu Hộ SnakeAid';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  rescuerName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF191910),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Chuyên gia cứu hộ rắn',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement call rescuer functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tính năng gọi điện đang được phát triển'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.call_rounded, size: 18),
                        label: const Text('Gọi'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF228B22),
                          side: const BorderSide(
                            color: Color(0xFF228B22),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Open chat screen with rescuer
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChatScreen(
                                recipientName: rescuerName,
                                recipientAvatar: '🚑',
                                isExpert: true,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                        label: const Text('Nhắn Tin'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF228B22),
                          side: const BorderSide(
                            color: Color(0xFF228B22),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF228B22),
                  Color(0xFF1a6b1a),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF228B22).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFF3CD),
            const Color(0xFFFFF3CD).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF856404).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInstructionItem('Giữ khoảng cách an toàn'),
          const SizedBox(height: 16),
          _buildInstructionItem('Không tiếp cận con rắn'),
          const SizedBox(height: 16),
          _buildInstructionItem('Đội cứu hộ sẽ thông báo khi hoàn tất'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 20,
                  color: const Color(0xFF856404).withOpacity(0.8),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Thường mất khoảng 10-20 phút để cứu hộ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF856404).withOpacity(0.9),
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

  Widget _buildInstructionItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF856404).withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 16,
            color: Color(0xFF856404),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF856404),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterAction(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          // Show confirmation dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Hủy cứu hộ?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                'Bạn có chắc chắn muốn hủy yêu cầu cứu hộ này không?',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Không',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.pop(); // Close dialog
                    context.pop(); // Go back
                  },
                  child: const Text(
                    'Hủy cứu hộ',
                    style: TextStyle(
                      color: Color(0xFFDC3545),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: Text(
          'Hủy cứu hộ (nếu cần)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
