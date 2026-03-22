/// Models for community snake-sighting / area-warning reports.
class SnakeSpecies {
  final int id;
  final String commonName;
  final String? scientificName;
  final String? imageUrl;
  final bool isVenomous;
  /// Numeric risk level from API (1–10). Use [riskLevelLabel] for display.
  final int? riskLevel;

  const SnakeSpecies({
    required this.id,
    required this.commonName,
    this.scientificName,
    this.imageUrl,
    required this.isVenomous,
    this.riskLevel,
  });

  factory SnakeSpecies.fromJson(Map<String, dynamic> json) => SnakeSpecies(
        id: (json['id'] as num?)?.toInt() ?? 0,
        commonName: json['commonName'] as String? ??
            json['common_name'] as String? ??
            'Không rõ',
        scientificName: json['scientificName'] as String?,
        imageUrl: json['imageUrl'] as String?,
        isVenomous: json['isVenomous'] as bool? ?? false,
        riskLevel: (json['riskLevel'] as num?)?.toInt(),
      );

  @override
  String toString() => commonName;

  @override
  bool operator ==(Object other) => other is SnakeSpecies && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

extension SnakeSpeciesRisk on SnakeSpecies {
  /// Converts numeric riskLevel (1–10) to a string label.
  String get riskLevelLabel {
    final r = riskLevel ?? 0;
    if (r >= 9) return 'Extreme';
    if (r >= 7) return 'Critical';
    if (r >= 5) return 'High';
    if (r >= 3) return 'Medium';
    return 'Low';
  }
}

class CommunityReport {
  final String id;
  final double latitude;
  final double longitude;
  final String notes;
  final String? imageUrl;
  final int? snakeSpeciesId;
  final SnakeSpecies? snakeSpecies;
  final String? reporterName;
  final String? reporterId;
  final String? riskLevel;
  final bool isVenomous;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CommunityReport({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.notes,
    this.imageUrl,
    this.snakeSpeciesId,
    this.snakeSpecies,
    this.reporterName,
    this.reporterId,
    this.riskLevel,
    required this.isVenomous,
    required this.createdAt,
    this.updatedAt,
  });

  String get snakeDisplayName => snakeSpecies?.commonName ?? 'Không rõ loài';

  String get resolvedRiskLevel =>
      riskLevel ?? snakeSpecies?.riskLevelLabel ?? 'Low';

  factory CommunityReport.fromJson(Map<String, dynamic> json) {
    SnakeSpecies? species;
    if (json['snakeSpecies'] is Map<String, dynamic>) {
      species =
          SnakeSpecies.fromJson(json['snakeSpecies'] as Map<String, dynamic>);
    }
    return CommunityReport(
      id: _toStringNullable(json['id']) ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      snakeSpeciesId: (json['snakeSpeciesId'] as num?)?.toInt(),
      snakeSpecies: species,
      reporterName: _toStringNullable(json['reporterName']) ??
          _toStringNullable(json['reporterFullName']),
      reporterId: _toStringNullable(json['reporterId']) ??
          _toStringNullable(json['userId']),
      riskLevel: _toStringNullable(json['riskLevel']) ?? species?.riskLevelLabel,
      isVenomous:
          json['isVenomous'] as bool? ?? species?.isVenomous ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}

/// Safely convert any JSON value to String?, returning null when the value is null.
String? _toStringNullable(dynamic value) {
  if (value == null) return null;
  return value.toString();
}
