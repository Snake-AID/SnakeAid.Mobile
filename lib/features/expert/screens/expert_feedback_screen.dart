import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Expert Feedback Screen - View and respond to customer reviews
/// Màn hình đánh giá & phản hồi của Expert
class ExpertFeedbackScreen extends StatefulWidget {
  const ExpertFeedbackScreen({super.key});

  @override
  State<ExpertFeedbackScreen> createState() => _ExpertFeedbackScreenState();
}

class _ExpertFeedbackScreenState extends State<ExpertFeedbackScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = [
    'Tất cả',
    '5 sao',
    'Có bình luận',
    'Chưa phản hồi',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F8),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildOverallRatingCard(),
            _buildHighlightsCard(),
            _buildFilterTabs(),
            _buildReviewList(),
            _buildBottomStatsCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF7F6F8),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF131018)),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Đánh Giá & Phản Hồi',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF131018),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.tune, color: Color(0xFF131018)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildOverallRatingCard() {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating Score
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    '4.9',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF131018),
                    ),
                  ),
                  const Text(
                    '/5.0',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < 5 ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFFD700),
                    size: 20,
                  );
                }),
              ),
              const SizedBox(height: 8),
              const Text(
                '156 đánh giá',
                style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
              ),
            ],
          ),
          const SizedBox(width: 32),
          // Rating Distribution
          Expanded(
            child: Column(
              children: [
                _buildRatingBar(5, 120, 77, const Color(0xFF10B981)),
                const SizedBox(height: 8),
                _buildRatingBar(4, 28, 18, const Color(0xFF84CC16)),
                const SizedBox(height: 8),
                _buildRatingBar(3, 6, 4, const Color(0xFFF59E0B)),
                const SizedBox(height: 8),
                _buildRatingBar(2, 2, 1, const Color(0xFFF97316)),
                const SizedBox(height: 8),
                _buildRatingBar(1, 0, 0, const Color(0xFFEF4444)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, int count, int percentage, Color color) {
    return Row(
      children: [
        Text(
          '$stars⭐',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF131018),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      count > 0 ? '$count' : '',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '$percentage%',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTagChip('Kiến thức chuyên sâu (102)'),
              _buildTagChip('Tư vấn chi tiết (95)'),
              _buildTagChip('Nhiệt tình (78)'),
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Đã phản hồi',
                      style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '99%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF131018),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thời gian phản hồi',
                      style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '< 1 giờ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF131018),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF6C47C2).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6C47C2),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5))),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final isSelected = _selectedFilter == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 12, right: 24),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected
                                ? const Color(0xFF6C47C2)
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFF6C47C2)
                              : const Color(0xFF999999),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          Row(
            children: [
              const Text(
                'Mới nhất',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF666666),
                ),
              ),
              const Icon(Icons.expand_more, size: 18, color: Color(0xFF666666)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewList() {
    return Column(
      children: [
        _buildReviewCard(
          userName: 'Trần Thị C',
          userAvatar: 'https://via.placeholder.com/40',
          date: '20 Thg 12',
          rating: 5,
          consultationCode: '#EXP-2025-5678',
          comment:
              'Bác sĩ tư vấn rất chi tiết và kiên nhẫn. Giải đáp mọi thắc mắc của tôi về cách xử lý vết rắn cắn. Kiến thức chuyên môn rất sâu!',
          images: ['https://via.placeholder.com/80'],
          tags: ['Kiến thức chuyên sâu', 'Tư vấn chi tiết'],
          hasResponse: true,
          expertName: 'TS. Nguyễn Văn A',
          expertAvatar: 'https://via.placeholder.com/32',
          responseDate: '20 Thg 12',
          response:
              'Cảm ơn bạn đã tin tưởng! Hãy nhớ theo dõi các dấu hiệu và liên hệ ngay nếu có bất thường.',
        ),
        const SizedBox(height: 12),
        _buildReviewCard(
          userName: 'Phạm Văn D',
          userAvatar: 'https://via.placeholder.com/40',
          date: '18 Thg 12',
          rating: 5,
          consultationCode: '#EXP-2025-5432',
          comment:
              'Rất nhiệt tình và phản hồi nhanh chóng. Cảm ơn bác sĩ đã giúp đỡ trong tình huống khẩn cấp!',
          tags: ['Nhiệt tình', 'Phản hồi nhanh'],
          hasResponse: false,
        ),
      ],
    );
  }

  Widget _buildReviewCard({
    required String userName,
    required String userAvatar,
    required String date,
    required int rating,
    required String consultationCode,
    required String comment,
    List<String>? images,
    required List<String> tags,
    required bool hasResponse,
    String? expertName,
    String? expertAvatar,
    String? responseDate,
    String? response,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(userAvatar),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF131018),
                        ),
                      ),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFFD700),
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                Text(
                  consultationCode,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF999999),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: Color(0xFF999999),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
              height: 1.5,
            ),
          ),
          if (images != null && images.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: images
                  .map(
                    (url) => Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(url),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C47C2).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6C47C2),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const Divider(height: 32),
          if (hasResponse && response != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6C47C2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(expertAvatar!),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              expertName!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF131018),
                              ),
                            ),
                            Text(
                              'Đã phản hồi $responseDate',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          response,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF6C47C2)),
                  foregroundColor: const Color(0xFF6C47C2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Phản Hồi',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.star, 'Điểm mạnh', 'Kiến thức sâu'),
          _buildStatItem(Icons.comment, 'Góp ý cải thiện', '1'),
          _buildStatItem(Icons.repeat, 'Khách quay lại', '22%'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF6C47C2), size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF131018),
          ),
        ),
      ],
    );
  }
}
