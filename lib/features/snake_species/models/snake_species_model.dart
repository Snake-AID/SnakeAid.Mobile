/// Model for a snake species returned by GET /api/snake-species and GET /api/snake-species/{id}
class SnakeSpeciesModel {
  final int id;
  final String scientificName;
  final String slug;
  final String commonName;
  final String? imageUrl;
  final String? description;
  final String? identificationSummary;
  final String? primaryVenomType;
  final SnakeIdentification? identification;
  final List<SnakeSymptomsByTime> symptomsByTime;
  final int riskLevel;
  final bool isVenomous;
  final bool isActive;
  final List<String> alternativeNames;
  final List<SnakeVenom> venoms;
  final List<dynamic> antivenoms;

  const SnakeSpeciesModel({
    required this.id,
    required this.scientificName,
    required this.slug,
    required this.commonName,
    this.imageUrl,
    this.description,
    this.identificationSummary,
    this.primaryVenomType,
    this.identification,
    required this.symptomsByTime,
    required this.riskLevel,
    required this.isVenomous,
    required this.isActive,
    required this.alternativeNames,
    required this.venoms,
    required this.antivenoms,
  });

  factory SnakeSpeciesModel.fromJson(Map<String, dynamic> json) {
    return SnakeSpeciesModel(
      id: (json['id'] as num).toInt(),
      scientificName: (json['scientificName'] ?? '') as String,
      slug: (json['slug'] ?? '') as String,
      commonName: (json['commonName'] ?? '') as String,
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      identificationSummary: json['identificationSummary'] as String?,
      primaryVenomType: json['primaryVenomType'] as String?,
      identification: json['identification'] != null
          ? SnakeIdentification.fromJson(
              json['identification'] as Map<String, dynamic>)
          : null,
      symptomsByTime: (json['symptomsByTime'] as List<dynamic>? ?? [])
          .map((e) =>
              SnakeSymptomsByTime.fromJson(e as Map<String, dynamic>))
          .toList(),
      riskLevel: (json['riskLevel'] as num? ?? 0).toInt(),
      isVenomous: json['isVenomous'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      alternativeNames: (json['alternativeNames'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      venoms: (json['venoms'] as List<dynamic>? ?? [])
          .map((e) => SnakeVenom.fromJson(e as Map<String, dynamic>))
          .toList(),
      antivenoms: json['antivenoms'] as List<dynamic>? ?? [],
    );
  }
}

class SnakeIdentification {
  final List<String> physicalTraits;
  final List<String> behaviors;
  final String? habitat;

  const SnakeIdentification({
    required this.physicalTraits,
    required this.behaviors,
    this.habitat,
  });

  factory SnakeIdentification.fromJson(Map<String, dynamic> json) {
    return SnakeIdentification(
      physicalTraits: (json['physicalTraits'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      behaviors: (json['behaviors'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      habitat: json['habitat'] as String?,
    );
  }
}

class SnakeSymptomsByTime {
  final String timeRange;
  final List<String> signs;
  final bool isCritical;

  const SnakeSymptomsByTime({
    required this.timeRange,
    required this.signs,
    required this.isCritical,
  });

  factory SnakeSymptomsByTime.fromJson(Map<String, dynamic> json) {
    return SnakeSymptomsByTime(
      timeRange: (json['timeRange'] ?? '') as String,
      signs: (json['signs'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      isCritical: json['isCritical'] as bool? ?? false,
    );
  }
}

class SnakeVenom {
  final String venomType;
  final String? description;

  const SnakeVenom({required this.venomType, this.description});

  factory SnakeVenom.fromJson(Map<String, dynamic> json) {
    return SnakeVenom(
      venomType: (json['venomType'] ?? '') as String,
      description: json['description'] as String?,
    );
  }
}
