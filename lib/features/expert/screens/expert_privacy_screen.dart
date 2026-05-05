import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expert_services_and_terms.dart';
import '../providers/expert_services_and_terms_provider.dart';

/// Expert Privacy Screen - Privacy policy for experts
class ExpertPrivacyScreen extends ConsumerWidget {
  const ExpertPrivacyScreen({super.key});

  static const List<String> _defaultPrivacySections = [
    '1. Giới Thiệu chung về bảo vệ quyền riêng tư.',
    '2. Thông tin thu tập (Cá nhân, Chuyên nghiệp, Thanh toán, Hoạt động, Kỹ thuật).',
    '3. Cách sử dụng thông tin (Cải thiện dịch vụ, Thanh toán, Liên lạc, Pháp lý).',
    '4. Chia sẻ thông tin (Không bán dữ liệu; chỉ chia sẻ cho đối tác tin cậy hoặc pháp luật).',
    '5. Bảo vệ dữ liệu (Mã hóa SSL/TLS, mật khẩu một chiều).',
    '6. Quyền của chuyên gia (Truy cập, sửa đổi, xóa, phản đối).',
    '7. Thời gian lưu trữ (Lưu giữ thông tin thanh toán 7 năm).',
    '8. Cookies (Ghi nhớ sở thích và theo dõi hoạt động).',
    '10. Liên hệ khiếu nại: privacy@snakeaid.com',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final termsAsync = ref.watch(expertServicesAndTermsProvider);

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
          'Chính Sách Bảo Mật',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
      ),
      body: termsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            _buildPrivacyContent(sections: _defaultPrivacySections),
        data: (terms) => _buildPrivacyContent(
          sections: terms.privacyPolicy?.sections ?? _defaultPrivacySections,
        ),
      ),
    );
  }

  Widget _buildPrivacyContent({required List<String> sections}) {
    // Use defaults if API data is empty
    final useSections = sections.isNotEmpty
        ? sections
        : _defaultPrivacySections;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C47C2), Color(0xFF4E2FA3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Chính Sách Bảo Mật',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Cách chúng tôi thu thập và bảo vệ dữ liệu chuyên gia.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...useSections
              .map((section) => _buildSectionCard(title: '', content: section))
              .toList(),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF6C47C2).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Phiên bản 1.0.0 • SnakeAid Expert',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4E2FA3),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required String content}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              height: 1.7,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return _buildSectionCard(title: title, content: content);
  }
}
