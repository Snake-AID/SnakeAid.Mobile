import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'notification_service.dart';

/// Background Service để giữ app nhận push notification ngay cả khi bị kill
/// Service này chạy dưới dạng foreground service trên Android
@pragma('vm:entry-point')
class BackgroundNotificationService {
  static const String notificationChannelId = 'background_service_channel';
  static const String notificationChannelName = 'Background Service';
  static const int notificationId = 888;

  /// Initialize và start background service
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    // Create notification channel cho foreground service
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId,
      notificationChannelName,
      description: 'Service to receive notifications even when app is closed',
      importance: Importance.low, // Low để không làm phiền user
      showBadge: false,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Configure service
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // onStart được gọi khi service start
        onStart: onStart,

        // Auto start service khi device boot
        autoStart: true,
        autoStartOnBoot: true,

        // Chạy dưới dạng foreground service
        isForegroundMode: true,

        // Notification cho foreground service
        notificationChannelId: notificationChannelId,
        initialNotificationTitle: 'Notification Service',
        initialNotificationContent: 'Listening for notifications...',
        foregroundServiceNotificationId: notificationId,
        foregroundServiceTypes: [AndroidForegroundType.dataSync],
      ),
      iosConfiguration: IosConfiguration(
        // iOS không cần foreground service như Android
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    // Start service
    await service.startService();
    debugPrint('Background service started');
  }

  /// Main entry point cho background service trên Android
  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // Đảm bảo plugin binding được khởi tạo
    DartPluginRegistrant.ensureInitialized();

    // Initialize Firebase nếu chưa
    try {
      await Firebase.initializeApp();
      debugPrint('Firebase initialized in background service');
    } catch (e) {
      debugPrint('Firebase already initialized: $e');
    }

    // Initialize notification service
    final notificationService = NotificationService();
    await notificationService.initialize();

    // Listen for FCM messages trong background
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Background Service: Message received');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');

      // Hiển thị notification
      if (message.notification != null) {
        notificationService.showNotificationFromFCM(message);
      }
    });

    // Background message handler
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // Update foreground notification periodically
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });

      service.on('stopService').listen((event) {
        service.stopSelf();
      });

      // Heartbeat để keep service alive
      Timer.periodic(const Duration(minutes: 1), (timer) async {
        if (await service.isForegroundService()) {
          // Update notification để show service vẫn đang chạy
          service.setForegroundNotificationInfo(
            title: 'Notification Service Active',
            content:
                'Last check: ${DateTime.now().toString().substring(11, 19)}',
          );
          debugPrint('Service heartbeat');
        }
      });
    }

    debugPrint('Background service is running');
  }

  /// Handler cho iOS background
  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  /// Background message handler
  @pragma('vm:entry-point')
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    debugPrint('Background message handler: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');

    // Notification service sẽ tự động hiển thị qua onStart handler
  }

  /// Stop background service
  static Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke('stopService');
    debugPrint('Background service stopped');
  }

  /// Check if service is running
  static Future<bool> isServiceRunning() async {
    final service = FlutterBackgroundService();
    return await service.isRunning();
  }
}
