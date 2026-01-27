import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snakeaid_mobile/core/services/notification_service.dart';
import 'package:snakeaid_mobile/examples/theme_examples.dart';
import 'package:snakeaid_mobile/features/shared/screens/location_tracker_screen.dart';
import 'package:snakeaid_mobile/features/shared/screens/signalr_test_screen.dart';
import 'core/services/background_notification_service.dart';
import 'core/services/fcm_service.dart';
import 'app/theme.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnakeAid Mobile',
      debugShowCheckedModeBanner: false,

      // Sử dụng AppTheme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Tự động chuyển đổi theo system
      // Define routes
      initialRoute: '/',
      routes: {
        '/': (context) => const ThemeExamples(),
        '/signalr-test': (context) => const SignalRTestScreen(),
        '/map-test': (context) => const LocationTrackerScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool isDarkMode = false;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar sử dụng theme đã định nghĩa
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleTheme,
            tooltip: 'Toggle Theme',
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          children: [
            // Ví dụ sử dụng Card với theme
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme Demo',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: AppTheme.spacingSmall),
                    Text(
                      'Đây là ví dụ về cách sử dụng AppTheme',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppTheme.spacingSmall),
                    Text(
                      'Current theme: ${isDarkMode ? "Dark" : "Light"}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingLarge),

            // Ví dụ sử dụng TextField với theme
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nhập text',
                hintText: 'Placeholder text',
                prefixIcon: Icon(Icons.text_fields),
              ),
            ),

            const SizedBox(height: AppTheme.spacingLarge),

            // Ví dụ Counter với text theme
            Center(
              child: Column(
                children: [
                  Text(
                    'Bạn đã nhấn nút này:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingLarge),

            // Ví dụ buttons với theme
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _incrementCounter,
                  child: const Text('Tăng'),
                ),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _counter = 0;
                    });
                  },
                  child: const Text('Reset'),
                ),
                TextButton(
                  onPressed: _toggleTheme,
                  child: const Text('Đổi Theme'),
                ),
              ],
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Tăng counter',
        child: const Icon(Icons.add),
      ),
    );
  }
}
