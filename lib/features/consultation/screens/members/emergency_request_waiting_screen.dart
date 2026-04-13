import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/http_provider.dart';
import '../../../../core/services/emergency_consultation_signalr_service.dart';

// ── Helper to show the modal from anywhere ─────────────────────────────────────
void showEmergencyRequestModal(
  BuildContext context, {
  required String requestId,
  required String expertId,
  required String expertName,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (_) => EmergencyRequestWaitingDialog(
      requestId: requestId,
      expertId: expertId,
      expertName: expertName,
    ),
  );
}

// ── Full-page fallback (used by router for deep-links) ────────────────────────
class EmergencyRequestWaitingScreen extends StatelessWidget {
  final String requestId;
  final String expertId;
  final String expertName;

  const EmergencyRequestWaitingScreen({
    super.key,
    required this.requestId,
    required this.expertId,
    required this.expertName,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showEmergencyRequestModal(
        context,
        requestId: requestId,
        expertId: expertId,
        expertName: expertName,
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

  const EmergencyRequestWaitingDialog({
    super.key,
    required this.requestId,
    required this.expertId,
    required this.expertName,
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
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  String _status = 'PendingPayment';
  String? _statusMessage;
  bool _isConnecting = true;
  String? _acceptedConsultationId;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    Future.microtask(_initRealtime);
  }

  Future<void> _initRealtime() async {
    try {
      final baseUrl = ref.read(httpServiceProvider).baseUrl;
      _signalR = EmergencyConsultationSignalRService(baseUrl: baseUrl);

      _statusSub = _signalR!.statusChangedStream.listen((event) {
        if (!mounted) return;
        setState(() {
          _status = event.status;
          _statusMessage = _mapStatusToMessage(event.status);
          _isConnecting = false;
          if (event.consultationId != null &&
              event.consultationId!.isNotEmpty) {
            _acceptedConsultationId = event.consultationId;
          }
        });

        if (event.status == 'AcceptedByExpert' &&
            event.consultationId != null &&
            event.consultationId!.isNotEmpty) {
          if (mounted) Navigator.of(context).pop();
          context.go(
            '/video-waiting/${event.consultationId}',
            extra: {
              'expertName': widget.expertName,
              'expertSpecialty': 'Tư vấn ngay',
            },
          );
        }
      });

      await _signalR!.connectAndJoinRequestRoom(widget.requestId);

      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _statusMessage = _mapStatusToMessage(_status);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _statusMessage =
            'Không thể kết nối realtime. Yêu cầu đã tạo nhưng chưa theo dõi được trạng thái.';
      });
    }
  }

  String _mapStatusToMessage(String status) {
    switch (status) {
      case 'PendingPayment':
        return 'Yêu cầu đã tạo. Đang chờ xác nhận thanh toán.';
      case 'PendingExpertResponse':
        return 'Đã thanh toán. Đang chờ chuyên gia phản hồi...';
      case 'AcceptedByExpert':
        return 'Chuyên gia đã chấp nhận! Đang chuyển vào phòng tư vấn...';
      case 'DeclinedByExpert':
        return 'Chuyên gia đã từ chối yêu cầu. Vui lòng chọn chuyên gia khác.';
      case 'Expired':
        return 'Yêu cầu đã hết hạn. Vui lòng tạo yêu cầu mới.';
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

  bool get _isTerminal =>
      _status == 'DeclinedByExpert' || _status == 'Expired';
  bool get _isAccepted => _status == 'AcceptedByExpert';

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _statusSub?.cancel();
    _signalR?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _isTerminal,
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 52),
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
                  const Icon(Icons.person_outline,
                      size: 14, color: Color(0xFF9CA3AF)),
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
                    horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _accentColor.withOpacity(0.2),
                  ),
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
                              padding:
                                  const EdgeInsets.only(top: 2, right: 8),
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
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go(
                        '/video-waiting/$_acceptedConsultationId',
                        extra: {
                          'expertName': widget.expertName,
                          'expertSpecialty': 'Tư vấn ngay',
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
                          borderRadius: BorderRadius.circular(12)),
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
                        borderRadius: BorderRadius.circular(12)),
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
