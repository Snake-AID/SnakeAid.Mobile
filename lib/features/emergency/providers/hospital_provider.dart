import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/hospital_response.dart';
import '../models/hospital_transfer_pricing_response.dart';
import '../repository/treatment_facility_repository.dart';

/// Hospital State
class HospitalState {
  final List<HospitalResponse> hospitals;
  final Position? currentPosition;
  final bool isLoading;
  final bool isLoadingLocation;
  final String? error;
  final HospitalTransferPricingResponse? selectedHospitalPricing;
  final bool isSelectingHospital;

  HospitalState({
    this.hospitals = const [],
    this.currentPosition,
    this.isLoading = false,
    this.isLoadingLocation = false,
    this.error,
    this.selectedHospitalPricing,
    this.isSelectingHospital = false,
  });

  HospitalState copyWith({
    List<HospitalResponse>? hospitals,
    Position? currentPosition,
    bool? isLoading,
    bool? isLoadingLocation,
    String? error,
    HospitalTransferPricingResponse? selectedHospitalPricing,
    bool? isSelectingHospital,
    bool clearError = false,
    bool clearHospitals = false,
    bool clearSelectedHospital = false,
  }) {
    return HospitalState(
      hospitals: clearHospitals ? [] : (hospitals ?? this.hospitals),
      currentPosition: currentPosition ?? this.currentPosition,
      isLoading: isLoading ?? this.isLoading,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      error: clearError ? null : (error ?? this.error),
      selectedHospitalPricing: clearSelectedHospital
          ? null
          : (selectedHospitalPricing ?? this.selectedHospitalPricing),
      isSelectingHospital: isSelectingHospital ?? this.isSelectingHospital,
    );
  }

  bool get hasHospitals => hospitals.isNotEmpty;
  bool get hasLocation => currentPosition != null;
  bool get hasSelectedHospital => selectedHospitalPricing != null;
}

/// Hospital Notifier
class HospitalNotifier extends StateNotifier<HospitalState> {
  final TreatmentFacilityRepository repository;

  HospitalNotifier({required this.repository}) : super(HospitalState());

  /// Get current location
  Future<void> getCurrentLocation() async {
    try {
      debugPrint('📍 Getting current location...');
      state = state.copyWith(isLoadingLocation: true, clearError: true);

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLoadingLocation: false,
          error: 'Vui lòng bật dịch vụ định vị',
        );
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            isLoadingLocation: false,
            error: 'Quyền truy cập vị trí bị từ chối',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoadingLocation: false,
          error: 'Vui lòng cấp quyền vị trí trong cài đặt',
        );
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      debugPrint('✅ Location: ${position.latitude}, ${position.longitude}');
      state = state.copyWith(
        currentPosition: position,
        isLoadingLocation: false,
      );

      // Auto-load nearest hospital after getting location
      await loadNearestHospital();
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
      state = state.copyWith(
        isLoadingLocation: false,
        error: 'Không thể lấy vị trí: ${e.toString()}',
      );
    }
  }

  /// Load nearest hospital based on current location
  Future<void> loadNearestHospital() async {
    if (state.currentPosition == null) {
      debugPrint('⚠️ No current position available');
      state = state.copyWith(error: 'Vui lòng cho phép truy cập vị trí');
      return;
    }

    try {
      debugPrint('🏥 Loading nearest hospitals...');
      state = state.copyWith(isLoading: true, clearError: true);

      final response = await repository.getNearestHospital(
        lat: state.currentPosition!.latitude,
        lng: state.currentPosition!.longitude,
      );

      if (response.isSuccess &&
          response.data != null &&
          response.data!.isNotEmpty) {
        debugPrint('✅ ${response.data!.length} hospital(s) loaded');
        debugPrint('   Nearest: ${response.data!.first.name}');
        debugPrint('   Distance: ${response.data!.first.distanceKm} km');
        state = state.copyWith(hospitals: response.data!, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message.isNotEmpty
              ? response.message
              : 'Không tìm thấy bệnh viện gần đây',
        );
      }
    } catch (e) {
      debugPrint('❌ Error loading hospitals: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Refresh hospital data
  Future<void> refresh() async {
    await getCurrentLocation();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Set selected hospital pricing after successful API call
  void setSelectedHospitalPricing(HospitalTransferPricingResponse pricing) {
    debugPrint('✅ Hospital selected: ${pricing.hospitalName}');
    debugPrint('   Total price: ${pricing.totalPrice}');
    state = state.copyWith(selectedHospitalPricing: pricing);
  }

  /// Clear selected hospital
  void clearSelectedHospital() {
    state = state.copyWith(clearSelectedHospital: true);
  }
}

/// Provider for Hospital
final hospitalProvider = StateNotifierProvider<HospitalNotifier, HospitalState>(
  (ref) {
    final repository = ref.watch(treatmentFacilityRepositoryProvider);
    return HospitalNotifier(repository: repository);
  },
);
