import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/consultation_booking_response.dart';
import '../repository/consultation_repository.dart';

/// State for the consultation bookings list
class ConsultationBookingsState {
  final bool isLoading;
  final List<ConsultationBookingResponse> bookings;
  final String? error;

  const ConsultationBookingsState({
    this.isLoading = false,
    this.bookings = const [],
    this.error,
  });

  ConsultationBookingsState copyWith({
    bool? isLoading,
    List<ConsultationBookingResponse>? bookings,
    String? error,
  }) {
    return ConsultationBookingsState(
      isLoading: isLoading ?? this.isLoading,
      bookings: bookings ?? this.bookings,
      error: error,
    );
  }
}

/// Notifier for fetching the current member's consultation bookings
class ConsultationBookingsNotifier
    extends StateNotifier<ConsultationBookingsState> {
  final ConsultationRepository _repository;

  ConsultationBookingsNotifier(this._repository)
      : super(const ConsultationBookingsState()) {
    loadBookings();
  }

  Future<void> loadBookings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final bookings = await _repository.getMyBookings();
      state = state.copyWith(isLoading: false, bookings: bookings);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final consultationBookingsProvider = StateNotifierProvider<
    ConsultationBookingsNotifier, ConsultationBookingsState>((ref) {
  final repository = ref.watch(consultationRepositoryProvider);
  return ConsultationBookingsNotifier(repository);
});
