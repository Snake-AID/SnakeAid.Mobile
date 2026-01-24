import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// Service for handling local notifications display
/// Manages notification channels, styling, and user interactions
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Notification channel IDs
  static const String paymentChannelId = 'payment_notifications';
  static const String paymentChannelName = 'Payment Notifications';
  static const String paymentChannelDescription =
      'Notifications for payment updates and transactions';

  static const String generalChannelId = 'general_notifications';
  static const String generalChannelName = 'General Notifications';
  static const String generalChannelDescription =
      'General app notifications and updates';

  bool _initialized = false;

  /// Initialize the notification service with channels and handlers
  Future<void> initialize() async {
    if (_initialized) return;

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Combined initialization settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // Initialize plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels (Android only)
    await _createNotificationChannels();

    _initialized = true;
    debugPrint('✅ NotificationService initialized successfully');
  }

  /// Request notification permissions for Android 13+ and iOS
  Future<bool> requestPermissions() async {
    // For Android 13+ (API 33+)
    if (await _isAndroid13OrHigher()) {
      final bool? granted = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      debugPrint('📱 Android 13+ notification permission: ${granted ?? false}');
      return granted ?? false;
    }

    // For iOS
    final bool? granted = await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    debugPrint('🍎 iOS notification permission: ${granted ?? false}');
    return granted ?? false;
  }

  /// Check if running on Android 13+ (API 33+)
  Future<bool> _isAndroid13OrHigher() async {
    final androidInfo = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return androidInfo != null;
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation == null) return;

    // Payment notifications channel - High priority
    const AndroidNotificationChannel paymentChannel =
        AndroidNotificationChannel(
          paymentChannelId,
          paymentChannelName,
          description: paymentChannelDescription,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          ledColor: Color.fromARGB(255, 76, 175, 80), // Green for payment
          showBadge: true,
        );

    // General notifications channel - Default priority
    const AndroidNotificationChannel generalChannel =
        AndroidNotificationChannel(
          generalChannelId,
          generalChannelName,
          description: generalChannelDescription,
          importance: Importance.defaultImportance,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        );

    // Create channels
    await androidImplementation.createNotificationChannel(paymentChannel);
    await androidImplementation.createNotificationChannel(generalChannel);

    debugPrint('Notification channels created');
  }

  /// Display notification from FCM RemoteMessage
  Future<void> showNotificationFromFCM(RemoteMessage message) async {
    if (!_initialized) {
      debugPrint('NotificationService not initialized');
      return;
    }

    final notification = message.notification;
    final data = message.data;

    if (notification == null) {
      debugPrint('RemoteMessage has no notification payload');
      return;
    }

    // Determine channel based on data or default to general
    final String channelId = data['channel'] == 'payment'
        ? paymentChannelId
        : generalChannelId;

    // Determine notification ID (use hashCode or custom ID from data)
    final int notificationId = data['id'] != null
        ? int.tryParse(data['id'].toString()) ?? message.hashCode
        : message.hashCode;

    // Android notification details
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelId,
          channelId == paymentChannelId
              ? paymentChannelName
              : generalChannelName,
          channelDescription: channelId == paymentChannelId
              ? paymentChannelDescription
              : generalChannelDescription,
          importance: channelId == paymentChannelId
              ? Importance.high
              : Importance.defaultImportance,
          priority: channelId == paymentChannelId
              ? Priority.high
              : Priority.defaultPriority,
          showWhen: true,
          styleInformation: BigTextStyleInformation(
            notification.body ?? '',
            contentTitle: notification.title,
            summaryText: data['summary'],
          ),
          icon: '@mipmap/ic_launcher',
          color: const Color.fromARGB(255, 76, 175, 80),
          enableVibration: true,
          playSound: true,
          ticker: notification.title,
        );

    // iOS notification details
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Combined notification details
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    // Show notification
    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      notification.title ?? 'Notification',
      notification.body ?? '',
      notificationDetails,
      payload: message.data.toString(),
    );

    debugPrint('Notification displayed: ${notification.title}');
  }

  /// Show custom notification (not from FCM)
  Future<void> showCustomNotification({
    required int id,
    required String title,
    required String body,
    String? channelId,
    Map<String, dynamic>? payload,
  }) async {
    if (!_initialized) {
      debugPrint('NotificationService not initialized');
      return;
    }

    final String selectedChannelId = channelId ?? generalChannelId;

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          selectedChannelId,
          selectedChannelId == paymentChannelId
              ? paymentChannelName
              : generalChannelName,
          channelDescription: selectedChannelId == paymentChannelId
              ? paymentChannelDescription
              : generalChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload?.toString(),
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Navigate to specific screen based on payload
    // You can use a navigation service or global key to navigate
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  /// Get active notifications (Android only)
  Future<List<ActiveNotification>> getActiveNotifications() async {
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      return await androidImplementation.getActiveNotifications();
    }
    return [];
  }
}
