/// ExpertProfile model for GET/PUT /api/experts/me/profile
class ExpertProfile {
  final String accountId;
  final String? userName;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final bool isActive;
  final int? reputationPoints;
  final String? reputationStatus;
  final String? biography;
  final bool isOnline;
  final bool isVerified;
  final double? scheduledConsultationFee;
  final double? emergencyConsultationFee;
  final double? rating;
  final int? ratingCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ExpertProfile({
    required this.accountId,
    this.userName,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    required this.isActive,
    this.reputationPoints,
    this.reputationStatus,
    this.biography,
    required this.isOnline,
    required this.isVerified,
    this.scheduledConsultationFee,
    this.emergencyConsultationFee,
    this.rating,
    this.ratingCount,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpertProfile.fromJson(Map<String, dynamic> json) {
    return ExpertProfile(
      accountId: json['accountId']?.toString() ?? '',
      userName: json['userName'] as String?,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: (json['avatarUrl'] as String?)?.isNotEmpty == true
          ? json['avatarUrl'] as String
          : null,
      isActive: json['isActive'] as bool? ?? true,
      reputationPoints: json['reputationPoints'] as int?,
      reputationStatus: json['reputationStatus'] as String?,
      biography: json['biography'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      scheduledConsultationFee:
          (json['scheduledConsultationFee'] as num?)?.toDouble(),
      emergencyConsultationFee:
          (json['emergencyConsultationFee'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      ratingCount: json['ratingCount'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }
}
