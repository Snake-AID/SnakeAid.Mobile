import 'snake_identification_response.dart';
import 'sos_incident_response.dart';

/// API Wrapper Response
class DetailedIncidentResponse {
  final int statusCode;
  final String message;
  final bool isSuccess;
  final DetailedIncidentData? data;
  final String? error;

  DetailedIncidentResponse({
    required this.statusCode,
    required this.message,
    required this.isSuccess,
    this.data,
    this.error,
  });

  factory DetailedIncidentResponse.fromJson(Map<String, dynamic> json) {
    return DetailedIncidentResponse(
      statusCode: json['status_code'] ?? 0,
      message: json['message'] ?? '',
      isSuccess: json['is_success'] ?? false,
      data: json['data'] != null
          ? DetailedIncidentData.fromJson(json['data'])
          : null,
      error: json['error'],
    );
  }

  @override
  String toString() =>
      'DetailedIncidentResponse(isSuccess: $isSuccess, message: $message)';
}

/// Main Incident Data with all related entities
class DetailedIncidentData {
  final String id;
  final GeoPointCoordinates locationCoordinates;
  final String? address;
  final List<ReportSymptom>? symptomsReport;
  final IncidentStatus status;

  // Assignment info
  final DateTime? assignedAt;
  final String? assignedRescuerId;
  final String? cancellationReason;
  final int severityLevel;
  final DateTime? incidentOccurredAt;

  // Rescue attempts tracking (legacy; now handled by dispatch center)
  final int totalRescueAttempts;
  final int failedAttemptsCount;

  // Related entities
  final BriefMemberProfile user;
  final BriefRescuerProfile? assignedRescuer;
  final RescueMission? activeMission;
  final List<SnakeAIDetectMedia> media;

  // Identification results
  final DetectedSnakeSpecies? identifiedSnakeSpecies;
  final SnakeIdentificationContext? identificationContext;

  DetailedIncidentData({
    required this.id,
    required this.locationCoordinates,
    this.address,
    this.symptomsReport,
    required this.status,
    this.assignedAt,
    this.assignedRescuerId,
    this.cancellationReason,
    required this.severityLevel,
    this.incidentOccurredAt,
    required this.totalRescueAttempts,
    required this.failedAttemptsCount,
    required this.user,
    this.assignedRescuer,
    this.activeMission,
    required this.media,
    this.identifiedSnakeSpecies,
    this.identificationContext,
  });

