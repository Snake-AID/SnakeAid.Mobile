import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Screen for members to select the quantity of snakes they've encountered
class SnakeQuantitySelectionScreen extends StatefulWidget {
  const SnakeQuantitySelectionScreen({super.key});

  @override
  State<SnakeQuantitySelectionScreen> createState() =>
      _SnakeQuantitySelectionScreenState();
}

class _SnakeQuantitySelectionScreenState
    extends State<SnakeQuantitySelectionScreen> {
  String? _selectedQuantity; // 'single', 'few', 'many'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Báo Cáo Phát Hiện Rắn',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black87),
            onPressed: () {
              _showInfoDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading
                  const Text(
                    'Số lượng rắn bạn thấy:',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thông tin này giúp chúng tôi chuẩn bị dụng cụ phù hợp.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Selection Cards
                  _buildSelectionCard(
                    quantity: 'single',
                    title: '1 con rắn',
                    description: 'Chụp ảnh rõ nét từ khoảng cách an toàn.',
                    icon: Icons.pets,
                    accentColor: const Color(0xFF228B22),
                    isSelected: _selectedQuantity == 'single',
                  ),
                  const SizedBox(height: 16),
                  _buildSelectionCard(
                    quantity: 'few',
                    title: '2-5 con rắn',
                    description: 'Quan sát hướng di chuyển của chúng.',
                    icon: Icons.pie_chart,
                    accentColor: const Color(0xFFFFA726),
                    isSelected: _selectedQuantity == 'few',
                  ),
                  const SizedBox(height: 16),
                  _buildSelectionCard(
                    quantity: 'many',
                    title: 'Nhiều con / Ổ rắn',
                    description:
                        'Rời khỏi khu vực ngay lập tức và gọi hỗ trợ.',
                    icon: Icons.warning,
                    accentColor: const Color(0xFFDC3545),
                    isSelected: _selectedQuantity == 'many',
                  ),
                  const SizedBox(height: 24),

                  // Safety Info Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF), // sky-50
                      border: Border.all(
                        color: const Color(0xFFE0F2FE), // sky-100
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBAE6FD), // sky-200
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.security,
                            color: Color(0xFF0369A1), // sky-700
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lời khuyên an toàn',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0C4A6E), // sky-900
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Luôn giữ khoảng cách tối thiểu 2 mét. Đừng cố gắng tự bắt rắn nếu bạn không có kinh nghiệm.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF0369A1), // sky-700
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          border: Border(
            top: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _selectedQuantity != null
                  ? () {
                      // Navigate to report detail screen with selected quantity
                      context.push('/snake-report-detail/$_selectedQuantity');
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF228B22),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                disabledForegroundColor: Colors.grey[500],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: _selectedQuantity != null ? 4 : 0,
                shadowColor: const Color(0xFF228B22).withOpacity(0.3),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tiếp tục',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required String quantity,
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
    required bool isSelected,
  }) {
    // Image URLs for each quantity type
    final imageUrl = quantity == 'single'
        ? 'https://lh3.googleusercontent.com/aida-public/AB6AXuCpV2th9rwq2wC-qfes_zN4Jyu_o8CcEeJUSOuLKvs0rrG9inQOYXV0uIRdXnGi2UypaX9oGCnutBk7_w-SlvJ9gbURrvj20huVFQrB5kJABRPDuGJmww0nytuR0rezLXnsEPB-oUN6VuPwSPt-eoECEqnsOTc-AC_Pnk2Ul0-3rO37z1j2fGDpxGsUdQcEuMhHKdBSfMVLSVgzeBWOwQ_pHit_vsStT4sLkU2xeEZylfr26dKJ6PexamIWcMthywV3BIBl-pFqCzcY'
        : quantity == 'few'
            ? 'https://lh3.googleusercontent.com/aida-public/AB6AXuApxQfoNj0gGh6WbfW55N4bB4TA5YRlnXsZV4WiB9knnGb9Sp6FxCvTlCD1yawx3fFYXotmNUoBxIPPrmzmFQVigpFayK3gF9XeqwyXHnfBwTjZ-EL3ks-4-AW4VEBmmdsSnz-IZ3RjrORvp7ygJlgfccOaxH3hCjDfQthiHykwuBHsJcypw3Qesyxqjtylg5UNhSB12sZmiIpWaSBjbCcX-qtWNlJ604xCL3lz2fml2IP8qPK3xnma4bGpL2s35rUqZHfwn7M5ikWn'
            : 'https://lh3.googleusercontent.com/aida-public/AB6AXuC2DcJ_pN0oc3OwvatjuyzxQnmkGLrv6JCuBDQgbIhsvym3ihKxT8rxY8b5t_g0ZdfS3H0qeo1eGfGzyuCWAoepwpYF5Aq7pQN60kxFyPrYBB87GG2LClgSQG1jSG8WCWaxcKXjgrVFcMGDCLktGjyz_fPoUhZUsh9yor04rAdOPkD3WAlJvzkb5K1yajsv_dhWpbwdPU7S92MjcdQ9-SM62_6jIv89thId0iO6AzW3O9Ae6ynf4xZWM2sMl-sF1ahyVtAGcxoPmEzF';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedQuantity = quantity;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: isSelected
            ? (Matrix4.identity()..scale(1.02))
            : Matrix4.identity(),
        height: isSelected ? 140 : 120,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFECFDF3) : Colors.white,
          border: Border.all(
            color: isSelected ? accentColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.15),
                    blurRadius: 15,
                    spreadRadius: 0,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Content Row
            Row(
              children: [
                // Text content - Left side
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      isSelected ? 52 : 44,
                      12,
                      12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: isSelected ? 20 : 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? accentColor : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Flexible(
                          child: Text(
                            description,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                              color: isSelected ? Colors.grey[700] : Colors.grey[500],
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Image - Right side
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                        topRight: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Background image
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            bottomLeft: Radius.circular(24),
                            topRight: Radius.circular(14),
                            bottomRight: Radius.circular(14),
                          ),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              isSelected ? Colors.transparent : Colors.grey,
                              isSelected ? BlendMode.dst : BlendMode.saturation,
                            ),
                            child: Opacity(
                              opacity: isSelected ? 1.0 : 0.6,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                height: double.infinity,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Icon(
                                      icon,
                                      size: 40,
                                      color: Colors.grey[400],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        // Gradient overlay
                        if (isSelected)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                bottomLeft: Radius.circular(24),
                                topRight: Radius.circular(14),
                                bottomRight: Radius.circular(14),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  const Color(0xFFECFDF3).withOpacity(0.9),
                                  const Color(0xFFECFDF3).withOpacity(0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Radio button icon - Top left
            Positioned(
              top: 16,
              left: 16,
              child: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? accentColor : Colors.grey[300],
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Color(0xFF228B22)),
            SizedBox(width: 8),
            Text('Thông tin hướng dẫn'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Khi phát hiện rắn:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Giữ khoảng cách an toàn tối thiểu 2 mét'),
            Text('• Không cố gắng bắt hoặc tiếp cận rắn'),
            Text('• Chụp ảnh từ xa để nhận diện loài'),
            Text('• Gọi ngay số hotline hoặc sử dụng app này'),
            SizedBox(height: 12),
            Text(
              'Số lượng rắn giúp chúng tôi:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Chuẩn bị dụng cụ bắt phù hợp'),
            Text('• Điều động đủ nhân lực'),
            Text('• Đánh giá mức độ nguy hiểm'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              'Đã hiểu',
              style: TextStyle(color: Color(0xFF228B22)),
            ),
          ),
        ],
      ),
    );
  }
}
