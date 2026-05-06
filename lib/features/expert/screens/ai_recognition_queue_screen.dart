import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/ai_recognition_review_models.dart';
import '../providers/ai_recognition_review_provider.dart';

/// Expert AI Recognition Review — Queue & History Screen
class AiRecognitionQueueScreen extends ConsumerStatefulWidget {
  const AiRecognitionQueueScreen({super.key});

  @override
  ConsumerState<AiRecognitionQueueScreen> createState() =>
      _AiRecognitionQueueScreenState();
}

class _AiRecognitionQueueScreenState
    extends ConsumerState<AiRecognitionQueueScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load history lazily when user switches to that tab
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        ref.read(aiReviewHistoryProvider.notifier).load();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queueState = ref.watch(aiReviewQueueProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F8),
      appBar: _buildAppBar(queueState),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [_QueueTabContent(), _HistoryTabContent()],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AiReviewQueueState queueState) {
    final pendingCount = queueState.items.length;
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF131018)),
        onPressed: () => context.pop(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Xem Xét AI Nhận Diện',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF131018),
            ),
          ),
          if (pendingCount > 0 && !queueState.isLoading) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$pendingCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFE5E7EB)),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF10B981),
        indicatorWeight: 3,
        labelColor: const Color(0xFF10B981),
        unselectedLabelColor: const Color(0xFF6B7280),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'Hàng Đợi'),
          Tab(text: 'Đã Xử Lý'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Queue Tab
// ---------------------------------------------------------------------------

class _QueueTabContent extends ConsumerStatefulWidget {
  const _QueueTabContent();

  @override
  ConsumerState<_QueueTabContent> createState() => _QueueTabContentState();
}

class _QueueTabContentState extends ConsumerState<_QueueTabContent> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(aiReviewQueueProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiReviewQueueProvider);

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF10B981)),
      );
    }

    if (state.error != null && state.items.isEmpty) {
      return _buildErrorState(state.error!);
    }

    if (state.items.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: const Color(0xFF10B981),
      onRefresh: () =>
          ref.read(aiReviewQueueProvider.notifier).load(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF10B981),
                  strokeWidth: 2,
                ),
              ),
            );
          }
          return _ReviewQueueCard(
            item: state.items[index],
            onTap: () => context.push(
              '/expert-ai-review/${state.items[index].aiResult.id}',
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF10B981),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Không có ảnh cần xem xét',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF131018),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tất cả ảnh AI đã được xử lý hoặc chưa có ảnh mới',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, color: Color(0xFF9CA3AF), size: 48),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(aiReviewQueueProvider.notifier).load(refresh: true),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// History Tab
// ---------------------------------------------------------------------------

class _HistoryTabContent extends ConsumerStatefulWidget {
  const _HistoryTabContent();

  @override
  ConsumerState<_HistoryTabContent> createState() => _HistoryTabContentState();
}

class _HistoryTabContentState extends ConsumerState<_HistoryTabContent> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(aiReviewHistoryProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiReviewHistoryProvider);

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF10B981)),
      );
    }

    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, color: Color(0xFF9CA3AF), size: 48),
              const SizedBox(height: 16),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => ref
                    .read(aiReviewHistoryProvider.notifier)
                    .load(refresh: true),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF6B7280).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history,
                color: Color(0xFF9CA3AF),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có lịch sử xem xét',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF131018),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Các ảnh bạn đã xem xét sẽ hiện tại đây',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF10B981),
      onRefresh: () =>
          ref.read(aiReviewHistoryProvider.notifier).load(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF10B981),
                  strokeWidth: 2,
                ),
              ),
            );
          }
          return _ReviewHistoryCard(item: state.items[index]);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Queue Card
// ---------------------------------------------------------------------------

class _ReviewQueueCard extends StatelessWidget {
  const _ReviewQueueCard({required this.item, required this.onTap});

