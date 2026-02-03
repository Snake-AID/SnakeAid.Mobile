/// Snake Detection Response Model
class SnakeDetectionResponse {
  final int statusCode;
  final String message;
  final bool isSuccess;
  final DetectionData? data;
  final dynamic error;

  SnakeDetectionResponse({
    required this.statusCode,
    required this.message,
    required this.isSuccess,
    this.data,
    this.error,
  });

  factory SnakeDetectionResponse.fromJson(Map<String, dynamic> json) {
    return SnakeDetectionResponse(
      statusCode: json['status_code'] ?? 0,
      message: json['message'] ?? '',
      isSuccess: json['is_success'] ?? false,
      data: json['data'] != null ? DetectionData.fromJson(json['data']) : null,
      error: json['error'],
    );
  }
}

class DetectionData {
  final AiMetadata aiMetadata;
  final List<DetectionResult> results;
  final String recognitionResultId;

  DetectionData({
    required this.aiMetadata,
    required this.results,
    required this.recognitionResultId,
  });

  factory DetectionData.fromJson(Map<String, dynamic> json) {
    return DetectionData(
      aiMetadata: AiMetadata.fromJson(json['ai_metadata'] ?? {}),
      results: (json['results'] as List<dynamic>?)
              ?.map((r) => DetectionResult.fromJson(r))
              .toList() ??
          [],
      recognitionResultId: json['recognition_result_id'] ?? '',
    );
  }
}

class AiMetadata {
  final String modelVersion;
  final int imageWidth;
  final int imageHeight;
  final int detectionCount;
  final Map<String, dynamic> warnings;

  AiMetadata({
    required this.modelVersion,
    required this.imageWidth,
    required this.imageHeight,
    required this.detectionCount,
    required this.warnings,
  });

  factory AiMetadata.fromJson(Map<String, dynamic> json) {
    return AiMetadata(
      modelVersion: json['model_version']?.toString() ?? '',
      imageWidth: json['image_width'] ?? 0,
      imageHeight: json['image_height'] ?? 0,
      detectionCount: json['detection_count'] ?? 0,
      warnings: json['warnings'] ?? {},
    );
  }
}

class DetectionResult {
  final AiDetection aiDetection;
  final SnakeInfo snake;

  DetectionResult({
    required this.aiDetection,
    required this.snake,
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      aiDetection: AiDetection.fromJson(json['ai_detection'] ?? {}),
      snake: SnakeInfo.fromJson(json['snake'] ?? {}),
    );
  }
}

class AiDetection {
  final int classId;
  final String className;
  final double confidence;
  final BoundingBox bbox;

  AiDetection({
    required this.classId,
    required this.className,
    required this.confidence,
    required this.bbox,
  });

  factory AiDetection.fromJson(Map<String, dynamic> json) {
    return AiDetection(
      classId: json['class_id'] ?? 0,
      className: json['class_name'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      bbox: BoundingBox.fromJson(json['bbox'] ?? {}),
    );
  }
}

class BoundingBox {
  final int x1;
  final int y1;
  final int x2;
  final int y2;

  BoundingBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x1: json['x1'] ?? 0,
      y1: json['y1'] ?? 0,
      x2: json['x2'] ?? 0,
      y2: json['y2'] ?? 0,
    );
  }
}

class SnakeInfo {
  final int id;
  final String scientificName;
  final String slug;
  final String commonName;
  final String imageUrl;
  final String description;
  final String identificationSummary;
  final String primaryVenomType;
  final Identification identification;
  final List<SymptomByTime> symptomsByTime;
  final FirstAidGuidelineOverride? firstAidGuidelineOverride;
  final int riskLevel;
  final bool isVenomous;
  final List<SpeciesVenom> speciesVenoms;

  SnakeInfo({
    required this.id,
    required this.scientificName,
    required this.slug,
    required this.commonName,
    required this.imageUrl,
    required this.description,
    required this.identificationSummary,
    required this.primaryVenomType,
    required this.identification,
    required this.symptomsByTime,
    this.firstAidGuidelineOverride,
    required this.riskLevel,
    required this.isVenomous,
    required this.speciesVenoms,
  });

