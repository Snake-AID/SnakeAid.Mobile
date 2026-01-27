import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Rescuer Terms and Conditions Screen
/// Màn hình điều khoản và cam kết cho người cứu hộ
class RescuerTermsScreen extends StatefulWidget {
  final Map<String, String> registrationData;

  const RescuerTermsScreen({
    super.key,
    required this.registrationData,
  });

  @override
  State<RescuerTermsScreen> createState() => _RescuerTermsScreenState();
}

class _RescuerTermsScreenState extends State<RescuerTermsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      
      // Check if scrolled to bottom (with 50px threshold)
      if (currentScroll >= maxScroll - 50 && !_hasScrolledToBottom) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('rescuer_registration');
            }
          },
        ),
        title: const Text(
          'Điều Khoản & Cam Kết',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Terms Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text(
                      'Điều Khoản Dành Cho Người Cứu Hộ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF228B22),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Vui lòng đọc kỹ các điều khoản sau đây',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Terms Content
                    _buildTermSection(
                      '1. Trách nhiệm và Nghĩa vụ',
                      [
                        'Cung cấp dịch vụ cứu hộ rắn chuyên nghiệp, an toàn và hiệu quả.',
                        'Tuân thủ các quy định pháp luật về bảo vệ động vật hoang dã.',
                        'Đảm bảo trang thiết bị cứu hộ đầy đủ và đáp ứng tiêu chuẩn.',
                        'Có bảo hiểm trách nhiệm nghề nghiệp (nếu áp dụng).',
                        'Thông báo kịp thời khi không thể thực hiện nhiệm vụ.',
                      ],
                    ),

                    _buildTermSection(
                      '2. Quyền lợi',
                      [
                        'Nhận phí dịch vụ theo thỏa thuận với khách hàng.',
                        'Được hỗ trợ về mặt thông tin và kỹ thuật từ hệ thống.',
                        'Được bảo vệ quyền lợi khi thực hiện đúng quy trình.',
                        'Tham gia các khóa đào tạo và nâng cao kỹ năng.',
                      ],
                    ),

                    _buildTermSection(
                      '3. Quy trình cứu hộ',
                      [
                        'Xác nhận yêu cầu cứu hộ trong vòng 5-10 phút.',
                        'Đánh giá tình huống và thông báo thời gian đến hiện trường.',
                        'Thực hiện cứu hộ theo đúng quy trình an toàn.',
                        'Tư vấn cho khách hàng về phòng ngừa và xử lý.',
                        'Báo cáo kết quả và cập nhật trạng thái trên hệ thống.',
                      ],
                    ),

                    _buildTermSection(
                      '4. An toàn',
                      [
                        'Ưu tiên an toàn của bản thân và mọi người xung quanh.',
                        'Không cố gắng cứu hộ khi điều kiện không đảm bảo.',
                        'Sử dụng đúng trang thiết bị bảo hộ.',
                        'Thông báo ngay khi gặp tình huống nguy hiểm.',
                      ],
                    ),

                    _buildTermSection(
                      '5. Đạo đức nghề nghiệp',
                      [
                        'Tôn trọng khách hàng và giữ bí mật thông tin cá nhân.',
                        'Không lạm dụng vị trí để yêu cầu phí không hợp lý.',
                        'Hợp tác với các cứu hộ viên khác khi cần thiết.',
                        'Thực hiện đúng cam kết với khách hàng và hệ thống.',
                      ],
                    ),

                    _buildTermSection(
                      '6. Xử lý vi phạm',
                      [
                        'Vi phạm quy định có thể dẫn đến cảnh cáo hoặc đình chỉ tài khoản.',
                        'Khiếu nại từ khách hàng sẽ được xem xét và xử lý công bằng.',
                        'Quyền khiếu nại được đảm bảo trong quá trình xử lý.',
                      ],
                    ),

                    _buildTermSection(
                      '7. Cam kết',
                      [
                        'Tôi cam kết đã đọc, hiểu rõ và đồng ý với tất cả các điều khoản trên.',
                        'Tôi cam kết thực hiện đúng trách nhiệm và nghĩa vụ của người cứu hộ.',
                        'Tôi hiểu rằng mọi vi phạm sẽ bị xử lý theo quy định.',
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Scroll indicator
                    if (!_hasScrolledToBottom)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFFFE69C),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.arrow_downward,
                              size: 20,
                              color: Color(0xFF856404),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Vui lòng cuộn xuống để đọc hết điều khoản',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF856404),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom Section
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Agreement Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: _agreedToTerms,
                          onChanged: _hasScrolledToBottom
                              ? (value) {
                                  setState(() {
                                    _agreedToTerms = value ?? false;
                                  });
                                }
                              : null,
                          activeColor: const Color(0xFF228B22),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _hasScrolledToBottom
                              ? () {
                                  setState(() {
                                    _agreedToTerms = !_agreedToTerms;
                                  });
                                }
                              : null,
                          child: Text(
                            'Tôi đã đọc, hiểu rõ và cam kết tuân thủ tất cả các điều khoản trên',
                            style: TextStyle(
                              fontSize: 14,
                              color: _hasScrolledToBottom
                                  ? const Color(0xFF333333)
                                  : const Color(0xFF999999),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (_hasScrolledToBottom && _agreedToTerms && !_isLoading)
                          ? _handleContinue
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: const Color(0xFF228B22).withOpacity(0.3),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Xác Nhận và Tiếp Tục',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermSection(String title, List<String> points) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          ...points.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF228B22),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        point,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _handleContinue() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Submit registration data to API
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Navigate to OTP verification first
      final result = await context.pushNamed(
        'otp_verification',
        extra: {
          'email': widget.registrationData['email']!,
          'roleRoute': 'rescuer_login',
          'themeColor': const Color(0xFFFF6B35),
        },
      );

      // After OTP verification, navigate to pending screen
      if (mounted && result == null) {
        // OTP verified successfully, go to pending screen
        context.goNamed(
          'registration_pending',
          extra: widget.registrationData['email']!,
        );
      }
    }
  }
}
