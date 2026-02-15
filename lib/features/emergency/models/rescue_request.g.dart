// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rescue_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RescueRequest _$RescueRequestFromJson(Map<String, dynamic> json) =>
    RescueRequest(
      requestId: json['requestId'] as String,
      sessionId: json['sessionId'] as String,
      incidentId: json['incidentId'] as String,
      radiusKm: (json['radiusKm'] as num).toDouble(),
      requestSentAt: DateTime.parse(json['requestSentAt'] as String),
      expiredAt: DateTime.parse(json['expiredAt'] as String),
    );

Map<String, dynamic> _$RescueRequestToJson(RescueRequest instance) =>
    <String, dynamic>{
      'requestId': instance.requestId,
      'sessionId': instance.sessionId,
      'incidentId': instance.incidentId,
      'radiusKm': instance.radiusKm,
      'requestSentAt': instance.requestSentAt.toIso8601String(),
      'expiredAt': instance.expiredAt.toIso8601String(),
    };

AcceptRequestResponse _$AcceptRequestResponseFromJson(
  Map<String, dynamic> json,
) => AcceptRequestResponse(
  isSuccess: json['isSuccess'] as bool,
  message: json['message'] as String,
  missionId: json['missionId'] as String?,
  error: json['error'] as String?,
);

Map<String, dynamic> _$AcceptRequestResponseToJson(
  AcceptRequestResponse instance,
) => <String, dynamic>{
  'isSuccess': instance.isSuccess,
  'message': instance.message,
  'missionId': instance.missionId,
  'error': instance.error,
};
