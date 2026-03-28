class ConsultationReviewResponse {
  final String id;
  final String? raterId;
  final String? targetUserId;
  final String? referenceId;
  final String? type;
  final int rating;
  final String? comments;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? raterName;
  final String? targetUserName;

  const ConsultationReviewResponse({
    required this.id,
    this.raterId,
    this.targetUserId,
    this.referenceId,
    this.type,
    required this.rating,
    this.comments,
    this.createdAt,
    this.updatedAt,
    this.raterName,
    this.targetUserName,
  });

  factory ConsultationReviewResponse.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return ConsultationReviewResponse(
      id: (json['id'] ?? '').toString(),
      raterId: json['raterId']?.toString(),
      targetUserId: json['targetUserId']?.toString(),
      referenceId: json['referenceId']?.toString(),
      type: json['type']?.toString(),
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comments: json['comments']?.toString(),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      raterName: json['raterName']?.toString(),
      targetUserName: json['targetUserName']?.toString(),
    );
  }
}
