import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/snake_species_model.dart';
import '../models/snake_first_aid_model.dart';
import '../repository/snake_species_repository.dart';

// ---------------------------------------------------------------------------
// Snake Species List
// ---------------------------------------------------------------------------

class SnakeSpeciesListState {
  final List<SnakeSpeciesModel> species;
  final List<SnakeSpeciesModel> filtered;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const SnakeSpeciesListState({
    this.species = const [],
    this.filtered = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  SnakeSpeciesListState copyWith({
    List<SnakeSpeciesModel>? species,
    List<SnakeSpeciesModel>? filtered,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? searchQuery,
  }) {
    return SnakeSpeciesListState(
      species: species ?? this.species,
      filtered: filtered ?? this.filtered,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final snakeSpeciesListProvider =
    StateNotifierProvider<SnakeSpeciesListNotifier, SnakeSpeciesListState>(
        (ref) {
  final repository = ref.watch(snakeSpeciesRepositoryProvider);
  return SnakeSpeciesListNotifier(repository);
});

class SnakeSpeciesListNotifier
    extends StateNotifier<SnakeSpeciesListState> {
  final SnakeSpeciesRepository _repository;

  SnakeSpeciesListNotifier(this._repository)
      : super(const SnakeSpeciesListState()) {
    loadSpecies();
  }

  Future<void> loadSpecies() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _repository.getAllSpecies();
      state = state.copyWith(
        isLoading: false,
        species: list,
        filtered: list,
        searchQuery: '',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Không thể tải danh sách loài rắn.',
      );
    }
  }

  void search(String query) {
    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? state.species
        : state.species.where((s) {
            return s.commonName.toLowerCase().contains(q) ||
                s.scientificName.toLowerCase().contains(q) ||
                s.alternativeNames
                    .any((n) => n.toLowerCase().contains(q));
          }).toList();
    state = state.copyWith(searchQuery: query, filtered: filtered);
  }
}

// ---------------------------------------------------------------------------
// Snake Species Detail
// ---------------------------------------------------------------------------

class SnakeSpeciesDetailState {
  final SnakeSpeciesModel? species;
  final bool isLoading;
  final String? error;

  const SnakeSpeciesDetailState({
    this.species,
    this.isLoading = false,
    this.error,
  });

  SnakeSpeciesDetailState copyWith({
    SnakeSpeciesModel? species,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return SnakeSpeciesDetailState(
      species: species ?? this.species,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final snakeSpeciesDetailProvider = StateNotifierProvider.family<
    SnakeSpeciesDetailNotifier, SnakeSpeciesDetailState, int>((ref, id) {
  final repository = ref.watch(snakeSpeciesRepositoryProvider);
  return SnakeSpeciesDetailNotifier(repository, id);
});

class SnakeSpeciesDetailNotifier
    extends StateNotifier<SnakeSpeciesDetailState> {
  final SnakeSpeciesRepository _repository;

  SnakeSpeciesDetailNotifier(this._repository, int id)
      : super(const SnakeSpeciesDetailState()) {
    load(id);
  }

  Future<void> load(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final species = await _repository.getSpeciesById(id);
      state = state.copyWith(isLoading: false, species: species);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Không thể tải thông tin loài rắn.',
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Snake First Aid
// ---------------------------------------------------------------------------

class SnakeFirstAidState {
  final SnakeFirstAidModel? guideline;
  final bool isLoading;
  final String? error;

  const SnakeFirstAidState({
    this.guideline,
    this.isLoading = false,
    this.error,
  });

  SnakeFirstAidState copyWith({
    SnakeFirstAidModel? guideline,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return SnakeFirstAidState(
      guideline: guideline ?? this.guideline,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final snakeFirstAidProvider = StateNotifierProvider.family<
    SnakeFirstAidNotifier, SnakeFirstAidState, int>((ref, snakeSpeciesId) {
  final repository = ref.watch(snakeSpeciesRepositoryProvider);
  return SnakeFirstAidNotifier(repository, snakeSpeciesId);
});

class SnakeFirstAidNotifier extends StateNotifier<SnakeFirstAidState> {
  final SnakeSpeciesRepository _repository;

  SnakeFirstAidNotifier(this._repository, int snakeSpeciesId)
      : super(const SnakeFirstAidState()) {
    load(snakeSpeciesId);
  }

  Future<void> load(int snakeSpeciesId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final guideline =
          await _repository.getFirstAidBySpecies(snakeSpeciesId);
      state = state.copyWith(isLoading: false, guideline: guideline);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Không thể tải hướng dẫn sơ cứu.',
      );
    }
  }
}
