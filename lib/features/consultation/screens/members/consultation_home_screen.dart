import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/consultation_booking_response.dart';
import '../../providers/consultation_bookings_provider.dart';

/// Trạng thái hiển thị của một buổi tư vấn (derived from ConsultationBookingStatus)
enum ConsultationStatus {
  active,         // Đang diễn ra (confirmed + đến giờ)
  upcoming,       // Đã xác nhận, chưa đến giờ
  pendingPayment, // Chờ thanh toán
  completed,      // Đã hoàn thành
  cancelled,      // Đã hủy
}

/// Internal UI model for a consultation card
class _ConsultationItem {
  final String id;
  final String expertName;
  final String expertSpecialty;
  final String? expertAvatarUrl;
  final DateTime scheduledTime;
  final ConsultationStatus status;
  final String serviceType;
  final int feeCost;
  final double? rating;

  const _ConsultationItem({
    required this.id,
    required this.expertName,
    required this.expertSpecialty,
    this.expertAvatarUrl,
    required this.scheduledTime,
    required this.status,
    required this.serviceType,
    required this.feeCost,
    this.rating,
  });

  /// Map from API booking response to UI model
  factory _ConsultationItem.fromBooking(ConsultationBookingResponse b) {
    final ConsultationStatus uiStatus;
    if (b.status == ConsultationBookingStatus.confirmed) {
      final diff = b.scheduledTime.difference(DateTime.now());
      uiStatus = diff.inMinutes <= 10
          ? ConsultationStatus.active
          : ConsultationStatus.upcoming;
    } else if (b.status == ConsultationBookingStatus.pendingPayment) {
      uiStatus = ConsultationStatus.pendingPayment;
    } else if (b.status == ConsultationBookingStatus.completed) {
      uiStatus = ConsultationStatus.completed;
    } else {
      uiStatus = ConsultationStatus.cancelled;
    }

    return _ConsultationItem(
      id: b.id,
      expertName: b.expertName,
      expertSpecialty: b.expertSpecialty ?? '',
      expertAvatarUrl: b.expertAvatarUrl,
      scheduledTime: b.scheduledTime,
      status: uiStatus,
      serviceType: b.consultationType == 'Instant' ? 'Tư vấn khẩn cấp' : 'Tư vấn đặt lịch',
      feeCost: b.feeCost,
      rating: b.rating,
    );
  }
}

/// Màn hình trang chủ tư vấn chuyên gia
/// Hiển thị lịch sử các buổi tư vấn và cho phép đặt lịch mới
class ConsultationHomeScreen extends ConsumerStatefulWidget {
  /// ID buổi tư vấn vừa được đặt (từ màn hình thanh toán) — sẽ được highlight vàng
  final String? highlightedId;

  const ConsultationHomeScreen({super.key, this.highlightedId});

  @override
  ConsumerState<ConsultationHomeScreen> createState() =>
      _ConsultationHomeScreenState();
}

