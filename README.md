# SnakeAid.Mobile

## CodeMagic CI/CD

This repository includes a minimal [codemagic.yaml](codemagic.yaml) for MVP builds.

Current CI direction:

- Android: build a debug APK that can be downloaded from CodeMagic artifacts and installed directly on an Android device
- iOS: build an unsigned IPA with `--no-codesign` for sideloading or TrollStore-style workflows

### Required CodeMagic Variables

Only these environment variables are currently generated into `.env` during CI:

- `BASE_URL`
- `API_TIMEOUT` (optional, defaults to `30000`)

### Android Firebase Requirement

The Android workflow also requires Firebase configuration because the project applies the Google Services Gradle plugin.

CodeMagic must provide:

- `GOOGLE_SERVICES_JSON_BASE64`

This secret should contain the Base64-encoded contents of:

- `android/app/google-services.json`

On Windows PowerShell, you can generate it with:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android/app/google-services.json"))
```

Then add the resulting string as a secure environment variable in CodeMagic.

Without this value, Android builds will fail at `:app:processDebugGoogleServices` because `google-services.json` is not committed to the repository.

### Android Output

The Android workflow builds:

```bash
flutter build apk --debug
```

Artifact output on CodeMagic:

- `build/app/outputs/flutter-apk/*.apk`

How to install:

1. Open the CodeMagic build
2. Go to `Artifacts`
3. Download the generated `.apk`
4. Copy it to an Android device
5. Enable installation from unknown sources if needed
6. Open the APK and install

### iOS Output

The iOS workflow currently runs:

```bash
flutter build ios --release --no-codesign
```

Artifact output on CodeMagic:

- `build/ios/iphoneos/*.app`
- `build/ios/unsigned_ipa/*.ipa`

Important:

- The generated `.ipa` is unsigned
- The generated `.app` is still useful as a raw build artifact
- This workflow does not use Apple signing
- Installation still depends on the sideload method you choose later

### iOS Strategy Without Paid Apple Developer Account

The current goal is to avoid the Apple Developer Program cost while still keeping an iOS path for MVP testing.

Practical options:

- `TrollStore`: only works on supported iOS versions and devices
- `AltStore`, `SideStore`, or `Sideloadly`: usually require a free Apple ID and periodic refresh
- `Xcode Personal Team`: works for personal testing, but still depends on an Apple account and is not a clean CI distribution path

Practical conclusion:

- Android is the primary installable artifact in CI today
- iOS CI now produces an unsigned IPA artifact
- If real iPhone installation is needed, use that IPA with the sideload path you choose, such as `TrollStore`, `AltStore`, `SideStore`, or `Sideloadly`

### After Commit / Push

To keep builds running smoothly on CodeMagic:

1. Push the branch that CodeMagic is configured to build
2. Ensure `BASE_URL` exists in CodeMagic environment variables
3. Trigger the `android_debug` workflow for an installable Android artifact
4. Trigger the `ios_release` workflow for an unsigned iOS IPA artifact

If Android fails again with missing `.env`, the first thing to check is whether the CodeMagic environment variables are present for that workflow.

> ## 🚨 Local Development Connection Issue
>
> If you are running the backend locally (`http://<your-ip>:8080`) but the Mobile App (Real device) throws **Connection Timeout** or **SocketException**, your Windows Firewall is likely blocking incoming connections to port 8080.
>
> **Quick Fix:** Run PowerShell as Administrator and execute this command:
>
> ```powershell
> New-NetFirewallRule -DisplayName "Allow Port 8080" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
> ```
>
> Expected output: `Enabled: True`, `Action: Allow`. Restart your app after applying this rule.

```dart
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
```
