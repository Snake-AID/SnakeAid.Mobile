import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/my_consultation_response.dart';
import '../models/consultation_review_response.dart';
import '../repository/consultation_repository.dart';

class MyConsultationsState {
  final bool isLoading;
  final List<MyConsultationResponse> ongoing;
  final List<MyConsultationResponse> completed;
  final Map<String, ConsultationReviewResponse?> reviewsByConsultationId;
  final String? error;

  const MyConsultationsState({
    this.isLoading = false,
    this.ongoing = const [],
    this.completed = const [],
    this.reviewsByConsultationId = const {},
    this.error,
  });

  MyConsultationsState copyWith({
    bool? isLoading,
    List<MyConsultationResponse>? ongoing,
    List<MyConsultationResponse>? completed,
    Map<String, ConsultationReviewResponse?>? reviewsByConsultationId,
    String? error,
  }) {
    return MyConsultationsState(
      isLoading: isLoading ?? this.isLoading,
      ongoing: ongoing ?? this.ongoing,
      completed: completed ?? this.completed,
      reviewsByConsultationId:
          reviewsByConsultationId ?? this.reviewsByConsultationId,
      error: error,
    );
  }
}

class MyConsultationsNotifier extends StateNotifier<MyConsultationsState> {
  final ConsultationRepository _repository;

  MyConsultationsNotifier(this._repository)
    : super(const MyConsultationsState()) {
    loadConsultations();
  }

  Future<void> loadConsultations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _repository.getMyConsultations(
          status: 'Ongoing',
          pageNumber: 1,
          pageSize: 10,
        ),
        _repository.getMyConsultations(
          status: 'Scheduled',
          pageNumber: 1,
          pageSize: 10,
        ),
        _repository.getMyConsultations(
          status: 'Completed',
          pageNumber: 1,
          pageSize: 10,
        ),
      ]);

      final ongoingAndScheduled = [...results[0], ...results[1]];
      final ongoingById = <String, MyConsultationResponse>{
        for (final c in ongoingAndScheduled) c.consultationId: c,
      };
      final completed = results[2];
      final reviewPairs = await Future.wait(
        completed.map((c) async {
          final consultationId = c.consultationId;
          if (consultationId.isEmpty) {
            return MapEntry<String, ConsultationReviewResponse?>(
              consultationId,
              null,
            );
          }
          try {
            final review = await _repository.getConsultationReview(
              consultationId,
            );
            return MapEntry<String, ConsultationReviewResponse?>(
              consultationId,
              review,
            );
          } catch (_) {
            return MapEntry<String, ConsultationReviewResponse?>(
              consultationId,
              null,
            );
          }
        }),
      );

      state = state.copyWith(
        isLoading: false,
        ongoing: ongoingById.values.toList(),
        completed: completed,
        reviewsByConsultationId:
            Map<String, ConsultationReviewResponse?>.fromEntries(reviewPairs),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final myConsultationsProvider =
    StateNotifierProvider<MyConsultationsNotifier, MyConsultationsState>((ref) {
      final repository = ref.watch(consultationRepositoryProvider);
      return MyConsultationsNotifier(repository);
    });
