import 'package:flutter/material.dart';
import 'health_history_detail_screen.dart';

/// Health History Screen - Shows all snake bite incidents
class HealthHistoryScreen extends StatelessWidget {
  const HealthHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top App Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFFDDDDDD),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 56,
                child: Stack(
                  children: [
                    // Back button
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFF333333),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    // Title - centered
                    Center(
                      child: const Text(
                        'Lịch Sử Sức Khỏe',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    // Filter button
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.filter_list,
                          color: Color(0xFF333333),
                        ),
                        onPressed: () {
                          // TODO: Implement filter
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Bộ lọc - Đang phát triển')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Summary Card
                  Container(
                    padding: const EdgeInsets.all(24),
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
                      children: [
                        const Text(
                          '5 ca rắn cắn',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Lần cuối: 3 tháng trước',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF228B22).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: const Color(0xFF228B22),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Không có ca đang theo dõi',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF228B22),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Incident Cards
                  _IncidentCard(
                    date: '15 Thg 9, 2025 - 14:30',
                    severity: 'Nguy kịch',
                    severityColor: const Color(0xFFD32F2F),
                    snakeSpecies: 'Rắn Hổ Mang',
                    hasAIDetection: true,
                    location: 'Quận 1, TP.HCM',
                    onViewDetails: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const HealthHistoryDetailScreen(
                            date: '15 Thg 9, 2025 - 14:30',
                            severity: 'Nguy kịch',
                            severityColor: Color(0xFFD32F2F),
                            snakeSpecies: 'Rắn Hổ Mang',
                            hasAIDetection: true,
                            location: 'Quận 1, TP.HCM',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _IncidentCard(
                    date: '22 Thg 6, 2025 - 09:15',
                    severity: 'Nặng',
                    severityColor: const Color(0xFFF0AD4E),
                    snakeSpecies: 'Rắn Lục',
                    hasAIDetection: false,
                    location: 'Huyện Cần Giờ, TP.HCM',
                    onViewDetails: () {},
                  ),
                  const SizedBox(height: 12),
                  _IncidentCard(
                    date: '01 Thg 3, 2025 - 18:00',
                    severity: 'Nhẹ',
                    severityColor: const Color(0xFF5CB85C),
                    snakeSpecies: 'Rắn Cạp Nia',
                    hasAIDetection: false,
                    location: 'Thành phố Thủ Đức, TP.HCM',
                    onViewDetails: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final String date;
  final String severity;
  final Color severityColor;
  final String snakeSpecies;
  final bool hasAIDetection;
  final String location;
  final VoidCallback onViewDetails;

  const _IncidentCard({
    required this.date,
    required this.severity,
    required this.severityColor,
    required this.snakeSpecies,
    required this.hasAIDetection,
    required this.location,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
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
          // Date and Severity Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  severity,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: severityColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Snake Species
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Loài rắn:',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              Row(
                children: [
                  Text(
                    snakeSpecies,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  if (hasAIDetection) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8A2BE2).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'AI',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8A2BE2),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trạng thái:',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: const Color(0xFF228B22),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Đã hoàn thành điều trị',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF228B22),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Location
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: const Color(0xFF666666),
              ),
              const SizedBox(width: 4),
              Text(
                location,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Divider and View Details
          Container(
            height: 1,
            color: const Color(0xFFDDDDDD),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: onViewDetails,
              child: const Text(
                'Xem Chi Tiết',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF007AFF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty State Widget - Use when no health history available
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_information_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có lịch sử sức khỏe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Các ca rắn cắn sẽ được lưu tại đây.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
