import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../wallet/repository/transaction_repository.dart';
import 'transaction_detail_screen.dart';

/// Payment History Screen — shows transaction history via GET /api/transactions.
/// [themeColor] adapts the accent color per role (Member=green, Expert=purple, Rescuer=blue).
/// [filterTypes] constrains the available filter chips to role-relevant types.
///   Pass null to show all types.
class PaymentHistoryScreen extends ConsumerStatefulWidget {
  final Color themeColor;
  final List<String>? filterTypes;
  final String title;

  const PaymentHistoryScreen({
    super.key,
    this.themeColor = const Color(0xFF228B22),
    this.filterTypes,
    this.title = 'Lịch Sử Thanh Toán',
  });

  @override
  ConsumerState<PaymentHistoryScreen> createState() =>
      _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  // â”€â”€ Filter state â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  String? _selectedType; // null = "Tất cả"

  // â”€â”€ Pagination state â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final List<TransactionInfo> _items = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _page = 1;
  static const int _pageSize = 20;

  // â”€â”€ Scroll controller â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initialLoad();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // â”€â”€ Data loading â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _initialLoad() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _items.clear();
      _page = 1;
      _hasMore = true;
    });
    await _fetchPage();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchPage() async {
    final userId = ref.read(currentUserProvider)?.id;
    try {
      final result = await ref
          .read(transactionRepositoryProvider)
          .getTransactions(
            userId: userId,
            transType: _selectedType,
            pageNumber: _page,
            pageSize: _pageSize,
          );
      if (!mounted) return;
      setState(() {
        _items.addAll(result);
        if (result.length < _pageSize) _hasMore = false;
        _error = null;
      });
    } catch (e) {
      if (mounted)
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    _page++;
    await _fetchPage();
    if (mounted) setState(() => _isLoadingMore = false);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _onFilterChanged(String? type) {
    if (_selectedType == type) return;
    setState(() => _selectedType = type);
    _initialLoad();
  }

  // â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  String _formatAmount(double amount) {
    return amount
            .toStringAsFixed(0)
            .replaceAllMapped(
              RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]}.',
            ) +
        ' đ';
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

  // â”€â”€ Filter chips list â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  // Category strings accepted by the API's TransType query param
  static const Map<String, (String, IconData)> _kCategoryMeta = {
    'consultation': ('Tư vấn', Icons.forum_rounded),
    'snake catching': ('Bắt rắn', Icons.catching_pokemon),
    'snakebite incident': ('Rắn cắn', Icons.emergency_rounded),
    'system': ('Hệ thống', Icons.account_balance_wallet_rounded),
  };

  List<_FilterChipData> get _chips {
    const allChip = _FilterChipData(null, 'Tất cả', Icons.apps_rounded);
    final all = [
      allChip,
      for (final entry in _kCategoryMeta.entries)
        _FilterChipData(entry.key, entry.value.$1, entry.value.$2),
    ];
    if (widget.filterTypes == null) return all;
    return all
        .where((c) => c.type == null || widget.filterTypes!.contains(c.type))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        elevation: 1,
        shadowColor: Colors.black12,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter bar
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: _chips.map((c) {
                  final selected = _selectedType == c.type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _FilterChip(
                      data: c,
                      selected: selected,
                      themeColor: widget.themeColor,
                      onTap: () => _onFilterChanged(c.type),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // List
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: widget.themeColor));
    }
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF666666)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _initialLoad,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.themeColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'Chưa có giao dịch',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lịch sử giao dịch sẽ hiển thị tại đây.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: widget.themeColor,
      onRefresh: _initialLoad,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _items.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(color: widget.themeColor),
              ),
            );
          }
          final tx = _items[index];
          return _TransactionCard(
            transaction: tx,
            themeColor: widget.themeColor,
            formattedAmount: _formatAmount(tx.amount),
            formattedDate: _formatDate(tx.createdAt),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TransactionDetailScreen(
                  transactionId: tx.id,
                  themeColor: widget.themeColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// â”€â”€ Support classes â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _FilterChipData {
  final String? type;
  final String label;
  final IconData icon;
  const _FilterChipData(this.type, this.label, this.icon);
}

class _FilterChip extends StatelessWidget {
  final _FilterChipData data;
  final bool selected;
  final Color themeColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.data,
    required this.selected,
    required this.themeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? themeColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: selected ? null : Border.all(color: const Color(0xFFDDDDDD)),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: themeColor.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              data.icon,
              size: 15,
              color: selected ? Colors.white : const Color(0xFF777777),
            ),
            const SizedBox(width: 6),
            Text(
              data.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF555555),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionInfo transaction;
  final Color themeColor;
  final String formattedAmount;
  final String formattedDate;
  final VoidCallback onTap;

  const _TransactionCard({
    required this.transaction,
    required this.themeColor,
    required this.formattedAmount,
    required this.formattedDate,
    required this.onTap,
  });

  IconData get _icon {
    switch (transaction.transactionType) {
      case 'ConsultationPayment':
      case 'ConsultationRefund':
        return Icons.forum_outlined;
      case 'ExpertPayout':
        return Icons.payments_outlined;
      case 'MissionDonation':
      case 'RescuerReward':
        return Icons.volunteer_activism_outlined;
      case 'CatchingPayment':
      case 'CatcherPayout':
      case 'CatchingRefund':
      case 'CatchingDeposit':
        return Icons.catching_pokemon_outlined;
      case 'SnakebiteIncidentPayment':
      case 'SnakebiteIncidentRefund':
        return Icons.emergency_outlined;
      case 'WalletTopup':
        return Icons.add_card_outlined;
      case 'WalletWithdraw':
        return Icons.account_balance_outlined;
      case 'PlatformFee':
        return Icons.percent_outlined;
      case 'AdminAdjustment':
        return Icons.tune_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final credit = isCredit(transaction.transactionType);
    final amountColor = credit
        ? const Color(0xFF2E7D32)
        : const Color(0xFF333333);
    final prefix = credit ? '+' : '-';
    final iconBg = themeColor.withOpacity(0.1);
    final iconColor = themeColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(_icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transTypeLabel(transaction.transactionType),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  if (transaction.description?.isNotEmpty == true) ...[
                    const SizedBox(height: 2),
                    Text(
                      transaction.description!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFAAAAAA),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$prefix$formattedAmount',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
