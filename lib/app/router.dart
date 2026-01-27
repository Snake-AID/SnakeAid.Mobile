import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snakeaid_mobile/features/shared/widgets/main_scaffold.dart';
import 'package:snakeaid_mobile/features/shared/screens/location_tracker_screen.dart';
import 'package:snakeaid_mobile/features/shared/screens/signalr_test_screen.dart';

/// App routing configuration using go_router
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const MainScaffold(initialIndex: 0),
    ),
    GoRoute(
      path: '/location-tracker',
      name: 'location_tracker',
      builder: (context, state) => const LocationTrackerScreen(),
    ),
    GoRoute(
      path: '/signalr-test',
      name: 'signalr_test',
      builder: (context, state) => const SignalRTestScreen(),
    ),
  ],
);
