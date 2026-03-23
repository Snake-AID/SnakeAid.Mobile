import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expert_detail_model.dart';
import '../models/review_model.dart';
import '../models/availability_model.dart';
import '../repository/consultation_repository.dart';

/// State for expert detail
class ExpertDetailState {
  final ExpertDetailModel? expert;
  final bool isLoading;
  final String? error;

  const ExpertDetailState({
    this.expert,
    this.isLoading = false,
    this.error,
  });

  ExpertDetailState copyWith({
    ExpertDetailModel? expert,
    bool? isLoading,
    String? error,
  }) {
    return ExpertDetailState(
      expert: expert ?? this.expert,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Provider for expert detail
/// Usage: ref.watch(expertDetailProvider(expertId))
final expertDetailProvider = StateNotifierProvider.family<ExpertDetailNotifier, ExpertDetailState, String>(
  (ref, expertId) {
    final repository = ref.watch(consultationRepositoryProvider);
    return ExpertDetailNotifier(repository: repository, expertId: expertId);
  },
);

/// Notifier for expert detail management
class ExpertDetailNotifier extends StateNotifier<ExpertDetailState> {
  final ConsultationRepository repository;
  final String expertId;

  ExpertDetailNotifier({
    required this.repository,
    required this.expertId,
  }) : super(const ExpertDetailState()) {
    // Load expert detail immediately
    loadExpertDetail();
  }

  /// Load expert detail from API
  Future<void> loadExpertDetail() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final expert = await repository.getExpertDetail(expertId);
      state = state.copyWith(
        expert: expert,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('❌ Error loading expert detail: $e');
      // Load mock data as fallback
      _loadMockData();
    }
  }

  /// Load mock data for testing
  void _loadMockData() {
    debugPrint('📝 Loading mock expert detail data');

    // Generate mock availability for next 7 days
    final now = DateTime.now();
    final availability = List.generate(7, (index) {
      final date = now.add(Duration(days: index));
      final dayOfWeek = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][date.weekday - 1];
      final isAvailable = index != 1 && index != 4; // T3 and T6 not available

      return AvailabilityDay(
        date: date,
        dayOfWeek: dayOfWeek,
        isAvailable: isAvailable,
        timeSlots: isAvailable
            ? [
                TimeSlotEntry(id: 'mock-${index}-1', startTime: '08:00', endTime: '09:00'),
                TimeSlotEntry(id: 'mock-${index}-2', startTime: '10:00', endTime: '11:00'),
                TimeSlotEntry(id: 'mock-${index}-3', startTime: '14:00', endTime: '15:00'),
                TimeSlotEntry(id: 'mock-${index}-4', startTime: '16:00', endTime: '17:00'),
              ]
            : null,
      );
    });

    // Generate mock reviews
    final reviews = [
      ReviewModel(
        id: 'r1',
        expertId: expertId,
        patientId: 'p1',
        patientName: 'Nguyễn Thị B',
        patientAvatarUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAJ9uiK1A0iJmbInWlTfJEKznF04lDv6lIfgILCbFPVXgtXxMhMXKn_uw6cCNdCgBswyHO7sTiUFnDDQYptFd7A9b_cWR2g-SgVVUZBJ6bqyNJkQw09iiKdfIzIIyyCasfXDz0nhnxWeOnpE6ZUmv4IEHY7llcc32FslYaKrfP1o4uPlJAvlHVAZJn-pnBKbpmPcEbQKX-A-k05JnADIeoy2SDrhBcHrgqvkuyO9LmcJcTTjYrOrOS8eJGCg5JVx3zvtXFsGJfuoK8u',
        rating: 5.0,
        comment:
            'Tư vấn rất chi tiết và hữu ích. Bác sĩ An đã trấn an gia đình tôi rất nhiều trong lúc hoảng loạn. Cảm ơn bác sĩ.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ReviewModel(
        id: 'r2',
        expertId: expertId,
        patientId: 'p2',
        patientName: 'Trần Văn C',
        patientAvatarUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuA69qKZDAcrLxGFv3PZAE4FWWoQf4TDDCJx2SIkvhCix34Pw6EnS1hKMYCX8wEpUpl1CDhjmQDAKFkuNWArUT9M-srfEW-5S2tph1RwOvxxs95dGkES4ESJNQqxtotSN-Bvf969AbECbSq70PEhVOxt2hSWqIUXWyURkblmXqtOlQ3N_po2TvHW-hwi1V_JV-JujHuKFfczRIG_vwXbstOLrf5zC4NU55BnVZa3K7yvdjWHAGHqwvxhUN0rO8ZA_9jdFjLDYHM1vOh3',
        rating: 5.0,
        comment:
            'Phản hồi cực kỳ nhanh chóng, chỉ 2 phút sau khi yêu cầu là bác sĩ đã gọi lại. Hướng dẫn sơ cứu rất rõ ràng, dễ hiểu.',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];

    final mockExpert = ExpertDetailModel(
      id: expertId,
      userId: 'user_$expertId',
      fullName: 'Nguyễn Văn An',
      avatarUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB3QUpFDWX2SHO3DXHhkwK1jIpNtKumOYtR9tqCnq6ynbEsh2irNC9Xhl28Kus5qQ_3HildgsILuheBU-QY3dQimcUtE34o0Ba4UMcws-eRfgBXyIjt3-vdC4jb5XghPSuzcRL1q7PF6dMILu9wRJz1CKjEvAq-mT2Vq0TBmH2M-RDsYkxRL29ip6OamqUfs1oY0YlzJZOgobLXUKQ3-pwEBPcLsTZW5d92ITU8Du2eFnNfQIydO2cpTNHUnmGwFsRW91lBhuZTjHM7',
      academicRank: 'TS',
      specialty: 'Rắn Độc Việt Nam',
      specialties: ['Rắn Độc Việt Nam', 'Điều Trị Nọc Độc', 'Cứu Hộ Rắn'],
      isVerified: true,
      isOnline: true,
      rating: 4.9,
      reviewCount: 128,
      consultationFee: 150000,
      consultationDuration: 30,
      bio:
          'Chuyên gia hàng đầu về rắn độc Việt Nam với hơn 15 năm kinh nghiệm. Từng tư vấn cho hơn 500 ca rắn cắn nghiêm trọng. Cam kết mang lại sự hỗ trợ nhanh chóng và chính xác nhất cho cộng đồng...',
      yearsOfExperience: 15,
      createdAt: DateTime.now().subtract(const Duration(days: 1000)),
      experienceList: [
        'Tiến sĩ Sinh học, Đại học Khoa học Tự nhiên',
        '15 năm nghiên cứu về nọc rắn tại Viện Sinh Thái',
        'Cố vấn chuyên môn cho 5 bệnh viện lớn trên toàn quốc',
      ],
      totalConsultations: 500,
      averageResponseTime: '< 5 phút',
      successRate: 98.0,
      consultationFees: {
        30: 150000,
        60: 200000,
      },
      availability: availability,
      reviews: reviews,
    );

    state = state.copyWith(
      expert: mockExpert,
      isLoading: false,
    );
  }

  /// Refresh expert detail
  Future<void> refresh() async {
    await loadExpertDetail();
  }
}
