import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/http_provider.dart';
import '../../../core/services/http_service.dart';
import '../models/snake_species_model.dart';
import '../models/snake_first_aid_model.dart';

/// Provider for SnakeSpeciesRepository
final snakeSpeciesRepositoryProvider = Provider<SnakeSpeciesRepository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return SnakeSpeciesRepository(httpService: httpService);
});

/// Repository for snake species API calls
class SnakeSpeciesRepository {
  final HttpService httpService;

  SnakeSpeciesRepository({required this.httpService});

  /// GET /api/snake-species — fetch all species
  Future<List<SnakeSpeciesModel>> getAllSpecies() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🐍 Fetching all snake species');
      final response = await httpService.get('/api/snake-species');
      final body = response.data as Map<String, dynamic>;
      final data = body['data'];
      if (data is List) {
        return data
            .map((e) => SnakeSpeciesModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      // Single object (shouldn't happen for list endpoint)
      if (data is Map<String, dynamic>) {
        return [SnakeSpeciesModel.fromJson(data)];
      }
      return [];
    } on DioException catch (e) {
      debugPrint('❌ getAllSpecies error: ${e.message}');
      rethrow;
    }
  }

  /// GET /api/snake-species/{id} — fetch detail by id
  Future<SnakeSpeciesModel> getSpeciesById(int id) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🐍 Fetching snake species #$id');
      final response = await httpService.get('/api/snake-species/$id');
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return SnakeSpeciesModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint('❌ getSpeciesById error: ${e.message}');
      rethrow;
    }
  }

  /// GET /api/first-aid-guidelines/recommendation/species/{snakeSpeciesId}
  Future<SnakeFirstAidModel> getFirstAidBySpecies(int snakeSpeciesId) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(
        '🩹 Fetching first aid guideline for species #$snakeSpeciesId',
      );
      final response = await httpService.get(
        '/api/first-aid-guidelines/recommendation/species/$snakeSpeciesId',
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return SnakeFirstAidModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint('❌ getFirstAidBySpecies error: ${e.message}');
      rethrow;
    }
  }
}
