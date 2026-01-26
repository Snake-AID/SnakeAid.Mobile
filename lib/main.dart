import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snakeaid_mobile/core/services/notification_service.dart';
import 'core/services/background_notification_service.dart';
import 'core/services/fcm_service.dart';
import 'app/router.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase for background handler
  await Firebase.initializeApp();

  // Initialize notification service to display notification
  final notificationService = NotificationService();
  await notificationService.initialize();

  debugPrint('🔔 Background message received: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');

  // Display notification in background/terminated state
  if (message.notification != null) {
    await notificationService.showNotificationFromFCM(message);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // // Initialize Firebase
  // await Firebase.initializeApp();

  // // Set up background message handler (must be done early)
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // // Initialize Background Service (để nhận notification khi app bị kill)
  // try {
  //   await BackgroundNotificationService.initializeService();
  //   debugPrint('Background service initialized');
  // } catch (e) {
  //   debugPrint('Background service initialization failed: $e');
  // }

  // // Initialize FCM and Notification services
  // final fcmService = FCMService();
  // await fcmService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'SnakeAid Mobile',
      debugShowCheckedModeBanner: false,
      
      // TODO: Replace with new theme when redesigned
      // For now using default Material Design 3 theme
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      
      // Use go_router configuration
      routerConfig: router,
    );
  }
}
