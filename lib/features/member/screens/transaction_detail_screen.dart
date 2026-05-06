import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../wallet/repository/transaction_repository.dart';

class TransactionDetailScreen extends ConsumerStatefulWidget {
  final String transactionId;
  final Color themeColor;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
    this.themeColor = const Color(0xFF228B22),
  });

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends ConsumerState<TransactionDetailScreen> {
  TransactionInfo? _tx;
  bool _isLoading = true;
  String? _error;

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
      final tx = await ref
          .read(transactionRepositoryProvider)
          .getTransactionById(widget.transactionId);
      if (mounted)
        setState(() {
          _tx = tx;
          _isLoading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _formatAmount(double amount) {
    final f = amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return '$f đ';
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final mo = local.month.toString().padLeft(2, '0');
    final y = local.year;
    final h = local.hour.toString().padLeft(2, '0');
    final mi = local.minute.toString().padLeft(2, '0');
    final s = local.second.toString().padLeft(2, '0');
    return '$d/$mo/$y lúc $h:$mi:$s';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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
          'Chi Tiết Giao Dịch',
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
      return Center(child: CircularProgressIndicator(color: widget.themeColor));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFFDC3545),
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF666666)),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.themeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final tx = _tx!;
    final credit = isCredit(tx.transactionType);
    final amountColor = credit
        ? const Color(0xFF228B22)
        : const Color(0xFFDC3545);
    final amountPrefix = credit ? '+' : '-';
    final typeLabel = transTypeLabel(tx.transactionType);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Amount hero ────────────────────────────────────────────────
          Container(
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
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: amountColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    credit
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: amountColor,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$amountPrefix${_formatAmount(tx.amount)}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  typeLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Transaction info ───────────────────────────────────────────
          _SectionCard(
            title: 'THÔNG TIN GIAO DỊCH',
            children: [
              _DetailRow(label: 'Loại giao dịch', value: typeLabel),
              _DetailRow(
                label: 'Phương thức',
                value: tx.paymentMethod.isEmpty
                    ? '—'
                    : (tx.paymentMethod == 'PayOS' ? 'PayOS' : 'SnakeAidPay'),
              ),
              _DetailRow(
                label: 'Mô tả',
                value: tx.description.isEmpty ? '—' : tx.description,
              ),
              _DetailRow(label: 'Tiền tệ', value: tx.currency),
              _DetailRow(label: 'Thời gian', value: _formatDate(tx.createdAt)),
            ],
          ),
          const SizedBox(height: 12),

          // ── Reference info ─────────────────────────────────────────────
          _SectionCard(
            title: 'THÔNG TIN THAM CHIẾU',
            children: [
              _CopyRow(label: 'Mã giao dịch', value: tx.id),
              if (tx.referenceId.isNotEmpty)
                _CopyRow(label: 'Mã tham chiếu', value: tx.referenceId),
              if (tx.externalTransactionId.isNotEmpty)
                _CopyRow(
                  label: 'Mã ngoài hệ thống',
                  value: tx.externalTransactionId,
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Account info ───────────────────────────────────────────────
          if (tx.fullName.isNotEmpty || tx.userName.isNotEmpty)
            _SectionCard(
              title: 'TÀI KHOẢN',
              children: [
                if (tx.fullName.isNotEmpty)
                  _DetailRow(label: 'Tên', value: tx.fullName),
                if (tx.userName.isNotEmpty)
                  _DetailRow(label: 'Email', value: tx.userName),
              ],
            ),
          const SizedBox(height: 24),
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
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF999999),
              letterSpacing: 0.6,
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

// ── Copy Row ───────────────────────────────────────────────────────────────

class _CopyRow extends StatelessWidget {
  final String label;
  final String value;
  const _CopyRow({required this.label, required this.value});

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
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF222222),
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã sao chép'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Icon(
              Icons.copy_rounded,
              size: 16,
              color: Color(0xFFAAAAAA),
            ),
          ),
        ],
      ),
    );
  }
}
