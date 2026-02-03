import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/http_service.dart';
import '../../../core/providers/http_provider.dart';
import '../models/symptom_config.dart';
import '../models/symptom_tracking_response.dart';

final symptomRepositoryProvider = Provider<SymptomRepository>((ref) {
  return SymptomRepository(ref.read(httpServiceProvider));
});

class SymptomRepository {
  final HttpService _httpService;

  SymptomRepository(this._httpService);

  /// Get all symptom configurations
  Future<SymptomConfigResponse> getSymptomConfigs() async {
    try {
      final response = await _httpService.get('/api/symptom-configs');
      return SymptomConfigResponse.fromJson(response.data);
    } catch (e) {
      return SymptomConfigResponse(
        statusCode: 500,
        message: 'Failed to load symptom configs: $e',
        isSuccess: false,
        data: null,
        error: e.toString(),
      );
    }
  }

  /// Update symptoms tracking for an incident
  Future<SymptomTrackingResponse> updateSymptomsTracking({
    required String incidentId,
    required List<int> symptomIdList,
  }) async {
    try {
      final response = await _httpService.put(
        '/api/incidents/$incidentId/symptoms-tracking',
        data: {
          'symptomIdList': symptomIdList,
        },
      );
      return SymptomTrackingResponse.fromJson(response.data);
    } catch (e) {
      return SymptomTrackingResponse(
        statusCode: 500,
        message: 'Failed to update symptoms tracking: $e',
        isSuccess: false,
        data: null,
        error: e.toString(),
      );
    }
  }
}
