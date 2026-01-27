import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_dialog.dart';

class RescuerArrivedScreen extends StatefulWidget {
  final String rescuerName;
  final String rescuerPhone;
  final double rescuerRating;

  const RescuerArrivedScreen({
    Key? key,
    required this.rescuerName,
    required this.rescuerPhone,
    required this.rescuerRating,
  }) : super(key: key);

  @override
  State<RescuerArrivedScreen> createState() => _RescuerArrivedScreenState();
}

class _RescuerArrivedScreenState extends State<RescuerArrivedScreen> {
  final Set<String> _completedChecklist = {};

  final List<Map<String, String>> _checklistItems = [
    {
      'id': 'snake_info',
      'title': 'Thông tin loài rắn',
      'description': 'Đã chia sẻ loài rắn, độc tính, ảnh chụp',
    },
    {
      'id': 'symptoms',
      'title': 'Triệu chứng hiện tại',
      'description': 'Đã báo cáo các triệu chứng đang gặp',
    },
    {
      'id': 'first_aid',
      'title': 'Sơ cứu đã thực hiện',
      'description': 'Đã thông báo các bước sơ cứu đã làm',
    },
    {
      'id': 'bite_time',
      'title': 'Thời gian bị cắn',
      'description': 'Đã xác nhận thời điểm bị rắn cắn',
    },
  ];

  void _confirmArrival() {
    if (_completedChecklist.length < _checklistItems.length) {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orange,
          title: 'Chưa hoàn thành checklist',
          content: const Text(
            'Vui lòng hoàn thành tất cả các mục trong danh sách '
            'trước khi xác nhận cứu hộ viên đã đến.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            DialogAction(
              label: 'Đóng',
              onPressed: () => Navigator.pop(context),
              isPrimary: true,
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        icon: Icons.check_circle,
        iconColor: const Color(0xFF228B22),
        title: 'Xác nhận cứu hộ viên đã đến?',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bạn đã gặp và xác minh danh tính của cứu hộ viên?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sau khi xác nhận, bạn sẽ được chuyển đến bệnh viện '
                      'và màn hình thanh toán.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          DialogAction(
            label: 'Chưa',
            onPressed: () => Navigator.pop(context),
            isPrimary: false,
          ),
          DialogAction(
            label: 'Xác nhận',
            onPressed: () {
              Navigator.pop(context);
              _proceedToPayment();
            },
            isPrimary: true,
            icon: Icons.check,
          ),
        ],
      ),
    );
  }

  void _proceedToPayment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chuyển đến màn hình thanh toán...'),
        backgroundColor: Color(0xFF228B22),
      ),
    );

    // TODO: Navigate to PaymentScreen
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => const PaymentScreen()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF228B22),
        foregroundColor: Colors.white,
        title: const Text(
          'Cứu hộ viên đã đến',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Success banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF228B22), Color(0xFF1a6b1a)],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF228B22),
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cứu hộ viên đã có mặt',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vui lòng xác minh thông tin và hoàn thành checklist',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Rescuer verification card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin cứu hộ viên',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFF228B22),
                          borderRadius: BorderRadius.circular(35),
                        ),
                        child: Center(
                          child: Text(
                            widget.rescuerName.substring(0, 2).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.rescuerName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  widget.rescuerRating.toString(),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF228B22).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Đã xác minh',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF228B22),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Call button
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF228B22).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đang gọi ${widget.rescuerPhone}...'),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.phone,
                            color: Color(0xFF228B22),
                          ),
                          iconSize: 28,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Transfer checklist
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Checklist chuyển giao thông tin',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Đánh dấu các mục đã hoàn thành',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Checklist items
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _checklistItems.length,
              itemBuilder: (context, index) {
                final item = _checklistItems[index];
                final isCompleted = _completedChecklist.contains(item['id']);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: isCompleted
                        ? const Color(0xFF228B22).withOpacity(0.05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (isCompleted) {
                            _completedChecklist.remove(item['id']);
                          } else {
                            _completedChecklist.add(item['id']!);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCompleted
                                ? const Color(0xFF228B22)
                                : Colors.grey.shade300,
                            width: isCompleted ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? const Color(0xFF228B22)
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isCompleted
                                      ? const Color(0xFF228B22)
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 18,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title']!,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isCompleted
                                          ? Colors.black87
                                          : Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['description']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Progress indicator
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF228B22).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF228B22).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _completedChecklist.length == _checklistItems.length
                        ? Icons.check_circle
                        : Icons.pending,
                    color: _completedChecklist.length == _checklistItems.length
                        ? const Color(0xFF228B22)
                        : Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_completedChecklist.length}/${_checklistItems.length} mục đã hoàn thành',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Confirm button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _confirmArrival,
                  icon: const Icon(Icons.check_circle, size: 22),
                  label: const Text(
                    'Xác nhận đã gặp cứu hộ viên',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _completedChecklist.length == _checklistItems.length
                        ? const Color(0xFF228B22)
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
