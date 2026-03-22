import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../emergency/models/detailed_incident_response.dart';
import '../../emergency/providers/detailed_incident_provider.dart';
import '../../emergency/repository/incident_repository.dart';
import '../../snake_catching/repository/wallet_repository.dart';

enum MemberPaymentMethod { payos, wallet }

class MemberIncidentFinishedDetailScreen extends ConsumerStatefulWidget {
  final String incidentId;

  const MemberIncidentFinishedDetailScreen({
    super.key,
    required this.incidentId,
  });

  @override
  ConsumerState<MemberIncidentFinishedDetailScreen> createState() =>
      _MemberIncidentFinishedDetailScreenState();
}

class _MemberIncidentFinishedDetailScreenState
    extends ConsumerState<MemberIncidentFinishedDetailScreen> {
  bool _isProcessingPayment = false;
  bool _hasPaid = false;
  bool _isLoadingWallet = false;
  WalletInfo? _walletInfo;
  MemberPaymentMethod _selectedMethod = MemberPaymentMethod.payos;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.incidentId.isNotEmpty) {
        ref
            .read(detailedIncidentProvider.notifier)
            .loadDetailedIncident(widget.incidentId);
      }
      _loadWallet();
    });
  }

  Future<void> _loadWallet() async {
    setState(() => _isLoadingWallet = true);
    try {
      final wallet = await ref.read(walletRepositoryProvider).getWalletInfo();
      if (mounted) {
        setState(() => _walletInfo = wallet);
      }
    } catch (_) {
      // T ignore và giữ _walletInfo là null
    } finally {
      if (mounted) setState(() => _isLoadingWallet = false);
    }
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(value);
  }

  Future<void> _payWithPayOs(DetailedIncidentData incident) async {
    if (_isProcessingPayment) return;

    final mission = incident.activeMission;
    final amount = mission?.actualCost ?? mission?.price ?? 0.0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Số tiền không hợp lệ, không thể thanh toán.'),
        ),
      );
      return;
    }

    setState(() => _isProcessingPayment = true);

    try {
      final repository = ref.read(incidentRepositoryProvider);
      final paymentResponse = await repository
          .createSnakebiteIncidentPaymentLink(
            incidentId: incident.id,
            amount: amount,
            description: 'Thanh toán phí cứu hộ',
          );

      if (paymentResponse.checkoutUrl != null &&
          paymentResponse.checkoutUrl!.isNotEmpty) {
        final uri = Uri.tryParse(paymentResponse.checkoutUrl!);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Mở PayOS checkout...')));
        } else {
          throw Exception('Liên kết thanh toán không hợp lệ');
        }
      } else {
        throw Exception('Không nhận được liên kết thanh toán từ PayOS');
      }

      // After redirect and webhook, refresh UI state
      await ref
          .read(detailedIncidentProvider.notifier)
          .refreshDetailedIncident();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PayOS payment thất bại: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isProcessingPayment = false);
    }
  }

  Future<void> _payWithWallet(DetailedIncidentData incident) async {
    if (_isProcessingPayment || _hasPaid) return;

    final mission = incident.activeMission;
    final amount = mission?.actualCost ?? mission?.price ?? 0.0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Số tiền không hợp lệ, không thể thanh toán.'),
        ),
      );
      return;
    }

    setState(() => _isProcessingPayment = true);

    try {
      final repository = ref.read(incidentRepositoryProvider);
      final paymentResponse = await repository.paySnakebiteIncidentWithWallet(
        incidentId: incident.id,
        amount: amount,
        description: 'Thanh toán bằng ví cho snakebite incident',
      );

      if (paymentResponse.status.toLowerCase() == 'paid') {
        setState(() => _hasPaid = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanh toán bằng ví thành công.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Thanh toán bằng ví chưa hoàn tất: ${paymentResponse.status}',
            ),
          ),
        );
      }

      await ref
          .read(detailedIncidentProvider.notifier)
          .refreshDetailedIncident();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thanh toán ví thất bại: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isProcessingPayment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailedIncidentState = ref.watch(detailedIncidentProvider);
    final incident = detailedIncidentState.incident;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Chi tiết sự cố'),
        backgroundColor: const Color(0xFF228B22),
      ),
      body: detailedIncidentState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF228B22)),
            )
          : detailedIncidentState.error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Không tải được dữ liệu sự cố.'),
                    const SizedBox(height: 12),
                    Text(detailedIncidentState.error!),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () => ref
                          .read(detailedIncidentProvider.notifier)
                          .loadDetailedIncident(
                            widget.incidentId,
                            forceRefresh: true,
                          ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          : incident == null
          ? const Center(child: Text('Không tìm thấy sự cố.'))
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(detailedIncidentProvider.notifier)
                    .loadDetailedIncident(
                      widget.incidentId,
                      forceRefresh: true,
                    );
              },
              color: const Color(0xFF228B22),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusOverview(incident),
                    const SizedBox(height: 12),
                    _buildIncidentInfoCard(incident),
                    const SizedBox(height: 12),
                    _buildRescuerInfoCard(incident),
                    const SizedBox(height: 12),
                    _buildPaymentCard(incident),
                    const SizedBox(height: 12),
                    _buildMediaCard(incident),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusOverview(DetailedIncidentData incident) {
    final occurredAt = incident.incidentOccurredAt ?? DateTime.now();
    final elapsed = DateTime.now().difference(occurredAt);
    final minutes = elapsed.inMinutes;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF228B22).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Trạng thái: ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Chip(
                backgroundColor:
                    incident.status == IncidentStatus.finished ||
                        incident.status == IncidentStatus.completed
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                label: Text(
                  incident.status.displayText,
                  style: TextStyle(
                    color:
                        incident.status == IncidentStatus.finished ||
                            incident.status == IncidentStatus.completed
                        ? Colors.green.shade800
                        : Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentInfoCard(DetailedIncidentData incident) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB2DFDB), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi tiết sự cố',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _infoRow('Mức độ', incident.severityText),
          _infoRow(
            'Thời gian',
            DateFormat(
              'dd/MM/yyyy HH:mm',
            ).format((incident.incidentOccurredAt ?? DateTime.now()).toLocal()),
          ),
          _infoRow('Địa chỉ', incident.address ?? 'Chưa có'),
          _infoRow(
            'Tọa độ',
            '${incident.locationCoordinates.latitude.toStringAsFixed(6)}, ${incident.locationCoordinates.longitude.toStringAsFixed(6)}',
          ),
          if (incident.symptomsReport?.isNotEmpty ?? false)
            _infoRow(
              'Triệu chứng',
              incident.symptomsReport!.map((e) => e.symptomName).join(', '),
            ),
          if (incident.identifiedSnakeSpecies != null)
            _infoRow('Loài rắn', incident.identifiedSnakeSpecies!.commonName),
        ],
      ),
    );
  }

  Widget _buildRescuerInfoCard(DetailedIncidentData incident) {
    final rescuer = incident.assignedRescuer;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8BC34A).withOpacity(0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin cứu hộ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          rescuer != null
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFF4CAF50),
                      backgroundImage:
                          rescuer.account?.avatarUrl?.isNotEmpty == true
                          ? NetworkImage(rescuer.account!.avatarUrl!)
                          : null,
                      child:
                          rescuer.account?.avatarUrl == null ||
                              rescuer.account?.avatarUrl?.isEmpty == true
                          ? Text(
                              (rescuer.account?.fullName?.isNotEmpty == true
                                  ? rescuer.account!.fullName!
                                        .substring(0, 1)
                                        .toUpperCase()
                                  : 'R'),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rescuer.account?.fullName ?? 'Không có',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rescuer.phoneNumber ?? 'Không có số'.toString(),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Đánh giá: ${rescuer.rating.toStringAsFixed(1)} ⭐',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : const Text(
                  'Chưa có nhân viên cứu hộ phân công.',
                  style: TextStyle(color: Colors.grey),
                ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(DetailedIncidentData incident) {
    final mission = incident.activeMission;
    final serviceFee = mission?.price ?? 0.0;
    final actualCost = mission?.actualCost;
    final transportFee = mission?.costFromCenter;
    final alreadyPaid = _hasPaid || incident.status == IncidentStatus.completed;

    if (alreadyPaid) {
      return Container();
    }

    final canPay =
        (incident.status == IncidentStatus.finished ||
        incident.status == IncidentStatus.completed);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.3),
          width: 1.3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thanh toán',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _infoRow('Giá dịch vụ', _formatCurrency(serviceFee)),
          if (transportFee != null)
            _infoRow('Giá di chuyển', _formatCurrency(transportFee)),
          _infoRow(
            'Tổng thanh toán',
            _formatCurrency(actualCost ?? serviceFee + (transportFee ?? 0)),
          ),
          _infoRow(
            'Trạng thái',
            alreadyPaid ? 'Đã thanh toán' : 'Chưa thanh toán',
          ),
          const Divider(color: Colors.grey, height: 18),
          Text(
            'Phương thức thanh toán',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          if (_isLoadingWallet) ...[
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF228B22)),
            ),
            const SizedBox(height: 8),
          ],
          _buildPaymentOption(
            method: MemberPaymentMethod.payos,
            title: 'PayOS',
            subtitle: 'Thanh toán qua cổng MoMo/PayOS',
            icon: Icons.payment,
            color: const Color(0xFF7B1FA2),
            enabled: canPay,
          ),
          const SizedBox(height: 10),
          _buildPaymentOption(
            method: MemberPaymentMethod.wallet,
            title: 'SnakeAid Wallet',
            subtitle: _walletInfo != null
                ? 'Trừ trực tiếp trong ví – Số dư: ${_formatCurrency(_walletInfo!.balance)}'
                : 'Trừ trực tiếp trong ví',
            icon: Icons.account_balance_wallet,
            color: const Color(0xFF00695C),
            enabled: canPay && _walletInfo != null,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: canPay && !alreadyPaid && !_isProcessingPayment
                ? () async {
                    if (_selectedMethod == MemberPaymentMethod.payos) {
                      await _payWithPayOs(incident);
                    } else {
                      if (_walletInfo == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Không lấy được thông tin ví.'),
                          ),
                        );
                        return;
                      }

                      final amount = mission?.actualCost ?? mission?.price ?? 0;
                      if (_walletInfo!.balance < amount) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Số dư ví không đủ, vui lòng nạp thêm.',
                            ),
                          ),
                        );
                        return;
                      }

                      await _payWithWallet(incident);
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: alreadyPaid
                  ? Colors.grey
                  : const Color(0xFF2F65E0),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              alreadyPaid
                  ? 'Đã thanh toán'
                  : _selectedMethod == MemberPaymentMethod.payos
                  ? 'Thanh toán qua PayOS'
                  : 'Thanh toán bằng ví',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          if (_isProcessingPayment) ...[
            const SizedBox(height: 12),
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF228B22)),
            ),
            const SizedBox(height: 8),
            const Center(child: Text('Đang xử lý thanh toán...')),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required MemberPaymentMethod method,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool enabled,
  }) {
    final isSelected = _selectedMethod == method;
    return InkWell(
      onTap: enabled
          ? () {
              setState(() => _selectedMethod = method);
            }
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE0E0E0),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: enabled ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: enabled ? Colors.black54 : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Radio<MemberPaymentMethod>(
              value: method,
              groupValue: _selectedMethod,
              onChanged: enabled
                  ? (value) {
                      if (value != null) {
                        setState(() => _selectedMethod = value);
                      }
                    }
                  : null,
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaCard(DetailedIncidentData incident) {
    if (incident.media.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDE7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFFEB3B).withOpacity(0.35),
            width: 1.2,
          ),
        ),
        child: Row(
          children: const [
            Icon(Icons.image_not_supported, color: Colors.grey),
            SizedBox(width: 8),
            Expanded(child: Text('Chưa cung cấp hình ảnh minh chứng.')),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hình ảnh',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: incident.media.map((m) {
              return SizedBox(
                width: 110,
                height: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: m.mediaUrl.isNotEmpty
                      ? Image.network(
                          m.mediaUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 28),
                        )
                      : const Icon(Icons.image_not_supported, size: 28),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
