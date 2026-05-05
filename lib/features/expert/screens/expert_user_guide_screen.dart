import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expert_services_and_terms.dart';
import '../providers/expert_services_and_terms_provider.dart';

/// Expert User Guide Screen - Instructions for consulting workflows
class ExpertUserGuideScreen extends ConsumerStatefulWidget {
  const ExpertUserGuideScreen({super.key});

  @override
  ConsumerState<ExpertUserGuideScreen> createState() =>
      _ExpertUserGuideScreenState();
}

class _ExpertUserGuideScreenState extends ConsumerState<ExpertUserGuideScreen> {
  int? _expandedImmediateStep;
  int? _expandedScheduledStep;
  int? _expandedWithdrawalStep;

  // Default mock data for fallback
  late final List<GuideStep> _defaultImmediateSteps;
  late final List<GuideStep> _defaultScheduledSteps;
  late final List<GuideStep> _defaultWithdrawalSteps;

  @override
  void initState() {
    super.initState();
    _initDefaultData();
  }

  void _initDefaultData() {
    _defaultImmediateSteps = [
      GuideStep(
        number: 1,
        title: 'Nhận yêu cầu tư vấn',
        description:
            'Bạn sẽ nhận thông báo khi có khách hàng yêu cầu tư vấn ngay. Hãy kiểm tra thông tin khách hàng và chi tiết vấn đề cần tư vấn.',
        details: [
          'Thông báo push sẽ được gửi ngay',
          'Bạn có 2 phút để chấp nhận hoặc từ chối',
          'Kiểm tra tiểu sử khách hàng để hiểu rõ nhu cầu',
        ],
      ),
      GuideStep(
        number: 2,
        title: 'Chấp nhận yêu cầu',
        description:
            'Nhấp vào "Chấp nhận" để xác nhận bạn sẵn sàng tư vấn cho khách hàng.',
        details: [
          'Nút "Chấp nhận" được highlight để bạn dễ thao tác',
          'Sau khi chấp nhận, hệ thống sẽ thiết lập kết nối',
          'Khách hàng sẽ được thông báo bạn đã chấp nhận',
        ],
      ),
      GuideStep(
        number: 3,
        title: 'Chuẩn bị phiên tư vấn',
        description:
            'Kiểm tra thiết bị: camera, microphone, ánh sáng trước khi bắt đầu.',
        details: [
          'Đảm bảo đèn sáng đủ cho khách hàng thấy rõ',
          'Kiểm tra âm thanh - nói thử và nghe kỹ',
          'Đóng các ứng dụng không cần thiết để ổn định kết nối',
        ],
      ),
      GuideStep(
        number: 4,
        title: 'Bắt đầu phiên video',
        description:
            'Nhấp vào nút "Bắt đầu tư vấn" để kết nối video với khách hàng.',
        details: [
          'Chào hỏi khách hàng thân thiện và chuyên nghiệp',
          'Xác nhận bạn đã hiểu rõ vấn đề cần tư vấn',
          'Nếu cần thêm thông tin, hãy hỏi chi tiết',
        ],
      ),
      GuideStep(
        number: 5,
        title: 'Cung cấp tư vấn',
        description:
            'Lắng nghe khách hàng, đặt câu hỏi, và cung cấp giải pháp chuyên nghiệp.',
        details: [
          'Dùng kiến thức chuyên môn để giải quyết vấn đề',
          'Giải thích rõ ràng để khách hàng dễ hiểu',
          'Có thể sử dụng hình ảnh hoặc tư liệu nếu cần',
        ],
      ),
      GuideStep(
        number: 6,
        title: 'Kết thúc và nhận đánh giá',
        description:
            'Khi hoàn tất tư vấn, kết thúc phiên và khách hàng sẽ đánh giá bạn.',
        details: [
          'Nhấp "Kết thúc tư vấn" khi hoàn tất',
          'Hóa đơn thanh toán sẽ được tạo tự động',
          'Khách hàng sẽ để lại đánh giá và bình luận',
        ],
      ),
    ];

    _defaultScheduledSteps = [
      GuideStep(
        number: 1,
        title: 'Cài đặt lịch khả dụng',
        description:
            'Vào "Cài đặt lịch làm việc" để chọn các khung giờ bạn có thể tư vấn.',
        details: [
          'Chọn các ngày trong tuần bạn sẵn sàng',
          'Đặt khung giờ làm việc (ví dụ: 9:00 - 18:00)',
          'Lưu thay đổi để cập nhật lịch của bạn',
        ],
      ),
      GuideStep(
        number: 2,
        title: 'Khách hàng đặt lịch',
        description:
            'Khách hàng sẽ xem lịch của bạn và chọn thời gian phù hợp để đặt lịch.',
        details: [
          'Họ chỉ có thể chọn trong các khung giờ bạn cài đặt',
          'Họ sẽ cung cấp thông tin chi tiết về vấn đề cần tư vấn',
          'Bạn sẽ nhận được thông báo về đơn đặt lịch',
        ],
      ),
      GuideStep(
        number: 3,
        title: 'Xem xét và phê duyệt',
        description:
            'Kiểm tra thông tin khách hàng và xác nhận có thể tư vấn vào thời gian đó.',
        details: [
          'Xem chi tiết vấn đề khách hàng muốn tư vấn',
          'Kiểm tra lịch của bạn để đảm bảo sẵn sàng',
          'Nhấp "Vào phòng" hoặc "Từ chối" tùy theo tình hình',
        ],
      ),
      GuideStep(
        number: 4,
        title: 'Chuẩn bị cho cuộc hẹn',
        description: 'Trước 15 phút cuộc hẹn, hãy chuẩn bị thiết bị và não bộ.',
        details: [
          'Kiểm tra camera, microphone, ánh sáng',
          'Chuẩn bị tài liệu hoặc hình ảnh nếu cần',
          'Đảm bảo kết nối internet ổn định',
        ],
      ),
      GuideStep(
        number: 5,
        title: 'Tham gia cuộc họp video',
        description:
            'Khi đến giờ, nhấp "Tham gia cuộc hẹn" để kết nối với khách hàng.',
        details: [
          'Chào hỏi khách hàng chuyên nghiệp',
          'Xác nhận lại vấn đề cần tư vấn',
          'Bắt đầu cuộc tư vấn sau khi làm quen',
        ],
      ),
      GuideStep(
        number: 6,
        title: 'Hoàn tất tư vấn',
        description: 'Sau khi tư vấn xong, kết thúc phiên và nhận thanh toán.',
        details: [
          'Tóm tắt những điểm chính đã tư vấn',
          'Cung cấp thông tin liên hệ nếu khách hàng có thêm câu hỏi',
          'Nhấp "Kết thúc" để hoàn tất cuộc hẹn',
        ],
      ),
    ];

    _defaultWithdrawalSteps = [
      GuideStep(
        number: 1,
        title: 'Truy cập Quản lý thu nhập',
        description: 'Mở tab "Cá nhân" và chọn mục "Quản lý thu nhập".',
        details: [
          'Bạn sẽ thấy số dư khả dụng trong ví SnakeAidPay',
          'Kiểm tra lịch sử các phiên tư vấn đã được quyết toán',
        ],
      ),
      GuideStep(
        number: 2,
        title: 'Chọn Rút tiền',
        description: 'Nhấn vào nút "Rút tiền" trên màn hình quản lý.',
        details: [
          'Nhập số tiền bạn muốn rút (tối thiểu 50,000đ)',
          'Đảm bảo số dư trong ví đủ để thực hiện lệnh',
        ],
      ),
      GuideStep(
        number: 3,
        title: 'Nhập thông tin ngân hàng',
        description: 'Cung cấp thông tin tài khoản nhận tiền chính xác.',
        details: [
          'Chọn ngân hàng từ danh sách hỗ trợ',
          'Nhập số tài khoản và tên chủ tài khoản (viết hoa không dấu)',
        ],
      ),
      GuideStep(
        number: 4,
        title: 'Xác nhận và chờ xử lý',
        description: 'Kiểm tra lại thông tin và xác nhận lệnh rút tiền.',
        details: [
          'Lệnh sẽ được gửi tới bộ phận kế toán',
          'Tiền sẽ được chuyển vào tài khoản trong vòng 1-3 ngày làm việc',
        ],
      ),
    ];
  }

