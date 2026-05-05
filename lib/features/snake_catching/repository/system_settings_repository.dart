import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/http_service.dart';
import '../../../core/providers/http_provider.dart';
import '../models/system_setting.dart';

final systemSettingsRepositoryProvider = Provider<SystemSettingsRepository>((ref) {
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
}
