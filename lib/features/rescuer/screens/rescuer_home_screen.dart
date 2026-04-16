import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'rescuer_profile_screen.dart';
import 'rescuer_income_management_screen.dart';
import 'package:snakeaid_mobile/features/lesson/providers/lesson_read_provider.dart';
import '../../emergency/providers/rescuer_emergency_provider.dart';
import '../../emergency/providers/mission_hub_provider.dart';
import '../../emergency/providers/active_mission_provider.dart';
import '../../emergency/widgets/rescue_request_modal.dart';
import '../managers/location_manager.dart';
import '../providers/tracking_provider.dart';
import 'package:snakeaid_mobile/features/snake_catching/screens/rescuers/rescuer_accept_request_screen.dart';
import 'package:snakeaid_mobile/features/snake_catching/screens/rescuers/rescuer_available_jobs_screen.dart';
import 'package:snakeaid_mobile/features/snake_catching/screens/rescuers/rescuer_tracking_screen.dart';
import 'package:snakeaid_mobile/features/snake_catching/screens/rescuers/rescuer_en_route_screen.dart';
import 'package:snakeaid_mobile/features/snake_catching/repository/snake_catching_repository.dart';
import 'package:snakeaid_mobile/features/snake_catching/models/snake_catching_request.dart';
import '../../notifications/providers/notification_inbox_provider.dart';
import '../../notifications/screens/notification_inbox_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../repository/rescuer_analytics_repository.dart';
import '../models/rescuer_daily_stats.dart';

// ── Rescuer daily statistics provider ────────────────────────────────────────
final _rescuerDailyStatsProvider =
    FutureProvider.autoDispose<RescuerDailyStats>((ref) async {
      final repo = ref.watch(rescuerAnalyticsRepositoryProvider);
      return repo.getStatistics(period: 'day');
    });

// ── Active snake catching job provider ──────────────────────────────────
final _activeCatchingJobProvider =
    FutureProvider.autoDispose<SnakeCatchingRequestData?>((ref) async {
      final currentUser = ref.watch(currentUserProvider);
      if (currentUser == null) return null;
      final repo = ref.watch(snakeCatchingRepositoryProvider);
      final response = await repo.getRequests(
        assignedRescuerId: currentUser.id,
      );
      const terminalStatuses = {
        'completed',
        'cancelled',
        'expired',
        'rejected',
        'failed',
        'finished',
      };
      return response.data.where((r) {
        if (terminalStatuses.contains(r.status.toLowerCase())) return false;

        // Also check mission status if it exists.
        if (r.mission != null) {
          final mStatus = r.mission!.status.toLowerCase();
          if (terminalStatuses.contains(mStatus)) return false;
        }

        return true;
      }).firstOrNull;
    });

/// Rescuer Home Screen - Dashboard for rescue team members
class RescuerHomeScreen extends ConsumerStatefulWidget {
  const RescuerHomeScreen({super.key});

  @override
  ConsumerState<RescuerHomeScreen> createState() => _RescuerHomeScreenState();
}

class _RescuerHomeScreenState extends ConsumerState<RescuerHomeScreen> {
  int _selectedIndex = 0;
  final AudioPlayer _snakeCatchingAudioPlayer = AudioPlayer();
  final AudioPlayer _sosAudioPlayer = AudioPlayer();

