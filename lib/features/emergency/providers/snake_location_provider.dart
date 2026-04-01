import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/http_provider.dart';
import '../repository/snake_species_repository.dart';
import '../models/snakes_by_location_response.dart';

/// Provider for SnakeSpeciesRepository
final snakeSpeciesRepositoryProvider = Provider<SnakeSpeciesRepository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return SnakeSpeciesRepository(httpService);
});

/// State for location-based snake filtering
class SnakeLocationState {
  final SnakesByLocationResponse? data;
  final String? placeName;
  final double? latitude;
  final double? longitude;
  final bool isLoading;
  final String? error;

  SnakeLocationState({
    this.data,
    this.placeName,
    this.latitude,
    this.longitude,
    this.isLoading = false,
    this.error,
  });

  SnakeLocationState copyWith({
    SnakesByLocationResponse? data,
    String? placeName,
    double? latitude,
    double? longitude,
    bool? isLoading,
    String? error,
  }) {
    return SnakeLocationState(
      data: data ?? this.data,
      placeName: placeName ?? this.placeName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// StateNotifier for managing location-based snake filtering
class SnakeLocationNotifier extends StateNotifier<SnakeLocationState> {
  final SnakeSpeciesRepository _repository;

  // In-memory cache keyed by rounded location string to avoid repeated requests
  static final Map<String, SnakeLocationState> _locationCache = {};

  SnakeLocationNotifier(this._repository) : super(SnakeLocationState());

  String _cacheKey(double latitude, double longitude) {
    // Round to 4 decimals to reduce unnecessary extra cache keys
    return '${latitude.toStringAsFixed(4)},${longitude.toStringAsFixed(4)}';
  }

  Future<String?> _getPlaceNameFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'addressdetails': '1',
          'accept-language': 'vi',
        },
        options: Options(
          headers: {'User-Agent': 'SnakeAid Mobile App'},
          connectTimeout: const Duration(milliseconds: 7000),
          sendTimeout: const Duration(milliseconds: 7000),
          receiveTimeout: const Duration(milliseconds: 7000),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final preferredKeys = [
            'state',
            'province',
            'county',
            'region',
            'city',
            'town',
            'village',
          ];
          for (final key in preferredKeys) {
            final maybe = address[key] as String?;
            if (maybe != null && maybe.isNotEmpty) {
              return maybe;
            }
          }
        }

        final displayName = data['display_name'] as String?;
        if (displayName != null && displayName.isNotEmpty) {
          final parts = displayName.split(',');
          if (parts.isNotEmpty) return parts.first.trim();
          return displayName;
        }
      }
    } catch (e) {
      // Keep silent on reverse-geocode errors, falling back to region name.
    }

    return null;
  }

  /// Fetch snakes by GPS location
  Future<void> fetchSnakesByLocation({
    required double latitude,
    required double longitude,
  }) async {
    final cacheKey = _cacheKey(latitude, longitude);
    if (_locationCache.containsKey(cacheKey)) {
      state = _locationCache[cacheKey]!;
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.getSnakesByLocation(
        latitude: latitude,
        longitude: longitude,
      );

      final placeName = await _getPlaceNameFromCoordinates(latitude, longitude);

      final newState = SnakeLocationState(
        data: result,
        placeName: placeName,
        latitude: latitude,
        longitude: longitude,
        isLoading: false,
        error: null,
      );

      state = newState;
      _locationCache[cacheKey] = newState;
    } catch (e) {
      // Extract clean error message
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  /// Clear state
  void clear() {
    state = SnakeLocationState();
  }
}

/// Provider for SnakeLocationNotifier
final snakeLocationProvider =
    StateNotifierProvider<SnakeLocationNotifier, SnakeLocationState>((ref) {
      final repository = ref.watch(snakeSpeciesRepositoryProvider);
      return SnakeLocationNotifier(repository);
    });
