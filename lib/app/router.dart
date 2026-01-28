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
import 'package:snakeaid_mobile/features/emergency/screens/members/snake_identification_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/snake_identification_result_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/snake_selection_by_location_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/snake_identification_questions_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/snake_filtered_results_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/snake_confirmation_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/generic_first_aid_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/first_aid_steps_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/symptom_report_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/severity_assessment_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/emergency_tracking_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/rescuer_arrived_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/emergency_service_completion_screen.dart';
import 'package:snakeaid_mobile/features/member/screens/messages_screen.dart';
import 'package:snakeaid_mobile/features/member/screens/message_detail_screen.dart';
import 'package:snakeaid_mobile/features/rescuer/screens/rescuer_home_screen.dart';

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
        final data = state.extra as Map<String, dynamic>;
        return OtpVerificationScreen(
          email: data['email'] as String,
          roleRoute: data['roleRoute'] as String,
          themeColor: data['themeColor'] as Color,
        );
      },
    ),
    GoRoute(
      path: '/registration-success',
      name: 'registration_success',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return RegistrationSuccessScreen(
          email: data['email'] as String,
          roleRoute: data['roleRoute'] as String,
          themeColor: data['themeColor'] as Color,
        );
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
    
    // === RESCUER APP ROUTES ===
    GoRoute(
      path: '/rescuer-home',
      name: 'rescuer_home',
      builder: (context, state) => const RescuerHomeScreen(),
    ),
    
    // === EMERGENCY ROUTES ===
    GoRoute(
      path: '/emergency-alert',
      name: 'emergency_alert',
      builder: (context, state) => const EmergencyAlertScreen(),
    ),
    GoRoute(
      path: '/snake-identification',
      name: 'snake_identification',
      builder: (context, state) => const SnakeIdentificationScreen(),
    ),
    // Note: SnakeIdentificationResultScreen requires File snakeImage, not navigable via route name
    // Use Navigator.push with MaterialPageRoute to pass File object
    GoRoute(
      path: '/snake-selection-by-location',
      name: 'snake_selection_by_location',
      builder: (context, state) => const SnakeSelectionByLocationScreen(),
    ),
    GoRoute(
      path: '/snake-identification-questions',
      name: 'snake_identification_questions',
      builder: (context, state) => const SnakeIdentificationQuestionsScreen(),
    ),
    GoRoute(
      path: '/snake-filtered-results',
      name: 'snake_filtered_results',
      builder: (context, state) {
        final answers = state.extra as Map<int, String>;
        return SnakeFilteredResultsScreen(answers: answers);
      },
    ),
    GoRoute(
      path: '/snake-confirmation',
      name: 'snake_confirmation',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return SnakeConfirmationScreen(
          snakeName: data['snakeName'] as String,
          englishName: data['englishName'] as String,
          scientificName: data['scientificName'] as String,
          isPoisonous: data['isPoisonous'] as bool,
          imageUrl: data['imageUrl'] as String?,
          features: (data['features'] as List<dynamic>).cast<IdentificationFeature>(),
          matchedFeaturesCount: data['matchedFeaturesCount'] as int,
        );
      },
    ),
    GoRoute(
      path: '/generic-first-aid',
      name: 'generic_first_aid',
      builder: (context, state) => const GenericFirstAidScreen(),
    ),
    GoRoute(
      path: '/first-aid-steps',
      name: 'first_aid_steps',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return FirstAidStepsScreen(
          snakeName: data['snakeName'] as String,
          snakeNameVi: data['snakeNameVi'] as String,
          venomType: data['venomType'] as String,
          snakeImageUrl: data['snakeImageUrl'] as String,
        );
      },
    ),
    GoRoute(
      path: '/symptom-report',
      name: 'symptom_report',
      builder: (context, state) => const SymptomReportScreen(),
    ),
    GoRoute(
      path: '/severity-assessment',
      name: 'severity_assessment',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        return SeverityAssessmentScreen(
          severityScore: data?['severityScore'] as int? ?? 85,
          riskFactors: data?['riskFactors'] as List<String>? ?? [],
          timeSinceBite: data?['timeSinceBite'] as String? ?? '15 phút',
          painLevel: data?['painLevel'] as int? ?? 7,
        );
      },
    ),
    GoRoute(
      path: '/emergency-tracking',
      name: 'emergency_tracking',
      builder: (context, state) => const EmergencyTrackingScreen(),
    ),
    GoRoute(
      path: '/rescuer-arrived',
      name: 'rescuer_arrived',
      builder: (context, state) => const RescuerArrivedScreen(),
    ),
    GoRoute(
      path: '/emergency-completion',
      name: 'emergency_completion',
      builder: (context, state) => const EmergencyServiceCompletionScreen(),
    ),
    
    // === MEMBER ROUTES ===
    GoRoute(
      path: '/messages',
      name: 'messages',
      builder: (context, state) => const MessagesScreen(),
    ),
    GoRoute(
      path: '/message-detail',
      name: 'message_detail',
      builder: (context, state) {
        final thread = state.extra as MessageThread;
        return MessageDetailScreen(thread: thread);
      },
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
