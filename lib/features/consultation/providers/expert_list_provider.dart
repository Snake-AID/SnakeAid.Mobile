import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/consultation_repository.dart';
import '../models/expert_model.dart';

/// State for expert list screen
class ExpertListState {
  final List<ExpertModel> experts;
  final List<ExpertModel> filteredExperts;
  final bool isLoading;
  final String? error;
  final String? selectedSpecialty;
  final bool onlineOnly;
  final String sortBy; // 'rating', 'fee', 'reviews'
  final int totalCount;
  final int onlineCount;
  final List<String> specialties;

  const ExpertListState({
    this.experts = const [],
    this.filteredExperts = const [],
    this.isLoading = false,
    this.error,
    this.selectedSpecialty,
    this.onlineOnly = false,
    this.sortBy = 'online', // Default: online first
    this.totalCount = 0,
    this.onlineCount = 0,
    this.specialties = const [],
  });

  ExpertListState copyWith({
    List<ExpertModel>? experts,
    List<ExpertModel>? filteredExperts,
    bool? isLoading,
    String? error,
    String? selectedSpecialty,
    bool? onlineOnly,
    String? sortBy,
    int? totalCount,
    int? onlineCount,
    List<String>? specialties,
    bool clearError = false,
    bool clearSpecialty = false,
  }) {
    return ExpertListState(
      experts: experts ?? this.experts,
      filteredExperts: filteredExperts ?? this.filteredExperts,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedSpecialty: clearSpecialty
          ? null
          : (selectedSpecialty ?? this.selectedSpecialty),
      onlineOnly: onlineOnly ?? this.onlineOnly,
      sortBy: sortBy ?? this.sortBy,
      totalCount: totalCount ?? this.totalCount,
      onlineCount: onlineCount ?? this.onlineCount,
      specialties: specialties ?? this.specialties,
    );
  }

  @override
  String toString() =>
      'ExpertListState(experts: ${experts.length}, filtered: ${filteredExperts.length}, loading: $isLoading)';
}

/// Provider for expert list state
final expertListProvider =
    StateNotifierProvider<ExpertListNotifier, ExpertListState>((ref) {
  final repository = ref.watch(consultationRepositoryProvider);
  return ExpertListNotifier(repository);
});

/// Notifier for managing expert list state
class ExpertListNotifier extends StateNotifier<ExpertListState> {
  final ConsultationRepository _repository;

  ExpertListNotifier(this._repository) : super(const ExpertListState()) {
    loadExperts();
    loadSpecialties();
  }

  /// Load list of experts

  /// Load list of experts
  Future<void> loadExperts() async {
    try {
      debugPrint('🔄 Loading experts...');

      state = state.copyWith(isLoading: true, clearError: true);

      final response = await _repository.getExperts(
        specialty: state.selectedSpecialty,
        onlineOnly: state.onlineOnly,
        sortBy: state.sortBy,
      );

      if (response.isSuccess && response.data != null) {
        final experts = response.data!.experts;
        
        debugPrint('✅ Loaded ${experts.length} experts');

        state = state.copyWith(
          experts: experts,
          filteredExperts: _applyFiltersAndSort(experts),
          totalCount: response.data!.totalCount,
          onlineCount: response.data!.onlineCount,
          isLoading: false,
        );
      } else {
        debugPrint('❌ Failed to load experts: ${response.message}');

        state = state.copyWith(
          isLoading: false,
          error: response.message,
        );
      }
    } catch (e) {
      debugPrint('❌ Error loading experts: $e');

      state = state.copyWith(
        isLoading: false,
        error: 'Không thể tải danh sách chuyên gia. Vui lòng thử lại.',
      );
    }
  }

  /// Load list of specialties
  Future<void> loadSpecialties() async {
    try {
      final specialties = await _repository.getSpecialties();
      state = state.copyWith(specialties: specialties);
    } catch (e) {
      debugPrint('❌ Error loading specialties: $e');
    }
  }

  /// Filter by specialty
  void filterBySpecialty(String? specialty) {
    debugPrint('🔍 Filtering by specialty: $specialty');

    state = state.copyWith(
      selectedSpecialty: specialty,
      clearSpecialty: specialty == null || specialty == 'Tất cả chuyên môn',
    );

    // Apply filters
    state = state.copyWith(
      filteredExperts: _applyFiltersAndSort(state.experts),
    );
  }

  /// Toggle online only filter
  void toggleOnlineOnly(bool onlineOnly) {
    debugPrint('🔍 Toggle online only: $onlineOnly');

    state = state.copyWith(onlineOnly: onlineOnly);

    // Apply filters
    state = state.copyWith(
      filteredExperts: _applyFiltersAndSort(state.experts),
    );
  }

  /// Change sort order
  void changeSortOrder(String sortBy) {
    debugPrint('🔄 Changing sort order: $sortBy');

    state = state.copyWith(sortBy: sortBy);

    // Apply filters
    state = state.copyWith(
      filteredExperts: _applyFiltersAndSort(state.experts),
    );
  }

  /// Clear all filters
  void clearFilters() {
    debugPrint('🧹 Clearing all filters');

    state = state.copyWith(
      clearSpecialty: true,
      onlineOnly: false,
      filteredExperts: _applyFiltersAndSort(state.experts),
    );
  }

  /// Apply filters and sorting to expert list
  List<ExpertModel> _applyFiltersAndSort(List<ExpertModel> experts) {
    var filtered = List<ExpertModel>.from(experts);

    // Filter by specialty
    if (state.selectedSpecialty != null &&
        state.selectedSpecialty!.isNotEmpty &&
        state.selectedSpecialty != 'Tất cả chuyên môn') {
      filtered = filtered.where((expert) {
        return expert.specialties.contains(state.selectedSpecialty) ||
            expert.specialty == state.selectedSpecialty;
      }).toList();
    }

    // Filter by online status
    if (state.onlineOnly) {
      filtered = filtered.where((expert) => expert.isOnline).toList();
    }

    // Sort
    switch (state.sortBy) {
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'fee':
        filtered.sort((a, b) => a.consultationFee.compareTo(b.consultationFee));
        break;
      case 'reviews':
        filtered.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
      case 'online':
      default:
        // Online first, then by rating
        filtered.sort((a, b) {
          if (a.isOnline && !b.isOnline) return -1;
          if (!a.isOnline && b.isOnline) return 1;
          return b.rating.compareTo(a.rating);
        });
    }

    return filtered;
  }

  /// Refresh expert list
  Future<void> refresh() async {
    await loadExperts();
  }
}
