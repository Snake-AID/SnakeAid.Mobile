import 'package:flutter/material.dart';
import 'dart:async';
import 'rescuer_arrived_screen.dart';

class EmergencyTrackingScreen extends StatefulWidget {
  final String snakeNameVi;
  final String severityLevel;

  const EmergencyTrackingScreen({
    Key? key,
    required this.snakeNameVi,
    required this.severityLevel,
  }) : super(key: key);

  @override
  State<EmergencyTrackingScreen> createState() =>
      _EmergencyTrackingScreenState();
}

class _EmergencyTrackingScreenState extends State<EmergencyTrackingScreen> {
  Timer? _timer;
  int _etaMinutes = 15;
  double _rescuerDistance = 3.5; // km
  String _rescuerStatus = 'Đang trên đường đến';
  final List<String> _updates = [];

  @override
  void initState() {
    super.initState();
    _startTracking();
    _addInitialUpdates();
  }

  void _startTracking() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        if (_etaMinutes > 0) {
          _etaMinutes--;
          _rescuerDistance = (_rescuerDistance * 0.9).clamp(0.1, 100);

          if (_etaMinutes <= 2) {
            _rescuerStatus = 'Sắp đến nơi';
          }

          if (_etaMinutes == 10) {
            _addUpdate('Cứu hộ viên đang di chuyển qua Đường Lê Lợi');
          } else if (_etaMinutes == 5) {
            _addUpdate('Cứu hộ viên đã đến gần, chuẩn bị đón');
          } else if (_etaMinutes == 1) {
            _addUpdate('Cứu hộ viên đã đến khu vực của bạn');
          }
        }
      });
    });
  }

  void _addInitialUpdates() {
    _addUpdate('SOS đã được gửi thành công');
    _addUpdate('Đang tìm cứu hộ viên gần nhất...');
    _addUpdate('Đã tìm thấy: Nguyễn Văn An - Cứu hộ viên chuyên nghiệp');
    _addUpdate('Cứu hộ viên đã nhận cuộc gọi và đang di chuyển đến');
  }

  void _addUpdate(String update) {
    setState(() {
      _updates.insert(
        0,
        '${TimeOfDay.now().format(context)} - $update',
      );
    });
  }

  void _simulateRescuerArrival() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RescuerArrivedScreen(
          rescuerName: 'Nguyễn Văn An',
          rescuerPhone: '0909123456',
          rescuerRating: 4.8,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF228B22),
        foregroundColor: Colors.white,
        title: const Text(
          'Theo dõi cứu hộ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Map placeholder
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              image: const DecorationImage(
                image: NetworkImage('https://picsum.photos/seed/map/600/400'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // Patient marker (center)
                const Center(
                  child: Icon(
                    Icons.person_pin_circle,
                    size: 50,
                    color: Colors.blue,
                  ),
                ),

                // Rescuer marker (moving)
                Positioned(
                  top: 100,
                    left: 150,
                  child: Column(
                    children: const [
                      Icon(
                        Icons.directions_car,
                        size: 40,
                        color: Color(0xFF228B22),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Cứu hộ viên',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          backgroundColor: Color(0xFF228B22),
                        ),
                      ),
                    ],
                  ),
                ),

                // ETA badge
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Color(0xFF228B22),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ETA: $_etaMinutes phút',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Rescuer info card
          Container(
            margin: const EdgeInsets.all(16),
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
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF228B22),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text(
                      'AN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nguyễn Văn An',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '4.8',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '• 156 cuộc cứu hộ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF228B22).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _rescuerStatus,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF228B22),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Call button
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đang gọi cứu hộ viên...')),
                    );
                  },
                  icon: const Icon(Icons.phone, color: Color(0xFF228B22)),
                  iconSize: 28,
                ),
              ],
            ),
          ),

          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    Icons.navigation,
                    '${_rescuerDistance.toStringAsFixed(1)} km',
                    'Khoảng cách',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    Icons.local_hospital,
                    widget.severityLevel,
                    'Mức độ',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Updates section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.update, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Cập nhật theo thời gian thực',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Updates list
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _updates.length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF228B22),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _updates[index],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Test arrival button (for demo)
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
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _simulateRescuerArrival,
                icon: const Icon(Icons.check_circle, size: 22),
                label: const Text(
                  'Cứu hộ viên đã đến (Demo)',
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
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
        children: [
          Icon(icon, color: const Color(0xFF228B22), size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
