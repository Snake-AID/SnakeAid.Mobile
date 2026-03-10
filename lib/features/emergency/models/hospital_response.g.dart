// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hospital_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HospitalResponse _$HospitalResponseFromJson(Map<String, dynamic> json) =>
    HospitalResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      address: json['address'] as String,
      contactNumber: json['contactNumber'] as String?,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$HospitalResponseToJson(HospitalResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'contactNumber': instance.contactNumber,
      'distanceKm': instance.distanceKm,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