  final ExpertReviewItemResponse item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ai = item.aiResult;
    final confident = ai.confidence;
    final confPct = (confident * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Snake photo
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _SnakeNetworkImage(
                    url: item.media.mediaUrl,
                    width: 80,
                    height: 80,
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reference badge
                      _ReferenceTypeBadge(type: item.media.referenceType),
                      const SizedBox(height: 6),
                      // AI class
                      Text(
                        ai.yoloClassName.isEmpty
                            ? 'Chưa phân loại'
                            : ai.yoloClassName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF131018),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Detected species
                      if (ai.detectedSpecies != null)
                        Text(
                          ai.detectedSpecies!.commonName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      // Confidence bar
                      _ConfidenceBar(confidence: confident),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Độ tin cậy: $confPct%',
                            style: TextStyle(
                              fontSize: 11,
                              color: _confidenceColor(confident),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF9CA3AF),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// History Card
// ---------------------------------------------------------------------------

class _ReviewHistoryCard extends StatelessWidget {
  const _ReviewHistoryCard({required this.item});

  final ExpertReviewedRecognitionItemResponse item;

  @override
  Widget build(BuildContext context) {
    final ai = item.aiResult;
    final confident = ai.confidence;
    final confPct = (confident * 100).round();
    final isVerified =
        (item.expertStatus ?? ai.status).toLowerCase().contains('verified') ||
        (item.expertStatus ?? ai.status) == RecognitionStatus.expertVerified;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Snake photo
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _SnakeNetworkImage(
                url: item.media.mediaUrl,
                width: 80,
                height: 80,
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _ReferenceTypeBadge(type: item.media.referenceType),
                      const Spacer(),
                      _StatusBadge(isVerified: isVerified),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ai.yoloClassName.isEmpty
                        ? 'Chưa phân loại'
                        : ai.yoloClassName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF131018),
                    ),
                  ),
                  if (ai.detectedSpecies != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      ai.detectedSpecies!.commonName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Độ tin cậy: $confPct%',
                        style: TextStyle(
                          fontSize: 11,
                          color: _confidenceColor(confident),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (item.expertReviewedAt != null) ...[
                        const Spacer(),
                        Text(
                          _formatDate(item.expertReviewedAt!),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }
}

// ---------------------------------------------------------------------------
// Shared Widgets
// ---------------------------------------------------------------------------

class _SnakeNetworkImage extends StatelessWidget {
  const _SnakeNetworkImage({
    required this.url,
    required this.width,
    required this.height,
  });

  final String url;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _placeholder();
    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          width: width,
          height: height,
          color: const Color(0xFFF3F4F6),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF10B981),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF3F4F6),
      child: const Icon(
        Icons.image_outlined,
        color: Color(0xFFD1D5DB),
        size: 32,
      ),
    );
  }
}

class _ConfidenceBar extends StatelessWidget {
  const _ConfidenceBar({required this.confidence});
  final double confidence;

  @override
  Widget build(BuildContext context) {
    final color = _confidenceColor(confidence);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: confidence.clamp(0.0, 1.0),
        minHeight: 5,
        backgroundColor: const Color(0xFFE5E7EB),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

class _ReferenceTypeBadge extends StatelessWidget {
  const _ReferenceTypeBadge({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    final label = _labelFor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color(0xFF10B981),
        ),
      ),
    );
  }

  String _labelFor(String type) {
    switch (type.toLowerCase()) {
      case 'snakecatchingrequest':
      case '3':
        return 'Bắt rắn';
      case 'snakecatchingmission':
      case '4':
        return 'Nhiệm vụ';
      case 'communityreport':
      case '0':
        return 'Báo cáo';
      case 'snakebiteincident':
      case '1':
        return 'Cắn rắn';
      case 'rescuemission':
      case '2':
        return 'Cứu hộ';
      default:
        return type.isEmpty ? 'Ảnh' : type;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isVerified});
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isVerified
            ? const Color(0xFF10B981).withOpacity(0.1)
            : const Color(0xFFEF4444).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isVerified ? 'Đã xác nhận' : 'Đã từ chối',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isVerified ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers (shared across both files)
// ---------------------------------------------------------------------------

Color _confidenceColor(double confidence) {
  if (confidence >= 0.7) return const Color(0xFF10B981);
  if (confidence >= 0.5) return const Color(0xFFF59E0B);
  return const Color(0xFFEF4444);
}
