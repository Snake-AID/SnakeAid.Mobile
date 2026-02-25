import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'rescuer_en_route_screen.dart';

/// Màn hình hiển thị trạng thái đã nhận đơn thành công
class RescuerAcceptRequestScreen extends StatefulWidget {
  final Map<String, dynamic> requestData;
  
  const RescuerAcceptRequestScreen({
    super.key,
    required this.requestData,
  });

  @override
  State<RescuerAcceptRequestScreen> createState() => _RescuerAcceptRequestScreenState();
}

class _RescuerAcceptRequestScreenState extends State<RescuerAcceptRequestScreen> {
  final List<bool> _equipmentChecked = [false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Đơn Đã Nhận',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Header
            _buildSuccessHeader(),
            
            const SizedBox(height: 16),
            
            // Job Information Card
            _buildJobInformationCard(),
            
            const SizedBox(height: 16),
            
            // Customer Information Card
            _buildCustomerInformationCard(),
            
            const SizedBox(height: 16),
            
            // Map Card
            _buildMapCard(),
            
            const SizedBox(height: 16),
            
            // Equipment Checklist Card
            _buildEquipmentChecklistCard(),
            
            const SizedBox(height: 16),
            
            // Safety Warning Card
            _buildSafetyWarningCard(),
            
            const SizedBox(height: 16),
            
            // Quick Action Buttons
            _buildQuickActionButtons(),
            
            const SizedBox(height: 16),
            
            // Main Action Button
            _buildMainActionButton(),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF28A745).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Color(0xFF28A745),
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'ĐÃ NHẬN ĐƠN THÀNH CÔNG!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF28A745),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy chuẩn bị thiết bị và bắt đầu di chuyển',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobInformationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            'Thông Tin Công Việc',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Snake Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: const Color(0xFFF0F0F0),
                  child: Image.network(
                    widget.requestData['image'] ?? 'https://picsum.photos/400/300',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image, size: 40, color: Color(0xFFCCCCCC));
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Snake Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.requestData['title'] ?? 'Rắn Hổ Mang Chúa',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC3545).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ĐỘC MẠNH',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDC3545),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.requestData['quantity'] ?? 1} con rắn',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE0E0E0)),
          const SizedBox(height: 12),
          
          // Distance and Address
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFFFF6B35), size: 18),
              const SizedBox(width: 8),
              Text(
                widget.requestData['distance'] ?? '2.5 km',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const Text(
                ' - ',
                style: TextStyle(color: Color(0xFF999999)),
              ),
              Expanded(
                child: Text(
                  widget.requestData['address'] ?? '123 Nguyễn Văn Linh, Q7',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Price
          Row(
            children: [
              const Icon(Icons.payments, color: Color(0xFF28A745), size: 18),
              const SizedBox(width: 8),
              Text(
                '~${widget.requestData['price'] ?? '489,000'} VNĐ',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF28A745),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Giá cuối sẽ xét nhận thành',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF999999),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInformationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            'Thông Tin Khách Hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Color(0xFF999999), size: 30),
              ),
              const SizedBox(width: 12),
              
              // Customer Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text(
                          'Nguyễn Văn A',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.verified, color: Color(0xFF2196F3), size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '0912 345 678',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(5, (index) => const Icon(
                          Icons.star,
                          size: 14,
                          color: Color(0xFFFFC107),
                        )),
                        const SizedBox(width: 4),
                        const Text(
                          '4.8 (28 đánh giá)',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Call Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Make phone call
              },
              icon: const Icon(Icons.call, size: 18),
              label: const Text(
                'GỌI KHÁCH HÀNG',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Field Notes
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFE5CC)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.warning_amber, color: Color(0xFFFF6B35), size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"Rắn trong vườn, gần hồ nước. Đang ẩn dưới gốc cây"',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                      fontStyle: FontStyle.italic,
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

  Widget _buildMapCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
        children: [
          // Map
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              width: double.infinity,
              height: 180,
              color: const Color(0xFFE0E0E0),
              child: Stack(
                children: [
                  Image.network(
                    'https://maps.googleapis.com/maps/api/staticmap?center=${widget.requestData['address']}&zoom=15&size=600x400&markers=color:red%7C${widget.requestData['address']}&key=YOUR_API_KEY',
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.map, size: 40, color: Color(0xFF999999)),
                      );
                    },
                  ),
                  Center(
                    child: const Icon(
                      Icons.location_on,
                      color: Color(0xFFDC3545),
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Directions Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Open map directions
                },
                icon: const Icon(Icons.directions, size: 18),
                label: const Text(
                  'CHỈ ĐƯỜNG',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentChecklistCard() {
    final equipmentList = [
      'Móc bắt rắn (1.2m+)',
      'Găng tay bảo hộ',
      'Túi vải dày / Hộp nhựa',
      'Đèn pin (nếu tối)',
    ];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            'Thiết Bị Cần Mang',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          
          ...List.generate(equipmentList.length, (index) {
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
                  Text(
                    equipmentList[index],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            );
          }),
          
          const SizedBox(height: 8),
          
          TextButton.icon(
            onPressed: () {
              // TODO: Show full safety guide
            },
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text(
              'Xem hướng dẫn an toàn đầy đủ',
              style: TextStyle(fontSize: 13),
            ),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2196F3),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyWarningCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFF6B35),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Đọc lại hướng dẫn an toàn trước khi xuất phát',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Xem hướng dẫn →',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFF6B35),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Call expert
              },
              icon: const Icon(Icons.headset_mic, size: 18),
              label: const Text(
                'Gọi Chuyên Gia',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2196F3),
                side: const BorderSide(color: Color(0xFF2196F3)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: View snake detail
              },
              icon: const Icon(Icons.info_outline, size: 18),
              label: const Text(
                'Xem Chi Tiết Rắn',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF666666),
                side: const BorderSide(color: Color(0xFFDDDDDD)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                _showCancelDialog();
              },
              icon: const Icon(Icons.close, size: 18),
              label: const Text(
                'Hủy Đơn',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC3545),
                side: const BorderSide(color: Color(0xFFDC3545)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainActionButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RescuerEnRouteScreen(
                      requestData: widget.requestData,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.navigation, size: 20),
              label: const Text(
                'BẮT ĐẦU DI CHUYỂN',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              // TODO: Request more time
            },
            child: const Text(
              'Tôi cần thêm thời gian',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đơn'),
        content: const Text(
          'Bạn có chắc chắn muốn hủy đơn này?\nĐiều này có thể ảnh hưởng đến đánh giá của bạn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Giữ đơn'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã hủy đơn')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC3545),
            ),
            child: const Text('Hủy đơn'),
          ),
        ],
      ),
    );
  }
}
