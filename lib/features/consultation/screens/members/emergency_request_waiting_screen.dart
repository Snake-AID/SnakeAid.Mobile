import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/http_provider.dart';
import '../../../../core/services/emergency_consultation_signalr_service.dart';
import '../../repository/consultation_repository.dart';

// ── Helper to show the modal from anywhere ─────────────────────────────────────
void showEmergencyRequestModal(
  BuildContext context, {
  required String requestId,
  required String expertId,
  required String expertName,
  String initialStatus = 'PendingExpertResponse',
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (_) => EmergencyRequestWaitingDialog(
      requestId: requestId,
      expertId: expertId,
      expertName: expertName,
      initialStatus: initialStatus,
    ),
  );
}

// ── Full-page fallback (used by router for deep-links) ────────────────────────
class EmergencyRequestWaitingScreen extends StatelessWidget {
  final String requestId;
  final String expertId;
  final String expertName;
  final String initialStatus;

  const EmergencyRequestWaitingScreen({
    super.key,
    required this.requestId,
    required this.expertId,
    required this.expertName,
    this.initialStatus = 'PendingExpertResponse',
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showEmergencyRequestModal(
        context,
        requestId: requestId,
        expertId: expertId,
        expertName: expertName,
        initialStatus: initialStatus,
      );
    });
    return const Scaffold(backgroundColor: Color(0xFFF6F8F6));
  }
}

// ── The actual modal dialog widget ────────────────────────────────────────────
class EmergencyRequestWaitingDialog extends ConsumerStatefulWidget {
  final String requestId;
  final String expertId;
  final String expertName;
  final String initialStatus;

  const EmergencyRequestWaitingDialog({
    super.key,
    required this.requestId,
    required this.expertId,
    required this.expertName,
    this.initialStatus = 'PendingExpertResponse',
  });

  @override
  ConsumerState<EmergencyRequestWaitingDialog> createState() =>
      _EmergencyRequestWaitingDialogState();
}

