/// Booking status values returned by the backend
enum ConsultationBookingStatus {
  pendingPayment, // Chờ thanh toán
  confirmed,      // Đã xác nhận
  completed,      // Đã hoàn thành
  cancelled,      // Đã hủy
}

/// Response DTO for a consultation booking
/// Maps backend `ConsultationBookingResponse`
class ConsultationBookingResponse {
  final String id;
  final String? userId;
  final String expertId;
  final String expertName;
  final String? expertAvatarUrl;
  final String? expertSpecialty;
  final String consultationType; // "Scheduled" | "Instant"
  final DateTime scheduledTime;
  final ConsultationBookingStatus status;
  final int feeCost;
  final String? timeSlotId;
  final double? rating;
  // Fields from create-booking response
  final String? consultationId;  // ID for the video call room
  final String? roomId;          // LiveKit room ID
  final DateTime? slotStartTime;
  final DateTime? slotEndTime;
  final DateTime? paymentDeadline;
  final String? userName;             // Patient name (from expert's view)
  final String? problemDescription;  // Problem submitted by patient
  final DateTime? bookedAt;
  final int? grossPrice;
  final int? netPrice;

  const ConsultationBookingResponse({
    required this.id,
    this.userId,
    required this.expertId,
    required this.expertName,
    this.expertAvatarUrl,
    this.expertSpecialty,
    required this.consultationType,
    required this.scheduledTime,
    required this.status,
    required this.feeCost,
    this.timeSlotId,
    this.rating,
    this.consultationId,
    this.roomId,
    this.slotStartTime,
    this.slotEndTime,
    this.paymentDeadline,
    this.userName,
    this.problemDescription,
    this.bookedAt,
    this.grossPrice,
    this.netPrice,
  });

  static DateTime? _parseBackendDate(dynamic value) {
    if (value == null) return null;
    final raw = value.toString();
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return null;

    // Backend currently sends VN wall-clock timestamps with UTC suffix (Z).
    // Keep the clock fields as-is to avoid +7h shift on mobile UI.
    final isUtcTagged = raw.endsWith('Z') || raw.contains('+00:00');
    if (isUtcTagged) {
      final utc = parsed.toUtc();
      return DateTime(
        utc.year,
        utc.month,
        utc.day,
        utc.hour,
        utc.minute,
        utc.second,
        utc.millisecond,
        utc.microsecond,
      );
    }

    return parsed;
  }

  factory ConsultationBookingResponse.fromJson(Map<String, dynamic> json) {
    DateTime? slotStart = _parseBackendDate(json['slotStartTime']);
    return ConsultationBookingResponse(
      id: (json['id'] ?? '').toString(),
      userId: json['userId'] as String?,
      expertId: (json['expertId'] ?? '').toString(),
      expertName: (json['expertName'] as String?) ?? 'Chuyên gia',
      expertAvatarUrl: json['expertAvatarUrl'] as String?,
      expertSpecialty: (json['expertSpecialty'] ?? json['specialization']) as String?,
      consultationType: (json['consultationType'] as String?) ?? 'Scheduled',
      scheduledTime: slotStart ??
          (_parseBackendDate(json['bookedAt']) ??
              (_parseBackendDate(json['scheduledTime']) ?? DateTime.now())),
      status: _parseStatus(json['status'] as String?),
      feeCost: (json['grossPrice'] as num?)?.toInt() ??
          (json['grossAmount'] as num?)?.toInt() ??
          (json['feeCost'] as num?)?.toInt() ??
          (json['fee'] as num?)?.toInt() ??
          (json['price'] as num?)?.toInt() ??
          0,
      timeSlotId: (json['timeSlotId'] as String?),
      rating: (json['rating'] as num?)?.toDouble(),
      consultationId: json['consultationId'] as String?,
      roomId: json['roomId'] as String?,
      slotStartTime: slotStart,
      slotEndTime: _parseBackendDate(json['slotEndTime']),
      paymentDeadline: _parseBackendDate(json['paymentDeadline']),
      userName: json['userName'] as String?,
      problemDescription: json['problemDescription'] as String?,
      bookedAt: _parseBackendDate(json['bookedAt']),
      grossPrice: (json['grossPrice'] as num?)?.toInt() ??
          (json['grossAmount'] as num?)?.toInt(),
      netPrice: (json['netPrice'] as num?)?.toInt() ??
          (json['netAmount'] as num?)?.toInt(),
    );
  }

  static ConsultationBookingStatus _parseStatus(String? s) {
    switch (s) {
      case 'PendingPayment':
        return ConsultationBookingStatus.pendingPayment;
      case 'Confirmed':
        return ConsultationBookingStatus.confirmed;
      case 'Completed':
        return ConsultationBookingStatus.completed;
      case 'Cancelled':
        return ConsultationBookingStatus.cancelled;
      default:
        return ConsultationBookingStatus.confirmed;
    }
  }
}

/// Request DTO for creating a new consultation booking
/// API: POST /api/consultations/scheduled
class CreateConsultationBookingRequest {
  final String timeSlotId;
  final String problemDescription;

  const CreateConsultationBookingRequest({
    required this.timeSlotId,
    required this.problemDescription,
  });

  Map<String, dynamic> toJson() => {
        'timeSlotId': timeSlotId,
        'problemDescription': problemDescription,
      };
}
