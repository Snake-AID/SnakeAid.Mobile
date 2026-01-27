import 'package:flutter/material.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/symptom_report_screen.dart';

class GenericFirstAidScreen extends StatelessWidget {
  const GenericFirstAidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sơ cứu cấp cứu',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber[700]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.help_outline,
                            size: 18,
                            color: Colors.amber[900],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Chưa xác định loài',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Warning banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.yellow[50],
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange[700],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '⚠️ Không xác định được loài rắn chính xác',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[900],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Hãy áp dụng quy trình sơ cứu CHUNG cho TẤT CẢ các trường hợp rắn cắn',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.orange[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Important alert
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'QUAN TRỌNG - ĐỌC KỸ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[900],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Giả định rắn CÓ ĐỘC cho đến khi được xác nhận khác',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Neurotoxic (thần kinh): Tê liệt, khó thở, mờ mắt\n'
                          '• Hemotoxic (huyết độc): Chảy máu, sưng phù, hoại tử',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[700],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // First aid steps
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Các bước sơ cứu',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Step 1
                        _buildFirstAidStep(
                          stepNumber: 1,
                          icon: Icons.self_improvement,
                          title: 'Giữ bình tĩnh',
                          description:
                              'Tránh di chuyển nhiều. Ngồi hoặc nằm xuống ngay. Giữ vết cắn thấp hơn tim.',
                        ),

                        // Step 2
                        _buildFirstAidStep(
                          stepNumber: 2,
                          icon: Icons.do_not_step,
                          title: 'Cố định chi bị cắn',
                          description:
                              'Sử dụng nẹp hoặc vật cứng để cố định chi bị cắn. Không để vết thương bị di chuyển.',
                        ),

                        // Step 3
                        _buildFirstAidStep(
                          stepNumber: 3,
                          icon: Icons.watch_off,
                          title: 'Tháo đồ trang sức',
                          description:
                              'Tháo nhẫn, vòng tay, đồng hồ ngay trước khi sưng. Tháo giày nếu bị cắn ở chân.',
                        ),

                        // Step 4
                        _buildFirstAidStep(
                          stepNumber: 4,
                          icon: Icons.water_drop_outlined,
                          title: 'Làm sạch nhẹ nhàng',
                          description:
                              'Rửa vết thương bằng nước sạch. KHÔNG cọ rửa mạnh. Không dùng xà phòng hoặc hóa chất.',
                        ),

                        // Step 5
                        _buildFirstAidStep(
                          stepNumber: 5,
                          icon: Icons.healing,
                          title: 'Băng ép nhẹ',
                          description:
                              'Băng vết thương bằng băng gạc sạch. Không băng quá chặt. Kiểm tra lưu thông máu.',
                        ),

                        // Step 6
                        _buildFirstAidStep(
                          stepNumber: 6,
                          icon: Icons.local_hospital,
                          title: 'ĐI BỆNH VIỆN NGAY',
                          description:
                              'Gọi cấp cứu 115 hoặc đến bệnh viện GẦN NHẤT có khoa cấp cứu và huyết thanh kháng nọc.',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  // DO NOT section
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.block,
                              color: Colors.red[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tuyệt đối KHÔNG làm',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[900],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.3,
                          children: [
                            _buildDoNotCard(
                              icon: Icons.no_food,
                              title: 'KHÔNG hút nọc độc',
                              subtitle: 'Nguy hiểm cho người sơ cứu',
                            ),
                            _buildDoNotCard(
                              icon: Icons.content_cut,
                              title: 'KHÔNG rạch vết thương',
                              subtitle: 'Gây nhiễm trùng, chảy máu',
                            ),
                            _buildDoNotCard(
                              icon: Icons.api,
                              title: 'KHÔNG thắt garô',
                              subtitle: 'Gây hoại tử chi',
                            ),
                            _buildDoNotCard(
                              icon: Icons.ac_unit,
                              title: 'KHÔNG chườm đá',
                              subtitle: 'Không hiệu quả, gây tổn thương',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Bottom action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SymptomReportScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Tiếp tục báo cáo triệu chứng',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Cập nhật tình trạng cho cứu hộ viên',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Call emergency number
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC3545),
                            side: const BorderSide(
                              color: Color(0xFFDC3545),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text(
                            'Gọi 115',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Navigate to hospital finder
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF228B22),
                            side: const BorderSide(
                              color: Color(0xFF228B22),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.local_hospital, size: 18),
                          label: const Text(
                            'Tìm bệnh viện',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }

  Widget _buildFirstAidStep({
    required int stepNumber,
    required IconData icon,
    required String title,
    required String description,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF228B22),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                stepNumber.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: const Color(0xFF228B22),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
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

  Widget _buildDoNotCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 28,
            color: Colors.red[700],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.red[900],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.red[700],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
