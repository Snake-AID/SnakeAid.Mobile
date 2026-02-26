import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

class FindHospitalScreen extends StatefulWidget {
  final String missionId;
  final String incidentId;

  const FindHospitalScreen({
    super.key,
    required this.missionId,
    required this.incidentId,
  });

  @override
  State<FindHospitalScreen> createState() => _FindHospitalScreenState();
}

class _FindHospitalScreenState extends State<FindHospitalScreen> {
  int _selectedFilter = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'Đang mở cửa',
    '24/7',
    'Có huyết thanh',
    'Gần nhất',
  ];

  final List<Map<String, dynamic>> _hospitals = [
    {
      'name': 'Bệnh viện Chợ Rẫy',
      'distance': '2.3 km',
      'duration': '8 phút lái xe',
      'latitude': 10.7545,
      'longitude': 106.6650,
      'features': [
        {
          'icon': Icons.check_circle,
          'text': 'Có huyết thanh King Cobra',
          'color': Color(0xFF28A745),
        },
        {
          'icon': Icons.check_circle,
          'text': 'Cấp cứu 24/7',
          'color': Color(0xFF28A745),
        },
      ],
      'rating': 4.8,
      'reviews': 1234,
      'phone': '0283822254',
    },
    {
      'name': 'Bệnh viện Quận 10',
      'distance': '5.1 km',
      'duration': '15 phút lái xe',
      'latitude': 10.7720,
      'longitude': 106.6677,
      'features': [
        {
          'icon': Icons.check_circle,
          'text': 'Nhiều loại huyết thanh',
          'color': Color(0xFF28A745),
        },
        {
          'icon': Icons.warning,
          'text': 'Đóng cửa lúc 22:00',
          'color': Color(0xFFFFC107),
        },
      ],
      'rating': 4.5,
      'reviews': 856,
      'phone': '0283865731',
    },
    {
      'name': 'Bệnh viện Nguyễn Tri Phương',
      'distance': '6.8 km',
      'duration': '18 phút lái xe',
      'latitude': 10.7589,
      'longitude': 106.6744,
      'features': [
        {
          'icon': Icons.check_circle,
          'text': 'Có huyết thanh đa dạng',
          'color': Color(0xFF28A745),
        },
        {
          'icon': Icons.check_circle,
          'text': 'Cấp cứu 24/7',
          'color': Color(0xFF28A745),
        },
      ],
      'rating': 4.6,
      'reviews': 567,
      'phone': '0283850222',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openGoogleMaps(
    double latitude,
    double longitude,
    String hospitalName,
  ) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&destination_place_id=$hospitalName',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở Google Maps')),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể thực hiện cuộc gọi')),
        );
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF28A745).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF28A745),
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hoàn thành hỗ trợ?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C100D),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Bệnh nhân đã được đưa đến bệnh viện an toàn. Xác nhận hoàn thành nhiệm vụ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF666666),
                        side: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        context.push(
                          '/rescuer/mission-completion',
                          extra: {
                            'missionId': widget.missionId,
                            'needHospital': true,
                            'hospitalName':
                                'Selected Hospital', // TODO: Pass actual selected hospital
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF28A745),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Xác nhận'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      body: Column(
        children: [
          // Header
          SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFF1C100D),
                    ),
                    onPressed: () => context.pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Expanded(
                    child: Text(
                      'Tìm bệnh viện',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C100D),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.filter_list,
                      color: Color(0xFF1C100D),
                    ),
                    onPressed: () {
                      // TODO: Show filter options
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Tìm theo tên hoặc vị trí...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF999999),
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color(0xFF999999),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        // TODO: Use current location
                      },
                      child: const Text(
                        'Dùng vị trí của tôi',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF8800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Map View
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            color: const Color(0xFFE5E5E5),
            child: Stack(
              children: [
                // Map placeholder with markers
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Current location indicator
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF007AFF),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      // Radius circles
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF007AFF).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF007AFF).withOpacity(0.15),
                            width: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Hospital markers
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.07,
                  left: MediaQuery.of(context).size.width * 0.25,
                  child: _buildMapMarker('1'),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.10,
                  right: MediaQuery.of(context).size.width * 0.15,
                  child: _buildMapMarker('2'),
                ),
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.09,
                  left: MediaQuery.of(context).size.width * 0.18,
                  child: _buildMapMarker('3'),
                ),
                // Zoom controls
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: () {},
                          color: const Color(0xFF1C100D),
                        ),
                        Container(
                          height: 1,
                          width: 32,
                          color: Colors.grey.withOpacity(0.2),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove, size: 20),
                          onPressed: () {},
                          color: const Color(0xFF1C100D),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final isSelected = _selectedFilter == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFF8800)
                              : const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFF8800)
                                : Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _filters[index],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF666666),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Hospital List
          Expanded(
            child: Container(
              color: const Color(0xFFF8F7F5),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _hospitals.length,
                itemBuilder: (context, index) {
                  final hospital = _hospitals[index];
                  return _buildHospitalCard(hospital, index == 0);
                },
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F8FF),
              border: Border(
                top: BorderSide(
                  color: const Color(0xFF007AFF).withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Text('💡', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Mẹo: Gọi trước để xác nhận có huyết thanh.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1C100D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _showCompletionDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8800),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'HOÀN THÀNH HỖ TRỢ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

  Widget _buildMapMarker(String number) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFDC3545),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        CustomPaint(size: const Size(8, 6), painter: _MarkerArrowPainter()),
      ],
    );
  }

  Widget _buildHospitalCard(Map<String, dynamic> hospital, bool isHighlighted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted
            ? Border.all(color: const Color(0xFFFF8800), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isHighlighted ? 0.1 : 0.05),
            blurRadius: isHighlighted ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  hospital['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C100D),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hospital['distance'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF8800),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            hospital['duration'],
            style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
          ),
          const SizedBox(height: 12),
          ...List.generate(hospital['features'].length, (index) {
            final feature = hospital['features'][index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(feature['icon'], size: 16, color: feature['color']),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature['text'],
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1C100D),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
              const SizedBox(width: 4),
              Text(
                hospital['rating'].toString(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C100D),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${hospital['reviews']} đánh giá)',
                style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openGoogleMaps(
                    hospital['latitude'],
                    hospital['longitude'],
                    hospital['name'],
                  ),
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text('Chỉ đường'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8800),
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
                child: OutlinedButton(
                  onPressed: () => _makePhoneCall(hospital['phone']),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF8800),
                    side: const BorderSide(color: Color(0xFFFF8800), width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Gọi BV',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MarkerArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDC3545)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
