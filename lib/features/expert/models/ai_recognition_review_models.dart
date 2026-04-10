/// Models for Expert AI Recognition Review Feature
/// Based on /api/experts/ai-recognition endpoints

// ---------------------------------------------------------------------------
// ReportMediaResponse
// ---------------------------------------------------------------------------

class ReportMediaResponse {
  final String id;
  final String mediaUrl;
  final String fileName;
  final String contentType;
  final int fileSize;
  final String referenceType;
  final String purpose;
  final bool requiresAIProcessing;

  const ReportMediaResponse({
    required this.id,
    required this.mediaUrl,
    required this.fileName,
    required this.contentType,
    required this.fileSize,
    required this.referenceType,
    required this.purpose,
    required this.requiresAIProcessing,
  });

  factory ReportMediaResponse.fromJson(Map<String, dynamic> json) {
    return ReportMediaResponse(
      id: json['id'] as String? ?? '',
      mediaUrl: json['mediaUrl'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      contentType: json['contentType'] as String? ?? '',
      fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
      referenceType: json['referenceType'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
      requiresAIProcessing: json['requiresAIProcessing'] as bool? ?? false,
    );
  }
}

// ---------------------------------------------------------------------------
// DetectedSpeciesResponse  (embedded in AI result)
// ---------------------------------------------------------------------------

class DetectedSpeciesResponse {
  final int id;
  final String scientificName;
  final String slug;
  final String commonName;
  final String? imageUrl;
  final String? description;
  final String? identificationSummary;
  final String? primaryVenomType;
  final double riskLevel;
  final bool isVenomous;
  final bool isActive;

  const DetectedSpeciesResponse({
    required this.id,
    required this.scientificName,
    required this.slug,
    required this.commonName,
    this.imageUrl,
    this.description,
    this.identificationSummary,
    this.primaryVenomType,
    required this.riskLevel,
    required this.isVenomous,
    required this.isActive,
  });

  factory DetectedSpeciesResponse.fromJson(Map<String, dynamic> json) {
    return DetectedSpeciesResponse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      scientificName: json['scientificName'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      commonName: json['commonName'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      identificationSummary: json['identificationSummary'] as String?,
      primaryVenomType: json['primaryVenomType'] as String?,
      riskLevel: (json['riskLevel'] as num?)?.toDouble() ?? 0,
      isVenomous: json['isVenomous'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

// ---------------------------------------------------------------------------
// SnakeAIRecognitionResultResponse
// ---------------------------------------------------------------------------

class SnakeAIRecognitionResultResponse {
  final String id;
  final String reportMediaId;
  final String yoloClassName;
  final double confidence;
  final int? detectedSpeciesId;
  final bool isMapped;
  final String status;
  final DetectedSpeciesResponse? detectedSpecies;

  const SnakeAIRecognitionResultResponse({
    required this.id,
    required this.reportMediaId,
    required this.yoloClassName,
    required this.confidence,
    this.detectedSpeciesId,
    required this.isMapped,
    required this.status,
    this.detectedSpecies,
  });

  factory SnakeAIRecognitionResultResponse.fromJson(
      Map<String, dynamic> json) {
    return SnakeAIRecognitionResultResponse(
      id: json['id'] as String? ?? '',
      reportMediaId: json['reportMediaId'] as String? ?? '',
      yoloClassName: json['yoloClassName'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      detectedSpeciesId: (json['detectedSpeciesId'] as num?)?.toInt(),
      isMapped: json['isMapped'] as bool? ?? false,
      status: json['status'] as String? ?? '',
      detectedSpecies: json['detectedSpecies'] != null
          ? DetectedSpeciesResponse.fromJson(
              json['detectedSpecies'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// ExpertReviewItemResponse  (queue list item)
// ---------------------------------------------------------------------------

class ExpertReviewItemResponse {
  final ReportMediaResponse media;
  final SnakeAIRecognitionResultResponse aiResult;

  const ExpertReviewItemResponse({
    required this.media,
    required this.aiResult,
  });

  factory ExpertReviewItemResponse.fromJson(Map<String, dynamic> json) {
    return ExpertReviewItemResponse(
      media: ReportMediaResponse.fromJson(
          json['media'] as Map<String, dynamic>),
      aiResult: SnakeAIRecognitionResultResponse.fromJson(
          json['aiResult'] as Map<String, dynamic>),
    );
  }
}

// ---------------------------------------------------------------------------
// AIRecognitionReviewDetailResponse  (detail view)
// ---------------------------------------------------------------------------

class AIRecognitionReviewDetailResponse {
  final String recognitionResultId;
  final ReportMediaResponse media;
  final SnakeAIRecognitionResultResponse aiResult;

  const AIRecognitionReviewDetailResponse({
    required this.recognitionResultId,
    required this.media,
    required this.aiResult,
  });

  factory AIRecognitionReviewDetailResponse.fromJson(
      Map<String, dynamic> json) {
    return AIRecognitionReviewDetailResponse(
      recognitionResultId: json['recognitionResultId'] as String? ?? '',
      media: ReportMediaResponse.fromJson(
          json['media'] as Map<String, dynamic>),
      aiResult: SnakeAIRecognitionResultResponse.fromJson(
          json['aiResult'] as Map<String, dynamic>),
    );
  }
}

// ---------------------------------------------------------------------------
// ExpertReviewActionResponse  (after verify/reject)
// ---------------------------------------------------------------------------

class ExpertReviewActionResponse {
  final String recognitionResultId;
  final String status;
  final String expertId;
  final DateTime? expertVerifiedAt;
  final int? expertCorrectedSpeciesId;
  final bool isTrainingReady;

  const ExpertReviewActionResponse({
    required this.recognitionResultId,
    required this.status,
    required this.expertId,
    this.expertVerifiedAt,
    this.expertCorrectedSpeciesId,
    required this.isTrainingReady,
  });

  factory ExpertReviewActionResponse.fromJson(Map<String, dynamic> json) {
    return ExpertReviewActionResponse(
      recognitionResultId: json['recognitionResultId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      expertId: json['expertId'] as String? ?? '',
      expertVerifiedAt: json['expertVerifiedAt'] != null
          ? DateTime.tryParse(json['expertVerifiedAt'] as String)
          : null,
      expertCorrectedSpeciesId:
          (json['expertCorrectedSpeciesId'] as num?)?.toInt(),
      isTrainingReady: json['isTrainingReady'] as bool? ?? false,
    );
  }
}

// ---------------------------------------------------------------------------
// ExpertReviewedRecognitionItemResponse  (history list item)
// ---------------------------------------------------------------------------

class ExpertReviewedRecognitionItemResponse {
  final ReportMediaResponse media;
  final SnakeAIRecognitionResultResponse aiResult;
  final String? expertStatus;
  final DateTime? expertReviewedAt;
  final int? expertCorrectedSpeciesId;

  const ExpertReviewedRecognitionItemResponse({
    required this.media,
    required this.aiResult,
    this.expertStatus,
    this.expertReviewedAt,
    this.expertCorrectedSpeciesId,
  });

  factory ExpertReviewedRecognitionItemResponse.fromJson(
      Map<String, dynamic> json) {
    // Handle both 'media+aiResult' shape and flattened shapes
    final mediaJson = json['media'] as Map<String, dynamic>?;
    final aiJson = json['aiResult'] as Map<String, dynamic>?;

    return ExpertReviewedRecognitionItemResponse(
      media: mediaJson != null
          ? ReportMediaResponse.fromJson(mediaJson)
          : ReportMediaResponse(
              id: '',
              mediaUrl: '',
              fileName: '',
              contentType: '',
              fileSize: 0,
              referenceType: '',
              purpose: '',
              requiresAIProcessing: false,
            ),
      aiResult: aiJson != null
          ? SnakeAIRecognitionResultResponse.fromJson(aiJson)
          : SnakeAIRecognitionResultResponse(
              id: json['recognitionResultId'] as String? ?? '',
              reportMediaId: '',
              yoloClassName: '',
              confidence: 0,
              isMapped: false,
              status: json['status'] as String? ?? '',
            ),
      expertStatus: json['expertStatus'] as String? ??
          json['status'] as String? ??
          aiJson?['status'] as String?,
      expertReviewedAt: (() {
        final raw = json['expertReviewedAt'] as String? ??
            json['expertVerifiedAt'] as String?;
        return raw != null ? DateTime.tryParse(raw) : null;
      })(),
      expertCorrectedSpeciesId:
          (json['expertCorrectedSpeciesId'] as num?)?.toInt(),
    );
  }
}

// ---------------------------------------------------------------------------
// Enums as string constants
// ---------------------------------------------------------------------------

abstract class RecognitionStatus {
  static const String processing = 'Processing';
  static const String completed = 'Completed';
  static const String failed = 'Failed';
  static const String expertVerified = 'ExpertVerified';
  static const String expertRejected = 'ExpertRejected';
}

// ---------------------------------------------------------------------------
// Request models
// ---------------------------------------------------------------------------

class ExpertVerifyRecognitionRequest {
  final int correctedSpeciesId;
  final String? expertNotes;

  const ExpertVerifyRecognitionRequest({
    required this.correctedSpeciesId,
    this.expertNotes,
  });

  Map<String, dynamic> toJson() => {
        'correctedSpeciesId': correctedSpeciesId,
        if (expertNotes != null && expertNotes!.isNotEmpty)
          'expertNotes': expertNotes,
      };
}

class ExpertRejectRecognitionRequest {
  final String? expertNotes;

  const ExpertRejectRecognitionRequest({this.expertNotes});

  Map<String, dynamic> toJson() => {
        if (expertNotes != null && expertNotes!.isNotEmpty)
          'expertNotes': expertNotes,
      };
}
