import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snakeaid_mobile/features/shared/widgets/main_scaffold.dart';
import 'package:snakeaid_mobile/features/shared/screens/location_tracker_screen.dart';
import 'package:snakeaid_mobile/features/shared/screens/signalr_test_screen.dart';
import 'package:snakeaid_mobile/features/auth/screens/splash_screen.dart';
import 'package:snakeaid_mobile/features/auth/screens/role_selection_screen.dart';
import 'package:snakeaid_mobile/features/auth/screens/member/member_login_screen.dart';
import 'package:snakeaid_mobile/features/auth/screens/member/member_registration_screen.dart';
import 'package:snakeaid_mobile/features/auth/screens/rescuer/rescuer_login_screen.dart';
import 'package:snakeaid_mobile/features/auth/screens/rescuer/rescuer_registration_screen.dart';
import 'package:snakeaid_mobile/features/auth/screens/rescuer/rescuer_terms_screen.dart';
import 'package:snakeaid_mobile/features/auth/screens/expert/expert_login_screen.dart';
import 'package:snakeaid_mobile/features/auth/screens/expert/expert_registration_screen.dart';
import 'package:snakeaid_mobile/features/auth/screens/expert/expert_credentials_screen.dart';
import 'package:snakeaid_mobile/features/auth/screens/otp_verification_screen.dart';
import 'package:snakeaid_mobile/features/auth/screens/registration_success_screen.dart';
import 'package:snakeaid_mobile/features/auth/screens/registration_pending_screen.dart';
import 'package:snakeaid_mobile/features/auth/screens/forgot_password_screen.dart';
import 'package:snakeaid_mobile/features/auth/screens/forgot_password_otp_screen.dart';
import 'package:snakeaid_mobile/features/auth/screens/reset_password_screen.dart';
import 'package:snakeaid_mobile/features/auth/screens/password_reset_success_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/emergency_alert_screen.dart';

/// App routing configuration using go_router
final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    // === AUTH ROUTES ===
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/role-selection',
      name: 'role_selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    
    // Member Auth Routes
    GoRoute(
      path: '/member-login',
      name: 'member_login',
      builder: (context, state) => const MemberLoginScreen(),
    ),
    GoRoute(
      path: '/member-registration',
      name: 'member_registration',
      builder: (context, state) => const MemberRegistrationScreen(),
    ),
    
    // Rescuer Auth Routes
    GoRoute(
      path: '/rescuer-login',
      name: 'rescuer_login',
      builder: (context, state) => const RescuerLoginScreen(),
    ),
    GoRoute(
      path: '/rescuer-registration',
      name: 'rescuer_registration',
      builder: (context, state) => const RescuerRegistrationScreen(),
    ),
    GoRoute(
      path: '/rescuer-terms',
      name: 'rescuer_terms',
      builder: (context, state) {
        final data = state.extra as Map<String, String>;
        return RescuerTermsScreen(registrationData: data);
      },
    ),
    
    // Expert Auth Routes
    GoRoute(
      path: '/expert-login',
      name: 'expert_login',
      builder: (context, state) => const ExpertLoginScreen(),
    ),
    GoRoute(
      path: '/expert-registration',
      name: 'expert_registration',
      builder: (context, state) => const ExpertRegistrationScreen(),
    ),
    GoRoute(
      path: '/expert-credentials',
      name: 'expert_credentials',
      builder: (context, state) {
        final data = state.extra as Map<String, String>;
        return ExpertCredentialsScreen(registrationData: data);
      },
    ),
    
    // Common Auth Routes
    GoRoute(
      path: '/otp-verification',
      name: 'otp_verification',
      builder: (context, state) {
        final email = state.extra as String;
        return OtpVerificationScreen(email: email);
      },
    ),
    GoRoute(
      path: '/registration-success',
      name: 'registration_success',
      builder: (context, state) {
        final email = state.extra as String;
        return RegistrationSuccessScreen(email: email);
      },
    ),
    GoRoute(
      path: '/registration-pending',
      name: 'registration_pending',
      builder: (context, state) {
        final email = state.extra as String;
        return RegistrationPendingScreen(email: email);
      },
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot_password',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return ForgotPasswordScreen(
          themeColor: data['themeColor'] as Color,
          roleRoute: data['roleRoute'] as String,
        );
      },
    ),
    GoRoute(
      path: '/forgot-password-otp',
      name: 'forgot_password_otp',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return ForgotPasswordOtpScreen(
          email: data['email'] as String,
          themeColor: data['themeColor'] as Color,
          roleRoute: data['roleRoute'] as String,
        );
      },
    ),
    GoRoute(
      path: '/reset-password',
      name: 'reset_password',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return ResetPasswordScreen(
          email: data['email'] as String,
          themeColor: data['themeColor'] as Color,
          roleRoute: data['roleRoute'] as String,
        );
      },
    ),
    GoRoute(
      path: '/password-reset-success',
      name: 'password_reset_success',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return PasswordResetSuccessScreen(
          themeColor: data['themeColor'] as Color,
          roleRoute: data['roleRoute'] as String,
        );
      },
    ),
    
    // === MEMBER APP ROUTES ===
    GoRoute(
      path: '/member-home',
      name: 'member_home',
      builder: (context, state) => const MainScaffold(initialIndex: 0),
    ),
    
    // === EMERGENCY ROUTES ===
    GoRoute(
      path: '/emergency-alert',
      name: 'emergency_alert',
      builder: (context, state) => const EmergencyAlertScreen(),
    ),
    
    // === SHARED/UTILS ROUTES ===
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
