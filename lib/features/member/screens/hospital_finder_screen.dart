import 'package:flutter/material.dart';

/// Hospital Finder Screen - Find nearby hospitals with antivenom
class HospitalFinderScreen extends StatefulWidget {
  const HospitalFinderScreen({super.key});

  @override
  State<HospitalFinderScreen> createState() => _HospitalFinderScreenState();
}

class _HospitalFinderScreenState extends State<HospitalFinderScreen> {
  String _selectedFilter = 'Đang mở cửa';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _hospitals = [
    {
      'name': 'Bệnh viện Chợ Rẫy',
      'distance': '2.3 km',
      'duration': '8 phút lái xe',
      'features': [
        {'icon': Icons.vaccines, 'text': 'Có huyết thanh King Cobra'},
        {'icon': Icons.emergency, 'text': 'Cấp cứu 24/7'},
      ],
      'rating': 4.8,
      'reviews': 1234,
      'hasAntivenom': true,
      'is24h': true,
    },
    {
      'name': 'Bệnh viện Quận 10',
      'distance': '5.1 km',
      'duration': '12 phút lái xe',
      'features': [
        {'icon': Icons.vaccines, 'text': 'Nhiều loại huyết thanh'},
        {'icon': Icons.schedule, 'text': 'Đóng cửa lúc 22:00', 'warning': true},
      ],
      'rating': 4.5,
      'reviews': 856,
      'hasAntivenom': true,
      'is24h': false,
    },
    {
      'name': 'Bệnh viện Thống Nhất',
      'distance': '7.8 km',
      'duration': '15 phút lái xe',
      'features': [
        {'icon': Icons.vaccines, 'text': 'Có huyết thanh cơ bản'},
        {'icon': Icons.emergency, 'text': 'Cấp cứu 24/7'},
      ],
      'rating': 4.6,
      'reviews': 654,
      'hasAntivenom': true,
      'is24h': true,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top white area with SafeArea
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new),
                          onPressed: () {
                            // Navigate back in navigation bar context
                            final scaffold = Scaffold.of(context);
                            if (scaffold.hasDrawer) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'Tìm bệnh viện',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.filter_list),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Bộ lọc - Đang phát triển')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Search Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Tìm theo tên hoặc vị trí...',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF888888),
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Color(0xFF888888),
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
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đang lấy vị trí của bạn...')),
                            );
                          },
                          child: const Text(
                            'Dùng vị trí\ncủa tôi',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF228B22),
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Map Placeholder
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            color: const Color(0xFFE8F5E9),
            child: Stack(
              children: [
                // Placeholder for Google Maps
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        size: 64,
                        color: const Color(0xFF228B22).withOpacity(0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bản đồ bệnh viện',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF228B22).withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                // Your location indicator
                Center(
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                // Hospital markers
                Positioned(
                  top: 60,
                  left: 80,
                  child: _buildMapMarker('1'),
                ),
                Positioned(
                  top: 100,
                  right: 60,
                  child: _buildMapMarker('2'),
                ),
                Positioned(
                  bottom: 80,
                  left: 70,
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
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: () {},
                        ),
                        Container(
                          height: 1,
                          width: 32,
                          color: const Color(0xFFE0E0E0),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove, size: 20),
                          onPressed: () {},
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Đang mở cửa'),
                  const SizedBox(width: 8),
                  _buildFilterChip('24/7'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Có huyết thanh'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Gần nhất'),
                ],
              ),
            ),
          ),

          // Hospital List
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _hospitals.length,
                itemBuilder: (context, index) {
                  return _buildHospitalCard(_hospitals[index]);
                },
              ),
            ),
          ),

          // Tip Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              border: Border(
                top: BorderSide(
                  color: const Color(0xFF2196F3).withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  const Text(
                    '💡',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1565C0),
                        ),
                        children: [
                          TextSpan(
                            text: 'Mẹo: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: 'Gọi trước để xác nhận có huyết thanh.',
                          ),
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
            color: const Color(0xFFE53935),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        CustomPaint(
          size: const Size(12, 8),
          painter: _MarkerTrianglePainter(),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF228B22) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF228B22) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }

  Widget _buildHospitalCard(Map<String, dynamic> hospital) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  hospital['name'],
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hospital['distance'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF228B22),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            hospital['duration'],
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 12),

          // Features
          Column(
            children: (hospital['features'] as List).map((feature) {
              final isWarning = feature['warning'] ?? false;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      feature['icon'],
                      size: 18,
                      color: isWarning ? const Color(0xFFFFA726) : const Color(0xFF228B22),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature['text'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Rating
          Row(
            children: [
              const Icon(
                Icons.star,
                size: 18,
                color: Color(0xFFFFB300),
              ),
              const SizedBox(width: 4),
              Text(
                hospital['rating'].toString(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${hospital['reviews']} đánh giá)',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF888888),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Chỉ đường đến ${hospital['name']}'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF228B22),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.directions, size: 20),
                  label: const Text(
                    'Chỉ đường',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đang gọi bệnh viện...'),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF228B22),
                    side: const BorderSide(
                      color: Color(0xFF228B22),
                      width: 2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Gọi ngay',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
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

class _MarkerTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE53935)
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
