import 'package:flutter/material.dart';

class MemberConsultationDetailScreen extends StatelessWidget {
  final String expertName;
  final String expertSpecialty;
  final String serviceType;
  final DateTime scheduledTime;
  final int feeCost;
  final String statusLabel;
  final Color statusColor;
  final double? rating;
  final String? problemDescription;

  const MemberConsultationDetailScreen({
    super.key,
    required this.expertName,
    required this.expertSpecialty,
    required this.serviceType,
    required this.scheduledTime,
    required this.feeCost,
    required this.statusLabel,
    required this.statusColor,
    this.rating,
    this.problemDescription,
  });

  static const Color _bg = Color(0xFFF8F6F8);
  static const Color _primary = Color(0xFF228B22);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Chi Tiết Tư Vấn',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        children: [
          _SectionCard(
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _primary.withOpacity(0.1),
                  ),
                  child: const Icon(Icons.person, color: _primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expertName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        expertSpecialty.isEmpty
                            ? 'Chuyên gia tư vấn'
                            : expertSpecialty,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            label: 'Thông Tin Tư Vấn',
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.medical_services_outlined,
                  label: 'Loại tư vấn',
                  value: serviceType,
                ),
                const _Divider(),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Thời gian',
                  value:
                      '${_pad(scheduledTime.day)}/${_pad(scheduledTime.month)}/${scheduledTime.year} lúc ${_pad(scheduledTime.hour)}:${_pad(scheduledTime.minute)}',
                ),
                const _Divider(),
                _DetailRow(
                  icon: Icons.payments_outlined,
                  label: 'Chi phí',
                  value: _formatFee(feeCost),
                  valueBold: true,
                  valueColor: _primary,
                ),
              ],
            ),
          ),
          if (problemDescription != null &&
              problemDescription!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _SectionCard(
              label: 'Mô Tả Vấn Đề',
              child: Text(
                problemDescription!.trim(),
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF374151),
                ),
              ),
            ),
          ],
          if (rating != null) ...[
            const SizedBox(height: 12),
            _SectionCard(
              label: 'Đánh Giá Của Bạn',
              child: Row(
                children: [
                  const Icon(Icons.star, size: 18, color: Color(0xFFFBBF24)),
                  const SizedBox(width: 8),
                  Text(
                    '${rating!.toStringAsFixed(1)}/5',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _pad(int value) => value.toString().padLeft(2, '0');

  String _formatFee(int fee) {
    final formatted = fee
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return '$formatted VNĐ';
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  final String? label;

  const _SectionCard({required this.child, this.label});

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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 10),
          ],
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool valueBold;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? const Color(0xFF374151),
              fontWeight: valueBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
    );
  }
}
