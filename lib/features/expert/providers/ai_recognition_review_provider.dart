import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_recognition_review_models.dart';
import '../repository/ai_recognition_review_repository.dart';
import '../../snake_species/repository/snake_species_repository.dart';
import '../../snake_species/models/snake_species_model.dart';

// ---------------------------------------------------------------------------
// Review Queue Provider
// ---------------------------------------------------------------------------

class AiReviewQueueState {
  final List<ExpertReviewItemResponse> items;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;
  final int page;

  const AiReviewQueueState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
    this.page = 1,
  });

  AiReviewQueueState copyWith({
    List<ExpertReviewItemResponse>? items,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
    bool? hasMore,
    int? page,
  }) {
    return AiReviewQueueState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }
}

class AiReviewQueueNotifier extends StateNotifier<AiReviewQueueState> {
  final AiRecognitionReviewRepository _repo;
  static const int _pageSize = 20;

  AiReviewQueueNotifier(this._repo) : super(const AiReviewQueueState()) {
    load();
  }

  Future<void> load({bool refresh = false}) async {
    if (state.isLoading || state.isLoadingMore) return;
    if (refresh) {
      state = const AiReviewQueueState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, clearError: true);
    }
    try {
      final results = await _repo.getReviewQueue(page: 1, pageSize: _pageSize);
      state = state.copyWith(
        isLoading: false,
        items: results,
        hasMore: results.length >= _pageSize,
        page: 2,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final results =
          await _repo.getReviewQueue(page: state.page, pageSize: _pageSize);
      state = state.copyWith(
        isLoadingMore: false,
        items: [...state.items, ...results],
        hasMore: results.length >= _pageSize,
        page: state.page + 1,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Remove an item after the expert has acted on it.
  void removeItem(String recognitionResultId) {
    state = state.copyWith(
      items: state.items
          .where((i) => i.aiResult.id != recognitionResultId)
          .toList(),
    );
  }
}

final aiReviewQueueProvider =
    StateNotifierProvider<AiReviewQueueNotifier, AiReviewQueueState>((ref) {
  return AiReviewQueueNotifier(
      ref.watch(aiRecognitionReviewRepositoryProvider));
});

// ---------------------------------------------------------------------------
// Review History Provider
// ---------------------------------------------------------------------------

class AiReviewHistoryState {
  final List<ExpertReviewedRecognitionItemResponse> items;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;
  final int page;

  const AiReviewHistoryState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
    this.page = 1,
  });

  AiReviewHistoryState copyWith({
    List<ExpertReviewedRecognitionItemResponse>? items,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
    bool? hasMore,
    int? page,
  }) {
    return AiReviewHistoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }
}

class AiReviewHistoryNotifier extends StateNotifier<AiReviewHistoryState> {
  final AiRecognitionReviewRepository _repo;
  static const int _pageSize = 20;

  AiReviewHistoryNotifier(this._repo) : super(const AiReviewHistoryState());

  Future<void> load({bool refresh = false}) async {
    if (state.isLoading || state.isLoadingMore) return;
    if (refresh) {
      state = const AiReviewHistoryState(isLoading: true);
    } else {
      if (state.items.isNotEmpty) return; // already loaded
      state = state.copyWith(isLoading: true, clearError: true);
    }
    try {
      final results =
          await _repo.getReviewHistory(page: 1, pageSize: _pageSize);
      state = state.copyWith(
        isLoading: false,
        items: results,
        hasMore: results.length >= _pageSize,
        page: 2,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final results =
          await _repo.getReviewHistory(page: state.page, pageSize: _pageSize);
      state = state.copyWith(
        isLoadingMore: false,
        items: [...state.items, ...results],
        hasMore: results.length >= _pageSize,
        page: state.page + 1,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final aiReviewHistoryProvider =
    StateNotifierProvider<AiReviewHistoryNotifier, AiReviewHistoryState>((ref) {
  return AiReviewHistoryNotifier(
      ref.watch(aiRecognitionReviewRepositoryProvider));
});

// ---------------------------------------------------------------------------
// Detail Provider (autoDispose.family — per recognitionResultId)
// ---------------------------------------------------------------------------

final aiReviewDetailProvider = FutureProvider.autoDispose
    .family<AIRecognitionReviewDetailResponse, String>((ref, id) {
  return ref.watch(aiRecognitionReviewRepositoryProvider).getReviewDetail(id);
});

// ---------------------------------------------------------------------------
// All species (for verify picker) — cached for session
// ---------------------------------------------------------------------------

final allSpeciesForPickerProvider =
    FutureProvider<List<SnakeSpeciesModel>>((ref) {
  return ref.watch(snakeSpeciesRepositoryProvider).getAllSpecies();
});
