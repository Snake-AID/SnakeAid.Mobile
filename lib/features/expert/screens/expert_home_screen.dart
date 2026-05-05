import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repository/expert_analytics_repository.dart';
import '../models/expert_daily_stats.dart';
import '../../../core/providers/http_provider.dart';
import '../../../core/services/emergency_consultation_signalr_service.dart';
import 'expert_profile_screen.dart';
import 'expert_withdraw_money_screen.dart';
import '../../consultation/repository/consultation_repository.dart';
import '../../consultation/models/consultation_booking_response.dart';
import '../../blog/providers/blog_provider.dart';
import '../../blog/models/blog_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notifications/providers/notification_inbox_provider.dart';
import '../../wallet/repository/transaction_repository.dart';
import '../providers/ai_recognition_review_provider.dart';
import '../providers/expert_availability_provider.dart';

/// FutureProvider for today's expert statistics (used in stats grid).
/// Not autoDispose so data is cached for the session (avoids re-spinner on tab switch).
final _expertDailyStatsProvider = FutureProvider<ExpertStats>((ref) {
  return ref
      .watch(expertAnalyticsRepositoryProvider)
      .getStatistics(period: 'day');
});

/// FutureProvider for this month's expert statistics (used in earnings card).
/// Not autoDispose so data is cached for the session (avoids re-spinner on tab switch).
final _expertMonthlyStatsProvider = FutureProvider<ExpertStats>((ref) {
  return ref
      .watch(expertAnalyticsRepositoryProvider)
      .getStatistics(period: 'month');
});

/// FutureProvider for the current expert's bookings from the API.
final _expertBookingsFutureProvider =
    FutureProvider<List<ConsultationBookingResponse>>((ref) {
      return ref.read(consultationRepositoryProvider).getExpertBookings();
    });

/// Map a [ConsultationBookingResponse] to the internal [_ExpertConsultation].
_ExpertConsultation _bookingToExpertConsultation(
  ConsultationBookingResponse b,
) {
  final isScheduled = b.consultationType != 'Instant';

  DateTime normalizeForExpertUi(DateTime value) {
    // Scheduled bookings are currently over-shifted on expert screens.
    // Keep instant flow unchanged and only offset scheduled times back.
    return isScheduled ? value : value.add(const Duration(hours: 7));
  }

  final now = DateTime.now();
  final scheduled = normalizeForExpertUi(b.slotStartTime ?? b.scheduledTime);
  final slotStartTime = b.slotStartTime != null
      ? normalizeForExpertUi(b.slotStartTime!)
      : null;
  final slotEndTime = b.slotEndTime != null
      ? normalizeForExpertUi(b.slotEndTime!)
      : null;
  final bookedAt = b.bookedAt != null
      ? normalizeForExpertUi(b.bookedAt!)
      : null;
  final paymentDeadline = b.paymentDeadline != null
      ? normalizeForExpertUi(b.paymentDeadline!)
      : null;

  final _ExpertConsultationStatus status;
  switch (b.status) {
    case ConsultationBookingStatus.confirmed:
      final diff = scheduled.difference(now);
      // Chỉ hiện "Đến giờ" khi trong vòng 15 phút trước giờ hẹn
      status = diff.inMinutes <= 15
          ? _ExpertConsultationStatus.waiting
          : _ExpertConsultationStatus.upcoming;
      break;
    case ConsultationBookingStatus.completed:
      status = _ExpertConsultationStatus.completed;
      break;
    case ConsultationBookingStatus.expertAbsent:
      status = _ExpertConsultationStatus.expertAbsent;
      break;
    case ConsultationBookingStatus.expertAbsentHandled:
      status = _ExpertConsultationStatus.expertAbsentHandled;
      break;
    default:
      status = _ExpertConsultationStatus.cancelled;
  }
  return _ExpertConsultation(
    id: b.consultationId ?? b.id,
    bookingId: b.id,
    consultationId: b.consultationId,
    roomId: b.roomId,
    userId: b.userId,
    expertId: b.expertId,
    patientName: b.userName ?? 'Bệnh nhân',
    patientAvatarUrl: b.userAvatarUrl,
    patientPhone: '',
    consultationType: b.consultationType == 'Instant' ? 'Khẩn Cấp' : 'Đặt Lịch',
    snakeSuspect: '',
    hasSnakeImage: false,
    scheduledTime: scheduled,
    bookedAt: bookedAt,
    paymentDeadline: paymentDeadline,
    slotStartTime: slotStartTime,
    slotEndTime: slotEndTime,
    status: status,
    feeCost: b.feeCost,
    rating: b.rating,
    durationSeconds: slotEndTime != null && slotStartTime != null
        ? slotEndTime.difference(slotStartTime).inSeconds
        : null,
    durationMinutes: slotEndTime != null && slotStartTime != null
        ? slotEndTime.difference(slotStartTime).inMinutes
        : 45,
    consultationMethod: 'video',
    problemDescription: b.problemDescription,
    questions: null,
    grossPrice: b.grossPrice,
    netPrice: b.netPrice,
  );
}

/// Expert Home Screen - Dashboard for snake experts
class ExpertHomeScreen extends StatefulWidget {
  final int initialTab;
  final int initialConsultationsTab;

  const ExpertHomeScreen({
    super.key,
    this.initialTab = 0,
    this.initialConsultationsTab = 0,
  });

  @override
  State<ExpertHomeScreen> createState() => _ExpertHomeScreenState();
}

class _ExpertHomeScreenState extends State<ExpertHomeScreen> {
  late int _selectedIndex;
  final _homeKey = GlobalKey<_HomeTabState>();
  final _consultationsKey = GlobalKey<_ConsultationsTabState>();

