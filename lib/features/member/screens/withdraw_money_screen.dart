import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../wallet/repository/wallet_repository.dart';
import '../../wallet/repository/withdrawal_repository.dart';

/// Withdraw Money Screen — request a withdrawal from SnakeAidPay wallet.
class WithdrawMoneyScreen extends ConsumerStatefulWidget {
  final Color themeColor;
  const WithdrawMoneyScreen({
    super.key,
    this.themeColor = const Color(0xFF228B22),
  });

  @override
  ConsumerState<WithdrawMoneyScreen> createState() =>
      _WithdrawMoneyScreenState();
}

class _WithdrawMoneyScreenState extends ConsumerState<WithdrawMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();

  WalletInfo? _walletInfo;
  bool _isLoadingWallet = true;

  List<BankInfo> _banks = [];
  bool _isLoadingBanks = true;
  BankInfo? _selectedBank;

  bool _isSubmitting = false;

  int _activeWithdrawalCount = 0;
  bool _isCheckingActive = false;

  static const List<int> _quickAmounts = [
    100000,
    500000,
    1000000,
    2000000,
    5000000,
  ];

  @override
  void initState() {
    super.initState();
    _loadWallet();
    _loadBanks();
    _loadActiveWithdrawals();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  Future<void> _loadWallet() async {
    try {
      final wallet = await ref.read(walletRepositoryProvider).getWalletInfo();
      if (mounted)
        setState(() {
          _walletInfo = wallet;
          _isLoadingWallet = false;
        });
    } catch (_) {
      if (mounted) setState(() => _isLoadingWallet = false);
    }
  }

  Future<void> _loadBanks() async {
    try {
      final banks = await ref.read(withdrawalRepositoryProvider).getBanks();
      if (mounted) {
        setState(() {
          // Prioritize TransferSupported
          _banks = banks
            ..sort((a, b) {
              final aS = a.vietQrStatus == 'TransferSupported' ? 0 : 1;
              final bS = b.vietQrStatus == 'TransferSupported' ? 0 : 1;
              return aS.compareTo(bS);
            });
          _isLoadingBanks = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingBanks = false);
    }
  }

  Future<void> _loadActiveWithdrawals() async {
    if (!mounted) return;
    setState(() => _isCheckingActive = true);
    try {
      final list = await ref
          .read(withdrawalRepositoryProvider)
          .getMyWithdrawals();
      final count = list
          .where((w) => w.status == 'Pending' || w.status == 'Approved')
          .length;
      if (mounted)
        setState(() {
          _activeWithdrawalCount = count;
          _isCheckingActive = false;
        });
    } catch (_) {
      if (mounted) setState(() => _isCheckingActive = false);
    }
  }

  Future<void> _showBankPicker() async {
    final result = await showModalBottomSheet<BankInfo>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BankPickerSheet(banks: _banks),
    );
    if (result != null) setState(() => _selectedBank = result);
  }

  void _showLimitReachedDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.block_rounded, color: Color(0xFFDC3545)),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Đã đạt giới hạn rút tiền',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'Bạn đang có 3 yêu cầu rút tiền chưa hoàn tất (Chờ duyệt / Đã duyệt). Vui lòng đợi admin xử lý trước khi tạo yêu cầu mới.',
          style: TextStyle(fontSize: 14, color: Color(0xFF555555), height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.themeColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (_activeWithdrawalCount >= 3) {
      _showLimitReachedDialog();
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBank == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ngân hàng')));
      return;
    }

    final raw = _amountController.text
        .replaceAll('.', '')
        .replaceAll(',', '')
        .trim();
    final amount = double.tryParse(raw) ?? 0;

    // Confirm dialog
    final confirmed = await _showConfirmDialog(amount);
    if (confirmed != true) return;

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(withdrawalRepositoryProvider)
          .createWithdrawal(
            amount: amount,
            bankAccount: _accountNumberController.text.trim(),
            bankName: _selectedBank!.name,
            accountHolderName: _accountNameController.text.trim().toUpperCase(),
            bankBin: _selectedBank!.bin,
          );
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await _showSuccessDialog(amount);
      await _loadWallet();
      await _loadActiveWithdrawals();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: const Color(0xFFDC3545),
        ),
      );
    }
  }

  Future<bool?> _showConfirmDialog(double amount) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Xác nhận rút tiền',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ConfirmRow(label: 'Số tiền', value: _formatCurrency(amount)),
            const Divider(height: 24),
            _ConfirmRow(
              label: 'Ngân hàng',
              value: _selectedBank?.shortName ?? '',
            ),
            const SizedBox(height: 8),
            _ConfirmRow(label: 'Số TK', value: _accountNumberController.text),
            const SizedBox(height: 8),
            _ConfirmRow(
              label: 'Tên TK',
              value: _accountNameController.text.trim().toUpperCase(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Hủy',
              style: TextStyle(color: Color(0xFF888888)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.themeColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSuccessDialog(double amount) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: widget.themeColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: widget.themeColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Yêu cầu rút tiền đã gửi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _formatCurrency(amount),
              style: TextStyle(
                fontSize: 20,
                color: widget.themeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Yêu cầu đang chờ admin xét duyệt. Tiền sẽ được chuyển về tài khoản của bạn sau khi được duyệt.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Đóng',
              style: TextStyle(
                color: widget.themeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBalance(double amount) {
    final f = amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return '$f đ';
  }

  String _formatCurrency(double amount) {
    final f = amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return '$f đ';
  }

  @override
  Widget build(BuildContext context) {
    final balance = _walletInfo?.balance ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // App Bar
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFDDDDDD), width: 1),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 56,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFF333333),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'Rút Tiền',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.themeColor,
                            widget.themeColor.withOpacity(0.75),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: widget.themeColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white70,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Ví SnakeAidPay',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Số dư khả dụng',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (_isLoadingWallet)
                            const SizedBox(
                              height: 40,
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                            )
                          else
                            Text(
                              _formatBalance(balance),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Amount
                    const Text(
                      'Số tiền rút',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.themeColor,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        suffixText: 'đ',
                        suffixStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF888888),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFDDDDDD),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.themeColor,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        final v = double.tryParse(
                          (value ?? '').replaceAll('.', '').replaceAll(',', ''),
                        );
                        if (v == null || v <= 0) return 'Vui lòng nhập số tiền';
                        if (v < 50000) return 'Số tiền tối thiểu là 50.000đ';
                        if (v > 5000000)
                          return 'Số tiền tối đa là 5.000.000đ/lần';
                        if (v > balance) return 'Số dư không đủ';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    // Quick amounts
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._quickAmounts.map(
                          (a) => _QuickAmountButton(
                            amount: a,
                            color: widget.themeColor,
                            onTap: () => _amountController.text = a.toString(),
                          ),
                        ),
                        _QuickAmountButton(
                          amount: balance.toInt(),
                          label: 'Tất cả',
                          color: widget.themeColor,
                          onTap: () => _amountController.text = balance
                              .toInt()
                              .toString(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Bank selection
                    const Text(
                      'Ngân hàng nhận',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_isLoadingBanks)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            color: widget.themeColor,
                          ),
                        ),
                      )
                    else
                      FormField<BankInfo>(
                        validator: (_) => _selectedBank == null
                            ? 'Vui lòng chọn ngân hàng'
                            : null,
                        builder: (field) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: _showBankPicker,
                              child: Container(
                                height: 56,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: field.hasError
                                        ? Colors.red
                                        : const Color(0xFFDDDDDD),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    if (_selectedBank != null) ...[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: CachedNetworkImage(
                                          imageUrl: _selectedBank!.logoUrl,
                                          width: 36,
                                          height: 36,
                                          fit: BoxFit.contain,
                                          placeholder: (_, __) => Container(
                                            width: 36,
                                            height: 36,
                                            color: const Color(0xFFF0F0F0),
                                          ),
                                          errorWidget: (_, __, ___) =>
                                              const Icon(
                                                Icons.account_balance,
                                                size: 24,
                                                color: Color(0xFF888888),
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _selectedBank!.shortName.isNotEmpty
                                              ? _selectedBank!.shortName
                                              : _selectedBank!.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF333333),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ] else ...[
                                      const Icon(
                                        Icons.account_balance,
                                        size: 22,
                                        color: Color(0xFF888888),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          'Chọn ngân hàng',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xFF999999),
                                          ),
                                        ),
                                      ),
                                    ],
                                    const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Color(0xFF888888),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (field.hasError)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 6,
                                  left: 12,
                                ),
                                child: Text(
                                  field.errorText!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Account number
                    TextFormField(
                      controller: _accountNumberController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Số tài khoản',
                        hintText: '0123456789',
                        prefixIcon: const Icon(Icons.credit_card),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFDDDDDD),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: widget.themeColor),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Vui lòng nhập số tài khoản';
                        if (v.trim().length < 8)
                          return 'Số tài khoản tối thiểu 8 chữ số';
                        if (v.trim().length > 20)
                          return 'Số tài khoản tối đa 20 chữ số';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Account name
                    TextFormField(
                      controller: _accountNameController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: 'Tên chủ tài khoản',
                        hintText: 'NGUYEN VAN A',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFDDDDDD),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: widget.themeColor),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Vui lòng nhập tên chủ tài khoản';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFFF9800),
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '• Số tiền tối thiểu: 50.000đ\n'
                              '• Số tiền tối đa: 5.000.000đ/lần\n'
                              '• Hạn mức rút trong ngày: 10.000.000đ\n'
                              '• Hãy kiểm tra kỹ thông tin trước khi xác nhận',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF333333),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_activeWithdrawalCount >= 3)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEF9A9A)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.block_rounded,
                              color: Color(0xFFDC3545),
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Bạn đang có 3 yêu cầu rút tiền chưa hoàn tất. Vui lòng đợi admin xử lý trước khi tạo yêu cầu mới.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFC62828),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Bottom CTA
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFDDDDDD), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (_isSubmitting ||
                        _isCheckingActive ||
                        _activeWithdrawalCount >= 3)
                    ? null
                    : _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _activeWithdrawalCount >= 3
                      ? const Color(0xFFDC3545)
                      : widget.themeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: _activeWithdrawalCount >= 3
                      ? const Color(0xFFDC3545).withOpacity(0.6)
                      : widget.themeColor.withOpacity(0.6),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : _activeWithdrawalCount >= 3
                    ? const Text(
                        'Có 3 Đơn Rút Tiền Chưa Hoàn Tất',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const Text(
                        'Xác Nhận Rút Tiền',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

// ── Helpers ──────────────────────────────────────────────────────────────────

class _QuickAmountButton extends StatelessWidget {
  final int amount;
  final String? label;
  final VoidCallback onTap;
  final Color color;

  const _QuickAmountButton({
    required this.amount,
    this.label,
    required this.onTap,
    this.color = const Color(0xFF228B22),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label ?? _fmt(amount),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }

  String _fmt(int v) {
    if (v >= 1000000) {
      return '${(v / 1000000).toStringAsFixed(v % 1000000 == 0 ? 0 : 1)}tr';
    }
    return '${(v / 1000).toInt()}k';
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _ConfirmRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF888888)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            color: highlight
                ? const Color(0xFF228B22)
                : const Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}

// ── Bank Picker Bottom Sheet ──────────────────────────────────────────────────

class _BankPickerSheet extends StatefulWidget {
  final List<BankInfo> banks;
  const _BankPickerSheet({required this.banks});

  @override
  State<_BankPickerSheet> createState() => _BankPickerSheetState();
}

class _BankPickerSheetState extends State<_BankPickerSheet> {
  final _searchController = TextEditingController();
  List<BankInfo> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.banks;
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = widget.banks.where((b) {
        return b.shortName.toLowerCase().contains(q) ||
            b.name.toLowerCase().contains(q) ||
            (b.code?.toLowerCase().contains(q) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chọn ngân hàng',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm ngân hàng...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF888888),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            // List
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'Không tìm thấy ngân hàng',
                        style: TextStyle(color: Color(0xFF888888)),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 72),
                      itemBuilder: (_, i) {
                        final bank = _filtered[i];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: bank.logoUrl,
                              width: 44,
                              height: 44,
                              fit: BoxFit.contain,
                              placeholder: (_, __) => Container(
                                width: 44,
                                height: 44,
                                color: const Color(0xFFF0F0F0),
                                child: const Icon(
                                  Icons.account_balance,
                                  size: 22,
                                  color: Color(0xFFCCCCCC),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F0F0),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.account_balance,
                                  size: 22,
                                  color: Color(0xFF888888),
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            bank.shortName.isNotEmpty
                                ? bank.shortName
                                : bank.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Color(0xFF333333),
                            ),
                          ),
                          subtitle: Text(
                            bank.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF888888),
                            ),
                          ),
                          onTap: () => Navigator.of(context).pop(bank),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
