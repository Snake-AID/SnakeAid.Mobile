import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../wallet/repository/transaction_repository.dart';
import '../../wallet/repository/withdrawal_repository.dart';
import 'withdrawal_detail_screen.dart';

/// Withdrawal History Screen — shows all withdrawal requests for the current user.
class WalletHistoryScreen extends ConsumerStatefulWidget {
  final Color themeColor;
  final bool showTopup;
  const WalletHistoryScreen({
    super.key,
    this.themeColor = const Color(0xFF228B22),
    this.showTopup = true,
  });

  @override
  ConsumerState<WalletHistoryScreen> createState() =>
      _WalletHistoryScreenState();
}

class _WalletHistoryScreenState
    extends ConsumerState<WalletHistoryScreen> {
  List<WithdrawalInfo> _withdrawals = [];
  List<TransactionInfo> _topups = [];
  bool _isLoading = true;
  String? _error;
  // 0 = Tất cả, 1 = Nạp tiền, 2 = Rút tiền
  int _selectedFilter = 0;

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
      final userId = ref.read(currentUserProvider)?.id;
      final results = await Future.wait([
        ref.read(withdrawalRepositoryProvider).getMyWithdrawals(),
        ref.read(transactionRepositoryProvider).getTransactions(
          userId: userId,
          transType: 'system',
          pageNumber: 1,
          pageSize: 100,
        ),
      ]);
      final withdrawals = results[0] as List<WithdrawalInfo>;
      final allTx = results[1] as List<TransactionInfo>;
      final topups = allTx.where((t) =>
          t.transactionType == 'WalletTopup' &&
          t.externalTransactionId.isNotEmpty).toList();
      if (mounted) {
        setState(() {
          _withdrawals = withdrawals;
          _topups = topups;
          _isLoading = false;
        });
      }
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

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Pending':   return Icons.schedule;
      case 'Approved':  return Icons.check_circle_outline;
      case 'Completed': return Icons.task_alt;
      case 'Rejected':
      case 'Failed':    return Icons.cancel_outlined;
      default:          return Icons.info_outline;
    }
  }

  String _formatAmount(double amount) {
    final f = amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return '$f đ';
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final mo = local.month.toString().padLeft(2, '0');
    final y = local.year;
    final h = local.hour.toString().padLeft(2, '0');
    final mi = local.minute.toString().padLeft(2, '0');
    return '$d/$mo/$y • $h:$mi';
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
          'Lịch Sử Ví',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: Row(
              children: [
                _FilterTab(label: 'Tất cả', selected: _selectedFilter == 0,
                    themeColor: widget.themeColor, onTap: () => setState(() => _selectedFilter = 0)),
                if (widget.showTopup)
                  _FilterTab(label: 'Nạp tiền', selected: _selectedFilter == 1,
                      themeColor: widget.themeColor, onTap: () => setState(() => _selectedFilter = 1)),
                _FilterTab(label: 'Rút tiền', selected: _selectedFilter == 2,
                    themeColor: widget.themeColor, onTap: () => setState(() => _selectedFilter = 2)),
              ],
            ),
          ),
        ),
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
              const Icon(Icons.error_outline, size: 48, color: Color(0xFFDC3545)),
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

    // Build display lists based on selected filter
    final showWithdrawals = _selectedFilter != 1;
    final showTopups = widget.showTopup && _selectedFilter != 2;

    // Combined sorted items (newest first)
    final List<_HistoryEntry> entries = [
      if (showWithdrawals)
        ..._withdrawals.map((w) => _HistoryEntry.withdrawal(w)),
      if (showTopups)
        ..._topups.map((t) => _HistoryEntry.topup(t)),
    ]..sort((a, b) => b.date.compareTo(a.date));

    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 56, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                _selectedFilter == 1
                    ? 'Chưa có lịch sử nạp tiền'
                    : _selectedFilter == 2
                        ? 'Chưa có yêu cầu rút tiền nào'
                        : 'Chưa có giao dịch nào',
                style: const TextStyle(fontSize: 16, color: Color(0xFF888888)),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: widget.themeColor,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final entry = entries[i];
          if (entry.withdrawal != null) {
            final w = entry.withdrawal!;
            return _WithdrawalCard(
              item: w,
              themeColor: widget.themeColor,
              statusLabel: _statusLabel(w.status),
              statusColor: _statusColor(w.status),
              statusIcon: _statusIcon(w.status),
              formatAmount: _formatAmount,
              formatDate: _formatDate,
              onRefresh: _load,
            );
          } else {
            return _TopupCard(
              item: entry.topup!,
              formatAmount: _formatAmount,
              formatDate: _formatDate,
            );
          }
        },
      ),
    );
  }
}

// ── History entry (union) ──────────────────────────────────────────────────

class _HistoryEntry {
  final WithdrawalInfo? withdrawal;
  final TransactionInfo? topup;
  final DateTime date;

  _HistoryEntry.withdrawal(WithdrawalInfo w)
      : withdrawal = w,
        topup = null,
        date = w.createdAt;

  _HistoryEntry.topup(TransactionInfo t)
      : topup = t,
        withdrawal = null,
        date = t.createdAt;
}

// ── Filter Tab ─────────────────────────────────────────────────────────────

class _FilterTab extends StatelessWidget {
  final String label;
  final bool selected;
  final Color themeColor;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.selected,
    required this.themeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? themeColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? themeColor : const Color(0xFF888888),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Topup Card ─────────────────────────────────────────────────────────────

class _TopupCard extends StatelessWidget {
  final TransactionInfo item;
  final String Function(double) formatAmount;
  final String Function(DateTime) formatDate;

  const _TopupCard({
    required this.item,
    required this.formatAmount,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF228B22);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_downward_rounded, color: green, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '+${formatAmount(item.amount)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: green,
                      ),
                    ),
                    const _StatusBadge(label: 'Thành công', color: green),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Nạp tiền qua PayOS',
                  style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                ),
                const SizedBox(height: 2),
                Text(
                  formatDate(item.createdAt),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// ── _WalletHistoryScreenState closing brace was moved above ─────────────────
}

// ── Withdrawal Card ────────────────────────────────────────────────────────

class _WithdrawalCard extends StatelessWidget {
  final WithdrawalInfo item;
  final Color themeColor;
  final String statusLabel;
  final Color statusColor;
  final IconData statusIcon;
  final String Function(double) formatAmount;
  final String Function(DateTime) formatDate;
  final VoidCallback onRefresh;

  const _WithdrawalCard({
    required this.item,
    required this.themeColor,
    required this.statusLabel,
    required this.statusColor,
    required this.statusIcon,
    required this.formatAmount,
    required this.formatDate,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WithdrawalDetailScreen(
              withdrawalId: item.id,
              themeColor: themeColor,
            ),
          ),
        );
        onRefresh();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Status circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor, size: 22),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatAmount(item.amount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF222222),
                        ),
                      ),
                      _StatusBadge(label: statusLabel, color: statusColor),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.bankName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatDate(item.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC), size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Status Badge ───────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
