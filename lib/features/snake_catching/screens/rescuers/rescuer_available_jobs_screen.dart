import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snakeaid_mobile/features/snake_catching/screens/rescuers/rescuer_request_detail_screen.dart';

/// Màn hình hiển thị danh sách các đơn cứu hộ có thể nhận
class RescuerAvailableJobsScreen extends StatefulWidget {
  const RescuerAvailableJobsScreen({super.key});

  @override
  State<RescuerAvailableJobsScreen> createState() => _RescuerAvailableJobsScreenState();
}

class _RescuerAvailableJobsScreenState extends State<RescuerAvailableJobsScreen> {
  bool _showAvailableJobs = true; // true = "Đơn có thể nhận", false = "Đơn đã hỏi nhận"
  bool _isOnline = true;
  String _selectedFilter = 'Gần nhất'; // Gần nhất, Mới nhất, Giá cao

  // Mock data cho 3 nhóm khu vực
  final Map<String, List<Map<String, dynamic>>> _jobsByArea = {
    'GẦN BẠN (10KM)': [
      {
        'id': '1',
        'title': 'Rắn Hổ Mang Chúa',
        'distance': '2.5 km',
        'timeAgo': '5 phút trước',
        'image': 'https://picsum.photos/400/300',
        'danger': 'ĐỘC MẠNH',
        'dangerLevel': 'Cao',
        'aiAccuracy': '98%',
        'address': '123 Đường Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP.HCM',
        'quantity': 1,
        'price': '500.000',
        'viewers': 3,
      },
      {
        'id': '2',
        'title': 'Rắn Lục Đuôi Đỏ',
        'distance': '8.5 km',
        'timeAgo': '15 phút trước',
        'image': 'https://picsum.photos/400/301',
        'danger': 'TRUNG BÌNH',
        'dangerLevel': 'Trung Bình',
        'aiAccuracy': '92%',
        'address': '45 Lê Lợi, Phường Bến Thành, Quận 1, TP.HCM',
        'quantity': 1,
        'price': '350.000',
        'viewers': 2,
      },
      {
        'id': '3',
        'title': 'Rắn Ráo Trâu',
        'distance': '9.8 km',
        'timeAgo': '20 phút trước',
        'image': 'https://picsum.photos/400/302',
        'danger': 'ĐỘC MẠNH',
        'dangerLevel': 'Cao',
        'aiAccuracy': '95%',
        'address': '789 Võ Văn Tần, Phường 6, Quận 3, TP.HCM',
        'quantity': 1,
        'price': '450.000',
        'viewers': 5,
      },
    ],
    'KHU VỰC (20KM)': [
      {
        'id': '4',
        'title': 'Rắn Hổ Đất',
        'distance': '12.3 km',
        'timeAgo': '30 phút trước',
        'image': 'https://picsum.photos/400/303',
        'danger': 'TRUNG BÌNH',
        'dangerLevel': 'Trung Bình',
        'aiAccuracy': '88%',
        'address': '56 Cách Mạng Tháng 8, Phường 6, Quận Tân Bình, TP.HCM',
        'quantity': 1,
        'price': '300.000',
        'viewers': 4,
      },
      {
        'id': '5',
        'title': 'Rắn Nước Vạch Đôi',
        'distance': '15.7 km',
        'timeAgo': '45 phút trước',
        'image': 'https://picsum.photos/400/304',
        'danger': 'YẾU',
        'dangerLevel': 'Thấp',
        'aiAccuracy': '90%',
        'address': '12 Hoàng Văn Thụ, Phường 4, Quận Tân Bình, TP.HCM',
        'quantity': 2,
        'price': '250.000',
        'viewers': 1,
      },
    ],
    'RỘNG (30KM)': [
      {
        'id': '6',
        'title': 'Rắn Cạp Nia',
        'distance': '22.1 km',
        'timeAgo': '1 giờ trước',
        'image': 'https://picsum.photos/400/305',
        'danger': 'TRUNG BÌNH',
        'dangerLevel': 'Trung Bình',
        'aiAccuracy': '85%',
        'address': '234 Lê Văn Việt, Phường Hiệp Phú, Quận 9, TP.HCM',
        'quantity': 1,
        'price': '400.000',
        'viewers': 2,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFBF5),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Filter Sort Options
            _buildFilterSortRow(),
            
            // Job List by Area
            Expanded(
              child: _buildJobListByArea(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          const Text(
            'Đơn Có Thể Nhận',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const Spacer(),
          
          // Online Status Toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isOnline ? const Color(0xFFFF6B35).withOpacity(0.1) : const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isOnline ? const Color(0xFFFF6B35) : const Color(0xFFDDDDDD),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  'TRỰC TUYẾN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _isOnline ? const Color(0xFFFF6B35) : const Color(0xFF999999),
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _isOnline,
                  onChanged: (value) {
                    setState(() {
                      _isOnline = value;
                    });
                  },
                  activeColor: const Color(0xFFFF6B35),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          
          // Menu Icon
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Color(0xFF333333)),
            onPressed: () {
              // TODO: Show menu
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSortRow() {
    final filters = ['Gần nhất', 'Mới nhất', 'Giá cao'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.navigation, color: Color(0xFFFF6B35), size: 20),
          const SizedBox(width: 8),
          ...filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFF6B35).withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFF6B35) : const Color(0xFFDDDDDD),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? const Color(0xFFFF6B35) : const Color(0xFF666666),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
          const Spacer(),
          const Icon(Icons.tune, color: Color(0xFF666666), size: 20),
        ],
      ),
    );
  }

