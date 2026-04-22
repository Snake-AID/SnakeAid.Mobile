import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router.dart';
import '../../../core/services/emergency_consultation_signalr_service.dart';
import '../repository/consultation_repository.dart';
import '../../expert/providers/expert_availability_provider.dart';

class ExpertGlobalEmergencyPopupListener extends ConsumerStatefulWidget {
  const ExpertGlobalEmergencyPopupListener({super.key});

  @override
  ConsumerState<ExpertGlobalEmergencyPopupListener> createState() =>
      _ExpertGlobalEmergencyPopupListenerState();
}

class _ExpertGlobalEmergencyPopupListenerState
    extends ConsumerState<ExpertGlobalEmergencyPopupListener> {
  EmergencyConsultationSignalRService? _service;
  StreamSubscription<EmergencyConsultationRequestEvent>? _requestSub;
  ProviderSubscription<ExpertAvailabilityState>? _availabilitySub;
  Timer? _countdownTimer;

  EmergencyConsultationRequestEvent? _activeRequest;
  DateTime? _expiresAtUtc;
  int _countdownSeconds = 0;
  bool _isVisible = false;
  bool _isHandlingAction = false;

  bool _shouldShowForStatus(String? status) {
    if (status == null || status.isEmpty) {
      // Backward-compatible: some payloads don't include status.
      return true;
    }
    final normalized = status.trim().toLowerCase();
    // Expert should only see actionable requests after member payment.
    return normalized == 'pendingexpertresponse';
  }

  @override
  void initState() {
    super.initState();
    _service = ref.read(expertAvailabilitySignalRServiceProvider);
    _requestSub = _service!.requestStream.listen((event) {
      if (!mounted) return;

      final availability = ref.read(expertAvailabilityProvider);
      if (!availability.isOnline) {
        return;
      }

      if (!_shouldShowForStatus(event.status)) {
        debugPrint(
          'Ignore emergency popup because status is not actionable: ${event.status}',
        );
        return;
      }

      final expiresAtUtc = event.expiresAt?.toUtc();
      if (expiresAtUtc == null) return;

      final remain = expiresAtUtc.difference(DateTime.now().toUtc()).inSeconds;
      if (remain <= 0) return;

      setState(() {
        _activeRequest = event;
        _expiresAtUtc = expiresAtUtc;
        _countdownSeconds = remain;
        _isVisible = true;
      });
      _startCountdown();
    });

    _availabilitySub = ref.listenManual<ExpertAvailabilityState>(
      expertAvailabilityProvider,
      (previous, next) {
        if (!next.isOnline && mounted && _isVisible) {
          setState(() {
            _isVisible = false;
            _activeRequest = null;
            _expiresAtUtc = null;
            _countdownSeconds = 0;
          });
        }
      },
    );
  }

  bool _syncCountdown() {
    if (_expiresAtUtc == null) {
      _countdownSeconds = 0;
      return false;
    }
    final sec = _expiresAtUtc!.difference(DateTime.now().toUtc()).inSeconds;
    if (sec <= 0) {
      _countdownSeconds = 0;
      return false;
    }
    _countdownSeconds = sec;
    return true;
  }

  void _startCountdown() {
    final ok = _syncCountdown();
    if (!ok) {
      setState(() {
        _isVisible = false;
        _activeRequest = null;
      });
      return;
    }

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final stillValid = _syncCountdown();
      if (!stillValid) {
        _countdownTimer?.cancel();
        setState(() {
          _isVisible = false;
          _activeRequest = null;
          _expiresAtUtc = null;
        });
      } else {
        setState(() {});
      }
    });
  }

  Future<void> _accept() async {
    final req = _activeRequest;
    if (req == null || _isHandlingAction) return;

    setState(() => _isHandlingAction = true);
    try {
      final repo = ref.read(consultationRepositoryProvider);
      final accepted = await repo.acceptEmergencyRequest(req.requestId);
      if (!mounted) return;

      final consultationId = accepted.consultationId;
      setState(() {
        _isHandlingAction = false;
        _isVisible = false;
        _activeRequest = null;
        _expiresAtUtc = null;
        _countdownSeconds = 0;
      });

      if (consultationId == null || consultationId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã chấp nhận nhưng chưa có consultationId')),
        );
        return;
      }

      router.push(
        '/expert-video-waiting/$consultationId',
        extra: {
          'patientName': req.requesterName ?? 'Bệnh nhân',
          'consultationType': 'Khẩn Cấp',
          'feeCost': req.feeCost ?? 0,
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isHandlingAction = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _reject() async {
    final req = _activeRequest;
    if (req == null || _isHandlingAction) return;

    setState(() => _isHandlingAction = true);
    try {
      final repo = ref.read(consultationRepositoryProvider);
      await repo.rejectEmergencyRequest(req.requestId);
      if (!mounted) return;

      setState(() {
        _isHandlingAction = false;
        _isVisible = false;
        _activeRequest = null;
        _expiresAtUtc = null;
        _countdownSeconds = 0;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isHandlingAction = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  String get _countdownLabel =>
      '${(_countdownSeconds ~/ 60).toString().padLeft(2, '0')}:${(_countdownSeconds % 60).toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _requestSub?.cancel();
    _availabilitySub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible || _activeRequest == null) {
      return const SizedBox.shrink();
    }

    final req = _activeRequest!;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: Material(
          color: const Color(0xFF160D1B).withOpacity(0.8),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 520,
                  maxHeight: MediaQuery.of(context).size.height * 0.88,
                ),
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
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C47C2).withOpacity(0.1),
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
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3CD),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer,
                                    size: 16, color: Color(0xFFD97706)),
                                const SizedBox(width: 6),
                                Text(
                                  'Tự từ chối sau $_countdownLabel',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF8FC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color:
                                        const Color(0xFF6C47C2).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                    border:
                                        Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: const Icon(Icons.person,
                                      color: Color(0xFF6C47C2)),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        req.requesterName ?? 'Bệnh nhân',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF160D1B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Tư vấn 30 phút · Video Call',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                      Text(
                                        req.snakeSuspect ?? 'Chưa rõ loài rắn',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
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
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFDBEAFE)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline,
                                    size: 18, color: Color(0xFF4F46E5)),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Yêu cầu đã được thanh toán từ phía người dùng.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF4338CA),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isHandlingAction ? null : _accept,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C47C2),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 4,
                                shadowColor:
                                    const Color(0xFF6C47C2).withOpacity(0.4),
                              ),
                              child: _isHandlingAction
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
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _isHandlingAction ? null : _reject,
                            child: const Text(
                              'Từ Chối',
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFF999999)),
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
      ),
    );
  }
}
