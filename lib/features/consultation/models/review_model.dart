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

  /// Create from JSON (handles both local fields and backend UserFeedbackResponse)
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String? ?? '',
      expertId: json['expertId'] as String? ?? '',
      // backend uses userId for the reviewer
      patientId:
          (json['patientId'] ?? json['userId'] ?? '') as String,
      // backend uses userName or fullName
      patientName: (json['patientName'] ??
              json['userName'] ??
              json['fullName'] ??
              'Người dùng') as String,
      // backend uses userAvatarUrl or avatarUrl
      patientAvatarUrl: (json['patientAvatarUrl'] ??
          json['userAvatarUrl'] ??
          json['avatarUrl']) as String?,
      rating: ((json['rating'] ?? 0) as num).toDouble(),
      // backend may use feedback, content, or comment
      comment: (json['comment'] ??
              json['feedback'] ??
              json['content'] ??
              '') as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
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
