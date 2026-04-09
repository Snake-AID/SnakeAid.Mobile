import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'notification_service.dart';

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NotificationService _notificationService = NotificationService();

  /// Initialize FCM and request permissions
  Future<void> initialize({
    Future<void> Function(String token)? onTokenRefresh,
  }) async {
    // Initialize notification service first
    await _notificationService.initialize();

    // Request notification permissions (iOS + Android 13+)
    await requestPermissions();

    // Get the FCM token
    String? token = await getToken();
    if (token != null) {
      debugPrint('FCM Token: $token');
      await saveToken(token);
    }

    // Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM Token refreshed: $newToken');
      await saveToken(newToken);
      if (onTokenRefresh != null) {
        await onTokenRefresh(newToken);
      }
    });
  }

  /// Request notification permissions for both iOS and Android 13+
  Future<NotificationSettings> requestPermissions() async {
    // Request Firebase Messaging permissions (iOS + Android 13+)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    // Also request local notification permissions (Android 13+)
    await _notificationService.requestPermissions();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional notification permission');
    } else {
      debugPrint('User declined notification permission');
    }

    return settings;
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Save FCM token locally
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  /// Get saved FCM token
  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  /// Get last token sent to backend
  Future<String?> getLastSentToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token_sent');
  }

  /// Save last token sent to backend
  Future<void> saveLastSentToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token_sent', token);
  }

  /// Clear last sent token (on logout)
  Future<void> clearLastSentToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fcm_token_sent');
  }

  /// Check if token needs to be sent to backend
  Future<bool> shouldUpdateToken() async {
    final currentToken = await getSavedToken();
    final lastSentToken = await getLastSentToken();

    // Update if we have a token and it's different from last sent
    return currentToken != null && currentToken != lastSentToken;
  }

  /// Setup message handlers for foreground, background, and terminated states
  void setupMessageHandlers({
    required Function(RemoteMessage) onMessageReceived,
    required Function(RemoteMessage) onMessageOpenedApp,
  }) {
    // Foreground messages are displayed as system notifications
    // to keep the same UX as background/terminated states.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
          'Message notification: ${message.notification!.title} - ${message.notification!.body}',
        );

        // Show local notification even in foreground for unified behavior.
        _notificationService.showNotificationFromFCM(message);
      } else if (message.data.isNotEmpty) {
        // Data-only fallback for foreground.
        final title = (message.data['title'] ?? '').toString().trim();
        final body = (message.data['body'] ?? '').toString().trim();
        final channel = (message.data['channel'] ?? '')
            .toString()
            .toLowerCase();
        final targetChannelId = channel == 'payment'
            ? NotificationService.paymentChannelId
            : NotificationService.generalChannelId;

        if (title.isNotEmpty || body.isNotEmpty) {
          _notificationService.showCustomNotification(
            id: message.messageId.hashCode,
            title: title.isEmpty ? 'Notification' : title,
            body: body,
            channelId: targetChannelId,
            payload: message.data,
          );
        }
      }

      // Call custom handler
      onMessageReceived(message);
    });

    // Message opened app from background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification clicked! App opened from background');
      onMessageOpenedApp(message);
    });
  }

  /// Check initial message (opened from terminated state)
  Future<RemoteMessage?> getInitialMessage() async {
    return await _firebaseMessaging.getInitialMessage();
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  /// Get notification service instance
  NotificationService get notificationService => _notificationService;
}
