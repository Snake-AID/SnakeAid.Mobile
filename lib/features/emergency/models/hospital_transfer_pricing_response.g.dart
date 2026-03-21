// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hospital_transfer_pricing_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HospitalTransferPricingResponse _$HospitalTransferPricingResponseFromJson(
  Map<String, dynamic> json,
) => HospitalTransferPricingResponse(
  hospitalId: (json['hospitalId'] as num).toInt(),
  hospitalName: json['hospitalName'] as String,
  requiresHospitalization: json['requiresHospitalization'] as bool,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$HospitalTransferPricingResponseToJson(
  HospitalTransferPricingResponse instance,
) => <String, dynamic>{
  'hospitalId': instance.hospitalId,
  'hospitalName': instance.hospitalName,
  'requiresHospitalization': instance.requiresHospitalization,
  'updatedAt': instance.updatedAt.toIso8601String(),
};
