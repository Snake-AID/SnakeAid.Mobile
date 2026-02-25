import 'package:json_annotation/json_annotation.dart';
import 'detailed_incident_response.dart'; // For enum types

part 'report_media_response.g.dart';

/// Report Media Response from upload
/// POST /api/media/report
@JsonSerializable()
class ReportMediaResponse {
  /// Unique identifier of the media record (Guid from backend)
  @JsonKey(name: 'id')
  final String id;

  /// Public URL of the uploaded media (Cloudinary)
  @JsonKey(name: 'mediaUrl')
  final String mediaUrl;

  /// Original file name
  @JsonKey(name: 'fileName')
  final String fileName;

  /// MIME content type
  @JsonKey(name: 'contentType')
  final String contentType;

  /// File size in bytes
  @JsonKey(name: 'fileSize')
  final int fileSize;

  /// Reference type (e.g., "Incident", "RescueMission")
  @JsonKey(name: 'referenceType')
  final String referenceType;

  /// Media purpose (e.g., "Evidence", "SnakeIdentification")
  @JsonKey(name: 'purpose')
  final String purpose;

  /// Whether this media requires AI processing
  @JsonKey(name: 'requiresAIProcessing')
  final bool requiresAIProcessing;

  ReportMediaResponse({
    required this.id,
    required this.mediaUrl,
    required this.fileName,
    required this.contentType,
    required this.fileSize,
    required this.referenceType,
    required this.purpose,
    required this.requiresAIProcessing,
  });

  factory ReportMediaResponse.fromJson(Map<String, dynamic> json) =>
      _$ReportMediaResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReportMediaResponseToJson(this);

  /// Convert referenceType string to enum
  MediaReferenceType get referenceTypeEnum =>
      MediaReferenceType.fromString(referenceType);

  /// Convert purpose string to enum
  MediaPurpose get purposeEnum => MediaPurpose.fromString(purpose);
}

/// API Response wrapper for report media upload
/// Matches standard backend response format
class ReportMediaApiResponse {
  final int statusCode;
  final String message;
  final bool isSuccess;
  final ReportMediaResponse? data;
  final String? error;

  ReportMediaApiResponse({
    required this.statusCode,
    required this.message,
    required this.isSuccess,
    this.data,
    this.error,
  });

  factory ReportMediaApiResponse.fromJson(Map<String, dynamic> json) {
    return ReportMediaApiResponse(
      statusCode: json['status_code'] ?? json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      isSuccess: json['is_success'] ?? json['isSuccess'] ?? false,
      data: json['data'] != null
          ? ReportMediaResponse.fromJson(json['data'])
          : null,
      error: json['error'],
    );
  }

  @override
  String toString() =>
      'ReportMediaApiResponse(isSuccess: $isSuccess, message: $message)';
}

/// Complete Mission Request
@JsonSerializable()
class CompleteMissionRequest {
  @JsonKey(name: 'evidenceMediaIds')
  final List<String> evidenceMediaIds;

  @JsonKey(name: 'completionNotes')
  final String? completionNotes;

  CompleteMissionRequest({
    required this.evidenceMediaIds,
    this.completionNotes,
  });

  factory CompleteMissionRequest.fromJson(Map<String, dynamic> json) =>
      _$CompleteMissionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CompleteMissionRequestToJson(this);
}
