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
  distanceKm: (json['distanceKm'] as num).toDouble(),
  pricePerKm: (json['pricePerKm'] as num).toDouble(),
  hospitalTransferPrice: (json['hospitalTransferPrice'] as num).toDouble(),
  baseMissionPrice: (json['baseMissionPrice'] as num).toDouble(),
  totalPrice: (json['totalPrice'] as num).toDouble(),
  calculatedAt: DateTime.parse(json['calculatedAt'] as String),
);

Map<String, dynamic> _$HospitalTransferPricingResponseToJson(
  HospitalTransferPricingResponse instance,
) => <String, dynamic>{
  'hospitalId': instance.hospitalId,
  'hospitalName': instance.hospitalName,
  'distanceKm': instance.distanceKm,
  'pricePerKm': instance.pricePerKm,
  'hospitalTransferPrice': instance.hospitalTransferPrice,
  'baseMissionPrice': instance.baseMissionPrice,
  'totalPrice': instance.totalPrice,
  'calculatedAt': instance.calculatedAt.toIso8601String(),
};
