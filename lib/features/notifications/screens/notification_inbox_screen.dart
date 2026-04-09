import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../auth/models/user_role.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/app_notification_response.dart';
import '../providers/notification_inbox_provider.dart';

class NotificationInboxScreen extends ConsumerStatefulWidget {
  const NotificationInboxScreen({super.key});

  @override
  ConsumerState<NotificationInboxScreen> createState() =>
      _NotificationInboxScreenState();
}

class _NotificationInboxScreenState
    extends ConsumerState<NotificationInboxScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(notificationInboxProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final thresholdReached =
        _scrollController.position.pixels + 240 >=
        _scrollController.position.maxScrollExtent;
    if (thresholdReached) {
      ref.read(notificationInboxProvider.notifier).loadMore();
    }
  }

  Future<void> _refresh() async {
    await ref.read(notificationInboxProvider.notifier).refresh();
  }

  Future<void> _openNotification(AppNotificationResponse item) async {
    try {
      await ref.read(notificationInboxProvider.notifier).markAsRead(item.id);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể đánh dấu đã đọc')),
      );
    }

    if (!mounted) return;

    final userRole = ref.read(currentUserRoleProvider) ?? UserRole.member;
    final primaryColor = _getPrimaryColor(userRole);
    final lighterColor =
        Color.lerp(primaryColor, Colors.white, 0.15) ?? primaryColor;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, lighterColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Chi tiết thông báo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDateTime(item.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Text(
                        item.message,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.55,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Đóng',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime.toLocal());
  }

  Color _getPrimaryColor(UserRole role) {
    switch (role) {
      case UserRole.member:
        return const Color(0xFF228B22);
      case UserRole.rescuer:
        return const Color(0xFFFF8800);
      case UserRole.expert:
        return const Color(0xFF6C47C2);
    }
  }

  Color _getUnreadBgColor(UserRole role) {
    switch (role) {
      case UserRole.member:
        return const Color(0xFFEEF8EE);
      case UserRole.rescuer:
        return const Color(0xFFFFEDE0);
      case UserRole.expert:
        return const Color(0xFFF3ECFD);
    }
  }

  Widget _buildNotificationTile(AppNotificationResponse item) {
    final isUnread = !item.isRead;
    final userRole = ref.read(currentUserRoleProvider) ?? UserRole.member;
    final primaryColor = _getPrimaryColor(userRole);
    final unreadBgColor = _getUnreadBgColor(userRole);
    final readBgColor = Colors.white;

    return InkWell(
      onTap: () => _openNotification(item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread ? unreadBgColor : readBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? primaryColor.withOpacity(0.25)
                : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isUnread ? 0.05 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(isUnread ? 0.18 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_outlined,
                color: primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8, top: 6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC3545),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatDateTime(item.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingList(Color primaryColor) {
    return Center(child: CircularProgressIndicator(color: primaryColor));
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 120),
        Icon(Icons.notifications_none, size: 64, color: Color(0xFFCBD5E1)),
        SizedBox(height: 12),
        Text(
          'Chưa có thông báo',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 6),
        Text(
          'Khi có cập nhật mới, chúng sẽ xuất hiện ở đây.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message, Color primaryColor) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        const Icon(Icons.error_outline, size: 64, color: Color(0xFFDC3545)),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            onPressed: () => ref
                .read(notificationInboxProvider.notifier)
                .loadInitial(forceRefresh: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Thử lại'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationInboxProvider);
    final userRole = ref.watch(currentUserRoleProvider) ?? UserRole.member;
    final primaryColor = _getPrimaryColor(userRole);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Thông báo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: Icon(Icons.refresh, color: primaryColor),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Builder(
            builder: (context) {
              if (state.isLoading && state.items.isEmpty) {
                return _buildLoadingList(primaryColor);
              }

              if (state.error != null && state.items.isEmpty) {
                return _buildErrorState(state.error!, primaryColor);
              }

              if (state.items.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                color: primaryColor,
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= state.items.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        ),
                      );
                    }

                    final item = state.items[index];
                    return _buildNotificationTile(item);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
