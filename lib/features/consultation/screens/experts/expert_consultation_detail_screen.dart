import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Chi tiết lịch tư vấn dành cho chuyên gia.
/// Nhận dữ liệu qua [data] map (từ router extra).
class ExpertConsultationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const ExpertConsultationDetailScreen({super.key, required this.data});

  // ── Helpers ────────────────────────────────────────────────────────────────

  static const _purple = Color(0xFF6C47C2);
  static const _darkPurple = Color(0xFF553C9A);
  static const _green = Color(0xFF28A745);
  static const _red = Color(0xFFDC3545);

  // status index: 0=waiting, 1=upcoming, 2=completed, 3=cancelled
  int get _statusIndex => (data['statusIndex'] as int?) ?? 1;
  bool get _isWaiting => _statusIndex == 0;
  bool get _isUpcoming => _statusIndex == 1;
  bool get _isCompleted => _statusIndex == 2;
  bool get _isCancelled => _statusIndex == 3;
  bool get _isActionable => _isWaiting || _isUpcoming;

  String get _statusLabel {
    switch (_statusIndex) {
      case 0:
        return 'ĐÃ ĐẾN GIỜ';
      case 1:
        return 'SẮP TỚI';
      case 2:
        return 'HOÀN THÀNH';
      case 3:
        return 'ĐÃ HỦY';
      default:
        return 'SẮP TỚI';
    }
  }

  Color get _statusColor {
    switch (_statusIndex) {
      case 0:
        return _red;
      case 1:
        return _purple;
      case 2:
        return _green;
      case 3:
        return Colors.grey;
      default:
        return _purple;
    }
  }

  String _formatDateTime(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/${dt.year}  $h:$min';
  }

  String _formatDateTimePlus7(int ms) {
    return _formatDateTime(ms);
  }

  String _formatCurrency(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ₫';
    }
    return '${(amount / 1000).toStringAsFixed(0)}.000 ₫';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final consultationId =
        (data['consultationId'] as String?) ?? (data['id'] as String?) ?? '';
    final patientName = data['patientName'] as String? ?? '';
    final patientPhone = data['patientPhone'] as String? ?? '';
    final consultationType = data['consultationType'] as String? ?? '';
    final scheduledMs = (data['scheduledTime'] as int?) ?? 0;
    final bookedAtMs = data['bookedAt'] as int?;
    final paymentDeadlineMs = data['paymentDeadline'] as int?;
    final slotStartMs = data['slotStartTime'] as int?;
    final slotEndMs = data['slotEndTime'] as int?;
    final feeCost = (data['feeCost'] as int?) ?? 0;
    final rating = data['rating'] as double?;
    final durationSeconds = data['durationSeconds'] as int?;
    final durationMinutes = (data['durationMinutes'] as int?) ?? 45;
    final consultationMethod = data['consultationMethod'] as String? ?? 'video';
    final questions = data['questions'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Color(0xFF2D2D2D),
          ),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Chi Tiết Tư Vấn',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _statusColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              children: [
                // ── Patient info ────────────────────────────────────────────
                _SectionCard(
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _purple.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: _purple,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patientName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D2D2D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              patientPhone.isEmpty
                                  ? 'Khách hàng'
                                  : patientPhone,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: consultationType == 'Khẩn Cấp'
                              ? _red.withOpacity(0.1)
                              : _purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          consultationType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: consultationType == 'Khẩn Cấp'
                                ? _red
                                : _purple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Appointment details ─────────────────────────────────────
                _SectionCard(
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.calendar_today,
                        label: 'Ngày & Giờ',
                        value: scheduledMs > 0
                            ? _formatDateTime(scheduledMs)
                            : '--',
                      ),
                      const _Divider(),
                      _DetailRow(
                        icon: consultationMethod == 'video'
                            ? Icons.videocam
                            : Icons.chat,
                        label: 'Hình Thức',
                        value: '',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                consultationMethod == 'video'
                                    ? Icons.videocam
                                    : Icons.chat_bubble,
                                size: 14,
                                color: _purple,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                consultationMethod == 'video'
                                    ? 'Gọi video'
                                    : 'Chat',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _purple,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const _Divider(),
                      _DetailRow(
                        icon: Icons.schedule,
                        label: 'Thời Lượng Dự Kiến',
                        value: '$durationMinutes phút',
                      ),
                      const _Divider(),
                      _DetailRow(
                        icon: Icons.payments_outlined,
                        label: 'Phí Tư Vấn',
                        value: _formatCurrency(feeCost),
                        valueColor: _isCompleted ? _green : _darkPurple,
                        valueBold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                _SectionCard(
                  label: 'Thông Tin Phiên Tư Vấn',
                  child: Column(
                    children: [
                      if (bookedAtMs != null)
                        _DetailRow(
                          icon: Icons.event_available_outlined,
                          label: 'Đặt lúc',
                          value: _formatDateTimePlus7(bookedAtMs),
                        ),
                      if (bookedAtMs != null &&
                          (paymentDeadlineMs != null ||
                              slotStartMs != null ||
                              slotEndMs != null))
                        const _Divider(),
                      if (paymentDeadlineMs != null) ...[
                        _DetailRow(
                          icon: Icons.timer_outlined,
                          label: 'Hạn thanh toán',
                          value: _formatDateTimePlus7(paymentDeadlineMs),
                        ),
                        if (slotStartMs != null || slotEndMs != null)
                          const _Divider(),
                      ],
                      if (slotStartMs != null) ...[
                        _DetailRow(
                          icon: Icons.schedule_outlined,
                          label: 'Bắt đầu khung giờ',
                          value: _formatDateTime(slotStartMs),
                        ),
                        if (slotEndMs != null) const _Divider(),
                      ],
                      if (slotEndMs != null) ...[
                        _DetailRow(
                          icon: Icons.schedule,
                          label: 'Kết thúc khung giờ',
                          value: _formatDateTime(slotEndMs),
                        ),
                      ],
                      if (bookedAtMs != null ||
                          paymentDeadlineMs != null ||
                          slotStartMs != null ||
                          slotEndMs != null)
                        const _Divider(),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Questions ──────────────────────────────────────────────
                if (questions?.isNotEmpty == true) ...[
                  _SectionCard(
                    label: 'Câu Hỏi Của Bệnh Nhân',
                    child: Text(
                      questions!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2D2D2D),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Rating (completed only) ─────────────────────────────────
                if (_isCompleted && durationSeconds != null) ...[
                  _SectionCard(
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: _green, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Thời Lượng Thực Tế: ${_fmtSec(durationSeconds!)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '+${_formatCurrency(feeCost)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                if (_isCompleted && rating != null) ...[
                  _SectionCard(
                    label: 'Đánh Giá Của Bệnh Nhân',
                    child: Row(
                      children: [
                        ...List.generate(5, (i) {
                          final full = i < rating.floor();
                          final half = !full && i < rating;
                          return Icon(
                            full
                                ? Icons.star
                                : (half ? Icons.star_half : Icons.star_border),
                            size: 24,
                            color: const Color(0xFFFFC107),
                          );
                        }),
                        const SizedBox(width: 10),
                        Text(
                          '${rating.toStringAsFixed(1)} / 5.0',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Cancelled note ─────────────────────────────────────────
                if (_isCancelled) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.cancel_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Lịch tư vấn này đã bị hủy.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                const SizedBox(height: 80),
              ],
            ),
          ),

          // ── Action button ─────────────────────────────────────────────────
          if (_isActionable)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push(
                      '/expert-video-waiting/$consultationId',
                      extra: {
                        'consultationId': consultationId,
                        'patientName': patientName,
                        'consultationType': consultationType,
                        'feeCost': feeCost,
                      },
                    );
                  },
                  icon: const Icon(Icons.videocam, size: 22),
                  label: const Text(
                    'Bắt Đầu Tư Vấn',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isWaiting ? _red : _purple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _fmtSec(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}

// ── Shared helper widgets ──────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String? label;
  final Widget child;

  const _SectionCard({this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          if (label != null) ...[
            Text(
              label!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF999999),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
          ],
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool valueBold;
  final Widget? trailing;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueBold = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6C47C2)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
            ),
          ),
          trailing ??
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: valueBold ? FontWeight.bold : FontWeight.w500,
                    color: valueColor ?? const Color(0xFF2D2D2D),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: Color(0xFFF0F0F0));
  }
}
