import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Configuration manager for BASE_URL with support for runtime override.
///
/// This allows hot-patching the BASE_URL without recompiling the app,
/// useful for testing different backend environments.
///
/// Features:
/// - Load default URL from .env file
/// - Override via deep link (snakeaid://config/baseurl?url=...)
/// - Override via debug settings screen
/// - Persist override across app restarts
/// - Only enabled in debug mode for security
class BaseUrlConfig extends StateNotifier<String> {
  final SharedPreferences prefs;
  static const String _overrideKey = 'base_url_override';
  static const String _enabledKey = 'base_url_override_enabled';

  /// The default URL from .env file
  final String defaultUrl;

  BaseUrlConfig(this.prefs, String? envUrl)
    : defaultUrl = envUrl ?? 'https://dev.snakeaid.tech',
      super(envUrl ?? 'https://dev.snakeaid.tech') {
    _loadOverride();
  }

  /// Current base URL (either overridden or default)
  String get currentUrl => state;

  /// Check if URL is currently overridden
  bool get isOverridden => prefs.getBool(_enabledKey) ?? false;

  /// Check if override is allowed (only in debug mode)
  bool get canOverride => kDebugMode;

  /// Load overridden URL from SharedPreferences
  void _loadOverride() {
    if (canOverride && isOverridden) {
      final overridden = prefs.getString(_overrideKey);
      if (overridden != null && overridden.isNotEmpty) {
        debugPrint('🔧 [BaseUrlConfig] Using overridden URL: $overridden');
        state = overridden;
      }
    } else {
      debugPrint('🔧 [BaseUrlConfig] Using default URL: $defaultUrl');
    }
  }

  /// Override the BASE_URL and persist to SharedPreferences
  ///
  /// Returns true if successful, false if override is not allowed
  Future<bool> overrideBaseUrl(String newUrl) async {
    if (!canOverride) {
      debugPrint('⚠️ [BaseUrlConfig] Override not allowed in release mode');
      return false;
    }

    if (!_isValidUrl(newUrl)) {
      debugPrint('⚠️ [BaseUrlConfig] Invalid URL format: $newUrl');
      return false;
    }

    await prefs.setString(_overrideKey, newUrl);
    await prefs.setBool(_enabledKey, true);
    state = newUrl;

    debugPrint('✅ [BaseUrlConfig] URL overridden to: $newUrl');
    return true;
  }

  /// Reset to default URL from .env file
  Future<void> resetToDefault() async {
    await prefs.remove(_overrideKey);
    await prefs.setBool(_enabledKey, false);
    state = defaultUrl;

    debugPrint('✅ [BaseUrlConfig] Reset to default URL: $defaultUrl');
  }

  /// Clear override but keep current URL (useful for temporary override)
  Future<void> clearOverride() async {
    await prefs.remove(_overrideKey);
    await prefs.setBool(_enabledKey, false);

    debugPrint('✅ [BaseUrlConfig] Override cleared');
  }

  /// Validate URL format
  bool _isValidUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  /// Get info about current configuration for debugging
  Map<String, dynamic> getConfigInfo() {
    return {
      'currentUrl': state,
      'defaultUrl': defaultUrl,
      'isOverridden': isOverridden,
      'canOverride': canOverride,
      'isDebugMode': kDebugMode,
    };
  }
}

/// Provider for creating BaseUrlConfig instance
/// Call this in main.dart after initializing SharedPreferences
BaseUrlConfig createBaseUrlConfig(SharedPreferences prefs) {
  final envUrl = dotenv.env['BASE_URL'];
  return BaseUrlConfig(prefs, envUrl);
}

/// Riverpod provider for BaseUrlConfig
/// This provider should be overridden in main.dart with the actual instance
final baseUrlConfigProvider = Provider<BaseUrlConfig>((ref) {
  throw StateError('baseUrlConfigProvider must be overridden in main.dart');
});

/// Convenient provider to watch the current URL value
final currentBaseUrlProvider = Provider<String>((ref) {
  return ref.watch(baseUrlConfigProvider).currentUrl;
});
