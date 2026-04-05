import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_notification_response.dart';
import '../repository/notification_repository.dart';

class NotificationInboxState {
  final List<AppNotificationResponse> items;
  final NotificationPageMeta? meta;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  const NotificationInboxState({
    this.items = const [],
    this.meta,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  NotificationInboxState copyWith({
    List<AppNotificationResponse>? items,
    NotificationPageMeta? meta,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
  }) {
    return NotificationInboxState(
      items: items ?? this.items,
      meta: meta ?? this.meta,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get hasMore => meta?.hasNextPage ?? false;

  int get unreadCount => items.where((item) => !item.isRead).length;
}

class NotificationInboxNotifier extends StateNotifier<NotificationInboxState> {
  final NotificationRepository _repository;
  final int _pageSize;
  bool _hasLoadedInitial = false;
  int _nextPage = 1;

  NotificationInboxNotifier(this._repository, {int pageSize = 20})
    : _pageSize = pageSize,
      super(const NotificationInboxState());

  Future<void> loadInitial({bool forceRefresh = false}) async {
    if (state.isLoading) return;
    if (_hasLoadedInitial && !forceRefresh && state.items.isNotEmpty) return;

    _hasLoadedInitial = true;
    _nextPage = 1;

    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      clearError: true,
      items: forceRefresh ? const [] : state.items,
      meta: forceRefresh ? null : state.meta,
    );

    try {
      final response = await _repository.getMyNotifications(
        page: 1,
        pageSize: _pageSize,
      );

      state = state.copyWith(
        items: response.items,
        meta: response.meta,
        isLoading: false,
      );
      _nextPage = response.meta.hasNextPage ? 2 : response.meta.currentPage;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> refresh() async {
    await loadInitial(forceRefresh: true);
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final response = await _repository.getMyNotifications(
        page: _nextPage,
        pageSize: _pageSize,
      );

      state = state.copyWith(
        items: [...state.items, ...response.items],
        meta: response.meta,
        isLoadingMore: false,
      );
      _nextPage = response.meta.hasNextPage
          ? response.meta.currentPage + 1
          : response.meta.currentPage;
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final index = state.items.indexWhere((item) => item.id == notificationId);
    if (index == -1) return;

    final previousItems = state.items;
    final optimisticItem = state.items[index].copyWith(isRead: true);
    final updatedItems = List<AppNotificationResponse>.from(state.items)
      ..[index] = optimisticItem;

    state = state.copyWith(items: updatedItems, clearError: true);

    try {
      final updated = await _repository.markNotificationAsRead(notificationId);
      final refreshedIndex = state.items.indexWhere(
        (item) => item.id == updated.id,
      );
      if (refreshedIndex != -1) {
        final refreshedItems = List<AppNotificationResponse>.from(state.items)
          ..[refreshedIndex] = updated;
        state = state.copyWith(items: refreshedItems);
      }
    } catch (e) {
      state = state.copyWith(
        items: previousItems,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  void clearCache() {
    _hasLoadedInitial = false;
    _nextPage = 1;
    state = const NotificationInboxState();
  }
}

final notificationInboxProvider =
    StateNotifierProvider<NotificationInboxNotifier, NotificationInboxState>((
      ref,
    ) {
      final repository = ref.watch(notificationRepositoryProvider);
      return NotificationInboxNotifier(repository);
    });
