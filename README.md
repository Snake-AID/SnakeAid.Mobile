# SnakeAid.Mobile

````dart
lib/
├── core/                          # Core utilities 
│   ├── config/
│   │   ├── app_config.dart
│   │   ├── route_config.dart
│   │   └── theme_config.dart
│   ├── constants/
│   │   ├── api_endpoints.dart
│   │   ├── enums.dart            # Từ DB enums
│   │   └── app_constants.dart
│   ├── services/                 # Shared services
│   │   ├── api_service.dart      # Dio client
│   │   ├── auth_service.dart     # Authentication
│   │   ├── location_service.dart # GPS tracking
│   │   ├── notification_service.dart # Service notification
│   │   └── storage_service.dart  # Local storage
│   ├── utils/
│   │   ├── extensions/
│   │   ├── validators/
│   │   └── helpers/
│   └── widgets/                  # Shared UI components
│       ├── common/
│       ├── forms/
│       └── media/
│
│
├── features/                      # Feature-based modules
│   ├── auth/                     # Authentication
│   │   ├── models/
│   │   │   ├── account.dart      
│   │   │   └── user_profile.dart
│   │   ├── providers/
│   │   │   ├── auth_provider.dart
│   │   │   └── profile_provider.dart
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── profile_screen.dart
│   │   ├── widgets/
│   │   │   ├── login_form.dart
│   │   │   └── profile_card.dart
│   │   └── repository/
│   │       └── auth_repository.dart  # Single repository per feature
│   │
│   ├── emergency/                # SOS & Emergency features
│   │   ├── models/
│   │   │   ├── snakebite_incident.dart
│   │   │   ├── rescue_request.dart
│   │   │   └── rescue_mission.dart
│   │   ├── providers/
│   │   │   ├── emergency_provider.dart
│   │   │   └── tracking_provider.dart
│   │   ├── screens/
│   │   │   ├── sos_form_screen.dart
│   │   │   ├── emergency_tracking_screen.dart
│   │   │   └── first_aid_guide_screen.dart
│   │   ├── widgets/
│   │   │   ├── symptom_selector.dart
│   │   │   ├── location_picker.dart
│   │   │   └── emergency_button.dart
│   │   └── repository/
│   │       └── emergency_repository.dart
│   │
│   ├── snake_catching/           # Snake removal requests
│   │   ├── models/
│   │   │   ├── catching_request.dart
│   │   │   └── catching_report.dart
│   │   ├── providers/
│   │   │   ├── catching_provider.dart
│   │   │   └── queue_provider.dart
│   │   ├── screens/
│   │   │   ├── catching_request_screen.dart
│   │   │   ├── queue_screen.dart
│   │   │   └── report_screen.dart
│   │   ├── widgets/
│   │   │   ├── species_selector.dart
│   │   │   └── quantity_input.dart
│   │   └── repository/
│   │       └── catching_repository.dart
│   │
│   ├── consultation/             # Expert consultation
│   │   ├── models/
│   │   │   ├── consultation_session.dart
│   │   │   ├── chat_message.dart
│   │   │   └── expert_profile.dart
│   │   ├── providers/
│   │   │   ├── consultation_provider.dart
│   │   │   ├── webrtc_provider.dart
│   │   │   └── chat_provider.dart
│   │   ├── screens/
│   │   │   ├── expert_list_screen.dart
│   │   │   ├── consultation_room_screen.dart
│   │   │   └── chat_screen.dart
│   │   ├── widgets/
│   │   │   ├── video_call_widget.dart
│   │   │   ├── chat_widget.dart
│   │   │   └── expert_card.dart
│   │   └── repository/
│   │       └── consultation_repository.dart
│   │
│   ├── snake_ai/                 # Snake recognition & library
│   │   ├── models/
│   │   │   ├── snake_species.dart
│   │   │   ├── ai_recognition_result.dart
│   │   │   └── first_aid_guideline.dart
│   │   ├── providers/
│   │   │   ├── snake_recognition_provider.dart
│   │   │   ├── snake_library_provider.dart
│   │   │   └── ai_provider.dart
│   │   ├── screens/
│   │   │   ├── camera_recognition_screen.dart
│   │   │   ├── snake_library_screen.dart
│   │   │   ├── species_detail_screen.dart
│   │   │   └── manual_filter_screen.dart
│   │   ├── widgets/
│   │   │   ├── camera_widget.dart
│   │   │   ├── species_card.dart
│   │   │   └── filter_widget.dart
│   │   └── repository/
│   │       └── snake_repository.dart
│   │
│   ├── payment/                  # Payment & wallet
│   │   ├── models/
│   │   │   ├── payment_transaction.dart
│   │   │   ├── wallet_account.dart
│   │   │   └── payment_method.dart
│   │   ├── providers/
│   │   │   ├── payment_provider.dart
│   │   │   └── wallet_provider.dart
│   │   ├── screens/
│   │   │   ├── payment_screen.dart
│   │   │   ├── wallet_screen.dart
│   │   │   └── payment_history_screen.dart
│   │   ├── widgets/
│   │   │   ├── payment_form.dart
│   │   │   └── payment_method_card.dart
│   │   └── repository/
│   │       └── payment_repository.dart
│   │
│   ├── rescuer/                  # Rescuer-specific features
│   │   ├── models/
│   │   │   ├── rescuer_profile.dart
│   │   │   └── mission.dart
│   │   ├── providers/
│   │   │   ├── rescuer_provider.dart
│   │   │   ├── mission_provider.dart
│   │   │   └── availability_provider.dart
│   │   ├── screens/
│   │   │   ├── rescuer_dashboard_screen.dart
│   │   │   ├── mission_queue_screen.dart
│   │   │   ├── active_mission_screen.dart
│   │   │   └── training_screen.dart
│   │   ├── widgets/
│   │   │   ├── mission_card.dart
│   │   │   ├── availability_toggle.dart
│   │   │   └── location_tracker.dart
│   │   └── repository/
│   │       └── rescuer_repository.dart
│   │
│   ├── expert/                   # Expert-specific features
│   │   ├── models/
│   │   │   ├── expert_profile.dart
│   │   │   ├── expert_schedule.dart
│   │   │   └── certificate.dart
│   │   ├── providers/
│   │   │   ├── expert_provider.dart
│   │   │   ├── schedule_provider.dart
│   │   │   └── consultation_queue_provider.dart
│   │   ├── screens/
│   │   │   ├── expert_dashboard_screen.dart
│   │   │   ├── consultation_requests_screen.dart
│   │   │   ├── schedule_management_screen.dart
│   │   │   └── knowledge_management_screen.dart
│   │   ├── widgets/
│   │   │   ├── consultation_request_card.dart
│   │   │   ├── schedule_calendar.dart
│   │   │   └── certificate_uploader.dart
│   │   └── repository/
│   │       └── expert_repository.dart
│   │
│   └── shared/                   # Shared between roles
│       ├── models/
│       │   ├── location.dart
│       │   ├── media.dart
│       │   └── notification.dart
│       ├── providers/
│       │   ├── location_provider.dart
│       │   ├── media_provider.dart
│       │   └── notification_provider.dart
│       └── widgets/
│           ├── map_widget.dart
│           ├── media_picker.dart
│           └── notification_badge.dart
│
├── app/                          # App-level configuration
│   ├── router.dart              # Go Router configuration
│   ├── providers.dart           # Global providers
│   └── theme.dart              # App theme
│
└── main.dart
````
