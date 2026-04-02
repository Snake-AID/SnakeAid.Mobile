import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

/// Renders blog content written in Markdown.
///
/// Callout boxes: start a line with "> " followed by a trigger emoji:
///   > ⚠️  warning (orange)  · > 🚫 / ❌  danger (red)
///   > ✅   success (green)  · > ℹ️ / 💡 / 📌  info (blue)
class BlogRichContentView extends StatelessWidget {
  final String content;

  const BlogRichContentView({super.key, required this.content});

  static const _green = Color(0xFF228B22);
  static const _darkGreen = Color(0xFF1A3C34);

  // ---------------------------------------------------------------------------
  // Parse content into alternating markdown / callout segments.
  // ---------------------------------------------------------------------------
  List<_Segment> _parse(String raw) {
    final segments = <_Segment>[];
    final mdBuffer = StringBuffer();

    void flushMd() {
      final text = mdBuffer.toString().trimRight();
      if (text.isNotEmpty) segments.add(_MarkdownSegment(text));
      mdBuffer.clear();
    }

    for (final line in raw.split('\n')) {
      if (line.startsWith('> ')) {
        final inner = line.substring(2);
        final type = _calloutType(inner);
        if (type != null) {
          flushMd();
          segments.add(_CalloutSegment(type: type, text: _stripEmoji(inner)));
          continue;
        }
      }
      mdBuffer.writeln(line);
    }
    flushMd();
    return segments;
  }

  String? _calloutType(String text) {
    if (text.startsWith('⚠️') || text.startsWith('⚠')) return 'warning';
    if (text.startsWith('🚫') || text.startsWith('❌')) return 'danger';
    if (text.startsWith('✅') || text.startsWith('☑️')) return 'success';
    if (text.startsWith('ℹ️') ||
        text.startsWith('💡') ||
        text.startsWith('📌')) return 'info';
    return null;
  }

  /// Remove the leading trigger emoji (and optional trailing space) from callout text.
  String _stripEmoji(String text) {
    const triggers = [
      '⚠️', '⚠',
      '🚫', '❌',
      '✅', '☑️',
      'ℹ️', '💡', '📌',
    ];
    for (final t in triggers) {
      if (text.startsWith(t)) {
        return text.substring(t.length).trimLeft();
      }
    }
    return text;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final segments = _parse(content);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: segments.map((s) {
        if (s is _CalloutSegment) return _CalloutBox(s);
        if (s is _MarkdownSegment) {
          return _MarkdownBlock(
            data: s.text,
            styleSheet: _buildStyleSheet(),
          );
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }

  MarkdownStyleSheet _buildStyleSheet() {
    return MarkdownStyleSheet(
      // --- Headings ---
      h1: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: _darkGreen,
        height: 1.4,
        letterSpacing: -0.3,
      ),
      h1Padding: const EdgeInsets.only(top: 20, bottom: 6),
      h2: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: _green,
        height: 1.4,
      ),
      h2Padding: const EdgeInsets.only(top: 16, bottom: 4),
      h3: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _green,
        height: 1.4,
      ),
      h3Padding: const EdgeInsets.only(top: 12, bottom: 4),

      // --- Body text ---
      p: const TextStyle(fontSize: 15, height: 1.8, color: Color(0xFF333333)),
      pPadding: const EdgeInsets.symmetric(vertical: 4),

      // --- Emphasis ---
      strong: const TextStyle(fontWeight: FontWeight.bold, color: _darkGreen),
      em: const TextStyle(fontStyle: FontStyle.italic),

      // --- Lists ---
      listBullet: const TextStyle(fontSize: 15, color: _green),
      listIndent: 20,

      // --- Blockquote (non-callout fallback) ---
      blockquote: const TextStyle(
        fontSize: 14,
        color: Color(0xFF555555),
        height: 1.7,
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(color: Color(0xFFFFB300), width: 4),
        ),
      ),
      blockquotePadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

      // --- Code ---
      code: const TextStyle(
        backgroundColor: Color(0xFFE8F5E9),
        color: _green,
        fontFamily: 'monospace',
        fontSize: 13,
      ),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(8),
      ),
      codeblockPadding: const EdgeInsets.all(12),

