import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/http_provider.dart';
import '../../../core/services/http_service.dart';
import '../models/rescuer_daily_stats.dart';

final rescuerAnalyticsRepositoryProvider =
    Provider<RescuerAnalyticsRepository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return RescuerAnalyticsRepository(httpService: httpService);
});

class RescuerAnalyticsRepository {
  final HttpService _httpService;

  RescuerAnalyticsRepository({required HttpService httpService})
      : _httpService = httpService;

  /// GET /api/analytics/rescuer/statistics?Period=day|week|month
  Future<RescuerDailyStats> getStatistics({String period = 'day'}) async {
    final response = await _httpService.get(
      '/api/analytics/rescuer/statistics',
      queryParameters: {'Period': period},
    );
    final data = (response.data['data'] as Map<String, dynamic>?) ??
        response.data as Map<String, dynamic>;
    return RescuerDailyStats.fromJson(data);
  }
}
