import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/snake_catching_request.dart';
import 'package:intl/intl.dart';

/// Success screen after submitting a snake catching request
class SnakeCatchingSuccessScreen extends StatelessWidget {
  final SnakeCatchingRequestData requestData;

  const SnakeCatchingSuccessScreen({
    super.key,
    required this.requestData,
  });

  String _formatCurrency(double value) {
    final fmt = NumberFormat('#,###', 'vi_VN');
    return '${fmt.format(value.round())}đ';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8F6),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeroHeader(context)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildPaymentCallout(context),
                  const SizedBox(height: 16),
                  _buildStepsCard(),
                  const SizedBox(height: 16),
                  _buildSummaryCard(),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomActions(context),
      ),
    );
  }

  // ─── Hero header ──────────────────────────────────────────────────────────
  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(
            children: [
              // Animated icon ring
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                ),
                child: const Icon(Icons.check_circle_rounded, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'Yêu Cầu Đã Được Gửi!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mã đơn: #${requestData.id.substring(0, 8).toUpperCase()}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.75),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Payment call-to-action card ─────────────────────────────────────────
  Widget _buildPaymentCallout(BuildContext context) {
    final hasPrice = requestData.estimatedPrice != null && requestData.estimatedPrice! > 0;
    final hasDistance = requestData.distanceKm != null && requestData.distanceKm! > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top accent bar
          Container(
            height: 4,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                colors: [Color(0xFF228B22), Color(0xFF4CAF50)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.payments_rounded,
                            color: Color(0xFF228B22), size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phí Di Chuyển',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Xác nhận đơn để ưu tiên phân công cứu hộ viên',
                              style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (hasPrice || hasDistance) ...[
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (hasDistance) ...[
                          Expanded(
                            child: _buildMetricTile(
                              icon: Icons.route_rounded,
                              iconColor: const Color(0xFF1976D2),
                              bgColor: const Color(0xFFE3F2FD),
                              label: 'Khoảng cách',
                              value: '${requestData.distanceKm!.toStringAsFixed(1)} km',
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (hasPrice)
                          Expanded(
                            child: _buildMetricTile(
                              icon: Icons.account_balance_wallet_rounded,
                              iconColor: const Color(0xFF388E3C),
                              bgColor: const Color(0xFFE8F5E9),
                              label: 'Phí di chuyển',
                              value: _formatCurrency(requestData.estimatedPrice!),
                              valueColor: const Color(0xFF1B5E20),
                              bold: true,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '* Phí thực tế sẽ được xác nhận sau khi hoàn thành nhiệm vụ',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/activity-detail/${requestData.id}'),
                      icon: const Icon(Icons.payments_rounded, size: 20),
                      label: const Text(
                        'Thanh Toán Phí Di Chuyển',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
    Color? valueColor,
    bool bold = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                    color: valueColor ?? const Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Process steps card ──────────────────────────────────────────────────
  Widget _buildStepsCard() {
    final steps = [
      _StepInfo(
        icon: Icons.send_rounded,
        label: 'Đã gửi yêu cầu',
        sub: 'Hệ thống đã tiếp nhận',
        done: true,
        active: false,
      ),
      _StepInfo(
        icon: Icons.payments_rounded,
        label: 'Thanh toán phí di chuyển',
        sub: 'Xác nhận ưu tiên phân công',
        done: false,
        active: true,
      ),
      _StepInfo(
        icon: Icons.support_agent_rounded,
        label: 'Chờ điều phối xác nhận',
        sub: 'Kiểm tra & liên hệ khách',
        done: false,
        active: false,
      ),
      _StepInfo(
        icon: Icons.person_pin_circle_rounded,
        label: 'Phân công cứu hộ viên',
        sub: 'Cứu hộ viên di chuyển đến',
        done: false,
        active: false,
      ),
      _StepInfo(
        icon: Icons.task_alt_rounded,
        label: 'Hoàn thành dịch vụ',
        sub: 'Thanh toán phần còn lại',
        done: false,
        active: false,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.linear_scale_rounded, color: Color(0xFF228B22), size: 20),
              SizedBox(width: 8),
              Text(
                'Quy trình xử lý',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final isLast = i == steps.length - 1;
            return _buildStepRow(step, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildStepRow(_StepInfo step, bool isLast) {
    final Color textColor = step.done || step.active
        ? const Color(0xFF212121)
        : const Color(0xFF9E9E9E);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: step.done
                    ? const Color(0xFF228B22)
                    : step.active
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFF5F5F5),
                border: step.active
                    ? Border.all(color: const Color(0xFF228B22), width: 2)
                    : null,
              ),
              child: Icon(
                step.done ? Icons.check_rounded : step.icon,
                size: 16,
                color: step.done
                    ? Colors.white
                    : step.active
                        ? const Color(0xFF228B22)
                        : const Color(0xFFBDBDBD),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: step.done
                    ? const Color(0xFF228B22).withValues(alpha: 0.3)
                    : const Color(0xFFE0E0E0),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: step.active ? FontWeight.bold : FontWeight.w500,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  step.sub,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                if (step.active)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF228B22).withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      'Bước hiện tại',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF228B22),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Compact summary card ─────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F8E9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: Color(0xFF2E7D32), size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Chi Tiết Yêu Cầu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF228B22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(requestData.status),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time
                _buildInfoRow(
                  Icons.access_time,
                  'Thời gian gửi',
                  DateFormat('dd/MM/yyyy, HH:mm').format(requestData.requestDate.toLocal()),
                ),
                
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                
                // Location
                _buildInfoRow(
                  Icons.location_on,
                  'Vị trí',
                  requestData.address,
                ),
                
                // Preferred Time
                if (requestData.preferredTime != null) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.schedule,
                    'Thời gian mong muốn',
                    DateFormat('HH:mm').format(requestData.preferredTime!.toLocal()),
                  ),
                ],
                
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                
                // Snake Species
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: Color(0xFFFF9800),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loài rắn phát hiện',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${requestData.details.length} loài',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...requestData.details.map((detail) => _buildSpeciesChip(detail)),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Additional Details
                if (requestData.additionalDetails != null && requestData.additionalDetails!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          size: 20,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ghi chú địa chỉ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              requestData.additionalDetails!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF333333),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                
                // Notes (Thông tin bổ sung)
                if (requestData.notes != null && requestData.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thông tin bổ sung',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              requestData.notes!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF333333),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                
                // Priority
                if (requestData.priority != 'Normal') ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.priority_high,
                    'Mức độ ưu tiên',
                    requestData.priority,
                    valueColor: _getPriorityColor(requestData.priority),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF228B22).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF228B22),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? const Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpeciesChip(SnakeSpeciesDetail detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.snakeSpeciesName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail.snakeSpeciesScientificName,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF228B22).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'x${detail.quantity}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF228B22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/activity-detail/${requestData.id}'),
                icon: const Icon(Icons.payments_rounded, size: 20),
                label: const Text(
                  'Thanh Toán Phí Di Chuyển',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF228B22),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.go('/member-home'),
                icon: const Icon(Icons.home_outlined, size: 20),
                label: const Text('Về Trang Chủ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF228B22),
                  side: const BorderSide(color: Color(0xFF228B22), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ Xử Lý';
      case 'confirmed':
        return 'Đã Xác Nhận';
      case 'assigned':
        return 'Đã Phân Công';
      case 'finished':
        return 'Đã Bắt Xong';
      case 'completed':
        return 'Hoàn Thành';
      case 'dispute':
        return 'Đang Tranh Chấp';
      case 'cancelled':
        return 'Đã Hủy';
      case 'expired':
        return 'Hết Hạn';
      default:
        return status;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFDC3545);
      case 'medium':
        return const Color(0xFFFFA500);
      default:
        return const Color(0xFF228B22);
    }
  }
}

class _StepInfo {
  final IconData icon;
  final String label;
  final String sub;
  final bool done;
  final bool active;

  const _StepInfo({
    required this.icon,
    required this.label,
    required this.sub,
    required this.done,
    required this.active,
  });
}
