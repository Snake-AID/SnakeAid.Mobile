import 'package:snakeaid_mobile/features/emergency/models/snake_detection_response.dart';
import 'package:snakeaid_mobile/features/emergency/models/snake_identification_response.dart';

/// Response từ endpoint GET /api/first-aid-guidelines/recommendation/incident/{id}
/// Backend trả về first aid recommendation dựa trên incident
///
/// NOTE: Khi chưa có rắn được nhận diện (guideline GENERAL), các trường sau sẽ null:
/// - identifiedSnake, identificationContext, guidelineId
class FirstAidRecommendationResponse {
  final int? guidelineId; // Nullable khi dùng species-specific override
  final String guidelineName;
  final FirstAidContent
  firstAidGuideline; // Renamed from 'content' for consistency
  final String source; // "General", "VENOM_TYPE", "SPECIES_OVERRIDE"
  final SnakeInfo? identifiedSnake; // Nullable khi dùng guideline GENERAL
  final SnakeIdentificationContext?
  identificationContext; // Nullable khi GENERAL
  final List<String> warnings;

  FirstAidRecommendationResponse({
    this.guidelineId,
    required this.guidelineName,
    required this.firstAidGuideline,
    required this.source,
    this.identifiedSnake,
    this.identificationContext,
    this.warnings = const [],
  });

  factory FirstAidRecommendationResponse.fromJson(Map<String, dynamic> json) {
    // Parse content (always present) - backend uses 'content' not 'first_aid_guideline'
    final firstAidGuideline = FirstAidContent.fromJson(
      json['content'] as Map<String, dynamic>,
    );

    // Parse optional snake info (null for GENERAL guideline)
    // Backend uses 'identifiedSnake' (camelCase) not 'snake'
    SnakeInfo? snake;
    if (json['identifiedSnake'] != null) {
      snake = SnakeInfo.fromJson(
        json['identifiedSnake'] as Map<String, dynamic>,
      );
    }

    // Parse optional identification context (camelCase)
    SnakeIdentificationContext? identificationContext;
    if (json['identificationContext'] != null) {
      identificationContext = SnakeIdentificationContext.fromJson(
        json['identificationContext'] as Map<String, dynamic>,
      );
    }

    // Parse warnings array
    final warnings =
        (json['warnings'] as List<dynamic>?)
            ?.map((w) => w.toString())
            .toList() ??
        [];

    return FirstAidRecommendationResponse(
      guidelineId: json['guidelineId'] as int?,
      guidelineName: json['guidelineName'] as String,
      firstAidGuideline: firstAidGuideline,
      source: json['source'] as String,
      identifiedSnake: snake,
      identificationContext: identificationContext,
      warnings: warnings,
    );
  }

  /// Helper: Check if this is a snake-specific guideline
  bool get isSnakeSpecific => identifiedSnake != null;

  /// Helper: Get snake for backward compatibility
  SnakeInfo? get snake => identifiedSnake;

  /// Helper: Convert source string to enum
  FirstAidGuidelineSource get firstAidGuidelineSource {
    return FirstAidGuidelineSource.fromString(source);
  }
}

/// Enum cho nguồn gốc của first aid guideline
enum FirstAidGuidelineSource {
  speciesOverride('SPECIES_OVERRIDE'),
  venomType('VENOM_TYPE'),
  general('GENERAL');

  final String value;
  const FirstAidGuidelineSource(this.value);

  static FirstAidGuidelineSource fromString(String value) {
    return FirstAidGuidelineSource.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FirstAidGuidelineSource.general,
    );
  }

  /// Display text cho UI
  String get displayText {
    switch (this) {
      case FirstAidGuidelineSource.speciesOverride:
        return 'Hướng dẫn chuyên biệt cho loài';
      case FirstAidGuidelineSource.venomType:
        return 'Hướng dẫn theo loại nọc độc';
      case FirstAidGuidelineSource.general:
        return 'Hướng dẫn chung';
    }
  }
}
