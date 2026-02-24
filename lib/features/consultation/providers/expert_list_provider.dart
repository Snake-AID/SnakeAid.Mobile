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
    // TEMPORARY: Comment out API calls, using mock data only for testing
    // loadExperts();
    // loadSpecialties();
    
    // TEMPORARY: Load mock data for testing
    _loadMockData();
  }

  /// TEMPORARY: Load mock data for testing (remove when API is ready)
  void _loadMockData() {
    final mockExperts = [
      ExpertModel(
        id: '1',
        userId: 'user1',
        fullName: 'Nguyễn Văn An',
        academicRank: 'TS',
        avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBhfLr-NKjrkkQecggKI7KMShAmkOy1WMGGPrgjDFvVFbHNhAOHIpbjRHPecS48_aXAyYuJXGPJgomQYSeJtjD06VkG08eFLWRRDMotH3tXwZ1JStH6NsLTXWvT0Voq-iUfi5EqcPCa0E0MroXlsKlq8jKqXMrbD_4uW28bCU5LonhfeUE3xxvKaUMeOLN-3RQZ02G7i0Z1GquLi-I5wleyh2MQP9XRrQbLgoqfoKt0EpV25U96Inas2ok3oBClKxvuGPwTfOoZYhqB',
        specialties: ['Rắn Độc Việt Nam'],
        specialty: 'Rắn Độc Việt Nam',
        isVerified: false,
        isOnline: true,
        rating: 4.9,
        reviewCount: 128,
        consultationFee: 150000,
        consultationDuration: 30,
        bio: 'Chuyên gia hàng đầu về rắn độc Việt Nam',
        yearsOfExperience: 15,
        createdAt: DateTime.now(),
      ),
      ExpertModel(
        id: '2',
        userId: 'user2',
        fullName: 'Trần Thị Bích',
        academicRank: 'ThS',
        avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA-eBOwQjyaW4LsRiMJ6aivYVzv1Bur0lH7XXQ9QpsiXYshGcTVthm5MlDsAjLuMkRAX9AjoG81il1E_aaDYDCtcgmnalHexrtltYdmP1X_PA9amxseAcQ10_XnDEPPYdPun-XRXXuNO9TBlDwKd2fIREmdngM1tmkXRbvGuikJ75UPVNu7iuS3rNrG6DfkZQfcnH_d8wVEAc_j_XIDkS5MO6Xf4Tu2WZIUUb-r-TtHwZcjtbRAcfzQ4crzgV-3tkOROY18t1k2EtT8',
        specialties: ['Rắn Cảnh'],
        specialty: 'Rắn Cảnh',
        isVerified: true,
        isOnline: true,
        rating: 4.8,
        reviewCount: 97,
        consultationFee: 120000,
        consultationDuration: 30,
        bio: 'Chuyên môn về rắn cảnh và chăm sóc',
        yearsOfExperience: 10,
        createdAt: DateTime.now(),
      ),
      ExpertModel(
        id: '3',
        userId: 'user3',
        fullName: 'Lê Minh Cường',
        academicRank: 'BS',
        avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA9YaWwdKUa8UYWHGK1fS5ltX3bnrM1qJETxlYE5kzWJmawSroi94awG84RzLkAcXSekETlWgVVA1y0f5xMu4asZlycw-SAe7tHCQcQZ_zSGGAAypCw7Py8uadPIpT6p28cnkE3qmWSd6XQjxF4vnPL3eX50BlmaNMR_ig5oqa4X35R2OfDuSuBFwm7mQ_jA3ym5hDzwIpX1N2Y03hGjvKvSmD4Hmpn9FybJThKHZj8WsUcs0F_XvmVIPwvmBIQYUkC_tV3KvHlDAC5',
        specialties: ['Rắn Nước'],
        specialty: 'Rắn Nước',
        isVerified: false,
        isOnline: false,
        rating: 4.7,
        reviewCount: 210,
        consultationFee: 100000,
        consultationDuration: 30,
        bio: 'Chuyên gia về rắn nước và môi trường sống',
        yearsOfExperience: 8,
        createdAt: DateTime.now(),
      ),
      ExpertModel(
        id: '4',
        userId: 'user4',
        fullName: 'Phạm Thu Hà',
        academicRank: 'PGS.TS',
        avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCFzUpuw3HzLq1SEboVsfKEEVD_SABfuRmaxVbenx50vToIM-ZsHlq7uoeYqaN7kx8-AIInCeq9x1t7Qu60oXw6avdkWg_Y5brm_Tg3Y3khojYc1oPUVYYLL0nO_n-RbSrYXOKrQxnztYGC8cW5ROZDKfaQXqDLpmgpFMH40_kpwTTbc9F0BO9gzAN5NKcBh8BFrVGLcLDd_kisrivExRDCR_I5i3FDvFC2Xo8hgGQaLo-QeNo9Zb6o6NJ7YVaEbvSuKSObQauAiWcs',
        specialties: ['Rắn Độc Việt Nam', 'Nghiên cứu rắn'],
        specialty: 'Rắn Độc Việt Nam',
        isVerified: true,
        isOnline: true,
        rating: 5.0,
        reviewCount: 75,
        consultationFee: 250000,
        consultationDuration: 30,
        bio: 'Phó Giáo sư, Tiến sĩ về nghiên cứu rắn',
        yearsOfExperience: 20,
        createdAt: DateTime.now(),
      ),
      ExpertModel(
        id: '5',
        userId: 'user5',
        fullName: 'Hoàng Văn Tuấn',
        academicRank: 'TS',
        avatarUrl: null,
        specialties: ['Xử lý vết cắn', 'Rắn Độc Việt Nam'],
        specialty: 'Xử lý vết cắn',
        isVerified: true,
        isOnline: false,
        rating: 4.6,
        reviewCount: 156,
        consultationFee: 180000,
        consultationDuration: 30,
        bio: 'Chuyên gia xử lý vết cắn rắn độc',
        yearsOfExperience: 12,
        createdAt: DateTime.now(),
      ),
    ];

    state = state.copyWith(
      experts: mockExperts,
      filteredExperts: _applyFiltersAndSort(mockExperts),
      totalCount: mockExperts.length,
      onlineCount: mockExperts.where((e) => e.isOnline).length,
      isLoading: false,
      specialties: [
        'Tất cả chuyên môn',
        'Rắn Độc Việt Nam',
        'Rắn Cảnh',
        'Rắn Nước',
        'Rắn Không Độc',
        'Xử lý vết cắn',
        'Cứu hộ rắn',
        'Nghiên cứu rắn',
      ],
    );
  }

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
