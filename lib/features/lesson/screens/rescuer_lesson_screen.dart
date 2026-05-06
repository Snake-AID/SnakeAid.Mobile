import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/lesson.dart';
import '../repository/lesson_repository.dart';
import 'rescuer_lesson_detail_screen.dart';
import '../providers/lesson_read_provider.dart';

/// Category tab definition
class _CategoryTab {
  final String key;
  final String label;
  final IconData icon;
  final Color color;

  const _CategoryTab({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
  });
}

const _categories = [
  _CategoryTab(
    key: 'all',
    label: 'Tất Cả',
    icon: Icons.menu_book_rounded,
    color: Color(0xFFFF6B35),
  ),
  _CategoryTab(
    key: 'Safety',
    label: 'An Toàn',
    icon: Icons.shield_rounded,
    color: Color(0xFF28A745),
  ),
  _CategoryTab(
    key: 'Catching',
    label: 'Bắt Rắn',
    icon: Icons.pest_control_rounded,
    color: Color(0xFFFF6B35),
  ),
  _CategoryTab(
    key: 'FirstAid',
    label: 'Sơ Cứu',
    icon: Icons.medical_services_rounded,
    color: Color(0xFFDC3545),
  ),
];

class RescuerLessonScreen extends ConsumerStatefulWidget {
  const RescuerLessonScreen({super.key});

  @override
  ConsumerState<RescuerLessonScreen> createState() =>
      _RescuerLessonScreenState();
}

class _RescuerLessonScreenState extends ConsumerState<RescuerLessonScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  List<LessonData> _allLessons = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadLessons();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLessons() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(lessonRepositoryProvider);
      final response = await repo.getLessons();
      if (!mounted) return;
      setState(() {
        final published = response.data.where((l) => l.isPublished).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _allLessons = published;
        _isLoading = false;
        // Update known IDs so the home badge stays accurate
        ref
            .read(lessonReadProvider.notifier)
            .updateKnownIds(published.map((l) => l.id).toList());
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<LessonData> _forCategory(String key) {
    if (key == 'all') return _allLessons;
    return _allLessons.where((l) => l.category == key).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
                  )
                : _errorMessage != null
                ? _buildError()
                : Builder(
                    builder: (context) {
                      final readState = ref.watch(lessonReadProvider);
                      return TabBarView(
                        controller: _tabController,
                        children: _categories
                            .map(
                              (c) => _buildLessonList(
                                _forCategory(c.key),
                                readState,
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFF6B35),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Bài Học An Toàn',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadLessons,
          tooltip: 'Làm mới',
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFFFF6B35),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: _categories
            .map(
              (c) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(c.icon, size: 15),
                    const SizedBox(width: 6),
                    Text(c.label),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildLessonList(List<LessonData> lessons, LessonReadState readState) {
    if (lessons.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      color: const Color(0xFFFF6B35),
      onRefresh: _loadLessons,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: lessons.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _buildCard(lessons[i], readState),
      ),
    );
  }

  Widget _buildCard(LessonData lesson, LessonReadState readState) {
    final cat = _categories.firstWhere(
      (c) => c.key == lesson.category,
      orElse: () => _categories.first,
    );
    final hasVideo = lesson.youtubeUrl != null;
    final isRead = readState.isRead(lesson.id);

    return GestureDetector(
      onTap: () {
        ref.read(lessonReadProvider.notifier).markAsRead(lesson.id);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RescuerLessonDetailScreen(lesson: lesson),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Coloured header strip ────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              decoration: BoxDecoration(
                color: cat.color.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cat.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(cat.icon, size: 18, color: cat.color),
                      ),
                      if (!isRead)
                        Positioned(
                          top: -3,
                          right: -3,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3B30),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // ── Excerpt + meta ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.cleanContent,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF555555),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: cat.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cat.icon, size: 11, color: cat.color),
                            const SizedBox(width: 4),
                            Text(
                              cat.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: cat.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (hasVideo) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFDC3545,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_circle_outline,
                                size: 11,
                                color: Color(0xFFDC3545),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Video',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFDC3545),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Color(0xFFBBBBBB),
                      ),
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Chưa có bài học nào',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Đã xảy ra lỗi',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF666666)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadLessons,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
