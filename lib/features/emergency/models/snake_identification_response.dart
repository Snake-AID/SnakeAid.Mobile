import 'snake_detection_response.dart';

/// Response từ endpoint POST /api/incidents/{id}/identify/ai
/// Backend trả về sau khi confirm snake identification
class IdentifySnakeResponse {
  final String incidentId;
  final int identifiedSnakeSpeciesId;
  final String identificationMethod;
  final DateTime identifiedAt;
  final SnakeInfo snake;
  final String? aiRecognitionResultId;
  final double? aiConfidence;
  final List<dynamic> matchedSnakes;

  IdentifySnakeResponse({
    required this.incidentId,
    required this.identifiedSnakeSpeciesId,
    required this.identificationMethod,
    required this.identifiedAt,
    required this.snake,
    this.aiRecognitionResultId,
    this.aiConfidence,
    required this.matchedSnakes,
  });

  factory IdentifySnakeResponse.fromJson(Map<String, dynamic> json) {
    return IdentifySnakeResponse(
      incidentId: json['incidentId'] as String,
      identifiedSnakeSpeciesId: json['identifiedSnakeSpeciesId'] as int,
      identificationMethod: json['identificationMethod'] as String,
      identifiedAt: DateTime.parse(json['identifiedAt'] as String),
      snake: SnakeInfo.fromJson(json['snake'] as Map<String, dynamic>),
      aiRecognitionResultId: json['aiRecognitionResultId'] as String?,
      aiConfidence: (json['aiConfidence'] as num?)?.toDouble(),
      matchedSnakes: json['matchedSnakes'] as List<dynamic>? ?? [],
    );
  }
}

/// Enum cho method identification
enum SnakeIdentificationMethod {
  humanExpert('HUMAN_EXPERT'),
  ai('AI');

  final String value;
  const SnakeIdentificationMethod(this.value);

  static SnakeIdentificationMethod fromString(String value) {
    return SnakeIdentificationMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SnakeIdentificationMethod.ai,
    );
  }
}

/// Context về việc nhận dạng rắn
class SnakeIdentificationContext {
  final SnakeIdentificationMethod method;
  final String? speciesId; // Optional - không có trong response từ backend
  final String? recognitionResultId; // Optional
  final double? aiConfidence; // NEW: Confidence score từ AI (0.0 - 1.0)
  final DateTime? identifiedAt; // NEW: Thời điểm nhận diện

  SnakeIdentificationContext({
    required this.method,
    this.speciesId,
    this.recognitionResultId,
    this.aiConfidence,
    this.identifiedAt,
  });

  factory SnakeIdentificationContext.fromJson(Map<String, dynamic> json) {
    return SnakeIdentificationContext(
      method: SnakeIdentificationMethod.fromString(
        json['method'] as String? ?? 'AI',
      ),
      speciesId: json['species_id'] as String?,
      recognitionResultId: json['recognition_result_id'] as String?,
      aiConfidence: (json['aiConfidence'] as num?)?.toDouble(),
      identifiedAt: json['identifiedAt'] != null
          ? DateTime.parse(json['identifiedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method.value,
      if (speciesId != null) 'species_id': speciesId,
      if (recognitionResultId != null)
        'recognition_result_id': recognitionResultId,
      if (aiConfidence != null) 'aiConfidence': aiConfidence,
      if (identifiedAt != null) 'identifiedAt': identifiedAt!.toIso8601String(),
    };
  }
}
