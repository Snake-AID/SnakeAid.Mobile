import '../../../core/services/http_service.dart';
import '../models/snakes_by_location_response.dart';

/// Repository for snake species operations
/// Handles location-based filtering and AI detection
class SnakeSpeciesRepository {
  final HttpService _httpService;

  SnakeSpeciesRepository(this._httpService);

  /// Get snakes by GPS location
  /// Returns list of snake species common in the geographic region
  /// 
  /// Endpoint: GET /api/snake-species/by-location?lat={lat}&lng={lng}
  Future<SnakesByLocationResponse> getSnakesByLocation({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _httpService.get(
      '/api/snake-species/by-location',
      queryParameters: {
        'lat': latitude,
        'lng': longitude,
      },
    );

    // Backend returns ApiResponse<SnakesByLocationResponse> with snake_case fields
    // Check for is_success (snake_case) not isSuccess (camelCase)
    if (response.data['is_success'] == true && response.data['data'] != null) {
      return SnakesByLocationResponse.fromJson(response.data['data']);
    } else {
      throw Exception(
        response.data['message'] ?? 'Failed to get snakes by location',
      );
    }
  }

  /// Search snake species by text query
  /// Used for expert consultation to quickly find snake info
  /// 
  /// Endpoint: GET /api/snake-species/search?q={query}
  Future<List<dynamic>> searchSnakes(String query) async {
    final response = await _httpService.get(
      '/api/snake-species/search',
      queryParameters: {'q': query},
    );

    // Check for is_success (snake_case) not isSuccess (camelCase)
    if (response.data['is_success'] == true && response.data['data'] != null) {
      return response.data['data'] as List<dynamic>;
    } else {
      throw Exception(
        response.data['message'] ?? 'Failed to search snakes',
      );
    }
  }

  /// Get snake species details by ID
  /// Returns detailed information including antivenoms, venoms, symptoms
  /// 
  /// Endpoint: GET /api/snake-species/{id}
  Future<Map<String, dynamic>> getSnakeSpeciesById(int id) async {
    final response = await _httpService.get('/api/snake-species/$id');

    // Check for is_success (snake_case) not isSuccess (camelCase)
    if (response.data['is_success'] == true && response.data['data'] != null) {
      return response.data['data'] as Map<String, dynamic>;
    } else {
      throw Exception(
        response.data['message'] ?? 'Failed to get snake species details',
      );
    }
  }
}
