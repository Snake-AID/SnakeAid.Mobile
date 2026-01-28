import 'package:flutter/material.dart';
import 'dart:async';
import 'rescuer_navigation_screen.dart';

class RescuerSosDetailScreen extends StatefulWidget {
  const RescuerSosDetailScreen({super.key});

  @override
  State<RescuerSosDetailScreen> createState() => _RescuerSosDetailScreenState();
}

class _RescuerSosDetailScreenState extends State<RescuerSosDetailScreen> {
  late Timer _timer;
  int _secondsElapsed = 42;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C100D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi Tiết Yêu Cầu',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C100D),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                _formatTime(_secondsElapsed),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDC3545),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 140),
            children: [
              // Severity Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFDC3545), Color(0xFFC82333)],
                  ),
                ),
                child: const Text(
                  '⚠️ NGUY KỊCH - CẦN PHẢN HỒI NGAY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Patient Information Card
                    _buildPatientInfoCard(),
                    const SizedBox(height: 16),
                    
                    // Snake Identification Card
                    _buildSnakeIdentificationCard(),
                    const SizedBox(height: 16),
                    
                    // Bite Information Card
                    _buildBiteInfoCard(),
                    const SizedBox(height: 16),
                    
                    // Location & Navigation Card
                    _buildLocationCard(),
                    const SizedBox(height: 16),
                    
                    // Safety Guide Accordion
                    _buildSafetyGuideCard(),
                    const SizedBox(height: 16),
                    
                    // Contact Expert Card
                    _buildContactExpertCard(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
          
          // Sticky Bottom Action Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RescuerNavigationScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF28A745),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'CHẤP NHẬN NHIỆM VỤ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF666666),
                        side: const BorderSide(color: Color(0xFFCCCCCC), width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'TỪ CHỐI',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông Tin Bệnh Nhân',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C100D),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8800).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFFFF8800),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nguyễn Văn A',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C100D),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Nam, 35 tuổi',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.call, size: 18),
                label: const Text('Gọi'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF28A745),
                  side: const BorderSide(color: Color(0xFF28A745)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Color(0xFF666666), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: const Text(
                  '123 Nguyễn Huệ, Quận 1, TP.HCM',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1C100D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule, color: Color(0xFF666666), size: 20),
              const SizedBox(width: 8),
              Text(
                'Bị cắn ${(_secondsElapsed ~/ 60)} phút trước',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Triệu chứng: ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C100D),
                  ),
                ),
                Expanded(
                  child: const Text(
                    'Đau dữ dội, sưng nhanh, khó thở',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFDC3545),
                      fontWeight: FontWeight.w500,
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

  Widget _buildSnakeIdentificationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '🐍',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(width: 8),
              Text(
                'Nhận Diện Rắn - AI',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C100D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  color: const Color(0xFFE5E5E5),
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuA6s40USDT6TipNdXa9Ee9qJlQz_vPu9x3MTCt7M1Mw28M-kGqhrik0zqpfTocZbah0pi5i7djNm6LbWIj5bXOYbcHGirbB5SHivbnv4mWxYejvtWJ58NR5w3TilJeJYlS6fWZfa3BazTUMPuJePWXdN44BWOLEW0Hu_lMOu_7C3u6HiqECD9DWui52wwvHVeDlaxu-z52BEE0Kwyh0aSwFk0bSfm-mFQL-lPcUfBOxJchJ2dfo2x0H2c8RU2gDxjqoSdPlYzm3EN4X',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.image, size: 80, color: Color(0xFFCCCCCC)),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '1 / 3',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Rắn hổ mang chúa',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C100D),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC3545),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'CỰC ĐỘC',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF28A745), size: 18),
              const SizedBox(width: 6),
              const Text(
                'Độ tin cậy: 95%',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF28A745),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {},
            child: const Text(
              'Xem hướng dẫn an toàn xử lý rắn này →',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF007AFF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiteInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông Tin Vết Cắn',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C100D),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 120,
                  height: 90,
                  color: const Color(0xFFE5E5E5),
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAnfSuVp-mgVBatc7iqR2u4JCzfk4YDHJfm4nwcWl5sU1rlyw4ac_UWdi1xUJcR3bhPm6ZegV9xIkGpbnxcmwoNmiP4PySe1FGTXu3_9uMSdb-RY22z1WfSjjDYBhA54RreD0j8E24X4lwpnq7vOzOtB67hg4S2Y8JdYoEdB2xInsBm-9jaMUd1-k2JI6zYeOY6Yx94t-J23EhvsZ44gMrF4pwRgQKkg1la9BMSPsB0F88hs71D0qBfZtoP0eUOB8MS8D3GcUl_IRWR',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.image, size: 40, color: Color(0xFFCCCCCC)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Vị trí:', 'Cẳng chân trái'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Triệu chứng:', 'Sưng nhanh, đỏ tím'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF28A745), size: 16),
                        const SizedBox(width: 6),
                        const Text(
                          'Đã băng ép',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF28A745),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C100D),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vị Trí & Điều Hướng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C100D),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 120,
              color: const Color(0xFFE5E5E5),
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuD4qxAe9PnHj9H-jdYN44xSjXevZM8W3wlsKaUPD7T6Tt7gOjUgBHX9NTlVIeygGDkUI6qWJDJ-SXPLtFE3e97O9iUUHHFxTZE7cn-af82ePZ-Dk9ePrk7jIKKcFFo5wOIThU_UNPtADt9AYJWmY4KD9Dw7zKmLxw9KXOT3J2gr7Sit7KM6rzXmz8Bb5L7165cpyqn7ndXHZSskc5oVauCDza3tMPGQ-BQ9nltiEWszC9gyrz8zLiinNom6_b1URGE17Kjp3h5RhKfK',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.map, size: 60, color: Color(0xFFCCCCCC)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '123 Nguyễn Huệ, Quận 1, TP.HCM',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF1C100D),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: const Color(0xFFE5E5E5)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        '📍 2.1 km',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF8800),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: const Color(0xFFE5E5E5),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        '⏱️ 8 phút',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const Text(
                        '(xe máy)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF007AFF),
                side: const BorderSide(color: Color(0xFF007AFF)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Xem Bản Đồ Đầy Đủ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyGuideCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hướng Dẫn An Toàn',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C100D),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Xem hướng dẫn xử lý an toàn cho loài này',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.expand_more,
              color: Color(0xFF666666),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactExpertCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF1976D2),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Không chắc chắn về loài rắn?',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1976D2),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6C47C2),
              side: const BorderSide(color: Color(0xFF6C47C2)),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Liên Hệ Chuyên Gia',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
