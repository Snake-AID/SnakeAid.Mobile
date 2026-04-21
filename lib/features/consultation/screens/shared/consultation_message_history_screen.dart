import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/consultation_message_history_response.dart';
import '../../repository/consultation_repository.dart';

class ConsultationMessageHistoryScreen extends ConsumerStatefulWidget {
  final String consultationId;
  final String title;
  final bool isExpertMode;

  const ConsultationMessageHistoryScreen({
    super.key,
    required this.consultationId,
    required this.title,
    this.isExpertMode = false,
  });

  @override
  ConsumerState<ConsultationMessageHistoryScreen> createState() =>
      _ConsultationMessageHistoryScreenState();
}

class _ConsultationMessageHistoryScreenState
    extends ConsumerState<ConsultationMessageHistoryScreen> {
  static const _memberPrimary = Color(0xFF228B22);
  static const _expertPrimary = Color(0xFF6C47C2);

  final ScrollController _scrollController = ScrollController();

  final List<ConsultationMessageHistoryItem> _messages = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  String? _currentUserId;

  Color get _primary => widget.isExpertMode ? _expertPrimary : _memberPrimary;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('user_id');
    await _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _messages.clear();
      _currentPage = 1;
      _totalPages = 1;
    });

    try {
      final repo = ref.read(consultationRepositoryProvider);
      final result = await repo.getConsultationMessageHistory(
        consultationId: widget.consultationId,
        pageNumber: 1,
        pageSize: 20,
      );

      if (!mounted) return;
      setState(() {
        _messages.addAll(result.items);
        _currentPage = result.meta.currentPage;
        _totalPages = result.meta.totalPages;
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _loadOlderMessages() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;

    final previousOffset = _scrollController.hasClients
        ? _scrollController.position.maxScrollExtent -
            _scrollController.position.pixels
        : 0.0;

    setState(() => _isLoadingMore = true);
    try {
      final nextPage = _currentPage + 1;
      final repo = ref.read(consultationRepositoryProvider);
      final result = await repo.getConsultationMessageHistory(
        consultationId: widget.consultationId,
        pageNumber: nextPage,
        pageSize: 20,
      );

      if (!mounted) return;
      setState(() {
        _messages.insertAll(0, result.items);
        _currentPage = result.meta.currentPage;
        _totalPages = result.meta.totalPages;
        _isLoadingMore = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;
        final target =
            _scrollController.position.maxScrollExtent - previousOffset;
        _scrollController.jumpTo(target.clamp(0.0, _scrollController.position.maxScrollExtent));
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _openAttachment(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  bool _isMine(ConsultationMessageHistoryItem item) {
    return _currentUserId != null && _currentUserId!.isNotEmpty && item.senderId == _currentUserId;
  }

  String _timeLabel(DateTime utc) {
    final local = utc.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final mo = local.month.toString().padLeft(2, '0');
    return '$d/$mo ${h}:$m';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF111827)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lịch Sử Tin Nhắn',
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            Text(
              widget.title,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: _primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.history_toggle_off, size: 48, color: Color(0xFF9CA3AF)),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadFirstPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mark_chat_read_outlined, size: 48, color: Color(0xFF9CA3AF)),
            SizedBox(height: 10),
            Text(
              'Không có tin nhắn lưu trữ',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_currentPage < _totalPages)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoadingMore ? null : _loadOlderMessages,
                icon: _isLoadingMore
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _primary,
                        ),
                      )
                    : const Icon(Icons.history),
                label: Text(
                  _isLoadingMore ? 'Đang tải...' : 'Tải thêm tin nhắn cũ',
                ),
              ),
            ),
          ),
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            itemCount: _messages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = _messages[index];
              final mine = _isMine(item);
              return _MessageBubble(
                item: item,
                mine: mine,
                primaryColor: _primary,
                timeLabel: _timeLabel(item.sentAt),
                onTapAttachment: item.attachmentUrl == null || item.attachmentUrl!.isEmpty
                    ? null
                    : () => _openAttachment(item.attachmentUrl!),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ConsultationMessageHistoryItem item;
  final bool mine;
  final Color primaryColor;
  final String timeLabel;
  final VoidCallback? onTapAttachment;

  const _MessageBubble({
    required this.item,
    required this.mine,
    required this.primaryColor,
    required this.timeLabel,
    required this.onTapAttachment,
  });

  @override
  Widget build(BuildContext context) {
    final align = mine ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = mine ? primaryColor : Colors.white;
    final textColor = mine ? Colors.white : const Color(0xFF111827);

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(mine ? 14 : 4),
              bottomRight: Radius.circular(mine ? 4 : 14),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: align,
            children: [
              if (item.attachmentUrl != null && item.attachmentUrl!.isNotEmpty)
                GestureDetector(
                  onTap: onTapAttachment,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: item.attachmentUrl!,
                      width: 220,
                      height: 150,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 220,
                        height: 150,
                        color: const Color(0xFFF3F4F6),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 220,
                        height: 150,
                        color: const Color(0xFFF3F4F6),
                        child: const Center(
                          child: Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                  ),
                ),
              if (item.attachmentUrl != null && item.attachmentUrl!.isNotEmpty && item.content.trim().isNotEmpty)
                const SizedBox(height: 8),
              if (item.content.trim().isNotEmpty)
                Text(
                  item.content.trim(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          timeLabel,
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
