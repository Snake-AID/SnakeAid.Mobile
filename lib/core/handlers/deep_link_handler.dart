import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import '../config/base_url_config.dart';

/// Handles deep links for the SnakeAid app.
///
/// Supported deep links:
/// - snakeaid://payment - Payment callback handling
/// - snakeaid://config/baseurl?url=<URL> - Hot-patch BASE_URL (debug only)
///
/// Usage examples:
/// ```bash
/// # Android ADB
/// adb shell am start -W -a android.intent.action.VIEW \
///   -d "snakeaid://config/baseurl?url=http://192.168.1.100:8080" \
///   com.snakeaid.mobile
///
/// # iOS Simulator
/// xcrun simctl openurl booted "snakeaid://config/baseurl?url=http://192.168.1.100:8080"
/// ```
class DeepLinkHandler {
  final BaseUrlConfig baseUrlConfig;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri?>? _deepLinkSub;

  DeepLinkHandler(this.baseUrlConfig);

  /// Initialize deep link listener
  /// Call this in main.dart after app initialization
  Future<void> initialize() async {
    debugPrint('🔗 [DeepLinkHandler] Initializing deep link handler');

    // Listen to deep links while app is running
    _deepLinkSub = _appLinks.uriLinkStream.listen((uri) {
      if (uri != null) {
        debugPrint('🔗 [DeepLinkHandler] Received deep link: $uri');
        _handleDeepLink(uri);
      }
    });

    // Check for initial link (app was opened via deep link)
    // Note: getInitialAppLink() API may vary by version, using uriLinkStream instead
  }

  /// Dispose resources
  void dispose() {
    _deepLinkSub?.cancel();
    _deepLinkSub = null;
  }

  /// Handle incoming deep link
  void _handleDeepLink(Uri uri) {
    if (uri.scheme != 'snakeaid') {
      debugPrint('⚠️ [DeepLinkHandler] Unknown scheme: ${uri.scheme}');
      return;
    }

    switch (uri.host) {
      case 'config':
        _handleConfigLink(uri);
        break;
      case 'payment':
        // Payment handling is done in activity_detail_screen.dart
        debugPrint(
          '💰 [DeepLinkHandler] Payment link received: ${uri.queryParameters}',
        );
        break;
      default:
        debugPrint('⚠️ [DeepLinkHandler] Unknown host: ${uri.host}');
    }
  }

  /// Handle config deep links (debug only)
  void _handleConfigLink(Uri uri) {
    if (!kDebugMode) {
      debugPrint('⚠️ [DeepLinkHandler] Config links only work in debug mode');
      return;
    }

    switch (uri.path) {
      case '/baseurl':
        _handleBaseUrlConfig(uri);
        break;
      case '/reset':
        _handleResetConfig(uri);
        break;
      default:
        debugPrint('⚠️ [DeepLinkHandler] Unknown config path: ${uri.path}');
    }
  }

  /// Handle BASE_URL configuration deep link
  /// snakeaid://config/baseurl?url=<URL>
  void _handleBaseUrlConfig(Uri uri) {
    final newUrl = uri.queryParameters['url'];

    if (newUrl == null || newUrl.isEmpty) {
      debugPrint('⚠️ [DeepLinkHandler] Missing URL parameter');
      _showError('Thiếu tham số url');
      return;
    }

    // Optional: Validate with token for extra security
    final token = uri.queryParameters['token'];
    if (token != null && token != 'snakeaid-debug-token') {
      debugPrint('⚠️ [DeepLinkHandler] Invalid token');
      _showError('Token không hợp lệ');
      return;
    }

    // Override the BASE_URL
    baseUrlConfig.overrideBaseUrl(newUrl).then((success) {
      if (success) {
        _showSuccess('Đã cập nhật BASE_URL:\n$newUrl');
      } else {
        _showError('Không thể cập nhật URL');
      }
    });
  }

  /// Handle reset config deep link
  /// snakeaid://config/reset
  void _handleResetConfig(Uri uri) {
    if (!kDebugMode) return;

    baseUrlConfig.resetToDefault().then((_) {
      _showSuccess('Đã reset về BASE_URL mặc định');
    });
  }

  /// Show success message
  void _showSuccess(String message) {
    debugPrint('✅ [DeepLinkHandler] $message');
    // In a real implementation, you could show a toast/snackbar here
  }

  /// Show error message
  void _showError(String message) {
    debugPrint('❌ [DeepLinkHandler] $message');
  }
}

/// Riverpod provider for DeepLinkHandler
final deepLinkHandlerProvider = Provider<DeepLinkHandler>((ref) {
  final baseUrlConfig = ref.read(baseUrlConfigProvider);
  return DeepLinkHandler(baseUrlConfig);
});
