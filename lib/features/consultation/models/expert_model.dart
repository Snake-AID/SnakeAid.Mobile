/// Expert model
/// Model for snake expert in consultation feature
class ExpertModel {
  final String id;
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final String? academicRank; // Học hàm: GS, PGS, TS, ThS, BS, etc.
  final String? specialty; // Chuyên môn chính
  final List<String> specialties; // Danh sách chuyên môn
  final bool isVerified;
  final bool isOnline;
  final double rating;
  final int reviewCount;
  final double consultationFee; // Phí tư vấn (VNĐ)
  final int consultationDuration; // Thời gian tư vấn (phút)
  final String? bio; // Giới thiệu
  final int yearsOfExperience;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ExpertModel({
    required this.id,
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    this.academicRank,
    this.specialty,
    required this.specialties,
    required this.isVerified,
    required this.isOnline,
    required this.rating,
    required this.reviewCount,
    required this.consultationFee,
    this.consultationDuration = 30, // Default 30 phút
    this.bio,
    this.yearsOfExperience = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory ExpertModel.fromJson(Map<String, dynamic> json) {
    return ExpertModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      avatarUrl: json['avatarUrl'],
      academicRank: json['academicRank'],
      specialty: json['specialty'],
      specialties: json['specialties'] != null
          ? List<String>.from(json['specialties'])
          : [],
      isVerified: json['isVerified'] ?? false,
      isOnline: json['isOnline'] ?? false,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      consultationFee: (json['consultationFee'] ?? 0).toDouble(),
      consultationDuration: json['consultationDuration'] ?? 30,
      bio: json['bio'],
      yearsOfExperience: json['yearsOfExperience'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'academicRank': academicRank,
      'specialty': specialty,
      'specialties': specialties,
      'isVerified': isVerified,
      'isOnline': isOnline,
      'rating': rating,
      'reviewCount': reviewCount,
      'consultationFee': consultationFee,
      'consultationDuration': consultationDuration,
      'bio': bio,
      'yearsOfExperience': yearsOfExperience,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Get display name with academic rank
  String get displayName {
    if (academicRank != null && academicRank!.isNotEmpty) {
      return '$academicRank. $fullName';
    }
    return fullName;
  }

  /// Get formatted consultation fee
  String get formattedFee {
    final fee = consultationFee.toInt();
    return '${fee.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )} VNĐ/$consultationDuration phút';
  }

  /// Get primary specialty (first in list or specialty field)
  String get primarySpecialty {
    if (specialty != null && specialty!.isNotEmpty) {
      return specialty!;
    }
    if (specialties.isNotEmpty) {
      return specialties.first;
    }
    return 'Chuyên gia rắn';
  }

  @override
  String toString() =>
      'ExpertModel(id: $id, fullName: $fullName, rating: $rating, isOnline: $isOnline)';
}
