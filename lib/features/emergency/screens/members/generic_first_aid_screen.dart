import 'package:flutter/material.dart';
import 'symptom_report_screen.dart';

/// Generic First Aid Screen - Shows general first aid instructions when snake species is unknown
class GenericFirstAidScreen extends StatelessWidget {
  const GenericFirstAidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hướng dẫn sơ cứu chung',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        centerTitle: true,
        actions: [
          // Unknown badge
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFE0B2),
              ),
            ),
            child: const Text(
              'Chưa xác định loài',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE65100),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Warning Banner (Amber)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.amber[200]!,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.amber[100],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.warning_amber,
                            color: Color(0xFFFF8F00),
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '⚠️ Không xác định được loài rắn chính xác',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Đang sử dụng giao thức sơ cứu CHUNG an toàn cho tất cả vết cắn rắn độc',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber[900],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Important Alert (Red)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(16),
                      border: const Border(
                        left: BorderSide(
                          color: Color(0xFFD32F2F),
                          width: 4,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.medical_services,
                          color: Color(0xFFD32F2F),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'QUAN TRỌNG - ĐỌC KỸ:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD32F2F),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Vì không biết loại nọc độc, hướng dẫn này bao gồm biện pháp AN TOÀN cho cả Neurotoxic và Hemotoxic venom.',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'CẦN ĐẾN BỆNH VIỆN NGAY để xét nghiệm và điều trị chính xác.',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFD32F2F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // First Aid Steps
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.health_and_safety,
                              color: Color(0xFF228B22),
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Các bước sơ cứu AN TOÀN:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        _buildFirstAidStep(
                          stepNumber: 1,
                          icon: Icons.self_improvement,
                          title: 'Giữ bình tĩnh & nằm yên',
                          description: 'Ngồi hoặc nằm xuống ngay lập tức. Sự hoảng loạn và vận động làm tim đập nhanh và nọc độc lan nhanh hơn.',
                        ),
                        const SizedBox(height: 12),
                        
                        _buildFirstAidStep(
                          stepNumber: 2,
                          icon: Icons.pan_tool,
                          title: 'Bất động chi bị cắn',
                          description: 'Dùng nẹp hoặc vải cố định tay/chân bị cắn để tránh cử động. Giữ vùng bị cắn thấp hơn tim.',
                        ),
                        const SizedBox(height: 12),
                        
                        _buildFirstAidStep(
                          stepNumber: 3,
                          icon: Icons.watch_off,
                          title: 'Tháo bỏ trang sức',
                          description: 'Tháo ngay nhẫn, vòng, đồng hồ hoặc nới lỏng quần áo chật trước khi vết thương bắt đầu sưng nề.',
                        ),
                        const SizedBox(height: 12),
                        
                        _buildFirstAidStep(
                          stepNumber: 4,
                          icon: Icons.cleaning_services,
                          title: 'Làm sạch nhẹ nhàng',
                          description: 'Rửa nhẹ vết cắn bằng nước sạch và xà phòng hoặc nước muối sinh lý. Không chà xát mạnh.',
                        ),
                        const SizedBox(height: 12),
                        
                        _buildFirstAidStep(
                          stepNumber: 5,
                          icon: Icons.medical_information,
                          title: 'Băng vết thương',
                          description: 'Che vết cắn bằng gạc khô, sạch. Không băng quá chặt làm tắc nghẽn lưu thông máu.',
                        ),
                        const SizedBox(height: 12),
                        
                        _buildFirstAidStep(
                          stepNumber: 6,
                          icon: Icons.local_hospital,
                          title: 'Đến bệnh viện ngay',
                          description: 'Gọi cấp cứu hoặc nhờ người chở đến bệnh viện gần nhất. Mang theo ảnh rắn nếu có (tuyệt đối không cố bắt rắn).',
                        ),
                      ],
                    ),
                  ),

                  // Do NOT Do Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      border: Border(
                        top: BorderSide(color: Colors.red[100]!),
                        bottom: BorderSide(color: Colors.red[100]!),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.cancel,
                              color: Color(0xFFD32F2F),
                              size: 28,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'TUYỆT ĐỐI KHÔNG LÀM:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFD32F2F),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.1,
                          children: [
                            _buildDoNotCard(
                              icon: Icons.water_drop,
                              text: 'KHÔNG\nhút nọc độc',
                            ),
                            _buildDoNotCard(
                              icon: Icons.content_cut,
                              text: 'KHÔNG\nrạch vết thương',
                            ),
                            _buildDoNotCard(
                              icon: Icons.block,
                              text: 'KHÔNG\ngarô (buộc chặt)',
                            ),
                            _buildDoNotCard(
                              icon: Icons.ac_unit,
                              text: 'KHÔNG\nchườm đá/lạnh',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 160),
                ],
              ),
            ),
          ),

          // Footer Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              border: Border(
                top: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Continue to Symptom Report Button
                  SizedBox(
                    width: double.infinity,
                    height: 64,
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
                        elevation: 4,
                        shadowColor: const Color(0xFF228B22).withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_forward, size: 28),
                          const SizedBox(width: 12),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tiếp tục báo cáo triệu chứng',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Cập nhật tình trạng cho cứu hộ viên',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Text(
                    'HOẶC NẾU KHẨN CẤP:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Emergency Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Call 115
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đang gọi 115...'),
                                backgroundColor: Color(0xFFD32F2F),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFD32F2F),
                            side: const BorderSide(color: Color(0xFFD32F2F)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.call, size: 20),
                              SizedBox(width: 6),
                              Text(
                                'Gọi 115',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Find hospital
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tìm bệnh viện gần nhất...'),
                                backgroundColor: Color(0xFF228B22),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF228B22),
                            side: const BorderSide(color: Color(0xFF228B22)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.local_hospital, size: 20),
                              SizedBox(width: 6),
                              Text(
                                'Tìm bệnh viện',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
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
          // Step Number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF228B22).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF228B22).withOpacity(0.2),
              ),
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF228B22),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: const Color(0xFF228B22),
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
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
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFFD32F2F),
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
