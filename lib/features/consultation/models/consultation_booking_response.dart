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

  const ConsultationBookingResponse({
    required this.id,
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
  });

  factory ConsultationBookingResponse.fromJson(Map<String, dynamic> json) {
    DateTime? slotStart = json['slotStartTime'] != null
        ? DateTime.parse(json['slotStartTime'] as String)
        : null;
    return ConsultationBookingResponse(
      id: (json['id'] ?? '').toString(),
      expertId: (json['expertId'] ?? '').toString(),
      expertName: (json['expertName'] as String?) ?? 'Chuyên gia',
      expertAvatarUrl: json['expertAvatarUrl'] as String?,
      expertSpecialty: (json['expertSpecialty'] ?? json['specialization']) as String?,
      consultationType: (json['consultationType'] as String?) ?? 'Scheduled',
      scheduledTime: slotStart ??
          (json['bookedAt'] != null
              ? DateTime.parse(json['bookedAt'] as String)
              : (json['scheduledTime'] != null
                  ? DateTime.parse(json['scheduledTime'] as String)
                  : DateTime.now())),
      status: _parseStatus(json['status'] as String?),
      feeCost: (json['price'] as num?)?.toInt() ??
          (json['feeCost'] as num?)?.toInt() ??
          (json['fee'] as num?)?.toInt() ??
          0,
      timeSlotId: (json['timeSlotId'] as String?),
      rating: (json['rating'] as num?)?.toDouble(),
      consultationId: json['consultationId'] as String?,
      roomId: json['roomId'] as String?,
      slotStartTime: slotStart,
      slotEndTime: json['slotEndTime'] != null
          ? DateTime.parse(json['slotEndTime'] as String)
          : null,
      paymentDeadline: json['paymentDeadline'] != null
          ? DateTime.parse(json['paymentDeadline'] as String)
          : null,
      userName: json['userName'] as String?,
      problemDescription: json['problemDescription'] as String?,
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
/// API: POST /api/v1/consultation-bookings
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
