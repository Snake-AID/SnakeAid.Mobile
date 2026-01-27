import 'package:flutter/material.dart';
import 'symptom_report_screen.dart';
import '../../../shared/widgets/custom_dialog.dart';

class FirstAidStepsScreen extends StatelessWidget {
  final String snakeNameVi;
  final String englishName;
  final bool isPoisonous;
  final String venomType;
  final String snakeImageUrl;

  const FirstAidStepsScreen({
    Key? key,
    required this.snakeNameVi,
    required this.englishName,
    required this.isPoisonous,
    required this.venomType,
    required this.snakeImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          'Hướng dẫn sơ cứu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Snake info header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                children: [
                  // Snake image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      color: const Color(0xFFF8F8F6),
                      child: Image.network(
                        snakeImageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            size: 60,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Snake name
                  Text(
                    snakeNameVi,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    englishName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Poison status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isPoisonous
                          ? const Color(0xFFDC3545).withOpacity(0.1)
                          : const Color(0xFF228B22).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isPoisonous
                            ? const Color(0xFFDC3545)
                            : const Color(0xFF228B22),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPoisonous ? Icons.dangerous : Icons.check_circle,
                          color: isPoisonous
                              ? const Color(0xFFDC3545)
                              : const Color(0xFF228B22),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isPoisonous ? 'RẮN CÓ ĐỘC' : 'RẮN KHÔNG ĐỘC',
                          style: TextStyle(
                            color: isPoisonous
                                ? const Color(0xFFDC3545)
                                : const Color(0xFF228B22),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Venom type warning (if poisonous)
            if (isPoisonous) ...[
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC3545).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFDC3545),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFDC3545),
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'LOẠI NỘC ĐỘC',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDC3545),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildVenomTypeInfo(venomType),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),

            // First aid steps
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'CÁC BƯỚC SƠ CỨU NGAY LẬP TỨC',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: 16),

            _buildFirstAidStep(
              stepNumber: 1,
              icon: Icons.self_improvement,
              title: 'Giữ bình tĩnh - Không hoảng loạn',
              description:
                  'Hít thở sâu, giữ bình tĩnh. Sự hoảng loạn làm tim đập nhanh, '
                  'tăng tốc độ lây lan độc tố trong cơ thể.',
              iconColor: Colors.blue,
            ),

            _buildFirstAidStep(
              stepNumber: 2,
              icon: Icons.phone,
              title: 'Gọi cấp cứu ngay - 115 hoặc 114',
              description:
                  'Gọi ngay số cấp cứu. Nêu rõ: bị rắn cắn, loài rắn (nếu biết), '
                  'vị trí hiện tại, tình trạng người bệnh.',
              iconColor: const Color(0xFFDC3545),
            ),

            _buildFirstAidStep(
              stepNumber: 3,
              icon: Icons.accessible,
              title: 'Cố định chi bị cắn, giữ thấp hơn tim',
              description:
                  'Giữ chi bị cắn bất động và thấp hơn mức tim. '
                  'Hạn chế di chuyển để ngăn độc tố lan nhanh theo máu.',
              iconColor: Colors.orange,
            ),

            _buildFirstAidStep(
              stepNumber: 4,
              icon: Icons.watch,
              title: 'Tháo bỏ đồ trang sức & quần áo chặt',
              description:
                  'Tháo ngay nhẫn, vòng tay, đồng hồ, giày dép chật. '
                  'Vùng bị cắn sẽ sưng phồng nhanh chóng.',
              iconColor: Colors.purple,
            ),

            _buildFirstAidStep(
              stepNumber: 5,
              icon: Icons.cleaning_services,
              title: 'Rửa vết thương nhẹ nhàng bằng nước sạch',
              description:
                  'Dùng nước sạch rửa nhẹ nhàng vết cắn. '
                  'KHÔNG chà xát mạnh, không dùng xà phòng hay hóa chất.',
              iconColor: Colors.teal,
            ),

