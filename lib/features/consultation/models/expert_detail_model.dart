import 'expert_model.dart';
import 'review_model.dart';
import 'availability_model.dart';

/// Expert detail model
/// Extended model for expert profile detail screen
class ExpertDetailModel extends ExpertModel {
  final List<String> experienceList; // Danh sách kinh nghiệm chi tiết
  final int totalConsultations; // Tổng số ca tư vấn
  final String averageResponseTime; // Thời gian phản hồi trung bình
  final double successRate; // Tỷ lệ thành công (%)
  final Map<int, double> consultationFees; // Bảng giá theo thời lượng {30: 150000, 60: 200000}
  final List<AvailabilityDay> availability; // Lịch trống
  final List<ReviewModel> reviews; // Danh sách đánh giá

  ExpertDetailModel({
    required super.id,
    required super.userId,
    required super.fullName,
    super.avatarUrl,
    super.academicRank,
    super.specialty,
    required super.specialties,
    required super.isVerified,
    required super.isOnline,
    required super.rating,
    required super.reviewCount,
    required super.consultationFee,
    super.scheduledConsultationFee,
    super.emergencyConsultationFee,
    super.consultationDuration,
    super.bio,
    super.yearsOfExperience,
    required super.createdAt,
    super.updatedAt,
    required this.experienceList,
    required this.totalConsultations,
    required this.averageResponseTime,
    required this.successRate,
    required this.consultationFees,
    required this.availability,
    required this.reviews,
  });

  /// Create from JSON
  factory ExpertDetailModel.fromJson(Map<String, dynamic> json) {
    return ExpertDetailModel(
      id: (json['id'] ?? json['expertId'] ?? '').toString(),
      userId: (json['userId'] ?? json['id'] ?? '').toString(),
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
      scheduledConsultationFee: ((json['scheduledConsultationFee'] ?? json['consultationFee'] ?? 0) as num).toDouble(),
      emergencyConsultationFee: ((json['emergencyConsultationFee'] ?? 0) as num).toDouble(),
      consultationDuration: json['consultationDuration'] ?? 30,
      bio: json['bio'],
      yearsOfExperience: json['yearsOfExperience'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      experienceList: json['experienceList'] != null
          ? List<String>.from(json['experienceList'])
          : [],
      totalConsultations: (json['totalConsultations'] ?? 0) as int,
      averageResponseTime: json['averageResponseTimeMinutes'] != null
          ? '${json['averageResponseTimeMinutes']} phút'
          : (json['averageResponseTime'] ?? '< 5 phút') as String,
      successRate: ((json['successRate'] ?? 0) as num).toDouble(),
      consultationFees: json['consultationFees'] != null
          ? Map<int, double>.from(
              (json['consultationFees'] as Map).map(
                (k, v) => MapEntry(int.parse(k.toString()), v.toDouble()),
              ),
            )
          : {},
      availability: json['availability'] != null
          ? (json['availability'] as List)
              .map((item) => AvailabilityDay.fromJson(item))
              .toList()
          : [],
      reviews: json['reviews'] != null
          ? (json['reviews'] as List)
              .map((item) => ReviewModel.fromJson(item))
              .toList()
          : [],
    );
  }

  /// Create from ExpertModel
  factory ExpertDetailModel.fromExpertModel(
    ExpertModel expert, {
    required List<String> experienceList,
    required int totalConsultations,
    required String averageResponseTime,
    required double successRate,
    required Map<int, double> consultationFees,
    required List<AvailabilityDay> availability,
    required List<ReviewModel> reviews,
  }) {
    return ExpertDetailModel(
      id: expert.id,
      userId: expert.userId,
      fullName: expert.fullName,
      avatarUrl: expert.avatarUrl,
      academicRank: expert.academicRank,
      specialty: expert.specialty,
      specialties: expert.specialties,
      isVerified: expert.isVerified,
      isOnline: expert.isOnline,
      rating: expert.rating,
      reviewCount: expert.reviewCount,
      consultationFee: expert.consultationFee,
      scheduledConsultationFee: expert.scheduledConsultationFee,
      emergencyConsultationFee: expert.emergencyConsultationFee,
      consultationDuration: expert.consultationDuration,
      bio: expert.bio,
      yearsOfExperience: expert.yearsOfExperience,
      createdAt: expert.createdAt,
      updatedAt: expert.updatedAt,
      experienceList: experienceList,
      totalConsultations: totalConsultations,
      averageResponseTime: averageResponseTime,
      successRate: successRate,
      consultationFees: consultationFees,
      availability: availability,
      reviews: reviews,
    );
  }

  /// Convert to JSON
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'experienceList': experienceList,
      'totalConsultations': totalConsultations,
      'averageResponseTime': averageResponseTime,
      'successRate': successRate,
      'consultationFees': consultationFees.map((k, v) => MapEntry(k.toString(), v)),
      'availability': availability.map((e) => e.toJson()).toList(),
      'reviews': reviews.map((e) => e.toJson()).toList(),
    });
    return json;
  }
}
