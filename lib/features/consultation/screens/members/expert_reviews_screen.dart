import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/review_model.dart';
import '../../repository/consultation_repository.dart';

class ExpertReviewsScreen extends ConsumerStatefulWidget {
  final String expertId;
  final String expertName;
  final double initialRating;
  final int initialReviewCount;

  const ExpertReviewsScreen({
    super.key,
    required this.expertId,
    required this.expertName,
    required this.initialRating,
    required this.initialReviewCount,
  });

  @override
  ConsumerState<ExpertReviewsScreen> createState() =>
      _ExpertReviewsScreenState();
}

class _ExpertReviewsScreenState extends ConsumerState<ExpertReviewsScreen> {
  static const Color _primaryColor = Color(0xFF228B22);

  final List<ReviewModel> _reviews = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _loadReviews(refresh: true);
  }

  Future<void> _loadReviews({required bool refresh}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentPage = 1;
        _totalPages = 1;
        _totalItems = 0;
      });
    } else {
      if (_isLoadingMore || _currentPage >= _totalPages) return;
      setState(() => _isLoadingMore = true);
    }

    try {
      final pageToLoad = refresh ? 1 : (_currentPage + 1);
      final result = await ref
          .read(consultationRepositoryProvider)
          .getExpertReviewsPaged(
            widget.expertId,
            pageNumber: pageToLoad,
            pageSize: 10,
          );

      if (!mounted) return;

      setState(() {
        if (refresh) {
          _reviews
            ..clear()
            ..addAll(result.items);
          _isLoading = false;
        } else {
          _reviews.addAll(result.items);
          _isLoadingMore = false;
        }

        _currentPage = result.currentPage;
        _totalPages = result.totalPages;
        _totalItems = result.totalItems;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (refresh) {
          _isLoading = false;
          _error = 'Không thể tải danh sách đánh giá.';
        } else {
          _isLoadingMore = false;
        }
      });
    }
  }

  String _formatReviewDate(DateTime value) {
    final local = value.toLocal();
    return DateFormat('dd/MM/yyyy HH:mm').format(local);
  }

  double get _averageRating {
    if (_reviews.isEmpty) return widget.initialRating;
    final sum = _reviews.fold<double>(0, (prev, e) => prev + e.rating);
    return sum / _reviews.length;
  }

  int get _displayTotalReviews {
    if (_totalItems > 0) return _totalItems;
    if (_reviews.isNotEmpty) return _reviews.length;
    return widget.initialReviewCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1F2937)),
        title: const Text(
          'Tất Cả Đánh Giá',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryColor))
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _loadReviews(refresh: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => _loadReviews(refresh: true),
              color: _primaryColor,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 16),
                  if (_reviews.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: Center(
                        child: Text(
                          'Chưa có đánh giá nào',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ),
                    )
                  else
                    ..._reviews.map(_buildReviewCard),
                  if (_currentPage < _totalPages) ...[
                    const SizedBox(height: 6),
                    OutlinedButton(
                      onPressed: _isLoadingMore
                          ? null
                          : () => _loadReviews(refresh: false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _primaryColor),
                        foregroundColor: _primaryColor,
                      ),
                      child: _isLoadingMore
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _primaryColor,
                              ),
                            )
                          : const Text('Xem thêm đánh giá'),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star, color: _primaryColor, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.expertName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_averageRating.toStringAsFixed(1)} / 5.0',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_displayTotalReviews} đánh giá',
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    final safeComment = review.comment.trim().isEmpty
        ? 'Không có nhận xét.'
        : review.comment.trim();
    final avatarUrl = (review.patientAvatarUrl ?? '').trim();
    final hasAvatar = avatarUrl.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFE5E7EB),
                backgroundImage: hasAvatar
                    ? CachedNetworkImageProvider(avatarUrl)
                    : null,
                child: !hasAvatar
                    ? Text(
                        review.patientName.trim().isEmpty
                            ? '?'
                            : review.patientName
                                  .trim()
                                  .substring(0, 1)
                                  .toUpperCase(),
                      )
                    : null,
              ),
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
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatReviewDate(review.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < review.rating.round() ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            safeComment,
            style: const TextStyle(color: Color(0xFF374151), height: 1.45),
          ),
        ],
      ),
    );
  }
}
