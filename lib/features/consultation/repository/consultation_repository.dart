import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/http_provider.dart';
import '../../../core/services/http_service.dart';
import '../models/expert_model.dart';
import '../models/expert_list_response.dart';
import '../models/expert_detail_model.dart';
import '../models/review_model.dart';
import '../models/availability_model.dart';
import '../models/consultation_booking_response.dart';
import '../models/my_consultation_response.dart';
import '../models/consultation_review_response.dart';
import '../models/emergency_consultation_request.dart';
import '../models/consultation_payment_response.dart';
import '../models/consultation_message_history_response.dart';

/// Provider for ConsultationRepository
final consultationRepositoryProvider = Provider<ConsultationRepository>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return ConsultationRepository(httpService: httpService);
});

/// Repository for consultation-related API calls
/// Handles fetching experts, creating consultations, etc.
class ConsultationRepository {
  final HttpService httpService;

  ConsultationRepository({required this.httpService});

  /// Get list of experts with optional filters
  ///
  /// Parameters:
  /// - specialty: Filter by specialty/expertise
  /// - onlineOnly: Show only online experts
  /// - sortBy: Sort by 'rating', 'fee', 'reviews'
  ///
  /// Returns [ExpertListResponse] with list of experts
  Future<ExpertListResponse> getExperts({
    String? specialty,

    /// null = tất cả, true = chỉ online, false = chỉ offline
    bool? isOnlineFilter,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📋 Fetching experts list');
      debugPrint('   Specialty: $specialty');
      debugPrint('   IsOnline filter: $isOnlineFilter (null=tất cả)');
      debugPrint('   Sort by: $sortBy, order: $sortOrder');
      debugPrint('   Page: $page, Size: $pageSize');

      // Build query parameters — field names match Swagger exactly
      final queryParams = <String, dynamic>{
        'PageNumber': page,
        'PageSize': pageSize,
      };

      if (specialty != null && specialty.isNotEmpty) {
        queryParams['Specialization'] = specialty;
      }

      // Chỉ gửi IsOnline khi được chọn rõ ràng (null = không filter = cả hai)
      if (isOnlineFilter != null) {
        queryParams['IsOnline'] = isOnlineFilter;
      }

      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['SortBy'] = sortBy;
        if (sortOrder != null && sortOrder.isNotEmpty) {
          queryParams['SortOrder'] = sortOrder;
        }
      }

      final response = await httpService.get(
        '/api/experts',
        queryParameters: queryParams,
      );

      debugPrint('✅ Experts fetched successfully');
      debugPrint('   Response type: ${response.data.runtimeType}');

      return ExpertListResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ Failed to fetch experts: ${e.message}');
      debugPrint('   Error type: ${e.type}');
      debugPrint('   Status code: ${e.response?.statusCode}');

      // Return error response
      return ExpertListResponse(
        statusCode: e.response?.statusCode ?? 500,
        message:
            e.response?.data?['message'] ??
            'Không thể tải danh sách chuyên gia',
        isSuccess: false,
        error: e.message,
      );
    } catch (e) {
      debugPrint('❌ Unexpected error fetching experts: $e');
      return ExpertListResponse(
        statusCode: 500,
        message: 'Lỗi không xác định khi tải danh sách chuyên gia',
        isSuccess: false,
        error: e.toString(),
      );
    }
  }

  /// Get expert by ID (basic profile)
  ///
  /// Returns [ExpertModel] or null if not found
  Future<ExpertModel?> getExpertById(String expertId) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📋 Fetching expert by id: $expertId');

      final response = await httpService.get('/api/experts/$expertId');

      debugPrint('✅ Expert fetched successfully');

      final body = response.data as Map<String, dynamic>;
      final data = body['is_success'] == true
          ? body['data'] as Map<String, dynamic>?
          : body;
      if (data == null) return null;
      return ExpertModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint('❌ Failed to fetch expert: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('❌ Unexpected error fetching expert: $e');
      return null;
    }
  }

  /// Get list of available specialties (local fallback — no dedicated endpoint)
  Future<List<String>> getSpecialties() async {
    return _getDefaultSpecialties();
  }

  /// Get default specialties (fallback)
  List<String> _getDefaultSpecialties() {
    return [
      'Tất cả chuyên môn',
      'Rắn Độc Việt Nam',
      'Rắn Cảnh',
      'Rắn Nước',
      'Rắn Không Độc',
      'Xử lý vết cắn',
      'Cứu hộ rắn',
      'Nghiên cứu rắn',
    ];
  }

  /// Get full expert detail: profile + reviews + time slots (3 parallel calls)
  ///
  /// Returns [ExpertDetailModel] assembled from:
  /// - `GET /api/experts/{id}`
  /// - `GET /api/experts/{id}/reviews`
  /// - `GET /api/experts/{id}/time-slots`
  Future<ExpertDetailModel> getExpertDetail(String expertId) async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📋 Fetching expert detail (3 parallel): $expertId');

    // Start all 3 requests in parallel
    final profileFuture = httpService.get('/api/experts/$expertId');
    final reviewsFuture = httpService.get(
      '/api/experts/$expertId/reviews',
      queryParameters: {'pageNumber': 1, 'pageSize': 10},
    );
    final slotsFuture = httpService.get('/api/experts/$expertId/time-slots');

    // Await results (all running in parallel)
    final profileResponse = await profileFuture;
    final reviewsResponse = await reviewsFuture;
    final slotsResponse = await slotsFuture;

    debugPrint('✅ All 3 expert detail requests completed');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // --- Parse profile ---
    final profileBody = profileResponse.data as Map<String, dynamic>;
    final profileData = profileBody['is_success'] == true
        ? (profileBody['data'] as Map<String, dynamic>? ?? profileBody)
        : profileBody;
    final expert = ExpertModel.fromJson(profileData);

    // --- Parse reviews (non-fatal) ---
    List<ReviewModel> reviews = [];
    try {
      final body = reviewsResponse.data as Map<String, dynamic>;
      if (body['is_success'] == true && body['data'] != null) {
        final data = body['data'];
        final items = (data['items'] ?? data['data'] ?? []) as List<dynamic>;
        reviews = items
            .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('⚠️ Failed to parse reviews: $e');
    }

    // --- Parse time slots (non-fatal) ---
    List<AvailabilityDay> availability = [];
    try {
      final body = slotsResponse.data as Map<String, dynamic>;
      if (body['is_success'] == true && body['data'] != null) {
        final slots = body['data'] as List<dynamic>;
        availability = _groupSlotsToAvailabilityDays(slots);
      }
    } catch (e) {
      debugPrint('⚠️ Failed to parse time slots: $e');
    }

    // Parse stats from profile data (backend may return int/double/string)
    final avgMinutesRaw = profileData['averageResponseTimeMinutes'];
    final avgMinutes = avgMinutesRaw is num
        ? avgMinutesRaw.round()
        : int.tryParse(avgMinutesRaw?.toString() ?? '');
    final totalConsultationsRaw = profileData['totalConsultations'];
    final totalConsultations = totalConsultationsRaw is num
        ? totalConsultationsRaw.toInt()
        : int.tryParse(totalConsultationsRaw?.toString() ?? '') ?? 0;
    final avgResponseStr = avgMinutes == null ? '< 5 phút' : '$avgMinutes phút';

    return ExpertDetailModel.fromExpertModel(
      expert,
      experienceList: const [],
      totalConsultations: totalConsultations,
      averageResponseTime: avgResponseStr,
      successRate: ((profileData['successRate'] ?? 0) as num).toDouble(),
      consultationFees: {
        30: expert.scheduledConsultationFee > 0
            ? expert.scheduledConsultationFee
            : expert.consultationFee,
      },
      availability: availability,
      reviews: reviews,
    );
  }

  /// Get reviews for an expert
  ///
  /// API: `GET /api/experts/{expertId}/reviews`
  Future<List<ReviewModel>> getExpertReviews(
    String expertId, {
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      debugPrint('📋 Fetching reviews for expert: $expertId');

      final response = await httpService.get(
        '/api/experts/$expertId/reviews',
        queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
      );

      final body = response.data as Map<String, dynamic>;
      if (body['is_success'] == true && body['data'] != null) {
        final data = body['data'];
        final items = (data['items'] ?? data['data'] ?? []) as List<dynamic>;
        return items
            .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('❌ Failed to fetch reviews: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('❌ Unexpected error fetching reviews: $e');
      return [];
    }
  }

  /// Get paged reviews for an expert including metadata.
  ///
  /// API: `GET /api/experts/{expertId}/reviews`
  Future<({
    List<ReviewModel> items,
    int totalPages,
    int totalItems,
    int currentPage,
    int pageSize,
  })> getExpertReviewsPaged(
    String expertId, {
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      debugPrint('📋 Fetching paged reviews for expert: $expertId');

      final response = await httpService.get(
        '/api/experts/$expertId/reviews',
        queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
      );

      final body = response.data as Map<String, dynamic>;
      if (body['is_success'] == true && body['data'] != null) {
        final data = body['data'] as Map<String, dynamic>;
        final itemsRaw = (data['items'] ?? data['data'] ?? []) as List<dynamic>;
        final meta = data['meta'] as Map<String, dynamic>? ?? <String, dynamic>{};

        final items = itemsRaw
            .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
            .toList();

        int parseInt(dynamic value, int fallback) {
          if (value is int) return value;
          if (value is num) return value.toInt();
          return int.tryParse(value?.toString() ?? '') ?? fallback;
        }

        return (
          items: items,
          totalPages: parseInt(meta['total_pages'], 1),
          totalItems: parseInt(meta['total_items'], items.length),
          currentPage: parseInt(meta['current_page'], pageNumber),
          pageSize: parseInt(meta['page_size'], pageSize),
        );
      }

      return (
        items: const <ReviewModel>[],
        totalPages: 1,
        totalItems: 0,
        currentPage: pageNumber,
        pageSize: pageSize,
      );
    } on DioException catch (e) {
      debugPrint('❌ Failed to fetch paged reviews: ${e.message}');
      return (
        items: const <ReviewModel>[],
        totalPages: 1,
        totalItems: 0,
        currentPage: pageNumber,
        pageSize: pageSize,
      );
    } catch (e) {
      debugPrint('❌ Unexpected error fetching paged reviews: $e');
      return (
        items: const <ReviewModel>[],
        totalPages: 1,
        totalItems: 0,
        currentPage: pageNumber,
        pageSize: pageSize,
      );
    }
  }

  /// Get available time slots for an expert
  ///
  /// API: `GET /api/experts/{expertId}/time-slots`
  Future<List<AvailabilityDay>> getExpertTimeSlots(String expertId) async {
    try {
      debugPrint('📋 Fetching time slots for expert: $expertId');

      final response = await httpService.get(
        '/api/experts/$expertId/time-slots',
      );

      final body = response.data as Map<String, dynamic>;
      if (body['is_success'] == true && body['data'] != null) {
        final slots = body['data'] as List<dynamic>;
        return _groupSlotsToAvailabilityDays(slots);
      }
      return [];
    } on DioException catch (e) {
      debugPrint('❌ Failed to fetch time slots: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('❌ Unexpected error fetching time slots: $e');
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Group flat time-slot list into [AvailabilityDay] objects grouped by date.
  ///
  /// Each slot from backend: `{ id, expertId, startTime (ISO UTC), endTime (ISO UTC) }`
  List<AvailabilityDay> _groupSlotsToAvailabilityDays(List<dynamic> slotsJson) {
    const weekDayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final Map<String, DateTime> dayToDate = {};
    final Map<String, List<TimeSlotEntry>> dayToEntries = {};

    for (final slot in slotsJson) {
      final startTimeStr = slot['startTime'] as String?;
      if (startTimeStr == null) continue;

      // Only show slots that are still available
      final status = slot['status'] as String?;
      if (status != null && status != 'Available') continue;

      final slotId = (slot['id'] as String?) ?? '';
      // Backend stores VN wall-clock time tagged as +00 (no real UTC conversion on backend)
      // So use UTC components directly as VN time — no offset needed
      final startUtc = DateTime.parse(startTimeStr).toUtc();
      final startTime = DateTime.utc(
        startUtc.year,
        startUtc.month,
        startUtc.day,
        startUtc.hour,
        startUtc.minute,
      );
      final endTimeStr = slot['endTime'] as String?;
      DateTime endTime;
      if (endTimeStr != null) {
        final endUtc = DateTime.parse(endTimeStr).toUtc();
        endTime = DateTime.utc(
          endUtc.year,
          endUtc.month,
          endUtc.day,
          endUtc.hour,
          endUtc.minute,
        );
      } else {
        endTime = startTime.add(const Duration(minutes: 30));
      }

      final dateKey =
          '${startTime.year.toString().padLeft(4, '0')}-'
          '${startTime.month.toString().padLeft(2, '0')}-'
          '${startTime.day.toString().padLeft(2, '0')}';

      final startStr =
          '${startTime.hour.toString().padLeft(2, '0')}:'
          '${startTime.minute.toString().padLeft(2, '0')}';
      final endStr =
          '${endTime.hour.toString().padLeft(2, '0')}:'
          '${endTime.minute.toString().padLeft(2, '0')}';

      dayToDate[dateKey] = DateTime.utc(
        startTime.year,
        startTime.month,
        startTime.day,
      );
      dayToEntries
          .putIfAbsent(dateKey, () => [])
          .add(TimeSlotEntry(id: slotId, startTime: startStr, endTime: endStr));
    }

    final days = dayToDate.entries.map((entry) {
      final date = entry.value;
      final slots = dayToEntries[entry.key]!
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
      return AvailabilityDay(
        date: date,
        dayOfWeek: weekDayLabels[date.weekday - 1],
        isAvailable: true,
        timeSlots: slots,
      );
    }).toList()..sort((a, b) => a.date.compareTo(b.date));

    return days;
  }

  // ---------------------------------------------------------------------------
  // Booking methods
  // ---------------------------------------------------------------------------

  /// Get all bookings for the current logged-in member
  ///
  /// API: `GET /api/users/me/consultations/scheduled`
  Future<List<ConsultationBookingResponse>> getMyBookings() async {
    try {
      debugPrint('📋 Fetching my bookings');
      final response =
          await httpService.get('/api/users/me/consultations/scheduled');

      final body = response.data as Map<String, dynamic>;
      if (body['is_success'] == true && body['data'] != null) {
        final list = body['data'] as List<dynamic>;
        return list
            .map(
              (e) => ConsultationBookingResponse.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('❌ Failed to fetch bookings: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('❌ Unexpected error fetching bookings: $e');
      return [];
    }
  }

  /// Get consultations for current user (scheduled + emergency).
  ///
  /// API: `GET /api/users/me/consultations`
  Future<List<MyConsultationResponse>> getMyConsultations({
    String? status,
    String? type,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      debugPrint(
        '📋 Fetching my consultations: status=$status, type=$type, page=$pageNumber, size=$pageSize',
      );
      final query = <String, dynamic>{
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      };
      if (status != null && status.isNotEmpty) {
        query['status'] = status;
      }
      if (type != null && type.isNotEmpty) {
        query['type'] = type;
      }

      final response = await httpService.get(
        '/api/users/me/consultations',
        queryParameters: query,
      );

      final body = response.data as Map<String, dynamic>;
      if (body['is_success'] == true && body['data'] != null) {
        final data = body['data'] as Map<String, dynamic>;
        final items = (data['items'] as List<dynamic>? ?? const []);
        return items
            .whereType<Map<String, dynamic>>()
            .map(MyConsultationResponse.fromJson)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('❌ Failed to fetch consultations: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('❌ Unexpected error fetching consultations: $e');
      return [];
    }
  }

  /// Create a new consultation booking
  ///
  /// API: `POST /api/consultations/scheduled`
  ///
  /// Throws:
  /// - `409` when the slot has already been booked (race condition)
  /// - `404` when expert or slot not found
  /// - `400/422` for invalid payload
  Future<ConsultationBookingResponse> createBooking(
    CreateConsultationBookingRequest request,
  ) async {
    debugPrint('📋 Creating booking for slot: ${request.timeSlotId}');

    final response = await httpService.post(
      '/api/consultations/scheduled',
      data: request.toJson(),
    );

    final body = response.data as Map<String, dynamic>;
    if (body['is_success'] == true && body['data'] != null) {
      return ConsultationBookingResponse.fromJson(
        body['data'] as Map<String, dynamic>,
      );
    }

    throw Exception(body['message'] ?? 'Không thể tạo lịch tư vấn');
  }

  /// Cancel a future scheduled booking as member or expert.
  ///
  /// API: `POST /api/consultations/scheduled/{bookingId}/cancel`
  Future<ConsultationBookingResponse> cancelScheduledBooking(
    String bookingId,
  ) async {
    debugPrint('📋 Cancelling scheduled booking: $bookingId');

    final response = await httpService.post(
      '/api/consultations/scheduled/$bookingId/cancel',
    );

    final body = response.data as Map<String, dynamic>;
    if (body['is_success'] == true && body['data'] != null) {
      return ConsultationBookingResponse.fromJson(
        body['data'] as Map<String, dynamic>,
      );
    }

    throw Exception(body['message'] ?? 'Không thể hủy lịch tư vấn');
  }

  // ---------------------------------------------------------------------------
  // Emergency consultation methods
  // ---------------------------------------------------------------------------

  /// Create an emergency consultation request for a specific expert.
  ///
  /// API: `POST /api/consultations/instant`
  Future<EmergencyConsultationRequest> createEmergencyRequest({
    required String expertId,
  }) async {
    debugPrint(
      '🚨 Creating emergency consultation request for expert: $expertId',
    );

    final response = await httpService.post(
      '/api/consultations/instant',
      data: {'expertId': expertId},
    );

    final body = response.data as Map<String, dynamic>;
    if (body['is_success'] == true && body['data'] != null) {
      return EmergencyConsultationRequest.fromJson(
        body['data'] as Map<String, dynamic>,
      );
    }

    throw Exception(body['message'] ?? 'Không thể tạo yêu cầu tư vấn ngay');
  }

  /// Expert accepts an emergency consultation request.
  ///
  /// API: `POST /api/consultations/instant/{requestId}/accept`
  Future<EmergencyConsultationRequest> acceptEmergencyRequest(
    String requestId,
  ) async {
    final response = await httpService.post(
      '/api/consultations/instant/$requestId/accept',
    );

    final body = response.data as Map<String, dynamic>;
    if (body['is_success'] == true && body['data'] != null) {
      return EmergencyConsultationRequest.fromJson(
        body['data'] as Map<String, dynamic>,
      );
    }

    throw Exception(
      body['message'] ?? 'Không thể chấp nhận yêu cầu tư vấn ngay',
    );
  }

  /// Expert rejects an emergency consultation request.
  ///
  /// API: `POST /api/consultations/instant/{requestId}/reject`
  Future<EmergencyConsultationRequest> rejectEmergencyRequest(
    String requestId,
  ) async {
    final response = await httpService.post(
      '/api/consultations/instant/$requestId/reject',
    );

    final body = response.data as Map<String, dynamic>;
    if (body['is_success'] == true && body['data'] != null) {
      return EmergencyConsultationRequest.fromJson(
        body['data'] as Map<String, dynamic>,
      );
    }

    throw Exception(body['message'] ?? 'Không thể từ chối yêu cầu tư vấn ngay');
  }

  /// Get current status of an emergency consultation request.
  ///
  /// Preferred API: `GET /api/consultations/instant/{requestId}`
  /// Fallback API: `GET /api/consultations/instant/{requestId}/status`
  ///
  /// Returns null when endpoint is unavailable to keep UI resilient.
  Future<EmergencyConsultationRequest?> getEmergencyRequestStatus(
    String requestId,
  ) async {
    final candidates = <String>[
      '/api/consultations/instant/$requestId',
      '/api/consultations/instant/$requestId/status',
    ];

    for (final path in candidates) {
      try {
        final response = await httpService.get(path);
        final body = response.data;
        if (body is! Map<String, dynamic>) continue;
        if (body['is_success'] == true && body['data'] is Map<String, dynamic>) {
          return EmergencyConsultationRequest.fromJson(
            body['data'] as Map<String, dynamic>,
          );
        }
      } catch (_) {
        // Ignore and try next candidate.
      }
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // In-room chat utility methods
  // ---------------------------------------------------------------------------

  /// Upload an image for chat message attachments.
  ///
  /// API: `POST /api/media/upload-image` with `domain=chat-media`
  /// Returns secure image URL.
  Future<String> uploadChatImage(String filePath) async {
    final fileName = filePath.split(RegExp(r'[\\/]')).last;
    Future<Response<dynamic>> sendUpload({required bool uppercaseKeys}) async {
      final formData = FormData.fromMap({
        uppercaseKeys ? 'File' : 'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
        uppercaseKeys ? 'Domain' : 'domain': 'chat-media',
      });

      return httpService.post(
        '/api/media/upload-image',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    }

    Response<dynamic> response;
    try {
      response = await sendUpload(uppercaseKeys: true);
    } catch (e) {
      debugPrint(
        '⚠️ Upload chat image with File/Domain failed, retrying file/domain: $e',
      );
      response = await sendUpload(uppercaseKeys: false);
    }

    final body = response.data as Map<String, dynamic>;
    if (body['is_success'] == true && body['data'] != null) {
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        final secureUrl =
            (data['secureUrl'] ??
                    data['SecureUrl'] ??
                    data['url'] ??
                    data['Url'])
                ?.toString();
        if (secureUrl != null && secureUrl.isNotEmpty) {
          debugPrint('✅ Chat image uploaded: $secureUrl');
          return secureUrl;
        }
      }
    }

    throw Exception(body['message'] ?? 'Không thể upload ảnh chat');
  }

  /// Search snake species by keyword for in-room expert assistance.
  ///
  /// API: `GET /api/snake-species`
  Future<List<Map<String, dynamic>>> searchSnakeSpecies(String query) async {
    final response = await httpService.get('/api/snake-species');

    final body = response.data as Map<String, dynamic>;
    if (body['is_success'] == true && body['data'] is List) {
      return (body['data'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    return [];
  }

  /// Get snake species detail by id.
  ///
  /// API: `GET /api/snake-species/{id}`
  Future<Map<String, dynamic>?> getSnakeSpeciesDetail(int id) async {
    final response = await httpService.get('/api/snake-species/$id');
    final body = response.data as Map<String, dynamic>;
    if (body['is_success'] == true && body['data'] is Map<String, dynamic>) {
      return body['data'] as Map<String, dynamic>;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Video call methods
  // ---------------------------------------------------------------------------

  /// Get a LiveKit access token for a consultation room.
  ///
  /// API: `POST /api/consultations/{consultationId}/video-token`
  ///
  /// Returns `({String token, String wsUrl})` from `data.token` + `data.wsUrl`.
  /// Falls back to `LIVEKIT_URL` env var if `wsUrl` is absent in response.
  /// Throws on 401 (unauthenticated), 403 (not a participant), 404 (not found).
  Future<({String token, String wsUrl})> getLivekitToken(
    String consultationId,
  ) async {
    debugPrint('🎥 Getting LiveKit token for consultation: $consultationId');

    final response = await httpService.post(
      '/api/consultations/$consultationId/video-token',
    );

    final body = response.data as Map<String, dynamic>;
    if (body['is_success'] == true && body['data'] != null) {
      final data = body['data'] as Map<String, dynamic>;
      final token = data['token'] as String?;
      final wsUrlFromApi = data['wsUrl'] as String?;
      final wsUrl = (wsUrlFromApi != null && wsUrlFromApi.isNotEmpty)
          ? wsUrlFromApi
          : (dotenv.env['LIVEKIT_URL'] ?? '');
      if (token != null && token.isNotEmpty)
        return (token: token, wsUrl: wsUrl);
    }

    final statusCode = body['status_code'] as int? ?? 0;
    if (statusCode == 403) throw Exception('403');
    if (statusCode == 404) throw Exception('404');
    throw Exception(body['message'] ?? 'Không thể lấy token phòng tư vấn');
  }

  /// End a consultation session.
  ///
  /// API: `POST /api/consultations/{consultationId}/end`
  ///
  /// Returns true on success; does not throw — failures are logged only
  /// so the UI can always navigate away.
  Future<bool> endConsultation(String consultationId) async {
    try {
      debugPrint('🏁 Ending consultation: $consultationId');
      final response = await httpService.post(
        '/api/consultations/$consultationId/end',
      );
      final body = response.data as Map<String, dynamic>;
      return body['is_success'] == true;
    } catch (e) {
      debugPrint('⚠️ endConsultation failed (non-critical): $e');
      return false;
    }
  }

  /// Get current user's wallet information.
  ///
  /// API: `GET /api/wallet/me`
  ///
  /// Returns wallet data including balance.
  /// Throws Exception if API call fails.
  Future<Map<String, dynamic>> getMyWallet() async {
    debugPrint('💰 Fetching wallet information');

    final response = await httpService.get('/api/wallet/me');
    final body = response.data as Map<String, dynamic>;

    if (body['is_success'] == true && body['data'] != null) {
      debugPrint('✅ Wallet fetched: ${body['data']}');
      return body['data'] as Map<String, dynamic>;
    }

    throw Exception(body['message'] ?? 'Không thể lấy thông tin ví');
  }

  /// Create a PayOS top-up payment link for current user's wallet.
  ///
  /// API: `POST /api/wallet/topup`
  Future<Map<String, dynamic>> createWalletTopup({
    required double amount,
    String? description,
  }) async {
    final sanitizedDescription = description?.trim();

    if (amount < 1000 || amount > 10000000) {
      throw Exception('Số tiền nạp phải từ 1.000 đến 10.000.000 VND');
    }
    if (sanitizedDescription != null && sanitizedDescription.length > 200) {
      throw Exception('Mô tả tối đa 200 ký tự');
    }

    try {
      final response = await httpService.post(
        '/api/wallet/topup',
        data: {
          'amount': amount,
          if (sanitizedDescription != null && sanitizedDescription.isNotEmpty)
            'description': sanitizedDescription,
        },
      );

      final body = response.data as Map<String, dynamic>;
      if (body['is_success'] == true && body['data'] != null) {
        return body['data'] as Map<String, dynamic>;
      }
      throw Exception(body['message'] ?? 'Không thể tạo giao dịch nạp ví');
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorBody = e.response?.data;
      String backendMessage = '';
      if (errorBody is Map<String, dynamic>) {
        backendMessage = (errorBody['message'] ?? '').toString().trim();
      }

      if (statusCode == 404) {
        throw Exception('Ví chưa tồn tại cho tài khoản này');
      }
      if (statusCode == 400) {
        final normalized = backendMessage.toLowerCase();
        if (normalized.contains('pending') ||
            normalized.contains('chưa hoàn thành') ||
            normalized.contains('dang cho')) {
          throw Exception(
            'Bạn đang có giao dịch nạp tiền chờ xử lý. Vui lòng hoàn tất hoặc hủy giao dịch trước.',
          );
        }
        if (normalized.contains('amount') ||
            normalized.contains('số tiền') ||
            normalized.contains('so tien')) {
          throw Exception('Số tiền nạp phải từ 1.000 đến 10.000.000 VND');
        }
      }

      throw Exception(
        backendMessage.isNotEmpty
            ? backendMessage
            : 'Không thể tạo giao dịch nạp ví',
      );
    }
  }

  /// Submit a review for a completed consultation.
  ///
  /// API: `POST /api/consultations/{consultationId}/reviews`
  ///
  /// Throws on validation errors or permission errors.
  Future<void> submitReview({
    required String consultationId,
    required int rating,
    String comment = '',
  }) async {
    debugPrint(
      '⭐ Submitting review for consultation: $consultationId, rating: $rating',
    );

    final response = await httpService.post(
      '/api/consultations/$consultationId/reviews',
      data: {'rating': rating, 'comments': comment},
    );

    final body = response.data as Map<String, dynamic>;
    if (body['is_success'] != true) {
      throw Exception(body['message'] ?? 'Không thể gửi đánh giá');
    }
  }

  /// Get review details for a specific consultation.
  ///
  /// API: `GET /api/consultations/{consultationId}/reviews`
  /// Returns null when no review exists.
  Future<ConsultationReviewResponse?> getConsultationReview(
    String consultationId,
  ) async {
    final response = await httpService.get(
      '/api/consultations/$consultationId/reviews',
    );

    final body = response.data as Map<String, dynamic>;
    if (body['is_success'] == true) {
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        return ConsultationReviewResponse.fromJson(data);
      }
      return null;
    }

    throw Exception(body['message'] ?? 'Không thể lấy đánh giá buổi tư vấn');
  }

  /// Report expert absence for a scheduled consultation.
  ///
  /// API: `POST /api/consultations/{consultationId}/expert-absent-report`
  Future<MyConsultationResponse> reportExpertAbsent({
    required String consultationId,
    required String customerReport,
  }) async {
    final report = customerReport.trim();
    if (report.isEmpty) {
      throw Exception('Nội dung báo cáo không được để trống');
    }
    if (report.length > 2000) {
      throw Exception('Nội dung báo cáo tối đa 2000 ký tự');
    }

    final response = await httpService.post(
      '/api/consultations/$consultationId/expert-absent-report',
      data: {'customerReport': report},
    );

    final body = response.data as Map<String, dynamic>;
    if (body['is_success'] == true && body['data'] is Map<String, dynamic>) {
      return MyConsultationResponse.fromJson(
        body['data'] as Map<String, dynamic>,
      );
    }

    throw Exception(body['message'] ?? 'Không thể gửi báo cáo chuyên gia vắng mặt');
  }

  /// Get persisted chat history for a terminal consultation.
  ///
  /// API: `GET /api/consultations/{consultationId}/messages-history`
  Future<ConsultationMessageHistoryResponse> getConsultationMessageHistory({
    required String consultationId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final response = await httpService.get(
      '/api/consultations/$consultationId/messages-history',
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    final body = response.data as Map<String, dynamic>;
    if (body['is_success'] == true && body['data'] is Map<String, dynamic>) {
      return ConsultationMessageHistoryResponse.fromJson(
        body['data'] as Map<String, dynamic>,
      );
    }

    throw Exception(body['message'] ?? 'Không thể tải lịch sử tin nhắn');
  }

  // ---------------------------------------------------------------------------
  // Expert profile settings
  // ---------------------------------------------------------------------------

  /// Update the current expert's profile settings.
  ///
  /// API: `PUT /api/experts/me/settings`
  ///
  /// Provide at least one of [scheduledConsultationFee],
  /// [emergencyConsultationFee], [biography], [specializations].
  /// Null values are omitted from the request body.
  ///
  /// Throws on 400/422 (invalid payload), 401/403 (unauthenticated / wrong role).
  Future<void> updateExpertSettings({
    double? scheduledConsultationFee,
    double? emergencyConsultationFee,
    // Backward-compatible alias for scheduled fee.
    double? consultationFee,
    String? biography,
    List<String>? specializations,
  }) async {
    final resolvedScheduledFee = scheduledConsultationFee ?? consultationFee;

    final body = <String, dynamic>{
      if (resolvedScheduledFee != null)
        'scheduledConsultationFee': resolvedScheduledFee,
      if (emergencyConsultationFee != null)
        'emergencyConsultationFee': emergencyConsultationFee,
      if (biography != null) 'biography': biography,
      if (specializations != null) 'specializations': specializations,
    };

    debugPrint('⚙️  Updating expert settings: $body');

    final response = await httpService.put(
      '/api/experts/me/settings',
      data: body,
    );

    final resBody = response.data as Map<String, dynamic>;
    if (resBody['is_success'] != true) {
      throw Exception(resBody['message'] ?? 'Không thể cập nhật cài đặt');
    }
  }

  // ---------------------------------------------------------------------------
  // Expert time-slot management
  // ---------------------------------------------------------------------------

  /// Submit bulk working-hour time slots for the current expert.
  ///
  /// API: `POST /api/v1/experts/me/time-slots/bulk`
  ///
  /// Request body:
  /// ```json
  /// {
  ///   "weekStartDate": "2026-03-09T00:00:00Z",
  ///   "days": [
  ///     { "dayOfWeek": "Monday", "timeBlocks": [{"startTime": "08:00", "endTime": "12:00"}] }
  ///   ]
  /// }
  /// ```
  Future<void> bulkTimeSlots({
    required String weekStartDate,
    required List<Map<String, dynamic>> days,
  }) async {
    debugPrint(
      '📅 Submitting bulk time slots for week $weekStartDate (${days.length} days)',
    );

    final response = await httpService.post(
      '/api/experts/me/time-slots/bulk',
      data: {'weekStartDate': weekStartDate, 'days': days},
    );

    final body = response.data as Map<String, dynamic>;
    if (body['is_success'] != true) {
      final statusCode = body['status_code'] as int? ?? 0;
      if (statusCode == 422) {
        throw Exception('weekStartDate phải là ngày Thứ Hai theo múi giờ UTC');
      }
      if (statusCode == 409) {
        throw Exception('Một số khung giờ đã bị trùng, vui lòng thử lại');
      }
      throw Exception(body['message'] ?? 'Không thể lưu lịch làm việc');
    }
  }

  // ---------------------------------------------------------------------------
  // Payment methods
  // ---------------------------------------------------------------------------

  bool _isPayOsMethod(String paymentMethod) {
    final normalized = paymentMethod.trim().toLowerCase();
    return normalized == 'payos';
  }

  List<String> _paymentMethodCandidates(String paymentMethod) {
    if (!_isPayOsMethod(paymentMethod)) {
      return [paymentMethod];
    }

    // Backend environments may deserialize enum casing inconsistently.
    final ordered = ['PayOs', 'PayOS', 'payos'];
    final unique = <String>{};
    final result = <String>[];
    for (final item in [paymentMethod, ...ordered]) {
      if (unique.add(item)) {
        result.add(item);
      }
    }
    return result;
  }

  bool _shouldRetryPayOsAttempt({
    required String paymentMethod,
    int? statusCode,
    String? message,
  }) {
    if (!_isPayOsMethod(paymentMethod)) return false;
    final msg = (message ?? '').toLowerCase();
    return (statusCode != null && statusCode >= 500) ||
        msg.contains('nullreferenceexception') ||
        msg.contains('object reference not set');
  }

  Exception _buildPaymentException({
    required String defaultMessage,
    int? statusCode,
    String? message,
  }) {
    final msg = (message ?? '').trim();
    if (statusCode == 409 &&
        (msg.toLowerCase().contains('balance') ||
            msg.toLowerCase().contains('wallet'))) {
      return Exception('Số dư ví không đủ để thanh toán');
    }
    if (statusCode != null && statusCode >= 500) {
      return Exception(
        'Hệ thống thanh toán đang lỗi phía máy chủ (HTTP $statusCode). Vui lòng thử lại sau hoặc dùng ví SnakeAid tạm thời.',
      );
    }
    return Exception(msg.isNotEmpty ? msg : defaultMessage);
  }

  Future<ConsultationPaymentResponse> _postConsultationPaymentWithFallback({
    required String path,
    required String paymentMethod,
    required String defaultErrorMessage,
  }) async {
    Exception? lastError;

    for (final method in _paymentMethodCandidates(paymentMethod)) {
      try {
        debugPrint('💳 Payment attempt: $path, paymentMethod=$method');
        final response = await httpService.post(
          path,
          data: {'paymentMethod': method},
        );

        final body = response.data as Map<String, dynamic>;
        if (body['is_success'] == true && body['data'] != null) {
          return ConsultationPaymentResponse.fromJson(
            body['data'] as Map<String, dynamic>,
          );
        }

        final statusCode = body['status_code'] as int?;
        final message = body['message']?.toString();
        debugPrint(
          '⚠️ Payment API failed: status=$statusCode, method=$method, message=$message',
        );
        final retry = _shouldRetryPayOsAttempt(
          paymentMethod: method,
          statusCode: statusCode,
          message: message,
        );

        lastError = _buildPaymentException(
          defaultMessage: defaultErrorMessage,
          statusCode: statusCode,
          message: message,
        );

        if (!retry) {
          throw lastError;
        }
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        String? message;
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          message = data['message']?.toString();
        } else {
          message = e.message;
        }
        debugPrint(
          '⚠️ Payment DioException: status=$statusCode, method=$method, message=$message',
        );

        final retry = _shouldRetryPayOsAttempt(
          paymentMethod: method,
          statusCode: statusCode,
          message: message,
        );

        lastError = _buildPaymentException(
          defaultMessage: defaultErrorMessage,
          statusCode: statusCode,
          message: message,
        );

        if (!retry) {
          throw lastError;
        }
      }
    }

    throw lastError ?? Exception(defaultErrorMessage);
  }

  /// Pay for a scheduled consultation booking.
  ///
  /// API: `POST /api/consultations/scheduled/{bookingId}/payments`
  ///
  /// Throws:
  /// - 409 when booking already paid or not in `PendingPayment`
  /// - 409 when wallet balance is insufficient
  Future<ConsultationPaymentResponse> payBooking(
    String bookingId, {
    String paymentMethod = 'WalletBalance',
  }) async {
    debugPrint('💳 Paying booking: $bookingId');

    return _postConsultationPaymentWithFallback(
      path: '/api/consultations/scheduled/$bookingId/payments',
      paymentMethod: paymentMethod,
      defaultErrorMessage: 'Không thể thanh toán',
    );
  }

  /// Pay for an emergency consultation request.
  ///
  /// API: `POST /api/consultations/instant/{requestId}/payments`
  ///
  /// This moves request status from `PendingPayment` to `PendingExpertResponse`.
  Future<ConsultationPaymentResponse> payEmergencyRequest(
    String requestId, {
    String paymentMethod = 'WalletBalance',
  }) async {
    debugPrint('💳 Paying emergency request: $requestId');

    return _postConsultationPaymentWithFallback(
      path: '/api/consultations/instant/$requestId/payments',
      paymentMethod: paymentMethod,
      defaultErrorMessage: 'Không thể thanh toán tư vấn ngay',
    );
  }

  /// Manual fallback confirm for consultation PayOS payment.
  ///
  /// API: `POST /api/consultations/payments/confirm`
  Future<ConsultationPaymentResponse> confirmConsultationPayment(
    String transactionId,
  ) async {
    final response = await httpService.post(
      '/api/consultations/payments/confirm',
      data: {'transactionId': transactionId},
    );

    final body = response.data as Map<String, dynamic>;
    if (body['is_success'] == true && body['data'] != null) {
      return ConsultationPaymentResponse.fromJson(
        body['data'] as Map<String, dynamic>,
      );
    }

    throw Exception(body['message'] ?? 'Không thể xác nhận thanh toán');
  }

  // ---------------------------------------------------------------------------
  // Expert booking methods
  // ---------------------------------------------------------------------------

  /// Get all bookings for the current logged-in expert.
  ///
  /// API priority:
  /// 1) `GET /api/experts/me/consultations`
  /// 2) `GET /api/experts/me/consultations/scheduled`
  /// 3) `GET /api/experts/me/consultation-bookings` (legacy fallback)
  Future<List<ConsultationBookingResponse>> getExpertBookings({
    String? status,
    String? type,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      debugPrint(
        '📋 Fetching expert consultations: status=$status, type=$type, page=$pageNumber, size=$pageSize',
      );
      final query = <String, dynamic>{
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      };
      if (status != null && status.isNotEmpty) {
        query['status'] = status;
      }
      if (type != null && type.isNotEmpty) {
        query['type'] = type;
      }

      Response<dynamic> response;
      try {
        // Prefer aggregate endpoint to include both scheduled and emergency consultations.
        response = await httpService.get(
          '/api/experts/me/consultations',
          queryParameters: query,
        );
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 404 || statusCode == 405) {
          // Fallback for environments still serving scheduled/legacy endpoints.
          try {
            response =
                await httpService.get('/api/experts/me/consultations/scheduled');
          } on DioException catch (e2) {
            final statusCode2 = e2.response?.statusCode;
            if (statusCode2 == 404 || statusCode2 == 405) {
              response =
                  await httpService.get('/api/experts/me/consultation-bookings');
            } else {
              rethrow;
            }
          }
        } else {
          rethrow;
        }
      }

      final body = response.data as Map<String, dynamic>;
      if (body['is_success'] == true && body['data'] != null) {
        List<Map<String, dynamic>> items;
        final data = body['data'];
        if (data is Map<String, dynamic>) {
          items = (data['items'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .toList();
        } else if (data is List) {
          items = data.whereType<Map<String, dynamic>>().toList();
        } else {
          return [];
        }

        return items.map((e) {
          int? parseAmount(dynamic value) {
          if (value is num) return value.toInt();
          if (value == null) return null;
          final raw = value.toString().trim();
          if (raw.isEmpty) return null;
          return int.tryParse(raw);
          }

          final payment = e['payment'] is Map
            ? Map<String, dynamic>.from(e['payment'] as Map)
            : <String, dynamic>{};
          final paymentInfo = e['paymentInfo'] is Map
            ? Map<String, dynamic>.from(e['paymentInfo'] as Map)
            : <String, dynamic>{};
          final consultationPayment = e['consultationPayment'] is Map
            ? Map<String, dynamic>.from(e['consultationPayment'] as Map)
            : <String, dynamic>{};

          final resolvedFee =
            parseAmount(e['grossPrice']) ??
            parseAmount(e['feeCost']) ??
            parseAmount(e['fee']) ??
            parseAmount(e['amount']) ??
            parseAmount(e['scheduledConsultationFee']) ??
            parseAmount(e['emergencyConsultationFee']) ??
            parseAmount(payment['amount']) ??
            parseAmount(payment['feeCost']) ??
            parseAmount(paymentInfo['amount']) ??
            parseAmount(paymentInfo['feeCost']) ??
            parseAmount(consultationPayment['amount']) ??
            parseAmount(consultationPayment['feeCost']) ??
            0;

          final endpointType = (e['type'] ?? '').toString().toLowerCase();
          final endpointStatus = (e['status'] ?? '').toString().toLowerCase();

          String normalizedStatus;
          switch (endpointStatus) {
            case 'completed':
              normalizedStatus = 'Completed';
              break;
            case 'cancelled':
            case 'canceled':
              normalizedStatus = 'Cancelled';
              break;
            case 'expertabsent':
              normalizedStatus = 'ExpertAbsent';
              break;
            case 'expertabsenthandled':
              normalizedStatus = 'ExpertAbsentHandled';
              break;
            case 'pendingpayment':
              normalizedStatus = 'PendingPayment';
              break;
            case 'scheduled':
            case 'ongoing':
            default:
              normalizedStatus = 'Confirmed';
              break;
          }

          final normalized = <String, dynamic>{
            'id': (e['bookingId'] ?? e['consultationId'] ?? '').toString(),
            'consultationId': e['consultationId'],
            'roomId': e['roomId'],
            'userId': e['userId'],
            'userName': e['userName'],
            'userAvatarUrl': e['userAvatarUrl'] ?? e['patientAvatarUrl'],
            'expertId': '',
            'expertName': 'Chuyên gia',
            'consultationType': endpointType == 'emergency'
                ? 'Instant'
                : 'Scheduled',
            'scheduledTime': e['startTime'],
            'slotStartTime': e['slotStartTime'] ?? e['startTime'],
            'slotEndTime': e['slotEndTime'] ?? e['endTime'],
            'status': normalizedStatus,
            'feeCost': resolvedFee,
            'bookedAt': e['startTime'],
            'grossPrice': e['grossPrice'] ?? resolvedFee,
            'netPrice': e['netPrice'],
          };

          return ConsultationBookingResponse.fromJson(normalized);
        }).toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('❌ Failed to fetch expert bookings: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('❌ Unexpected error fetching expert bookings: $e');
      return [];
    }
  }
}
