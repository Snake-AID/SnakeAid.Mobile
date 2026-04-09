import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../wallet/repository/withdrawal_repository.dart';

/// Withdrawal Detail Screen — shows full detail for one withdrawal request.
/// Also allows the user to cancel a Pending request.
class WithdrawalDetailScreen extends ConsumerStatefulWidget {
  final String withdrawalId;
  final Color themeColor;

  const WithdrawalDetailScreen({
    super.key,
    required this.withdrawalId,
    this.themeColor = const Color(0xFF228B22),
  });

  @override
  ConsumerState<WithdrawalDetailScreen> createState() =>
      _WithdrawalDetailScreenState();
}

class _WithdrawalDetailScreenState
    extends ConsumerState<WithdrawalDetailScreen> {
  WithdrawalInfo? _withdrawal;
  bool _isLoading = true;
  String? _error;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final w = await ref
          .read(withdrawalRepositoryProvider)
          .getWithdrawalById(widget.withdrawalId);
      if (mounted) setState(() { _withdrawal = w; _isLoading = false; });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
    }
  }

  // ── Status helpers ───────────────────────────────────────────────────────

  String _statusLabel(String status) {
    switch (status) {
      case 'Pending':   return 'Chờ duyệt';
      case 'Approved':  return 'Đã duyệt';
      case 'Rejected':  return 'Đã hủy';
      case 'Completed': return 'Hoàn tất';
      case 'Failed':    return 'Thất bại';
      default:          return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':   return const Color(0xFFFF9800);
      case 'Approved':  return const Color(0xFF2196F3);
      case 'Rejected':  return const Color(0xFFDC3545);
      case 'Completed': return const Color(0xFF228B22);
      case 'Failed':    return const Color(0xFFDC3545);
      default:          return const Color(0xFF888888);
    }
  }

  String _formatAmount(double amount) {
    final f = amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return '$f đ';
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final mo = local.month.toString().padLeft(2, '0');
    final y = local.year;
    final h = local.hour.toString().padLeft(2, '0');
    final mi = local.minute.toString().padLeft(2, '0');
    return '$d/$mo/$y lúc $h:$mi';
  }

  // ── Cancel ───────────────────────────────────────────────────────────────

  Future<void> _onCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hủy yêu cầu?',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333)),
        ),
        content: const Text(
          'Bạn có chắc muốn hủy yêu cầu rút tiền này?\nThao tác không thể hoàn tác.',
          style: TextStyle(color: Color(0xFF555555)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Không', style: TextStyle(color: Color(0xFF666666))),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hủy yêu cầu',
                style: TextStyle(
                    color: Color(0xFFDC3545), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isCancelling = true);
    try {
      final updated = await ref
          .read(withdrawalRepositoryProvider)
          .cancelWithdrawal(widget.withdrawalId);
      if (!mounted) return;
      setState(() {
        _withdrawal = updated;
        _isCancelling = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã hủy yêu cầu rút tiền'),
          backgroundColor: Color(0xFF444444),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCancelling = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: const Color(0xFFDC3545),
        ),
      );
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF333333)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Chi Tiết Rút Tiền',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        actions: [
          if (!_isLoading && _error == null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF555555)),
              onPressed: _load,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: widget.themeColor),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: Color(0xFFDC3545)),
              const SizedBox(height: 16),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF666666))),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.themeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final w = _withdrawal!;
    final statusColor = _statusColor(w.status);

    return RefreshIndicator(
      color: widget.themeColor,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status hero card ─────────────────────────────────────────
            _StatusHeroCard(
              status: w.status,
              statusLabel: _statusLabel(w.status),
              statusColor: statusColor,
              amount: _formatAmount(w.amount),
            ),
            const SizedBox(height: 16),

            // ── Bank info ────────────────────────────────────────────────
            _SectionCard(
              title: 'Thông Tin Ngân Hàng',
              children: [
                _DetailRow(
                  label: 'Ngân hàng',
                  value: w.bankName,
                ),
                _DetailRow(
                  label: 'Số tài khoản',
                  value: w.bankAccount,
                ),
                _DetailRow(
                  label: 'Chủ tài khoản',
                  value: w.accountHolderName,
                ),
                if (w.bankBin != null)
                  _DetailRow(label: 'BIN', value: w.bankBin!),
              ],
            ),
            const SizedBox(height: 12),

            // ── Timeline ─────────────────────────────────────────────────
            _SectionCard(
              title: 'Thời Gian',
              children: [
                _DetailRow(
                  label: 'Tạo lúc',
                  value: _formatDate(w.createdAt),
                ),
                _DetailRow(
                  label: 'Xử lý lúc',
                  value: _formatDate(w.processedAt),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Rejection / fail reason ───────────────────────────────────
            if (w.rejectionReason != null) ...[
              _SectionCard(
                title: w.status == 'Rejected' ? 'Lý Do Hủy' : 'Lý Do Thất Bại',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      w.rejectionReason == "Cancelled by user" ? "Đã hủy bởi người dùng" :
                      w.rejectionReason!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],


            // ── Cancel button ────────────────────────────────────────────
            if (w.status == 'Pending') ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isCancelling ? null : _onCancel,
                  icon: _isCancelling
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFDC3545),
                          ),
                        )
                      : const Icon(Icons.cancel_outlined),
                  label: Text(_isCancelling ? 'Đang hủy...' : 'Hủy Yêu Cầu'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC3545),
                    side: const BorderSide(color: Color(0xFFDC3545), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Status Hero Card ───────────────────────────────────────────────────────

class _StatusHeroCard extends StatelessWidget {
  final String status;
  final String statusLabel;
  final Color statusColor;
  final String amount;

  const _StatusHeroCard({
    required this.status,
    required this.statusLabel,
    required this.statusColor,
    required this.amount,
  });

  IconData get _icon {
    switch (status) {
      case 'Pending':   return Icons.schedule;
      case 'Approved':  return Icons.check_circle_outline;
      case 'Completed': return Icons.task_alt;
      case 'Rejected':
      case 'Failed':    return Icons.cancel_outlined;
      default:          return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: statusColor, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Card ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF999999),
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

// ── Detail Row ─────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF222222),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


