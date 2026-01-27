import 'package:flutter/material.dart';

/// Education/News section with article cards
class EducationSection extends StatelessWidget {
  const EducationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bài viết mới nhất',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12),
        _ArticleCard(
          title: 'Cách phòng tránh rắn mùa mưa',
          readTime: '5 phút đọc',
          views: '1,234 lượt xem',
          badge: 'Mới',
          badgeColor: Colors.green,
          imageUrl:
              'https://images.unsplash.com/photo-1527482797697-8795b05a13fe?w=400',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _ArticleCard(
          title: 'Nhận biết 5 loài rắn độc Việt Nam',
          readTime: '7 phút đọc',
          views: '3,456 lượt xem',
          imageUrl:
              'https://images.unsplash.com/photo-1531386151447-fd76ad50012f?w=400',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _ArticleCard(
          title: 'Video hướng dẫn băng ép đúng cách',
          readTime: '3:45 phút',
          views: '890 lượt xem',
          badge: 'Video',
          badgeColor: Colors.blue,
          imageUrl:
              'https://images.unsplash.com/photo-1584515933487-779824d29309?w=400',
          isVideo: true,
          onTap: () {},
        ),
      ],
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
