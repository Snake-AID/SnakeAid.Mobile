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
  distanceFromCenterKm: (json['distanceFromCenterKm'] as num?)?.toDouble(),
  costFromCenter: (json['costFromCenter'] as num?)?.toDouble(),
  requiresHospitalization: json['requiresHospitalization'] as bool? ?? false,
  hospitalId: json['hospitalId'] as int?,
  hospitalInfo: json['hospitalInfo'] == null
      ? null
      : HospitalTransferResponse.fromJson(
          json['hospitalInfo'] as Map<String, dynamic>,
        ),
  incident: BriefIncidentForMission.fromJson(
    json['incident'] as Map<String, dynamic>,
  ),
  rescuer: BriefRescuerProfile.fromJson(
    json['rescuer'] as Map<String, dynamic>,
  ),
  user: BriefMemberProfile.fromJson(json['user'] as Map<String, dynamic>),
  missionMedia:
      (json['missionMedia'] as List<dynamic>?)
          ?.map((e) => ReportMediaResponse.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
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
  'distanceFromCenterKm': instance.distanceFromCenterKm,
  'costFromCenter': instance.costFromCenter,
  'requiresHospitalization': instance.requiresHospitalization,
  'hospitalId': instance.hospitalId,
  'hospitalInfo': instance.hospitalInfo?.toJson(),
  'incident': instance.incident.toJson(),
  'rescuer': instance.rescuer.toJson(),
  'user': instance.user.toJson(),
  'missionMedia': instance.missionMedia.map((e) => e.toJson()).toList(),
};

BriefIncidentForMission _$BriefIncidentForMissionFromJson(
  Map<String, dynamic> json,
) => BriefIncidentForMission(
  id: json['id'] as String,
  locationCoordinates: GeoPointCoordinates.fromJson(
    json['locationCoordinates'] as Map<String, dynamic>,
  ),
  status: json['status'] as String,
  symptomsReport: (json['symptomsReport'] as List<dynamic>?)
      ?.map((e) => ReportSymptom.fromJson(e as Map<String, dynamic>))
      .toList(),
  severityLevel: (json['severityLevel'] as num?)?.toInt(),
  incidentOccurredAt: json['incidentOccurredAt'] == null
      ? null
      : DateTime.parse(json['incidentOccurredAt'] as String),
  assignedAt: json['assignedAt'] == null
      ? null
      : DateTime.parse(json['assignedAt'] as String),
  address: json['address'] as String?,
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
  'symptomsReport': instance.symptomsReport?.map((e) => e.toJson()).toList(),
  'severityLevel': instance.severityLevel,
  'incidentOccurredAt': instance.incidentOccurredAt?.toIso8601String(),
  'assignedAt': instance.assignedAt?.toIso8601String(),
  'address': instance.address,
  'identifiedSnake': instance.identifiedSnakeSpecies?.toJson(),
  'identificationContext': instance.identificationContext?.toJson(),
  'media': instance.media.map((e) => e.toJson()).toList(),
};

HospitalTransferResponse _$HospitalTransferResponseFromJson(
  Map<String, dynamic> json,
) => HospitalTransferResponse(
  hospitalId: json['hospitalId'] as int,
  hospitalName: json['hospitalName'] as String,
  address: json['address'] as String,
  contactNumber: json['contactNumber'] as String,
);

Map<String, dynamic> _$HospitalTransferResponseToJson(
  HospitalTransferResponse instance,
) => <String, dynamic>{
  'hospitalId': instance.hospitalId,
  'hospitalName': instance.hospitalName,
  'address': instance.address,
  'contactNumber': instance.contactNumber,
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

BasicRescueMissionResponse _$BasicRescueMissionResponseFromJson(
  Map<String, dynamic> json,
) => BasicRescueMissionResponse(
  missionId: json['missionId'] as String,
  incidentId: json['incidentId'] as String,
  status: json['status'] as String,
  startedAt: json['startedAt'] == null
      ? null
      : DateTime.parse(json['startedAt'] as String),
  acceptedAt: json['acceptedAt'] == null
      ? null
      : DateTime.parse(json['acceptedAt'] as String),
);

Map<String, dynamic> _$BasicRescueMissionResponseToJson(
  BasicRescueMissionResponse instance,
) => <String, dynamic>{
  'missionId': instance.missionId,
  'incidentId': instance.incidentId,
  'status': instance.status,
  'startedAt': instance.startedAt?.toIso8601String(),
  'acceptedAt': instance.acceptedAt?.toIso8601String(),
};
