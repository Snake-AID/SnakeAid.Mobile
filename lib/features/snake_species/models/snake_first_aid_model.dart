/// Model for GET /api/first-aid-guidelines/recommendation/species/{snakeSpeciesId}
class SnakeFirstAidModel {
  final String? guidelineId;
  final String guidelineName;
  final FirstAidContent content;
  final String? source;
  final SnakeSpeciesSummary? identifiedSnake;
  final List<String> warnings;

  const SnakeFirstAidModel({
    this.guidelineId,
    required this.guidelineName,
    required this.content,
    this.source,
    this.identifiedSnake,
    required this.warnings,
  });

  factory SnakeFirstAidModel.fromJson(Map<String, dynamic> json) {
    return SnakeFirstAidModel(
      guidelineId: json['guidelineId'] as String?,
      guidelineName: (json['guidelineName'] ?? '') as String,
      content: FirstAidContent.fromJson(
          json['content'] as Map<String, dynamic>? ?? {}),
      source: json['source'] as String?,
      identifiedSnake: json['identifiedSnake'] != null
          ? SnakeSpeciesSummary.fromJson(
              json['identifiedSnake'] as Map<String, dynamic>)
          : null,
      warnings: (json['warnings'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class FirstAidContent {
  final List<FirstAidStep> steps;
  final List<FirstAidStep> dos;
  final List<FirstAidStep> donts;
  final List<String> notes;

  const FirstAidContent({
    required this.steps,
    required this.dos,
    required this.donts,
    required this.notes,
  });

  factory FirstAidContent.fromJson(Map<String, dynamic> json) {
    return FirstAidContent(
      steps: (json['steps'] as List<dynamic>? ?? [])
          .map((e) => FirstAidStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      dos: (json['dos'] as List<dynamic>? ?? [])
          .map((e) => FirstAidStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      donts: (json['donts'] as List<dynamic>? ?? [])
          .map((e) => FirstAidStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: (json['notes'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class FirstAidStep {
  final String text;
  final String? mediaUrl;

  const FirstAidStep({required this.text, this.mediaUrl});

  factory FirstAidStep.fromJson(Map<String, dynamic> json) {
    final rawUrl = json['mediaUrl'] as String?;
    return FirstAidStep(
      text: (json['text'] ?? '') as String,
      mediaUrl: (rawUrl != null && rawUrl.isNotEmpty) ? rawUrl : null,
    );
  }
}

class SnakeSpeciesSummary {
  final int id;
  final String commonName;
  final String scientificName;
  final String? imageUrl;
  final String? identificationSummary;
  final String? primaryVenomType;
  final int riskLevel;
  final bool isVenomous;

  const SnakeSpeciesSummary({
    required this.id,
    required this.commonName,
    required this.scientificName,
    this.imageUrl,
    this.identificationSummary,
    this.primaryVenomType,
    required this.riskLevel,
    required this.isVenomous,
  });

  factory SnakeSpeciesSummary.fromJson(Map<String, dynamic> json) {
    return SnakeSpeciesSummary(
      id: (json['id'] as num).toInt(),
      commonName: (json['commonName'] ?? '') as String,
      scientificName: (json['scientificName'] ?? '') as String,
      imageUrl: json['imageUrl'] as String?,
      identificationSummary: json['identificationSummary'] as String?,
      primaryVenomType: json['primaryVenomType'] as String?,
      riskLevel: (json['riskLevel'] as num? ?? 0).toInt(),
      isVenomous: json['isVenomous'] as bool? ?? false,
    );
  }
}