  factory DetailedIncidentData.fromJson(Map<String, dynamic> json) {
    return DetailedIncidentData(
      id: json['id'] ?? '',
      locationCoordinates: GeoPointCoordinates.fromJson(
        json['locationCoordinates'] ?? {},
      ),
      symptomsReport: (json['symptomsReport'] as List<dynamic>?)
          ?.map((s) => ReportSymptom.fromJson(s as Map<String, dynamic>))
          .toList(),
      status: IncidentStatus.fromString(json['status'] ?? 'Pending'),
      assignedAt: json['assignedAt'] != null
          ? DateTime.parse(json['assignedAt'])
          : null,
      assignedRescuerId: json['assignedRescuerId'],
      cancellationReason: json['cancellationReason'],
      severityLevel: json['severityLevel'] ?? 1,
      incidentOccurredAt: json['incidentOccurredAt'] != null
          ? DateTime.parse(json['incidentOccurredAt'])
          : null,
      address: json['address'],
      totalRescueAttempts: json['totalRescueAttempts'] ?? 0,
      failedAttemptsCount: json['failedAttemptsCount'] ?? 0,
      user: BriefMemberProfile.fromJson(json['user'] ?? {}),
      assignedRescuer: json['assignedRescuer'] != null
          ? BriefRescuerProfile.fromJson(json['assignedRescuer'])
          : null,
      activeMission: json['activeMission'] != null
          ? RescueMission.fromJson(json['activeMission'])
          : null,
      media:
          (json['media'] as List<dynamic>?)
              ?.map((m) => SnakeAIDetectMedia.fromJson(m))
              .toList() ??
          [],
      // Backend returns 'identifiedSnake' not 'identified_snake_species'
      identifiedSnakeSpecies: json['identifiedSnake'] != null
          ? DetectedSnakeSpecies.fromJson(json['identifiedSnake'])
          : null,
      // Backend returns 'identificationContext' not 'identification_context'
      identificationContext: json['identificationContext'] != null
          ? SnakeIdentificationContext.fromJson(json['identificationContext'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'locationCoordinates': locationCoordinates.toJson(),
    'address': address,
    'symptomsReport': symptomsReport?.map((s) => s.toJson()).toList(),
    'status': status.value,
    'assignedAt': assignedAt?.toIso8601String(),
    'assignedRescuerId': assignedRescuerId,
    'cancellationReason': cancellationReason,
    'severityLevel': severityLevel,
    'incidentOccurredAt': incidentOccurredAt?.toIso8601String(),
    'totalRescueAttempts': totalRescueAttempts,
    'failedAttemptsCount': failedAttemptsCount,
    'user': user.toJson(),
    'assignedRescuer': assignedRescuer?.toJson(),
    'activeMission': activeMission?.toJson(),
    'media': media.map((m) => m.toJson()).toList(),
    'identifiedSnake': identifiedSnakeSpecies?.toJson(),
    'identificationContext': identificationContext?.toJson(),
  };

  /// Check if rescuer is assigned
  bool get hasAssignedRescuer => assignedRescuer != null;

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

/// Snake AI Detect Media
class SnakeAIDetectMedia {
  final String id;
  final String mediaUrl;
  final MediaReferenceType referenceType;
  final MediaPurpose purpose;
  final bool isProcessed;
  final DateTime? processedAt;
  final int? sequenceOrder;
  final List<DetectedSnakeSpecies> detectedSpecies;

  SnakeAIDetectMedia({
    required this.id,
    required this.mediaUrl,
    required this.referenceType,
    required this.purpose,
    required this.isProcessed,
    this.processedAt,
    this.sequenceOrder,
    required this.detectedSpecies,
  });

  factory SnakeAIDetectMedia.fromJson(Map<String, dynamic> json) {
    return SnakeAIDetectMedia(
      id: json['id'] ?? '',
      mediaUrl: json['mediaUrl'] ?? '',
      referenceType: MediaReferenceType.fromString(
        json['referenceType'] ?? 'Incident',
      ),
      purpose: MediaPurpose.fromString(json['purpose'] ?? 'Evidence'),
      isProcessed: json['isProcessed'] ?? false,
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : null,
      sequenceOrder: json['sequenceOrder'],
      detectedSpecies:
          (json['detectedSpecies'] as List<dynamic>?)
              ?.map((s) => DetectedSnakeSpecies.fromJson(s))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'mediaUrl': mediaUrl,
    'referenceType': referenceType.value,
    'purpose': purpose.value,
    'isProcessed': isProcessed,
    'processedAt': processedAt?.toIso8601String(),
    'sequenceOrder': sequenceOrder,
    'detectedSpecies': detectedSpecies.map((s) => s.toJson()).toList(),
  };

  /// Check if has any detected species
  bool get hasDetectedSpecies => detectedSpecies.isNotEmpty;

  /// Get first detected species (highest confidence)
  DetectedSnakeSpecies? get primarySpecies =>
      detectedSpecies.isNotEmpty ? detectedSpecies.first : null;
}

/// Detected Snake Species (from AI recognition)
class DetectedSnakeSpecies {
  final int id;
  final String scientificName;
  final String slug;
  final String commonName;
  final String? imageUrl;
  final String? description;
  final String? identificationSummary;
  final VenomType primaryVenomType;
  final int riskLevel;
  final bool isVenomous;
  final bool isActive;

  DetectedSnakeSpecies({
    required this.id,
    required this.scientificName,
    required this.slug,
    required this.commonName,
    this.imageUrl,
    this.description,
    this.identificationSummary,
    required this.primaryVenomType,
    required this.riskLevel,
    required this.isVenomous,
    required this.isActive,
  });

  factory DetectedSnakeSpecies.fromJson(Map<String, dynamic> json) {
    return DetectedSnakeSpecies(
      id: json['id'] ?? 0,
      scientificName: json['scientificName'] ?? '',
      slug: json['slug'] ?? '',
      commonName: json['commonName'] ?? '',
      imageUrl: json['imageUrl'],
      description: json['description'],
      identificationSummary: json['identificationSummary'],
      primaryVenomType: VenomType.fromString(
        json['primaryVenomType'] ?? 'Neurotoxic',
      ),
      riskLevel: json['riskLevel'] ?? 0,
      isVenomous: json['isVenomous'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'scientificName': scientificName,
    'slug': slug,
    'commonName': commonName,
    'imageUrl': imageUrl,
    'description': description,
    'identificationSummary': identificationSummary,
    'primaryVenomType': primaryVenomType.value,
    'riskLevel': riskLevel,
    'isVenomous': isVenomous,
    'isActive': isActive,
  };

  /// Get risk level text in Vietnamese
  String get riskLevelText {
    if (riskLevel >= 8) return 'Cực kỳ nguy hiểm';
    if (riskLevel >= 6) return 'Rất Nguy hiểm';
    if (riskLevel >= 5) return 'Nguy hiểm';
    if (riskLevel > 4) return 'Trung bình';
    return 'Thấp';
  }
}

// ============================================================================
// ENUMS
// ============================================================================

/// Incident Status
enum IncidentStatus {
  pending('Pending'),
  searching('Searching'),
  assigned('Assigned'),
  inProgress('InProgress'),
  finished('Finished'),
  cancelled('Cancelled');

  final String value;
  const IncidentStatus(this.value);

  static IncidentStatus fromString(String value) {
    return IncidentStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => IncidentStatus.pending,
    );
  }

  String get displayText {
    switch (this) {
      case IncidentStatus.pending:
        return 'Chờ xử lý';
      case IncidentStatus.searching:
        return 'Đang tìm kiếm cứu hộ';
      case IncidentStatus.assigned:
        return 'Đã phân công';
      case IncidentStatus.inProgress:
        return 'Đang thực hiện';
      case IncidentStatus.finished:
        return 'Hoàn thành';
      case IncidentStatus.cancelled:
        return 'Đã hủy';
    }
  }
}

/// Rescuer Type
enum RescuerType {
  emergency('Emergency'),
  professional('Professional');

  final String value;
  const RescuerType(this.value);

  static RescuerType fromString(String value) {
    return RescuerType.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => RescuerType.emergency,
    );
  }

  String get displayText {
    switch (this) {
      case RescuerType.emergency:
        return 'Khẩn cấp';
      case RescuerType.professional:
        return 'Chuyên nghiệp';
    }
  }
}

/// Mission Status
enum MissionStatus {
  preparing('Preparing'),
  enRoute('EnRoute'),
  rescuerArrived('RescuerArrived'),
  missionCompleted('MissionCompleted'),
  missionUncompleted('MissionUncompleted'),
  missionAborted('MissionAborted'),
  cancelled('Cancelled');

  final String value;
  const MissionStatus(this.value);

  static MissionStatus fromString(String value) {
    return MissionStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => MissionStatus.preparing,
    );
  }

  String get displayText {
    switch (this) {
      case MissionStatus.preparing:
        return 'Đang chuẩn bị';
      case MissionStatus.enRoute:
        return 'Đang di chuyển';
      case MissionStatus.rescuerArrived:
        return 'Đã đến nơi';
      case MissionStatus.missionCompleted:
        return 'Hoàn thành';
      case MissionStatus.missionUncompleted:
        return 'Chưa hoàn thành';
      case MissionStatus.missionAborted:
        return 'Đã hủy bỏ';
      case MissionStatus.cancelled:
        return 'Đã hủy';
    }
  }
}

/// Media Reference Type
enum MediaReferenceType {
  communityReport('CommunityReport'),
  snakebiteIncident('SnakebiteIncident'),
  rescueMission('RescueMission'),
  snakeCatchingRequest('SnakeCatchingRequest'),
  snakeCatchingMission('SnakeCatchingMission');

  final String value;
  const MediaReferenceType(this.value);

  static MediaReferenceType fromString(String value) {
    return MediaReferenceType.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => MediaReferenceType.snakebiteIncident,
    );
  }
}

/// Media Purpose
enum MediaPurpose {
  evidence('Evidence'),
  snakeIdentification('SnakeIdentification'),
  locationProof('LocationProof'),
  injuryPhoto('InjuryPhoto'),
  beforeAfter('BeforeAfter'),
  snakeOthers('SnakeOthers');

  final String value;
  const MediaPurpose(this.value);

  static MediaPurpose fromString(String value) {
    return MediaPurpose.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => MediaPurpose.evidence,
    );
  }
}

/// Venom Type
enum VenomType {
  neurotoxic('Neurotoxic'),
  hemotoxic('Hemotoxic'),
  cytotoxic('Cytotoxic'),
  cardiotoxic('Cardiotoxic'),
  myotoxic('Myotoxic'),
  none('None');

  final String value;
  const VenomType(this.value);

  static VenomType fromString(String value) {
    return VenomType.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => VenomType.none,
    );
  }

  String get displayText {
    switch (this) {
      case VenomType.neurotoxic:
        return 'Độc thần kinh';
      case VenomType.hemotoxic:
        return 'Độc huyết';
      case VenomType.cytotoxic:
        return 'Độc tế bào';
      case VenomType.cardiotoxic:
        return 'Độc tim';
      case VenomType.myotoxic:
        return 'Độc cơ';
      case VenomType.none:
        return 'Không độc';
    }
  }
}
