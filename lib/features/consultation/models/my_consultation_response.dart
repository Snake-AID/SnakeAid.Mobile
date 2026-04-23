enum MyConsultationType {
  scheduled,
  emergency,
}

enum MyConsultationStatus {
  scheduled,
  ongoing,
  completed,
  cancelled,
  userAbsent,
  expertAbsent,
  allAbsent,
}

class MyConsultationResponse {
  final String consultationId;
  final MyConsultationType type;
  final MyConsultationStatus status;
  final String expertId;
  final String expertName;
  final String? roomId;
  final DateTime? startTime;
  final DateTime? endTime;
  final double? grossPrice;
  final double? netPrice;
  final String? problemDescription;
  final String? customerReport;
  final DateTime? customerReportSubmittedAt;
  final String? bookingId;
  final DateTime? slotStartTime;
  final DateTime? slotEndTime;
  final String? emergencyRequestId;

  const MyConsultationResponse({
    required this.consultationId,
    required this.type,
    required this.status,
    required this.expertId,
    required this.expertName,
    this.roomId,
    this.startTime,
    this.endTime,
    this.grossPrice,
    this.netPrice,
    this.problemDescription,
    this.customerReport,
    this.customerReportSubmittedAt,
    this.bookingId,
    this.slotStartTime,
    this.slotEndTime,
    this.emergencyRequestId,
  });

  factory MyConsultationResponse.fromJson(Map<String, dynamic> json) {
    MyConsultationType parseType(String? value) {
      switch ((value ?? '').toLowerCase()) {
        case 'emergency':
          return MyConsultationType.emergency;
        case 'scheduled':
        default:
          return MyConsultationType.scheduled;
      }
    }

    MyConsultationStatus parseStatus(String? value) {
      switch ((value ?? '').toLowerCase()) {
        case 'scheduled':
          return MyConsultationStatus.scheduled;
        case 'cancelled':
        case 'canceled':
          return MyConsultationStatus.cancelled;
        case 'userabsent':
          return MyConsultationStatus.userAbsent;
        case 'expertabsent':
          return MyConsultationStatus.expertAbsent;
        case 'allabsent':
          return MyConsultationStatus.allAbsent;
        case 'completed':
          return MyConsultationStatus.completed;
        case 'ongoing':
        default:
          return MyConsultationStatus.ongoing;
      }
    }

    DateTime? parseDate(
      dynamic value, {
      required bool treatUtcAsWallClock,
    }) {
      if (value == null) return null;
      final raw = value.toString();
      final parsed = DateTime.tryParse(raw);
      if (parsed == null) return null;

      final isUtcTagged = raw.endsWith('Z') || raw.contains('+00:00');
      if (!isUtcTagged) return parsed;

      // Scheduled slots from backend are currently VN wall-clock values tagged as UTC.
      // Emergency timestamps are real UTC and must be converted to local time.
      if (treatUtcAsWallClock) {
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

      return parsed.toLocal();
    }

    final type = parseType(json['type']?.toString());
    final treatUtcAsWallClock = type == MyConsultationType.scheduled;

    return MyConsultationResponse(
      consultationId: (json['consultationId'] ?? '').toString(),
      type: type,
      status: parseStatus(json['status']?.toString()),
      expertId: (json['expertId'] ?? '').toString(),
      expertName: (json['expertName'] ?? 'Chuyen gia').toString(),
      roomId: json['roomId']?.toString(),
      startTime: parseDate(
        json['startTime'],
        treatUtcAsWallClock: treatUtcAsWallClock,
      ),
      endTime: parseDate(
        json['endTime'],
        treatUtcAsWallClock: treatUtcAsWallClock,
      ),
      grossPrice: (json['grossPrice'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble(),
      netPrice: (json['netPrice'] as num?)?.toDouble(),
      problemDescription: json['problemDescription']?.toString(),
      customerReport: json['customerReport']?.toString(),
      customerReportSubmittedAt: parseDate(
        json['customerReportSubmittedAt'],
        treatUtcAsWallClock: treatUtcAsWallClock,
      ),
      bookingId: json['bookingId']?.toString(),
      slotStartTime: parseDate(
        json['slotStartTime'],
        treatUtcAsWallClock: treatUtcAsWallClock,
      ),
      slotEndTime: parseDate(
        json['slotEndTime'],
        treatUtcAsWallClock: treatUtcAsWallClock,
      ),
      emergencyRequestId: json['emergencyRequestId']?.toString(),
    );
  }
}
