// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_media_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportMediaResponse _$ReportMediaResponseFromJson(Map<String, dynamic> json) =>
    ReportMediaResponse(
      id: json['id'] as String,
      mediaUrl: json['mediaUrl'] as String,
      fileName: json['fileName'] as String,
      contentType: json['contentType'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      referenceType: json['referenceType'] as String,
      purpose: json['purpose'] as String,
      requiresAIProcessing: json['requiresAIProcessing'] as bool,
    );

Map<String, dynamic> _$ReportMediaResponseToJson(
  ReportMediaResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'mediaUrl': instance.mediaUrl,
  'fileName': instance.fileName,
  'contentType': instance.contentType,
  'fileSize': instance.fileSize,
  'referenceType': instance.referenceType,
  'purpose': instance.purpose,
  'requiresAIProcessing': instance.requiresAIProcessing,
};

CompleteMissionRequest _$CompleteMissionRequestFromJson(
  Map<String, dynamic> json,
) => CompleteMissionRequest(
  evidenceMediaIds: (json['evidenceMediaIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  completionNotes: json['completionNotes'] as String?,
);

Map<String, dynamic> _$CompleteMissionRequestToJson(
  CompleteMissionRequest instance,
) => <String, dynamic>{
  'evidenceMediaIds': instance.evidenceMediaIds,
  'completionNotes': instance.completionNotes,
};
