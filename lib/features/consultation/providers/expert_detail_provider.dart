import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expert_detail_model.dart';
import '../repository/consultation_repository.dart';

/// State for expert detail
class ExpertDetailState {
  final ExpertDetailModel? expert;
  final bool isLoading;
  final String? error;

  const ExpertDetailState({
    this.expert,
    this.isLoading = false,
    this.error,
  });

  ExpertDetailState copyWith({
    ExpertDetailModel? expert,
    bool? isLoading,
    String? error,
  }) {
    return ExpertDetailState(
      expert: expert ?? this.expert,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Provider for expert detail
/// Usage: ref.watch(expertDetailProvider(expertId))
final expertDetailProvider = StateNotifierProvider.family<ExpertDetailNotifier, ExpertDetailState, String>(
  (ref, expertId) {
    final repository = ref.watch(consultationRepositoryProvider);
    return ExpertDetailNotifier(repository: repository, expertId: expertId);
  },
);

/// Notifier for expert detail management
class ExpertDetailNotifier extends StateNotifier<ExpertDetailState> {
  final ConsultationRepository repository;
  final String expertId;

  ExpertDetailNotifier({
    required this.repository,
    required this.expertId,
  }) : super(const ExpertDetailState()) {
    // Load expert detail immediately
    loadExpertDetail();
  }

  /// Load expert detail from API
  Future<void> loadExpertDetail() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final expert = await repository.getExpertDetail(expertId);
      state = state.copyWith(
        expert: expert,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('❌ Error loading expert detail: $e');
      state = state.copyWith(
        expert: null,
        isLoading: false,
        error: 'Không thể tải thông tin chuyên gia. Vui lòng thử lại.',
      );
    }
  }

  /// Refresh expert detail
  Future<void> refresh() async {
    await loadExpertDetail();
  }
}
