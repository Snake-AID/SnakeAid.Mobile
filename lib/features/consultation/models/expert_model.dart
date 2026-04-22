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
  final double consultationFee; // Phí tư vấn (VNĐ) — legacy fallback
  final double scheduledConsultationFee; // Phí đặt lịch tư vấn
  final double emergencyConsultationFee; // Phí tư vấn ngay (khẩn cấp)
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
    this.scheduledConsultationFee = 0,
    this.emergencyConsultationFee = 0,
    this.consultationDuration = 30, // Default 30 phút
    this.bio,
    this.yearsOfExperience = 0,
    required this.createdAt,
    this.updatedAt,
  });

  ExpertModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? avatarUrl,
    String? academicRank,
    String? specialty,
    List<String>? specialties,
    bool? isVerified,
    bool? isOnline,
    double? rating,
    int? reviewCount,
    double? consultationFee,
    double? scheduledConsultationFee,
    double? emergencyConsultationFee,
    int? consultationDuration,
    String? bio,
    int? yearsOfExperience,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpertModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      academicRank: academicRank ?? this.academicRank,
      specialty: specialty ?? this.specialty,
      specialties: specialties ?? this.specialties,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      consultationFee: consultationFee ?? this.consultationFee,
      scheduledConsultationFee:
          scheduledConsultationFee ?? this.scheduledConsultationFee,
      emergencyConsultationFee:
          emergencyConsultationFee ?? this.emergencyConsultationFee,
      consultationDuration: consultationDuration ?? this.consultationDuration,
      bio: bio ?? this.bio,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create from JSON
  factory ExpertModel.fromJson(Map<String, dynamic> json) {
    // Map tất cả field names có thể có từ backend
    // accountId (production) | id (legacy/test)
    final id = (json['accountId'] ?? json['id'] ?? json['expertId'] ?? '').toString();

    // specializations (production) | specialties (legacy)
    final List<dynamic> rawSpecializations =
        json['specializations'] as List<dynamic>? ??
        json['specialties'] as List<dynamic>? ??
        [];
    final specialties = rawSpecializations
        .map((e) => e is Map ? (e['name'] ?? e.toString()) : e.toString())
        .cast<String>()
        .toList();

    return ExpertModel(
      id: id,
      userId: (json['userId'] ?? json['accountId'] ?? json['id'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['name'] ?? '') as String,
      avatarUrl: (json['avatarUrl'] ?? json['profileImage'] ?? json['avatar'])
          as String?,
      academicRank: json['academicRank'] as String?,
      specialty: (json['specialty'] ?? json['specialization'] ??
          (specialties.isNotEmpty ? specialties.first : null)) as String?,
      specialties: specialties,
      isVerified: json['isVerified'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? false,
      rating: ((json['rating'] ?? 0) as num).toDouble(),
      // ratingCount (production) | reviewCount/totalFeedbacks (legacy)
      reviewCount: (json['ratingCount'] ??
              json['reviewCount'] ??
              json['totalFeedbacks'] ??
              json['feedbackCount'] ??
              0) as int,
      consultationFee:
          ((json['consultationFee'] ?? json['fee'] ?? 0) as num).toDouble(),
      scheduledConsultationFee:
          ((json['scheduledConsultationFee'] ?? json['consultationFee'] ?? json['fee'] ?? 0) as num).toDouble(),
      emergencyConsultationFee:
          ((json['emergencyConsultationFee'] ?? 0) as num).toDouble(),
      consultationDuration: (json['consultationDuration'] ?? 30) as int,
      // biography (production) | bio/introduction/description (legacy)
      bio: (json['biography'] ?? json['bio'] ?? json['introduction'] ?? json['description'])
          as String?,
      yearsOfExperience:
          (json['yearsOfExperience'] ?? json['experience'] ?? 0) as int,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
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
      'scheduledConsultationFee': scheduledConsultationFee,
      'emergencyConsultationFee': emergencyConsultationFee,
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
     final fee = (scheduledConsultationFee > 0 
      ? scheduledConsultationFee 
      : consultationFee).round();
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
