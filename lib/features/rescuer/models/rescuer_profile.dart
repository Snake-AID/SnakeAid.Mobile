/// RescuerProfile model for GET/PUT /api/rescuers/me/profile
class RescuerProfile {
  final String accountId;
  final String? userName;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final bool isActive;
  final int? reputationPoints;
  final String? reputationStatus;
  final bool isOnline;
  final bool isAvailable;
  final String? type;
  final double? rating;
  final int? ratingCount;
  final int? totalMissions;
  final int? completedMissions;
  final DateTime? lastLocationUpdate;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RescuerProfile({
    required this.accountId,
    this.userName,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    required this.isActive,
    this.reputationPoints,
    this.reputationStatus,
    required this.isOnline,
    required this.isAvailable,
    this.type,
    this.rating,
    this.ratingCount,
    this.totalMissions,
    this.completedMissions,
    this.lastLocationUpdate,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  factory RescuerProfile.fromJson(Map<String, dynamic> json) {
    return RescuerProfile(
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
      isOnline: json['isOnline'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? false,
      type: json['type'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      ratingCount: json['ratingCount'] as int?,
      totalMissions: json['totalMissions'] as int?,
      completedMissions: json['completedMissions'] as int?,
      lastLocationUpdate: json['lastLocationUpdate'] != null
          ? DateTime.tryParse(json['lastLocationUpdate'] as String)
          : null,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }
}