  List<GuideStep> _convertToGuideSteps(List<ExpertUsageGuideStep>? apiSteps) {
    if (apiSteps == null || apiSteps.isEmpty) {
      return [];
    }

    return apiSteps
        .map(
          (step) => GuideStep(
            number: step.step ?? 0,
            title: step.title ?? '',
            description: step.details ?? '',
            details: step.details != null ? [step.details!] : [],
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final termsAsync = ref.watch(expertServicesAndTermsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Hướng Dẫn Sử Dụng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
      ),
      body: termsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildGuideContent(
          immediateSteps: _defaultImmediateSteps,
          scheduledSteps: _defaultScheduledSteps,
          withdrawalSteps: _defaultWithdrawalSteps,
        ),
        data: (terms) => _buildGuideContent(
          immediateSteps: _convertToGuideSteps(
            terms.usageGuide?.immediateConsulting,
          ),
          scheduledSteps: _convertToGuideSteps(
            terms.usageGuide?.scheduledConsulting,
          ),
          withdrawalSteps: _convertToGuideSteps(
            terms.usageGuide?.withdrawalGuide,
          ),
        ),
      ),
    );
  }

  Widget _buildGuideContent({
    required List<GuideStep> immediateSteps,
    required List<GuideStep> scheduledSteps,
    required List<GuideStep> withdrawalSteps,
  }) {
    // Use defaults if API data is empty
    final useImmediate = immediateSteps.isNotEmpty
        ? immediateSteps
        : _defaultImmediateSteps;
    final useScheduled = scheduledSteps.isNotEmpty
        ? scheduledSteps
        : _defaultScheduledSteps;
    final useWithdrawal = withdrawalSteps.isNotEmpty
        ? withdrawalSteps
        : _defaultWithdrawalSteps;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // SECTION 1: Immediate Consulting
          _buildSectionHeader(
            'Tư Vấn Ngay',
            description: 'Khách hàng yêu cầu tư vấn ngay lập tức',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(
                useImmediate.length,
                (index) => _buildExpandableStep(
                  step: useImmediate[index],
                  isExpanded: _expandedImmediateStep == index,
                  onTap: () {
                    setState(() {
                      _expandedImmediateStep = _expandedImmediateStep == index
                          ? null
                          : index;
                    });
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // SECTION 2: Scheduled Consulting
          _buildSectionHeader(
            'Tư Vấn Đặt Lịch',
            description: 'Khách hàng đặt lịch tư vấn trước',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(
                useScheduled.length,
                (index) => _buildExpandableStep(
                  step: useScheduled[index],
                  isExpanded: _expandedScheduledStep == index,
                  onTap: () {
                    setState(() {
                      _expandedScheduledStep = _expandedScheduledStep == index
                          ? null
                          : index;
                    });
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // SECTION 3: Withdrawal
          _buildSectionHeader(
            'Hướng dẫn rút tiền',
            description: 'Quy trình nhận thu nhập từ hệ thống',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(
                useWithdrawal.length,
                (index) => _buildExpandableStep(
                  step: useWithdrawal[index],
                  isExpanded: _expandedWithdrawalStep == index,
                  onTap: () {
                    setState(() {
                      _expandedWithdrawalStep = _expandedWithdrawalStep == index
                          ? null
                          : index;
                    });
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? description}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandableStep({
    required GuideStep step,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isExpanded
                    ? const Color(0xFF6C47C2)
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      // Step number circle
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C47C2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${step.number}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: const Color(0xFF6C47C2),
                        size: 24,
                      ),
                    ],
                  ),

                  // Expanded content
                  if (isExpanded) ...[
                    const SizedBox(height: 12),
                    Text(
                      step.description,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C47C2).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          step.details.length,
                          (index) => Padding(
                            padding: EdgeInsets.only(
                              bottom: index < step.details.length - 1 ? 8 : 0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C47C2),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    step.details[index],
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.4,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GuideStep {
  final int number;
  final String title;
  final String description;
  final List<String> details;

  GuideStep({
    required this.number,
    required this.title,
    required this.description,
    required this.details,
  });
}
