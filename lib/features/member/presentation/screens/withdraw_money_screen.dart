import 'package:flutter/material.dart';

/// Withdraw Money Screen - Withdraw funds from SnakeAidPay wallet
class WithdrawMoneyScreen extends StatefulWidget {
  const WithdrawMoneyScreen({super.key});

  @override
  State<WithdrawMoneyScreen> createState() => _WithdrawMoneyScreenState();
}

class _WithdrawMoneyScreenState extends State<WithdrawMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();
  String _selectedBank = 'Vietcombank';

  final List<String> _banks = [
    'Vietcombank',
    'Techcombank',
    'BIDV',
    'VietinBank',
    'Agribank',
    'MB Bank',
    'ACB',
    'Sacombank',
    'VPBank',
    'TPBank',
  ];

  final List<int> _quickAmounts = [100000, 500000, 1000000, 2000000];

  @override
  void dispose() {
    _amountController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top App Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFFDDDDDD),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 56,
                child: Stack(
                  children: [
                    // Back button
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
                    // Title - centered
                    Center(
                      child: const Text(
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Balance Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF228B22), Color(0xFF1a6b1a)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF228B22).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Số dư khả dụng',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '1.250.000 đ',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Amount Input
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
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF228B22),
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
                            borderSide: const BorderSide(color: Color(0xFFDDDDDD), width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF228B22), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập số tiền';
                          }
                          final amount = int.tryParse(value.replaceAll(',', ''));
                          if (amount == null || amount < 50000) {
                            return 'Số tiền tối thiểu là 50.000đ';
                          }
                          if (amount > 1250000) {
                            return 'Số tiền vượt quá số dư';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Quick Amount Buttons
                      const Text(
                        'Chọn nhanh',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF888888),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._quickAmounts.map((amount) {
                            return _QuickAmountButton(
                              amount: amount,
                              onTap: () {
                                _amountController.text = amount.toString();
                              },
                            );
                          }).toList(),
                          _QuickAmountButton(
                            amount: 1250000,
                            label: 'Tất cả',
                            onTap: () {
                              _amountController.text = '1250000';
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Bank Information
                      const Text(
                        'Thông tin tài khoản nhận',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Bank Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedBank,
                        decoration: InputDecoration(
                          labelText: 'Ngân hàng',
                          prefixIcon: const Icon(Icons.account_balance),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF228B22)),
                          ),
                        ),
                        items: _banks.map((bank) {
                          return DropdownMenuItem(
                            value: bank,
                            child: Text(bank),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedBank = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // Account Number
                      TextFormField(
                        controller: _accountNumberController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Số tài khoản',
                          hintText: '0123456789',
                          prefixIcon: const Icon(Icons.credit_card),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF228B22)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập số tài khoản';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Account Name
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
                            borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF228B22)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên chủ tài khoản';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // Info Note
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFFF9800),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Lưu ý:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '• Số tiền tối thiểu: 50.000đ\n• Phí rút tiền: 5.000đ/giao dịch\n• Thời gian xử lý: 1-3 ngày làm việc\n• Kiểm tra kỹ thông tin tài khoản trước khi xác nhận',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF333333),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // Bottom Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: const Color(0xFFDDDDDD),
              width: 1,
            ),
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
                onPressed: _processWithdraw,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF228B22),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
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

  void _processWithdraw() {
    if (_formKey.currentState!.validate()) {
      final amount = int.parse(_amountController.text.replaceAll(',', ''));
      
      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
              const SizedBox(height: 8),
              _ConfirmRow(label: 'Phí', value: '5.000đ'),
              const Divider(height: 24),
              _ConfirmRow(
                label: 'Tổng rút',
                value: _formatCurrency(amount + 5000),
                highlight: true,
              ),
              const SizedBox(height: 16),
              _ConfirmRow(label: 'Ngân hàng', value: _selectedBank),
              const SizedBox(height: 8),
              _ConfirmRow(label: 'Số TK', value: _accountNumberController.text),
              const SizedBox(height: 8),
              _ConfirmRow(label: 'Tên TK', value: _accountNameController.text),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Hủy',
                style: TextStyle(color: Color(0xFF888888)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSuccessDialog(amount);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF228B22),
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
  }

  void _showSuccessDialog(int amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF228B22).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF228B22),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Yêu cầu rút tiền thành công',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Số tiền: ${_formatCurrency(amount)}',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF228B22),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tiền sẽ được chuyển vào tài khoản trong 1-3 ngày làm việc',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF888888),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Đóng',
              style: TextStyle(
                color: Color(0xFF228B22),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
  }
}

class _QuickAmountButton extends StatelessWidget {
  final int amount;
  final String? label;
  final VoidCallback onTap;

  const _QuickAmountButton({
    required this.amount,
    this.label,
    required this.onTap,
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
          border: Border.all(color: const Color(0xFF228B22)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label ?? _formatAmount(amount),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF228B22),
          ),
        ),
      ),
    );
  }

  String _formatAmount(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(amount % 1000000 == 0 ? 0 : 1)}tr';
    } else {
      return '${(amount / 1000).toInt()}k';
    }
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
          style: TextStyle(
            fontSize: 14,
            color: highlight ? const Color(0xFF333333) : const Color(0xFF888888),
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: highlight ? const Color(0xFF228B22) : const Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}
