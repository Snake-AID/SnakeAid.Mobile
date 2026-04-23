import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/consultation_booking_response.dart';
import '../../models/my_consultation_response.dart';
import '../../repository/consultation_repository.dart';
import 'consultation_completion_screen.dart';
import 'member_consultation_detail_screen.dart';
import '../../providers/consultation_bookings_provider.dart';
import '../../providers/my_consultations_provider.dart';

/// Trạng thái hiển thị của một buổi tư vấn
enum ConsultationStatus {
  active, // Đang diễn ra (confirmed + đến giờ)
  upcoming, // Đã xác nhận, chưa đến giờ
  pendingPayment, // Chờ thanh toán
  completed, // Đã hoàn thành
  cancelled, // Đã hủy
}

/// Internal UI model for a consultation card
class _ConsultationItem {
  final String id; // bookingId — dùng cho highlight, display
  final String? consultationId; // consultationId thật — dùng cho LiveKit token
  final String expertId;
  final String expertName;
  final String expertSpecialty;
  final String? expertAvatarUrl;
  final DateTime scheduledTime;
  final ConsultationStatus status;
  final String serviceType;
  final int feeCost;
  final double? rating;
  final String? problemDescription;
  final String? customerReport;
  final DateTime? customerReportSubmittedAt;
  final bool canReportExpertAbsent;

  const _ConsultationItem({
    required this.id,
    this.consultationId,
    required this.expertId,
    required this.expertName,
    required this.expertSpecialty,
    this.expertAvatarUrl,
    required this.scheduledTime,
    required this.status,
    required this.serviceType,
    required this.feeCost,
    this.rating,
    this.problemDescription,
    this.customerReport,
    this.customerReportSubmittedAt,
    this.canReportExpertAbsent = false,
  });

  /// Map from API my-consultation response to UI model
  factory _ConsultationItem.fromConsultation(MyConsultationResponse c) {
    final now = DateTime.now();
    final scheduledAt = c.startTime ?? c.slotStartTime ?? DateTime.now();

    final ConsultationStatus uiStatus;
    if (c.status == MyConsultationStatus.completed) {
      uiStatus = ConsultationStatus.completed;
    } else if (c.status == MyConsultationStatus.cancelled ||
        c.status == MyConsultationStatus.userAbsent ||
        c.status == MyConsultationStatus.expertAbsent ||
        c.status == MyConsultationStatus.allAbsent) {
      uiStatus = ConsultationStatus.cancelled;
    } else if (c.status == MyConsultationStatus.scheduled) {
      uiStatus = scheduledAt.isAfter(now)
          ? ConsultationStatus.upcoming
          : ConsultationStatus.active;
    } else {
      uiStatus = scheduledAt.isAfter(now)
          ? ConsultationStatus.upcoming
          : ConsultationStatus.active;
    }

    final fee = c.grossPrice?.toInt() ?? 0;
    final serviceType = c.type == MyConsultationType.emergency
        ? 'Tư vấn khẩn cấp'
        : 'Tư vấn đặt lịch';

    return _ConsultationItem(
      id: (c.bookingId != null && c.bookingId!.isNotEmpty)
          ? c.bookingId!
          : c.consultationId,
      consultationId: c.consultationId,
      expertId: c.expertId,
      expertName: c.expertName,
      expertSpecialty: '',
      expertAvatarUrl: null,
      scheduledTime: scheduledAt,
      status: uiStatus,
      serviceType: serviceType,
      feeCost: fee,
      rating: null,
      problemDescription: c.problemDescription,
      customerReport: c.customerReport,
      customerReportSubmittedAt: c.customerReportSubmittedAt,
      canReportExpertAbsent: c.type == MyConsultationType.scheduled,
    );
  }
}

