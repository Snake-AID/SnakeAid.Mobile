import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rescuer_profile_screen.dart';
import 'rescuer_income_management_screen.dart';
import '../../emergency/providers/rescuer_emergency_provider.dart';
import '../../emergency/providers/mission_hub_provider.dart';
import '../../emergency/providers/active_mission_provider.dart';
import '../../emergency/widgets/rescue_request_modal.dart';
import '../managers/location_manager.dart';
import '../providers/tracking_provider.dart';
import 'package:snakeaid_mobile/features/snake_catching/screens/rescuers/rescuer_available_jobs_screen.dart';

/// Rescuer Home Screen - Dashboard for rescue team members
class RescuerHomeScreen extends ConsumerStatefulWidget {
  const RescuerHomeScreen({super.key});

  @override
  ConsumerState<RescuerHomeScreen> createState() => _RescuerHomeScreenState();
}

class _RescuerHomeScreenState extends ConsumerState<RescuerHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _HomeTab(),
    const RescuerAvailableJobsScreen(),
    const _IncomeTab(),
    const _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    // Listen for new rescue requests
    ref.listen<AsyncValue<dynamic>>(newRescueRequestStreamProvider, (
      previous,
      next,
    ) {
      debugPrint(
        '👂 [GLOBAL] newRescueRequestStreamProvider listener triggered!',
      );
      debugPrint('   Previous: $previous');
      debugPrint('   Next: $next');

      next.whenData((request) {
        debugPrint('🚨 [GLOBAL] NEW RESCUE REQUEST: ${request.requestId}');

        // Ignore new requests if rescuer is already in an active mission
        final inActiveMission = ref
            .read(missionHubConnectionProvider)
            .isConnected;
        if (inActiveMission) {
          debugPrint(
            '⚠️ [GLOBAL] Ignoring new request – rescuer is in active mission',
          );
          return;
        }

        ref.read(activeRescueRequestProvider.notifier).setRequest(request);
        _showEmergencyAlert(request);
      });
    });

    // Listen for request taken by others
    ref.listen<AsyncValue<dynamic>>(requestTakenStreamProvider, (
      previous,
      next,
    ) {
      next.whenData((requestId) {
        debugPrint('⚠️ [GLOBAL] Request taken by another rescuer: $requestId');

        final activeRequest = ref.read(activeRescueRequestProvider).request;
        if (activeRequest?.requestId == requestId) {
          ref.read(activeRescueRequestProvider.notifier).clearRequest();

          // Dismiss modal if open
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nhiệm vụ đã được nhận bởi người khác'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      });
    });

    // Listen for request expired
    ref.listen<AsyncValue<dynamic>>(requestExpiredStreamProvider, (
      previous,
      next,
    ) {
      next.whenData((requestId) {
        debugPrint('⏰ [GLOBAL] Request expired: $requestId');

        final activeRequest = ref.read(activeRescueRequestProvider).request;
        if (activeRequest?.requestId == requestId) {
          ref.read(activeRescueRequestProvider.notifier).clearRequest();

          // Dismiss modal if open
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }
      });
    });

    // Listen for request cancelled
    ref.listen<AsyncValue<dynamic>>(requestCancelledStreamProvider, (
      previous,
      next,
    ) {
      next.whenData((requestId) {
        debugPrint('❌ [GLOBAL] Request cancelled: $requestId');

        final activeRequest = ref.read(activeRescueRequestProvider).request;
        if (activeRequest?.requestId == requestId) {
          ref.read(activeRescueRequestProvider.notifier).clearRequest();

          // Dismiss modal if open
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Yêu cầu đã bị hủy'),
              backgroundColor: Colors.grey,
            ),
          );
        }
      });
    });
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F5),
      body: _screens[_selectedIndex],
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
                _buildNavItem(1, Icons.task_alt, 'Nhiệm Vụ'),
                _buildNavItem(2, Icons.account_balance_wallet, 'Thu Nhập'),
                _buildNavItem(3, Icons.person, 'Cá Nhân'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show emergency alert modal - works across all tabs
  void _showEmergencyAlert(dynamic request) {
    debugPrint('🚨 [GLOBAL] Showing emergency alert modal...');

    // Show modal popup (can be minimized)
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      barrierColor: Colors.transparent,
      builder: (context) => RescueRequestModal(
        request: request,
        onDismiss: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final color = isSelected
        ? const Color(0xFFFF6B35)
        : const Color(0xFF999999);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
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
  const _HomeTab();

  @override
  ConsumerState<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<_HomeTab> with WidgetsBindingObserver {
  bool _isOnline = true;
  String? _rescuerId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadRescuerId();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _handleAppResumed();
    }
  }

  Future<void> _handleAppResumed() async {
    if (!mounted) return;

    // If rescue mode is active, ensure we are still connected and that idle
    // location tracking is resumed (throttle resets and/or stream restarts).
    final rescueModeState = ref.read(rescueModeProvider);
    if (!rescueModeState.isActive || _rescuerId == null) return;

    debugPrint('🔄 App resumed - checking rescue mode connectivity');

    // Ensure SignalR is connected (will no-op if already connected)
    if (!rescueModeState.isConnected) {
      await ref.read(rescueModeProvider.notifier).reconnect();
    }

    // Ensure idle location tracking is active again.
    await ref.read(locationManagerProvider).resumeTracking(_rescuerId!);
  }

  Future<void> _loadRescuerId() async {
    try {
      // Get rescuer ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        debugPrint('⚠️ No rescuer ID found');
        return;
      }

      setState(() {
        _rescuerId = userId;
      });

      debugPrint('👤 Rescuer ID loaded: $_rescuerId');
    } catch (e) {
      debugPrint('❌ Error loading rescuer ID: $e');
    }
  }

  Future<void> _toggleRescueMode() async {
    if (_rescuerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy thông tin cứu hộ viên'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final rescueModeState = ref.read(rescueModeProvider);

    if (rescueModeState.isActive) {
      // Stop rescue mode
      await ref.read(rescueModeProvider.notifier).stopRescueMode();

      // Stop idle location tracking
      ref.read(locationManagerProvider).stopTracking();

      setState(() {
        _isOnline = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã tắt chế độ cứu hộ'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    } else {
      // ── Kiểm tra GPS trước khi bật ─────────────────────────────────────
      final gpsResult = await ref.read(locationManagerProvider).checkGpsReady();

      if (!mounted) return;

      if (gpsResult != GpsCheckResult.ready) {
        await _showGpsRequiredDialog(gpsResult);
        return; // Không tiếp tục bật nếu GPS chưa sẵn sàng
      }

      // ── GPS OK, bật chế độ cứu hộ ────────────────────────────────────
      try {
        await ref
            .read(rescueModeProvider.notifier)
            .startRescueMode(_rescuerId!);

        // Start idle location tracking so the backend can find this
        // rescuer during PostGIS radius searches
        await ref.read(locationManagerProvider).startTracking(_rescuerId!);

        setState(() {
          _isOnline = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🚨 Đã bật chế độ cứu hộ - Sẵn sàng nhận nhiệm vụ'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể kết nối: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Hiển dialog yêu cầu bật GPS tương ứng với từng lý do thất bại.
  Future<void> _showGpsRequiredDialog(GpsCheckResult reason) async {
    String title;
    String message;
    String confirmLabel;
    VoidCallback? onConfirm;

    switch (reason) {
      case GpsCheckResult.serviceDisabled:
        title = 'GPS đang tắt';
        message =
            'Chế độ cứu hộ yêu cầu GPS được bật để hệ thống có thể xác định vị trí của bạn và gửi yêu cầu cứu hộ gần nhất.';
        confirmLabel = 'Mở Cài Đặt Vị Trí';
        onConfirm = () async {
          Navigator.of(context).pop();
          await Geolocator.openLocationSettings();
        };
      case GpsCheckResult.permissionDenied:
        title = 'Thiếu quyền truy cập vị trí';
        message =
            'Ứng dụng cần quyền truy cập vị trí để hoạt động. Vui lòng cấp quyền và thử lại.';
        confirmLabel = 'Thử Lại';
        onConfirm = () {
          Navigator.of(context).pop();
          // Gọi lại – Geolocator sẽ hiển dialog xin quyền
          _toggleRescueMode();
        };
      case GpsCheckResult.permissionDeniedForever:
        title = 'Quyền bị từ chối vĩnh viễn';
        message =
            'Quyền vị trí đã bị tắt vĩnh viễn. Vui lòng vào Cài đặt ứng dụng → Quyền → Vị trí để bật lại.';
        confirmLabel = 'Mở Cài Đặt Ứng Dụng';
        onConfirm = () async {
          Navigator.of(context).pop();
          await Geolocator.openAppSettings();
        };
      case GpsCheckResult.ready:
        return; // Không xảy ra
    }

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.location_off, color: Color(0xFFDC3545), size: 24),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Không, để sau',
              style: TextStyle(color: Color(0xFF999999)),
            ),
          ),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch rescue mode state
    final rescueModeState = ref.watch(rescueModeProvider);
    _isOnline = rescueModeState.isActive && rescueModeState.isConnected;

    // Watch active mission state
    final activeMissionState = ref.watch(activeMissionProvider);
    final hasActiveMission = activeMissionState.hasActiveMission;

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              // App Bar
              Container(
                color: const Color(0xFFF8F6F5),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'SnakeAid Rescuer',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                    const Spacer(),
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Thông báo - Đang phát triển'),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFDC3545),
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '2',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ═══ Active Mission Recovery Banner ═══════════════════
                      if (hasActiveMission) _buildActiveMissionBanner(),
                      if (hasActiveMission) const SizedBox(height: 16),

                      // Status Card
                      _buildStatusCard(),
                      const SizedBox(height: 24),

                      // Stats Section
                      const Text(
                        'Thống Kê Hôm Nay',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatsGrid(),
                      const SizedBox(height: 24),

                      // Current Mission
                      const Text(
                        'Nhiệm Vụ Hiện Tại',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCurrentMission(),
                      const SizedBox(height: 24),

                      // Recent Requests
                      const Text(
                        'Yêu Cầu Gần Đây',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRecentRequests(),
                      const SizedBox(height: 24),

                      // Quick Access
                      const Text(
                        'Truy Cập Nhanh',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildQuickAccess(),
                      const SizedBox(height: 24),
                      Container(
                        color: Colors.purple.shade50,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🎥 Video Call Demonstration',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    context.push('/demo-video-call'),
                                icon: const Icon(Icons.video_camera_front),
                                label: const Text(
                                  'Mở màn hình Video Call Demonstration',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveMissionBanner() {
    final mission = ref.watch(activeMissionProvider).mission;
    if (mission == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nhiệm Vụ Đang Hoạt Động',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Bạn có nhiệm vụ cần tiếp tục',
                      style: TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _navigateToActiveMission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFF6B35),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Quay Lại Nhiệm Vụ',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Navigate to active mission
  Future<void> _navigateToActiveMission() async {
    final mission = ref.read(activeMissionProvider).mission;

    if (mission == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy thông tin nhiệm vụ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to mission detail
    context.push('/rescuer/mission-detail/${mission.missionId}');
  }

  Widget _buildStatusCard() {
    final rescueModeState = ref.watch(rescueModeProvider);

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
              // Pulsing dot
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _isOnline
                          ? const Color(0xFF10B981)
                          : const Color(0xFF999999),
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (_isOnline)
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
                      rescueModeState.isConnecting
                          ? 'ĐANG KẾT NỐI...'
                          : (_isOnline ? 'ĐANG ONLINE' : 'OFFLINE'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: rescueModeState.isConnecting
                            ? const Color(0xFFFFA726)
                            : (_isOnline
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF999999)),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Color(0xFF999999),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rescueModeState.isActive
                              ? 'Sẵn sàng nhận yêu cầu'
                              : 'Vui lòng bật chế độ cứu hộ',
                          style: const TextStyle(
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
                value: _isOnline,
                activeColor: const Color(0xFFFF6B35),
                onChanged: rescueModeState.isConnecting
                    ? null
                    : (value) => _toggleRescueMode(),
              ),
            ],
          ),
          if (rescueModeState.error != null) ...[
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
                      rescueModeState.error!,
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
                  color: rescueModeState.isConnected
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  rescueModeState.isConnected ? 'Đã kết nối' : 'Chưa kết nối',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: rescueModeState.isConnected
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

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('12', 'Yêu cầu', const Color(0xFF333333)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('8', 'Hoàn thành', const Color(0xFF10B981)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('1.2M', 'Thu nhập', const Color(0xFFFF6B35)),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMission() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDC3545).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'ĐANG XỬ LÝ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDC3545),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Cứu hộ rắn hổ mang',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Color(0xFF999999)),
              SizedBox(width: 4),
              Text(
                '123 Nguyễn Huệ, Q.1',
                style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Color(0xFF999999)),
              SizedBox(width: 4),
              Text(
                'Thời gian: 18 phút',
                style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tiếp tục nhiệm vụ - Đang phát triển'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Tiếp Tục',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRequests() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildRequestCard(
            time: '15:30 - 05/12/2025',
            location: '456 Lê Lợi, Q.1',
            status: 'HOÀN THÀNH',
            statusColor: const Color(0xFF10B981),
            rating: 5.0,
          ),
          const SizedBox(width: 12),
          _buildRequestCard(
            time: '14:15 - 05/12/2025',
            location: '789 Trần Hưng Đạo, Q.5',
            status: 'HOÀN THÀNH',
            statusColor: const Color(0xFF10B981),
            rating: 4.8,
          ),
          const SizedBox(width: 12),
          _buildRequestCard(
            time: '11:02 - 05/12/2025',
            location: '101 Hai Bà Trưng, Q.3',
            status: 'ĐÃ HỦY',
            statusColor: const Color(0xFFDC3545),
            rating: null,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard({
    required String time,
    required String location,
    required String status,
    required Color statusColor,
    double? rating,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time,
                style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  if (rating != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFA500),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.star,
                          size: 12,
                          color: Color(0xFFFFA500),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Color(0xFF999999)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildQuickAccessItem(
          icon: Icons.health_and_safety,
          label: 'Hướng Dẫn\nAn Toàn',
          color: const Color(0xFFFF6B35),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Hướng dẫn an toàn - Đang phát triển'),
              ),
            );
          },
        ),
        _buildQuickAccessItem(
          icon: Icons.history,
          label: 'Lịch Sử\nCứu Hộ',
          color: const Color(0xFF666666),
          onTap: () {
            context.pushNamed('rescuer_history');
          },
        ),
        _buildQuickAccessItem(
          icon: Icons.account_balance_wallet,
          label: 'Thu Nhập',
          color: const Color(0xFF666666),
          onTap: () {
            context.pushNamed('rescuer_income_management');
          },
        ),
        _buildQuickAccessItem(
          icon: Icons.settings,
          label: 'Cài Đặt',
          color: const Color(0xFF666666),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cài đặt - Đang phát triển')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickAccessItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color == const Color(0xFFFF6B35)
                  ? color.withOpacity(0.2)
                  : const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 70,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Missions Tab
class _MissionsTab extends StatelessWidget {
  const _MissionsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Nhiệm Vụ\n(Đang phát triển)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Color(0xFF666666)),
      ),
    );
  }
}

// Income Tab
class _IncomeTab extends StatelessWidget {
  const _IncomeTab();

  @override
  Widget build(BuildContext context) {
    return const RescuerIncomeManagementScreen();
  }
}

// Profile Tab
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return const RescuerProfileScreen();
  }
}
