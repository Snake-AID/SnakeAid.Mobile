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
  final bool isLoading;
  final String? error;

  SnakeLocationState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  SnakeLocationState copyWith({
    SnakesByLocationResponse? data,
    bool? isLoading,
    String? error,
  }) {
    return SnakeLocationState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// StateNotifier for managing location-based snake filtering
class SnakeLocationNotifier extends StateNotifier<SnakeLocationState> {
  final SnakeSpeciesRepository _repository;

  SnakeLocationNotifier(this._repository) : super(SnakeLocationState());

  /// Fetch snakes by GPS location
  Future<void> fetchSnakesByLocation({
    required double latitude,
    required double longitude,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.getSnakesByLocation(
        latitude: latitude,
        longitude: longitude,
      );

      state = state.copyWith(
        data: result,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      // Extract clean error message
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
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
