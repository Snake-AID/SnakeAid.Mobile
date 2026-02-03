/// Symptom Configuration Response Model
class SymptomConfigResponse {
  final int statusCode;
  final String message;
  final bool isSuccess;
  final List<SymptomConfig>? data;
  final dynamic error;

  SymptomConfigResponse({
    required this.statusCode,
    required this.message,
    required this.isSuccess,
    this.data,
    this.error,
  });

  factory SymptomConfigResponse.fromJson(Map<String, dynamic> json) {
    return SymptomConfigResponse(
      statusCode: json['status_code'] ?? 0,
      message: json['message'] ?? '',
      isSuccess: json['is_success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List<dynamic>)
              .map((s) => SymptomConfig.fromJson(s))
              .toList()
          : null,
      error: json['error'],
    );
  }
}

/// Symptom Configuration Model
class SymptomConfig {
  final int id;
  final String groupName;
  final String attributeKey;
  final String attributeLabel;
  final String? uiHintDisplay;
  final int displayOrder;
  final String name;
  final String description;
  final bool isCritical;
  final String? alertMessage;
  final bool isActive;
  final String category;
  final String categoryDisplay;
  final List<TimeScore> timeScoreList;
  final int? venomTypeId;
  final VenomTypeInfo? venomType;
  final DateTime createdAt;
  final DateTime updatedAt;

  SymptomConfig({
    required this.id,
    required this.groupName,
    required this.attributeKey,
    required this.attributeLabel,
    this.uiHintDisplay,
    required this.displayOrder,
    required this.name,
    required this.description,
    required this.isCritical,
    this.alertMessage,
    required this.isActive,
    required this.category,
    required this.categoryDisplay,
    required this.timeScoreList,
    this.venomTypeId,
    this.venomType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SymptomConfig.fromJson(Map<String, dynamic> json) {
    return SymptomConfig(
      id: json['id'] ?? 0,
      groupName: json['groupName'] ?? '',
      attributeKey: json['attributeKey'] ?? '',
      attributeLabel: json['attributeLabel'] ?? '',
      uiHintDisplay: json['uiHintDisplay'],
      displayOrder: json['displayOrder'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isCritical: json['isCritical'] ?? false,
      alertMessage: json['alertMessage'],
      isActive: json['isActive'] ?? true,
      category: json['category'] ?? '',
      categoryDisplay: json['categoryDisplay'] ?? '',
      timeScoreList: (json['timeScoreList'] as List<dynamic>?)
              ?.map((t) => TimeScore.fromJson(t))
              .toList() ??
          [],
      venomTypeId: json['venomTypeId'],
      venomType: json['venomType'] != null
          ? VenomTypeInfo.fromJson(json['venomType'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
}

/// Time Score Model
class TimeScore {
  final int minMinutes;
  final int maxMinutes;
  final int score;

  TimeScore({
    required this.minMinutes,
    required this.maxMinutes,
    required this.score,
  });

  factory TimeScore.fromJson(Map<String, dynamic> json) {
    return TimeScore(
      minMinutes: json['minMinutes'] ?? 0,
      maxMinutes: json['maxMinutes'] ?? 0,
      score: json['score'] ?? 0,
    );
  }
}

/// Venom Type Info Model
class VenomTypeInfo {
  final int id;
  final String name;

  VenomTypeInfo({
    required this.id,
    required this.name,
  });

  factory VenomTypeInfo.fromJson(Map<String, dynamic> json) {
    return VenomTypeInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}