/// Màn hình trang chủ tư vấn chuyên gia
/// Hiển thị lịch sử các buổi tư vấn và cho phép đặt lịch mới
class ConsultationHomeScreen extends ConsumerStatefulWidget {
  /// ID buổi tư vấn vừa được đặt (từ màn hình thanh toán) — sẽ được highlight vàng
  final String? highlightedId;
  final int initialTab;

  const ConsultationHomeScreen({
    super.key,
    this.highlightedId,
    this.initialTab = 0,
  });

  @override
  ConsumerState<ConsultationHomeScreen> createState() =>
      _ConsultationHomeScreenState();
}

class _ConsultationHomeScreenState extends ConsumerState<ConsultationHomeScreen>
    with TickerProviderStateMixin {
  static const int _historyPageSize = 10;

  late TabController _tabController;

  // ── Highlight flash ──────────────────────────────────────────────────────
  String? _highlightedId;
  late AnimationController _flashController;
  late Animation<Color?> _flashColorAnimation;

  // ── Payment loading ───────────────────────────────────────────────────────
  String? _payingId; // bookingId đang được thanh toán

  // ── Member history paging ────────────────────────────────────────────────
  List<_ConsultationItem> _historyItems = [];
  int _historyCurrentPage = 1;
  bool _isLoadingMoreHistory = false;
  bool _hasMoreHistory = true;
  String _historyFirstPageKey = '';

  /// Derive UI item list from provider bookings
  List<_ConsultationItem> _toItems(
    List<MyConsultationResponse> consultations,
    Map<String, double> ratingByConsultationId,
  ) {
    return consultations.map((c) {
      final item = _ConsultationItem.fromConsultation(c);
      final rating = ratingByConsultationId[c.consultationId];
      return _ConsultationItem(
        id: item.id,
        consultationId: item.consultationId,
        expertId: item.expertId,
        expertName: item.expertName,
        expertSpecialty: item.expertSpecialty,
        expertAvatarUrl: item.expertAvatarUrl,
        scheduledTime: item.scheduledTime,
        status: item.status,
        serviceType: item.serviceType,
        feeCost: item.feeCost,
        rating: rating,
        problemDescription: item.problemDescription,
        customerReport: item.customerReport,
        customerReportSubmittedAt: item.customerReportSubmittedAt,
        canReportExpertAbsent: item.canReportExpertAbsent,
      );
    }).toList();
  }

  List<_ConsultationItem> _upcomingList(
    List<MyConsultationResponse> consultations,
    Map<String, double> ratingByConsultationId,
  ) {
    final list =
        _toItems(consultations, ratingByConsultationId)
            .where(
              (c) =>
                  c.status == ConsultationStatus.active ||
                  c.status == ConsultationStatus.upcoming ||
                  c.status == ConsultationStatus.pendingPayment,
            )
            .toList()
          ..sort((a, b) {
            // Active first, then pendingPayment, then by time
            if (a.status == ConsultationStatus.active &&
                b.status != ConsultationStatus.active)
              return -1;
            if (b.status == ConsultationStatus.active &&
                a.status != ConsultationStatus.active)
              return 1;
            if (_highlightedId != null) {
              if (a.id == _highlightedId) return -1;
              if (b.id == _highlightedId) return 1;
            }
            return a.scheduledTime.compareTo(b.scheduledTime);
          });
    return list;
  }

  List<_ConsultationItem> _historyList(
    List<MyConsultationResponse> consultations,
    Map<String, double> ratingByConsultationId,
  ) =>
      _toItems(consultations, ratingByConsultationId)
          .where(
            (c) =>
                c.status == ConsultationStatus.completed ||
                c.status == ConsultationStatus.cancelled,
          )
          .toList()
        ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

  List<_ConsultationItem> _bookingFallbackItems(
    List<ConsultationBookingResponse> bookings,
  ) {
    final now = DateTime.now();
    return bookings
        .where(
          (b) =>
              b.status == ConsultationBookingStatus.pendingPayment ||
              b.status == ConsultationBookingStatus.confirmed,
        )
        .map(
          (b) => _ConsultationItem(
            id: b.id,
            consultationId: b.consultationId,
            expertId: b.expertId,
            expertName: b.expertName,
            expertSpecialty: b.expertSpecialty ?? '',
            expertAvatarUrl: b.expertAvatarUrl,
            scheduledTime: b.scheduledTime,
            status: b.status == ConsultationBookingStatus.pendingPayment
                ? ConsultationStatus.pendingPayment
                : (b.scheduledTime.isAfter(now)
                      ? ConsultationStatus.upcoming
                      : ConsultationStatus.active),
            serviceType: b.consultationType == 'Instant'
                ? 'Tư vấn khẩn cấp'
                : 'Tư vấn đặt lịch',
            feeCost: b.feeCost,
            rating: b.rating,
            problemDescription: b.problemDescription,
            canReportExpertAbsent: b.consultationType == 'Scheduled',
          ),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );

    // Khởi tạo animation highlight vàng
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _flashColorAnimation =
        ColorTween(
          begin: const Color(0xFFFFE082), // Amber 200
          end: Colors.white,
        ).animate(
          CurvedAnimation(parent: _flashController, curve: Curves.easeInOut),
        );

    // Reload data mỗi khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myConsultationsProvider.notifier).loadConsultations();
      ref.read(consultationBookingsProvider.notifier).loadBookings();

      // Nếu có buổi tư vấn vừa được tạo, highlight nó khi danh sách load xong
      if (widget.highlightedId != null) {
        _highlightedId = widget.highlightedId;
        _startFlashAnimation();
      }
    });
  }

  Future<void> _startFlashAnimation() async {
    for (int i = 0; i < 3; i++) {
      if (!mounted) return;
      await _flashController.forward(from: 0.0);
      if (!mounted) return;
      await _flashController.reverse(from: 1.0);
    }
    if (mounted) setState(() => _highlightedId = null);
  }

  Future<void> _refreshAllData() async {
    await Future.wait([
      ref.read(myConsultationsProvider.notifier).loadConsultations(),
      ref.read(consultationBookingsProvider.notifier).loadBookings(),
    ]);
  }

  Future<void> _loadMoreHistory() async {
    if (!mounted || _isLoadingMoreHistory || !_hasMoreHistory) return;

    setState(() => _isLoadingMoreHistory = true);
    try {
      final nextPage = _historyCurrentPage + 1;
      final repo = ref.read(consultationRepositoryProvider);
      final nextConsultations = await repo.getMyConsultations(
        status: 'Completed',
        pageNumber: nextPage,
        pageSize: _historyPageSize,
      );

      if (!mounted) return;

      final reviews = ref.read(myConsultationsProvider).reviewsByConsultationId;
      final ratingByConsultationId = <String, double>{
        for (final entry in reviews.entries)
          if (entry.value != null) entry.key: entry.value!.rating.toDouble(),
      };

      final mapped = _historyList(nextConsultations, ratingByConsultationId);

      if (mapped.isEmpty) {
        setState(() {
          _isLoadingMoreHistory = false;
          _hasMoreHistory = false;
        });
        return;
      }

      final dedup = <String, _ConsultationItem>{
        for (final item in _historyItems) item.id: item,
      };
      for (final item in mapped) {
        dedup[item.id] = item;
      }

      final merged = dedup.values.toList()
        ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

      setState(() {
        _historyItems = merged;
        _historyCurrentPage = nextPage;
        _hasMoreHistory = mapped.length >= _historyPageSize;
        _isLoadingMoreHistory = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMoreHistory = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final consultationsState = ref.watch(myConsultationsProvider);
    final bookingsState = ref.watch(consultationBookingsProvider);
    final ratingByConsultationId = <String, double>{
      for (final entry in consultationsState.reviewsByConsultationId.entries)
        if (entry.value != null) entry.key: entry.value!.rating.toDouble(),
    };
    final ongoingFromNewApi = _upcomingList(
      consultationsState.ongoing,
      ratingByConsultationId,
    );
    final pendingFromLegacyBookings = _bookingFallbackItems(
      bookingsState.bookings,
    );
    final upcomingById = <String, _ConsultationItem>{
      for (final item in [...ongoingFromNewApi, ...pendingFromLegacyBookings])
        item.id: item,
    };
    final upcoming = upcomingById.values.toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    final history = _historyList(
      consultationsState.completed,
      ratingByConsultationId,
    );

    final firstPageKey = history.map((e) => e.id).join('|');
    if (firstPageKey != _historyFirstPageKey) {
      _historyFirstPageKey = firstPageKey;
      _historyItems = history;
      _historyCurrentPage = 1;
      _hasMoreHistory = history.length >= _historyPageSize;
      _isLoadingMoreHistory = false;
    }

    return Scaffold(
      backgroundColor: Colors.white, // Changed to match AppBar and status bar
      body: SafeArea(
        bottom: false, // Allows content to flow to the bottom edge if needed, or keep true if preferred
        child: Column(
          children: [
            // App Bar
            _buildAppBar(context),

            // Tab Bar
            _buildTabBar(upcoming),

            // Tab Content
            Expanded(
              child: Container(
                color: const Color(0xFFF6F8F6), // Moved the slightly grey background here
                child: (consultationsState.isLoading && bookingsState.isLoading)
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF228B22),
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildUpcomingTab(context, upcoming),
                          _buildHistoryTab(
                            context,
                            _historyItems,
                            isLoading: consultationsState.isLoading,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),

      // FAB đặt lịch mới
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/expert-list'),
        backgroundColor: const Color(0xFF228B22),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Đặt Lịch Mới',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.go('/member-home'),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
            ),
          ),
          const Expanded(
            child: Text(
              'Tư Vấn Chuyên Gia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Nút lịch sử thanh toán
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lịch sử thanh toán - Đang phát triển'),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: const Icon(
                Icons.receipt_long_outlined,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(List<_ConsultationItem> upcomingList) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF228B22),
        unselectedLabelColor: const Color(0xFF6B7280),
        indicatorColor: const Color(0xFF228B22),
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Sắp Tới'),
                if (upcomingList.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF228B22),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${upcomingList.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Tab(text: 'Lịch Sử'),
        ],
      ),
    );
  }

  // ─── Tab "Sắp Tới" ────────────────────────────────────────────────────────

  Widget _buildUpcomingTab(
    BuildContext context,
    List<_ConsultationItem> upcomingList,
  ) {
    if (upcomingList.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_today_outlined,
        message: 'Bạn chưa có buổi tư vấn nào sắp tới',
        subMessage: 'Đặt lịch tư vấn với chuyên gia ngay!',
        showBookButton: true,
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF228B22),
      onRefresh: _refreshAllData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // Banner thông tin
          _buildInfoBanner(),
          const SizedBox(height: 16),

          ...upcomingList.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildUpcomingCard(context, item),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF228B22).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF228B22).withOpacity(0.25)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF228B22), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Vào buổi tư vấn trước 5 phút để chuẩn bị thiết bị',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF228B22),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCard(BuildContext context, _ConsultationItem item) {
    final isActive = item.status == ConsultationStatus.active;
    final isHighlighted = item.id == _highlightedId;
    final timeText = _formatScheduledTime(item.scheduledTime);

    Widget card = AnimatedBuilder(
      animation: _flashController,
      builder: (context, child) {
        final bgColor = isHighlighted
            ? (_flashColorAnimation.value ?? Colors.white)
            : Colors.white;
        final borderColor = isHighlighted
            ? Color.lerp(
                const Color(0xFFFFC107),
                const Color(0xFFE5E7EB),
                _flashController.value,
              )
            : isActive
            ? const Color(0xFF228B22)
            : null;

        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: (isHighlighted || isActive)
                ? Border.all(
                    color: borderColor ?? const Color(0xFF228B22),
                    width: isHighlighted ? 2 : 1.5,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: trạng thái
          if (isActive)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF228B22),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Đến giờ tư vấn rồi!',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Expert info row
                Row(
                  children: [
                    _buildAvatar(item),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.expertName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.expertSpecialty,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(item.status),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(color: Color(0xFFF3F4F6), height: 1),
                const SizedBox(height: 14),

                // Thông tin chi tiết
                _buildDetailRow(
                  Icons.medical_services_outlined,
                  item.serviceType,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.access_time, timeText),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.payments_outlined,
                  _formatFee(item.feeCost),
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    // Xem chi tiết
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _viewDetail(context, item),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Chi Tiết',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Nút chính (vào / thanh toán / chờ)
                    Expanded(
                      flex: 2,
                      child:
                          isActive || item.status == ConsultationStatus.upcoming
                          ? ElevatedButton.icon(
                              onPressed: () => _joinConsultation(context, item),
                              icon: const Icon(Icons.video_call, size: 18),
                              label: const Text(
                                'Vào Buổi Tư Vấn',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF228B22),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                            )
                          : item.status == ConsultationStatus.pendingPayment
                          ? ElevatedButton.icon(
                              onPressed: () => _goToPayment(context, item),
                              icon: const Icon(Icons.payment, size: 18),
                              label: const Text(
                                'Thanh Toán Ngay',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF59E0B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: null, // disabled
                              icon: const Icon(Icons.hourglass_empty, size: 18),
                              label: const Text(
                                'Chưa Đến Giờ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE5E7EB),
                                foregroundColor: const Color(0xFF9CA3AF),
                                disabledBackgroundColor: const Color(
                                  0xFFE5E7EB,
                                ),
                                disabledForegroundColor: const Color(
                                  0xFF9CA3AF,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return card;
  }

  // ─── Tab "Lịch Sử" ────────────────────────────────────────────────────────

  Widget _buildHistoryTab(
    BuildContext context,
    List<_ConsultationItem> historyList, {
    required bool isLoading,
  }) {
    if (historyList.isEmpty) {
      if (isLoading) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF228B22),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Đang tải lịch sử tư vấn...',
                style: TextStyle(fontSize: 14, color: Color(0xFF8A8A8A)),
              ),
            ],
          ),
        );
      }

      return _buildEmptyState(
        icon: Icons.history,
        message: 'Chưa có lịch sử tư vấn',
        subMessage: 'Các buổi tư vấn đã hoàn thành sẽ xuất hiện ở đây',
        showBookButton: false,
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF228B22),
      onRefresh: _refreshAllData,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 180) {
            _loadMoreHistory();
          }
          return false;
        },
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: historyList.length + (_isLoadingMoreHistory ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index >= historyList.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            return _buildHistoryCard(context, historyList[index]);
          },
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, _ConsultationItem item) {
    final isCancelled = item.status == ConsultationStatus.cancelled;
    final isEmergencyType = item.serviceType.toLowerCase().contains('khẩn');
    final typeLabel = isEmergencyType ? 'Khẩn Cấp' : 'Đặt Lịch';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            // Expert info row
            Row(
              children: [
                _buildAvatar(item, greyed: isCancelled),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.expertName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCancelled
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isEmergencyType
                              ? const Color(0xFFFEE2E2)
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          typeLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isEmergencyType
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF228B22),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(item.status),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(color: Color(0xFFF3F4F6), height: 1),
            const SizedBox(height: 14),

            // Thông tin chi tiết
            _buildDetailRow(Icons.medical_services_outlined, item.serviceType),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.calendar_today_outlined,
              _formatPastTime(item.scheduledTime),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.payments_outlined,
              isCancelled ? 'Đã hoàn tiền' : _formatFee(item.feeCost),
            ),

            // Rating (nếu đã hoàn thành và có đánh giá)
            if (item.rating != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Color(0xFFFBBF24)),
                  const SizedBox(width: 6),
                  Text(
                    'Đánh giá của bạn: ${item.rating!.toStringAsFixed(1)}/5',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewDetail(context, item),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Xem Chi Tiết',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ),

                // Đặt lại (nếu đã hủy hoặc đã hoàn thành)
                const SizedBox(width: 10),
                if (!isCancelled && item.rating == null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final consultationId = item.consultationId;
                        if (consultationId == null || consultationId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Không tìm thấy phiên tư vấn để đánh giá.',
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ConsultationCompletionScreen(
                              expertName: item.expertName,
                              expertSpecialty: item.expertSpecialty,
                              durationSeconds: 1800,
                              consultationId: consultationId,
                              consultationTime: item.scheduledTime,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.star_border, size: 16),
                      label: const Text(
                        'Đánh Giá',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFBBF24),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  )
                else if (!isCancelled && item.rating != null)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Đã đánh giá',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  )
                else if (isCancelled)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/expert-list'),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text(
                        'Đặt Lại',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
              ],
            ),
              if (item.consultationId != null && item.consultationId!.isNotEmpty) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: TextButton.icon(
                    onPressed: () => _openMessageHistory(context, item),
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text(
                      'Xem Lịch Sử Tin Nhắn',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF228B22),
                      backgroundColor: const Color(0xFFE8F5E9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }

  // ─── Shared Widgets ────────────────────────────────────────────────────────

  Widget _buildAvatar(_ConsultationItem item, {bool greyed = false}) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: greyed
            ? const Color(0xFFE5E7EB)
            : const Color(0xFF228B22).withOpacity(0.1),
      ),
      child: Icon(
        Icons.person,
        size: 28,
        color: greyed ? const Color(0xFF9CA3AF) : const Color(0xFF228B22),
      ),
    );
  }

  Widget _buildStatusBadge(ConsultationStatus status) {
    late Color bgColor;
    late Color textColor;
    late String label;

    switch (status) {
      case ConsultationStatus.active:
        bgColor = const Color(0xFF228B22).withOpacity(0.12);
        textColor = const Color(0xFF228B22);
        label = 'Đang diễn ra';
        break;
      case ConsultationStatus.upcoming:
        bgColor = const Color(0xFF3B82F6).withOpacity(0.12);
        textColor = const Color(0xFF3B82F6);
        label = 'Sắp tới';
        break;
      case ConsultationStatus.pendingPayment:
        bgColor = const Color(0xFFF59E0B).withOpacity(0.12);
        textColor = const Color(0xFFF59E0B);
        label = 'Chờ thanh toán';
        break;
      case ConsultationStatus.completed:
        bgColor = const Color(0xFF228B22).withOpacity(0.12);
        textColor = const Color(0xFF228B22);
        label = 'Hoàn thành';
        break;
      case ConsultationStatus.cancelled:
        bgColor = const Color(0xFFEF4444).withOpacity(0.12);
        textColor = const Color(0xFFEF4444);
        label = 'Đã hủy';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String subMessage,
    required bool showBookButton,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF228B22).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: const Color(0xFF228B22).withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subMessage,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            if (showBookButton) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.push('/expert-list'),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Đặt Lịch Tư Vấn',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF228B22),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _formatScheduledTime(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(now);
    final totalMinutes = diff.inMinutes;

    if (totalMinutes <= 0) {
      return 'Đã đến giờ tư vấn';
    } else if (totalMinutes < 60) {
      return 'Bắt đầu sau $totalMinutes phút';
    } else if (diff.inHours < 24) {
      final hours = diff.inHours;
      final minutes = totalMinutes % 60;
      if (minutes == 0) {
        return 'Bắt đầu sau $hours giờ';
      }
      return 'Bắt đầu sau $hours giờ $minutes phút';
    } else if (diff.inDays == 1) {
      return 'Ngày mai ${_padTime(dt.hour)}:${_padTime(dt.minute)}';
    } else {
      return '${dt.day}/${dt.month}/${dt.year} lúc ${_padTime(dt.hour)}:${_padTime(dt.minute)}';
    }
  }

  String _formatPastTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} lúc ${_padTime(dt.hour)}:${_padTime(dt.minute)}';
  }

  String _padTime(int value) => value.toString().padLeft(2, '0');

  String _formatFee(int fee) {
    final formatted = fee.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$formatted VNĐ';
  }

  void _viewDetail(BuildContext context, _ConsultationItem item) {
    Color statusColor;
    String statusLabel;
    switch (item.status) {
      case ConsultationStatus.active:
        statusColor = const Color(0xFF228B22);
        statusLabel = 'Đang diễn ra';
        break;
      case ConsultationStatus.upcoming:
        statusColor = const Color(0xFF3B82F6);
        statusLabel = 'Sắp tới';
        break;
      case ConsultationStatus.pendingPayment:
        statusColor = const Color(0xFFF59E0B);
        statusLabel = 'Chờ thanh toán';
        break;
      case ConsultationStatus.completed:
        statusColor = const Color(0xFF228B22);
        statusLabel = 'Hoàn thành';
        break;
      case ConsultationStatus.cancelled:
        statusColor = const Color(0xFFEF4444);
        statusLabel = 'Đã hủy';
        break;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MemberConsultationDetailScreen(
          consultationId: item.consultationId,
          expertName: item.expertName,
          expertSpecialty: item.expertSpecialty,
          serviceType: item.serviceType,
          scheduledTime: item.scheduledTime,
          feeCost: item.feeCost,
          statusLabel: statusLabel,
          statusColor: statusColor,
          rating: item.rating,
          problemDescription: item.problemDescription,
          customerReport: item.customerReport,
          customerReportSubmittedAt: item.customerReportSubmittedAt,
        ),
      ),
    );
  }

  void _joinConsultation(BuildContext context, _ConsultationItem item) {
    final roomId = item.consultationId ?? item.id;
    context.push(
      '/video-waiting/$roomId',
      extra: {
        'expertName': item.expertName,
        'expertSpecialty': item.expertSpecialty,
        'canReportExpertAbsent': item.canReportExpertAbsent,
        'scheduledStartAtMs': item.scheduledTime.millisecondsSinceEpoch,
      },
    );
  }

  void _openMessageHistory(BuildContext context, _ConsultationItem item) {
    final consultationId = item.consultationId;
    if (consultationId == null || consultationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phiên tư vấn này chưa có lịch sử tin nhắn.')),
      );
      return;
    }

    context.push(
      '/consultation-message-history/$consultationId',
      extra: {
        'title': item.expertName,
        'isExpertMode': false,
      },
    );
  }

  void _goToPayment(BuildContext context, _ConsultationItem item) {
    final date = item.scheduledTime;
    final dateStr =
        '${_weekdayLabel(date.weekday)}, ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final timeStr =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} (30 phút)';
    final feeStr = item.feeCost <= 0
        ? 'Miễn phí'
        : '${item.feeCost.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} VNĐ';

    context.push(
      '/payment-confirmation/${item.expertId}',
      extra: {
        'consultationType': item.serviceType,
        'selectedDate': dateStr,
        'selectedTime': timeStr,
        'duration': '30 phút',
        'price': feeStr,
        'bookingId': item.id,
        'consultationId': item.consultationId,
        'expertName': item.expertName,
      },
    );
  }

  String _weekdayLabel(int weekday) {
    const labels = {
      DateTime.monday: 'Thứ Hai',
      DateTime.tuesday: 'Thứ Ba',
      DateTime.wednesday: 'Thứ Tư',
      DateTime.thursday: 'Thứ Năm',
      DateTime.friday: 'Thứ Sáu',
      DateTime.saturday: 'Thứ Bảy',
      DateTime.sunday: 'Chủ Nhật',
    };
    return labels[weekday] ?? '';
  }
}
