import 'package:snakeaid_mobile/features/emergency/models/detailed_incident_response.dart';

import 'sos_incident_response.dart';

/// API Wrapper Response
class ListIncidentResponse {
  final int statusCode;
  final String message;
  final bool isSuccess;
  final ListIncidentData? data;
  final String? error;

  ListIncidentResponse({
    required this.statusCode,
    required this.message,
    required this.isSuccess,
    this.data,
    this.error,
  });

  factory ListIncidentResponse.fromJson(Map<String, dynamic> json) {
    return ListIncidentResponse(
      statusCode: json['status_code'] ?? 0,
      message: json['message'] ?? '',
      isSuccess: json['is_success'] ?? false,
      data: json['data'] != null
          ? ListIncidentData.fromJson(json['data'])
          : null,
      error: json['error'],
    );
  }

  @override
  String toString() =>
      'ListIncidentResponse(isSuccess: $isSuccess, message: $message)';
}

/// Paged Incident Response (API wrapper for listing endpoints)
class PagedIncidentListResponse {
  final int statusCode;
  final String message;
  final bool isSuccess;
  final PagedIncidentListData? data;
  final String? error;

  PagedIncidentListResponse({
    required this.statusCode,
    required this.message,
    required this.isSuccess,
    this.data,
    this.error,
  });

  factory PagedIncidentListResponse.fromJson(Map<String, dynamic> json) {
    return PagedIncidentListResponse(
      statusCode: json['status_code'] ?? 0,
      message: json['message'] ?? '',
      isSuccess: json['is_success'] ?? false,
      data: json['data'] != null
          ? PagedIncidentListData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      error: json['error'],
    );
  }

  @override
  String toString() =>
      'PagedIncidentListResponse(isSuccess: $isSuccess, message: $message)';
}

/// Main Incident Data with all related entities
class ListIncidentData {
  final String id;
  final GeoPointCoordinates locationCoordinates;
  final String? address;
  final List<ReportSymptom>? symptomsReport;
  final IncidentStatus status;

  final int severityLevel;
  final DateTime? incidentOccurredAt;

  final RescueMission? activeMission;

  ListIncidentData({
    required this.id,
    required this.locationCoordinates,
    this.address,
    this.symptomsReport,
    required this.status,
    required this.severityLevel,
    this.incidentOccurredAt,
    this.activeMission,
  });

