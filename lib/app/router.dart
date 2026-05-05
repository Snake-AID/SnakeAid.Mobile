import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snakeaid_mobile/features/shared/widgets/main_scaffold.dart';
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
import 'package:snakeaid_mobile/features/emergency/screens/members/snake_identification_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/snake_selection_by_location_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/snake_identification_questions_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/snake_filtered_results_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/snake_confirmation_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/first_aid_steps_screen.dart';
import 'package:snakeaid_mobile/features/emergency/models/sos_incident_response.dart';
import 'package:snakeaid_mobile/features/emergency/models/filtered_snake.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/symptom_report_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/severity_assessment_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/emergency_tracking_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/member_incident_detail_screen.dart';
import 'package:snakeaid_mobile/features/member/screens/member_incident_finished_detail_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/rescuer_arrived_screen.dart'
    as member_screens;
import 'package:snakeaid_mobile/features/emergency/screens/members/emergency_service_completion_screen.dart';
import 'package:snakeaid_mobile/features/member/screens/messages_screen.dart';
import 'package:snakeaid_mobile/features/member/screens/message_detail_screen.dart';
import 'package:snakeaid_mobile/features/member/screens/activity_detail_screen.dart';
import 'package:snakeaid_mobile/features/member/screens/member_history_screen.dart';
import 'package:snakeaid_mobile/features/notifications/screens/notification_inbox_screen.dart';
import 'package:snakeaid_mobile/features/community_report/screens/community_alert_map_screen.dart';
import 'package:snakeaid_mobile/features/expert/screens/expert_home_screen.dart';
import 'package:snakeaid_mobile/features/expert/screens/expert_settings_screen.dart';
import 'package:snakeaid_mobile/features/expert/screens/expert_edit_profile_screen.dart';
import 'package:snakeaid_mobile/features/expert/screens/expert_id_documents_screen.dart';
import 'package:snakeaid_mobile/features/expert/screens/expert_certificate_detail_screen.dart';
import 'package:snakeaid_mobile/features/expert/screens/expert_certificate_form_screen.dart';
import 'package:snakeaid_mobile/features/expert/screens/expert_specialties_screen.dart';
import 'package:snakeaid_mobile/features/expert/screens/expert_feedback_screen.dart';
import 'package:snakeaid_mobile/features/expert/screens/expert_working_hours_screen.dart';
import 'package:snakeaid_mobile/features/expert/screens/expert_user_guide_screen.dart';
import 'package:snakeaid_mobile/features/expert/screens/expert_faq_screen.dart';
import 'package:snakeaid_mobile/features/expert/screens/expert_contact_support_screen.dart';
import 'package:snakeaid_mobile/features/expert/screens/expert_terms_screen.dart';
import 'package:snakeaid_mobile/features/expert/screens/expert_privacy_screen.dart';
import 'package:snakeaid_mobile/features/expert/screens/ai_recognition_queue_screen.dart';
import 'package:snakeaid_mobile/features/expert/screens/ai_recognition_review_screen.dart';
import 'package:snakeaid_mobile/features/rescuer/screens/rescuer_home_screen.dart';
import 'package:snakeaid_mobile/features/snake_catching/screens/rescuers/rescuer_available_jobs_screen.dart';

