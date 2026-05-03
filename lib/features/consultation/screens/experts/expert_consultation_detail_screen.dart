import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repository/consultation_repository.dart';
import '../../../../features/wallet/repository/transaction_repository.dart';

/// Chi tiết lịch tư vấn dành cho chuyên gia.
/// Nhận dữ liệu qua [data] map (từ router extra).
class ExpertConsultationDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;

  const ExpertConsultationDetailScreen({super.key, required this.data});

  @override
  ConsumerState<ExpertConsultationDetailScreen> createState() =>
      _ExpertConsultationDetailScreenState();
}

class _ExpertConsultationDetailScreenState
    extends ConsumerState<ExpertConsultationDetailScreen> {
  // ── Helpers ────────────────────────────────────────────────────────────────

  static const _purple = Color(0xFF6C47C2);
  static const _darkPurple = Color(0xFF553C9A);
  static const _green = Color(0xFF28A745);
  static const _red = Color(0xFFDC3545);

  Map<String, dynamic> get data => widget.data;

  // Settlement state
  bool _settlementLoading = false;
  double? _platformFee;
  double? _expertPayout;
  bool _isCancellingBooking = false;

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

  String _formatCurrency(num amount) {
    final intVal = amount.toInt();
    final formatted = intVal.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$formatted ₫';
  }

  @override
  void initState() {
    super.initState();
    if (_isCompleted && data['netPrice'] == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadSettlement());
    }
  }

  Future<void> _loadSettlement() async {
    final consultationId =
        (data['consultationId'] as String?) ?? (data['id'] as String?) ?? '';
    if (consultationId.isEmpty) return;
    if (!mounted) return;
    setState(() => _settlementLoading = true);
    try {
      final txns = await ref
          .read(transactionRepositoryProvider)
          .getTransactions(referenceId: consultationId, pageSize: 10);
      if (!mounted) return;
      double? pf;
      double? ep;
      for (final t in txns) {
        if (t.transactionType.toLowerCase() == 'platformfee') {
          pf = t.amount;
        } else if (t.transactionType.toLowerCase() == 'expertpayout') {
          ep = t.amount;
        }
      }
      setState(() {
        _platformFee = pf;
        _expertPayout = ep;
        _settlementLoading = false;
      });
    } catch (e) {
      debugPrint('⚠️ Settlement load error: $e');
      if (!mounted) return;
      setState(() => _settlementLoading = false);
    }
  }

  Future<void> _cancelBooking() async {
    if (_isCancellingBooking) return;

    final bookingId =
        (data['bookingId'] as String?) ?? (data['id'] as String?) ?? '';
    if (bookingId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy booking để hủy.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Xác Nhận Hủy Lịch',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Bạn có chắc muốn hủy lịch tư vấn này? Member sẽ nhận thông báo từ hệ thống.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Không Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hủy Lịch'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isCancellingBooking = true);
    try {
      await ref.read(consultationRepositoryProvider).cancelScheduledBooking(
            bookingId,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã hủy lịch tư vấn thành công.'),
          backgroundColor: Color(0xFF228B22),
        ),
      );
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCancellingBooking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: _red,
        ),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final consultationId =
        (data['consultationId'] as String?) ?? (data['id'] as String?) ?? '';
    final patientName = data['patientName'] as String? ?? '';
    final patientAvatarUrl = data['patientAvatarUrl'] as String?;
    final patientPhone = data['patientPhone'] as String? ?? '';
    final consultationType = data['consultationType'] as String? ?? '';
    final scheduledMs = (data['scheduledTime'] as int?) ?? 0;
    final paymentDeadlineMs = data['paymentDeadline'] as int?;
    final slotStartMs = data['slotStartTime'] as int?;
    final slotEndMs = data['slotEndTime'] as int?;
    final feeCost = (data['feeCost'] as num?)?.toInt() ?? 0;
    final rating = data['rating'] as double?;
    final durationSeconds = data['durationSeconds'] as int?;
    final durationMinutes = (data['durationMinutes'] as int?) ?? 45;
    final consultationMethod = data['consultationMethod'] as String? ?? 'video';
    final questions = data['questions'] as String?;
    final int? grossPrice = (data['grossPrice'] as num?)?.toInt();
    final int? netPrice = (data['netPrice'] as num?)?.toInt();

    final int displayGross = grossPrice ?? feeCost;
    final int? displayNet = netPrice ?? (_expertPayout?.toInt());
    final int? displayPlatformFee = (netPrice != null) 
        ? (displayGross - netPrice) 
        : (_platformFee?.toInt());

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
                      _Avatar(
                        avatarUrl: patientAvatarUrl,
                        fallbackColor: _purple.withOpacity(0.12),
                        iconColor: _purple,
                        size: 56,
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
                        value: _formatCurrency(displayGross),
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
                      if (paymentDeadlineMs != null) ...[
                        _DetailRow(
                          icon: Icons.timer_outlined,
                          label: 'Hạn thanh toán',
                          value: _formatDateTime(paymentDeadlineMs),
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
                      if (paymentDeadlineMs != null ||
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

                // ── Settlement breakdown (completed only) ──────────────────
                if (_isCompleted) ...[
                  _SectionCard(
                    label: 'PHÂN BỔ THANH TOÁN',
                    child: _settlementLoading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF6C47C2),
                                ),
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              _DetailRow(
                                icon: Icons.receipt_long_outlined,
                                label: 'Chi phí tư vấn',
                                value: _formatCurrency(displayGross),
                              ),
                              if (displayPlatformFee != null) ...[
                                const _Divider(),
                                _DetailRow(
                                  icon: Icons.account_balance_outlined,
                                  label: 'Phí nền tảng',
                                  value: '- ${_formatCurrency(displayPlatformFee)}',
                                  valueColor: _red,
                                ),
                              ],
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF7EE),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.savings_outlined,
                                      size: 17,
                                      color: Color(0xFF1D7A36),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Thực nhận',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1D7A36),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        displayNet != null
                                            ? '+${_formatCurrency(displayNet)}'
                                            : '--',
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF28A745),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_platformFee == null && !_settlementLoading)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: GestureDetector(
                                    onTap: _loadSettlement,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.refresh,
                                            size: 14,
                                            color: Color(0xFF999999)),
                                        SizedBox(width: 4),
                                        Text(
                                          'Tải lại dữ liệu phân bổ',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF999999),
                                          ),
                                        ),
                                      ],
                                    ),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
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
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: _isCancellingBooking ? null : _cancelBooking,
                      icon: _isCancellingBooking
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.event_busy_outlined, size: 18),
                      label: const Text(
                        'Hủy Lịch Tư Vấn',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.withOpacity(0.4)),
                        foregroundColor: const Color(0xFF6B7280),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (!_isActionable && consultationId.isNotEmpty)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push(
                      '/consultation-message-history/$consultationId',
                      extra: {
                        'title': patientName,
                        'isExpertMode': true,
                      },
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 20),
                  label: const Text(
                    'Xem Lịch Sử Tin Nhắn',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _purple, width: 1.3),
                    foregroundColor: _purple,
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

class _Avatar extends StatelessWidget {
  final String? avatarUrl;
  final Color fallbackColor;
  final Color iconColor;
  final double size;

  const _Avatar({
    this.avatarUrl,
    required this.fallbackColor,
    required this.iconColor,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    final url = (avatarUrl ?? '').trim();
    final hasAvatar = url.isNotEmpty;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fallbackColor,
        image: hasAvatar
            ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
            : null,
      ),
      child: hasAvatar
          ? null
          : Icon(Icons.person, size: size * 0.55, color: iconColor),
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
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 17, color: const Color(0xFF8B6CC8)),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
            ),
          ),
          Expanded(
            flex: 3,
            child: trailing != null
                ? Align(
                    alignment: Alignment.centerRight,
                    child: trailing!,
                  )
                : Text(
                    value,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight:
                          valueBold ? FontWeight.w600 : FontWeight.w500,
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
