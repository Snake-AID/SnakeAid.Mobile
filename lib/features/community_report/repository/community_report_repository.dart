import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snakeaid_mobile/core/providers/http_provider.dart';
import 'package:snakeaid_mobile/core/services/http_service.dart';
import '../models/community_report.dart';

class CommunityReportRepository {
  final HttpService _http;

  CommunityReportRepository(this._http);

  // ── Parsers ────────────────────────────────────────────────────────────────

  List<CommunityReport> _parseReportList(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().map(CommunityReport.fromJson).toList();
    }
    if (data is Map<String, dynamic> && data['data'] is List) {
      return (data['data'] as List).whereType<Map<String, dynamic>>().map(CommunityReport.fromJson).toList();
    }
    return [];
  }

  CommunityReport _parseSingleReport(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
        return CommunityReport.fromJson(data['data'] as Map<String, dynamic>);
      }
      return CommunityReport.fromJson(data);
    }
    throw const FormatException('Unexpected response format');
  }

  List<SnakeSpecies> _parseSpeciesList(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().map(SnakeSpecies.fromJson).toList();
    }
    if (data is Map<String, dynamic> && data['data'] is List) {
      return (data['data'] as List).whereType<Map<String, dynamic>>().map(SnakeSpecies.fromJson).toList();
    }
    return [];
  }

  // ── Community Reports ──────────────────────────────────────────────────────

  Future<List<CommunityReport>> getReports() async {
    try {
      final res = await _http.get('/api/community-reports');
      return _parseReportList(res.data);
    } catch (e) {
      throw Exception('Không thể tải danh sách cảnh báo: $e');
    }
  }

  Future<CommunityReport> getReportById(String id) async {
    try {
      final res = await _http.get('/api/community-reports/$id');
      return _parseSingleReport(res.data);
    } catch (e) {
      throw Exception('Không thể tải chi tiết báo cáo: $e');
    }
  }

  Future<CommunityReport> createReport({
    required double latitude,
    required double longitude,
    required String notes,
    int? snakeSpeciesId,
  }) async {
    try {
      final body = <String, dynamic>{
        'longitude': longitude,
        'latitude': latitude,
        'notes': notes,
        if (snakeSpeciesId != null) 'snakeSpeciesId': snakeSpeciesId,
      };
      final res = await _http.post('/api/community-reports', data: body);
      return _parseSingleReport(res.data);
    } catch (e) {
      throw Exception('Không thể tạo báo cáo: $e');
    }
  }

  Future<void> updateReport(
    String id, {
    String? notes,
    int? snakeSpeciesId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final body = <String, dynamic>{
        if (notes != null) 'notes': notes,
        if (snakeSpeciesId != null) 'snakeSpeciesId': snakeSpeciesId,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };
      await _http.put('/api/community-reports/$id', data: body);
    } catch (e) {
      throw Exception('Không thể cập nhật báo cáo: $e');
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      await _http.delete('/api/community-reports/$id');
    } catch (e) {
      throw Exception('Không thể xóa báo cáo: $e');
    }
  }

  // ── Snake Species ──────────────────────────────────────────────────────────

  Future<List<SnakeSpecies>> getSnakeSpecies() async {
    try {
      final res = await _http.get('/api/snake-species');
      return _parseSpeciesList(res.data);
    } catch (e) {
      throw Exception('Không thể tải danh sách loài rắn: $e');
    }
  }
}

final communityReportRepositoryProvider =
    Provider<CommunityReportRepository>((ref) {
  return CommunityReportRepository(ref.watch(httpServiceProvider));
});
