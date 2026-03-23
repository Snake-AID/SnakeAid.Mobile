import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snakeaid_mobile/core/services/notification_service.dart';
import 'core/config/base_url_config.dart';
import 'core/handlers/deep_link_handler.dart';
import 'package:snakeaid_mobile/features/auth/providers/auth_provider.dart';
import 'package:snakeaid_mobile/features/consultation/widgets/expert_global_emergency_popup_listener.dart';
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

/// Global instance of DeepLinkHandler for access in providers
DeepLinkHandler? _deepLinkHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Create BaseUrlConfig with SharedPreferences
  final baseUrlConfig = createBaseUrlConfig(prefs);

  // Create DeepLinkHandler
  _deepLinkHandler = DeepLinkHandler(baseUrlConfig);

  // Initialize deep link handler
  await _deepLinkHandler!.initialize();

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

  runApp(
    ProviderScope(
      overrides: [baseUrlConfigProvider.overrideWithValue(baseUrlConfig)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpert = ref.watch(isExpertProvider);

    return MaterialApp.router(
      title: 'SnakeAid Mobile',
      debugShowCheckedModeBanner: false,

      // // Use AppTheme from auth branch
      // theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      // themeMode: ThemeMode.system,

      // Use go_router configuration
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            if (isExpert) const ExpertGlobalEmergencyPopupListener(),
          ],
        );
      },
    );
  }
}
