class SnakeSpecies {
  final int id;
  final String scientificName;
  final String slug;
  final String commonName;
  final String? imageUrl;
  final String? description;
  final String? identificationSummary;
  final String? primaryVenomType;
  final SnakeIdentification? identification;
  final List<SymptomByTime>? symptomsByTime;
  final double riskLevel;
  final bool isVenomous;
  final bool isActive;

  SnakeSpecies({
    required this.id,
    required this.scientificName,
    required this.slug,
    required this.commonName,
    this.imageUrl,
    this.description,
    this.identificationSummary,
    this.primaryVenomType,
    this.identification,
    this.symptomsByTime,
    required this.riskLevel,
    required this.isVenomous,
    required this.isActive,
  });

  factory SnakeSpecies.fromJson(Map<String, dynamic> json) {
    return SnakeSpecies(
      id: json['id'] as int,
      scientificName: json['scientificName'] as String,
      slug: json['slug'] as String? ?? '',
      commonName: json['commonName'] as String,
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      identificationSummary: json['identificationSummary'] as String?,
      primaryVenomType: json['primaryVenomType'] as String?,
      identification: json['identification'] != null
          ? SnakeIdentification.fromJson(json['identification'])
          : null,
      symptomsByTime: json['symptomsByTime'] != null
          ? (json['symptomsByTime'] as List<dynamic>)
                .map((e) => SymptomByTime.fromJson(e))
                .toList()
          : null,
      riskLevel: (json['riskLevel'] as num).toDouble(),
      isVenomous: json['isVenomous'] as bool,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scientificName': scientificName,
      'slug': slug,
      'commonName': commonName,
      'imageUrl': imageUrl,
      'description': description,
      'identificationSummary': identificationSummary,
      'primaryVenomType': primaryVenomType,
      'identification': identification?.toJson(),
      'symptomsByTime': symptomsByTime?.map((e) => e.toJson()).toList(),
      'riskLevel': riskLevel,
      'isVenomous': isVenomous,
      'isActive': isActive,
    };
  }
}

class SnakeIdentification {
  final List<String> physicalTraits;
  final List<String> behaviors;
  final String habitat;

  SnakeIdentification({
    required this.physicalTraits,
    required this.behaviors,
    required this.habitat,
  });

  factory SnakeIdentification.fromJson(Map<String, dynamic> json) {
    return SnakeIdentification(
      physicalTraits:
          (json['physicalTraits'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      behaviors:
          (json['behaviors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      habitat: json['habitat'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'physicalTraits': physicalTraits,
      'behaviors': behaviors,
      'habitat': habitat,
    };
  }
}

class SymptomByTime {
  final String timeRange;
  final List<String> signs;
  final bool isCritical;

  SymptomByTime({
    required this.timeRange,
    required this.signs,
    required this.isCritical,
  });

  factory SymptomByTime.fromJson(Map<String, dynamic> json) {
    return SymptomByTime(
      timeRange: json['timeRange'] as String,
      signs:
          (json['signs'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      isCritical: json['isCritical'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'timeRange': timeRange, 'signs': signs, 'isCritical': isCritical};
  }
}
