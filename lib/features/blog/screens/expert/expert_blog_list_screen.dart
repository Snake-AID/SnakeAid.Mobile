import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/blog_model.dart';
import '../../providers/blog_provider.dart';

class ExpertBlogListScreen extends ConsumerStatefulWidget {
  const ExpertBlogListScreen({super.key});

  @override
  ConsumerState<ExpertBlogListScreen> createState() =>
      _ExpertBlogListScreenState();
}

class _ExpertBlogListScreenState extends ConsumerState<ExpertBlogListScreen>
    with SingleTickerProviderStateMixin {
  static const _purple = Color(0xFF6C47C2);

  late final TabController _tabController;

  static const _tabs = [
    (label: 'Tất cả', status: null),
    (label: 'Bản nháp', status: BlogStatus.draft),
    (label: 'Chờ duyệt', status: BlogStatus.pendingApproval),
    (label: 'Đã đăng', status: BlogStatus.published),
    (label: 'Bị từ chối', status: BlogStatus.rejected),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expertBlogListProvider);
    final notifier = ref.read(expertBlogListProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: _purple,
        foregroundColor: Colors.white,
        title: const Text(
          'Bài Viết Của Tôi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
        ),
        elevation: 0,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: _purple))
          : state.error != null
          ? _ErrorView(error: state.error!, onRetry: notifier.refresh)
          : TabBarView(
              controller: _tabController,
              children: _tabs
                  .map(
                    (t) => _BlogTabContent(
                      blogs: t.status == null
                          ? state.blogs
                          : state.blogs
                                .where((b) => b.status == t.status)
                                .toList(),
                      notifier: notifier,
                      onRefresh: notifier.refresh,
                    ),
                  )
                  .toList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/expert/blogs/new');
          notifier.refresh();
        },
        backgroundColor: _purple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Viết bài'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// One tab content
// ---------------------------------------------------------------------------

class _BlogTabContent extends ConsumerWidget {
  final List<BlogModel> blogs;
  final ExpertBlogListNotifier notifier;
  final Future<void> Function() onRefresh;

  const _BlogTabContent({
    required this.blogs,
    required this.notifier,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (blogs.isEmpty) {
      return const Center(
        child: Text(
          'Không có bài viết nào',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF6C47C2),
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: blogs.length,
        itemBuilder: (context, i) {
          final blog = blogs[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ExpertBlogCard(
              blog: blog,
              onEdit: () async {
                await context.push(
                  '/expert/blogs/${blog.id}/edit',
                  extra: blog,
                );
                notifier.refresh();
              },
              onSubmit: blog.status == BlogStatus.draft
                  ? () async {
                      final confirmed = await _confirmSubmit(
                        context,
                        blog.title,
                      );
                      if (confirmed == true) {
                        await notifier.submitForApproval(blog: blog);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã gửi bài viết để duyệt'),
                              backgroundColor: Color(0xFF6C47C2),
                            ),
                          );
                        }
                      }
                    }
                  : null,
              onDelete: () async {
                final confirmed = await _confirmDelete(context, blog.title);
                if (confirmed == true) {
                  await notifier.deleteBlog(blog.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã xoá bài viết')),
                    );
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, String title) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoá bài viết?'),
        content: Text('Bạn có chắc muốn xoá "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmSubmit(BuildContext context, String title) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đăng bài?'),
        content: Text('Gửi "$title" để chờ duyệt?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6C47C2),
            ),
            child: const Text('Đăng'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Expert blog card
// ---------------------------------------------------------------------------

class _ExpertBlogCard extends StatelessWidget {
  final BlogModel blog;
  final VoidCallback onEdit;
  final VoidCallback? onSubmit;
  final VoidCallback onDelete;

  const _ExpertBlogCard({
    required this.blog,
    required this.onEdit,
    this.onSubmit,
    required this.onDelete,
  });

  static const _purple = Color(0xFF6C47C2);

  Color _statusColor(BlogStatus s) => switch (s) {
    BlogStatus.draft => Colors.grey,
    BlogStatus.pendingApproval => Colors.orange,
    BlogStatus.published => const Color(0xFF228B22),
    BlogStatus.rejected => Colors.red,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              blog.thumbnailUrl,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 140,
                color: Colors.grey[200],
                child: const Icon(Icons.image, size: 48, color: Colors.grey),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(blog.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        blogStatusLabel(blog.status),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _statusColor(blog.status),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _purple.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        blogCategoryLabel(blog.category),
                        style: const TextStyle(fontSize: 11, color: _purple),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  blog.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Rejection reason
                if (blog.status == BlogStatus.rejected &&
                    blog.rejectionReason != null &&
                    blog.rejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Lý do từ chối: ${blog.rejectionReason}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 8),
                // Stats
                Row(
                  children: [
                    const Icon(
                      Icons.visibility_outlined,
                      size: 13,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${blog.viewCount}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.favorite_border,
                      size: 13,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${blog.likeCount}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),

                const Divider(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onSubmit != null)
                      TextButton.icon(
                        onPressed: onSubmit,
                        icon: const Icon(Icons.send, size: 16),
                        label: const Text('Đăng'),
                        style: TextButton.styleFrom(foregroundColor: _purple),
                      ),
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Sửa'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blueGrey,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Xoá'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error view
// ---------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C47C2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
