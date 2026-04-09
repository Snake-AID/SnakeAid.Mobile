class AppNotificationResponse {
  final String id;
  final String userId;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppNotificationResponse({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppNotificationResponse.fromJson(Map<String, dynamic> json) {
    return AppNotificationResponse(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'message': message,
    'isRead': isRead,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  AppNotificationResponse copyWith({bool? isRead}) {
    return AppNotificationResponse(
      id: id,
      userId: userId,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class NotificationPageMeta {
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  const NotificationPageMeta({
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  factory NotificationPageMeta.fromJson(Map<String, dynamic> json) {
    return NotificationPageMeta(
      currentPage: (json['currentPage'] as int?) ?? 1,
      pageSize: (json['pageSize'] as int?) ?? 20,
      totalItems: (json['totalItems'] as int?) ?? 0,
      totalPages: (json['totalPages'] as int?) ?? 1,
    );
  }

  bool get hasNextPage => currentPage < totalPages;
}

class PagedAppNotifications {
  final List<AppNotificationResponse> items;
  final NotificationPageMeta meta;

  const PagedAppNotifications({required this.items, required this.meta});

  factory PagedAppNotifications.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? const [])
        .map(
          (item) =>
              AppNotificationResponse.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    final metaJson = json['meta'] as Map<String, dynamic>? ?? const {};
    return PagedAppNotifications(
      items: items,
      meta: NotificationPageMeta.fromJson(metaJson),
    );
  }
}

class AppNotificationEnvelopeResponse {
  final int statusCode;
  final String message;
  final bool isSuccess;
  final dynamic data;
  final dynamic error;

  const AppNotificationEnvelopeResponse({
    required this.statusCode,
    required this.message,
    required this.isSuccess,
    required this.data,
    required this.error,
  });

  factory AppNotificationEnvelopeResponse.fromJson(Map<String, dynamic> json) {
    return AppNotificationEnvelopeResponse(
      statusCode: (json['status_code'] as int?) ?? 0,
      message: json['message'] as String? ?? '',
      isSuccess: json['is_success'] as bool? ?? false,
      data: json['data'],
      error: json['error'],
    );
  }
}
