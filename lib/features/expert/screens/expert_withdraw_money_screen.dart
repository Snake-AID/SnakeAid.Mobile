import 'package:flutter/material.dart';

/// Expert withdraw screen.
///
/// This screen is scoped to expert module to avoid cross-feature UI dependency
/// with member screens.
class ExpertWithdrawMoneyScreen extends StatefulWidget {
  const ExpertWithdrawMoneyScreen({super.key});

  @override
  State<ExpertWithdrawMoneyScreen> createState() =>
      _ExpertWithdrawMoneyScreenState();
}

class _ExpertWithdrawMoneyScreenState extends State<ExpertWithdrawMoneyScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();

  String _selectedBank = 'Vietcombank';
  final List<String> _banks = const [
    'Vietcombank',
    'Techcombank',
    'BIDV',
    'VietinBank',
    'MB Bank',
  ];

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
      backgroundColor: const Color(0xFFF8F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6F8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Rút tiền ví chuyên gia',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Số tiền rút',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Tối thiểu 50.000',
                    suffixText: 'VND',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    final amount = int.tryParse((value ?? '').trim()) ?? 0;
                    if (amount < 50000) {
                      return 'Số tiền tối thiểu là 50.000 VND';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedBank,
                  decoration: InputDecoration(
                    labelText: 'Ngân hàng',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _banks
                      .map(
                        (bank) =>
                            DropdownMenuItem(value: bank, child: Text(bank)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedBank = value);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _accountNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Số tài khoản',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Vui lòng nhập số tài khoản';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _accountNameController,
                  decoration: InputDecoration(
                    labelText: 'Tên chủ tài khoản',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Vui lòng nhập tên chủ tài khoản';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EBFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Lưu ý: Phí rút tiền có thể áp dụng theo chính sách hệ thống.',
                    style: TextStyle(color: Color(0xFF5A3DB0), fontSize: 12),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _onWithdrawPressed,
                    icon: const Icon(Icons.payments_outlined),
                    label: const Text('Xác nhận rút tiền'),
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
      ),
    );
  }

  void _onWithdrawPressed() {
    if (_formKey.currentState?.validate() != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Luồng rút tiền expert đã sẵn sàng để nối API.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
