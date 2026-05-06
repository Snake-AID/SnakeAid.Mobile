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

  /// null = tất cả, true = chỉ online, false = chỉ offline
  final bool? isOnlineFilter;
  final String sortBy;
  final String searchQuery;
  final int totalCount;
  final int onlineCount;
  final List<String> specialties;

  const ExpertListState({
    this.experts = const [],
    this.filteredExperts = const [],
    this.isLoading = false,
    this.error,
    this.selectedSpecialty,
    this.isOnlineFilter, // null = default (cả hai)
    this.sortBy = 'online', // Default: sort online lên trước (client-side)
    this.searchQuery = '',
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
    bool? isOnlineFilter,
    String? sortBy,
    String? searchQuery,
    int? totalCount,
    int? onlineCount,
    List<String>? specialties,
    bool clearError = false,
    bool clearSpecialty = false,
    bool clearIsOnlineFilter = false,
  }) {
    return ExpertListState(
      experts: experts ?? this.experts,
      filteredExperts: filteredExperts ?? this.filteredExperts,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedSpecialty: clearSpecialty
          ? null
          : (selectedSpecialty ?? this.selectedSpecialty),
      isOnlineFilter: clearIsOnlineFilter
          ? null
          : (isOnlineFilter ?? this.isOnlineFilter),
      sortBy: sortBy ?? this.sortBy,
      searchQuery: searchQuery ?? this.searchQuery,
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
  }

  /// Load list of experts

  /// Load list of experts
  Future<void> loadExperts() async {
    try {
      debugPrint('🔄 Loading experts...');

      state = state.copyWith(isLoading: true, clearError: true);

      // Map UI sort key → API SortBy/SortOrder
      // 'online' chỉ sort client-side, KHÔNG gửi IsOnline lên API
      String? apiSortBy;
      String? apiSortOrder;
      switch (state.sortBy) {
        case 'online':
          // client-side only — API trả về tất cả, sau đó sort local
          break;
        case 'Rating':
          apiSortBy = 'Rating';
          apiSortOrder = 'desc';
          break;
        case 'ConsultationFee':
          apiSortBy = 'ConsultationFee';
          apiSortOrder = 'asc';
          break;
        case 'ReviewCount':
          apiSortBy = 'ReviewCount';
          apiSortOrder = 'desc';
          break;
      }

      final response = await _repository.getExperts(
        specialty: state.selectedSpecialty,
        isOnlineFilter:
            state.isOnlineFilter, // null=tất cả, true=online, false=offline
        sortBy: apiSortBy,
        sortOrder: apiSortOrder,
      );

      if (response.isSuccess && response.data != null) {
        final experts = response.data!.experts;

        debugPrint('✅ Loaded ${experts.length} experts');

        final mergedExperts = _applyRealtimePresenceToExperts(experts);

        state = state.copyWith(
          experts: mergedExperts,
          filteredExperts: _applyFiltersAndSort(mergedExperts),
          totalCount: response.data!.totalCount,
          onlineCount: mergedExperts.where((e) => e.isOnline).length,
          isLoading: false,
        );
      } else {
        debugPrint('❌ Failed to load experts: ${response.message}');

        state = state.copyWith(isLoading: false, error: response.message);
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
  Future<void> filterBySpecialty(String? specialty) async {
    debugPrint('🔍 Filtering by specialty: $specialty');

    state = state.copyWith(
      selectedSpecialty: specialty,
      clearSpecialty: specialty == null || specialty == 'Tất cả chuyên môn',
    );

    await loadExperts();
  }

  /// Set IsOnline filter: null = tất cả, true = chỉ online, false = chỉ offline
  Future<void> setIsOnlineFilter(bool? value) async {
    debugPrint('🔍 IsOnline filter: $value');
    state = state.copyWith(
      isOnlineFilter: value,
      clearIsOnlineFilter: value == null,
    );
    await loadExperts();
  }

  /// Change sort order
  Future<void> changeSortOrder(String sortBy) async {
    debugPrint('🔄 Changing sort order: $sortBy');

    state = state.copyWith(sortBy: sortBy);

    await loadExperts();
  }

  /// Apply local keyword search by expert name (realtime per typed character).
  /// Empty query => show full list (with current sort/filter state).
  void setSearchQuery(String query) {
    final normalizedQuery = query.trim();
    state = state.copyWith(searchQuery: normalizedQuery);

    // Recompute after state.searchQuery is updated so filtering uses latest text.
    state = state.copyWith(
      filteredExperts: _applyFiltersAndSort(state.experts),
    );
  }

  /// Clear all filters
  void clearFilters() {
    debugPrint('🧹 Clearing all filters');

    state = state.copyWith(
      clearSpecialty: true,
      clearIsOnlineFilter: true,
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

    // Filter by online status (client-side mirror của IsOnline API filter)
    if (state.isOnlineFilter == true) {
      filtered = filtered.where((expert) => expert.isOnline).toList();
    } else if (state.isOnlineFilter == false) {
      filtered = filtered.where((expert) => !expert.isOnline).toList();
    }

    // Local keyword search
    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      filtered = filtered.where((expert) {
        final name = expert.displayName.toLowerCase();
        return name.contains(q);
      }).toList();
    }

    // Sort (client-side fallback)
    switch (state.sortBy) {
      case 'Rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'ConsultationFee':
        filtered.sort((a, b) => a.consultationFee.compareTo(b.consultationFee));
        break;
      case 'ReviewCount':
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

  /// Reset filters/sort for the simplified member expert-list UI.
  Future<void> resetForMemberListUi() async {
    state = state.copyWith(
      clearSpecialty: true,
      clearIsOnlineFilter: true,
      sortBy: 'online',
      searchQuery: '',
      filteredExperts: _applyFiltersAndSort(state.experts),
    );
    await loadExperts();
  }

  /// Apply full online snapshot from SignalR (authoritative realtime source).
  void applyOnlineExpertsSnapshot(Set<String> onlineExpertIds) {
    final normalized = onlineExpertIds.map((e) => e.toLowerCase()).toSet();
    final updatedExperts = state.experts
        .map(
          (expert) => expert.copyWith(
            isOnline: _isExpertInOnlineSet(expert, normalized),
          ),
        )
        .toList();

    state = state.copyWith(
      experts: updatedExperts,
      filteredExperts: _applyFiltersAndSort(updatedExperts),
      onlineCount: updatedExperts.where((e) => e.isOnline).length,
    );
  }

  /// Apply a single presence delta event from SignalR.
  void applyExpertPresenceChanged({
    required String expertId,
    required bool isOnline,
  }) {
    final normalizedId = expertId.toLowerCase();
    final updatedExperts = state.experts.map((expert) {
      final match =
          expert.id.toLowerCase() == normalizedId ||
          expert.userId.toLowerCase() == normalizedId;
      return match ? expert.copyWith(isOnline: isOnline) : expert;
    }).toList();

    state = state.copyWith(
      experts: updatedExperts,
      filteredExperts: _applyFiltersAndSort(updatedExperts),
      onlineCount: updatedExperts.where((e) => e.isOnline).length,
    );
  }

  List<ExpertModel> _applyRealtimePresenceToExperts(List<ExpertModel> experts) {
    if (state.experts.isEmpty) {
      return experts;
    }

    // Keep realtime online flags already known in-memory when reloading list.
    final knownOnlineById = <String, bool>{
      for (final e in state.experts) e.id.toLowerCase(): e.isOnline,
      for (final e in state.experts) e.userId.toLowerCase(): e.isOnline,
    };

    return experts
        .map(
          (expert) => expert.copyWith(
            isOnline:
                knownOnlineById[expert.id.toLowerCase()] ??
                knownOnlineById[expert.userId.toLowerCase()] ??
                expert.isOnline,
          ),
        )
        .toList();
  }

  bool _isExpertInOnlineSet(ExpertModel expert, Set<String> onlineIds) {
    return onlineIds.contains(expert.id.toLowerCase()) ||
        onlineIds.contains(expert.userId.toLowerCase());
  }
}