  final List<Widget> _screens = [
    const _HomeTab(),
    const RescuerAvailableJobsScreen(),
    const NotificationInboxScreen(),
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

    // Listen for SnakeCatchingRequestAssigned (Operator assigned a catching job to this rescuer)
    ref.listen<AsyncValue<Map<String, dynamic>>>(
      snakeCatchingRequestAssignedStreamProvider,
      (previous, next) {
        next.whenData((data) {
          debugPrint(
            '🐍 [GLOBAL] SnakeCatchingRequestAssigned: id=${data['id']}',
          );
          _showSnakeCatchingAssignedModal(data);
        });
      },
    );

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
                _buildNavItem(1, Icons.task_alt, 'Nhiệm Vụ'),
                _buildNavItem(
                  2,
                  Icons.notifications_outlined,
                  'Thông Báo',
                  unreadCount: ref.watch(notificationInboxProvider).unreadCount,
                ),
                _buildNavItem(3, Icons.person, 'Cá Nhân'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _snakeCatchingAudioPlayer.dispose();
    _sosAudioPlayer.dispose();
    super.dispose();
  }

  /// Show modal when a snake catching request is assigned to this rescuer.
  /// SignalR payload: { id, status, assignedAt, assignedRescuerId,
  ///                    assignedRescuerName, assignedRescuerPhone }
  /// Full request details are fetched via API when tapping "Xem chi tiết".
  void _showSnakeCatchingAssignedModal(Map<String, dynamic> data) {
    debugPrint('🐍 [GLOBAL] Showing snake catching assigned modal...');
    debugPrint('📋 SignalR payload: $data');
    _playSnakeCatchingAlert();

    // Fields actually sent by SignalR
    final requestId = (data['id'] as String?)?.trim() ?? '';
    final assignedAtRaw = data['assignedAt'] as String?;

    String? assignedAtText;
    if (assignedAtRaw != null) {
      final dt = DateTime.tryParse(assignedAtRaw);
      if (dt != null) {
        final local = dt.toLocal();
        assignedAtText =
            '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}'
            ' ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
      }
    }

    bool isNavigating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Gradient Header ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFD94010)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pest_control_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Đơn Bắt Rắn Mới',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Điều phối viên vừa phân công cho bạn',
                      style: TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
              ),

