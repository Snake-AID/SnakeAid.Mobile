import 'package:flutter/material.dart';

/// Payment History Screen - Shows all payment transactions
class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  int _selectedTabIndex = 0;

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
                        'Lịch Sử Thanh Toán',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    // Filter button
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.tune,
                          color: Color(0xFF333333),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Bộ lọc - Đang phát triển')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Summary Stats Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatColumn(
                            value: '2,450,000 VNĐ',
                            label: 'Tổng chi tiêu',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: const Color(0xFFDDDDDD),
                        ),
                        Expanded(
                          child: _StatColumn(
                            value: '450,000 VNĐ',
                            label: 'Tháng này',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: const Color(0xFFDDDDDD),
                        ),
                        Expanded(
                          child: _StatColumn(
                            value: '0',
                            label: 'Chờ thanh toán',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Tab Navigation
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFFDDDDDD),
                        width: 1,
                      ),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _TabItem(
                          label: 'Tất cả',
                          isSelected: _selectedTabIndex == 0,
                          onTap: () {
                            setState(() {
                              _selectedTabIndex = 0;
                            });
                          },
                        ),
                        const SizedBox(width: 24),
                        _TabItem(
                          label: 'Cứu hộ',
                          isSelected: _selectedTabIndex == 1,
                          onTap: () {
                            setState(() {
                              _selectedTabIndex = 1;
                            });
                          },
                        ),
                        const SizedBox(width: 24),
                        _TabItem(
                          label: 'Tư vấn chuyên gia',
                          isSelected: _selectedTabIndex == 2,
                          onTap: () {
                            setState(() {
                              _selectedTabIndex = 2;
                            });
                          },
                        ),
                        const SizedBox(width: 24),
                        _TabItem(
                          label: 'Khác',
                          isSelected: _selectedTabIndex == 3,
                          onTap: () {
                            setState(() {
                              _selectedTabIndex = 3;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Transaction List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _TransactionCard(
                        icon: Icons.sos,
                        title: 'Cứu Hộ Rắn',
                        provider: 'Đội cứu hộ ABC',
                        amount: '200,000 VNĐ',
                        date: '15 Thg 9, 2025',
                        status: 'Đã thanh toán',
                        onViewInvoice: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Xem hóa đơn - Đang phát triển')),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _TransactionCard(
                        icon: Icons.forum,
                        title: 'Tư vấn chuyên gia',
                        provider: 'BS. Nguyễn Văn An',
                        amount: '50,000 VNĐ',
                        date: '12 Thg 9, 2025',
                        status: 'Đã thanh toán',
                        onViewInvoice: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Xem hóa đơn - Đang phát triển')),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _TransactionCard(
                        icon: Icons.sos,
                        title: 'Cứu Hộ Rắn',
                        provider: 'Đội cứu hộ XYZ',
                        amount: '200,000 VNĐ',
                        date: '28 Thg 8, 2025',
                        status: 'Đã thanh toán',
                        onViewInvoice: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Xem hóa đơn - Đang phát triển')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;

  const _StatColumn({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF888888),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 13, top: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF228B22) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? const Color(0xFF228B22) : const Color(0xFF888888),
          ),
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String provider;
  final String amount;
  final String date;
  final String status;
  final VoidCallback onViewInvoice;

  const _TransactionCard({
    required this.icon,
    required this.title,
    required this.provider,
    required this.amount,
    required this.date,
    required this.status,
    required this.onViewInvoice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF228B22).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF228B22),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          amount,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF228B22),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF888888),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF228B22).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF228B22),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: const Color(0xFFDDDDDD),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: onViewInvoice,
            child: const Text(
              'Xem hóa đơn',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF007AFF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty State Widget - Use when no payment history available
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
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
              'Lịch sử thanh toán sẽ hiển thị tại đây.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
