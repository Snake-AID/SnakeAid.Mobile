import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/consultation_booking_response.dart';
import '../../repository/consultation_repository.dart';

/// Màn hình hoàn thành tư vấn dành cho chuyên gia.
/// Nhận dữ liệu qua [data] map từ router extra.
class ExpertConsultationCompletionScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;

  const ExpertConsultationCompletionScreen({super.key, required this.data});

  @override
  ConsumerState<ExpertConsultationCompletionScreen> createState() =>
      _ExpertConsultationCompletionScreenState();
}

class _ExpertConsultationCompletionScreenState
    extends ConsumerState<ExpertConsultationCompletionScreen> {
  static const _purple = Color(0xFF6C47C2);
  static const _green = Color(0xFF16A34A);

  bool _isSyncingSessionData = false;
  late String _patientName;
  String? _patientAvatarUrl;
  late int _durationSeconds;
  late int _feeCost;
  DateTime? _sessionTime;
  String? _problemDescription;
  int? _grossPrice;
  int? _netPrice;

  @override
  void initState() {
    super.initState();
    _patientName =
        (widget.data['patientName'] as String?)?.trim().isNotEmpty == true
        ? (widget.data['patientName'] as String).trim()
        : 'Bệnh nhân';
    _patientAvatarUrl = widget.data['patientAvatarUrl'] as String?;
    _durationSeconds = _toInt(widget.data['durationSeconds']);
    _feeCost = _toInt(widget.data['feeCost']);
    _sessionTime = widget.data['sessionTime'] as DateTime?;
    _problemDescription = (widget.data['problemDescription'] as String?)
        ?.trim();

    _syncCompletedSessionData();
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  Future<void> _syncCompletedSessionData() async {
    final consultationId = (widget.data['consultationId'] ?? '')
        .toString()
        .trim();
    if (consultationId.isEmpty) return;

    setState(() => _isSyncingSessionData = true);
    try {
      final repo = ref.read(consultationRepositoryProvider);
      ConsultationBookingResponse? matched;

      Future<void> scan({String? status}) async {
        for (var page = 1; page <= 3 && matched == null; page++) {
          final items = await repo.getExpertBookings(
            status: status,
            pageNumber: page,
            pageSize: 25,
          );
          if (items.isEmpty) break;

          for (final item in items) {
            final itemConsultationId = (item.consultationId ?? '').trim();
            if (itemConsultationId == consultationId ||
                item.id == consultationId) {
              matched = item;
              break;
            }
          }
        }
      }

      await scan(status: 'Completed');
      if (matched == null) {
        await scan();
      }

      if (!mounted || matched == null) return;

      final booking = matched!;
      final resolvedName = (booking.userName ?? '').trim();
      final resolvedDurationSeconds =
          booking.slotStartTime != null && booking.slotEndTime != null
          ? booking.slotEndTime!.difference(booking.slotStartTime!).inSeconds
          : 0;

      setState(() {
        if (resolvedName.isNotEmpty) {
          _patientName = resolvedName;
        }
        final resolvedAvatar = (booking.userAvatarUrl ?? '').trim();
        if (resolvedAvatar.isNotEmpty) {
          _patientAvatarUrl = resolvedAvatar;
        }
        if (booking.feeCost > 0) {
          _feeCost = booking.feeCost;
        }
        _grossPrice = booking.grossPrice;
        _netPrice = booking.netPrice;

        if (_durationSeconds <= 0 && resolvedDurationSeconds > 0) {
          _durationSeconds = resolvedDurationSeconds;
        }
        _sessionTime = booking.slotStartTime ?? booking.scheduledTime;

        final problem = (booking.problemDescription ?? '').trim();
        if (problem.isNotEmpty) {
          _problemDescription = problem;
        }
      });
    } catch (e) {
      debugPrint('⚠️ Could not sync completion data from history: $e');
    } finally {
      if (mounted) {
        setState(() => _isSyncingSessionData = false);
      }
    }
  }

  String _fmtDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (s == 0) return '$m phút';
    return '$m phút $s giây';
  }

  String _fmtCurrency(int amount) {
    if (amount <= 0) return '0 VNĐ';
    // Insert dots every 3 digits from right
    final s = amount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${buf.toString()} VNĐ';
  }

  @override
  Widget build(BuildContext context) {
    final patientName = _patientName;
    final durationSeconds = _durationSeconds;

    // Logic: Use grossPrice/netPrice if available from sync, otherwise fallback to feeCost (10%)
    final int feeCost = _grossPrice ?? _feeCost;
    final int? netAmount = _netPrice;
    final int platformFee = (netAmount != null)
        ? (feeCost - netAmount)
        : (feeCost * 0.1).round();
    final int finalNet = netAmount ?? (feeCost - platformFee);

    final now = _sessionTime ?? DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}'
        ' - ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // ── Success Header ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 36, 16, 20),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: _green,
                              size: 100,
                            ),
                            Positioned(
                              top: -8,
                              right: -12,
                              child: Icon(
                                Icons.auto_awesome,
                                color: Colors.amber[400],
                                size: 28,
                              ),
                            ),
                            Positioned(
                              bottom: -4,
                              left: -12,
                              child: Icon(
                                Icons.auto_awesome,
                                color: Colors.amber[400],
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '✓ Hoàn Tất Tư Vấn\nThành Công!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _green,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Báo cáo đã được gửi đến $patientName',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Session Card ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF0F0F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: _purple.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                      image:
                                          (_patientAvatarUrl ?? '')
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : DecorationImage(
                                              image: NetworkImage(
                                                _patientAvatarUrl!.trim(),
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                      border: Border.all(
                                        color: _purple.withOpacity(0.2),
                                        width: 2,
                                      ),
                                    ),
                                    child:
                                        (_patientAvatarUrl ?? '').trim().isEmpty
                                        ? const Icon(
                                            Icons.person,
                                            color: _purple,
                                            size: 30,
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF28A745),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
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
                                        color: Color(0xFF1A1A2E),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      dateStr,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF888888),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Divider(height: 1, color: Color(0xFFF0F0F0)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _Pill(
                                icon: Icons.schedule,
                                label: durationSeconds > 0
                                    ? _fmtDuration(durationSeconds)
                                    : '-- phút',
                                iconColor: const Color(0xFF888888),
                                bgColor: const Color(0xFFF5F5F5),
                                textColor: const Color(0xFF555555),
                              ),
                              const SizedBox(width: 8),
                              const _Pill(
                                icon: Icons.videocam,
                                label: 'Video Call',
                                iconColor: _purple,
                                bgColor: Color(0xFFEDE8FA),
                                textColor: _purple,
                              ),
                            ],
                          ),
                          if ((_problemDescription ?? '').isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Text(
                                _problemDescription!,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF4B5563),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // ── Payment Card ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: _isSyncingSessionData
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                SizedBox(height: 4),
                                _ShimmerPlaceholder(
                                  width: 120,
                                  height: 20,
                                  radius: 20,
                                ),
                                SizedBox(height: 16),
                                _ShimmerPlaceholder(
                                  width: double.infinity,
                                  height: 18,
                                  radius: 6,
                                ),
                                SizedBox(height: 10),
                                _ShimmerPlaceholder(
                                  width: double.infinity,
                                  height: 18,
                                  radius: 6,
                                ),
                                SizedBox(height: 12),
                                _ShimmerPlaceholder(
                                  width: double.infinity,
                                  height: 1,
                                  radius: 1,
                                ),
                                SizedBox(height: 12),
                                _ShimmerPlaceholder(
                                  width: 140,
                                  height: 20,
                                  radius: 6,
                                ),
                                SizedBox(height: 10),
                                _ShimmerPlaceholder(
                                  width: double.infinity,
                                  height: 14,
                                  radius: 6,
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _green,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'THANH TOÁN HOÀN TẤT',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _PayRow(
                                  label: 'Phí tư vấn',
                                  value: _fmtCurrency(feeCost),
                                  valueColor: const Color(0xFF1A1A2E),
                                ),
                                const SizedBox(height: 10),
                                _PayRow(
                                  label: 'Phí nền tảng',
                                  value: '-${_fmtCurrency(platformFee)}',
                                  valueColor: const Color(0xFFDC3545),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: DashedDivider(),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Bạn nhận được',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                    Text(
                                      '+${_fmtCurrency(finalNet)}',
                                      style: TextStyle(
                                        fontSize: finalNet > 999999 ? 20 : 22,
                                        fontWeight: FontWeight.bold,
                                        color: _green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet,
                                      size: 16,
                                      color: _green,
                                    ),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Chuyển vào ví SnakeAid trong vòng 24h',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ),

                  // ── Checklist ─────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          _CheckItem('Báo cáo đã được lưu vào hồ sơ'),
                          SizedBox(height: 12),
                          _CheckItem(
                            "Bạn có thể xem lại trong 'Lịch Sử Tư Vấn'",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Actions ────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: const Border(top: BorderSide(color: Color(0xFFF0F0F0))),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go(
                      '/expert-home',
                      extra: {'initialTab': 1, 'initialConsultationsTab': 1},
                    ),
                    icon: const Icon(Icons.description_outlined, size: 20),
                    label: const Text('Về Lịch Sử Tư Vấn'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _purple, width: 1.5),
                      foregroundColor: _purple,
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.go('/expert-home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: const Text('Về Trang Chủ'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color bgColor;
  final Color textColor;

  const _Pill({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _PayRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String text;

  const _CheckItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFFDCFCE7),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Color(0xFF16A34A), size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
          ),
        ),
      ],
    );
  }
}

class DashedDivider extends StatelessWidget {
  const DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final count = (constraints.constrainWidth() / (dashWidth + dashSpace))
            .floor();
        return Row(
          children: List.generate(
            count,
            (_) => const Padding(
              padding: EdgeInsets.only(right: dashSpace),
              child: SizedBox(
                width: dashWidth,
                height: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xFF86EFAC)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerPlaceholder extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerPlaceholder({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween(
      begin: 0.35,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: widget.width == double.infinity ? double.infinity : widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: const Color(0xFFECEFF1),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}
