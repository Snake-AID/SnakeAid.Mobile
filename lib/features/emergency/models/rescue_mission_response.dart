import 'package:json_annotation/json_annotation.dart';
import 'package:snakeaid_mobile/features/emergency/models/snake_identification_response.dart';
import 'detailed_incident_response.dart';
import 'report_media_response.dart';
import 'sos_incident_response.dart';

part 'rescue_mission_response.g.dart';

/// Mission Detail API Response (with envelope)
/// Wraps DetailRescueMissionResponse with status info
class MissionDetailResponse {
  final int statusCode;
  final String message;
  final bool isSuccess;
  final DetailRescueMissionResponse? data;
  final dynamic error;

  MissionDetailResponse({
    required this.statusCode,
    required this.message,
    required this.isSuccess,
    this.data,
    this.error,
  });

  factory MissionDetailResponse.fromJson(Map<String, dynamic> json) {
    return MissionDetailResponse(
      statusCode: json['status_code'] ?? 0,
      message: json['message'] ?? '',
      isSuccess: json['is_success'] ?? false,
      data: json['data'] != null
          ? DetailRescueMissionResponse.fromJson(json['data'])
          : null,
      error: json['error'],
    );
  }
}

/// Detail Rescue Mission Response
/// Full mission data for rescuer mission detail screen
@JsonSerializable(explicitToJson: true)
class DetailRescueMissionResponse {
  // Mission basic info
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'incidentId')
  final String incidentId;

  @JsonKey(name: 'rescuerId')
  final String rescuerId;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'price')
  final double price;

  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  @JsonKey(name: 'startedAt')
  final DateTime? startedAt;

  @JsonKey(name: 'arrivedAt')
  final DateTime? arrivedAt;

  @JsonKey(name: 'completedAt')
  final DateTime? completedAt;

  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  // Mission details
  @JsonKey(name: 'notes')
  final String? notes;

  @JsonKey(name: 'cancellationReason')
  final String? cancellationReason;

  // Cost tracking
  @JsonKey(name: 'estimatedCost')
  final double? estimatedCost;

  @JsonKey(name: 'actualCost')
  final double? actualCost;

  // Distance from rescuer to incident (calculated on demand)
  @JsonKey(name: 'distanceFromCenterKm')
  final double? distanceFromCenterKm;

  @JsonKey(name: 'costFromCenter')
  final double? costFromCenter;

  // Related entities
  @JsonKey(name: 'incident')
  final BriefIncidentForMission incident;

  @JsonKey(name: 'rescuer')
  final BriefRescuerProfile rescuer;

  @JsonKey(name: 'user')
  final BriefMemberProfile user;

  @JsonKey(name: 'missionMedia')
  final List<ReportMediaResponse> missionMedia;

  DetailRescueMissionResponse({
    required this.id,
    required this.incidentId,
    required this.rescuerId,
    required this.status,
    required this.price,
    required this.createdAt,
    this.startedAt,
    this.arrivedAt,
    this.completedAt,
    this.updatedAt,
    this.notes,
    this.cancellationReason,
    this.estimatedCost,
    this.actualCost,
    this.distanceFromCenterKm,
    this.costFromCenter,
    required this.incident,
    required this.rescuer,
    required this.user,
    required this.missionMedia,
  });

  factory DetailRescueMissionResponse.fromJson(Map<String, dynamic> json) =>
      _$DetailRescueMissionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DetailRescueMissionResponseToJson(this);

  // Computed properties
  MissionStatus get missionStatus => MissionStatus.fromString(status);

  String get formattedPrice =>
      '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ';

  String get formattedActualCost => actualCost == null
      ? "0 VNĐ"
      : '${actualCost!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ';

  String get formattedCostFromCenter => costFromCenter == null
      ? "0 VNĐ"
      : '${costFromCenter!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ';

  String get formattedMissionId {
    final idStr = id.toString().replaceAll('-', '');

    final last6 = idStr.length >= 6
        ? idStr.substring(idStr.length - 6)
        : idStr.padLeft(6, '0');

    return 'INC-$last6';
  }

  Duration? get elapsedTime {
    if (startedAt == null) return null;
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(startedAt!);
  }

  String? get formattedElapsedTime {
    final elapsed = elapsedTime;
    if (elapsed == null) return null;

    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes % 60;

    if (hours > 0) {
      return '$hours giờ $minutes phút';
    }
    return '$minutes phút';
  }
}

