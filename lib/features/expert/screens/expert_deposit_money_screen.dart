import 'package:flutter/material.dart';

/// Expert deposit screen.
///
/// This screen is scoped to expert module to avoid cross-feature UI dependency
/// with member screens.
class ExpertDepositMoneyScreen extends StatefulWidget {
  const ExpertDepositMoneyScreen({super.key});

  @override
  State<ExpertDepositMoneyScreen> createState() =>
      _ExpertDepositMoneyScreenState();
}

class _ExpertDepositMoneyScreenState extends State<ExpertDepositMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final List<int> _quickAmounts = [50000, 100000, 200000, 500000, 1000000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6F8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Nạp tiền ví chuyên gia',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C47C2), Color(0xFF5535A5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ví SnakeAidPay',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Nạp tiền để sẵn sàng thanh toán dịch vụ nội bộ',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Số tiền nạp',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Nhập số tiền (1.000 - 10.000.000)',
                  suffixText: 'VND',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickAmounts
                    .map(
                      (amount) => ActionChip(
                        label: Text(_formatMoney(amount)),
                        onPressed: () =>
                            _amountController.text = amount.toString(),
                      ),
                    )
                    .toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _onDepositPressed,
                  icon: const Icon(Icons.add_card),
                  label: const Text('Tiếp tục nạp tiền'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C47C2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onDepositPressed() {
    final value = int.tryParse(_amountController.text.trim()) ?? 0;
    if (value < 1000 || value > 10000000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Số tiền nạp phải từ 1.000 đến 10.000.000 VND'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Luồng nạp tiền expert đã sẵn sàng để nối API.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatMoney(int value) {
    final formatted = value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$formatted đ';
  }
}
