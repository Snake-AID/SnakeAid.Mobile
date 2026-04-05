import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/http_provider.dart';
import '../../../core/services/http_service.dart';
import '../models/app_notification_response.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return NotificationRepository(httpService: httpService);
});

class NotificationRepository {
  final HttpService httpService;

  NotificationRepository({required this.httpService});

  Future<PagedAppNotifications> getMyNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔔 Loading notifications page=$page size=$pageSize');

      final response = await httpService.get(
        '/api/notifications',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );

      final envelope = AppNotificationEnvelopeResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      final data = envelope.data;
      if (data is Map<String, dynamic>) {
        final paged = PagedAppNotifications.fromJson(data);
        debugPrint('✅ Notifications loaded: ${paged.items.length}');
        return paged;
      }

      throw Exception('Dữ liệu thông báo không hợp lệ từ máy chủ');
    } on DioException catch (e) {
      debugPrint('❌ Load notifications failed: ${e.message}');
      throw _handleError(e, fallback: 'Không thể tải danh sách thông báo');
    } catch (e) {
      debugPrint('❌ Unexpected notifications error: $e');
      throw Exception('Không thể tải danh sách thông báo');
    }
  }

  Future<AppNotificationResponse> markNotificationAsRead(
    String notificationId,
  ) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('✅ Marking notification as read: $notificationId');

      final response = await httpService.put(
        '/api/notifications/$notificationId/read',
      );

      final envelope = AppNotificationEnvelopeResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      final data = envelope.data;
      if (data is Map<String, dynamic>) {
        final notification = AppNotificationResponse.fromJson(data);
        debugPrint('✅ Notification marked as read');
        return notification;
      }

      throw Exception('Dữ liệu thông báo không hợp lệ từ máy chủ');
    } on DioException catch (e) {
      debugPrint('❌ Mark notification read failed: ${e.message}');
      throw _handleError(e, fallback: 'Không thể đánh dấu đã đọc');
    } catch (e) {
      debugPrint('❌ Unexpected read notification error: $e');
      throw Exception('Không thể đánh dấu đã đọc');
    }
  }

  Exception _handleError(DioException e, {required String fallback}) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    String message = e.message ?? fallback;
    if (data is Map<String, dynamic>) {
      message = data['message']?.toString() ?? message;
    } else if (data is String && data.isNotEmpty) {
      message = data;
    }

    if (statusCode == 401) {
      return Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
    }
    if (statusCode == 404) {
      return Exception(
        'Thông báo không tồn tại hoặc không thuộc tài khoản hiện tại.',
      );
    }

    return Exception(message.isNotEmpty ? message : fallback);
  }
}