import 'package:snakeaid_mobile/features/snake_catching/screens/members/snake_quantity_selection_screen.dart';
import 'package:snakeaid_mobile/features/snake_catching/screens/members/snake_report_detail_screen.dart';
import 'package:snakeaid_mobile/features/snake_catching/screens/members/snake_catching_success_screen.dart';
import 'package:snakeaid_mobile/features/snake_catching/models/snake_catching_request.dart';
import 'package:snakeaid_mobile/features/rescuer/screens/rescuer_settings_screen.dart';
import 'package:snakeaid_mobile/features/rescuer/screens/rescuer_edit_profile_screen.dart';
import 'package:snakeaid_mobile/features/rescuer/screens/rescuer_history_screen.dart';
import 'package:snakeaid_mobile/features/rescuer/screens/rescuer_history_detail_screen.dart';
import 'package:snakeaid_mobile/features/rescuer/screens/rescuer_income_management_screen.dart';
import 'package:snakeaid_mobile/features/lesson/screens/rescuer_lesson_screen.dart';
import 'package:snakeaid_mobile/features/rescuer/screens/rescuer_feedback_screen.dart';
import 'package:snakeaid_mobile/features/rescuer/screens/rescuer_id_documents_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/rescuers/rescuer_mission_detail_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/rescuers/rescuer_navigation_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/rescuers/rescuer_support_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/rescuers/find_hospital_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/rescuers/mission_completion_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/rescuers/rescuer_mission_success_screen.dart';
import 'package:snakeaid_mobile/features/video_call/screens/demo_video_call_screen.dart';
import 'package:snakeaid_mobile/features/emergency/models/route_navigation_data.dart';
import 'package:snakeaid_mobile/features/consultation/screens/members/consultation_home_screen.dart';
import 'package:snakeaid_mobile/features/consultation/screens/members/expert_list_screen.dart';
import 'package:snakeaid_mobile/features/consultation/screens/members/expert_profile_detail_screen.dart';
import 'package:snakeaid_mobile/features/consultation/screens/members/expert_reviews_screen.dart';
import 'package:snakeaid_mobile/features/consultation/screens/members/service_selection_screen.dart';
import 'package:snakeaid_mobile/features/consultation/screens/members/consultation_documents_screen.dart';
import 'package:snakeaid_mobile/features/consultation/screens/members/consultation_time_selection_screen.dart';
import 'package:snakeaid_mobile/features/consultation/screens/members/payment_confirmation_screen.dart';
import 'package:snakeaid_mobile/features/consultation/screens/members/video_consultation_screen.dart';
import 'package:snakeaid_mobile/features/consultation/screens/members/consultation_waiting_room_screen.dart';
import 'package:snakeaid_mobile/features/consultation/screens/members/consultation_completion_screen.dart';
import 'package:snakeaid_mobile/features/consultation/screens/members/emergency_request_waiting_screen.dart';
import 'package:snakeaid_mobile/features/consultation/screens/shared/consultation_message_history_screen.dart';
import 'package:snakeaid_mobile/features/consultation/screens/experts/expert_waiting_room_screen.dart';
import 'package:snakeaid_mobile/features/consultation/screens/experts/expert_consultation_detail_screen.dart';
import 'package:snakeaid_mobile/features/consultation/screens/experts/expert_consultation_completion_screen.dart';
import 'package:snakeaid_mobile/features/snake_species/screens/snake_library_screen.dart';
import 'package:snakeaid_mobile/features/snake_species/screens/snake_detail_screen.dart';
import 'package:snakeaid_mobile/features/snake_species/screens/snake_first_aid_screen.dart';
import 'package:snakeaid_mobile/features/blog/screens/member/blog_list_screen.dart';
import 'package:snakeaid_mobile/features/blog/screens/member/blog_detail_screen.dart';
import 'package:snakeaid_mobile/features/blog/screens/expert/expert_blog_list_screen.dart';
import 'package:snakeaid_mobile/features/blog/screens/expert/expert_blog_form_screen.dart';
import 'package:snakeaid_mobile/features/blog/models/blog_model.dart';

/// App routing configuration using go_router
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/providers/auth_provider.dart';

