import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/http_service.dart';
import '../../../core/providers/http_provider.dart';
import '../models/catching_environment.dart';

/// Provider for CatchingEnvironmentRepository
final catchingEnvironmentRepositoryProvider =
    Provider<CatchingEnvironmentRepository>((ref) {
      final httpService = ref.watch(httpServiceProvider);
      return CatchingEnvironmentRepository(httpService);
    });

class CatchingEnvironmentRepository {
  final HttpService _httpService;

  CatchingEnvironmentRepository(this._httpService);

  /// Fetch all catching environments
  /// GET /api/catchingEnvironments
  Future<List<CatchingEnvironment>> getCatchingEnvironments() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🌿 Fetching Catching Environments');
      debugPrint('📍 Endpoint: /api/catchingEnvironments');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await _httpService.get('/api/catchingEnvironments');

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is List) {
          return (response.data as List)
              .map((json) => CatchingEnvironment.fromJson(json))
              .toList();
        } else if (response.data is Map && response.data['data'] != null) {
          return (response.data['data'] as List)
              .map((json) => CatchingEnvironment.fromJson(json))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.message}');
      debugPrint('📥 Response: ${e.response?.data}');
      throw Exception(
        'Không thể tải danh sách môi trường bắt rắn. Vui lòng thử lại.',
      );
    } catch (e) {
      debugPrint('❌ Exception: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }
}