class _EmergencyRequestWaitingDialogState
    extends ConsumerState<EmergencyRequestWaitingDialog>
    with SingleTickerProviderStateMixin {
  static const _green = Color(0xFF228B22);
  static const _amber = Color(0xFFF59E0B);
  static const _red = Color(0xFFDC2626);

  EmergencyConsultationSignalRService? _signalR;
  StreamSubscription<EmergencyRequestStatusChanged>? _statusSub;
  Timer? _statusPollTimer;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  String _status = 'PendingExpertResponse';
  String? _statusMessage;
  bool _isConnecting = true;
  bool _isPollingStatus = false;
  String? _acceptedConsultationId;
  DateTime? _requestedAt;

  @override
  void initState() {
    super.initState();
    _status = _canonicalStatus(widget.initialStatus);
    _statusMessage = _mapStatusToMessage(_status);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.55,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    Future.microtask(_initRealtime);
  }

  String _canonicalStatus(String status) {
    final normalized = status.trim().toLowerCase();
    switch (normalized) {
      case 'pendingpayment':
      case 'pending_payment':
        return 'PendingPayment';
      case 'pendingexpertresponse':
      case 'pending_expert_response':
        return 'PendingExpertResponse';
      case 'acceptedbyexpert':
      case 'accepted_by_expert':
        return 'AcceptedByExpert';
      case 'declinedbyexpert':
      case 'declined_by_expert':
      case 'declined':
      case 'rejectedbyexpert':
      case 'rejected_by_expert':
      case 'rejected':
        return 'DeclinedByExpert';
      case 'expired':
      case 'timedout':
      case 'timeout':
        return 'Expired';
      default:
        return status;
    }
  }

  bool _isKnownStatus(String status) {
    return status == 'PendingPayment' ||
        status == 'PendingExpertResponse' ||
        status == 'AcceptedByExpert' ||
        status == 'DeclinedByExpert' ||
        status == 'Expired';
  }

  String _resolveStatus(EmergencyRequestStatusChanged event) {
    final canonical = _canonicalStatus(event.status);
    if (_isKnownStatus(canonical)) return canonical;

    if (event.consultationId != null && event.consultationId!.isNotEmpty) {
      return 'AcceptedByExpert';
    }

    final raw = event.status.trim().toLowerCase();
    if (RegExp(r'^\d+$').hasMatch(raw)) {
      switch (raw) {
        case '1':
          return 'PendingPayment';
        case '2':
          return 'PendingExpertResponse';
        case '3':
          // Some backends store "responded without consultation" as declined.
          if (event.respondedAtUtc != null) return 'DeclinedByExpert';
          return 'PendingExpertResponse';
        case '4':
          return 'DeclinedByExpert';
        case '5':
          return 'Expired';
      }
    }

    if (event.expiresAtUtc != null &&
        DateTime.now().toUtc().isAfter(event.expiresAtUtc!.toUtc())) {
      return 'Expired';
    }

    return canonical;
  }

  Future<void> _initRealtime() async {
    try {
      final baseUrl = ref.read(httpServiceProvider).baseUrl;
      _signalR = EmergencyConsultationSignalRService(baseUrl: baseUrl);
      debugPrint(
        '🔌 [EmergencyWaiting] Connecting realtime for request=${widget.requestId}',
      );

      _statusSub = _signalR!.statusChangedStream.listen((event) {
        if (event.requestId.isNotEmpty && event.requestId != widget.requestId) {
          debugPrint(
            '↩️ [EmergencyWaiting] Ignore status for other request ${event.requestId} (current ${widget.requestId})',
          );
          return;
        }

        final canonicalStatus = _resolveStatus(event);
        debugPrint(
          '📡 [EmergencyWaiting] Realtime status raw=${event.status} canonical=$canonicalStatus request=${event.requestId}',
        );
        if (!_isKnownStatus(canonicalStatus)) {
          debugPrint(
            'Ignore unknown emergency status payload for ${widget.requestId}: ${event.status}',
          );
          return;
        }
        if (!mounted) return;
        setState(() {
          _status = canonicalStatus;
          _statusMessage = _mapStatusToMessage(canonicalStatus);
          _isConnecting = false;
          if (event.consultationId != null &&
              event.consultationId!.isNotEmpty) {
            _acceptedConsultationId = event.consultationId;
          }
        });

        // Keep the user on waiting modal when accepted so they can confirm
        // and manually enter via "Vào Phòng Chờ Ngay".
      });

      await _signalR!.connectAndJoinRequestRoom(widget.requestId);
      _startStatusPolling();
      debugPrint(
        '✅ [EmergencyWaiting] Joined request room ${widget.requestId}',
      );

      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _statusMessage = _mapStatusToMessage(_status);
      });
    } catch (e) {
      _startStatusPolling();
      debugPrint('❌ [EmergencyWaiting] Realtime init failed: $e');
      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _statusMessage =
            'Không thể kết nối realtime. Yêu cầu đã tạo nhưng chưa theo dõi được trạng thái.';
      });
    }
  }

  void _startStatusPolling() {
    _statusPollTimer?.cancel();
    debugPrint(
      '🔁 [EmergencyWaiting] Start polling fallback for ${widget.requestId}',
    );
    _statusPollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted || _isPollingStatus || _isTerminal || _isAccepted) return;

      _isPollingStatus = true;
      try {
        final repo = ref.read(consultationRepositoryProvider);
        final request = await repo.getEmergencyRequestStatus(widget.requestId);
        if (!mounted || request == null) return;

        final canonicalStatus = _canonicalStatus(request.status);
        debugPrint(
          '🛰️ [EmergencyWaiting] Poll status raw=${request.status} canonical=$canonicalStatus request=${request.requestId}',
        );
        if (!_isKnownStatus(canonicalStatus)) return;

        if (canonicalStatus == _status &&
            (request.consultationId?.isNotEmpty != true ||
                request.consultationId == _acceptedConsultationId)) {
          return;
        }

        setState(() {
          _status = canonicalStatus;
          _statusMessage = _mapStatusToMessage(canonicalStatus);
          if (request.consultationId != null &&
              request.consultationId!.isNotEmpty) {
            _acceptedConsultationId = request.consultationId;
          }
          if (_requestedAt == null && request.requestedAt != null) {
            _requestedAt = request.requestedAt!.toLocal();
          }
        });

        // Keep the user on waiting modal when accepted so they can confirm
        // and manually enter via "Vào Phòng Chờ Ngay".
      } finally {
        _isPollingStatus = false;
      }
    });
  }

  String _mapStatusToMessage(String status) {
    switch (status) {
      case 'PendingPayment':
        return 'Yêu cầu đã tạo. Đang chờ xác nhận thanh toán.';
      case 'PendingExpertResponse':
        return 'Đã thanh toán. Đang chờ chuyên gia phản hồi...';
      case 'AcceptedByExpert':
        return 'Chuyên gia đã chấp nhận! Nhấn "Vào Phòng Chờ Ngay" để tiếp tục.';
      case 'DeclinedByExpert':
        return 'Chuyên gia đã từ chối yêu cầu. Tiền sẽ được hoàn về ví của bạn. Vui lòng chọn chuyên gia khác.';
      case 'Expired':
        return 'Yêu cầu đã hết hạn. Tiền sẽ được hoàn về ví của bạn. Vui lòng tạo yêu cầu mới.';
      default:
        return 'Đang theo dõi trạng thái tư vấn ngay...';
    }
  }

  Color get _accentColor {
    switch (_status) {
      case 'AcceptedByExpert':
        return _green;
      case 'DeclinedByExpert':
      case 'Expired':
        return _red;
      default:
        return _amber;
    }
  }

  bool get _isTerminal => _status == 'DeclinedByExpert' || _status == 'Expired';
  bool get _isAccepted => _status == 'AcceptedByExpert';

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _statusPollTimer?.cancel();
    _statusSub?.cancel();
    _signalR?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _isTerminal,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 52),
        backgroundColor: Colors.white,
        elevation: 24,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Pulsing icon circle ──────────────────────────────────
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, child) => Opacity(
                  opacity: (_isTerminal || _isAccepted)
                      ? 1.0
                      : _pulseAnim.value,
                  child: child,
                ),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isAccepted
                        ? Icons.check_circle_outline_rounded
                        : _isTerminal
                        ? Icons.cancel_outlined
                        : Icons.bolt_rounded,
                    color: _accentColor,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ── Title ────────────────────────────────────────────────
              Text(
                _isAccepted
                    ? 'Chuyên gia đã chấp nhận!'
                    : _status == 'DeclinedByExpert'
                    ? 'Yêu cầu bị từ chối'
                    : _status == 'Expired'
                    ? 'Yêu cầu hết hạn'
                    : 'Yêu cầu đã được gửi',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),

              // ── Expert name ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.expertName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // ── Status box ───────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _accentColor.withOpacity(0.2)),
                ),
                child: _isConnecting
                    ? const Row(
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _amber,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Đang kết nối...',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!_isTerminal && !_isAccepted)
                            Padding(
                              padding: const EdgeInsets.only(top: 2, right: 8),
                              child: SizedBox(
                                width: 13,
                                height: 13,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _accentColor,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              _statusMessage ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _accentColor,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),

              // ── Buttons ──────────────────────────────────────────────
              if (_acceptedConsultationId != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      DateTime? requestedAt = _requestedAt;
                      DateTime? respondedAt;
                      try {
                        final repo = ref.read(consultationRepositoryProvider);
                        final request = await repo.getEmergencyRequestStatus(
                          widget.requestId,
                        );
                        if (request != null) {
                          if (request.requestedAt != null) {
                            requestedAt = request.requestedAt!.toLocal();
                          }
                          if (request.respondedAt != null) {
                            respondedAt = request.respondedAt!.toLocal();
                          }
                        }
                      } catch (_) {
                        // Ignore fetch failure and continue with last known data.
                      }

                      final startAt =
                          requestedAt ?? respondedAt ?? DateTime.now();
                      if (!mounted) return;
                      Navigator.of(context).pop();
                      context.go(
                        '/video-waiting/$_acceptedConsultationId',
                        extra: {
                          'expertName': widget.expertName,
                          'expertSpecialty': 'Tư vấn ngay',
                          'scheduledStartAtMs': startAt.millisecondsSinceEpoch,
                          'scheduledDurationSeconds': 1800,
                          'canReportExpertAbsent': false,
                        },
                      );
                    },
                    icon: const Icon(Icons.videocam_rounded, size: 18),
                    label: const Text(
                      'Vào Phòng Chờ Ngay',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/consultation-home');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7280),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text('Về trang tư vấn'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
