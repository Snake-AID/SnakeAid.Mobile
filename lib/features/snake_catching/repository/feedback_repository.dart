import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/http_service.dart';
import '../../../core/providers/http_provider.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FeedbackRepository(ref.watch(httpServiceProvider));
});

// ── Model ─────────────────────────────────────────────────────────────────────

class FeedbackData {
  final String id;
  final String referenceId;
  final String type;
  final String raterId;
  final String targetUserId;
  final String? targetUserRole;
  final int rating;
  final String? comments;
  final DateTime? createdAt;

  const FeedbackData({
    required this.id,
    required this.referenceId,
    required this.type,
    required this.raterId,
    required this.targetUserId,
    this.targetUserRole,
    required this.rating,
    this.comments,
    this.createdAt,
  });

  factory FeedbackData.fromJson(Map<String, dynamic> json) {
    return FeedbackData(
      id: json['id'] as String? ?? '',
      referenceId: json['referenceId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      raterId: json['raterId'] as String? ?? '',
      targetUserId: json['targetUserId'] as String? ?? '',
      targetUserRole: json['targetUserRole'] as String?,
      rating: json['rating'] as int? ?? 0,
      comments: json['comments'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}

class FeedbackRequest {
  final String targetUserId;
  final String referenceId;
  final String type;
  final int rating;
  final String? comments;
  final String targetUserRole;

  const FeedbackRequest({
    required this.targetUserId,
    required this.referenceId,
    required this.type,
    required this.rating,
    this.comments,
    required this.targetUserRole,
  });

  Map<String, dynamic> toJson() => {
        'targetUserId': targetUserId,
        'referenceId': referenceId,
        'type': type,
        'rating': rating,
        if (comments != null && comments!.isNotEmpty) 'comments': comments,
        'targetUserRole': targetUserRole,
      };
}

// ── Repository ────────────────────────────────────────────────────────────────

class FeedbackRepository {
  final HttpService _http;
  FeedbackRepository(this._http);

  /// POST /api/feedback
  Future<FeedbackData> submitFeedback(FeedbackRequest request) async {
    try {
      final body = request.toJson();
      final response = await _http.post(
        '/api/feedback',
        data: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return FeedbackData.fromJson(data as Map<String, dynamic>);
      }
      throw Exception('Không thể gửi đánh giá (status ${response.statusCode})');
    } on DioException catch (e) {
      debugPrint('❌ [FeedbackRepo] DioException status=${e.response?.statusCode}');
      debugPrint('❌ [FeedbackRepo] response body=${e.response?.data}');
      debugPrint('❌ [FeedbackRepo] error=${e.message}');
      final msg = e.response?.data?['message'] as String?;
      if (e.response?.statusCode == 409) {
        throw Exception('Bạn đã gửi đánh giá cho yêu cầu này rồi.');
      }
      throw Exception(msg ?? 'Không thể gửi đánh giá. Vui lòng thử lại.');
    } catch (e) {
      debugPrint('❌ [FeedbackRepo] Unexpected error: $e');
      throw Exception('Không thể gửi đánh giá. Vui lòng thử lại.');
    }
  }

  /// GET /api/feedback/reference/{referenceId}
  Future<List<FeedbackData>> getFeedbacksByReference(String referenceId) async {
    try {
      final response = await _http.get('/api/feedback/reference/$referenceId');
      if (response.statusCode == 200 && response.data != null) {
        final list = (response.data['data'] ?? response.data) as List<dynamic>?;
        return list
                ?.map((e) => FeedbackData.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
