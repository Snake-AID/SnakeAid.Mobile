import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snakeaid_mobile/core/services/notification_service.dart';
import 'package:snakeaid_mobile/core/services/background_notification_service.dart';
import 'package:snakeaid_mobile/core/services/fcm_service.dart';
import 'core/config/base_url_config.dart';
import 'core/handlers/deep_link_handler.dart';
import 'package:snakeaid_mobile/features/auth/models/user_role.dart';
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

  // Initialize Firebase
  await Firebase.initializeApp();

  // Set up background message handler (must be done early)
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Background Service (để nhận notification khi app bị kill)
  try {
    await BackgroundNotificationService.initializeService();
    debugPrint('Background service initialized');
  } catch (e) {
    debugPrint('Background service initialization failed: $e');
  }

  // Initialize FCM and Notification services
  final fcmService = FCMService();
  await fcmService.initialize();

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
  bool _sessionDialogShowing = false;

  void _showSessionExpiredDialog(UserRole? role) {
    final ctx = router.routerDelegate.navigatorKey.currentContext;
    if (ctx == null || _sessionDialogShowing) return;
    _sessionDialogShowing = true;

    String loginRoute;
    switch (role) {
      case UserRole.expert:
        loginRoute = '/expert-login';
        break;
      case UserRole.rescuer:
        loginRoute = '/rescuer-login';
        break;
      default:
        loginRoute = '/member-login';
    }

    showDialog<void>(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFDC3545).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_clock_outlined,
                  color: Color(0xFFDC3545), size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Phên đăng nhập hết hạn',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Phên làm việc của bạn đã kết thúc. Vui lòng đăng nhập lại để tiếp tục sử dụng.',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _sessionDialogShowing = false;
                ref.read(authProvider.notifier).clearSessionExpired();
                router.go(loginRoute);
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFDC3545),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Đăng nhập lại',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.sessionExpired && !_sessionDialogShowing) {
        WidgetsBinding.instance.addPostFrameCallback(
            (_) => _showSessionExpiredDialog(next.sessionExpiredRole));
      }
    });

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