final router = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context, listen: false);
    final authState = container.read(authProvider);
    final user = authState.user;
    final isExpert = user?.role.name == 'expert';
    final isVerified = user?.isVerified == true;
    final isAuth = authState.isAuthenticated;
    final path = state.uri.path;

    // Nếu là expert, đã đăng nhập, nhưng chưa verified
    if (isAuth && isExpert && !isVerified) {
      // Chỉ cho phép vào các trang liên quan đến chứng chỉ
      if (!path.startsWith('/expert-id-documents') &&
          !path.startsWith('/expert-credentials') &&
          !path.startsWith('/registration-pending')) {
        return '/expert-id-documents';
      }
    }
    // Nếu đã verified hoặc không phải expert thì cho vào bình thường
    return null;
  },
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
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final initialTab = (extra?['initialTab'] as int?) ?? 0;
        final initialConsultationsTab =
            (extra?['initialConsultationsTab'] as int?) ?? 0;
        return ExpertHomeScreen(
          initialTab: initialTab,
          initialConsultationsTab: initialConsultationsTab,
        );
      },
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
      routes: [
        GoRoute(
          path: 'new',
          name: 'expert_certificate_create',
          builder: (context, state) => const ExpertCertificateFormScreen(),
        ),
        GoRoute(
          path: ':certificateId',
          name: 'expert_certificate_detail',
          builder: (context, state) {
            final certificateId = state.pathParameters['certificateId'] ?? '';
            return ExpertCertificateDetailScreen(certificateId: certificateId);
          },
        ),
        GoRoute(
          path: ':certificateId/edit',
          name: 'expert_certificate_edit',
          builder: (context, state) {
            final certificateId = state.pathParameters['certificateId'] ?? '';
            return ExpertCertificateFormScreen(certificateId: certificateId);
          },
        ),
      ],
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

    // Expert Support Screens
    GoRoute(
      path: '/expert-user-guide',
      name: 'expert_user_guide',
      builder: (context, state) => const ExpertUserGuideScreen(),
    ),
    GoRoute(
      path: '/expert-faq',
      name: 'expert_faq',
      builder: (context, state) => const ExpertFaqScreen(),
    ),
    GoRoute(
      path: '/expert-terms',
      name: 'expert_terms',
      builder: (context, state) => const ExpertTermsScreen(),
    ),
    GoRoute(
      path: '/expert-contact-support',
      name: 'expert_contact_support',
      builder: (context, state) => const ExpertContactSupportScreen(),
    ),
    GoRoute(
      path: '/expert-privacy',
      name: 'expert_privacy',
      builder: (context, state) => const ExpertPrivacyScreen(),
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
          otp: data['otp'] as String,
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

    // === SNAKE SPECIES ROUTES ===
    GoRoute(
      path: '/snake-species',
      name: 'snake_library',
      builder: (context, state) => const SnakeLibraryScreen(),
    ),
    GoRoute(
      path: '/snake-first-aid-guide',
      name: 'snake_first_aid_guide',
      builder: (context, state) => const SnakeLibraryScreen(firstAidMode: true),
    ),
    // Expert variants (purple)
    GoRoute(
      path: '/expert/snake-species',
      name: 'expert_snake_library',
      builder: (context, state) =>
          const SnakeLibraryScreen(themeColor: Color(0xFF6C47C2)),
    ),
    GoRoute(
      path: '/expert/snake-first-aid-guide',
      name: 'expert_snake_first_aid_guide',
      builder: (context, state) => const SnakeLibraryScreen(
        firstAidMode: true,
        themeColor: Color(0xFF6C47C2),
      ),
    ),
    // Rescuer variants (orange)
    GoRoute(
      path: '/rescuer/snake-species',
      name: 'rescuer_snake_library',
      builder: (context, state) =>
          const SnakeLibraryScreen(themeColor: Color(0xFFFF6B35)),
    ),
    GoRoute(
      path: '/rescuer/snake-first-aid-guide',
      name: 'rescuer_snake_first_aid_guide',
      builder: (context, state) => const SnakeLibraryScreen(
        firstAidMode: true,
        themeColor: Color(0xFFFF6B35),
      ),
    ),
    GoRoute(
      path: '/snake-species/:id',
      name: 'snake_detail',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return SnakeDetailScreen(snakeId: id);
      },
    ),
    GoRoute(
      path: '/snake-first-aid/:id',
      name: 'snake_first_aid',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final extra = state.extra as Map<String, dynamic>?;
        return SnakeFirstAidScreen(
          snakeSpeciesId: id,
          commonName: extra?['commonName'] as String?,
        );
      },
    ),

    // === BLOG ROUTES (MEMBER) ===
    GoRoute(
      path: '/blogs',
      name: 'blog_list',
      builder: (context, state) => const BlogListScreen(),
    ),
    GoRoute(
      path: '/blogs/:id',
      name: 'blog_detail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BlogDetailScreen(blogId: id);
      },
    ),

    // === BLOG ROUTES (EXPERT) ===
    GoRoute(
      path: '/expert/blogs',
      name: 'expert_blog_list',
      builder: (context, state) => const ExpertBlogListScreen(),
    ),
    GoRoute(
      path: '/expert/blogs/new',
      name: 'expert_blog_new',
      builder: (context, state) => const ExpertBlogFormScreen(),
    ),
    GoRoute(
      path: '/expert/blogs/:id/edit',
      name: 'expert_blog_edit',
      builder: (context, state) {
        final blog = state.extra as BlogModel?;
        return ExpertBlogFormScreen(existingBlog: blog);
      },
    ),

    // === MEMBER APP ROUTES ===
    GoRoute(
      path: '/member-home',
      name: 'member_home',
      builder: (context, state) => const MainScaffold(initialIndex: 0),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationInboxScreen(),
    ),

    // === CONSULTATION ROUTES ===
    // Consultation Home
    GoRoute(
      path: '/consultation-home',
      name: 'consultation_home',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final highlightedId = extra?['newConsultationId'] as String?;
        final initialTab = extra?['initialTab'] as int? ?? 0;
        return ConsultationHomeScreen(
          highlightedId: highlightedId,
          initialTab: initialTab,
        );
      },
    ),

    // Waiting Room (before & after video call)
    GoRoute(
      path: '/video-waiting/:consultationId',
      name: 'video_waiting',
      builder: (context, state) {
        final id = state.pathParameters['consultationId']!;
        final extra = state.extra as Map<String, dynamic>?;
        return ConsultationWaitingRoomScreen(
          consultationId: id,
          expertName: extra?['expertName'] as String? ?? 'Chuyên Gia',
          expertSpecialty: extra?['expertSpecialty'] as String? ?? '',
          canReportExpertAbsent:
              extra?['canReportExpertAbsent'] as bool? ?? false,
          scheduledStartAtMs: extra?['scheduledStartAtMs'] as int?,
          showCompleteButton: extra?['showCompleteButton'] as bool? ?? false,
          durationSeconds: extra?['durationSeconds'] as int? ?? 0,
          initialMicOn: extra?['initialMicOn'] as bool? ?? true,
          initialCameraOn: extra?['initialCameraOn'] as bool? ?? true,
        );
      },
    ),

    // Video Consultation
    GoRoute(
      path: '/video-consultation/:consultationId',
      name: 'video_consultation',
      builder: (context, state) {
        final id = state.pathParameters['consultationId']!;
        final extra = state.extra as Map<String, dynamic>?;
        final expertName = extra?['expertName'] as String? ?? 'Chuyên Gia';
        final expertSpecialty = extra?['expertSpecialty'] as String? ?? '';
        final initialMicOn = extra?['initialMicOn'] as bool? ?? true;
        final initialCameraOn = extra?['initialCameraOn'] as bool? ?? true;
        final afterCallRoute = extra?['afterCallRoute'] as String?;
        final isExpertMode = extra?['isExpertMode'] as bool? ?? false;
        return VideoConsultationScreen(
          consultationId: id,
          expertName: expertName,
          expertSpecialty: expertSpecialty,
          initialMicOn: initialMicOn,
          initialCameraOn: initialCameraOn,
          afterCallRoute: afterCallRoute,
          isExpertMode: isExpertMode,
          livekitToken: extra?['livekitToken'] as String? ?? '',
          wsUrl: extra?['wsUrl'] as String? ?? '',
        );
      },
    ),

    // Expert Waiting Room (for experts before/after video call)
    GoRoute(
      path: '/expert-video-waiting/:consultationId',
      name: 'expert_video_waiting',
      builder: (context, state) {
        final id = state.pathParameters['consultationId']!;
        final extra = state.extra as Map<String, dynamic>?;
        // Accept both initial keys (patientName/consultationType from consultation card)
        // and return-trip keys (expertName/expertSpecialty from VideoConsultationScreen)
        final patientName =
            (extra?['patientName'] ?? extra?['expertName']) as String? ??
            'Bệnh Nhân';
        final consultationType =
            (extra?['consultationType'] ?? extra?['expertSpecialty'])
                as String? ??
            'Tư Vấn';
        return ExpertWaitingRoomScreen(
          consultationId: id,
          patientName: patientName,
          consultationType: consultationType,
          showCompleteButton: extra?['showCompleteButton'] as bool? ?? false,
          durationSeconds: extra?['durationSeconds'] as int? ?? 0,
          feeCost: extra?['feeCost'] as int? ?? 0,
          initialMicOn: extra?['initialMicOn'] as bool? ?? true,
          initialCameraOn: extra?['initialCameraOn'] as bool? ?? true,
        );
      },
    ),

    // Expert Consultation Completion
    GoRoute(
      path: '/expert-consultation-complete',
      name: 'expert_consultation_complete',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ExpertConsultationCompletionScreen(data: extra);
      },
    ),

    // Expert Working Hours
    GoRoute(
      path: '/expert-working-hours',
      name: 'expert_working_hours',
      builder: (context, state) => const ExpertWorkingHoursScreen(),
    ),

    // Expert AI Recognition Review Queue
    GoRoute(
      path: '/expert-ai-review-queue',
      name: 'expert_ai_review_queue',
      builder: (context, state) => const AiRecognitionQueueScreen(),
    ),

    // Expert AI Recognition Review Detail
    GoRoute(
      path: '/expert-ai-review/:recognitionResultId',
      name: 'expert_ai_review',
      builder: (context, state) {
        final id = state.pathParameters['recognitionResultId']!;
        return AiRecognitionReviewScreen(recognitionResultId: id);
      },
    ),

    // Expert Consultation Detail
    GoRoute(
      path: '/expert-consultation-detail',
      name: 'expert_consultation_detail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ExpertConsultationDetailScreen(data: extra);
      },
    ),

    GoRoute(
      path: '/consultation-message-history/:consultationId',
      name: 'consultation_message_history',
      builder: (context, state) {
        final consultationId = state.pathParameters['consultationId']!;
        final extra = state.extra as Map<String, dynamic>?;
        return ConsultationMessageHistoryScreen(
          consultationId: consultationId,
          title: extra?['title'] as String? ?? 'Phiên tư vấn',
          isExpertMode: extra?['isExpertMode'] as bool? ?? false,
        );
      },
    ),

    // Consultation Completion & Rating
    GoRoute(
      path: '/consultation-complete',
      name: 'consultation_complete',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ConsultationCompletionScreen(
          expertName: extra?['expertName'] as String? ?? 'Chuyên Gia',
          expertSpecialty: extra?['expertSpecialty'] as String? ?? '',
          expertAvatarUrl: extra?['expertAvatarUrl'] as String?,
          durationSeconds: extra?['durationSeconds'] as int? ?? 0,
          consultationId: extra?['consultationId'] as String? ?? '',
          consultationTime: extra?['consultationTime'] as DateTime?,
        );
      },
    ),

    // Expert List
    GoRoute(
      path: '/expert-list',
      name: 'expert_list',
      builder: (context, state) => const ExpertListScreen(),
    ),

    // Expert Profile Detail
    GoRoute(
      path: '/expert-detail/:expertId',
      name: 'expert_detail',
      builder: (context, state) {
        final expertId = state.pathParameters['expertId']!;
        return ExpertProfileDetailScreen(expertId: expertId);
      },
    ),

    // Expert Reviews (all)
    GoRoute(
      path: '/expert-reviews/:expertId',
      name: 'expert_reviews',
      builder: (context, state) {
        final expertId = state.pathParameters['expertId']!;
        final extra = state.extra as Map<String, dynamic>?;
        return ExpertReviewsScreen(
          expertId: expertId,
          expertName: extra?['expertName'] as String? ?? 'Chuyên gia',
          initialRating: (extra?['rating'] as num?)?.toDouble() ?? 0,
          initialReviewCount: (extra?['reviewCount'] as num?)?.toInt() ?? 0,
        );
      },
    ),

    // Service Selection
    GoRoute(
      path: '/service-selection/:expertId',
      name: 'service_selection',
      builder: (context, state) {
        final expertId = state.pathParameters['expertId']!;
        return ServiceSelectionScreen(expertId: expertId);
      },
    ),

    // Consultation Time Selection (for scheduled consultation)
    GoRoute(
      path: '/consultation-time-selection/:expertId',
      name: 'consultation_time_selection',
      builder: (context, state) {
        final expertId = state.pathParameters['expertId']!;
        return ConsultationTimeSelectionScreen(expertId: expertId);
      },
    ),

    // Consultation Documents Upload
    GoRoute(
      path: '/consultation-documents/:expertId',
      name: 'consultation_documents',
      builder: (context, state) {
        final expertId = state.pathParameters['expertId']!;
        final extraData = state.extra as Map<String, dynamic>?;

        return ConsultationDocumentsScreen(
          expertId: expertId,
          consultationType: extraData?['consultationType'],
          selectedDate: extraData?['selectedDate'],
          selectedTime: extraData?['selectedTime'],
          duration: extraData?['duration'],
          price: extraData?['price'],
          timeSlotId: extraData?['timeSlotId'],
        );
      },
    ),

    // Emergency consultation request waiting/tracking
    GoRoute(
      path: '/emergency-request-waiting/:requestId',
      name: 'emergency_request_waiting',
      builder: (context, state) {
        final requestId = state.pathParameters['requestId']!;
        final extraData = state.extra as Map<String, dynamic>?;
        return EmergencyRequestWaitingScreen(
          requestId: requestId,
          expertId: extraData?['expertId'] as String? ?? '',
          expertName: extraData?['expertName'] as String? ?? 'Chuyên gia',
        );
      },
    ),

    // Payment Confirmation
    GoRoute(
      path: '/payment-confirmation/:expertId',
      name: 'payment_confirmation',
      builder: (context, state) {
        final expertId = state.pathParameters['expertId']!;
        final extraData = state.extra as Map<String, dynamic>?;

        return PaymentConfirmationScreen(
          expertId: expertId,
          consultationType: extraData?['consultationType'],
          selectedDate: extraData?['selectedDate'],
          selectedTime: extraData?['selectedTime'],
          duration: extraData?['duration'],
          price: extraData?['price'],
          problemDescription: extraData?['problemDescription'],
          questions: extraData?['questions'],
          bookingId: extraData?['bookingId'] as String?,
          consultationId: extraData?['consultationId'] as String?,
          expertName: extraData?['expertName'] as String?,
        );
      },
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

    // Member History
    GoRoute(
      path: '/member-history',
      name: 'member_history',
      builder: (context, state) => const MemberHistoryScreen(),
    ),

    // Community Alert Map
    GoRoute(
      path: '/community-alert',
      name: 'community_alert_map',
      builder: (context, state) => const CommunityAlertMapScreen(),
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
        final missionId = state.pathParameters['missionId']!;
        return RescuerMissionDetailScreen(missionId: missionId);
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
      path: '/rescuer-feedback/:targetUserId',
      name: 'rescuer_feedback',
      builder: (context, state) => RescuerFeedbackScreen(
        targetUserId: state.pathParameters['targetUserId'] ?? '',
      ),
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
          incidentId: extra?['incidentId'] as String? ?? '',
        );
      },
    ),
    GoRoute(
      path: '/rescuer/mission-success',
      name: 'rescuer_mission_success',
      builder: (context, state) => const RescuerMissionSuccessScreen(),
    ),
    GoRoute(
      path: '/rescuer-lessons',
      name: 'rescuer_lessons',
      builder: (context, state) => const RescuerLessonScreen(),
    ),

    // === EMERGENCY ROUTES ===
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
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        return SnakeIdentificationQuestionsScreen(
          incidentId: data?['incidentId'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/snake-filtered-results',
      name: 'snake_filtered_results',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        final filteredSnakes = data['filteredSnakes'] as List<dynamic>;
        final selectedOptionIds = data['selectedOptionIds'] as List<dynamic>;
        return SnakeFilteredResultsScreen(
          filteredSnakes: filteredSnakes.cast<FilteredSnake>(),
          selectedOptionIds: selectedOptionIds.cast<int>(),
          incidentId: data['incidentId'] as String?,
        );
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
          // API call data
          snakeId: data['snakeId'] as int?,
          selectedOptionIds: (data['selectedOptionIds'] as List<dynamic>?)
              ?.cast<int>(),
          matchScore: data['matchScore'] as int?,
          matchPercentage: data['matchPercentage'] as double?,
          incidentId: data['incidentId'] as String?,
        );
      },
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
          isDirectEntry: data['isDirectEntry'] as bool? ?? false,
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
          isDirectEntry: data?['isDirectEntry'] as bool? ?? false,
          cameFromSymptomReport:
              data?['cameFromSymptomReport'] as bool? ?? false,
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
      path: '/member-incident-finished-detail',
      name: 'member_incident_finished_detail',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        final incidentId =
            data?['incidentId'] as String? ??
            state.uri.queryParameters['incidentId'] ??
            '';
        return MemberIncidentFinishedDetailScreen(incidentId: incidentId);
      },
    ),
    GoRoute(
      path: '/member-rescuer-arrived',
      name: 'member_rescuer_arrived',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return member_screens.RescuerArrivedScreen(
          incidentId: extra?['incidentId'] as String?,
        );
      },
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

    // === VIDEO CALL DEMO ROUTE ===
    GoRoute(
      path: '/demo-video-call',
      name: 'demo_video_call',
      builder: (context, state) => const DemoVideoCallScreen(),
    ),
  ],
);
