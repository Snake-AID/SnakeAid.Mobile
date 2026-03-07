/// Symptom Configuration Response Model
class SymptomConfigResponse {
  final int statusCode;
  final String message;
  final bool isSuccess;
  final List<GroupedSymptomConfig>? data;
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
                .map((g) => GroupedSymptomConfig.fromJson(g))
                .toList()
          : null,
      error: json['error'],
    );
  }
}

/// Grouped Symptom Configuration (Question Group)
class GroupedSymptomConfig {
  final String groupName;
  final String attributeKey;
  final String attributeLabel;
  final int displayOrder;
  final List<SymptomOption> options;

  GroupedSymptomConfig({
    required this.groupName,
    required this.attributeKey,
    required this.attributeLabel,
    required this.displayOrder,
    required this.options,
  });

  factory GroupedSymptomConfig.fromJson(Map<String, dynamic> json) {
    return GroupedSymptomConfig(
      groupName: json['groupName'] ?? '',
      attributeKey: json['attributeKey'] ?? '',
      attributeLabel: json['attributeLabel'] ?? '',
      displayOrder: json['displayOrder'] ?? 0,
      options:
          (json['options'] as List<dynamic>?)
              ?.map((o) => SymptomOption.fromJson(o))
              .toList() ??
          [],
    );
  }
}

/// Individual Symptom Option within a Question Group
class SymptomOption {
  final int id;
  final String name;
  final String? description;
  final bool isCritical;
  final String? alertMessage;
  final String category;
  final String categoryDisplay;
  final List<TimeScore> timeScoreList;
  final int? venomTypeId;
  final VenomTypeInfo? venomType;
  final bool isActive;

  SymptomOption({
    required this.id,
    required this.name,
    this.description,
    required this.isCritical,
    this.alertMessage,
    required this.category,
    required this.categoryDisplay,
    required this.timeScoreList,
    this.venomTypeId,
    this.venomType,
    required this.isActive,
  });

  factory SymptomOption.fromJson(Map<String, dynamic> json) {
    return SymptomOption(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      isCritical: json['isCritical'] ?? false,
      alertMessage: json['alertMessage'],
      category: json['category'] ?? '',
      categoryDisplay: json['categoryDisplay'] ?? '',
      timeScoreList:
          (json['timeScoreList'] as List<dynamic>?)
              ?.map((t) => TimeScore.fromJson(t))
              .toList() ??
          [],
      venomTypeId: json['venomTypeId'],
      venomType: json['venomType'] != null
          ? VenomTypeInfo.fromJson(json['venomType'])
          : null,
      isActive: json['isActive'] ?? true,
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

  VenomTypeInfo({required this.id, required this.name});

  factory VenomTypeInfo.fromJson(Map<String, dynamic> json) {
    return VenomTypeInfo(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}
