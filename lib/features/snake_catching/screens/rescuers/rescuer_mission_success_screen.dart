import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/snake_catching_request.dart';
import '../../repository/snake_catching_repository.dart';

/// Màn hình hiển thị trạng thái nhiệm vụ đã hoàn thành và đang chờ khách hàng thanh toán
class RescuerMissionSuccessScreen extends ConsumerStatefulWidget {
  final SnakeCatchingRequestData requestData;
  final String missionId;
  final int photoCount;

  const RescuerMissionSuccessScreen({
    super.key,
    required this.requestData,
    required this.missionId,
    this.photoCount = 0,
  });

  @override
  ConsumerState<RescuerMissionSuccessScreen> createState() =>
      _RescuerMissionSuccessScreenState();
}

class _RescuerMissionSuccessScreenState
    extends ConsumerState<RescuerMissionSuccessScreen> {
  SnakeCatchingRequestData? _freshData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFreshData();
  }

  Future<void> _fetchFreshData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final repo = ref.read(snakeCatchingRepositoryProvider);
      final response = await repo.getRequestById(widget.requestData.id);
      if (mounted) setState(() { _freshData = response.data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString().replaceAll('Exception: ', ''); _isLoading = false; });
    }
  }

  // ─── Computed values ───────────────────────────────────────────────────────

  /// Fixed base service fee (platform default)
  static const double _baseFee = 500000.0;

  SnakeCatchingRequestData get _data => _freshData ?? widget.requestData;
  MissionData? get _mission => _data.mission;

  /// Actual total service cost from server (includes snake fee on top of base)
  double get _actualCost => _mission?.actualCost ?? _baseFee;

  /// Km deposit already paid by customer at booking
  double get _estimatedCost => _mission?.estimatedCost ?? 0.0;

  /// Extra amount customer still owes = actualCost − estimatedCost
  /// (server already stores this as mission.price)
  double get _missionPrice => _mission?.price ?? (_actualCost - _estimatedCost);

  /// Customer's total cost = km deposit + remaining balance (= actualCost total)
  double get _customerTotal => _estimatedCost + _missionPrice;

  /// Platform fee = 40% of base fee only (not applied to snake/travel fees)
  double get _platformFee => _baseFee * 0.4;

  /// Rescuer base share = 60% of base fee
  double get _rescuerBaseShare => _baseFee * 0.6;

  /// Snake catching fee = anything above base fee (goes 100% to rescuer)
  double get _snakeFee => (_actualCost - _baseFee).clamp(0.0, double.infinity);

  /// Travel fee = km deposit (goes 100% to rescuer)
  double get _travelFee => _estimatedCost;

  /// Rescuer total = base share + snake fee + travel fee
  double get _rescuerTotal => _rescuerBaseShare + _snakeFee + _travelFee;

  // ─── Duration ──────────────────────────────────────────────────────────────

  String get _missionDuration {
    final start = _mission?.startedAt;
    final end = _mission?.completedAt ?? DateTime.now();
    if (start == null) return '—';
    final diff = end.difference(start);
    if (diff.inMinutes < 1) return '< 1 phút';
    if (diff.inHours < 1) return '${diff.inMinutes} phút';
    return '${diff.inHours} giờ ${diff.inMinutes.remainder(60)} phút';
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8F6).withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF343A40)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chờ Thanh Toán',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF343A40)),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF28A745)))
          : _error != null
              ? _buildError()
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildCompletionHeader(),
                            const SizedBox(height: 24),
                            _buildPaymentStatusBadge(),
                            const SizedBox(height: 24),
                            _buildRescuerEarningsCard(),
                            const SizedBox(height: 16),
                            _buildCustomerPaymentCard(),
                            const SizedBox(height: 16),
                            _buildMissionSummaryCard(),
                            const SizedBox(height: 16),
                            _buildInfoCard(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomButton(context),
                  ],
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF666666))),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchFreshData,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF28A745)),
              child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionHeader() {
    final customerName = _data.user?.userName ?? _data.user?.email ?? 'Khách hàng';
    return Column(
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF28A745), size: 60),
        const SizedBox(height: 8),
        const Text(
          'Nhiệm vụ hoàn thành',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF28A745)),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.send, size: 16, color: Color(0xFF6C757D)),
            const SizedBox(width: 6),
            Text(
              'Đã gửi thông tin đến $customerName',
              style: const TextStyle(fontSize: 14, color: Color(0xFF6C757D)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFD7E14).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.schedule, size: 16, color: Color(0xFFFD7E14)),
          SizedBox(width: 6),
          Text(
            'Đang chờ khách hàng thanh toán',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFFD7E14)),
          ),
        ],
      ),
    );
  }

  Widget _buildRescuerEarningsCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Thu nhập của bạn',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF343A40))),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                const Text('Bạn sẽ nhận:',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6C757D))),
                const SizedBox(height: 6),
                Text(
                  '${_formatCurrency(_rescuerTotal.toInt())} VNĐ',
                  style: const TextStyle(
                      fontSize: 34, fontWeight: FontWeight.bold,
                      color: Color(0xFF28A745), letterSpacing: -1),
                ),
              ],
            ),
          ),
          const Divider(height: 28, color: Color(0xFFE2E8F0)),
          _buildFeeRow('Phí dịch vụ cơ bản:', '${_formatCurrency(_baseFee.toInt())} VNĐ'),
          const SizedBox(height: 8),
          _buildFeeRow('Phí nền tảng (40%):', '− ${_formatCurrency(_platformFee.toInt())} VNĐ',
              valueColor: const Color(0xFFDC3545)),
          const SizedBox(height: 8),
          _buildFeeRow(
            'Phần của bạn (60%):',
            '${_formatCurrency(_rescuerBaseShare.toInt())} VNĐ',
            valueColor: const Color(0xFF28A745),
          ),
          if (_snakeFee > 0) ...[
            const SizedBox(height: 8),
            _buildFeeRow('Phí bắt rắn:', '${_formatCurrency(_snakeFee.toInt())} VNĐ',
                valueColor: const Color(0xFF28A745)),
          ],
          if (_travelFee > 0) ...[
            const SizedBox(height: 8),
            _buildFeeRow('Phí di chuyển:', '${_formatCurrency(_travelFee.toInt())} VNĐ',
                valueColor: const Color(0xFF28A745)),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerPaymentCard() {
    final distanceKm = _data.distanceKm;
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chi phí khách hàng',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF343A40))),
          const Divider(height: 24, color: Color(0xFFE2E8F0)),
          _buildFeeRow(
            'Phí di chuyển (đã cọc):',
            '${_formatCurrency(_estimatedCost.toInt())} VNĐ${distanceKm != null ? ' · ${distanceKm.toStringAsFixed(1)} km' : ''}',
          ),
          const SizedBox(height: 8),
          _buildFeeRow('Phí phi vụ còn lại:', '${_formatCurrency(_missionPrice.toInt())} VNĐ'),
          const Divider(height: 20, color: Color(0xFFE2E8F0)),
          _buildFeeRow(
            'Tổng cộng:',
            '${_formatCurrency(_customerTotal.toInt())} VNĐ',
            labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                color: Color(0xFF343A40)),
            valueColor: const Color(0xFF343A40),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionSummaryCard() {
    final snakeNames = _data.details.isNotEmpty
        ? _data.details.map((d) => '${d.snakeSpeciesName} × ${d.quantity}').join(', ')
        : '—';

    return _buildCard(
      child: Column(
        children: [
          _buildSummaryRow(Icons.pest_control, 'Loài rắn: $snakeNames'),
          const SizedBox(height: 16),
          _buildSummaryRow(Icons.hourglass_top, 'Thời gian thực hiện: $_missionDuration'),
          const SizedBox(height: 16),
          _buildSummaryRow(Icons.location_on, _data.address),
          const SizedBox(height: 16),
          _buildSummaryRow(Icons.photo_camera, '${widget.photoCount} ảnh đã ghi nhận'),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D6EFD).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info, color: Color(0xFF0D6EFD), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Chúng tôi đã gửi yêu cầu thanh toán đến khách hàng. Bạn sẽ nhận thông báo khi thanh toán thành công.',
              style: TextStyle(fontSize: 14, color: Color(0xFF6C757D)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F6),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton(
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFFD7E14),
            side: const BorderSide(color: Color(0xFFFD7E14), width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Về Trang Chủ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildFeeRow(String label, String value, {
    Color? valueColor,
    TextStyle? labelStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle ??
            const TextStyle(fontSize: 14, color: Color(0xFF6C757D))),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: labelStyle != null ? FontWeight.bold : FontWeight.normal,
                color: valueColor ?? const Color(0xFF6C757D))),
      ],
    );
  }

  Widget _buildSummaryRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9), shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFF6C757D), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 14, color: Color(0xFF343A40))),
        ),
      ],
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
