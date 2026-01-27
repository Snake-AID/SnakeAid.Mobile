import 'package:flutter/material.dart';

/// Health History Detail Screen - Shows detailed information about a snake bite incident
class HealthHistoryDetailScreen extends StatelessWidget {
  final String date;
  final String severity;
  final Color severityColor;
  final String snakeSpecies;
  final bool hasAIDetection;
  final String location;

  const HealthHistoryDetailScreen({
    super.key,
    required this.date,
    required this.severity,
    required this.severityColor,
    required this.snakeSpecies,
    required this.hasAIDetection,
    required this.location,
  });

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
                        'Chi Tiết Ca Rắn Cắn',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    // Share button
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.share,
                          color: Color(0xFF333333),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Chia sẻ - Đang phát triển')),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF228B22).withOpacity(0.1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: const Color(0xFF228B22),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Đã hoàn thành điều trị',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF228B22),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Card
                        Container(
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    date,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: severityColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      severity,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: severityColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _InfoRow(
                                label: 'Loài rắn:',
                                value: snakeSpecies,
                                hasAIBadge: hasAIDetection,
                              ),
                              const SizedBox(height: 12),
                              _InfoRow(
                                icon: Icons.location_on,
                                label: 'Địa điểm:',
                                value: location,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Symptoms Section
                        _SectionHeader(title: 'Triệu Chứng'),
                        const SizedBox(height: 12),
                        _SymptomCard(
                          symptoms: [
                            'Sưng tấy vùng vết cắn',
                            'Đau đớn nghiêm trọng',
                            'Khó thở nhẹ',
                            'Chảy máu vết thương',
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Treatment Timeline
                        _SectionHeader(title: 'Tiến Trình Điều Trị'),
                        const SizedBox(height: 12),
                        _TimelineCard(
                          events: [
                            TimelineEvent(
                              time: '14:30',
                              title: 'Báo cáo ca cấp cứu',
                              description: 'Gọi SOS qua ứng dụng',
                              icon: Icons.warning_amber,
                              iconColor: const Color(0xFFD32F2F),
                            ),
                            TimelineEvent(
                              time: '14:45',
                              title: 'Sơ cứu ban đầu',
                              description: 'Hướng dẫn qua video call',
                              icon: Icons.video_call,
                              iconColor: const Color(0xFF228B22),
                            ),
                            TimelineEvent(
                              time: '15:10',
                              title: 'Đến bệnh viện',
                              description: 'BV Chợ Rẫy - Khoa Cấp Cứu',
                              icon: Icons.local_hospital,
                              iconColor: const Color(0xFF007AFF),
                            ),
                            TimelineEvent(
                              time: '15:30',
                              title: 'Tiêm huyết thanh',
                              description: '2 liều huyết thanh kháng độc',
                              icon: Icons.medication,
                              iconColor: const Color(0xFF228B22),
                            ),
                            TimelineEvent(
                              time: '18:00',
                              title: 'Xuất viện',
                              description: 'Tình trạng ổn định',
                              icon: Icons.check_circle,
                              iconColor: const Color(0xFF228B22),
                              isLast: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Treatment Details
                        _SectionHeader(title: 'Chi Tiết Điều Trị'),
                        const SizedBox(height: 12),
                        _InfoCard(
                          items: [
                            InfoItem(
                              label: 'Bệnh viện',
                              value: 'BV Chợ Rẫy',
                              icon: Icons.local_hospital,
                            ),
                            InfoItem(
                              label: 'Bác sĩ điều trị',
                              value: 'BS. Nguyễn Văn A',
                              icon: Icons.person,
                            ),
                            InfoItem(
                              label: 'Huyết thanh sử dụng',
                              value: '2 liều kháng nọc độc Hổ Mang',
                              icon: Icons.medical_information,
                            ),
                            InfoItem(
                              label: 'Thời gian nằm viện',
                              value: '3.5 giờ',
                              icon: Icons.access_time,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Emergency Contact
                        _SectionHeader(title: 'Cứu Hộ Viên'),
                        const SizedBox(height: 12),
                        Container(
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
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF228B22).withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: const Color(0xFF228B22),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Trần Văn Cường',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 14,
                                          color: const Color(0xFFFFC107),
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          '4.9 • 120 ca thành công',
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
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF228B22),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Text(
                                  'Liên hệ',
                                  style: TextStyle(
                                    color: Color(0xFF228B22),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Notes
                        _SectionHeader(title: 'Ghi Chú'),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F8F6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFDDDDDD),
                            ),
                          ),
                          child: const Text(
                            'Bệnh nhân đã được hướng dẫn sơ cứu qua video call trước khi đến bệnh viện. Rắn hổ mang được xác định qua AI. Điều trị kịp thời, không có biến chứng nghiêm trọng.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF333333),
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
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
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final bool hasAIBadge;

  const _InfoRow({
    required this.label,
    required this.value,
    this.icon,
    this.hasAIBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF666666),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              if (hasAIBadge) ...[
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
        ),
      ],
    );
  }
}

class _SymptomCard extends StatelessWidget {
  final List<String> symptoms;

  const _SymptomCard({required this.symptoms});

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
        children: symptoms
            .map(
              (symptom) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF228B22),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        symptom,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class TimelineEvent {
  final String time;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final bool isLast;

  TimelineEvent({
    required this.time,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    this.isLast = false,
  });
}

class _TimelineCard extends StatelessWidget {
  final List<TimelineEvent> events;

  const _TimelineCard({required this.events});

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
        children: events
            .map(
              (event) => _TimelineItem(event: event),
            )
            .toList(),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final TimelineEvent event;

  const _TimelineItem({required this.event});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: event.iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                event.icon,
                size: 16,
                color: event.iconColor,
              ),
            ),
            if (!event.isLast)
              Container(
                width: 2,
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: const Color(0xFFDDDDDD),
              ),
          ],
        ),
        const SizedBox(width: 12),
        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: event.isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.time,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: event.iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class InfoItem {
  final String label;
  final String value;
  final IconData icon;

  InfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _InfoCard extends StatelessWidget {
  final List<InfoItem> items;

  const _InfoCard({required this.items});

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
        children: items
            .asMap()
            .entries
            .map(
              (entry) => Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF228B22).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          entry.value.icon,
                          size: 16,
                          color: const Color(0xFF228B22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.value.label,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.value.value,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (entry.key < items.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Divider(
                        height: 1,
                        color: const Color(0xFFDDDDDD),
                      ),
                    ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