            _buildFirstAidStep(
              stepNumber: 6,
              icon: Icons.healing,
              title: 'Băng vết thương (không quá chặt)',
              description:
                  'Dùng băng sạch băng nhẹ nhàng. Băng đủ chặt để giữ băng, '
                  'nhưng vẫn luồn được 1 ngón tay vào giữa băng và da.',
              iconColor: Colors.green,
            ),

            if (isPoisonous)
              _buildFirstAidStep(
                stepNumber: 7,
                icon: Icons.local_hospital,
                title: 'ĐI BÁC SĨ NGAY - Không trì hoãn',
                description:
                    'THỜI GIAN VÀNG: Trong vòng 2-4 giờ đầu. '
                    'Đến bệnh viện có khoa cấp cứu và huyết thanh kháng nọc.',
                iconColor: const Color(0xFFDC3545),
              ),

            const SizedBox(height: 32),

            // DO NOT section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'TUYỆT ĐỐI KHÔNG LÀM',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildDoNotItem(
                    '❌ KHÔNG hút nọc độc bằng miệng',
                    'Làm độc tố vào cơ thể bạn qua niêm mạc miệng',
                  ),
                  _buildDoNotItem(
                    '❌ KHÔNG rạch vết cắn',
                    'Gây nhiễm trùng, chảy máu nhiều và tổn thương mô',
                  ),
                  _buildDoNotItem(
                    '❌ KHÔNG thắt chặt (tourniquet)',
                    'Dây thắt quá chặt gây hoại tử chi, nguy hiểm tính mạng',
                  ),
                  _buildDoNotItem(
                    '❌ KHÔNG đắp đá lạnh',
                    'Nhiệt độ thấp gây tổn thương mô và làm chậm lưu thông máu',
                  ),
                  _buildDoNotItem(
                    '❌ KHÔNG uống rượu hoặc caffeine',
                    'Làm tăng nhịp tim, tăng tốc độ lây lan độc tố',
                  ),
                  _buildDoNotItem(
                    '❌ KHÔNG chạy nhảy hoặc vận động mạnh',
                    'Vận động làm tim đập nhanh, độc tố lan nhanh hơn',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Emergency contact buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement call 115
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đang gọi 115...')),
                        );
                      },
                      icon: const Icon(Icons.phone, size: 22),
                      label: const Text(
                        'Gọi cấp cứu 115',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC3545),
                        side: const BorderSide(
                          color: Color(0xFFDC3545),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement find hospital
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đang tìm bệnh viện gần nhất...'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.local_hospital, size: 22),
                      label: const Text(
                        'Tìm bệnh viện gần nhất',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF228B22),
                        side: const BorderSide(
                          color: Color(0xFF228B22),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Continue button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bước tiếp theo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SymptomReportScreen(
                              snakeNameVi: snakeNameVi,
                              englishName: englishName,
                              isPoisonous: isPoisonous,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.description, size: 22),
                      label: const Text(
                        'Báo cáo triệu chứng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Cập nhật triệu chứng giúp cứu hộ viên đánh giá tình trạng',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
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

  Widget _buildVenomTypeInfo(String venom) {
    if (venom.contains('Neurotoxic')) {
      return const Text(
        'Nọc độc thần kinh: Ảnh hưởng hệ thần kinh, gây tê liệt, '
        'khó thở, rối loạn nhịp tim. CẦN cấp cứu ngay lập tức!',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFFDC3545),
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      );
    } else if (venom.contains('Hemotoxic')) {
      return const Text(
        'Nọc độc máu: Phá hủy tế bào máu, gây chảy máu, sưng phồng, '
        'hoại tử mô. Cần huyết thanh kháng nọc chuyên biệt!',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFFDC3545),
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      );
    } else {
      return const Text(
        'Loại nọc độc chưa xác định. Thực hiện sơ cứu chung và đến bệnh viện ngay.',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFFDC3545),
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      );
    }
  }

  Widget _buildFirstAidStep({
    required int stepNumber,
    required IconData icon,
    required String title,
    required String description,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$stepNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoNotItem(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDC3545).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFDC3545).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⛔',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC3545),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
