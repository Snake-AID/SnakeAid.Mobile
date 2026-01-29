import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Rescuer History Screen - View rescue mission history with filters and statistics
/// Màn hình lịch sử cứu hộ với bộ lọc và thống kê
class RescuerHistoryScreen extends StatefulWidget {
  const RescuerHistoryScreen({super.key});

  @override
  State<RescuerHistoryScreen> createState() => _RescuerHistoryScreenState();
}

class _RescuerHistoryScreenState extends State<RescuerHistoryScreen> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = ['Tất cả', 'Hoàn thành', 'Đã hủy', 'Tháng này'];

  // Mock data
  final List<Map<String, dynamic>> _missions = [
    {
      'id': '#RSC-2025-1234',
      'status': 'completed',
      'date': '15 Thg 12, 2025',
      'time': '14:30',
      'snakeName': 'Rắn Hổ Mang',
      'snakeImage': 'https://via.placeholder.com/60',
      'location': '123 Nguyễn Huệ, Q.1',
      'distance': '5.2 km',
      'duration': '45 phút',
      'rating': 5.0,
      'income': '200,000 VNĐ',
    },
    {
      'id': '#RSC-2025-1233',
      'status': 'completed',
      'date': '14 Thg 12, 2025',
      'time': '10:15',
      'snakeName': 'Rắn Lục',
      'snakeImage': 'https://via.placeholder.com/60',
      'location': '456 Lê Lợi, Q.3',
      'distance': '3.1 km',
      'duration': '25 phút',
      'rating': 4.0,
      'income': '150,000 VNĐ',
    },
    {
      'id': '#RSC-2025-1232',
      'status': 'cancelled',
      'date': '13 Thg 12, 2025',
      'time': '16:45',
      'snakeName': 'Rắn Ráo',
      'snakeImage': 'https://via.placeholder.com/60',
      'location': '789 Trần Hưng Đạo, Q.5',
      'distance': '7.8 km',
      'duration': '0 phút',
      'rating': 0.0,
      'income': '0 VNĐ',
    },
  ];

  List<Map<String, dynamic>> get _filteredMissions {
    switch (_selectedTabIndex) {
      case 1: // Hoàn thành
        return _missions.where((m) => m['status'] == 'completed').toList();
      case 2: // Đã hủy
        return _missions.where((m) => m['status'] == 'cancelled').toList();
      case 3: // Tháng này
        return _missions; // Mock: return all for now
      default: // Tất cả
        return _missions;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStatsSection(),
            _buildTabsSection(),
            ..._filteredMissions.map((mission) => _buildMissionCard(mission)),
            _buildBottomStatsCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F7F5),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1D150C)),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Lịch Sử Cứu Hộ',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1D150C),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.tune, color: Color(0xFF1D150C)),
          onPressed: () {
            // Show filter dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bộ lọc - Đang phát triển')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
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
            _buildStatItem('87', 'Tổng số', const Color(0xFF1D150C)),
            Container(width: 1, height: 60, color: const Color(0xFFE5E5E5)),
            _buildStatItem('95%', 'Thành công', const Color(0xFF10B981)),
            Container(width: 1, height: 60, color: const Color(0xFFE5E5E5)),
            _buildStatItem('52,8M', 'Tổng thu', const Color(0xFF10B981)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTabIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              padding: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? const Color(0xFFFF8800)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                _tabs[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF1D150C)
                      : const Color(0xFF999999),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMissionCard(Map<String, dynamic> mission) {
    final isCompleted = mission['status'] == 'completed';
    final isCancelled = mission['status'] == 'cancelled';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  mission['id'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : isCancelled
                            ? const Color(0xFFEF4444).withOpacity(0.1)
                            : const Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isCompleted
                        ? 'HOÀN THÀNH'
                        : isCancelled
                            ? 'ĐÃ HỦY'
                            : 'ĐANG XỬ LÝ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? const Color(0xFF10B981)
                          : isCancelled
                              ? const Color(0xFFEF4444)
                              : const Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date and Time
            Row(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 16,
                  color: Color(0xFF999999),
                ),
                const SizedBox(width: 8),
                Text(
                  '${mission['date']} - ${mission['time']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D150C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Snake Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFE5E5E5),
                    image: DecorationImage(
                      image: NetworkImage(mission['snakeImage']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission['snakeName'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D150C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Color(0xFF999999),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              mission['location'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF999999),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${mission['distance']} • ${mission['duration']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Rating and Income
            if (isCompleted)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          Icons.star,
                          size: 16,
                          color: index < mission['rating']
                              ? const Color(0xFFFFC107)
                              : const Color(0xFFE5E5E5),
                        );
                      }),
                      const SizedBox(width: 4),
                      Text(
                        mission['rating'].toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1D150C),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    mission['income'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),

            // View Detail Button
            if (isCompleted || isCancelled)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    context.pushNamed('rescuer_history_detail', extra: mission);
                  },
                  child: const Text(
                    'Xem Chi Tiết',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomStatsCard() {
    return Container(
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
      child: Column(
        children: [
          _buildStatRow(
            Icons.star,
            'Đánh giá TB:',
            '4.8/5.0',
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            Icons.pest_control,
            'Loài hay gặp:',
            'Rắn Hổ Mang',
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            Icons.history,
            'Giờ cao điểm:',
            '14h-18h',
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFFF8800).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFFFF8800),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1D150C),
              ),
              children: [
                TextSpan(
                  text: label,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
