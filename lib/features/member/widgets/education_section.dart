import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../blog/providers/blog_provider.dart';

/// Education/News section — shows 3 latest published blog posts.
class EducationSection extends ConsumerWidget {
  const EducationSection({super.key});

  static const _green = Color(0xFF228B22);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(blogListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bài viết mới nhất',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            TextButton(
              onPressed: () => context.push('/blogs'),
              child: const Text(
                'Xem thêm',
                style: TextStyle(
                  fontSize: 14,
                  color: _green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (state.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(color: _green),
            ),
          )
        else if (state.error != null)
          _buildError(context, ref)
        else if (state.blogs.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Chưa có bài viết nào',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ...state.blogs.take(3).map((blog) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ArticleCard(
                  title: blog.title,
                  readTime: '${blog.readingTime} phút đọc',
                  views: '${blog.viewCount} lượt xem',
                  imageUrl: blog.thumbnailUrl,
                  onTap: () => context.push('/blogs/${blog.id}'),
                ),
              )),
      ],
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Không tải được bài viết',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () =>
                ref.read(blogListProvider.notifier).refresh(),
            child: const Text('Thử lại',
                style: TextStyle(color: _green)),
          ),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final String title;
  final String readTime;
  final String views;
  final String? badge;
  final Color? badgeColor;
  final String imageUrl;
  final bool isVideo;
  final VoidCallback onTap;

  const _ArticleCard({
    required this.title,
    required this.readTime,
    required this.views,
    this.badge,
    this.badgeColor,
    required this.imageUrl,
    this.isVideo = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(10),
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
        child: Stack(
          children: [
            Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Image.network(
                        imageUrl,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 90,
                            height: 90,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 40),
                          );
                        },
                      ),
                      if (isVideo)
                        Container(
                          width: 90,
                          height: 90,
                          color: Colors.black.withOpacity(0.3),
                          child: const Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$readTime • $views',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Badge
            if (badge != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor?.withOpacity(0.1) ?? Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: badgeColor ?? Colors.grey[700],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