  Widget _buildJobListByArea() {
    // Gom tất cả jobs từ các area
    List<Map<String, dynamic>> allJobs = [];
    _jobsByArea.forEach((area, jobs) {
      for (var job in jobs) {
        allJobs.add({...job, 'area': area});
      }
    });
    
    // Sort theo filter đã chọn
    switch (_selectedFilter) {
      case 'Gần nhất':
        allJobs.sort((a, b) {
          double distanceA = double.parse(a['distance'].replaceAll(' km', ''));
          double distanceB = double.parse(b['distance'].replaceAll(' km', ''));
          return distanceA.compareTo(distanceB);
        });
        break;
      case 'Mới nhất':
        allJobs.sort((a, b) {
          int timeA = _parseTimeAgo(a['timeAgo']);
          int timeB = _parseTimeAgo(b['timeAgo']);
          return timeA.compareTo(timeB);
        });
        break;
      case 'Giá cao':
        allJobs.sort((a, b) {
          double priceA = double.parse(a['price'].replaceAll('.', ''));
          double priceB = double.parse(b['price'].replaceAll('.', ''));
          return priceB.compareTo(priceA); // Giảm dần
        });
        break;
    }
    
    // Nhóm lại theo area sau khi sort
    Map<String, List<Map<String, dynamic>>> sortedJobsByArea = {};
    for (var job in allJobs) {
      String area = job['area'];
      if (!sortedJobsByArea.containsKey(area)) {
        sortedJobsByArea[area] = [];
      }
      sortedJobsByArea[area]!.add(job);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: sortedJobsByArea.keys.length,
      itemBuilder: (context, index) {
        final areaName = sortedJobsByArea.keys.elementAt(index);
        final jobs = sortedJobsByArea[areaName]!;
        final count = jobs.length;
        
        // Xác định màu cho từng khu vực
        Color areaColor;
        if (areaName.contains('GẦN BẠN')) {
          areaColor = const Color(0xFF28A745); // Xanh lá
        } else if (areaName.contains('KHU VỰC')) {
          areaColor = const Color(0xFFFFC107); // Vàng
        } else {
          areaColor = const Color(0xFFFF6B35); // Cam
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Area Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFFFFFBF5),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: areaColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: areaColor, width: 1.5),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: areaColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    areaName.split('(')[0].trim(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${areaName.split('(')[1]}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$count yêu cầu',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: areaColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // Job Cards
            ...jobs.map((job) => _buildJobCard(job)).toList(),
          ],
        );
      },
    );
  }
  
  // Helper function để parse "X phút trước" thành số phút
  int _parseTimeAgo(String timeAgo) {
    if (timeAgo.contains('phút')) {
      return int.parse(timeAgo.split(' ')[0]);
    } else if (timeAgo.contains('giờ')) {
      return int.parse(timeAgo.split(' ')[0]) * 60;
    } else if (timeAgo.contains('ngày')) {
      return int.parse(timeAgo.split(' ')[0]) * 60 * 24;
    }
    return 0;
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    final Color dangerColor = _getDangerColor(job['danger']);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với badges
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Distance Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF28A745),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.near_me, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        job['distance'],
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                
                // Time Badge
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Color(0xFF999999)),
                    const SizedBox(width: 4),
                    Text(
                      job['timeAgo'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                
                // Menu
                const Icon(Icons.more_horiz, color: Color(0xFF999999), size: 20),
              ],
            ),
          ),
          
          // Snake Image with Danger Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    color: const Color(0xFFF0F0F0),
                    child: Image.network(
                      job['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.image, size: 60, color: Color(0xFFCCCCCC)),
                        );
                      },
                    ),
                  ),
                ),
                
                // Danger Badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: dangerColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          job['danger'],
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Title & AI Accuracy
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with Quantity
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        job['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'SL:0${job['quantity']}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // AI Accuracy
                Row(
                  children: [
                    const Icon(Icons.verified_user, size: 16, color: Color(0xFF28A745)),
                    const SizedBox(width: 6),
                    Text(
                      'AI Xác nhận: ${job['aiAccuracy']}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF28A745),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Address
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.location_on, size: 18, color: Color(0xFFFF6B35)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job['address'],
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Price
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${job['price']}đ',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B35),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Viewers
          if (job['viewers'] > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  // Avatar stack
                  SizedBox(
                    width: 50,
                    height: 24,
                    child: Stack(
                      children: List.generate(
                        job['viewers'] > 3 ? 3 : job['viewers'],
                        (index) => Positioned(
                          left: index * 12.0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDDDDDD),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.person, size: 12, color: Color(0xFF999999)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${job['viewers']} người đang xem',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 12),
          
          // View Detail Button
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RescuerRequestDetailScreen(requestData: job),
                      fullscreenDialog: false,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'XEM CHI TIẾT',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDangerColor(String danger) {
    switch (danger) {
      case 'ĐỘC MẠNH':
        return const Color(0xFFDC3545);
      case 'TRUNG BÌNH':
        return const Color(0xFFFFC107);
      case 'YẾU':
        return const Color(0xFF28A745);
      default:
        return const Color(0xFF999999);
    }
  }
}
