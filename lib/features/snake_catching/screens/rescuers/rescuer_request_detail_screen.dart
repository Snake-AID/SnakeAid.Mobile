import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snakeaid_mobile/features/snake_catching/screens/rescuers/rescuer_accept_request_screen.dart';

/// Màn hình hiển thị chi tiết một yêu cầu cứu hộ
class RescuerRequestDetailScreen extends StatefulWidget {
  final Map<String, dynamic> requestData;
  
  const RescuerRequestDetailScreen({
    super.key,
    required this.requestData,
  });

  @override
  State<RescuerRequestDetailScreen> createState() => _RescuerRequestDetailScreenState();
}

class _RescuerRequestDetailScreenState extends State<RescuerRequestDetailScreen> {
  int _currentImageIndex = 0;
  final List<String> _images = [
    'https://picsum.photos/400/300',
    'https://picsum.photos/400/301',
    'https://picsum.photos/400/302',
  ];
  
  final List<bool> _equipmentChecked = [false, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopBar(),
            
            // Main Content (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Gallery
                    _buildImageGallery(),
                    
                    // AI Identification Card
                    _buildAIIdentificationCard(),
                    
                    // Safety Guidelines Card
                    _buildSafetyGuidelinesCard(),
                    
                    // Equipment Checklist Card
                    _buildEquipmentChecklistCard(),
                    
                    // Location Card
                    _buildLocationCard(),
                    
                    // Fee Breakdown Card
                    _buildFeeBreakdownCard(),
                    
                    // Expert Consultation
                    _buildExpertConsultation(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Sticky Footer Actions
      bottomSheet: _buildStickyFooter(),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFF9F9F9),
      child: Row(
        children: [
          // Back Button
          InkWell(
            onTap: () => context.pop(),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.arrow_back_ios_new, color: Color(0xFF333333)),
            ),
          ),
          
          // Title
          const Expanded(
            child: Text(
              'Chi Tiết Yêu Cầu',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ),
          
          // Timer
          Row(
            children: const [
              Icon(Icons.timer, color: Color(0xFFDC3545), size: 20),
              SizedBox(width: 4),
              Text(
                '1:23',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDC3545),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Image Gallery with PageView
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: double.infinity,
              height: 250,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: _images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.4),
                            ],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                        child: Image.network(
                          _images[index],
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFF0F0F0),
                              child: const Center(
                                child: Icon(Icons.image, size: 60, color: Color(0xFFCCCCCC)),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  // Dots Indicator
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _images.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentImageIndex == index
                                ? const Color(0xFFFF6B35)
                                : Colors.white.withOpacity(0.5),
                          ),
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

  Widget _buildAIIdentificationCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Danger Badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.requestData['title'] ?? 'Rắn Hổ Mang',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC3545).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Có Độc',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDC3545),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // AI Accuracy Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${widget.requestData['aiAccuracy'] ?? '92%'} chính xác',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.92,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Danger Level and Scientific Name
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC3545).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Nguy hiểm cao',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFDC3545),
                    ),
                  ),
                ),
                const Text(
                  'Naja kaouthia',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyGuidelinesCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    color: Color(0xFFFF6B35),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Hướng Dẫn An Toàn',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Checklist
            _buildSafetyItem('Mang găng tay dày'),
            _buildSafetyItem('Sử dụng móc bắt rắn chuyên dụng'),
            _buildSafetyItem('Giữ khoảng cách an toàn 2m'),
            _buildSafetyItem('Chuẩn bị túi vải dày'),
            
            const SizedBox(height: 12),
            
            // Full Guide Link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Show full guide
                },
                child: const Text(
                  'Xem hướng dẫn đầy đủ',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFFFF6B35),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentChecklistCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thiết Bị Cần Thiết',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),
            _buildEquipmentItem(0, 'Móc bắt rắn (snake hook)'),
            _buildEquipmentItem(1, 'Găng tay bảo hộ'),
            _buildEquipmentItem(2, 'Túi vải/hộp đựng'),
            _buildEquipmentItem(3, 'Đèn pin'),
            _buildEquipmentItem(4, 'Phun nước (nếu cần)'),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentItem(int index, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: _equipmentChecked[index],
              onChanged: (value) {
                setState(() {
                  _equipmentChecked[index] = value ?? false;
                });
              },
              activeColor: const Color(0xFFFF6B35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                height: 120,
                color: const Color(0xFFE0E0E0),
                child: Image.network(
                  'https://maps.googleapis.com/maps/api/staticmap?center=${widget.requestData['address']}&zoom=15&size=600x300&markers=color:red%7C${widget.requestData['address']}&key=YOUR_API_KEY',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFE0E0E0),
                      child: const Center(
                        child: Icon(Icons.map, size: 40, color: Color(0xFF999999)),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address
                  Text(
                    widget.requestData['address'] ?? '123 Nguyễn Văn Linh, Quận 1',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Distance and Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.requestData['distance'] ?? '1.2 km',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.directions_car, size: 20, color: Color(0xFF999999)),
                          SizedBox(width: 4),
                          Text(
                            '5 phút lái xe',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Directions Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Open map directions
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF6B35),
                        side: const BorderSide(color: Color(0xFFFF6B35), width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Chỉ Đường',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  const Divider(color: Color(0xFFE0E0E0)),
                  
                  const SizedBox(height: 16),
                  
                  // Customer Info
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Nguyễn Văn A - 0912 345 678',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Rắn trong vườn, gần hồ nước.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFF28A745),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.call, color: Colors.white, size: 20),
                          onPressed: () {
                            // TODO: Make phone call
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeBreakdownCard() {
    final price = widget.requestData['price'] ?? '200.000';
    final priceInt = int.parse(price.replaceAll('.', ''));
    final rescuerCut = (priceInt * 0.85).toInt();
    final platformFee = (priceInt * 0.10).toInt();
    final insuranceFund = (priceInt * 0.05).toInt();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${price.replaceAll('.', ',')} VNĐ',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF28A745),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '- Phí cứu hộ: ${price.replaceAll('.', ',')} VNĐ -',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn nhận: ${_formatCurrency(rescuerCut)} VNĐ (85%)',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Phí nền tảng: ${_formatCurrency(platformFee)} VNĐ (10%)',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Quỹ bảo hiểm: ${_formatCurrency(insuranceFund)} VNĐ (5%)',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertConsultation() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Không chắc về loài rắn này?',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF666666),
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () {
                // TODO: Consult expert
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2196F3),
                side: const BorderSide(color: Color(0xFF2196F3), width: 2),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Hỏi Chuyên Gia',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyFooter() {
    return Container(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Accept Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Accept request
                _showAcceptDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'CHẤP NHẬN YÊU CẦU',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Reject Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // TODO: Reject request
                _showRejectDialog();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF666666),
                side: const BorderSide(color: Color(0xFFDDDDDD), width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'TỪ CHỐI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAcceptDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn chấp nhận yêu cầu này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail screen
              
              // Navigate to accept screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RescuerAcceptRequestScreen(
                    requestData: widget.requestData,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Từ chối yêu cầu'),
        content: const Text('Bạn có chắc chắn muốn từ chối yêu cầu này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã từ chối yêu cầu.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC3545),
            ),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
