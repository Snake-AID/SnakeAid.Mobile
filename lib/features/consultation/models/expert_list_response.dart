import 'expert_model.dart';

/// Response model for GET /api/experts
/// Contains list of experts and metadata
class ExpertListResponse {
  final int statusCode;
  final String message;
  final bool isSuccess;
  final ExpertListData? data;
  final dynamic error;

  ExpertListResponse({
    required this.statusCode,
    required this.message,
    required this.isSuccess,
    this.data,
    this.error,
  });

  /// Create from JSON response
  factory ExpertListResponse.fromJson(Map<String, dynamic> json) {
    return ExpertListResponse(
      statusCode: json['status_code'] ?? 0,
      message: json['message'] ?? '',
      isSuccess: json['is_success'] ?? false,
      data: json['data'] != null
          ? ExpertListData.fromJson(json['data'])
          : null,
      error: json['error'],
    );
  }

  @override
  String toString() =>
      'ExpertListResponse(isSuccess: $isSuccess, message: $message)';
}

/// Data container for expert list
class ExpertListData {
  final List<ExpertModel> experts;
  final int totalCount;
  final int onlineCount;

  ExpertListData({
    required this.experts,
    required this.totalCount,
    required this.onlineCount,
  });

  factory ExpertListData.fromJson(Map<String, dynamic> json) {
    // Handle experts array
    List<dynamic> expertsJson = [];
    
    if (json['experts'] != null) {
      // Object with experts field
      expertsJson = json['experts'] as List<dynamic>;
    } else if (json is Map && json.isNotEmpty) {
      // If json is a map but no 'experts' key, assume the map itself contains expert data
      expertsJson = [];
    }

    final experts = expertsJson
        .map((e) => ExpertModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Calculate online count if not provided
    final onlineCount = json['onlineCount'] as int? ??
        experts.where((e) => e.isOnline).length;

    return ExpertListData(
      experts: experts,
      totalCount: json['totalCount'] as int? ?? experts.length,
      onlineCount: onlineCount,
    );
  }

  @override
  String toString() =>
      'ExpertListData(total: $totalCount, online: $onlineCount, experts: ${experts.length})';
}