      // --- HR ---
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),

      // --- Tables ---
      tableBorder: TableBorder.all(color: Colors.grey.shade300),
      tableHead: const TextStyle(fontWeight: FontWeight.bold, color: _darkGreen),
      tableBody: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
      tableCellsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}

// ---------------------------------------------------------------------------
// Segment types
// ---------------------------------------------------------------------------
abstract class _Segment {}

class _MarkdownSegment extends _Segment {
  final String text;
  _MarkdownSegment(this.text);
}

class _CalloutSegment extends _Segment {
  final String type; // warning | danger | success | info
  final String text;
  _CalloutSegment({required this.type, required this.text});
}

// ---------------------------------------------------------------------------
// Markdown block widget
// ---------------------------------------------------------------------------
class _MarkdownBlock extends StatelessWidget {
  final String data;
  final MarkdownStyleSheet styleSheet;

  const _MarkdownBlock({required this.data, required this.styleSheet});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      selectable: true,
      extensionSet: md.ExtensionSet.gitHubWeb,
      imageBuilder: (uri, title, alt) {
        final url = uri.toString();
        if (url.isEmpty) return const SizedBox.shrink();
        return _ImageBlock(
            url: url, caption: alt?.isNotEmpty == true ? alt : title);
      },
      onTapLink: (text, href, title) async {
        if (href == null) return;
        final uri = Uri.tryParse(href);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      styleSheet: styleSheet,
    );
  }
}

// ---------------------------------------------------------------------------
// Callout box widget
// ---------------------------------------------------------------------------
class _CalloutBox extends StatelessWidget {
  final _CalloutSegment segment;
  const _CalloutBox(this.segment);

  static const _configs = <String, _CalloutConfig>{
    'warning': _CalloutConfig(
      bg: Color(0xFFFFF3E0),
      border: Color(0xFFFF8F00),
      icon: Icons.warning_amber_rounded,
      iconColor: Color(0xFFFF8F00),
    ),
    'danger': _CalloutConfig(
      bg: Color(0xFFFFEBEE),
      border: Color(0xFFE53935),
      icon: Icons.dangerous_outlined,
      iconColor: Color(0xFFE53935),
    ),
    'success': _CalloutConfig(
      bg: Color(0xFFE8F5E9),
      border: Color(0xFF43A047),
      icon: Icons.check_circle_outline,
      iconColor: Color(0xFF43A047),
    ),
    'info': _CalloutConfig(
      bg: Color(0xFFE3F2FD),
      border: Color(0xFF1976D2),
      icon: Icons.lightbulb_outline,
      iconColor: Color(0xFF1976D2),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final cfg = _configs[segment.type] ?? _configs['info']!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: cfg.border, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(cfg.icon, color: cfg.iconColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: MarkdownBody(
                data: segment.text,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    fontSize: 14,
                    height: 1.65,
                    color: cfg.border.withOpacity(0.85),
                  ),
                  strong: TextStyle(
                    fontSize: 14,
                    height: 1.65,
                    fontWeight: FontWeight.bold,
                    color: cfg.border.withOpacity(0.85),
                  ),
                  em: TextStyle(
                    fontSize: 14,
                    height: 1.65,
                    fontStyle: FontStyle.italic,
                    color: cfg.border.withOpacity(0.85),
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

// ---------------------------------------------------------------------------
// Embedded image block
// ---------------------------------------------------------------------------
class _ImageBlock extends StatelessWidget {
  final String url;
  final String? caption;

  const _ImageBlock({required this.url, this.caption});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 220,
                color: const Color(0xFFE8F5E9),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF228B22)),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.broken_image_outlined,
                      size: 48, color: Color(0xFF228B22)),
                ),
              ),
            ),
          ),
          if (caption != null && caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4, right: 4),
              child: Text(
                caption!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CalloutConfig {
  final Color bg;
  final Color border;
  final IconData icon;
  final Color iconColor;

  const _CalloutConfig({
    required this.bg,
    required this.border,
    required this.icon,
    required this.iconColor,
  });
}
