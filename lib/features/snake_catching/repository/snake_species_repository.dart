import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/http_service.dart';
import '../../../core/providers/http_provider.dart';
import '../models/snake_species.dart';

/// Provider for SnakeSpeciesRepository
final snakeSpeciesRepositoryProvider = Provider<SnakeSpeciesRepository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return SnakeSpeciesRepository(httpService);
});

class SnakeSpeciesRepository {
  final HttpService _httpService;

  SnakeSpeciesRepository(this._httpService);

  /// Fetch all snake species from API
  /// GET /api/snake-species
  Future<List<SnakeSpecies>> getSnakeSpecies() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🐍 Calling Snake Species API');
      debugPrint('🌐 Base URL: ${_httpService.dio.options.baseUrl}');
      debugPrint('📍 Endpoint: /api/snake-species');
      debugPrint('🔗 Full URL: ${_httpService.dio.options.baseUrl}/api/snake-species');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      final response = await _httpService.get('/api/snake-species');
      
      if (response.statusCode == 200 && response.data != null) {
        // Handle array response (legacy)
        if (response.data is List) {
          return (response.data as List)
              .map((json) => SnakeSpecies.fromJson(json))
              .toList();
        }
        // Handle wrapped response with data field (ApiResponse format with snake_case)
        else if (response.data is Map && response.data['data'] != null) {
          return (response.data['data'] as List)
              .map((json) => SnakeSpecies.fromJson(json))
              .toList();
        }
      }
      
      return [];
    } on DioException catch (e) {
      // If 404, the endpoint doesn't exist yet
      if (e.response?.statusCode == 404) {
        throw Exception('API endpoint chưa sẵn sàng. Vui lòng liên hệ admin để kích hoạt tính năng này.');
      }
      // If 401/403, authentication issue
      else if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('Bạn cần đăng nhập để xem danh sách loài rắn.');
      }
      // Other errors
      throw Exception('Không thể tải danh sách loài rắn. Vui lòng thử lại sau.');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Search snake species by name
  Future<List<SnakeSpecies>> searchSnakeSpecies(String query) async {
    try {
      final response = await _httpService.get(
        '/api/snake-species',
        queryParameters: {'search': query},
      );
      
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is List) {
          return (response.data as List)
              .map((json) => SnakeSpecies.fromJson(json))
              .toList();
        } else if (response.data is Map && response.data['data'] != null) {
          return (response.data['data'] as List)
              .map((json) => SnakeSpecies.fromJson(json))
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      // Return empty list on search error to avoid breaking UI
      return [];
    }
  }

  /// Get snake species detail by ID
  /// GET /api/snake-species/{id}
  Future<SnakeSpecies?> getSnakeSpeciesById(int id) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔍 Fetching Snake Species Detail');
      debugPrint('📍 Endpoint: /api/snake-species/$id');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      final response = await _httpService.get('/api/snake-species/$id');
      
      if (response.statusCode == 200 && response.data != null) {
        // Handle wrapped response with data field
        if (response.data is Map && response.data['data'] != null) {
          return SnakeSpecies.fromJson(response.data['data']);
        }
        // Handle direct response
        else if (response.data is Map) {
          return SnakeSpecies.fromJson(response.data);
        }
      }
      
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint('❌ Snake species not found: $id');
        return null;
      } else if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('Bạn cần đăng nhập để xem thông tin loài rắn.');
      }
      throw Exception('Không thể tải thông tin loài rắn. Vui lòng thử lại sau.');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }
}
