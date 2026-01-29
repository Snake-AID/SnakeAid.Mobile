import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RescuerArrivedScreen extends StatefulWidget {
  const RescuerArrivedScreen({super.key});

  @override
  State<RescuerArrivedScreen> createState() => _RescuerArrivedScreenState();
}

class _RescuerArrivedScreenState extends State<RescuerArrivedScreen> {
  final List<bool> _checklist = [true, true, true, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C100D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Xác Nhận Đến Nơi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C100D),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Map Preview
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCacSe4aOfW4hyYGR-GK_ZbUCMp05aPUDiIIKGCvmptA0zIKEbJTzgxSuVW1XZISy9J7TEE6Q5vL3C6EpUCHhtqRKUJoXdXa4RnSODWkSxuWbNB3A8fktK-azLhFcRM9VmYhdV3gXazB8fWLtdGRIjDb8QUz4uZZGtrEiRiGIb7M7fkF55CtMqSwI4r-rl6kapaYKhfWM3SDDOQ9u9VJqaD0ZnhvKAJD0rVcvENwh4iORoqr3MC9xpYC_OJVvJBetFuHHXQmTBKo-I',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Thời gian di chuyển: 7 phút',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Proximity Confirmation
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF28A745).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF28A745).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Color(0xFF28A745),
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Bạn đang ở trong phạm vi 50m',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF28A745),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Contact Patient Card
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Liên Hệ Bệnh Nhân',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C100D),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Cho bệnh nhân biết bạn đã đến',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF999999),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Số điện thoại: 090***1234',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.call, size: 18),
                                label: const Text('Gọi Điện'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF28A745),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.sms, size: 18),
                                label: const Text('Nhắn Tin'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF007AFF),
                                  side: const BorderSide(
                                    color: Color(0xFF007AFF),
                                    width: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Preparation Checklist
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chuẩn Bị',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C100D),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildChecklistItem('Đã liên hệ với bệnh nhân', _checklist[0], 0),
                        const SizedBox(height: 12),
                        _buildChecklistItem('Đã mang đủ thiết bị bảo hộ', _checklist[1], 1),
                        const SizedBox(height: 12),
                        _buildChecklistItem('Đã đọc hướng dẫn an toàn', _checklist[2], 2),
                        const SizedBox(height: 12),
                        _buildChecklistItem('Sẵn sàng hỗ trợ', _checklist[3], 3),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Snake Info Reminder
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nhắc Nhở - Thông Tin Rắn',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C100D),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: const DecorationImage(
                                  image: NetworkImage(
                                    'https://lh3.googleusercontent.com/aida-public/AB6AXuD9Y27KFgpmgFFeKEyj2aQOYJ8A_i5jcMaRSRElT8SAiuoGtbgM5aIf6MBw2uq5NkshD0FqsEu-X9Cpw79sQpDEy6KPBNZXV8UcsAS0YGnsst-cp74YDZoYbuZpe85Useow8yf6-r4HKp_3QYyXTL8stVmv6NPmHgzgB2PYut3jz7ItYOXKe6Q6tgQjkTiyDUoS7qMFAEsVdGS2APU2g6hwv2utWBQPdCHT10MUOw54yIEe9UVPNNcP_xH4drFEHDKyf1aEcs1piac',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Rắn hổ mang chúa',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1C100D),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDC3545).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.warning,
                                          size: 14,
                                          color: Color(0xFFDC3545),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'CỰC ĐỘC',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFDC3545),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: () {},
                          child: const Row(
                            children: [
                              Text(
                                'Xem Lại Hướng Dẫn An Toàn',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF007AFF),
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: Color(0xFF007AFF),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Expert Support Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8A2BE2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF8A2BE2).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8A2BE2).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.support_agent,
                                color: Color(0xFF8A2BE2),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Cần Hỗ Trợ Chuyên Gia?',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8A2BE2),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Miễn phí trong tình huống khẩn cấp',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF8A2BE2),
                              side: const BorderSide(
                                color: Color(0xFF8A2BE2),
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Gọi Chuyên Gia Rắn',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Arrival Status
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF28A745).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'ĐÃ ĐẾN NƠI',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF28A745),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Icon(
                              Icons.check,
                              size: 18,
                              color: Color(0xFF999999),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Bệnh nhân đã được thông báo',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          
          // Bottom Action Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7F5),
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    context.pushNamed('rescuer_support');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF28A745),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: const Color(0xFF28A745).withOpacity(0.3),
                  ),
                  child: const Text(
                    'BẮT ĐẦU HỖ TRỢ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String text, bool isChecked, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _checklist[index] = !_checklist[index];
        });
      },
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isChecked ? const Color(0xFF28A745) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isChecked ? const Color(0xFF28A745) : const Color(0xFFCCCCCC),
                width: 2,
              ),
            ),
            child: isChecked
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isChecked ? const Color(0xFF1C100D) : const Color(0xFF999999),
                fontWeight: isChecked ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

