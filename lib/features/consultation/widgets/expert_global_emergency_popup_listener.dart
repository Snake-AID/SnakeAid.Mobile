import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/http_provider.dart';
import '../../../core/services/emergency_consultation_signalr_service.dart';
import '../repository/consultation_repository.dart';

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
  Timer? _countdownTimer;

  EmergencyConsultationRequestEvent? _activeRequest;
  DateTime? _expiresAtUtc;
  int _countdownSeconds = 0;
  bool _isVisible = false;
  bool _isHandlingAction = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectRealtime();
    });
  }

  Future<void> _connectRealtime() async {
    try {
      final baseUrl = ref.read(httpServiceProvider).baseUrl;
      _service = EmergencyConsultationSignalRService(baseUrl: baseUrl);

      _requestSub = _service!.requestStream.listen((event) {
        if (!mounted) return;

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

      await _service!.connectAsExpert();
    } catch (e) {
      debugPrint('Expert global popup listener connect failed: $e');
    }
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

      context.push(
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
    _service?.dispose();
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
          color: Colors.black54,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Yêu cầu tư vấn khẩn cấp',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bệnh nhân: ${req.requesterName ?? 'Bệnh nhân'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tự từ chối sau $_countdownLabel',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFD97706),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isHandlingAction ? null : _reject,
                            child: const Text('Từ chối'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: _isHandlingAction ? null : _accept,
                            child: Text(
                              _isHandlingAction ? 'Đang xử lý...' : 'Chấp nhận',
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