  // Screens are created once and kept alive via IndexedStack.
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
    _screens = [
      _HomeTab(
        key: _homeKey,
        onSeeAll: () => setState(() => _selectedIndex = 1),
      ),
      _ConsultationsTab(
        key: _consultationsKey,
        initialTab: widget.initialConsultationsTab,
      ),
      const _IncomeTab(),
      _ProfileTab(onGoToHistory: _goToConsultationHistory),
    ];
  }

  void _goToConsultationHistory() {
    setState(() => _selectedIndex = 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _consultationsKey.currentState?._tabController.animateTo(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home, 'Trang Chủ'),
                _buildNavItem(1, Icons.medical_services, 'Tư Vấn'),
                _buildNavItem(2, Icons.account_balance_wallet, 'Thu Nhập'),
                _buildNavItem(3, Icons.person, 'Cá Nhân'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final color = isSelected
        ? const Color(0xFF6C47C2)
        : const Color(0xFF999999);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });

        // Reload data when switching to tab
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (index == 0) {
            _homeKey.currentState?.reload();
          } else if (index == 1) {
            _consultationsKey.currentState?.reload();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28, weight: isSelected ? 700 : 400),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Home Tab
class _HomeTab extends ConsumerStatefulWidget {
  final VoidCallback onSeeAll;
  const _HomeTab({super.key, required this.onSeeAll});

  @override
  ConsumerState<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<_HomeTab>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // Monthly stats local state (bypasses module-level FutureProvider caching issues)
  ExpertStats? _monthlyStats;
  bool _statsLoading = true;
  String? _statsError;

  // Instant consultation request popup
  bool _showInstantRequest = false;
  bool _isInstantMinimized = true;
  int _countdownSeconds = 0;
  DateTime? _countdownExpiresAtUtc;
  Timer? _countdownTimer;
  bool _isHandlingInstantAction = false;

  EmergencyConsultationSignalRService? _emergencyInboxService;
  StreamSubscription<EmergencyConsultationRequestEvent>? _emergencyRequestSub;

  EmergencyConsultationRequestEvent? _activeEmergencyRequest;

  String get _instantPatientName =>
      _activeEmergencyRequest?.requesterName ?? 'Người dùng';
  String get _instantConsultationType => 'Khẩn Cấp';
  int get _instantDurationMinutes => 30;
  String get _instantConsultationMethod => 'video';
  int get _instantFeeCost => _activeEmergencyRequest?.feeCost ?? 0;
  String get _instantSnakeSuspect =>
      _activeEmergencyRequest?.snakeSuspect ?? 'Chưa rõ loài rắn';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
    WidgetsBinding.instance.addObserver(this);
    // Handled globally at app root so popup can appear on every expert screen.

    // Reload data mỗi khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(_expertBookingsFutureProvider);
      ref.invalidate(_expertDailyStatsProvider);
      _loadStats();
      _autoGoOnlineIfEnabled();
    });
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() {
      _statsLoading = true;
      _statsError = null;
    });
    try {
      final stats = await ref
          .read(expertAnalyticsRepositoryProvider)
          .getStatistics(period: 'month');
      if (!mounted) return;
      setState(() {
        _monthlyStats = stats;
        _statsLoading = false;
      });
    } catch (e) {
      debugPrint('⚠️ Monthly stats error: $e');
      if (!mounted) return;
      setState(() {
        _statsError = e.toString();
        _statsLoading = false;
      });
    }
  }

  Future<void> _toggleExpertAvailability(bool nextOnline) async {
    final notifier = ref.read(expertAvailabilityProvider.notifier);
    await notifier.setOnline(nextOnline);

    if (!mounted) return;
    final state = ref.read(expertAvailabilityProvider);
    if (state.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.error!)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nextOnline
              ? 'Bạn đã chuyển sang trạng thái online'
              : 'Bạn đã chuyển sang trạng thái offline',
        ),
        backgroundColor: nextOnline ? Colors.green : Colors.grey,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _handleAppResumed();
    }
  }

  Future<void> _handleAppResumed() async {
    await _autoGoOnlineIfEnabled();
  }

  Future<void> _autoGoOnlineIfEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final autoOnline = prefs.getBool('expert_autoOnline') ?? true;
    if (!autoOnline) return;

    final availabilityState = ref.read(expertAvailabilityProvider);
    if (availabilityState.isOnline || availabilityState.isLoading) return;

    final notifier = ref.read(expertAvailabilityProvider.notifier);
    await notifier.setOnline(true);
    if (!mounted) return;

    final nextState = ref.read(expertAvailabilityProvider);
    if (nextState.error == null && nextState.isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tự động chuyển sang trạng thái online'),
          backgroundColor: Color(0xFF6C47C2),
        ),
      );
    }
  }

  // Public method to reload data when tab is selected
  void reload() {
    if (mounted) {
      ref.invalidate(_expertBookingsFutureProvider);
      ref.invalidate(_expertDailyStatsProvider);
      _loadStats();
    }
  }

  Future<void> _initEmergencyInboxRealtime() async {
    try {
      final baseUrl = ref.read(httpServiceProvider).baseUrl;
      _emergencyInboxService = EmergencyConsultationSignalRService(
        baseUrl: baseUrl,
      );

      _emergencyRequestSub = _emergencyInboxService!.requestStream.listen((
        event,
      ) {
        if (!mounted) return;

        final expiresAtUtc = event.expiresAt?.toUtc();
        if (expiresAtUtc == null) {
          debugPrint(
            'EmergencyConsultationRequest thiếu expiresAt: ${event.requestId}',
          );
          return;
        }

        final remainingSeconds = expiresAtUtc
            .difference(DateTime.now().toUtc())
            .inSeconds;
        if (remainingSeconds <= 0) {
          setState(() {
            _showInstantRequest = false;
            _activeEmergencyRequest = null;
            _countdownExpiresAtUtc = null;
            _countdownSeconds = 0;
          });
          return;
        }

        setState(() {
          _activeEmergencyRequest = event;
          _showInstantRequest = true;
          _isInstantMinimized = true;
          _countdownExpiresAtUtc = expiresAtUtc;
          _countdownSeconds = remainingSeconds;
        });
        _startCountdown();
      });

      await _emergencyInboxService!.connectAsExpert();
    } catch (e) {
      debugPrint('Không thể kết nối emergency inbox realtime: $e');
    }
  }

  bool _syncCountdownFromExpiresAt() {
    final expiresAtUtc = _countdownExpiresAtUtc;
    if (expiresAtUtc == null) {
      _countdownSeconds = 0;
      return false;
    }

    final sec = expiresAtUtc.difference(DateTime.now().toUtc()).inSeconds;
    if (sec <= 0) {
      _countdownSeconds = 0;
      return false;
    }

    _countdownSeconds = sec;
    return true;
  }

  void _startCountdown() {
    final hasRemaining = _syncCountdownFromExpiresAt();
    if (!hasRemaining) {
      setState(() {
        _showInstantRequest = false;
        _activeEmergencyRequest = null;
      });
      return;
    }

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final stillValid = _syncCountdownFromExpiresAt();
      if (!stillValid) {
        _countdownTimer?.cancel();
        setState(() {
          _showInstantRequest = false;
          _activeEmergencyRequest = null;
          _countdownExpiresAtUtc = null;
        });
      } else {
        setState(() {});
      }
    });
  }

  String get _countdownLabel =>
      '${(_countdownSeconds ~/ 60).toString().padLeft(2, '0')}:${(_countdownSeconds % 60).toString().padLeft(2, '0')}';

  Future<void> _acceptInstant() async {
    final requestId = _activeEmergencyRequest?.requestId;
    if (requestId == null || requestId.isEmpty) return;
    if (_isHandlingInstantAction) return;

    setState(() => _isHandlingInstantAction = true);

    try {
      final repo = ref.read(consultationRepositoryProvider);
      final accepted = await repo.acceptEmergencyRequest(requestId);

      _countdownTimer?.cancel();
      if (!mounted) return;

      setState(() {
        _showInstantRequest = false;
        _activeEmergencyRequest = null;
        _countdownExpiresAtUtc = null;
        _countdownSeconds = 0;
        _isHandlingInstantAction = false;
      });

      final consultationId = accepted.consultationId;
      if (consultationId == null || consultationId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chấp nhận thành công nhưng chưa có consultationId'),
          ),
        );
        return;
      }

      context.push(
        '/expert-video-waiting/$consultationId',
        extra: {
          'patientName': _instantPatientName,
          'consultationType': _instantConsultationType,
          'feeCost': _instantFeeCost,
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isHandlingInstantAction = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể chấp nhận: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  Future<void> _declineInstant() async {
    final requestId = _activeEmergencyRequest?.requestId;
    if (requestId == null || requestId.isEmpty) return;
    if (_isHandlingInstantAction) return;

    setState(() => _isHandlingInstantAction = true);

    try {
      final repo = ref.read(consultationRepositoryProvider);
      await repo.rejectEmergencyRequest(requestId);

      _countdownTimer?.cancel();
      if (!mounted) return;

      setState(() {
        _showInstantRequest = false;
        _activeEmergencyRequest = null;
        _countdownExpiresAtUtc = null;
        _countdownSeconds = 0;
        _isHandlingInstantAction = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isHandlingInstantAction = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể từ chối: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  String _formatInstantFeeK(int feeCost) {
    final k = feeCost ~/ 1000;
    return '${k.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}K VNĐ';
  }

  void _openDetailFromHome(BuildContext context, _ExpertConsultation c) {
    context.push(
      '/expert-consultation-detail',
      extra: {
        'id': c.id,
        'bookingId': c.bookingId,
        'consultationId': c.consultationId,
        'roomId': c.roomId,
        'userId': c.userId,
        'expertId': c.expertId,
        'patientName': c.patientName,
        'patientAvatarUrl': c.patientAvatarUrl,
        'patientPhone': c.patientPhone,
        'consultationType': c.consultationType,
        'snakeSuspect': c.snakeSuspect,
        'scheduledTime': c.scheduledTime.millisecondsSinceEpoch,
        'bookedAt': c.bookedAt?.millisecondsSinceEpoch,
        'paymentDeadline': c.paymentDeadline?.millisecondsSinceEpoch,
        'slotStartTime': c.slotStartTime?.millisecondsSinceEpoch,
        'slotEndTime': c.slotEndTime?.millisecondsSinceEpoch,
        'statusIndex': c.status.index,
        'feeCost': c.feeCost,
        'rating': c.rating,
        'durationSeconds': c.durationSeconds,
        'durationMinutes': c.durationMinutes,
        'consultationMethod': c.consultationMethod,
        'problemDescription': c.problemDescription,
        'questions': c.questions,
        'grossPrice': c.grossPrice,
        'netPrice': c.netPrice,
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _emergencyRequestSub?.cancel();
    _emergencyInboxService?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availabilityState = ref.watch(expertAvailabilityProvider);

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: Row(
                children: [
                  const SizedBox(width: 8),
                  const Text(
                    'SnakeAid Expert',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C47C2),
                    ),
                  ),
                ],
              ),
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications,
                        color: Color(0xFF2D2D2D),
                      ),
                      onPressed: () => context.push('/notifications'),
                    ),
                    if (ref.watch(notificationInboxProvider).unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC3545),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF6C47C2).withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Container(
                        color: const Color(0xFF6C47C2).withOpacity(0.1),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF6C47C2),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Hero Earnings Card
                  _buildEarningsCard(),
                  const SizedBox(height: 20),

                  // Expert availability
                  _buildAvailabilityCard(availabilityState),
                  const SizedBox(height: 20),

                  // Quick Stats Grid
                  _buildStatsGrid(),
                  const SizedBox(height: 24),

                  // Upcoming Consultations
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Lịch Tư Vấn Sắp Tới',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C47C2),
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onSeeAll,
                        child: const Text(
                          'Xem Tất Cả',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ..._upcomingConsultations.take(3).expand((c) {
                    final dt = c.scheduledTime;
                    final dateStr =
                        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} - ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                    return [
                      _buildConsultationCard(
                        name: c.patientName,
                        type: c.consultationType,
                        date: dateStr,
                        onDetailTap: () => _openDetailFromHome(context, c),
                      ),
                      const SizedBox(height: 12),
                    ];
                  }),

                  // Blog section
                  const SizedBox(height: 8),
                  _buildBlogSection(context),

                  // Snake Library section
                  const SizedBox(height: 24),
                  _buildSnakeLibrarySection(context),

                  const SizedBox(height: 88),
                ]),
              ),
            ),
          ],
        ),

        // Instant Consultation Minimized Bubble
        if (_showInstantRequest && _isInstantMinimized)
          Positioned(
            left: 16,
            bottom: 100,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: GestureDetector(
                    onTap: () => setState(() => _isInstantMinimized = false),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C47C2).withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 3,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C47C2), Color(0xFF9F7AEA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.video_call,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Yêu Cầu Mới',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Cần Tư Vấn Ngay  $_countdownLabel',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        // Instant Consultation Full Popup (covers SOS button too)
        if (_showInstantRequest && !_isInstantMinimized)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF160D1B).withOpacity(0.8),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 40,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                            child: Column(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF6C47C2,
                                    ).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_circle,
                                    size: 40,
                                    color: Color(0xFF6C47C2),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Xác Nhận Bắt Đầu Tư Vấn',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6C47C2),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF3CD),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.timer,
                                        size: 16,
                                        color: Color(0xFFD97706),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Tự từ chối sau $_countdownLabel',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFD97706),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                // Patient Info Card
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAF8FC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF6C47C2,
                                          ).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          color: Color(0xFF6C47C2),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _instantPatientName,
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF160D1B),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Tư vấn $_instantDurationMinutes phút · ${_instantConsultationMethod == 'video' ? 'Video Call' : 'Nhắn Tin'}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                            Text(
                                              _instantSnakeSuspect,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Payment Card
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFD1FAE5),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Phí tư vấn',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF160D1B),
                                            ),
                                          ),
                                          Text(
                                            _formatInstantFeeK(_instantFeeCost),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF160D1B),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF10B981),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.check,
                                                  size: 12,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Đã thanh toán',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(
                                        color: Color(0xFFD1FAE5),
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Bạn sẽ nhận',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF047857),
                                                ),
                                              ),
                                              Text(
                                                '(sau phí nền tảng 10%)',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF6B7280),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            _formatInstantFeeK(
                                              (_instantFeeCost * 0.9).toInt(),
                                            ),
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF059669),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Action Buttons
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _isHandlingInstantAction
                                        ? null
                                        : _acceptInstant,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6C47C2),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 4,
                                      shadowColor: const Color(
                                        0xFF6C47C2,
                                      ).withOpacity(0.4),
                                    ),
                                    child: _isHandlingInstantAction
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Bắt Đầu Ngay',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: OutlinedButton(
                                    onPressed: () => setState(
                                      () => _isInstantMinimized = true,
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      foregroundColor: Colors.grey.shade600,
                                    ),
                                    child: const Text(
                                      'Thu Nhỏ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: _isHandlingInstantAction
                                      ? null
                                      : _declineInstant,
                                  child: const Text(
                                    'Từ Chối',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF999999),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<_ExpertConsultation> get _upcomingConsultations {
    final now = DateTime.now();
    final consultations =
        ref
            .watch(_expertBookingsFutureProvider)
            .whenOrNull(
              data: (bookings) =>
                  bookings.map(_bookingToExpertConsultation).toList(),
            ) ??
        [];
    return consultations
        .where(
          (c) =>
              (c.status == _ExpertConsultationStatus.upcoming ||
                  c.status == _ExpertConsultationStatus.waiting) &&
              !now.isAfter(c.scheduledTime.add(const Duration(minutes: 5))),
        )
        .toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  Widget _buildEarningsCard() {
    final stats = _monthlyStats;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C47C2), Color(0xFF9F7AEA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C47C2).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thu Nhập Tháng Này',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (_statsLoading)
            const SizedBox(
              height: 44,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white54,
                  ),
                ),
              ),
            )
          else if (stats == null)
            GestureDetector(
              onTap: _loadStats,
              child: const Text(
                '--',
                style: TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatIncome(stats.totalIncome),
                  style: const TextStyle(
                    fontSize: 36,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    stats.currency,
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white24, width: 1)),
            ),
            child: _statsLoading
                ? const Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.white38,
                        size: 18,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '— Tư Vấn Hoàn Thành',
                        style: TextStyle(fontSize: 14, color: Colors.white38),
                      ),
                      SizedBox(width: 16),
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  )
                : stats == null
                ? GestureDetector(
                    onTap: _loadStats,
                    child: const Row(
                      children: [
                        Icon(Icons.refresh, color: Colors.white54, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Nhấn để thử lại',
                          style: TextStyle(fontSize: 13, color: Colors.white54),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${stats.completedConsultations} Tư Vấn Hoàn Thành',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 1),
                      Container(width: 1, height: 16, color: Colors.white30),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.inbox_outlined,
                        color: Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${stats.consultationRequests} Yêu Cầu',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard(ExpertAvailabilityState availabilityState) {
    final isOnline = availabilityState.isOnline;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isOnline
                          ? const Color(0xFF10B981)
                          : const Color(0xFF999999),
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (isOnline)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      availabilityState.isLoading
                          ? 'ĐANG KẾT NỐI...'
                          : (isOnline ? 'ĐANG ONLINE' : 'OFFLINE'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: availabilityState.isLoading
                            ? const Color(0xFFFFA726)
                            : (isOnline
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF999999)),
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(
                          Icons.video_call,
                          size: 14,
                          color: Color(0xFF999999),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Bật để nhận tư vấn khẩn cấp',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Switch(
                value: isOnline,
                activeColor: const Color(0xFF6C47C2),
                onChanged: availabilityState.isLoading
                    ? null
                    : _toggleExpertAvailability,
              ),
            ],
          ),
          if (availabilityState.error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 16,
                    color: Color(0xFFD32F2F),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      availabilityState.error!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFD32F2F),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trạng thái kết nối',
                style: TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: availabilityState.isConnected
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  availabilityState.isConnected ? 'Đã kết nối' : 'Chưa kết nối',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: availabilityState.isConnected
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFF757575),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Format income: 1500000 → "1.5M", 500000 → "500K", etc.
  String _formatIncome(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  Widget _buildStatsGrid() {
    final statsAsync = ref.watch(_expertDailyStatsProvider);
    return statsAsync.when(
      loading: () => Row(
        children: List.generate(
          2,
          (_) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF0F0F0)),
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF6C47C2),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      error: (_, __) => Row(
        children: [
          Expanded(
            child: _buildStatCard('Yêu Cầu', '--', const Color(0xFF6C47C2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Hoàn Thành', '--', const Color(0xFF28A745)),
          ),
        ],
      ),
      data: (stats) => Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Yêu Cầu Hôm Nay',
              '${stats.consultationRequests}',
              const Color(0xFF6C47C2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Hoàn Thành Hôm Nay',
              '${stats.completedConsultations}',
              const Color(0xFF28A745),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationCard({
    required String name,
    required String type,
    required String date,
    VoidCallback? onDetailTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: Color(0xFF6C47C2), width: 6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C47C2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            type.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6C47C2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: Color(0xFF999999),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Color(0xFF999999)),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton(
              onPressed: onDetailTap,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF6C47C2), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: const Color(0xFF6C47C2),
                overlayColor: const Color(0xFF6C47C2).withOpacity(0.1),
              ),
              child: const Text(
                'Xem Chi Tiết',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnakeLibrarySection(BuildContext context) {
    const primaryColor = Color(0xFF6C47C2);
    const accentColor = Color(0xFF9F7AEA);
    const aiColor = Color(0xFF10B981);
    final queueState = ref.watch(aiReviewQueueProvider);
    final pendingCount = queueState.items.length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.manage_search,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Công Cụ Hỗ Trợ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF131018),
                      ),
                    ),
                    Text(
                      'Tra cứu & kiểm duyệt nhận diện AI',
                      style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 14),

          // Row: Thư viện loài + Sơ cứu
          Row(
            children: [
              Expanded(
                child: _SnakeLibraryCard(
                  icon: Icons.menu_book_outlined,
                  title: 'Thư Viện Loài',
                  subtitle: 'Nhận biết & phân loại',
                  color: primaryColor,
                  onTap: () => context.pushNamed('expert_snake_library'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SnakeLibraryCard(
                  icon: Icons.health_and_safety_outlined,
                  title: 'Hướng Dẫn\nSơ Cứu',
                  subtitle: 'Xử lý khi bị cắn',
                  color: accentColor,
                  onTap: () =>
                      context.pushNamed('expert_snake_first_aid_guide'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // AI Recognition Review — full-width highlighted row
          Material(
            color: aiColor.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => context.pushNamed('expert_ai_review_queue'),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: aiColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.document_scanner,
                        color: aiColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Xem Xét AI Nhận Diện',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF131018),
                            ),
                          ),
                          Text(
                            'Kiểm duyệt ảnh độ tin cậy thấp',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (pendingCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: aiColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$pendingCount chờ',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 13,
                      color: aiColor.withOpacity(0.7),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlogSection(BuildContext context) {
    final blogState = ref.watch(expertBlogListProvider);
    final recentBlogs = blogState.blogs.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bài Viết Của Tôi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C47C2),
              ),
            ),
            TextButton(
              onPressed: () => context.push('/expert/blogs'),
              child: const Text(
                'Xem tất cả',
                style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (blogState.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(
                color: Color(0xFF6C47C2),
                strokeWidth: 2,
              ),
            ),
          )
        else if (recentBlogs.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF6C47C2).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.article_outlined,
                  color: const Color(0xFF6C47C2).withOpacity(0.5),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bạn chưa có bài viết nào',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () async {
                          await context.push('/expert/blogs/new');
                          ref.read(expertBlogListProvider.notifier).refresh();
                        },
                        child: const Text(
                          'Viết bài đầu tiên ngay →',
                          style: TextStyle(
                            color: Color(0xFF6C47C2),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          ...recentBlogs.map(
            (blog) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildBlogCard(context, blog),
            ),
          ),
      ],
    );
  }

  Widget _buildBlogCard(BuildContext context, BlogModel blog) {
    Color statusColor;
    switch (blog.status) {
      case BlogStatus.draft:
        statusColor = Colors.grey;
        break;
      case BlogStatus.pendingApproval:
        statusColor = Colors.orange;
        break;
      case BlogStatus.published:
        statusColor = const Color(0xFF228B22);
        break;
      case BlogStatus.rejected:
        statusColor = Colors.red;
        break;
    }

    return InkWell(
      onTap: () => context.push('/expert/blogs'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                blog.thumbnailUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 72,
                  height: 72,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blog.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      blogStatusLabel(blog.status),
                      style: TextStyle(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

enum _ExpertConsultationStatus {
  waiting,
  upcoming,
  completed,
  cancelled,
  expertAbsent,
  expertAbsentHandled,
}

class _ExpertConsultation {
  final String id;
  final String bookingId;
  final String? consultationId;
  final String? roomId;
  final String? userId;
  final String expertId;
  final String patientName;
  final String? patientAvatarUrl;
  final String patientPhone;
  final String consultationType;
  final String snakeSuspect;
  final bool hasSnakeImage;
  final DateTime scheduledTime;
  final DateTime? bookedAt;
  final DateTime? paymentDeadline;
  final DateTime? slotStartTime;
  final DateTime? slotEndTime;
  final _ExpertConsultationStatus status;
  final int feeCost;
  final int? grossPrice;
  final int? netPrice;
  final double? rating;
  final int? durationSeconds;
  final int durationMinutes;
  final String consultationMethod; // 'video' | 'chat'
  final String? problemDescription;
  final String? questions;

  const _ExpertConsultation({
    required this.id,
    required this.bookingId,
    this.consultationId,
    this.roomId,
    this.userId,
    required this.expertId,
    required this.patientName,
    this.patientAvatarUrl,
    this.patientPhone = '',
    required this.consultationType,
    required this.snakeSuspect,
    this.hasSnakeImage = false,
    required this.scheduledTime,
    this.bookedAt,
    this.paymentDeadline,
    this.slotStartTime,
    this.slotEndTime,
    required this.status,
    required this.feeCost,
    this.rating,
    this.durationSeconds,
    this.durationMinutes = 45,
    this.consultationMethod = 'video',
    this.problemDescription,
    this.questions,
    this.grossPrice,
    this.netPrice,
  });
}

class _ConsultationsTab extends ConsumerStatefulWidget {
  final int initialTab;

  const _ConsultationsTab({super.key, this.initialTab = 0});

  @override
  ConsumerState<_ConsultationsTab> createState() => _ConsultationsTabState();
}

class _ConsultationsTabState extends ConsumerState<_ConsultationsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _selectedDay;
  late DateTime _weekStart; // Monday

  static const Color _purple = Color(0xFF6C47C2);

  List<_ExpertConsultation> _consultations = [];
  String? _cancellingBookingId;

  List<_ExpertConsultation> _consultationsForDay(DateTime day) {
    return _consultations.where((c) {
      final d = c.scheduledTime;
      if (!(d.year == day.year && d.month == day.month && d.day == day.day)) {
        return false;
      }
      if (c.status != _ExpertConsultationStatus.waiting &&
          c.status != _ExpertConsultationStatus.upcoming) {
        return false;
      }
      return true;
    }).toList()..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  List<_ExpertConsultation> get _historyList =>
      _consultations
          .where(
            (c) =>
                c.status == _ExpertConsultationStatus.completed ||
                c.status == _ExpertConsultationStatus.cancelled ||
                c.status == _ExpertConsultationStatus.expertAbsent ||
                c.status == _ExpertConsultationStatus.expertAbsentHandled,
          )
          .toList()
        ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    final initialTab = widget.initialTab < 0
        ? 0
        : (widget.initialTab > 1 ? 1 : widget.initialTab);
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialTab,
    );
    final today = DateTime.now();
    _selectedDay = DateTime(today.year, today.month, today.day);
    // Week starts from today (not Monday), showing today + next 6 days
    _weekStart = _selectedDay;
    // Rebuild every minute so time-based logic stays current
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });

    // Reload data mỗi khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConsultations();
    });
  }

  // Public method to reload data when tab is selected
  void reload() {
    if (mounted) {
      _loadConsultations();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadConsultations() async {
    if (!mounted) return;
    setState(() {});
    try {
      final repo = ref.read(consultationRepositoryProvider);
      final bookings = await repo.getExpertBookings();
      if (!mounted) return;
      setState(() {
        _consultations = bookings.map(_bookingToExpertConsultation).toList();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {});
    }
  }

  // Navigate to detail screen
  Future<void> _openDetail(BuildContext context, _ExpertConsultation c) async {
    final result = await context.push(
      '/expert-consultation-detail',
      extra: {
        'id': c.id,
        'bookingId': c.bookingId,
        'consultationId': c.consultationId,
        'roomId': c.roomId,
        'userId': c.userId,
        'expertId': c.expertId,
        'patientName': c.patientName,
        'patientPhone': c.patientPhone,
        'consultationType': c.consultationType,
        'snakeSuspect': c.snakeSuspect,
        'scheduledTime': c.scheduledTime.millisecondsSinceEpoch,
        'bookedAt': c.bookedAt?.millisecondsSinceEpoch,
        'paymentDeadline': c.paymentDeadline?.millisecondsSinceEpoch,
        'slotStartTime': c.slotStartTime?.millisecondsSinceEpoch,
        'slotEndTime': c.slotEndTime?.millisecondsSinceEpoch,
        'statusIndex': c.status.index,
        'feeCost': c.feeCost,
        'rating': c.rating,
        'durationSeconds': c.durationSeconds,
        'durationMinutes': c.durationMinutes,
        'consultationMethod': c.consultationMethod,
        'problemDescription': c.problemDescription,
        'questions': c.questions,
        'grossPrice': c.grossPrice,
        'netPrice': c.netPrice,
      },
    );

    if (result == true && mounted) {
      await _loadConsultations();
    }
  }

  Future<void> _cancelScheduledBooking(_ExpertConsultation c) async {
    if (_cancellingBookingId != null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hủy Lịch Tư Vấn?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bạn sắp hủy lịch tư vấn với ${c.patientName}. Hệ thống sẽ xử lý hoàn tiền cho member theo trạng thái booking và gửi thông báo cho member.',
          style: const TextStyle(fontSize: 14, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Giữ Lịch'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC3545),
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác Nhận Hủy'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _cancellingBookingId = c.bookingId);
    try {
      final repo = ref.read(consultationRepositoryProvider);
      await repo.cancelScheduledBooking(c.bookingId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã hủy lịch tư vấn. Member sẽ nhận thông báo.'),
          backgroundColor: Color(0xFF228B22),
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _loadConsultations();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: const Color(0xFFDC3545),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _cancellingBookingId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Lịch Tư Vấn',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF553C9A),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Color(0xFF553C9A)),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDay,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 60)),
                builder: (ctx, child) => Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF6C47C2),
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                final day = DateTime(picked.year, picked.month, picked.day);
                setState(() {
                  _selectedDay = day;
                  _weekStart = day; // re-anchor week to picked day
                });
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: _purple,
          unselectedLabelColor: const Color(0xFF999999),
          indicatorColor: _purple,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Lịch Tư Vấn'),
            Tab(text: 'Lịch Sử'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildScheduleTab(context), _buildHistoryTab(context)],
      ),
    );
  }

  // ── Schedule tab ──────────────────────────────────────────────────────────

  /// Nhãn thứ trong tuần cho một ngày bất kỳ
  String _dayLabel(DateTime day) {
    const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return labels[day.weekday - 1];
  }

  Widget _buildScheduleTab(BuildContext context) {
    final dayConsultations = _consultationsForDay(_selectedDay);
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);

    return Column(
      children: [
        // Week calendar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final day = _weekStart.add(Duration(days: i));
                final isSelected = day == _selectedDay;
                final isToday = day == todayNorm;
                final count = _consultationsForDay(day).length;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedDay = day;
                    // _weekStart KHÔNG thay đổi — giữ nguyên tuần hiện tại
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? _purple : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? _purple
                            : (isToday
                                  ? _purple.withOpacity(0.4)
                                  : const Color(0xFFE8E8E8)),
                        width: isToday && !isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _purple.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _dayLabel(day),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white70
                                : const Color(0xFF999999),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 8,
                          child: count > 0
                              ? Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? Colors.white : _purple,
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected
                                            ? Colors.white.withOpacity(0.8)
                                            : _purple.withOpacity(0.55),
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Date header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Row(
            children: [
              Text(
                _formatFullDate(_selectedDay),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF553C9A),
                ),
              ),
              const SizedBox(width: 10),
              if (dayConsultations.isNotEmpty)
                Row(
                  children: [
                    const Icon(
                      Icons.assignment,
                      size: 16,
                      color: Color(0xFF6C47C2),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${dayConsultations.length} Tư Vấn',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6C47C2),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // Consultation list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadConsultations,
            child: dayConsultations.isEmpty
                ? ListView(
                    children: [SizedBox(height: 120, child: _buildEmptyDay())],
                  )
                : _buildDayList(context, dayConsultations),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyDay() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_available,
            size: 56,
            color: _purple.withOpacity(0.25),
          ),
          const SizedBox(height: 14),
          const Text(
            'Không có lịch tư vấn',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF999999),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayList(BuildContext context, List<_ExpertConsultation> list) {
    // Group by time of day
    final morning = list.where((c) => c.scheduledTime.hour < 12).toList();
    final afternoon = list
        .where((c) => c.scheduledTime.hour >= 12 && c.scheduledTime.hour < 17)
        .toList();
    final evening = list.where((c) => c.scheduledTime.hour >= 17).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (morning.isNotEmpty) ...[
          _buildSectionHeader('BUỔI SÁNG'),
          ...morning.map((c) => _buildScheduleCard(context, c)),
        ],
        if (afternoon.isNotEmpty) ...[
          _buildSectionHeader('BUỔI CHIỀU'),
          ...afternoon.map((c) => _buildScheduleCard(context, c)),
        ],
        if (evening.isNotEmpty) ...[
          _buildSectionHeader('BUỔI TỐI'),
          ...evening.map((c) => _buildScheduleCard(context, c)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF999999),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildPatientAvatar(String? avatarUrl, {double size = 40}) {
    final url = (avatarUrl ?? '').trim();
    final hasAvatar = url.isNotEmpty;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _purple.withOpacity(0.08),
        image: hasAvatar
            ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
            : null,
      ),
      child: hasAvatar
          ? null
          : Icon(Icons.person, color: _purple, size: size * 0.5),
    );
  }

  Widget _buildScheduleCard(BuildContext context, _ExpertConsultation c) {
    final isWaiting = c.status == _ExpertConsultationStatus.waiting;
    // Cho phép expert vào video call bất cứ lúc nào (không cần chờ đến giờ)
    final canStart =
        c.status == _ExpertConsultationStatus.waiting ||
        c.status == _ExpertConsultationStatus.upcoming;
    final hour = c.scheduledTime.hour;
    final minute = c.scheduledTime.minute.toString().padLeft(2, '0');
    final amPm = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour.toString().padLeft(2, '0');

    // Status badge
    String statusLabel;
    Color statusBg;
    Color statusText;
    if (isWaiting) {
      statusLabel = 'ĐẾN GIỜ';
      statusBg = const Color(0xFFDC3545).withOpacity(0.1);
      statusText = const Color(0xFFDC3545);
    } else if (!canStart) {
      statusLabel = 'CHƯA ĐẾN GIỜ';
      statusBg = const Color(0xFFAAAAAA).withOpacity(0.12);
      statusText = const Color(0xFF999999);
    } else {
      statusLabel = 'SẮP TỚI';
      statusBg = _purple.withOpacity(0.1);
      statusText = _purple;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWaiting
              ? const Color(0xFFDC3545).withOpacity(0.25)
              : const Color(0xFFEEEEEE),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Time column
            Container(
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: const Color(0xFFF0F0F0), width: 1),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '$displayHour:$minute',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isWaiting ? const Color(0xFFDC3545) : _purple,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    amPm,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: statusText,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _buildPatientAvatar(
                                    c.patientAvatarUrl,
                                    size: 36,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      c.patientName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A1A2E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if (c.snakeSuspect.trim().isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.pest_control,
                                      size: 14,
                                      color: Color(0xFF999999),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      c.snakeSuspect,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF555555),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        // Snake image placeholder
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: c.hasSnakeImage
                                ? const Color(0xFFDC3545).withOpacity(0.08)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: c.hasSnakeImage
                              ? const Icon(
                                  Icons.dangerous,
                                  color: Color(0xFFDC3545),
                                  size: 28,
                                )
                              : const Icon(
                                  Icons.image_not_supported,
                                  color: Color(0xFFCCCCCC),
                                  size: 24,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Method + duration
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: c.consultationMethod == 'video'
                                ? _purple.withOpacity(0.08)
                                : Colors.green.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                c.consultationMethod == 'video'
                                    ? Icons.videocam
                                    : Icons.chat,
                                size: 14,
                                color: c.consultationMethod == 'video'
                                    ? _purple
                                    : Colors.green[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                c.consultationMethod == 'video'
                                    ? 'Video Call'
                                    : 'Chat',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: c.consultationMethod == 'video'
                                      ? _purple
                                      : Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${c.durationMinutes} phút',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF999999),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _openDetail(context, c),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFF6C47C2),
                                width: 1.2,
                              ),
                              foregroundColor: _purple,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Chi Tiết',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: canStart
                                ? () {
                                    context.push(
                                      '/expert-video-waiting/${c.id}',
                                      extra: {
                                        'patientName': c.patientName,
                                        'consultationType': c.consultationType,
                                        'feeCost': c.feeCost,
                                      },
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isWaiting
                                  ? const Color(0xFFDC3545)
                                  : (canStart
                                        ? _purple
                                        : const Color(0xFFE0E0E0)),
                              foregroundColor: canStart
                                  ? Colors.white
                                  : const Color(0xFF999999),
                              disabledBackgroundColor: const Color(0xFFE8E8E8),
                              disabledForegroundColor: const Color(0xFF999999),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              isWaiting
                                  ? 'Vào Ngay'
                                  : (canStart ? 'Bắt Đầu' : 'Chưa Đến Giờ'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (canStart) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 34,
                        child: TextButton.icon(
                          onPressed: _cancellingBookingId == c.bookingId
                              ? null
                              : () => _cancelScheduledBooking(c),
                          icon: _cancellingBookingId == c.bookingId
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                )
                              : const Icon(Icons.event_busy_outlined, size: 14),
                          label: const Text(
                            'Hủy lịch tư vấn',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF9CA3AF),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── History tab ───────────────────────────────────────────────────────────

  Widget _buildHistoryTab(BuildContext context) {
    final list = _historyList;
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 56, color: _purple.withOpacity(0.25)),
            const SizedBox(height: 14),
            const Text(
              'Chưa có lịch sử tư vấn',
              style: TextStyle(fontSize: 15, color: Color(0xFF999999)),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadConsultations,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _buildHistoryCard(context, list[i]),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, _ExpertConsultation item) {
    final isDone = item.status == _ExpertConsultationStatus.completed;
    final isExpertAbsent =
        item.status == _ExpertConsultationStatus.expertAbsent;
    final isExpertAbsentHandled =
        item.status == _ExpertConsultationStatus.expertAbsentHandled;

    String statusLabel;
    Color statusColor;
    if (isDone) {
      statusLabel = 'HOÀN THÀNH';
      statusColor = const Color(0xFF28A745);
    } else if (isExpertAbsentHandled) {
      statusLabel = 'ĐÃ HOÀN TIỀN';
      statusColor = const Color(0xFF16A34A);
    } else if (isExpertAbsent) {
      statusLabel = 'VẮNG MẶT';
      statusColor = const Color(0xFFF59E0B);
    } else {
      statusLabel = 'ĐÃ HỦY';
      statusColor = const Color(0xFF999999);
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: statusColor,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildPatientAvatar(item.patientAvatarUrl, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.patientName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatFullDateTime(item.scheduledTime),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
              if (isDone)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '+${_formatFee(item.netPrice ?? item.feeCost)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF28A745),
                      ),
                    ),
                    if (item.durationSeconds != null)
                      Text(
                        _formatDuration(item.durationSeconds!),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF999999),
                        ),
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildHistoryMetaChip(
                icon: Icons.access_time_outlined,
                label: 'Khung giờ',
                value: _formatSlotRange(item),
              ),
            ],
          ),
          if (isDone && item.rating != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(5, (i) {
                  final full = i < item.rating!.floor();
                  final half = !full && i < item.rating!;
                  return Icon(
                    full
                        ? Icons.star
                        : (half ? Icons.star_half : Icons.star_border),
                    size: 15,
                    color: const Color(0xFFFFC107),
                  );
                }),
                const SizedBox(width: 5),
                Text(
                  '${item.rating!.toStringAsFixed(1)} / 5.0',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: OutlinedButton(
                    onPressed: () => _openDetail(context, item),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF6C47C2),
                        width: 1.2,
                      ),
                      foregroundColor: _purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Xem Chi Tiết',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed:
                        item.consultationId == null ||
                            item.consultationId!.isEmpty
                        ? null
                        : () {
                            context.push(
                              '/consultation-message-history/${item.consultationId}',
                              extra: {
                                'title': item.patientName,
                                'isExpertMode': true,
                              },
                            );
                          },
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text(
                      'Tin Nhắn',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE8E8E8),
                      disabledForegroundColor: const Color(0xFF999999),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryMetaChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF6B7280)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '$label: $value',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF2D2D2D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatSlotRange(_ExpertConsultation c) {
    final start = c.slotStartTime ?? c.scheduledTime;
    final end = c.slotEndTime;
    final startText =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    if (end == null) return startText;
    final endText =
        '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    return '$startText - $endText';
  }

  String _formatFullDate(DateTime d) {
    const months = [
      '',
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
    const days = [
      '',
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];
    return '${days[d.weekday]}, ${d.day} ${months[d.month]}, ${d.year}';
  }

  String _formatFullDateTime(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}'
      ' lúc ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _formatFullDateTimePlus7(DateTime d) {
    return _formatFullDateTime(d);
  }

  String _formatFee(int fee) {
    final formatted = fee.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '${formatted}đ';
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// ── Income Tab ────────────────────────────────────────────────────────────────

class _IncomeTab extends ConsumerStatefulWidget {
  const _IncomeTab();

  @override
  ConsumerState<_IncomeTab> createState() => _IncomeTabState();
}

class _IncomeTabState extends ConsumerState<_IncomeTab> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  final List<TransactionInfo> _allTransactions = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _page = 1;
  static const int _pageSize = 50;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialLoad());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _fetchPage(_page);
    }
  }

  Future<void> _initialLoad() async {
    setState(() {
      _allTransactions.clear();
      _isLoading = true;
      _error = null;
      _page = 1;
      _hasMore = true;
    });
    await _fetchPage(1);
  }

  Future<void> _fetchPage(int page) async {
    if (!_hasMore) return;
    if (page == 1) {
      setState(() => _isLoading = true);
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final userId = ref.read(authProvider).user?.id;
      if (userId == null || userId.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          if (page == 1) _error = 'Không xác định được người dùng';
        });
        return;
      }
      final results = await ref
          .read(transactionRepositoryProvider)
          .getTransactions(
            userId: userId,
            transType: 'consultation',
            pageNumber: page,
            pageSize: _pageSize,
          );
      if (!mounted) return;
      setState(() {
        if (page == 1) _allTransactions.clear();
        _allTransactions.addAll(results);
        _hasMore = results.length >= _pageSize;
        _page = page + 1;
        _isLoading = false;
        _isLoadingMore = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        if (page == 1) _error = e.toString();
      });
    }
  }

  List<TransactionInfo> get _filtered => _allTransactions
      .where(
        (t) =>
            t.createdAt.month == _selectedMonth &&
            t.createdAt.year == _selectedYear,
      )
      .toList();

  double get _filteredTotal => _filtered.fold(0.0, (sum, t) => sum + t.amount);

  String _formatAmount(double amount) {
    return amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  static const _months = [
    'Tháng 1',
    'Tháng 2',
    'Tháng 3',
    'Tháng 4',
    'Tháng 5',
    'Tháng 6',
    'Tháng 7',
    'Tháng 8',
    'Tháng 9',
    'Tháng 10',
    'Tháng 11',
    'Tháng 12',
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Thu Nhập',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF6C47C2)),
            tooltip: 'Tải lại',
            onPressed: _isLoading ? null : _initialLoad,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6C47C2)),
                  )
                : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cloud_off_outlined,
                            size: 56,
                            color: Color(0xFFCCCCCC),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Không thể tải dữ liệu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF555555),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF999999),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton.icon(
                            onPressed: _initialLoad,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử lại'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF6C47C2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      // ── Summary Card ───────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C47C2), Color(0xFF9F7AEA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C47C2).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.wallet,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Thu Nhập — ${_months[_selectedMonth - 1]} $_selectedYear',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatAmount(_filteredTotal),
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.1,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 6, left: 8),
                                  child: Text(
                                    'VNĐ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.only(top: 14),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.white24),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.receipt_long,
                                    color: Colors.white70,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${filtered.length} giao dịch',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (_allTransactions.length > filtered.length)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Tổng: ${_allTransactions.length} giao dịch',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Month / Year Filter ────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              size: 18,
                              color: Color(0xFF6C47C2),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Lọc theo tháng:',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF666666),
                              ),
                            ),
                            const Spacer(),
                            DropdownButton<int>(
                              value: _selectedMonth,
                              underline: const SizedBox(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6C47C2),
                              ),
                              items: List.generate(
                                12,
                                (i) => DropdownMenuItem(
                                  value: i + 1,
                                  child: Text(_months[i]),
                                ),
                              ),
                              onChanged: (v) =>
                                  setState(() => _selectedMonth = v!),
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<int>(
                              value: _selectedYear,
                              underline: const SizedBox(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6C47C2),
                              ),
                              items: [2024, 2025, 2026]
                                  .map(
                                    (y) => DropdownMenuItem(
                                      value: y,
                                      child: Text('$y'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedYear = v!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Transaction List ───────────────────────────────
                      Row(
                        children: [
                          const Text(
                            'Lịch Sử Giao Dịch',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                          const Spacer(),
                          if (filtered.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF6C47C2,
                                ).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${filtered.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6C47C2),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 52,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Không có giao dịch\ntrong ${_months[_selectedMonth - 1]} $_selectedYear',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF999999),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...filtered.map(_buildTransactionItem),

                      if (_isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF6C47C2),
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 80),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionInfo t) {
    final label = kTransTypeLabels[t.transactionType] ?? t.transactionType;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF28A745).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_downward_rounded,
              size: 20,
              color: Color(0xFF28A745),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.fullName.isNotEmpty
                      ? t.fullName
                      : (t.description.isNotEmpty
                            ? t.description
                            : 'Giao dịch'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C47C2).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6C47C2),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(t.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '+${_formatAmount(t.amount)} ₫',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF28A745),
            ),
          ),
        ],
      ),
    );
  }
}

// Profile Tab - Wrapper for ExpertProfileScreen
class _ProfileTab extends StatelessWidget {
  final VoidCallback onGoToHistory;
  const _ProfileTab({required this.onGoToHistory});

  @override
  Widget build(BuildContext context) {
    return ExpertProfileScreen(onGoToHistory: onGoToHistory);
  }
}

// Urgent Request Bottom Sheet
class _UrgentRequestSheet extends StatelessWidget {
  const _UrgentRequestSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Urgent Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFDC3545),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'YÊU CẦU KHẨN CẤP',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Còn 2:45 phút',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRescuerCard(),
                  const SizedBox(height: 20),
                  _buildSnakeImageSection(),
                  const SizedBox(height: 20),
                  _buildMessageCard(),
                ],
              ),
            ),
          ),

          _buildFooterActions(context),
        ],
      ),
    );
  }

  Widget _buildRescuerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Đội Cứu Hộ Sài Gòn',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.verified, color: Colors.blue[500], size: 18),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text(
                      '4.9',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFA500),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, color: Color(0xFFFFA500), size: 14),
                    const SizedBox(width: 6),
                    const Text(
                      '(234 đánh giá)',
                      style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.only(left: 8),
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Color(0xFFDC3545), width: 2),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Color(0xFFDC3545),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Quận 1, TP.HCM',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Cách vị trí rắn 2.3 km',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFDC3545).withOpacity(0.2),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Container(
                color: const Color(0xFFDC3545).withOpacity(0.1),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFFDC3545),
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnakeImageSection() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.dangerous, size: 100, color: Color(0xFFDC3545)),
            ),
          ),

          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA500),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'AI: Rắn độc không xác định (45%)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.home_work, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Vườn nhà',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.nightlight, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Ban đêm',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
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
  }

  Widget _buildMessageCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: Color(0xFFDC3545), width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.format_quote,
                color: const Color(0xFFDC3545).withOpacity(0.3),
                size: 32,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '"Rắn có vằn đen-vàng, đầu to hình tam giác. Tôi không chắc đây là loài gì. Cần xác nhận ngay!"',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F6F8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF0F0F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC3545),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(12, (index) {
                          final heights = [
                            8.0,
                            16.0,
                            12.0,
                            20.0,
                            24.0,
                            12.0,
                            16.0,
                            8.0,
                            12.0,
                            8.0,
                            8.0,
                            8.0,
                          ];
                          final isPlayed = index < 8;
                          return Container(
                            width: 3,
                            height: heights[index],
                            margin: const EdgeInsets.only(right: 2),
                            decoration: BoxDecoration(
                              color: isPlayed
                                  ? const Color(0xFFDC3545)
                                  : const Color(0xFFCCCCCC),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '0:12 • Tin nhắn thoại',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF999999),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.photo_library, size: 20),
                  label: const Text(
                    'Ảnh Khác (3)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF6C47C2)),
                    foregroundColor: const Color(0xFF6C47C2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.map, size: 20),
                  label: const Text(
                    'Bản Đồ',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF6C47C2)),
                    foregroundColor: const Color(0xFF6C47C2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF28A745).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF28A745).withOpacity(0.2),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.monetization_on, color: Color(0xFF28A745), size: 20),
                SizedBox(width: 8),
                Text(
                  'Bạn sẽ nhận 500K VNĐ cho tư vấn này',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF28A745),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF999999)),
                    foregroundColor: const Color(0xFF999999),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Từ Chối',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle, size: 22),
                  label: const Text(
                    'Chấp Nhận Ngay',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC3545),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Snake Library Card widget (shared for expert home) ──────────────────────
class _SnakeLibraryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SnakeLibraryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 13,
                color: color.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
