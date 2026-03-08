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
import 'package:snakeaid_mobile/features/emergency/screens/members/snake_selection_by_location_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/snake_identification_questions_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/snake_filtered_results_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/snake_confirmation_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/generic_first_aid_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/first_aid_steps_screen.dart';
import 'package:snakeaid_mobile/features/emergency/models/sos_incident_response.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/symptom_report_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/severity_assessment_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/emergency_tracking_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/member_incident_detail_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/rescuer_arrived_screen.dart'
    as member_screens;
import 'package:snakeaid_mobile/features/emergency/screens/members/emergency_service_completion_screen.dart';
import 'package:snakeaid_mobile/features/member/screens/messages_screen.dart';
import 'package:snakeaid_mobile/features/member/screens/message_detail_screen.dart';
import 'package:snakeaid_mobile/features/member/screens/activity_detail_screen.dart';
import 'package:snakeaid_mobile/features/expert/screens/expert_home_screen.dart';
import 'package:snakeaid_mobile/features/expert/screens/expert_settings_screen.dart';
import 'package:snakeaid_mobile/features/expert/screens/expert_edit_profile_screen.dart';
import 'package:snakeaid_mobile/features/expert/screens/expert_id_documents_screen.dart';
import 'package:snakeaid_mobile/features/expert/screens/expert_specialties_screen.dart';
import 'package:snakeaid_mobile/features/expert/screens/expert_feedback_screen.dart';
import 'package:snakeaid_mobile/features/rescuer/screens/rescuer_home_screen.dart';
import 'package:snakeaid_mobile/features/snake_catching/screens/rescuers/rescuer_available_jobs_screen.dart';
import 'package:snakeaid_mobile/features/snake_catching/screens/rescuers/rescuer_request_detail_screen.dart';
import 'package:snakeaid_mobile/features/snake_catching/screens/members/snake_quantity_selection_screen.dart';
import 'package:snakeaid_mobile/features/snake_catching/screens/members/snake_report_detail_screen.dart';
import 'package:snakeaid_mobile/features/snake_catching/screens/members/snake_catching_success_screen.dart';
import 'package:snakeaid_mobile/features/snake_catching/models/snake_catching_request.dart';
import 'package:snakeaid_mobile/features/rescuer/screens/rescuer_settings_screen.dart';
import 'package:snakeaid_mobile/features/rescuer/screens/rescuer_edit_profile_screen.dart';
import 'package:snakeaid_mobile/features/rescuer/screens/rescuer_history_screen.dart';
import 'package:snakeaid_mobile/features/rescuer/screens/rescuer_history_detail_screen.dart';
import 'package:snakeaid_mobile/features/rescuer/screens/rescuer_income_management_screen.dart';
import 'package:snakeaid_mobile/features/rescuer/screens/rescuer_feedback_screen.dart';
import 'package:snakeaid_mobile/features/rescuer/screens/rescuer_id_documents_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/rescuers/rescuer_mission_detail_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/rescuers/rescuer_navigation_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/rescuers/rescuer_arrived_screen.dart'
    as rescuer_screens;
