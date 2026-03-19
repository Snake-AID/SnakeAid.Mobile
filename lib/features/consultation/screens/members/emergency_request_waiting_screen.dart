import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/http_provider.dart';
import '../../../../core/services/emergency_consultation_signalr_service.dart';

class EmergencyRequestWaitingScreen extends ConsumerStatefulWidget {
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
  ConsumerState<EmergencyRequestWaitingScreen> createState() =>
      _EmergencyRequestWaitingScreenState();
}

class _EmergencyRequestWaitingScreenState
    extends ConsumerState<EmergencyRequestWaitingScreen> {
  EmergencyConsultationSignalRService? _signalR;
  StreamSubscription<EmergencyRequestStatusChanged>? _statusSub;

  String _status = 'PendingPayment';
  String? _statusMessage;
  bool _isConnecting = true;

  @override
  void initState() {
    super.initState();
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
        });

        if (event.status == 'AcceptedByExpert' &&
            event.consultationId != null &&
            event.consultationId!.isNotEmpty) {
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
        return 'Đã thanh toán. Đang chờ chuyên gia phản hồi.';
      case 'AcceptedByExpert':
        return 'Chuyên gia đã chấp nhận. Đang chuyển vào phòng tư vấn...';
      case 'DeclinedByExpert':
        return 'Chuyên gia đã từ chối yêu cầu. Vui lòng chọn chuyên gia khác.';
      case 'Expired':
        return 'Yêu cầu đã hết hạn. Vui lòng tạo yêu cầu mới.';
      default:
        return 'Đang theo dõi trạng thái tư vấn ngay...';
    }
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _signalR?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF228B22);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8F6),
        elevation: 0,
        title: const Text(
          'Tư Vấn Ngay',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bolt, color: primary),
                    SizedBox(width: 8),
                    Text(
                      'Yêu cầu tư vấn đã gửi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Chuyên gia: ${widget.expertName}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Request ID: ${widget.requestId}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 18),
                if (_isConnecting)
                  const Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 10),
                      Text('Đang kết nối realtime...'),
                    ],
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _statusMessage ?? 'Đang theo dõi trạng thái...',
                      style: const TextStyle(
                        color: Color(0xFF1F2937),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.go('/consultation-home'),
                        child: const Text('Về trang tư vấn'),
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
  }
}
