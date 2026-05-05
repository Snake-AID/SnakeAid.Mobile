import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/http_service.dart';
import '../../../core/providers/http_provider.dart';
import '../models/system_setting.dart';

final systemSettingsRepositoryProvider = Provider<SystemSettingsRepository>((
  ref,
) {
  final httpService = ref.watch(httpServiceProvider);
  return SystemSettingsRepository(httpService);
});

class SystemSettingsRepository {
  final HttpService _httpService;

  SystemSettingsRepository(this._httpService);

  Future<List<SystemSetting>> getSystemSettings() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('⚙️ Fetching System Settings');
      debugPrint('📍 Endpoint: /api/admin/system-settings');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _httpService.get('/api/admin/system-settings');

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is List) {
          return (response.data as List)
              .map((json) => SystemSetting.fromJson(json))
              .toList();
        } else if (response.data is Map && response.data['data'] != null) {
          return (response.data['data'] as List)
              .map((json) => SystemSetting.fromJson(json))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.message}');
      throw Exception('Không thể tải cài đặt hệ thống. Vui lòng thử lại.');
    } catch (e) {
      debugPrint('❌ Exception: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<SystemSetting?> getSystemSettingByKey(String key) async {
    try {
      final encodedKey = Uri.encodeComponent(key);
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('⚙️ Fetching System Setting By Key');
      debugPrint('📍 Endpoint: /api/admin/system-settings/$encodedKey');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _httpService.get(
        '/api/admin/system-settings/$encodedKey',
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map &&
            response.data['data'] is Map<String, dynamic>) {
          return SystemSetting.fromJson(
            response.data['data'] as Map<String, dynamic>,
          );
        }

        if (response.data is Map<String, dynamic>) {
          return SystemSetting.fromJson(response.data as Map<String, dynamic>);
        }

        if (response.data is List && (response.data as List).isNotEmpty) {
          return SystemSetting.fromJson(
            (response.data as List).first as Map<String, dynamic>,
          );
        }
      }

      return null;
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.message}');
      throw Exception('Không thể tải cài đặt hệ thống. Vui lòng thử lại.');
    } catch (e) {
      debugPrint('❌ Exception: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }
}
