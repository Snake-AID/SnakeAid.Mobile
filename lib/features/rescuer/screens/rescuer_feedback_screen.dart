import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../snake_catching/repository/feedback_repository.dart';

/// Rescuer Feedback Screen - View customer reviews
class RescuerFeedbackScreen extends ConsumerStatefulWidget {
  final String targetUserId;
  const RescuerFeedbackScreen({super.key, required this.targetUserId});

  @override
  ConsumerState<RescuerFeedbackScreen> createState() =>
      _RescuerFeedbackScreenState();
}

class _RescuerFeedbackScreenState extends ConsumerState<RescuerFeedbackScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['Tất cả', '5 sao', '4 sao', 'Có bình luận'];

  List<FeedbackData> _feedbacks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    try {
      final data = await ref
          .read(feedbackRepositoryProvider)
          .getFeedbacksByUser(widget.targetUserId);
      if (mounted) {
        setState(() {
          _feedbacks = data
            ..sort(
              (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
                a.createdAt ?? DateTime.now(),
              ),
            );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<FeedbackData> get _filteredFeedbacks {
    if (_selectedFilter == 0) return _feedbacks;
    if (_selectedFilter == 1)
      return _feedbacks.where((f) => f.rating == 5).toList();
    if (_selectedFilter == 2)
      return _feedbacks.where((f) => f.rating == 4).toList();
    if (_selectedFilter == 3)
      return _feedbacks
          .where((f) => f.comments != null && f.comments!.isNotEmpty)
          .toList();
    return _feedbacks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF8800)),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildOverallRatingCard(),
                  _buildFilterTabs(),
                  _buildReviewList(),
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
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1D150C)),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Đánh Giá',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1D150C),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.tune, color: Color(0xFF1D150C)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildOverallRatingCard() {
    final total = _feedbacks.length;
    final average = total > 0
        ? _feedbacks.map((f) => f.rating).reduce((a, b) => a + b) / total
        : 0.0;

    final count5 = _feedbacks.where((f) => f.rating == 5).length;
    final count4 = _feedbacks.where((f) => f.rating == 4).length;
    final count3 = _feedbacks.where((f) => f.rating == 3).length;
    final count2 = _feedbacks.where((f) => f.rating == 2).length;
    final count1 = _feedbacks.where((f) => f.rating == 1).length;

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
                  Text(
                    average.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1D150C),
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
                    index < average.floor()
                        ? Icons.star
                        : (index < average
                              ? Icons.star_half
                              : Icons.star_border),
                    color: const Color(0xFFFFD700),
                    size: 20,
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                '$total đánh giá',
                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
              ),
            ],
          ),
          const SizedBox(width: 32),
          // Rating Distribution
          Expanded(
            child: Column(
              children: [
                _buildRatingBar(
                  5,
                  count5,
                  total > 0 ? (count5 / total * 100).round() : 0,
                  const Color(0xFF10B981),
                ),
                const SizedBox(height: 8),
                _buildRatingBar(
                  4,
                  count4,
                  total > 0 ? (count4 / total * 100).round() : 0,
                  const Color(0xFF84CC16),
                ),
                const SizedBox(height: 8),
                _buildRatingBar(
                  3,
                  count3,
                  total > 0 ? (count3 / total * 100).round() : 0,
                  const Color(0xFFF59E0B),
                ),
                const SizedBox(height: 8),
                _buildRatingBar(
                  2,
                  count2,
                  total > 0 ? (count2 / total * 100).round() : 0,
                  const Color(0xFFF97316),
                ),
                const SizedBox(height: 8),
                _buildRatingBar(
                  1,
                  count1,
                  total > 0 ? (count1 / total * 100).round() : 0,
                  const Color(0xFFEF4444),
                ),
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
            color: Color(0xFF1D150C),
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
              _buildTagChip('Nhanh chóng (95)'),
              _buildTagChip('Chuyên nghiệp (87)'),
              _buildTagChip('Thân thiện (72)'),
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
                      '98%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D150C),
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
                      '< 2 giờ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D150C),
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
        color: const Color(0xFFFF8800).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFFFF8800),
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
                                ? const Color(0xFFFF8800)
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
                              ? const Color(0xFFFF8800)
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
    final list = _filteredFeedbacks;
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'Chưa có đánh giá nào.',
            style: TextStyle(color: Color(0xFF999999), fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      children: list
          .map(
            (feedback) => _buildReviewCard(
              userName: feedback.raterName ?? 'Người dùng',
              userAvatar:
                  'https://via.placeholder.com/40', // Hardcoded avatar for now
              date: feedback.createdAt != null
                  ? '${feedback.createdAt!.day}/${feedback.createdAt!.month}/${feedback.createdAt!.year}'
                  : 'Vừa xong',
              rating: feedback.rating,
              type: feedback.type,
              comment: feedback.comments?.isNotEmpty == true
                  ? feedback.comments!
                  : 'Không có',
              tags: const [], // Mocking tags since api doesn't have it yet
            ),
          )
          .toList(),
    );
  }

  String _getTypeText(String type) {
    switch (type) {
      case 'Catching':
        return 'Đơn bắt rắn';
      case 'Emergency':
        return 'Đơn rắn cắn';
      case 'Consultation':
        return 'Đơn tư vấn';
      default:
        return 'Đơn dịch vụ';
    }
  }

  Widget _buildReviewCard({
    required String userName,
    required String userAvatar,
    required String date,
    required int rating,
    required String type,
    required String comment,
    List<String>? images,
    required List<String> tags,
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
                          color: Color(0xFF1D150C),
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
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getTypeText(type),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
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
                      color: const Color(0xFFFF8800).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFFF8800),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
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
          _buildStatItem(Icons.star, 'Điểm mạnh', 'Nhanh chóng'),
          _buildStatItem(Icons.comment, 'Góp ý cải thiện', '2'),
          _buildStatItem(Icons.repeat, 'Khách quay lại', '15%'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFF8800), size: 24),
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
            color: Color(0xFF1D150C),
          ),
        ),
      ],
    );
  }
}