  factory ListIncidentData.fromJson(Map<String, dynamic> json) {
    return ListIncidentData(
      id: json['id'] ?? '',
      locationCoordinates: GeoPointCoordinates.fromJson(
        json['locationCoordinates'] ?? {},
      ),
      symptomsReport: (json['symptomsReport'] as List<dynamic>?)
          ?.map((s) => ReportSymptom.fromJson(s as Map<String, dynamic>))
          .toList(),
      status: IncidentStatus.fromString(json['status'] ?? 'Pending'),
      severityLevel: json['severityLevel'] ?? 1,
      incidentOccurredAt: json['incidentOccurredAt'] != null
          ? DateTime.parse(json['incidentOccurredAt'])
          : null,
      address: json['address'],
      activeMission: json['activeMission'] != null
          ? RescueMission.fromJson(json['activeMission'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'locationCoordinates': locationCoordinates.toJson(),
    'address': address,
    'symptomsReport': symptomsReport?.map((s) => s.toJson()).toList(),
    'status': status.value,
    'severityLevel': severityLevel,
    'incidentOccurredAt': incidentOccurredAt?.toIso8601String(),
    'activeMission': activeMission?.toJson(),
  };

  /// Check if mission exists
  bool get hasMission => activeMission != null;

  /// Get severity text in Vietnamese
  String get severityText {
    if (severityLevel >= 4) return 'Nghiêm trọng';
    if (severityLevel >= 3) return 'Cao';
    if (severityLevel >= 2) return 'Trung bình';
    return 'Thấp';
  }
}

/// Pagination metadata for paged incident responses
class PaginationMeta {
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  PaginationMeta({
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: (json['page'] as int?) ?? 1,
      pageSize: (json['pageSize'] as int?) ?? 10,
      totalItems: (json['totalItems'] as int?) ?? 0,
      totalPages: (json['totalPages'] as int?) ?? 0,
    );
  }
}

/// Paged incident list response data
class PagedIncidentListData {
  final List<ListIncidentData> items;
  final PaginationMeta meta;

  PagedIncidentListData({required this.items, required this.meta});

  factory PagedIncidentListData.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'];
    final metaJson = json['meta'];

    final items =
        (itemsJson as List<dynamic>?)
            ?.map((e) => ListIncidentData.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return PagedIncidentListData(
      items: items,
      meta: PaginationMeta.fromJson(metaJson as Map<String, dynamic>? ?? {}),
    );
  }
}

/// Geo Point Coordinates
class GeoPointCoordinates {
  final double latitude;
  final double longitude;

  GeoPointCoordinates({required this.latitude, required this.longitude});

  factory GeoPointCoordinates.fromJson(Map<String, dynamic> json) {
    return GeoPointCoordinates(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}

/// Brief Member Profile (Victim/User)
class BriefMemberProfile {
  final String accountId;
  final String? userName;
  final String? email;
  final String? phoneNumber;
  final double rating;
  final int ratingCount;
  final List<String> emergencyContacts;
  final bool hasUnderlyingDisease;
  final UserInfo? account;

  BriefMemberProfile({
    required this.accountId,
    this.userName,
    this.email,
    this.phoneNumber,
    required this.rating,
    required this.ratingCount,
    required this.emergencyContacts,
    required this.hasUnderlyingDisease,
    this.account,
  });

  factory BriefMemberProfile.fromJson(Map<String, dynamic> json) {
    return BriefMemberProfile(
      accountId: json['accountId'] ?? '',
      userName: json['userName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      emergencyContacts:
          (json['emergencyContacts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      hasUnderlyingDisease: json['hasUnderlyingDisease'] ?? false,
      account: json['account'] != null
          ? UserInfo.fromJson(json['account'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'accountId': accountId,
    'userName': userName,
    'email': email,
    'phoneNumber': phoneNumber,
    'rating': rating,
    'ratingCount': ratingCount,
    'emergencyContacts': emergencyContacts,
    'hasUnderlyingDisease': hasUnderlyingDisease,
    'account': account?.toJson(),
  };
}

/// Brief Rescuer Profile
class BriefRescuerProfile {
  final String accountId;
  final bool isOnline;
  final double rating;
  final int ratingCount;
  final String? phoneNumber;
  final RescuerType type;
  final GeoPointCoordinates? lastLocation;
  final DateTime? lastLocationUpdate;
  final int totalMissions;
  final int completedMissions;
  final UserInfo? account;

  BriefRescuerProfile({
    required this.accountId,
    required this.isOnline,
    required this.rating,
    required this.ratingCount,
    required this.type,
    this.phoneNumber,
    this.lastLocation,
    this.lastLocationUpdate,
    required this.totalMissions,
    required this.completedMissions,
    this.account,
  });

  factory BriefRescuerProfile.fromJson(Map<String, dynamic> json) {
    return BriefRescuerProfile(
      accountId: json['accountId'] ?? '',
      isOnline: json['isOnline'] ?? false,
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      type: RescuerType.fromString(json['type'] ?? 'Emergency'),
      phoneNumber: json['phoneNumber'],
      lastLocation: json['lastLocation'] != null
          ? GeoPointCoordinates.fromJson(json['lastLocation'])
          : null,
      lastLocationUpdate: json['lastLocationUpdate'] != null
          ? DateTime.parse(json['lastLocationUpdate'])
          : null,
      totalMissions: json['totalMissions'] ?? 0,
      completedMissions: json['completedMissions'] ?? 0,
      account: json['account'] != null
          ? UserInfo.fromJson(json['account'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'accountId': accountId,
    'isOnline': isOnline,
    'rating': rating,
    'ratingCount': ratingCount,
    'phoneNumber': phoneNumber,
    'type': type.value,
    'lastLocation': lastLocation?.toJson(),
    'lastLocationUpdate': lastLocationUpdate?.toIso8601String(),
    'totalMissions': totalMissions,
    'completedMissions': completedMissions,
    'account': account?.toJson(),
  };

  /// Get success rate percentage
  double get successRate {
    if (totalMissions == 0) return 0.0;
    return (completedMissions / totalMissions) * 100;
  }
}

/// User Info (Account details)
class UserInfo {
  final String id;
  final String? fullName;
  final String? phoneNumber;
  final String? email;
  final String? avatarUrl;
  final String? role;
  final bool isActive;

  UserInfo({
    required this.id,
    this.fullName,
    this.phoneNumber,
    this.email,
    this.avatarUrl,
    this.role,
    this.isActive = true,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? '',
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      role: json['role'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'email': email,
    'avatarUrl': avatarUrl,
    'role': role,
    'isActive': isActive,
  };
}

/// Rescue Mission
class RescueMission {
  final String id;
  final String incidentId;
  final String rescuerId;
  final MissionStatus status;
  final double price;
  final DateTime? startedAt;
  final DateTime? arrivedAt;
  final DateTime? completedAt;
  final String? notes;
  final String? cancellationReason;
  final double? estimatedCost;
  final double? actualCost;

  RescueMission({
    required this.id,
    required this.incidentId,
    required this.rescuerId,
    required this.status,
    required this.price,
    this.startedAt,
    this.arrivedAt,
    this.completedAt,
    this.notes,
    this.cancellationReason,
    this.estimatedCost,
    this.actualCost,
  });

  factory RescueMission.fromJson(Map<String, dynamic> json) {
    return RescueMission(
      id: json['id'] ?? '',
      incidentId: json['incidentId'] ?? '',
      rescuerId: json['rescuerId'] ?? '',
      status: MissionStatus.fromString(json['status'] ?? 'Preparing'),
      price: (json['price'] ?? 0.0).toDouble(),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : null,
      arrivedAt: json['arrivedAt'] != null
          ? DateTime.parse(json['arrivedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      notes: json['notes'],
      cancellationReason: json['cancellationReason'],
      estimatedCost: json['estimatedCost'] != null
          ? (json['estimatedCost'] as num).toDouble()
          : null,
      actualCost: json['actualCost'] != null
          ? (json['actualCost'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'incidentId': incidentId,
    'rescuerId': rescuerId,
    'status': status.value,
    'price': price,
    'startedAt': startedAt?.toIso8601String(),
    'arrivedAt': arrivedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'notes': notes,
    'cancellationReason': cancellationReason,
    'estimatedCost': estimatedCost,
    'actualCost': actualCost,
  };

  /// Get mission duration in minutes
  int? get durationMinutes {
    if (startedAt != null && completedAt != null) {
      return completedAt!.difference(startedAt!).inMinutes;
    }
    return null;
  }

  /// Get formatted price in VND
  String get formattedPrice {
    return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }
}
