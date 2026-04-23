import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../expert/repository/expert_certificate_repository.dart';
import '../providers/auth_provider.dart';

/// Registration Pending Screen
/// Màn hình chờ phê duyệt sau khi đăng ký expert/rescuer
class RegistrationPendingScreen extends ConsumerStatefulWidget {
  final String email;

  const RegistrationPendingScreen({super.key, required this.email});

  @override
  ConsumerState<RegistrationPendingScreen> createState() =>
      _RegistrationPendingScreenState();
}

class _RegistrationPendingScreenState
    extends ConsumerState<RegistrationPendingScreen> {
  bool _isChecking = false;

  Future<void> _checkStatus() async {
    setState(() {
      _isChecking = true;
    });

    try {
      final repo = ref.read(expertCertificateRepositoryProvider);
      final certs = await repo.getMyCertificates();

      final hasVerified = certs.any((c) => c.isVerified);

      if (!mounted) return;

      if (hasVerified) {
        // Cập nhật state isVerified = true để vượt qua router guard
        await ref.read(authProvider.notifier).markUserAsVerified();
        
        if (!mounted) return;
        // Nếu đã được duyệt -> Vào thẳng Home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tài khoản của bạn đã được phê duyệt!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/expert-home');
      } else {
        // Vẫn chưa được duyệt
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tài khoản của bạn vẫn đang trong quá trình chờ phê duyệt.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi kiểm tra trạng thái: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  void _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      context.goNamed('role_selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pending Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: const Icon(
                        Icons.schedule,
                        size: 60,
                        color: Color(0xFFFFB020),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    const Text(
                      'Đã Nộp Chứng Chỉ!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF228B22),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    const Text(
                      'Đang Chờ Phê Duyệt',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    const Text(
                      'Chứng chỉ của bạn đang được xem xét bởi quản trị viên.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Info Cards
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.email_outlined,
                                size: 24,
                                color: Color(0xFF666666),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Email xác nhận:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.email,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF333333),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          Row(
                            children: const [
                              Icon(
                                Icons.info_outline,
                                size: 24,
                                color: Color(0xFF228B22),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Thời gian xét duyệt: 1-3 ngày làm việc',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF228B22),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Next Steps
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFDDDDDD)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Các bước tiếp theo:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildStep(
                            '1',
                            'Chúng tôi xác thực giấy tờ và chứng chỉ',
                          ),
                          const SizedBox(height: 8),
                          _buildStep(
                            '2',
                            'Nhấn "Kiểm tra trạng thái" để làm mới',
                          ),
                          const SizedBox(height: 8),
                          _buildStep(
                            '3',
                            'Bắt đầu sử dụng tài khoản Chuyên gia',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Buttons
              Column(
                children: [
                  // Check Status Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isChecking ? null : _checkStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isChecking
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Kiểm tra trạng thái',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text(
                        'Đăng xuất',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF228B22).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF228B22),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
