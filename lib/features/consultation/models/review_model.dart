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
      expertId:
          (json['expertId'] ?? json['targetUserId'] ?? json['expert_id'] ?? '')
              as String,
      // Backend variants: patientId/userId/raterId.
      patientId:
        (json['patientId'] ?? json['userId'] ?? json['raterId'] ?? '') as String,
      // Backend variants: patientName/userName/fullName/raterName.
      patientName: (json['patientName'] ??
              json['userName'] ??
              json['fullName'] ??
          json['raterName'] ??
              'Người dùng') as String,
      // Backend variants: patientAvatarUrl/userAvatarUrl/avatarUrl/raterAvatarUrl.
      patientAvatarUrl: (json['patientAvatarUrl'] ??
          json['userAvatarUrl'] ??
        json['avatarUrl'] ??
        json['raterAvatarUrl']) as String?,
      rating: ((json['rating'] ?? json['stars'] ?? 0) as num).toDouble(),
      // Backend variants: comment/comments/feedback/content.
      comment: (json['comment'] ??
          json['comments'] ??
              json['feedback'] ??
              json['content'] ??
              '') as String,
      createdAt: (json['createdAt'] ?? json['reviewedAt']) != null
        ? DateTime.parse((json['createdAt'] ?? json['reviewedAt']) as String)
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
