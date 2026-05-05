import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../providers/member_services_and_terms_provider.dart';
import '../../snake_catching/repository/system_settings_repository.dart';

class MemberContactSupportScreen extends ConsumerStatefulWidget {
  const MemberContactSupportScreen({super.key});

  @override
  ConsumerState<MemberContactSupportScreen> createState() =>
      _MemberContactSupportScreenState();
}

class _MemberContactSupportScreenState
    extends ConsumerState<MemberContactSupportScreen> {
  String? _latitude;
  String? _longitude;
  String _hotline = '078 717 1699';
  String _email = 'support@snakeaid.vn';
  String _workingHours = '6:00 - 23:00 (Hàng ngày)';
  String _liveChat = 'Phản hồi trong vòng 5 phút.';
  bool _isLoadingMap = true;

  @override
  void initState() {
    super.initState();
    _fetchCenterLocation();
  }

  Future<void> _fetchCenterLocation() async {
    String? latitude;
    String? longitude;

    try {
      final repo = ref.read(systemSettingsRepositoryProvider);
      final settings = await repo.getSystemSettings();

      latitude = settings
          .firstWhere((s) => s.settingKey == 'Center:Latitude')
          .value;
      longitude = settings
          .firstWhere((s) => s.settingKey == 'Center:Longitude')
          .value;
    } catch (_) {}

    try {
      final terms = await ref.read(memberServicesAndTermsProvider.future);
      if (mounted) {
        setState(() {
          _hotline = terms.support.hotline.trim().isEmpty
              ? _hotline
              : terms.support.hotline.trim();
          _email = terms.support.email.trim().isEmpty
              ? _email
              : terms.support.email.trim();
          _workingHours = terms.support.workingHours.trim().isEmpty
              ? _workingHours
              : terms.support.workingHours.trim();
          _liveChat = terms.support.liveChat.trim().isEmpty
              ? _liveChat
              : terms.support.liveChat.trim();
        });
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _latitude = latitude;
        _longitude = longitude;
        _isLoadingMap = false;
      });
    }
  }

  Future<void> _openMap() async {
    if (_latitude == null || _longitude == null) return;
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$_latitude,$_longitude',
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể mở bản đồ'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _callHotline() async {
    final cleanPhone = _hotline.replaceAll(RegExp(r'\s+'), '');
    final phoneNumber = 'tel:$cleanPhone';
    try {
      if (await canLaunchUrl(Uri.parse(phoneNumber))) {
        await launchUrl(Uri.parse(phoneNumber));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể thực hiện cuộc gọi'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1B5E20)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Liên Hệ Hỗ Trợ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Main Hotline Card
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryGreen, AppTheme.primaryGreenDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.support_agent_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Trung Tâm Hỗ Trợ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Chúng tôi luôn sẵn sàng lắng nghe và giải đáp mọi thắc mắc của bạn.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFF0F0F0),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _callHotline,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Gọi Hotline',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _hotline,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Info Sections
            _buildInfoTile(
              icon: Icons.access_time_rounded,
              title: 'Giờ làm việc',
              subtitle: _workingHours,
            ),
            _buildInfoTile(
              icon: Icons.mail_outline_rounded,
              title: 'Email hỗ trợ',
              subtitle: _email,
            ),
            _buildInfoTile(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Chat trực tuyến',
              subtitle: _liveChat,
            ),
            _buildMapTile(),
            const SizedBox(height: 40),
            Text(
              'SnakeAid - Bảo vệ bạn và gia đình an toàn',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapTile() {
    if (_isLoadingMap) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_latitude == null || _longitude == null) return const SizedBox();

    return GestureDetector(
      onTap: _openMap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: AppTheme.primaryGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Địa chỉ trung tâm',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Xem trên Google Map',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppTheme.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }
}
