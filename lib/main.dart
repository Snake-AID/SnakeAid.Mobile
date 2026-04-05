import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:snakeaid_mobile/core/services/notification_service.dart';
import 'package:snakeaid_mobile/core/services/fcm_service.dart';
import 'core/config/base_url_config.dart';
import 'core/handlers/deep_link_handler.dart';
import 'package:snakeaid_mobile/features/auth/providers/auth_provider.dart';
import 'package:snakeaid_mobile/features/consultation/widgets/expert_global_emergency_popup_listener.dart';
import 'package:snakeaid_mobile/features/notifications/providers/notification_inbox_provider.dart';
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

  // Display notification
  if (message.notification == null && message.data.isNotEmpty) {
    final title = (message.data['title'] ?? '').toString().trim();
    final body = (message.data['body'] ?? '').toString().trim();
    if (title.isNotEmpty || body.isNotEmpty) {
      await notificationService.showCustomNotification(
        id: message.messageId.hashCode,
        title: title.isEmpty ? 'Notification' : title,
        body: body,
        channelId: NotificationService.generalChannelId,
        payload: message.data,
      );
    }
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

  // Initialize Firebase
  await Firebase.initializeApp();

  // Set up background message handler (must be done early)
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize FCM and Notification services
  final fcmService = FCMService();
  await fcmService.initialize();
  fcmService.setupMessageHandlers(
    onMessageReceived: (message) {
      debugPrint('📩 Foreground message received in app runtime');
    },
    onMessageOpenedApp: (message) {
      debugPrint('🖱️ Notification tapped to open app');
    },
  );

  runApp(
    ProviderScope(
      overrides: [baseUrlConfigProvider.overrideWithValue(baseUrlConfig)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _handledLogoutRedirect = false;

  @override
  Widget build(BuildContext context) {
    final isExpert = ref.watch(isExpertProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      // Check 2 scenarios:
      // 1. State changed from authenticated → unauthenticated (normal logout flow)
      // 2. Initial state is unauthenticated (logout happened during startup)
      final wasAuthenticated = previous?.isAuthenticated ?? false;
      final becameLoggedOut = wasAuthenticated && !next.isAuthenticated;
      final startedUnauthenticated = previous == null && !next.isAuthenticated;

      if ((!becameLoggedOut && !startedUnauthenticated) ||
          _handledLogoutRedirect)
        return;

      _handledLogoutRedirect = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        ref.invalidate(notificationInboxProvider);

        // Navigate to login immediately - ScaffoldMessenger is not available at MyApp level
        debugPrint('🔐 Logout detected - navigating to role selection');
        context.go('/role-selection');

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _handledLogoutRedirect = false;
        });
      });
    });

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
