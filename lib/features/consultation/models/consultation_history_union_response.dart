import 'my_consultation_response.dart';

enum ConsultationHistoryKind {
  consultation,
  instant,
}

enum InstantRequestStatus {
  declinedByExpert,
  expired,
  unknown,
}

InstantRequestStatus parseInstantRequestStatus(String? value) {
  switch ((value ?? '').trim().toLowerCase()) {
    case 'declinedbyexpert':
      return InstantRequestStatus.declinedByExpert;
    case 'expired':
      return InstantRequestStatus.expired;
    default:
      return InstantRequestStatus.unknown;
  }
}

DateTime? _parseInstantDate(dynamic value) {
  if (value == null) return null;
  final raw = value.toString();
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return null;
  return parsed.toLocal();
}

class ConsultationHistoryMeta {
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  const ConsultationHistoryMeta({
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  bool get hasNextPage => currentPage < totalPages;

  factory ConsultationHistoryMeta.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, int fallback) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    return ConsultationHistoryMeta(
      currentPage: parseInt(
        json['currentPage'] ?? json['current_page'],
        1,
      ),
      pageSize: parseInt(
        json['pageSize'] ?? json['page_size'],
        10,
      ),
      totalItems: parseInt(
        json['totalItems'] ?? json['total_items'],
        0,
      ),
      totalPages: parseInt(
        json['totalPages'] ?? json['total_pages'],
        1,
      ),
    );
  }
}

class PagedHistoryResponse<T> {
  final List<T> items;
  final ConsultationHistoryMeta meta;

  const PagedHistoryResponse({required this.items, required this.meta});

  factory PagedHistoryResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemBuilder,
  ) {
    final itemsRaw = (json['items'] as List<dynamic>? ?? const []);
    final metaRaw = json['meta'] as Map<String, dynamic>? ?? const {};

    return PagedHistoryResponse(
      items: itemsRaw
          .whereType<Map<String, dynamic>>()
          .map(itemBuilder)
          .toList(),
      meta: ConsultationHistoryMeta.fromJson(metaRaw),
    );
  }
}

class MemberInstantConsultationHistory {
  final String instantRequestId;
  final String expertId;
  final String expertName;
  final String? expertAvatarUrl;
  final InstantRequestStatus requestStatus;
  final String type;
  final DateTime? requestedAt;
  final DateTime? respondedAt;

  const MemberInstantConsultationHistory({
    required this.instantRequestId,
    required this.expertId,
    required this.expertName,
    this.expertAvatarUrl,
    required this.requestStatus,
    required this.type,
    this.requestedAt,
    this.respondedAt,
  });

  factory MemberInstantConsultationHistory.fromJson(
    Map<String, dynamic> json,
  ) {
    return MemberInstantConsultationHistory(
      instantRequestId: (json['instantRequestId'] ?? '').toString(),
      expertId: (json['expertId'] ?? '').toString(),
      expertName: (json['expertName'] ?? 'Chuyen gia').toString(),
      expertAvatarUrl: json['expertAvatarUrl']?.toString(),
      requestStatus: parseInstantRequestStatus(
        json['requestStatus']?.toString(),
      ),
      type: (json['type'] ?? 'Emergency').toString(),
      requestedAt: _parseInstantDate(json['requestedAt']),
      respondedAt: _parseInstantDate(json['respondedAt']),
    );
  }
}

class ExpertInstantConsultationHistory {
  final String instantRequestId;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final InstantRequestStatus requestStatus;
  final String type;
  final DateTime? requestedAt;
  final DateTime? respondedAt;

  const ExpertInstantConsultationHistory({
    required this.instantRequestId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.requestStatus,
    required this.type,
    this.requestedAt,
    this.respondedAt,
  });

  factory ExpertInstantConsultationHistory.fromJson(
    Map<String, dynamic> json,
  ) {
    return ExpertInstantConsultationHistory(
      instantRequestId: (json['instantRequestId'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      userName: (json['userName'] ?? 'Bệnh nhân').toString(),
      userAvatarUrl: json['userAvatarUrl']?.toString(),
      requestStatus: parseInstantRequestStatus(
        json['requestStatus']?.toString(),
      ),
      type: (json['type'] ?? 'Emergency').toString(),
      requestedAt: _parseInstantDate(json['requestedAt']),
      respondedAt: _parseInstantDate(json['respondedAt']),
    );
  }
}

class ExpertConsultationHistoryResponse {
  final String consultationId;
  final MyConsultationType type;
  final MyConsultationStatus status;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String? roomId;
  final DateTime? startTime;
  final DateTime? endTime;
  final double? grossPrice;
  final double? netPrice;
  final String? emergencyRequestId;

  const ExpertConsultationHistoryResponse({
    required this.consultationId,
    required this.type,
    required this.status,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    this.roomId,
    this.startTime,
    this.endTime,
    this.grossPrice,
    this.netPrice,
    this.emergencyRequestId,
  });

  factory ExpertConsultationHistoryResponse.fromJson(
    Map<String, dynamic> json,
  ) {
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
        case 'expertabsenthandled':
          return MyConsultationStatus.expertAbsentHandled;
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

    return ExpertConsultationHistoryResponse(
      consultationId: (json['consultationId'] ?? '').toString(),
      type: type,
      status: parseStatus(json['status']?.toString()),
      userId: (json['userId'] ?? '').toString(),
      userName: (json['userName'] ?? 'Bệnh nhân').toString(),
      userAvatarUrl: json['userAvatarUrl']?.toString(),
      roomId: json['roomId']?.toString(),
      startTime: parseDate(
        json['startTime'],
        treatUtcAsWallClock: treatUtcAsWallClock,
      ),
      endTime: parseDate(
        json['endTime'],
        treatUtcAsWallClock: treatUtcAsWallClock,
      ),
      grossPrice: (json['grossPrice'] as num?)?.toDouble() ??
          (json['grossAmount'] as num?)?.toDouble(),
      netPrice: (json['netPrice'] as num?)?.toDouble() ??
          (json['netAmount'] as num?)?.toDouble(),
      emergencyRequestId: json['emergencyRequestId']?.toString(),
    );
  }
}

class MemberConsultationHistoryUnion {
  final ConsultationHistoryKind kind;
  final Map<String, dynamic> raw;

  const MemberConsultationHistoryUnion({
    required this.kind,
    required this.raw,
  });

  factory MemberConsultationHistoryUnion.fromJson(Map<String, dynamic> json) {
    final kindValue = (json['kind'] ?? '').toString().toLowerCase();
    final kind = kindValue == 'instant'
        ? ConsultationHistoryKind.instant
        : ConsultationHistoryKind.consultation;

    return MemberConsultationHistoryUnion(kind: kind, raw: json);
  }
}

class ExpertConsultationHistoryUnion {
  final ConsultationHistoryKind kind;
  final Map<String, dynamic> raw;

  const ExpertConsultationHistoryUnion({
    required this.kind,
    required this.raw,
  });

  factory ExpertConsultationHistoryUnion.fromJson(Map<String, dynamic> json) {
    final kindValue = (json['kind'] ?? '').toString().toLowerCase();
    final kind = kindValue == 'instant'
        ? ConsultationHistoryKind.instant
        : ConsultationHistoryKind.consultation;

    return ExpertConsultationHistoryUnion(kind: kind, raw: json);
  }
}