/// Brief Incident Response for Mission
/// Subset of incident data needed for mission detail
@JsonSerializable(explicitToJson: true)
class BriefIncidentForMission {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'locationCoordinates')
  final GeoPointCoordinates locationCoordinates;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'symptomsReport')
  final List<ReportSymptom>? symptomsReport;

  @JsonKey(name: 'severityLevel')
  final int? severityLevel;

  @JsonKey(name: 'incidentOccurredAt')
  final DateTime? incidentOccurredAt;

  @JsonKey(name: 'assignedAt')
  final DateTime? assignedAt;

  @JsonKey(name: 'address')
  final String? address;

  // Backend returns 'identifiedSnake' not 'identified_snake_species'
  @JsonKey(name: 'identifiedSnake')
  final DetectedSnakeSpecies? identifiedSnakeSpecies;

  // Backend returns 'identificationContext' not 'identification_context'
  @JsonKey(name: 'identificationContext')
  final SnakeIdentificationContext? identificationContext;

  @JsonKey(name: 'media')
  final List<SnakeAIDetectMedia> media;

  BriefIncidentForMission({
    required this.id,
    required this.locationCoordinates,
    required this.status,
    this.symptomsReport,
    this.severityLevel,
    this.incidentOccurredAt,
    this.assignedAt,
    this.address,
    this.identifiedSnakeSpecies,
    this.identificationContext,
    required this.media,
  });

  factory BriefIncidentForMission.fromJson(Map<String, dynamic> json) =>
      _$BriefIncidentForMissionFromJson(json);

  Map<String, dynamic> toJson() => _$BriefIncidentForMissionToJson(this);

  // Computed properties
  IncidentStatus get incidentStatus => IncidentStatus.fromString(status);

  String getSeverityText() {
    if (severityLevel == null) return 'Chưa xác định';
    if (severityLevel! >= 70) return 'Nghiêm trọng';
    if (severityLevel! >= 40) return 'Cao';
    if (severityLevel! >= 10) return 'Trung bình';
    return 'Thấp';
  }

  String getSeverityColorHex() {
    if (severityLevel == null) return '9E9E9E';
    if (severityLevel! >= 70) return 'D32F2F';
    if (severityLevel! >= 40) return 'FF9800';
    if (severityLevel! >= 10) return 'FFC107';
    return '4CAF50';
  }

  String getIsVenomousText() {
    if (identifiedSnakeSpecies == null) return 'Chưa xác định';
    return identifiedSnakeSpecies!.isVenomous ? 'Rắn độc' : 'Rắn không độc';
  }
}

/// Update Mission Status Request
@JsonSerializable()
class UpdateMissionStatusRequest {
  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'cancellationReason')
  final String? cancellationReason;

  UpdateMissionStatusRequest({required this.status, this.cancellationReason});

  factory UpdateMissionStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateMissionStatusRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateMissionStatusRequestToJson(this);
}

/// Cancel/Abort Mission Request
/// Used for abort and cancel mission endpoints
@JsonSerializable()
class CancelMissionRequest {
  @JsonKey(name: 'cancellationReason')
  final String? cancellationReason;

  CancelMissionRequest({this.cancellationReason});

  factory CancelMissionRequest.fromJson(Map<String, dynamic> json) =>
      _$CancelMissionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CancelMissionRequestToJson(this);
}

/// Basic Rescue Mission Response
/// Lightweight mission data for persistence in SharedPreferences
/// Used by active_mission_provider for caching active mission
@JsonSerializable()
class BasicRescueMissionResponse {
  @JsonKey(name: 'missionId')
  final String missionId;

  @JsonKey(name: 'incidentId')
  final String incidentId;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'startedAt')
  final DateTime? startedAt;

  @JsonKey(name: 'acceptedAt')
  final DateTime? acceptedAt;

  BasicRescueMissionResponse({
    required this.missionId,
    required this.incidentId,
    required this.status,
    this.startedAt,
    this.acceptedAt,
  });

  factory BasicRescueMissionResponse.fromJson(Map<String, dynamic> json) =>
      _$BasicRescueMissionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BasicRescueMissionResponseToJson(this);

  /// Convert from detailed mission
  factory BasicRescueMissionResponse.fromDetailed(
    DetailRescueMissionResponse detailed,
  ) {
    return BasicRescueMissionResponse(
      missionId: detailed.id,
      incidentId: detailed.incidentId,
      status: detailed.status,
      startedAt: detailed.startedAt,
      acceptedAt: detailed.createdAt,
    );
  }
}
