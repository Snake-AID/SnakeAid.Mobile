// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snakes_by_location_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SnakesByLocationResponse _$SnakesByLocationResponseFromJson(
  Map<String, dynamic> json,
) => SnakesByLocationResponse(
  region: GeographicRegionDto.fromJson(json['region'] as Map<String, dynamic>),
  snakes: (json['snakes'] as List<dynamic>)
      .map((e) => SnakeInRegionDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SnakesByLocationResponseToJson(
  SnakesByLocationResponse instance,
) => <String, dynamic>{'region': instance.region, 'snakes': instance.snakes};

GeographicRegionDto _$GeographicRegionDtoFromJson(Map<String, dynamic> json) =>
    GeographicRegionDto(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$GeographicRegionDtoToJson(
  GeographicRegionDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'description': instance.description,
};

SnakeInRegionDto _$SnakeInRegionDtoFromJson(Map<String, dynamic> json) =>
    SnakeInRegionDto(
      id: (json['id'] as num).toInt(),
      scientificName: json['scientificName'] as String,
      commonName: json['commonName'] as String,
      slug: json['slug'] as String,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String?,
      identificationSummary: json['identificationSummary'] as String,
      primaryVenomType: json['primaryVenomType'] as String?,
      riskLevel: (json['riskLevel'] as num).toDouble(),
      isVenomous: json['isVenomous'] as bool,
      commonLevel: json['commonLevel'] as String,
      priority: (json['priority'] as num).toInt(),
      distributionNotes: json['distributionNotes'] as String?,
    );

Map<String, dynamic> _$SnakeInRegionDtoToJson(SnakeInRegionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scientificName': instance.scientificName,
      'commonName': instance.commonName,
      'slug': instance.slug,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
      'identificationSummary': instance.identificationSummary,
      'primaryVenomType': instance.primaryVenomType,
      'riskLevel': instance.riskLevel,
      'isVenomous': instance.isVenomous,
      'commonLevel': instance.commonLevel,
      'priority': instance.priority,
      'distributionNotes': instance.distributionNotes,
    };
