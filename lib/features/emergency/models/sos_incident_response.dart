/// SOS Incident Response Model
/// Response model after creating emergency SOS incident
class SosIncidentResponse {
  final int statusCode;
  final String message;
  final bool isSuccess;
  final IncidentData? data;
  final dynamic error;

  SosIncidentResponse({
    required this.statusCode,
    required this.message,
    required this.isSuccess,
    this.data,
    this.error,
  });

  /// Create from JSON response
  factory SosIncidentResponse.fromJson(Map<String, dynamic> json) {
    return SosIncidentResponse(
      statusCode: json['status_code'] ?? 0,
      message: json['message'] ?? '',
      isSuccess: json['is_success'] ?? false,
      data: json['data'] != null ? IncidentData.fromJson(json['data']) : null,
      error: json['error'],
    );
  }

  @override
  String toString() => 'SosIncidentResponse(isSuccess: $isSuccess, message: $message)';
}

/// Incident Data
class IncidentData {
  final String id;
  final String userId;
  final LocationCoordinates locationCoordinates;
  final String? symptomsReport;
  final String status; // "Pending", "InProgress", "Completed", etc.
  final int currentSessionNumber;
  final int currentRadiusKm;
  final DateTime? lastSessionAt;
  final DateTime? assignedAt;
  final String? assignedRescuerId;
  final String? cancellationReason;
  final int severityLevel;
  final DateTime incidentOccurredAt;
  final List<IncidentSession> sessions;

  IncidentData({
    required this.id,
    required this.userId,
    required this.locationCoordinates,
    this.symptomsReport,
    required this.status,
    required this.currentSessionNumber,
    required this.currentRadiusKm,
    this.lastSessionAt,
    this.assignedAt,
    this.assignedRescuerId,
    this.cancellationReason,
    required this.severityLevel,
    required this.incidentOccurredAt,
    required this.sessions,
  });

  factory IncidentData.fromJson(Map<String, dynamic> json) {
    return IncidentData(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      locationCoordinates: LocationCoordinates.fromJson(json['locationCoordinates'] ?? {}),
      symptomsReport: json['symptomsReport'],
      status: json['status'] ?? 'Pending',
      currentSessionNumber: json['currentSessionNumber'] ?? 1,
      currentRadiusKm: json['currentRadiusKm'] ?? 5,
      lastSessionAt: json['lastSessionAt'] != null
          ? DateTime.parse(json['lastSessionAt'])
          : null,
      assignedAt: json['assignedAt'] != null
          ? DateTime.parse(json['assignedAt'])
          : null,
      assignedRescuerId: json['assignedRescuerId'],
      cancellationReason: json['cancellationReason'],
      severityLevel: json['severityLevel'] ?? 1,
      incidentOccurredAt: json['incidentOccurredAt'] != null
          ? DateTime.parse(json['incidentOccurredAt'])
          : DateTime.now(),
      sessions: (json['sessions'] as List<dynamic>?)
              ?.map((s) => IncidentSession.fromJson(s))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'locationCoordinates': locationCoordinates.toJson(),
    'symptomsReport': symptomsReport,
    'status': status,
    'currentSessionNumber': currentSessionNumber,
    'currentRadiusKm': currentRadiusKm,
    'lastSessionAt': lastSessionAt?.toIso8601String(),
    'assignedAt': assignedAt?.toIso8601String(),
    'assignedRescuerId': assignedRescuerId,
    'cancellationReason': cancellationReason,
    'severityLevel': severityLevel,
    'incidentOccurredAt': incidentOccurredAt.toIso8601String(),
    'sessions': sessions.map((s) => s.toJson()).toList(),
  };
}

/// Location Coordinates
class LocationCoordinates {
  final double latitude;
  final double longitude;

  LocationCoordinates({
    required this.latitude,
    required this.longitude,
  });

  factory LocationCoordinates.fromJson(Map<String, dynamic> json) {
    return LocationCoordinates(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}

/// Incident Session
class IncidentSession {
  final String id;
  final String incidentId;
  final int sessionNumber;
  final int radiusKm;
  final String status; // "Active", "Expired", "Completed"
  final DateTime createdAt;
  final String triggerType; // "Initial", "Timeout", "Manual"
  final int rescuersPinged;

  IncidentSession({
    required this.id,
    required this.incidentId,
    required this.sessionNumber,
    required this.radiusKm,
    required this.status,
    required this.createdAt,
    required this.triggerType,
    required this.rescuersPinged,
  });

  factory IncidentSession.fromJson(Map<String, dynamic> json) {
    return IncidentSession(
      id: json['id'] ?? '',
      incidentId: json['incidentId'] ?? '',
      sessionNumber: json['sessionNumber'] ?? 1,
      radiusKm: json['radiusKm'] ?? 5,
      status: json['status'] ?? 'Active',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      triggerType: json['triggerType'] ?? 'Initial',
      rescuersPinged: json['rescuersPinged'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'incidentId': incidentId,
    'sessionNumber': sessionNumber,
    'radiusKm': radiusKm,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'triggerType': triggerType,
    'rescuersPinged': rescuersPinged,
  };
}