              // ── Info Body ────────────────────────────────────────────────
              Container(
                constraints: const BoxConstraints(maxHeight: 320),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F6F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _modalInfoRow(
                              Icons.assignment_turned_in_rounded,
                              const Color(0xFF28A745),
                              'Trạng thái',
                              'Đã được phân công',
                            ),
                            if (assignedAtText != null) ...[
                              const Divider(height: 16, thickness: 0.5),
                              _modalInfoRow(
                                Icons.schedule_rounded,
                                const Color(0xFF666666),
                                'Thời gian phân công',
                                assignedAtText,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFFF6B35).withOpacity(0.3),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Color(0xFFFF6B35),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Nhấn "Xem chi tiết" để xem đầy đủ thông tin đơn bắt rắn.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF666666),
                                  height: 1.4,
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

              // ── Action Buttons ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isNavigating
                            ? null
                            : () {
                                _stopSnakeCatchingAlert();
                                Navigator.of(ctx).pop();
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF666666),
                          side: const BorderSide(color: Color(0xFFDDDDDD)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Để sau'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: (isNavigating || requestId.isEmpty)
                            ? null
                            : () async {
                                setModalState(() => isNavigating = true);
                                try {
                                  final repository = ref.read(
                                    snakeCatchingRepositoryProvider,
                                  );
                                  final response = await repository
                                      .getRequestById(requestId);
                                  if (!context.mounted) return;
                                  _stopSnakeCatchingAlert();
                                  Navigator.of(ctx).pop();
                                  if (response.isSuccess &&
                                      response.data != null) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            RescuerAcceptRequestScreen(
                                              requestData: response.data!,
                                            ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Không thể tải thông tin đơn. Vui lòng thử lại.',
                                        ),
                                        backgroundColor: Color(0xFFDC3545),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (!context.mounted) return;
                                  setModalState(() => isNavigating = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Lỗi: $e'),
                                      backgroundColor: const Color(0xFFDC3545),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          disabledBackgroundColor: const Color(
                            0xFFFF6B35,
                          ).withOpacity(0.6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isNavigating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Xem chi tiết',
                                style: TextStyle(fontWeight: FontWeight.bold),
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
    ).then((_) => _stopSnakeCatchingAlert());
  }

  /// Play loud alert sound + vibrate when a catching job is assigned
  Future<void> _playSnakeCatchingAlert() async {
    // Sound — requires assets/sounds/snake_alert.mp3 (see assets/sounds/README.md)
    try {
      // Reset player state before playing to avoid stuck state
      await _snakeCatchingAudioPlayer.stop();
      await _snakeCatchingAudioPlayer.setVolume(1.0);
      await _snakeCatchingAudioPlayer.setReleaseMode(ReleaseMode.loop);
      await _snakeCatchingAudioPlayer.play(
        AssetSource('sounds/snake_alert.mp3'),
      );
    } catch (e) {
      debugPrint('⚠️ Could not play snake alert sound: $e');
    }
    // Vibration
    try {
      if (await Vibration.hasVibrator() == true) {
        Vibration.vibrate(pattern: [0, 500, 150, 500, 150, 700], repeat: 0);
      }
    } catch (e) {
      debugPrint('⚠️ Could not vibrate: $e');
    }
  }

  /// Stop alert sound and vibration
  void _stopSnakeCatchingAlert() {
    try {
      _snakeCatchingAudioPlayer.stop();
    } catch (_) {}
    try {
      Vibration.cancel();
    } catch (_) {}
  }

  /// Play loud alert sound + vibrate for SOS emergency request
  Future<void> _playSnakebiteIncidentAlert() async {
    // Sound — requires assets/sounds/sos_alert.mp3
    try {
      await _sosAudioPlayer.stop();
      await _sosAudioPlayer.setVolume(1.0);
      await _sosAudioPlayer.setReleaseMode(ReleaseMode.loop);
      await _sosAudioPlayer.play(AssetSource('sounds/sos_alert.mp3'));
    } catch (e) {
      debugPrint('⚠️ Could not play SOS alert sound: $e');
    }
    // Vibration
    try {
      if (await Vibration.hasVibrator() == true) {
        Vibration.vibrate(pattern: [0, 500, 150, 500, 150, 700], repeat: 0);
      }
    } catch (e) {
      debugPrint('⚠️ Could not vibrate: $e');
    }
  }

  /// Stop SOS alert sound and vibration
  void _stopSnakebiteIncidentAlert() {
    try {
      _sosAudioPlayer.stop();
    } catch (_) {}
    try {
      Vibration.cancel();
    } catch (_) {}
  }

  /// Labeled info row widget used inside the snake catching modal
  Widget _modalInfoRow(
    IconData icon,
    Color iconColor,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 15, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF999999),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Show emergency alert modal - works across all tabs
  void _showEmergencyAlert(dynamic request) {
    debugPrint('🚨 [GLOBAL] Showing emergency alert modal...');
    _playSnakebiteIncidentAlert();

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
    ).then((_) => _stopSnakebiteIncidentAlert());
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label, {
    int unreadCount = 0,
  }) {
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 28,
                  weight: isSelected ? 700 : 400,
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: -2,
                    right: -4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDC3545),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
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

class _HomeTabState extends ConsumerState<_HomeTab>
    with WidgetsBindingObserver {
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

    // Refresh active mission state from server so terminal status changes
    // (e.g. MissionCompleted) are picked up when database is updated externally.
    if (ref.read(activeMissionProvider).hasActiveMission) {
      await ref.read(activeMissionProvider.notifier).refreshMission();
    }

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
                    Builder(
                      builder: (context) {
                        final unread = ref
                            .watch(notificationInboxProvider)
                            .unreadCount;
                        return Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined),
                              onPressed: () => context.push('/notifications'),
                            ),
                            if (unread > 0)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFDC3545),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
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

                      // Snake Library section
                      _buildSnakeLibrarySection(context),
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
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF8800)),
      ),
    );

    try {
      final activeMissionNotifier = ref.read(activeMissionProvider.notifier);

      // Keep mission state in sync with server when the user taps the banner.
      if (ref.read(activeMissionProvider).hasActiveMission) {
        await activeMissionNotifier.refreshMission();
      }

      final mission = ref.read(activeMissionProvider).mission;

      if (!mounted) return;

      // Dismiss loading
      Navigator.of(context).pop();

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
    } catch (e) {
      if (!mounted) return;

      // Dismiss loading
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải nhiệm vụ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    final statsAsync = ref.watch(_rescuerDailyStatsProvider);
    return statsAsync.when(
      loading: () => Row(
        children: List.generate(
          3,
          (_) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFFF6B35),
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
            child: _buildStatCard('--', 'Yêu cầu', const Color(0xFF333333)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('--', 'Hoàn thành', const Color(0xFF10B981)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('--', 'Rắn cắn', const Color(0xFFE53935)),
          ),
        ],
      ),
      data: (stats) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '${stats.totalRequests}',
                'Yêu cầu',
                const Color(0xFF333333),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '${stats.totalCompleted}',
                'Hoàn thành',
                const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '${stats.snakebiteRequests}',
                'Rắn cắn',
                const Color(0xFFE53935),
              ),
            ),
          ],
        );
      },
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
    // Priority 1: active snakebite rescue mission
    final activeMissionState = ref.watch(activeMissionProvider);
    if (activeMissionState.hasActiveMission) {
      final mission = activeMissionState.mission!;
      return _buildMissionCard(
        typeLabel: 'CỨU HỘ',
        typeLabelColor: const Color(0xFFDC3545),
        icon: Icons.emergency_outlined,
        title: 'Nhiệm vụ cứu hộ rắn cắn',
        subtitle:
            'Đang xử lý • Mã: ...${mission.missionId.length >= 6 ? mission.missionId.substring(mission.missionId.length - 6) : mission.missionId}',
        onContinue: () {
          if (mission.status.toLowerCase() == 'en route' ||
              mission.status.toLowerCase() == 'arrived') {
            context.push(
              '/rescuer/navigation/${mission.incidentId}?missionId=${mission.missionId}',
            );
          } else {
            context.push('/rescuer/mission-detail/${mission.missionId}');
          }
        },
      );
    }

    // Priority 2: active snake catching job
    final catchingAsync = ref.watch(_activeCatchingJobProvider);
    return catchingAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
        ),
      ),
      error: (_, __) => _buildNoActiveMissionCard(),
      data: (job) {
        if (job == null) return _buildNoActiveMissionCard();

        final mStatus =
            job.mission?.status.toLowerCase() ?? job.status.toLowerCase();

        return _buildMissionCard(
          typeLabel: 'BẮT RẮN',
          typeLabelColor: const Color(0xFF228B22),
          icon: Icons.catching_pokemon,
          title: 'Yêu cầu bắt rắn',
          subtitle: job.address.isNotEmpty ? job.address : 'Địa chỉ không có',
          onContinue: () {
            if (mStatus == 'arrived' || mStatus == 'catching') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RescuerTrackingScreen(
                    requestData: job,
                    missionId: job.mission?.id ?? '',
                  ),
                ),
              );
            } else if (mStatus == 'en_route' ||
                mStatus == 'en route' ||
                mStatus == 'enroute') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RescuerEnRouteScreen(
                    requestData: job,
                    missionId: job.mission?.id ?? '',
                  ),
                ),
              );
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RescuerAcceptRequestScreen(requestData: job),
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildMissionCard({
    required String typeLabel,
    required Color typeLabelColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onContinue,
  }) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeLabelColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  typeLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: typeLabelColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(icon, size: 20, color: typeLabelColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onContinue,
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
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoActiveMissionCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.check_circle_outline, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text(
              'Không có nhiệm vụ đang hoạt động',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
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

  Widget _buildSnakeLibrarySection(BuildContext context) {
    const primaryColor = Color(0xFFFF6B35);
    const accentColor = Color(0xFFE53935);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Thư Viện Loài Rắn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Tra cứu loài rắn và hướng dẫn sơ cứu',
          style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _RescuerSnakeLibraryCard(
                icon: Icons.menu_book_outlined,
                title: 'Thư Viện Loài',
                subtitle: 'Nhận biết & phân loại',
                color: primaryColor,
                onTap: () => context.pushNamed('rescuer_snake_library'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RescuerSnakeLibraryCard(
                icon: Icons.health_and_safety_outlined,
                title: 'Hướng Dẫn\nSơ Cứu',
                subtitle: 'Xử lý khi bị cắn',
                color: accentColor,
                onTap: () => context.pushNamed('rescuer_snake_first_aid_guide'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccess() {
    final hasUnreadLesson = ref.watch(lessonReadProvider).hasUnread;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildQuickAccessItem(
          icon: Icons.health_and_safety,
          label: 'Bài học\nAn Toàn',
          color: const Color(0xFFFF6B35),
          showBadge: hasUnreadLesson,
          onTap: () {
            context.pushNamed('rescuer_lessons');
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
          icon: Icons.settings,
          label: 'Cài Đặt',
          color: const Color(0xFF666666),
          onTap: () {
            context.pushNamed('rescuer_settings');
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
    bool showBadge = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
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
              if (showBadge)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
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

// ── Snake Library Card widget (for rescuer home) ─────────────────────────────
class _RescuerSnakeLibraryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RescuerSnakeLibraryCard({
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
            border: Border.all(color: color.withOpacity(0.2)),
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
