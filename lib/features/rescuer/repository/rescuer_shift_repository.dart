import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/http_service.dart';
import '../../../../core/providers/http_provider.dart';

final rescuerShiftRepositoryProvider = Provider<RescuerShiftRepository>((ref) {
  return RescuerShiftRepository(ref.watch(httpServiceProvider));
});

class ShiftData {
  final String id;
  final String name;
  final String startTime;
  final String endTime;

  ShiftData({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
  });

  factory ShiftData.fromJson(Map<String, dynamic> json) {
    return ShiftData(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
    );
  }
}

class ShiftAssignment {
  final String id;
  final String rescuerId;
  final String shiftId;
  final String shiftStartLocal;
  final String shiftEndLocal;
  final String status;
  final ShiftData? shift;

  ShiftAssignment({
    required this.id,
    required this.rescuerId,
    required this.shiftId,
    required this.shiftStartLocal,
    required this.shiftEndLocal,
    required this.status,
    this.shift,
  });

  factory ShiftAssignment.fromJson(Map<String, dynamic> json) {
    final rawShift = json['shift'];
    return ShiftAssignment(
      id: json['id'] as String? ?? '',
      rescuerId: json['rescuerId'] as String? ?? '',
      shiftId: json['shiftId'] as String? ?? '',
      shiftStartLocal: json['shiftStartLocal'] as String? ?? '',
      shiftEndLocal: json['shiftEndLocal'] as String? ?? '',
      status: json['status'] as String? ?? '',
      shift: rawShift is Map<String, dynamic>
          ? ShiftData.fromJson(rawShift)
          : (rawShift is Map ? ShiftData.fromJson(Map<String, dynamic>.from(rawShift)) : null),
    );
  }
}

class RescuerShiftRepository {
  final HttpService _httpService;

  RescuerShiftRepository(this._httpService);

  Future<List<ShiftAssignment>> getAssignments({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _httpService.get(
        '/api/shifts/assignments',
        queryParameters: {
          'startDate': startDate,
          'endDate': endDate,
        },
      );
      final raw = response.data;
      if (raw is! Map) return <ShiftAssignment>[];

      final data = raw['data'];
      if (data is! List) return <ShiftAssignment>[];

      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .map(ShiftAssignment.fromJson)
          .toList();
    } catch (e) {
      throw Exception('Không thể tải lịch làm việc: $e');
    }
  }
}