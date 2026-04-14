import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../consultation/models/review_model.dart';
import '../../consultation/repository/consultation_repository.dart';

/// Expert Feedback Screen - View real reviews from API
class ExpertFeedbackScreen extends ConsumerStatefulWidget {
  const ExpertFeedbackScreen({super.key});

  @override
  ConsumerState<ExpertFeedbackScreen> createState() =>
      _ExpertFeedbackScreenState();
}

class _ExpertFeedbackScreenState extends ConsumerState<ExpertFeedbackScreen> {
  int _selectedFilter = 0;
  bool _showNewestFirst = true;
  bool _isLoading = true;
  String? _error;
  List<ReviewModel> _reviews = [];

  final List<String> _filters = ['Tất cả', '5 sao', 'Có bình luận'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReviews();
    });
  }

  Future<void> _loadReviews() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
        _error = 'Không tìm thấy thông tin chuyên gia';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = ref.read(consultationRepositoryProvider);
      final reviews = await repo.getExpertReviews(currentUser.id, pageSize: 100);
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (!mounted) return;
      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Không thể tải đánh giá. Vui lòng thử lại.';
      });
    }
  }

  List<ReviewModel> get _filteredReviews {
    final list = _reviews.where((review) {
      if (_selectedFilter == 1) {
        return review.rating.round() == 5;
      }
      if (_selectedFilter == 2) {
        return review.comment.trim().isNotEmpty;
      }
      return true;
    }).toList();

    list.sort((a, b) => _showNewestFirst
        ? b.createdAt.compareTo(a.createdAt)
        : a.createdAt.compareTo(b.createdAt));

    return list;
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0;
    final total = _reviews.fold<double>(0, (sum, r) => sum + r.rating);
    return total / _reviews.length;
  }

  int _countByStar(int star) {
    return _reviews.where((r) => r.rating.round() == star).length;
  }

  String _formatDate(DateTime dateTime) {
    const months = [
      'Thg 1',
      'Thg 2',
      'Thg 3',
      'Thg 4',
      'Thg 5',
      'Thg 6',
      'Thg 7',
      'Thg 8',
      'Thg 9',
      'Thg 10',
      'Thg 11',
      'Thg 12',
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF131018)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Danh sách đánh giá',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF131018),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadReviews,
            icon: const Icon(Icons.refresh, color: Color(0xFF131018)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadReviews,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildErrorState()
                : _buildContent(),
      ),
    );
  }

  Widget _buildErrorState() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
        const SizedBox(height: 12),
        Text(
          _error ?? 'Đã có lỗi xảy ra',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            onPressed: _loadReviews,
            child: const Text('Thử lại'),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final filtered = _filteredReviews;

    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        _buildSummaryCard(),
        _buildFilterTabs(),
        const SizedBox(height: 8),
        if (filtered.isEmpty)
          _buildEmptyState()
        else
          ...filtered.map(_buildReviewCard),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final totalReviews = _reviews.length;
    final withComment = _reviews.where((r) => r.comment.trim().isNotEmpty).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF1EDFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF131018),
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        final filled = index < _averageRating.round();
                        return Icon(
                          filled ? Icons.star : Icons.star_border,
                          size: 18,
                          color: const Color(0xFFF59E0B),
                        );
                      }),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$totalReviews đánh giá',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    for (int star = 5; star >= 1; star--) _buildRatingBar(star),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildQuickStat('Có bình luận', '$withComment'),
              ),
              Expanded(
                child: _buildQuickStat('Đánh giá 5 sao', '${_countByStar(5)}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A8A))),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF131018),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBar(int star) {
    final count = _countByStar(star);
    final percent = _reviews.isEmpty ? 0.0 : count / _reviews.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '$star',
              style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
            ),
          ),
          const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 8,
                backgroundColor: const Color(0xFFE7E7EF),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF6C47C2)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final isSelected = _selectedFilter == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6C47C2)
                            : const Color(0xFFEAE8F3),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF4B4561),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => setState(() => _showNewestFirst = !_showNewestFirst),
            icon: Icon(
              _showNewestFirst ? Icons.arrow_downward : Icons.arrow_upward,
              size: 16,
            ),
            label: Text(_showNewestFirst ? 'Mới nhất' : 'Cũ nhất'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.rate_review_outlined, size: 48, color: Color(0xFFB7B7C7)),
          SizedBox(height: 10),
          Text(
            'Chưa có đánh giá phù hợp',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A4A55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(review),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.patientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1B29),
                      ),
                    ),
                    Text(
                      _formatDate(review.createdAt),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating.round() ? Icons.star : Icons.star_border,
                    color: const Color(0xFFF59E0B),
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          if (review.comment.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF3B3B46),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(ReviewModel review) {
    final avatar = review.patientAvatarUrl?.trim() ?? '';
    final initial = review.patientName.isNotEmpty
        ? review.patientName.trim().substring(0, 1).toUpperCase()
        : '?';

    if (avatar.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(avatar),
      );
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: const Color(0xFFE8E3F8),
      child: Text(
        initial,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF4E3A82),
        ),
      ),
    );
  }
}
