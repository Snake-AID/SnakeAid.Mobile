import 'package:json_annotation/json_annotation.dart';

part 'snakes_by_location_response.g.dart';

/// Response model for location-based snake filtering
/// Endpoint: GET /api/snake-species/by-location
@JsonSerializable()
class SnakesByLocationResponse {
  final GeographicRegionDto region;
  final List<SnakeInRegionDto> snakes;

  SnakesByLocationResponse({
    required this.region,
    required this.snakes,
  });

  factory SnakesByLocationResponse.fromJson(Map<String, dynamic> json) =>
      _$SnakesByLocationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SnakesByLocationResponseToJson(this);
}

/// Geographic region information
@JsonSerializable()
class GeographicRegionDto {
  final int id;
  final String code;
  final String name;
  final String description;

  GeographicRegionDto({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
  });

  factory GeographicRegionDto.fromJson(Map<String, dynamic> json) =>
      _$GeographicRegionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GeographicRegionDtoToJson(this);
}

/// Snake species information in a specific region
@JsonSerializable()
class SnakeInRegionDto {
  final int id;
  final String scientificName;
  final String commonName;
  final String slug;
  final String imageUrl;
  final String? description;
  final String identificationSummary;
  final String? primaryVenomType;
  final double riskLevel;
  final bool isVenomous;
  final String commonLevel;
  final int priority;
  final String? distributionNotes;

  SnakeInRegionDto({
    required this.id,
    required this.scientificName,
    required this.commonName,
    required this.slug,
    required this.imageUrl,
    this.description,
    required this.identificationSummary,
    this.primaryVenomType,
    required this.riskLevel,
    required this.isVenomous,
    required this.commonLevel,
    required this.priority,
    this.distributionNotes,
  });

  factory SnakeInRegionDto.fromJson(Map<String, dynamic> json) =>
      _$SnakeInRegionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SnakeInRegionDtoToJson(this);
}