class _ConsultationHomeScreenState extends ConsumerState<ConsultationHomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // ── Highlight flash ──────────────────────────────────────────────────────
  String? _highlightedId;
  late AnimationController _flashController;
  late Animation<Color?> _flashColorAnimation;

  /// Derive UI item list from provider bookings
  List<_ConsultationItem> _toItems(
      List<ConsultationBookingResponse> bookings) {
    return bookings.map(_ConsultationItem.fromBooking).toList();
  }

  List<_ConsultationItem> _upcomingList(
      List<ConsultationBookingResponse> bookings) {
    final list = _toItems(bookings)
        .where((c) =>
            c.status == ConsultationStatus.active ||
            c.status == ConsultationStatus.upcoming ||
            c.status == ConsultationStatus.pendingPayment)
        .toList()
      ..sort((a, b) {
        // Active first, then pendingPayment, then by time
        if (a.status == ConsultationStatus.active &&
            b.status != ConsultationStatus.active) return -1;
        if (b.status == ConsultationStatus.active &&
            a.status != ConsultationStatus.active) return 1;
        if (_highlightedId != null) {
          if (a.id == _highlightedId) return -1;
          if (b.id == _highlightedId) return 1;
        }
        return a.scheduledTime.compareTo(b.scheduledTime);
      });
    return list;
  }

  List<_ConsultationItem> _historyList(
      List<ConsultationBookingResponse> bookings) =>
      _toItems(bookings)
          .where((c) =>
              c.status == ConsultationStatus.completed ||
              c.status == ConsultationStatus.cancelled)
          .toList()
        ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Khởi tạo animation highlight vàng
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _flashColorAnimation = ColorTween(
      begin: const Color(0xFFFFE082), // Amber 200
      end: Colors.white,
    ).animate(CurvedAnimation(
      parent: _flashController,
      curve: Curves.easeInOut,
    ));

    // Nếu có buổi tư vấn vừa được tạo, highlight nó khi danh sách load xong
    if (widget.highlightedId != null) {
      _highlightedId = widget.highlightedId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startFlashAnimation();
      });
    }
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

  @override
  void dispose() {
    _tabController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsState = ref.watch(consultationBookingsProvider);
    final upcoming = _upcomingList(bookingsState.bookings);
    final history = _historyList(bookingsState.bookings);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(context),

            // Tab Bar
            _buildTabBar(upcoming),

            // Tab Content
            Expanded(
              child: bookingsState.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF228B22)))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildUpcomingTab(context, upcoming),
                        _buildHistoryTab(context, history),
                      ],
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
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
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF1F2937),
              ),
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
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
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
                        horizontal: 6, vertical: 2),
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

  Widget _buildUpcomingTab(BuildContext context,
      List<_ConsultationItem> upcomingList) {
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
      onRefresh: () => ref.read(consultationBookingsProvider.notifier).loadBookings(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // Banner thông tin
          _buildInfoBanner(),
          const SizedBox(height: 16),

          ...upcomingList.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildUpcomingCard(context, item),
              )),
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
        border: Border.all(
          color: const Color(0xFF228B22).withOpacity(0.25),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFF228B22),
            size: 20,
          ),
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
                const Color(0xFFFFC107), const Color(0xFFE5E7EB), _flashController.value)
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
                    width: isHighlighted ? 2 : 1.5)
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
                    Icons.medical_services_outlined, item.serviceType),
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
                      child: isActive
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                            )
                          : item.status == ConsultationStatus.pendingPayment
                              ? ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Thanh toán - Đang phát triển'),
                                      ),
                                    );
                                  },
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
                                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                                    disabledBackgroundColor:
                                        const Color(0xFFE5E7EB),
                                    disabledForegroundColor:
                                        const Color(0xFF9CA3AF),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildHistoryTab(BuildContext context,
      List<_ConsultationItem> historyList) {
    if (historyList.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        message: 'Chưa có lịch sử tư vấn',
        subMessage: 'Các buổi tư vấn đã hoàn thành sẽ xuất hiện ở đây',
        showBookButton: false,
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF228B22),
      onRefresh: () => ref.read(consultationBookingsProvider.notifier).loadBookings(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: historyList
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildHistoryCard(context, item),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, _ConsultationItem item) {
    final isCancelled = item.status == ConsultationStatus.cancelled;

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
                  const Icon(
                    Icons.star,
                    size: 16,
                    color: Color(0xFFFBBF24),
                  ),
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
                // Xem chi tiết (luôn có)
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
                if (!isCancelled && item.rating == null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đánh giá chuyên gia - Đang phát triển'),
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
                  ),
                ] else if (isCancelled) ...[
                  const SizedBox(width: 10),
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
              ],
            ),
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
        color: greyed
            ? const Color(0xFF9CA3AF)
            : const Color(0xFF228B22),
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
        bgColor = const Color(0xFF6B7280).withOpacity(0.12);
        textColor = const Color(0xFF6B7280);
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
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
            ),
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
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            if (showBookButton) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.push('/expert-list'),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Đặt Lịch Tư Vấn',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF228B22),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
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

    if (diff.inMinutes <= 10) {
      return 'Bắt đầu sau ${diff.inMinutes} phút';
    } else if (diff.inHours < 24) {
      return 'Hôm nay ${_padTime(dt.hour)}:${_padTime(dt.minute)}';
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
        (m) => '${m[1]}.');
    return '$formatted VNĐ';
  }

  void _viewDetail(BuildContext context, _ConsultationItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chi tiết buổi tư vấn #${item.id} - Đang phát triển'),
      ),
    );
  }

  void _joinConsultation(BuildContext context, _ConsultationItem item) {
    context.push(
      '/video-waiting/${item.id}',
      extra: {
        'expertName': item.expertName,
        'expertSpecialty': item.expertSpecialty,
      },
    );
  }
}
