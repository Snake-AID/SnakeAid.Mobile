# BASE_URL Hot-Patching Guide

## Overview

The SnakeAid Mobile app supports runtime BASE_URL configuration through deep links and a debug settings screen. This feature allows developers to switch between different backend environments (development, staging, production) without rebuilding the app.

## Architecture

### Core Components

1. **BaseUrlConfig** (`lib/core/config/base_url_config.dart`)
   - StateNotifier that manages the current BASE_URL
   - Persists URL overrides to SharedPreferences
   - Provides default URL from `.env` file

2. **DeepLinkHandler** (`lib/core/handlers/deep_link_handler.dart`)
   - Listens for `snakeaid://` scheme deep links
   - Handles BASE_URL configuration commands
   - Only works in debug mode (`kDebugMode`)

3. **Debug Settings Screen** (`lib/features/debug/debug_settings_screen.dart`)
   - UI for viewing and changing BASE_URL
   - Accessible only in debug mode
   - Provides preset environment options

4. **HTTP Provider** (`lib/core/providers/http_provider.dart`)
   - Uses dynamic `baseUrlProvider` instead of static dotenv value
   - Enables runtime URL switching without app restart

## Deep Link Configuration

### Android

The `snakeaid://` scheme is configured in `android/app/src/main/AndroidManifest.xml`:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="snakeaid"/>
</intent-filter>
```

### iOS

The `snakeaid` URL scheme is configured in `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>snakeaid</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>snakeaid</string>
        </array>
    </dict>
</array>
```

## Usage

### Method 1: Deep Link (ADB for Android)

```bash
# Set BASE_URL to a custom URL
adb shell am start -W -a android.intent.action.VIEW \
  -d "snakeaid://config/baseurl?url=http://192.168.1.100:8080" \
  com.snakeaid.mobile

# Reset BASE_URL to default
adb shell am start -W -a android.intent.action.VIEW \
  -d "snakeaid://config/reset" \
  com.snakeaid.mobile
```

### Method 2: Deep Link (iOS Simulator)

```bash
# Set BASE_URL to a custom URL
xcrun simctl openurl booted "snakeaid://config/baseurl?url=http://192.168.1.100:8080"

# Reset BASE_URL to default
xcrun simctl openurl booted "snakeaid://config/reset"
```

### Method 3: Debug Settings Screen

1. Open the app in debug mode
2. Navigate to the Debug Settings screen (accessible from profile/settings)
3. View current BASE_URL
4. Enter a custom URL or select a preset environment
5. Tap "Save" to apply changes
6. Tap "Reset to Default" to restore the original BASE_URL

### Method 4: Direct Provider Access (Development)

```dart
// In a debug console or test code
final config = ref.read(baseUrlConfigProvider);
await config.overrideBaseUrl('http://192.168.1.100:8080');

// Reset to default
await config.resetToDefault();
```

## Supported Deep Link Commands

| Command | Description | Example |
|---------|-------------|---------|
| `snakeaid://config/baseurl?url=<URL>` | Set BASE_URL to a custom value | `snakeaid://config/baseurl?url=http://localhost:8080` |
| `snakeaid://config/reset` | Reset BASE_URL to default from `.env` | `snakeaid://config/reset` |
| `snakeaid://payment` | Payment callback handling | `snakeaid://payment?status=success` |

## Security Considerations

### Debug Mode Only

⚠️ **BASE_URL hot-patching ONLY works in debug mode** (`kDebugMode = true`).

In production builds:
- Deep link config commands are ignored
- Debug Settings Screen is not accessible
- BASE_URL is fixed to the value from `.env` file

### Token Validation (Optional)

For additional security, you can add a token parameter to deep links:

```bash
adb shell am start -W -a android.intent.action.VIEW \
  -d "snakeaid://config/baseurl?url=http://example.com&token=snakeaid-debug-token" \
  com.snakeaid.mobile
```

The token is validated in `DeepLinkHandler._handleBaseUrlConfig()`.

### Best Practices

1. **Never expose production URLs in debug builds**
   - Use separate backend environments for development/testing

2. **Validate URL format**
   - The `BaseUrlConfig` class validates URLs before applying them

3. **Clear URL overrides before release**
   - Run `snakeaid://config/reset` before building for production

4. **Monitor BASE_URL changes**
   - Check logs for `[DeepLinkHandler]` messages to track URL changes

## Testing

### Manual Testing

1. **Test deep link handling:**
   ```bash
   # Android
   adb shell am start -W -a android.intent.action.VIEW \
     -d "snakeaid://config/baseurl?url=http://test.example.com" \
     com.snakeaid.mobile
   
   # Check logs
   adb logcat | grep DeepLinkHandler
   ```

2. **Test Debug Settings Screen:**
   - Open app in debug mode
   - Navigate to Debug Settings
   - Change BASE_URL
   - Verify API calls use the new URL

3. **Test reset functionality:**
   ```bash
   adb shell am start -W -a android.intent.action.VIEW \
     -d "snakeaid://config/reset" \
     com.snakeaid.mobile
   ```

### Automated Testing

```dart
// Example widget test for Debug Settings Screen
testWidgets('Debug Settings Screen updates BASE_URL', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: const DebugSettingsScreen(),
    ),
  );
  
  // Enter new URL
  await tester.enterText(find.byType(TextField), 'http://test.example.com');
  await tester.tap(find.text('Save'));
  await tester.pump();
  
  // Verify URL was updated
  final config = tester.readProvider(baseUrlConfigProvider);
  expect(config.state, equals('http://test.example.com'));
});
```

## Troubleshooting

### Deep Link Not Working

1. **Check app is in debug mode:**
   - Deep links only work in debug builds

2. **Verify package name (Android):**
   - Use correct package name in ADB command: `com.snakeaid.mobile`

3. **Check intent filter:**
   - Ensure `android/app/src/main/AndroidManifest.xml` has the `snakeaid://` scheme

4. **Check logs:**
   ```bash
   adb logcat | grep -E "DeepLinkHandler|BaseUrlConfig"
   ```

### BASE_URL Not Persisting

1. **Check SharedPreferences:**
   ```dart
   final prefs = await SharedPreferences.getInstance();
   print(prefs.getString('base_url_override'));
   ```

2. **Clear app data and retry:**
   ```bash
   adb shell pm clear com.snakeaid.mobile
   ```

### HTTP Calls Still Using Old URL

1. **Verify provider is watched:**
   - Services should use `ref.watch(baseUrlProvider)` not static values

2. **Check service initialization:**
   - Services may need to be recreated after URL change

3. **Restart app:**
   - Some services may require app restart to pick up new URL

## Related Files

- `lib/core/config/base_url_config.dart` - Base URL configuration and state management
- `lib/core/handlers/deep_link_handler.dart` - Deep link handling logic
- `lib/core/providers/http_provider.dart` - HTTP service provider using dynamic BASE_URL
- `lib/features/debug/debug_settings_screen.dart` - UI for BASE_URL configuration
- `android/app/src/main/AndroidManifest.xml` - Android deep link configuration
- `ios/Runner/Info.plist` - iOS deep link configuration

## Future Enhancements

- [ ] Add URL history for quick switching between recent URLs
- [ ] Implement QR code scanner for BASE_URL configuration
- [ ] Add environment presets (Dev, Staging, Production) with one-tap switching
- [ ] Add confirmation dialog before applying URL changes
- [ ] Log BASE_URL changes to analytics (debug only)
