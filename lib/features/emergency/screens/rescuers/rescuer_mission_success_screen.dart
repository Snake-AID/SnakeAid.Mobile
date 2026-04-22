import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/mission_detail_provider.dart';

class RescuerMissionSuccessScreen extends ConsumerStatefulWidget {
  const RescuerMissionSuccessScreen({super.key});

  @override
  ConsumerState<RescuerMissionSuccessScreen> createState() =>
      _RescuerMissionSuccessScreenState();
}

class _RescuerMissionSuccessScreenState
    extends ConsumerState<RescuerMissionSuccessScreen> {
  String _formatCurrency(double? value) {
    if (value == null) return '-';
    final formatted = value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return '$formattedđ';
  }

  String _formatVietnamTime(DateTime? value) {
    if (value == null) return '-';

    // Backend timestamps are UTC; display them in Vietnam time (UTC+7).
    final vietnamTime = value.toUtc().add(const Duration(hours: 7));
    final day = vietnamTime.day.toString().padLeft(2, '0');
    final month = vietnamTime.month.toString().padLeft(2, '0');
    final year = vietnamTime.year;
    final hour = vietnamTime.hour.toString().padLeft(2, '0');
    final minute = vietnamTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year - $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final missionState = ref.watch(missionDetailProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      body: Column(
        children: [
          // Header
          SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7F5).withOpacity(0.95),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF1C100D)),
                    onPressed: () => context.go('/rescuer-home'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Expanded(
                    child: Text(
                      'Cảm Ơn Bạn!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C100D),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Icon(
                    Icons.emoji_events,
                    color: Color(0xFFFFC107),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Hero Section
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.military_tech,
                            size: 64,
                            color: Color(0xFFFFC107),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Hoàn Thành Nhiệm Vụ!',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C100D),
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Nhiệm vụ hoàn thành. Cảm ơn bạn đã đóng góp cho cộng đồng!',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF666666),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Today's Stats Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thống Kê Hôm Nay',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C100D),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            // Use mission detail values rather than mock data
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    missionState
                                            .mission
                                            ?.formattedElapsedTime ??
                                        '-',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1C100D),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Thời gian',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[300],
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    _formatCurrency(
                                      missionState.mission?.actualCost,
                                    ),
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          missionState.mission?.actualCost !=
                                              null
                                          ? const Color(0xFF28A745)
                                          : Colors.grey[600],
                                    ),
                                  ),
                                   const SizedBox(height: 4),
                                  Text(
                                    'Khách hàng thanh toán',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Mission Details Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chi Tiết Nhiệm Vụ Này',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C100D),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          'Mã nhiệm vụ:',
                          missionState.mission?.formattedMissionId ?? '-',
                          true,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Thời gian:',
                          _formatVietnamTime(missionState.mission?.completedAt),
                          false,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Thời lượng:',
                          missionState.mission?.formattedElapsedTime ?? '-',
                          false,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3CD),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFFFD54F).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFC107),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'ĐANG XỬ LÝ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF856404),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const Spacer(),
                              const Expanded(
                                child: Text(
                                  'Chờ thanh toán từ bệnh nhân',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF856404),
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Support Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.help_outline,
                              color: Colors.grey[600],
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Gặp vấn đề với nhiệm vụ này?',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1C100D),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF666666),
                                  side: BorderSide(
                                    color: Colors.grey.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Báo Cáo Sự Cố',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF666666),
                                  side: BorderSide(
                                    color: Colors.grey.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Liên Hệ Hỗ Trợ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7F5).withOpacity(0.95),
              border: Border(
                top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => context.go('/rescuer-home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8800),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'VỀ TRANG CHỦ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    bool isBold, {
    bool isHighlighted = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold || isHighlighted
                ? FontWeight.bold
                : FontWeight.normal,
            color: isHighlighted
                ? const Color(0xFFFF8800)
                : const Color(0xFF1C100D),
          ),
        ),
      ],
    );
  }

}
