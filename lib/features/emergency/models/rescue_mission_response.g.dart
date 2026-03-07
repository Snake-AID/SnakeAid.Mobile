// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rescue_mission_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetailRescueMissionResponse _$DetailRescueMissionResponseFromJson(
  Map<String, dynamic> json,
) => DetailRescueMissionResponse(
  id: json['id'] as String,
  incidentId: json['incidentId'] as String,
  rescuerId: json['rescuerId'] as String,
  status: json['status'] as String,
  price: (json['price'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  startedAt: json['startedAt'] == null
      ? null
      : DateTime.parse(json['startedAt'] as String),
  arrivedAt: json['arrivedAt'] == null
      ? null
      : DateTime.parse(json['arrivedAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  notes: json['notes'] as String?,
  cancellationReason: json['cancellationReason'] as String?,
  estimatedCost: (json['estimatedCost'] as num?)?.toDouble(),
  actualCost: (json['actualCost'] as num?)?.toDouble(),
  distanceKm: (json['distanceKm'] as num?)?.toDouble(),
  incident: BriefIncidentForMission.fromJson(
    json['incident'] as Map<String, dynamic>,
  ),
  rescuer: BriefRescuerProfile.fromJson(
    json['rescuer'] as Map<String, dynamic>,
  ),
  user: BriefMemberProfile.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DetailRescueMissionResponseToJson(
  DetailRescueMissionResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'incidentId': instance.incidentId,
  'rescuerId': instance.rescuerId,
  'status': instance.status,
  'price': instance.price,
  'createdAt': instance.createdAt.toIso8601String(),
  'startedAt': instance.startedAt?.toIso8601String(),
  'arrivedAt': instance.arrivedAt?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'notes': instance.notes,
  'cancellationReason': instance.cancellationReason,
  'estimatedCost': instance.estimatedCost,
  'actualCost': instance.actualCost,
  'distanceKm': instance.distanceKm,
  'incident': instance.incident.toJson(),
  'rescuer': instance.rescuer.toJson(),
  'user': instance.user.toJson(),
};

BriefIncidentForMission _$BriefIncidentForMissionFromJson(
  Map<String, dynamic> json,
) => BriefIncidentForMission(
  id: json['id'] as String,
  locationCoordinates: GeoPointCoordinates.fromJson(
    json['locationCoordinates'] as Map<String, dynamic>,
  ),
  status: json['status'] as String,
  symptomsReport: json['symptomsReport'] as String?,
  severityLevel: (json['severityLevel'] as num?)?.toInt(),
  incidentOccurredAt: json['incidentOccurredAt'] == null
      ? null
      : DateTime.parse(json['incidentOccurredAt'] as String),
  assignedAt: json['assignedAt'] == null
      ? null
      : DateTime.parse(json['assignedAt'] as String),
  currentSessionNumber: (json['currentSessionNumber'] as num).toInt(),
  currentRadiusKm: (json['currentRadiusKm'] as num).toInt(),
  identifiedSnakeSpecies: json['identifiedSnake'] == null
      ? null
      : DetectedSnakeSpecies.fromJson(
          json['identifiedSnake'] as Map<String, dynamic>,
        ),
  identificationContext: json['identificationContext'] == null
      ? null
      : SnakeIdentificationContext.fromJson(
          json['identificationContext'] as Map<String, dynamic>,
        ),
  media: (json['media'] as List<dynamic>)
      .map((e) => SnakeAIDetectMedia.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BriefIncidentForMissionToJson(
  BriefIncidentForMission instance,
) => <String, dynamic>{
  'id': instance.id,
  'locationCoordinates': instance.locationCoordinates.toJson(),
  'status': instance.status,
  'symptomsReport': instance.symptomsReport,
  'severityLevel': instance.severityLevel,
  'incidentOccurredAt': instance.incidentOccurredAt?.toIso8601String(),
  'assignedAt': instance.assignedAt?.toIso8601String(),
  'currentSessionNumber': instance.currentSessionNumber,
  'currentRadiusKm': instance.currentRadiusKm,
  'identifiedSnake': instance.identifiedSnakeSpecies?.toJson(),
  'identificationContext': instance.identificationContext?.toJson(),
  'media': instance.media.map((e) => e.toJson()).toList(),
};

UpdateMissionStatusRequest _$UpdateMissionStatusRequestFromJson(
  Map<String, dynamic> json,
) => UpdateMissionStatusRequest(
  status: json['status'] as String,
  cancellationReason: json['cancellationReason'] as String?,
);

Map<String, dynamic> _$UpdateMissionStatusRequestToJson(
  UpdateMissionStatusRequest instance,
) => <String, dynamic>{
  'status': instance.status,
  'cancellationReason': instance.cancellationReason,
};

CancelMissionRequest _$CancelMissionRequestFromJson(
  Map<String, dynamic> json,
) => CancelMissionRequest(
  cancellationReason: json['cancellationReason'] as String?,
);

Map<String, dynamic> _$CancelMissionRequestToJson(
  CancelMissionRequest instance,
) => <String, dynamic>{'cancellationReason': instance.cancellationReason};
