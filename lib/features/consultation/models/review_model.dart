/// Review model
/// Model for patient review/feedback
class ReviewModel {
  final String id;
  final String expertId;
  final String patientId;
  final String patientName;
  final String? patientAvatarUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.expertId,
    required this.patientId,
    required this.patientName,
    this.patientAvatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  /// Create from JSON
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      expertId: json['expertId'] ?? '',
      patientId: json['patientId'] ?? '',
      patientName: json['patientName'] ?? '',
      patientAvatarUrl: json['patientAvatarUrl'],
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expertId': expertId,
      'patientId': patientId,
      'patientName': patientName,
      'patientAvatarUrl': patientAvatarUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Get star display string
  String get starDisplay {
    return '★' * rating.round();
  }
}