import 'package:snakeaid_mobile/features/emergency/screens/rescuers/rescuer_support_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/rescuers/find_hospital_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/rescuers/mission_completion_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/rescuers/rescuer_mission_success_screen.dart';
import 'package:snakeaid_mobile/features/video_call/screens/demo_video_call_screen.dart';
import 'package:snakeaid_mobile/features/emergency/models/route_navigation_data.dart';

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

    // Expert Home
    GoRoute(
      path: '/expert-home',
      name: 'expert_home',
      builder: (context, state) => const ExpertHomeScreen(),
    ),

    // === EXPERT APP ROUTES ===
    // Expert Settings
    GoRoute(
      path: '/expert-settings',
      name: 'expert_settings',
      builder: (context, state) => const ExpertSettingsScreen(),
    ),

    // Expert Edit Profile
    GoRoute(
      path: '/expert-edit-profile',
      name: 'expert_edit_profile',
      builder: (context, state) => const ExpertEditProfileScreen(),
    ),

    // Expert ID Documents
    GoRoute(
      path: '/expert-id-documents',
      name: 'expert_id_documents',
      builder: (context, state) => const ExpertIdDocumentsScreen(),
    ),

    // Expert Specialties
    GoRoute(
      path: '/expert-specialties',
      name: 'expert_specialties',
      builder: (context, state) => const ExpertSpecialtiesScreen(),
    ),

    // Expert Feedback
    GoRoute(
      path: '/expert-feedback',
      name: 'expert_feedback',
      builder: (context, state) => const ExpertFeedbackScreen(),
    ),
    // Note: Expert consultation and emergency routes will be added here
    // as the expert workflow screens are implemented

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

    // Rescuer Available Jobs
    GoRoute(
      path: '/rescuer-available-jobs',
      name: 'rescuer_available_jobs',
      builder: (context, state) => const RescuerAvailableJobsScreen(),
    ),

    // Rescuer Request Detail
    GoRoute(
      path: '/rescuer-request-detail/:requestId',
      name: 'rescuer_request_detail',
      builder: (context, state) {
        final requestId = state.pathParameters['requestId']!;
        final requestData = state.extra as SnakeCatchingRequestData?;
        return RescuerRequestDetailScreen(
          requestId: requestId,
          requestData: requestData,
        );
      },
    ),

    // === MEMBER SNAKE CATCHING ROUTES ===
    // Snake Quantity Selection
    GoRoute(
      path: '/snake-quantity-selection',
      name: 'snake_quantity_selection',
      builder: (context, state) => const SnakeQuantitySelectionScreen(),
    ),

    // Snake Report Detail
    GoRoute(
      path: '/snake-report-detail/:quantity',
      name: 'snake_report_detail',
      builder: (context, state) {
        final quantity = state.pathParameters['quantity'] ?? 'single';
        return SnakeReportDetailScreen(quantity: quantity);
      },
    ),

    // Snake Catching Success
    GoRoute(
      path: '/snake-catching-success',
      name: 'snake_catching_success',
      builder: (context, state) {
        final requestData = state.extra as SnakeCatchingRequestData;
        return SnakeCatchingSuccessScreen(requestData: requestData);
      },
    ),

    // Activity Detail
    GoRoute(
      path: '/activity-detail/:requestId',
      name: 'activity_detail',
      builder: (context, state) {
        final requestId = state.pathParameters['requestId']!;
        return ActivityDetailScreen(requestId: requestId);
      },
    ),

    // Rescuer Settings
    GoRoute(
      path: '/rescuer-settings',
      name: 'rescuer_settings',
      builder: (context, state) => const RescuerSettingsScreen(),
    ),

    // Rescuer Edit Profile
    GoRoute(
      path: '/rescuer-edit-profile',
      name: 'rescuer_edit_profile',
      builder: (context, state) => const RescuerEditProfileScreen(),
    ),

    // Rescuer History
    GoRoute(
      path: '/rescuer-history',
      name: 'rescuer_history',
      builder: (context, state) => const RescuerHistoryScreen(),
    ),
    GoRoute(
      path: '/rescuer-history-detail',
      name: 'rescuer_history_detail',
      builder: (context, state) {
        final mission = state.extra as Map<String, dynamic>;
        return RescuerHistoryDetailScreen(mission: mission);
      },
    ),

    // Rescuer Income Management
    GoRoute(
      path: '/rescuer-income-management',
      name: 'rescuer_income_management',
      builder: (context, state) => const RescuerIncomeManagementScreen(),
    ),

    // Rescuer Feedback
    GoRoute(
      path: '/rescuer-feedback',
      name: 'rescuer_feedback',
      builder: (context, state) => const RescuerFeedbackScreen(),
    ),

    // Rescuer ID Documents
    GoRoute(
      path: '/rescuer-id-documents',
      name: 'rescuer_id_documents',
      builder: (context, state) => const RescuerIdDocumentsScreen(),
    ),

    GoRoute(
      path: '/rescuer/mission-detail/:missionId',
      name: 'rescuer_mission_detail',
      builder: (context, state) {
        final missionId = state.pathParameters['missionId']!;
        return RescuerMissionDetailScreen(missionId: missionId);
      },
    ),
    GoRoute(
      path: '/rescuer/navigation',
      name: 'rescuer_navigation',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return RescuerNavigationScreen(
          missionId: data['missionId'] as String,
          mission: data['mission'],
          routeData: data['routeData'] as RouteNavigationData?,
        );
      },
    ),
    GoRoute(
      path: '/rescuer/arrived',
      name: 'rescuer_arrived',
      builder: (context, state) => const rescuer_screens.RescuerArrivedScreen(),
    ),
    GoRoute(
      path: '/rescuer/support',
      name: 'rescuer_support',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return RescuerSupportScreen(
          missionId: extra?['missionId'] as String? ?? '',
          incidentId: extra?['incidentId'] as String? ?? '',
        );
      },
    ),
    GoRoute(
      path: '/rescuer/find-hospital',
      name: 'rescuer_find_hospital',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return FindHospitalScreen(
          missionId: extra?['missionId'] as String? ?? '',
          incidentId: extra?['incidentId'] as String? ?? '',
        );
      },
    ),
    GoRoute(
      path: '/rescuer/mission-completion',
      name: 'rescuer_mission_completion',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return MissionCompletionScreen(
          missionId: extra?['missionId'] as String? ?? '',
        );
      },
    ),
    GoRoute(
      path: '/rescuer/mission-success',
      name: 'rescuer_mission_success',
      builder: (context, state) => const RescuerMissionSuccessScreen(),
    ),

    // === EMERGENCY ROUTES ===
    GoRoute(
      path: '/emergency-alert',
      name: 'emergency_alert',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return EmergencyAlertScreen(
          incident: extra?['incident'] as IncidentData?,
        );
      },
    ),
    GoRoute(
      path: '/snake-identification',
      name: 'snake_identification',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return SnakeIdentificationScreen(
          incident: extra?['incident'] as IncidentData?,
        );
      },
    ),
    // Note: SnakeIdentificationResultScreen requires File snakeImage, not navigable via route name
    // Use Navigator.push with MaterialPageRoute to pass File object
    GoRoute(
      path: '/snake-selection-by-location',
      name: 'snake_selection_by_location',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        return SnakeSelectionByLocationScreen(
          incident: data?['incident'] as IncidentData?,
        );
      },
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
          features: (data['features'] as List<dynamic>)
              .cast<IdentificationFeature>(),
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
        return FirstAidStepsScreen(incident: data['incident'] as IncidentData);
      },
    ),
    GoRoute(
      path: '/symptom-report',
      name: 'symptom_report',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return SymptomReportScreen(
          incidentId: data['incidentId'] as String,
          recognitionResultId: data['recognitionResultId'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/severity-assessment',
      name: 'severity_assessment',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        return SeverityAssessmentScreen(
          incidentId: data?['incidentId'] as String? ?? '',
          recognitionResultId: data?['recognitionResultId'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/emergency-tracking',
      name: 'emergency_tracking',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return EmergencyTrackingScreen(
          incidentId: extra?['incidentId'] as String?,
          missionId: extra?['missionId'] as String?,
          rescuerId: extra?['rescuerId'] as String?,
        );
      },
      routes: [
        // Spoke screen: Snake identification via camera
        GoRoute(
          path: 'snake-identification',
          name: 'emergency_snake_identification',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>?;
            return SnakeIdentificationScreen(
              incident: data?['incident'] as IncidentData?,
            );
          },
        ),
        // Spoke screen: Incident detail view
        GoRoute(
          path: 'incident-detail',
          name: 'emergency_incident_detail',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>?;
            final incidentId = data?['incidentId'] as String?;
            return MemberIncidentDetailScreen(incidentId: incidentId ?? '');
          },
        ),
      ],
    ),
    GoRoute(
      path: '/member-rescuer-arrived',
      name: 'member_rescuer_arrived',
      builder: (context, state) => const member_screens.RescuerArrivedScreen(),
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

    // === VIDEO CALL DEMO ROUTE ===
    GoRoute(
      path: '/demo-video-call',
      name: 'demo_video_call',
      builder: (context, state) => const DemoVideoCallScreen(),
    ),
  ],
);
