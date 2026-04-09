/// Filtered Snake Response Model for Questionnaire Results
class FilteredSnakeResponse {
  final int statusCode;
  final String message;
  final bool isSuccess;
  final List<FilteredSnake>? data;
  final dynamic error;

  FilteredSnakeResponse({
    required this.statusCode,
    required this.message,
    required this.isSuccess,
    this.data,
    this.error,
  });

  factory FilteredSnakeResponse.fromJson(Map<String, dynamic> json) {
    return FilteredSnakeResponse(
      statusCode: json['status_code'] ?? 0,
      message: json['message'] ?? '',
      isSuccess: json['is_success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List<dynamic>)
              .map((s) => FilteredSnake.fromJson(s))
              .toList()
          : null,
      error: json['error'],
    );
  }
}

/// Filtered Snake Model
class FilteredSnake {
  final int id;
  final String scientificName;
  final String commonName;
  final String imageUrl;
  final bool isVenomous;
  final double riskLevel;
  final int matchScore;
  final int totalAnswered;
  final double matchPercentage;
  final List<String> matchedFeatures;

  FilteredSnake({
    required this.id,
    required this.scientificName,
    required this.commonName,
    required this.imageUrl,
    required this.isVenomous,
    required this.riskLevel,
    required this.matchScore,
    required this.totalAnswered,
    required this.matchPercentage,
    required this.matchedFeatures,
  });

  factory FilteredSnake.fromJson(Map<String, dynamic> json) {
    return FilteredSnake(
      id: json['id'] ?? 0,
      scientificName: json['scientificName'] ?? '',
      commonName: json['commonName'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isVenomous: json['isVenomous'] ?? false,
      riskLevel: (json['riskLevel'] ?? 0).toDouble(),
      matchScore: json['matchScore'] ?? 0,
      totalAnswered: json['totalAnswered'] ?? 0,
      matchPercentage: (json['matchPercentage'] ?? 0).toDouble(),
      matchedFeatures: (json['matchedFeatures'] as List<dynamic>?)
              ?.map((f) => f.toString())
              .toList() ??
          [],
    );
  }
}