  factory SnakeInfo.fromJson(Map<String, dynamic> json) {
    return SnakeInfo(
      id: json['id'] ?? 0,
      scientificName: json['scientificName'] ?? '',
      slug: json['slug'] ?? '',
      commonName: json['commonName'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      identificationSummary: json['identificationSummary'] ?? '',
      primaryVenomType: json['primaryVenomType'] ?? '',
      identification: Identification.fromJson(json['identification'] ?? {}),
      symptomsByTime: (json['symptomsByTime'] as List<dynamic>?)
              ?.map((s) => SymptomByTime.fromJson(s))
              .toList() ??
          [],
      firstAidGuidelineOverride: json['firstAidGuidelineOverride'] != null
          ? FirstAidGuidelineOverride.fromJson(json['firstAidGuidelineOverride'])
          : null,
      riskLevel: json['riskLevel'] ?? 0,
      isVenomous: json['isVenomous'] ?? false,
      speciesVenoms: (json['speciesVenoms'] as List<dynamic>?)
              ?.map((v) => SpeciesVenom.fromJson(v))
              .toList() ??
          [],
    );
  }
}

class Identification {
  final List<String> physicalTraits;
  final List<String> behaviors;
  final String habitat;

  Identification({
    required this.physicalTraits,
    required this.behaviors,
    required this.habitat,
  });

  factory Identification.fromJson(Map<String, dynamic> json) {
    return Identification(
      physicalTraits: (json['physicalTraits'] as List<dynamic>?)
              ?.map((t) => t.toString())
              .toList() ??
          [],
      behaviors: (json['behaviors'] as List<dynamic>?)
              ?.map((b) => b.toString())
              .toList() ??
          [],
      habitat: json['habitat'] ?? '',
    );
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
      timeRange: json['timeRange'] ?? '',
      signs: (json['signs'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
      isCritical: json['isCritical'] ?? false,
    );
  }
}

class FirstAidGuidelineOverride {
  final String mode;
  final List<String> steps;

  FirstAidGuidelineOverride({
    required this.mode,
    required this.steps,
  });

  factory FirstAidGuidelineOverride.fromJson(Map<String, dynamic> json) {
    return FirstAidGuidelineOverride(
      mode: json['mode'] ?? '',
      steps: (json['steps'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
    );
  }
}

class SpeciesVenom {
  final VenomType venomType;

  SpeciesVenom({required this.venomType});

  factory SpeciesVenom.fromJson(Map<String, dynamic> json) {
    return SpeciesVenom(
      venomType: VenomType.fromJson(json['venomType'] ?? {}),
    );
  }
}

class VenomType {
  final String name;
  final String description;
  final FirstAidGuideline firstAidGuideline;

  VenomType({
    required this.name,
    required this.description,
    required this.firstAidGuideline,
  });

  factory VenomType.fromJson(Map<String, dynamic> json) {
    return VenomType(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      firstAidGuideline: FirstAidGuideline.fromJson(json['firstAidGuideline'] ?? {}),
    );
  }
}

class FirstAidGuideline {
  final String name;
  final FirstAidContent content;
  final String summary;

  FirstAidGuideline({
    required this.name,
    required this.content,
    required this.summary,
  });

  factory FirstAidGuideline.fromJson(Map<String, dynamic> json) {
    return FirstAidGuideline(
      name: json['name'] ?? '',
      content: FirstAidContent.fromJson(json['content'] ?? {}),
      summary: json['summary'] ?? '',
    );
  }
}

class FirstAidContent {
  final List<FirstAidStep> steps;
  final List<FirstAidStep> dos;
  final List<FirstAidStep> donts;

  FirstAidContent({
    required this.steps,
    required this.dos,
    required this.donts,
  });

  factory FirstAidContent.fromJson(Map<String, dynamic> json) {
    return FirstAidContent(
      steps: (json['steps'] as List<dynamic>?)
              ?.map((s) => FirstAidStep.fromJson(s))
              .toList() ??
          [],
      dos: (json['dos'] as List<dynamic>?)
              ?.map((d) => FirstAidStep.fromJson(d))
              .toList() ??
          [],
      donts: (json['donts'] as List<dynamic>?)
              ?.map((d) => FirstAidStep.fromJson(d))
              .toList() ??
          [],
    );
  }
}

class FirstAidStep {
  final String text;
  final String mediaUrl;

  FirstAidStep({
    required this.text,
    required this.mediaUrl,
  });

  factory FirstAidStep.fromJson(Map<String, dynamic> json) {
    return FirstAidStep(
      text: json['text'] ?? '',
      mediaUrl: json['mediaUrl'] ?? '',
    );
  }
}
