import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/rescuer_services_and_terms_provider.dart';
import '../../snake_catching/repository/system_settings_repository.dart';

class RescuerContactSupportScreen extends ConsumerStatefulWidget {
  const RescuerContactSupportScreen({super.key});

  @override
  ConsumerState<RescuerContactSupportScreen> createState() =>
      _RescuerContactSupportScreenState();
}

class _RescuerContactSupportScreenState
    extends ConsumerState<RescuerContactSupportScreen> {
  String? _latitude;
  String? _longitude;
  String _hotline = '0787171699';
  String _workingHours = 'Từ 6:00 AM đến 11:00 PM (hàng ngày)';
  String _responseTime = 'Bình thường trong 2-3 phút';
  String _supportScope = 'Vấn đề kỹ thuật, thanh toán, yêu cầu';
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
      final terms = await ref.read(rescuerServicesAndTermsProvider.future);
      final support = terms.support;
      if (mounted) {
        setState(() {
          if (support != null) {
            if (support.hotline.trim().isNotEmpty) {
              _hotline = support.hotline.trim();
            }
            if (support.workingHours.trim().isNotEmpty) {
              _workingHours = support.workingHours.trim();
            }
            if (support.responseTime.trim().isNotEmpty) {
              _responseTime = support.responseTime.trim();
            }
            if (support.supportScope.trim().isNotEmpty) {
              _supportScope = support.supportScope.trim();
            }
          }
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
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
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
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F5),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF231A0F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Liên Hệ Hỗ Trợ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF231A0F),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Main Hotline Card
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFD94010)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withOpacity(0.3),
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
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.headset_mic_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Đội Hỗ Trợ 24/7',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Liên hệ trực tiếp với chúng tôi bất kỳ lúc nào',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
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
                            foregroundColor: const Color(0xFFFF6B35),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                          ),
                          child: const Text(
                            'Gọi Hotline',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _hotline,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Info Cards
              _buildInfoCard(
                Icons.schedule_rounded,
                'Thời Gian Hỗ Trợ',
                _workingHours,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                Icons.call_rounded,
                'Thời Gian Phản Hồi',
                _responseTime,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                Icons.check_circle_rounded,
                'Hỗ Trợ',
                _supportScope,
              ),
              const SizedBox(height: 12),
              _buildMapCard(),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFFF6B35), size: 24),
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
                    color: Color(0xFF231A0F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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
    );
  }

  Widget _buildMapCard() {
    if (_isLoadingMap) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
        ),
      );
    }
    if (_latitude == null || _longitude == null) return const SizedBox();

    return GestureDetector(
      onTap: _openMap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Color(0xFFFF6B35),
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
                      color: Color(0xFF231A0F),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Xem trên Google Map',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFF6B35),
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
              color: Color(0xFFFF6B35),
            ),
          ],
        ),
      ),
    );
  }
}
