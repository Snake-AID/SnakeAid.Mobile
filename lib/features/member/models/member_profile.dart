/// MemberProfile model for GET/PUT /api/members/me/profile
class MemberProfile {
  final String accountId;
  final String? userName;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final bool isActive;
  final int reputationPoints;
  final String? reputationStatus;
  final double? rating;
  final int? ratingCount;
  final List<String> emergencyContacts;
  final bool hasUnderlyingDisease;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MemberProfile({
    required this.accountId,
    this.userName,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    required this.isActive,
    required this.reputationPoints,
    this.reputationStatus,
    this.rating,
    this.ratingCount,
    required this.emergencyContacts,
    required this.hasUnderlyingDisease,
    this.createdAt,
    this.updatedAt,
  });

  factory MemberProfile.fromJson(Map<String, dynamic> json) {
    final contacts = json['emergencyContacts'];
    final List<String> contactsList = contacts is List
        ? contacts.map((e) => e.toString()).toList()
        : <String>[];

    return MemberProfile(
      accountId: json['accountId']?.toString() ?? '',
      userName: json['userName'] as String?,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: (json['avatarUrl'] as String?)?.isNotEmpty == true
          ? json['avatarUrl'] as String
          : null,
      isActive: json['isActive'] as bool? ?? true,
      reputationPoints: json['reputationPoints'] as int? ?? 0,
      reputationStatus: json['reputationStatus'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      ratingCount: json['ratingCount'] as int?,
      emergencyContacts: contactsList,
      hasUnderlyingDisease: json['hasUnderlyingDisease'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }
}
