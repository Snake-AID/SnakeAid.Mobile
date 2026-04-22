import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/http_provider.dart';
import '../../../core/services/emergency_consultation_signalr_service.dart';
import '../repository/expert_profile_repository.dart';

class ExpertAvailabilityState {
  final bool isOnline;
  final bool isLoading;
  final bool isConnected;
  final bool isInitialized;
  final String? error;

  const ExpertAvailabilityState({
    this.isOnline = false,
    this.isLoading = false,
    this.isConnected = false,
    this.isInitialized = false,
    this.error,
  });

  ExpertAvailabilityState copyWith({
    bool? isOnline,
    bool? isLoading,
    bool? isConnected,
    bool? isInitialized,
    String? error,
    bool clearError = false,
  }) {
    return ExpertAvailabilityState(
      isOnline: isOnline ?? this.isOnline,
      isLoading: isLoading ?? this.isLoading,
      isConnected: isConnected ?? this.isConnected,
      isInitialized: isInitialized ?? this.isInitialized,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final expertAvailabilitySignalRServiceProvider =
    Provider<EmergencyConsultationSignalRService>((ref) {
      final baseUrl = ref.watch(baseUrlProvider);
      return EmergencyConsultationSignalRService(baseUrl: baseUrl);
    });

class ExpertAvailabilityNotifier extends StateNotifier<ExpertAvailabilityState> {
  final ExpertProfileRepository _profileRepository;
  final EmergencyConsultationSignalRService _signalRService;

  ExpertAvailabilityNotifier({
    required ExpertProfileRepository profileRepository,
    required EmergencyConsultationSignalRService signalRService,
  }) : _profileRepository = profileRepository,
       _signalRService = signalRService,
       super(const ExpertAvailabilityState()) {
    initialize();
  }

  Future<void> initialize() async {
    if (state.isLoading || state.isInitialized) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profile = await _profileRepository.getMyProfile();
      final shouldBeOnline = profile.isOnline;

      if (shouldBeOnline) {
        await _signalRService.connectAsExpert();
      } else {
        await _signalRService.disconnect();
      }

      state = state.copyWith(
        isOnline: shouldBeOnline,
        isConnected: shouldBeOnline && _signalRService.isConnected,
        isLoading: false,
        isInitialized: true,
        clearError: true,
      );
    } catch (e) {
      debugPrint('Expert availability init failed: $e');
      state = state.copyWith(
        isOnline: false,
        isConnected: false,
        isLoading: false,
        isInitialized: true,
        error: 'Không thể đồng bộ trạng thái online',
      );
    }
  }

  Future<void> setOnline(bool shouldBeOnline) async {
    if (!state.isInitialized) {
      await initialize();
    }
    if (state.isLoading || state.isOnline == shouldBeOnline) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      if (shouldBeOnline) {
        await _signalRService.connectAsExpert();
      } else {
        await _signalRService.leaveAsExpert();
      }

      state = state.copyWith(
        isOnline: shouldBeOnline,
        isConnected: shouldBeOnline && _signalRService.isConnected,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      debugPrint('Expert availability toggle failed: $e');
      state = state.copyWith(
        isLoading: false,
        isConnected: _signalRService.isConnected,
        error: shouldBeOnline
            ? 'Không thể chuyển sang online'
            : 'Không thể chuyển sang offline',
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isInitialized: false);
    await initialize();
  }

  @override
  void dispose() {
    _signalRService.dispose();
    super.dispose();
  }
}

final expertAvailabilityProvider =
    StateNotifierProvider<ExpertAvailabilityNotifier, ExpertAvailabilityState>((
      ref,
    ) {
      final repository = ref.watch(expertProfileRepositoryProvider);
      final signalRService = ref.watch(expertAvailabilitySignalRServiceProvider);

      return ExpertAvailabilityNotifier(
        profileRepository: repository,
        signalRService: signalRService,
      );
    });
