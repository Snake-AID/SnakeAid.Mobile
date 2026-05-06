import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/http_provider.dart';
import '../../../core/services/http_service.dart';
import '../models/ai_recognition_review_models.dart';

/// Provider for [AiRecognitionReviewRepository].
final aiRecognitionReviewRepositoryProvider =
    Provider<AiRecognitionReviewRepository>((ref) {
      return AiRecognitionReviewRepository(
        httpService: ref.watch(httpServiceProvider),
      );
    });

/// Repository for Expert AI Recognition Review API.
class AiRecognitionReviewRepository {
  final HttpService _httpService;

  AiRecognitionReviewRepository({required HttpService httpService})
    : _httpService = httpService;

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Parses a paged or plain-list response body into a typed list.
  List<T> _parseList<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    List<dynamic> list;
    if (raw is List) {
      list = raw;
    } else if (raw is Map && raw['items'] is List) {
      list = raw['items'] as List;
    } else {
      list = [];
    }
    return list.whereType<Map<String, dynamic>>().map(fromJson).toList();
  }

  // ── Queue ─────────────────────────────────────────────────────────────────

  /// GET /api/experts/ai-recognition/review-queue
  Future<List<ExpertReviewItemResponse>> getReviewQueue({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      debugPrint(
        '🤖 GET /api/experts/ai-recognition/review-queue'
        ' page=$page size=$pageSize',
      );
      final response = await _httpService.get(
        '/api/experts/ai-recognition/review-queue',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      final body = response.data as Map<String, dynamic>;
      return _parseList(body['data'], ExpertReviewItemResponse.fromJson);
    } on DioException catch (e) {
      debugPrint('❌ getReviewQueue: ${e.message}');
      throw Exception('Không thể tải hàng đợi xem xét. Vui lòng thử lại.');
    }
  }

  // ── Detail ────────────────────────────────────────────────────────────────

  /// GET /api/experts/ai-recognition/review-queue/{recognitionResultId}
  Future<AIRecognitionReviewDetailResponse> getReviewDetail(
    String recognitionResultId,
  ) async {
    try {
      debugPrint(
        '🔍 GET /api/experts/ai-recognition/review-queue/$recognitionResultId',
      );
      final response = await _httpService.get(
        '/api/experts/ai-recognition/review-queue/$recognitionResultId',
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? body;
      return AIRecognitionReviewDetailResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('❌ getReviewDetail: ${e.message}');
      throw Exception('Không thể tải chi tiết. Vui lòng thử lại.');
    }
  }

  // ── History ───────────────────────────────────────────────────────────────

  /// GET /api/experts/ai-recognition/review-history
  Future<List<ExpertReviewedRecognitionItemResponse>> getReviewHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      debugPrint(
        '📋 GET /api/experts/ai-recognition/review-history'
        ' page=$page size=$pageSize',
      );
      final response = await _httpService.get(
        '/api/experts/ai-recognition/review-history',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      final body = response.data as Map<String, dynamic>;
      return _parseList(
        body['data'],
        ExpertReviewedRecognitionItemResponse.fromJson,
      );
    } on DioException catch (e) {
      debugPrint('❌ getReviewHistory: ${e.message}');
      throw Exception('Không thể tải lịch sử. Vui lòng thử lại.');
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  /// POST /api/experts/ai-recognition/review-queue/{recognitionResultId}/verify
  Future<ExpertReviewActionResponse> verify({
    required String recognitionResultId,
    required int correctedSpeciesId,
    String? expertNotes,
  }) async {
    try {
      debugPrint(
        '✅ POST verify  id=$recognitionResultId'
        '  speciesId=$correctedSpeciesId',
      );
      final payload = ExpertVerifyRecognitionRequest(
        correctedSpeciesId: correctedSpeciesId,
        expertNotes: expertNotes,
      ).toJson();
      final response = await _httpService.post(
        '/api/experts/ai-recognition/review-queue/$recognitionResultId/verify',
        data: payload,
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? body;
      return ExpertReviewActionResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('❌ verify: ${e.message}');
      throw Exception('Xác nhận thất bại. Vui lòng thử lại.');
    }
  }

  /// POST /api/experts/ai-recognition/review-queue/{recognitionResultId}/reject
  Future<ExpertReviewActionResponse> reject({
    required String recognitionResultId,
    String? expertNotes,
  }) async {
    try {
      debugPrint('❌ POST reject  id=$recognitionResultId');
      final payload = ExpertRejectRecognitionRequest(
        expertNotes: expertNotes,
      ).toJson();
      final response = await _httpService.post(
        '/api/experts/ai-recognition/review-queue/$recognitionResultId/reject',
        data: payload,
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? body;
      return ExpertReviewActionResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('❌ reject: ${e.message}');
      throw Exception('Từ chối thất bại. Vui lòng thử lại.');
    }
  }
}
