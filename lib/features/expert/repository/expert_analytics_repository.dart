import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/http_provider.dart';
import '../../../core/services/http_service.dart';
import '../models/expert_daily_stats.dart';

final expertAnalyticsRepositoryProvider =
    Provider<ExpertAnalyticsRepository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return ExpertAnalyticsRepository(httpService: httpService);
});

class ExpertAnalyticsRepository {
  final HttpService _httpService;

  ExpertAnalyticsRepository({required HttpService httpService})
      : _httpService = httpService;

  /// GET /api/analytics/expert/statistics?Period=day|month|year
  Future<ExpertStats> getStatistics({String period = 'day'}) async {
    final response = await _httpService.get(
      '/api/analytics/expert/statistics',
      queryParameters: {'Period': period},
    );
    final data = (response.data['data'] as Map<String, dynamic>?) ??
        response.data as Map<String, dynamic>;
    return ExpertStats.fromJson(data);
  }
}
