import 'dart:convert';

class SymptomTrackingResponse {
  final int statusCode;
  final String message;
  final bool isSuccess;
  final SymptomTrackingData? data;
  final String? error;

  SymptomTrackingResponse({
    required this.statusCode,
    required this.message,
    required this.isSuccess,
    this.data,
    this.error,
  });

  factory SymptomTrackingResponse.fromJson(Map<String, dynamic> json) {
    return SymptomTrackingResponse(
      statusCode: json['status_code'] ?? 0,
      message: json['message'] ?? '',
      isSuccess: json['is_success'] ?? false,
      data: json['data'] != null ? SymptomTrackingData.fromJson(json['data']) : null,
      error: json['error'],
    );
  }
}

class SymptomTrackingData {
  final String id;
  final String userId;
  final List<String> symptomsReport;
  final int severityLevel;

  SymptomTrackingData({
    required this.id,
    required this.userId,
    required this.symptomsReport,
    required this.severityLevel,
  });

  factory SymptomTrackingData.fromJson(Map<String, dynamic> json) {
    // Parse symptomsReport from JSON string
    List<String> symptoms = [];
    if (json['symptomsReport'] != null) {
      try {
        final decoded = jsonDecode(json['symptomsReport']);
        if (decoded is List) {
          symptoms = decoded.map((e) => e.toString()).toList();
        }
      } catch (e) {
        symptoms = [];
      }
    }

    return SymptomTrackingData(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      symptomsReport: symptoms,
      severityLevel: json['severityLevel'] ?? 0,
    );
  }
}
