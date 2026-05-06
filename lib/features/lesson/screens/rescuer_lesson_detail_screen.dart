import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/lesson.dart';

/// Category colour/icon helper (mirrors list screen)
({IconData icon, Color color, String label}) _catMeta(String category) {
  switch (category) {
    case 'Safety':
      return (
        icon: Icons.shield_rounded,
        color: const Color(0xFF28A745),
        label: 'An Toàn',
      );
    case 'Catching':
      return (
        icon: Icons.pest_control_rounded,
        color: const Color(0xFFFF6B35),
        label: 'Bắt Rắn',
      );
    case 'FirstAid':
      return (
        icon: Icons.medical_services_rounded,
        color: const Color(0xFFDC3545),
        label: 'Sơ Cứu',
      );
    default:
      return (
        icon: Icons.menu_book_rounded,
        color: const Color(0xFFFF6B35),
        label: category,
      );
  }
}

/// Splits [content] into sections delimited by emoji headings (lines starting
/// with an emoji + digit + dot pattern or 🌲/🛡️/🔍 etc.).
/// Each section is a [_Section] with an optional heading and body paragraphs.
class _Section {
  final String? heading; // e.g. "1. TRANG PHỤC BẢO HỘ CHUYÊN DỤNG:"
  final String body;

  const _Section({this.heading, required this.body});
}

List<_Section> _parseSections(String content) {
  // Remove raw URLs (they are handled as video link separately)
  final noUrls = content.replaceAll(RegExp(r'https?://\S+'), '').trim();

  // Split on lines that start with an emoji or emoji + number
  final lines = noUrls.split('\n');
  final sections = <_Section>[];

  String? currentHeading;
  final bodyLines = <String>[];

  for (final raw in lines) {
    final line = raw.trimRight();
    if (line.isEmpty) {
      bodyLines.add('');
      continue;
    }
    // Detect section heading: starts with emoji (Unicode block) or "🌲 1." / "🛡️ 1." etc.
    final isHeading = RegExp(
      r'^[\u{1F300}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
      unicode: true,
    ).hasMatch(line);
    if (isHeading) {
      // Save previous section
      final prevBody = bodyLines.join('\n').trim();
      if (prevBody.isNotEmpty || currentHeading != null) {
        sections.add(_Section(heading: currentHeading, body: prevBody));
      }
      currentHeading = line.trim();
      bodyLines.clear();
    } else {
      bodyLines.add(line);
    }
  }
  // Last section
  final lastBody = bodyLines.join('\n').trim();
  if (lastBody.isNotEmpty || currentHeading != null) {
    sections.add(_Section(heading: currentHeading, body: lastBody));
  }

  if (sections.isEmpty) {
    sections.add(_Section(body: noUrls));
  }
  return sections;
}

class RescuerLessonDetailScreen extends StatelessWidget {
  final LessonData lesson;

  const RescuerLessonDetailScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final cat = _catMeta(lesson.category);
    final sections = _parseSections(lesson.content);
    final videoUrl = lesson.youtubeUrl;
    final dateStr = DateFormat('dd/MM/yyyy').format(lesson.updatedAt.toLocal());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      body: CustomScrollView(
        slivers: [
          // ── Hero AppBar ────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: cat.color,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1.0,
              titlePadding: const EdgeInsetsDirectional.only(
                start: 40,
                end: 16,
                bottom: 10,
              ),
              title: Text(
                lesson.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.3,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cat.color.withValues(alpha: 0.85), cat.color],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    // Faint large icon — decorative bg
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Icon(
                          cat.icon,
                          size: 160,
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                    ),
                    // Centered hero content: icon circle + label
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 52),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                cat.icon,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                cat.label,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Gradient scrim at bottom for title readability
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 90,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.5),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Update date ──────────────────────────────────────
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: Color(0xFF999999),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Cập nhật: $dateStr',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Video banner ─────────────────────────────────────
                  if (videoUrl != null) ...[
                    _VideoBanner(url: videoUrl, accentColor: cat.color),
                    const SizedBox(height: 20),
                  ],

                  // ── Divider ──────────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: cat.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Nội Dung Bài Học',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── Sections ─────────────────────────────────────────
                  ...sections.map(
                    (s) => _SectionCard(section: s, accentColor: cat.color),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Video banner widget ────────────────────────────────────────────────────

class _VideoBanner extends StatelessWidget {
  final String url;
  final Color accentColor;

  const _VideoBanner({required this.url, required this.accentColor});

  Future<void> _openVideo(BuildContext context) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể mở video. Vui lòng thử lại.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Extracts YouTube video ID from a youtube.com or youtu.be URL.
  String? _extractVideoId() {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    return uri.queryParameters['v'];
  }

  @override
  Widget build(BuildContext context) {
    final videoId = _extractVideoId();
    final thumbUrl = videoId != null
        ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg'
        : null;

    return GestureDetector(
      onTap: () => _openVideo(context),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail
              if (thumbUrl != null)
                Image.network(
                  thumbUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: const Color(0xFF1A1A2E)),
                )
              else
                Container(color: const Color(0xFF1A1A2E)),

              // Dark scrim
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.black.withValues(alpha: 0.2),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),

              // Play button
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC3545),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),

              // Label
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    const Icon(
                      Icons.smart_display_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Xem video hướng dẫn trên YouTube',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC3545),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'YouTube',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section card widget ────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final _Section section;
  final Color accentColor;

  const _SectionCard({required this.section, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final hasHeading = section.heading != null && section.heading!.isNotEmpty;
    final hasBody = section.body.isNotEmpty;

    if (!hasHeading && !hasBody) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasHeading)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Text(
                section.heading!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                  height: 1.4,
                ),
              ),
            ),
          if (hasBody)
            Padding(
              padding: EdgeInsets.fromLTRB(14, hasHeading ? 10 : 12, 14, 12),
              child: _buildBodyText(section.body),
            ),
        ],
      ),
    );
  }

  Widget _buildBodyText(String body) {
    // Split into bullet lines (starting with '-') and normal paragraphs
    final lines = body.split('\n');
    final widgets = <Widget>[];

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }
      if (line.startsWith('-') || line.startsWith('•')) {
        final text = line.replaceFirst(RegExp(r'^[-•]\s*'), '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF444444),
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              line,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF444444),
                height: 1.55,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
