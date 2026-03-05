import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/snake_catching_request.dart';
import '../../models/snake_species.dart';
import '../../repository/snake_catching_repository.dart';
import '../../repository/snake_species_repository.dart';
import '../../repository/transaction_repository.dart';
import 'rescuer_en_route_screen.dart';

/// Màn hình sau khi tài xế chấp nhận đơn — chờ khách hàng thanh toán
class RescuerAcceptRequestScreen extends ConsumerStatefulWidget {
  final SnakeCatchingRequestData requestData;

  const RescuerAcceptRequestScreen({
    super.key,
    required this.requestData,
  });

  @override
  ConsumerState<RescuerAcceptRequestScreen> createState() =>
      _RescuerAcceptRequestScreenState();
}

class _RescuerAcceptRequestScreenState
    extends ConsumerState<RescuerAcceptRequestScreen> {
  final List<bool> _equipmentChecked = [false, false, false, false];

  TransactionInfo? _transaction;
  bool _isCheckingPayment = true;
  bool _paymentConfirmed = false;
  Timer? _pollingTimer;
  int _pollCount = 0;
  bool _cancelledByCustomerHandled = false;

  final Map<int, SnakeSpecies?> _speciesCache = {};
  bool _isStartingMission = false;

  /// Full request data fetched from detail API (includes user.account.fullName)
  SnakeCatchingRequestData? _fullRequest;

  @override
  void initState() {
    super.initState();
    _checkPayment();
    _loadSnakeSpecies();
    _fetchFullRequest();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_paymentConfirmed) _checkPayment(silent: true);
      _pollRequestStatus();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchFullRequest() async {
    try {
      final repo = ref.read(snakeCatchingRepositoryProvider);
      final response = await repo.getRequestById(widget.requestData.id);
      if (mounted && response.data != null) {
        setState(() => _fullRequest = response.data);
      }
    } catch (e) {
      debugPrint('⚠️ Could not fetch full request details: $e');
    }
  }

  Future<void> _pollRequestStatus() async {
    if (_cancelledByCustomerHandled) return;
    try {
      final repo = ref.read(snakeCatchingRepositoryProvider);
      final response = await repo.getRequestById(widget.requestData.id);
      if (!mounted) return;
      final data = response.data;
      if (data != null) {
        setState(() => _fullRequest = data);
        if (data.status == 'Cancelled' && !_cancelledByCustomerHandled) {
          _cancelledByCustomerHandled = true;
          _pollingTimer?.cancel();
          _showCancelledByCustomerDialog(data.cancellationReason);
        }
      }
    } catch (_) {}
  }

  void _showCancelledByCustomerDialog(String? reason) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFDC3545).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cancel, color: Color(0xFFDC3545), size: 38),
            ),
            const SizedBox(height: 16),
            const Text(
              'Đơn bị hủy bởi khách hàng',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F1F1F),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Khách hàng đã hủy yêu cầu này. Bạn sẽ được đưa về danh sách công việc.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4),
            ),
            if (reason != null && reason.isNotEmpty) ...[  
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lý do hủy:',
                      style: TextStyle(fontSize: 11, color: Color(0xFF999999)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reason,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF444444),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                // Pop back to rescuer home / available jobs list
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              child: const Text(
                'Về Danh Sách Công Việc',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startMission() async {
    setState(() => _isStartingMission = true);
    try {
      final repo = ref.read(snakeCatchingRepositoryProvider);
      // Get missionId — prefer from widget data, refresh if missing
      String? missionId = widget.requestData.mission?.id;
      if (missionId == null || missionId.isEmpty) {
        final response = await repo.getRequestById(widget.requestData.id);
        missionId = response.data?.mission?.id;
      }
      if (missionId == null || missionId.isEmpty) {
        throw Exception('Không tìm thấy nhiệm vụ. Vui lòng thử lại.');
      }

      await repo.startMission(missionId);

      if (!mounted) return;
      _pollingTimer?.cancel();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => RescuerEnRouteScreen(
          requestData: widget.requestData,
          missionId: missionId!,
        ),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: const Color(0xFFDC3545),
        ),
      );
    } finally {
      if (mounted) setState(() => _isStartingMission = false);
    }
  }

  Future<void> _loadSnakeSpecies() async {
    final repo = ref.read(snakeSpeciesRepositoryProvider);
    final ids = widget.requestData.details.map((d) => d.snakeSpeciesId).toSet();
    await Future.wait(ids.map((id) async {
      try {
        final species = await repo.getSnakeSpeciesById(id);
        if (mounted) setState(() => _speciesCache[id] = species);
      } catch (_) {
        if (mounted) setState(() => _speciesCache[id] = null);
      }
    }));
  }

  Future<void> _checkPayment({bool silent = false}) async {
    if (!silent) setState(() => _isCheckingPayment = true);
    try {
      final repo = ref.read(transactionRepositoryProvider);
      final tx = await repo.getTransactionByRequestId(widget.requestData.id);
      if (!mounted) return;
      setState(() {
        _transaction = tx;
        _paymentConfirmed = tx != null && tx.isDeposited;
        _isCheckingPayment = false;
        _pollCount++;
      });
      if (_paymentConfirmed) _pollingTimer?.cancel();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isCheckingPayment = false);
    }
  }

  Widget _buildSnakeSpeciesRow(SnakeSpeciesDetail detail) {
    final species = _speciesCache[detail.snakeSpeciesId];
    final isLoading = !_speciesCache.containsKey(detail.snakeSpeciesId);

    // Danger color based on risk level or venom
    Color dangerColor = const Color(0xFFFF6B35);
    String dangerLabel = 'Không độc';
    if (species != null) {
      if (species.isVenomous && species.riskLevel >= 8) {
        dangerColor = const Color(0xFFDC3545);
        dangerLabel = 'Rất nguy hiểm';
      } else if (species.isVenomous && species.riskLevel >= 5) {
        dangerColor = const Color(0xFFFF6B35);
        dangerLabel = 'Có độc';
      } else if (species.isVenomous) {
        dangerColor = const Color(0xFFFFC107);
        dangerLabel = 'Độc nhẹ';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: image + info + quantity badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Snake image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: isLoading
                      ? Container(
                          color: const Color(0xFFEEEEEE),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF6B35)),
                            ),
                          ),
                        )
                      : (species?.imageUrl != null
                          ? Image.network(
                              species!.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFFEEEEEE),
                                child: const Icon(Icons.pest_control, size: 36, color: Color(0xFFBBBBBB)),
                              ),
                            )
                          : Container(
                              color: const Color(0xFFEEEEEE),
                              child: const Icon(Icons.pest_control, size: 36, color: Color(0xFFBBBBBB)),
                            )),
                ),
              ),

              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        species?.commonName ?? detail.snakeSpeciesName,
                        style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        species?.scientificName ?? detail.snakeSpeciesScientificName,
                        style: const TextStyle(
                          fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF888888),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Badges row
                      Row(
                        children: [
                          if (species != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: dangerColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    species.isVenomous ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                                    size: 11,
                                    color: dangerColor,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    dangerLabel,
                                    style: TextStyle(
                                      fontSize: 11, fontWeight: FontWeight.w600, color: dangerColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(width: 6),
                          if (species != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF666666).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Nguy cơ ${species.riskLevel.toInt()}/10',
                                style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF666666), fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Quantity badge
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'x${detail.quantity}',
                    style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Identification summary (if available)
          if (species?.identificationSummary != null && species!.identificationSummary!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: dangerColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 13, color: dangerColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        species.identificationSummary!,
                        style: TextStyle(
                          fontSize: 11, color: dangerColor.withOpacity(0.85),
                          fontStyle: FontStyle.italic, height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    return value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = _fullRequest ?? widget.requestData;
    final mission = request.mission;
    final user = request.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Đơn Đã Nhận',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSuccessHeader(),
            const SizedBox(height: 16),
            _buildPaymentStatusBanner(),
            const SizedBox(height: 16),
            _buildJobInformationCard(request, mission),
            const SizedBox(height: 16),
            _buildCustomerInformationCard(user),
            const SizedBox(height: 16),
            _buildEquipmentChecklistCard(),
            const SizedBox(height: 16),
            _buildSafetyWarningCard(),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomSheet: _buildStickyFooter(request),
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF28A745).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Color(0xFF28A745), size: 44),
          ),
          const SizedBox(height: 12),
          const Text(
            'ĐÃ NHẬN ĐƠN THÀNH CÔNG!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF28A745),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Hãy chuẩn bị thiết bị và chờ khách hàng thanh toán',
            style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusBanner() {
    if (_isCheckingPayment && _pollCount == 0) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.4)),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2196F3)),
            ),
            SizedBox(width: 12),
            Text(
              'Đang kiểm tra trạng thái thanh toán...',
              style: TextStyle(fontSize: 14, color: Color(0xFF2196F3)),
            ),
          ],
        ),
      );
    }

    if (_paymentConfirmed) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF28A745)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Color(0xFF28A745), shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Khách hàng đã thanh toán đặt cọc',
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF28A745),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Bạn có thể bắt đầu di chuyển ngay bây giờ',
                    style: TextStyle(fontSize: 12, color: Color(0xFF4CAF50)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Not paid yet
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFC107)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.hourglass_top_rounded, color: Color(0xFFFF8F00), size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chờ khách hàng thanh toán',
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF8F00),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Hệ thống tự động kiểm tra mỗi 5 giây',
                  style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _checkPayment,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _isCheckingPayment
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF8F00)),
                    )
                  : const Icon(Icons.refresh, size: 18, color: Color(0xFFFF8F00)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobInformationCard(SnakeCatchingRequestData request, MissionData? mission) {
    final price = mission?.estimatedCost ?? request.estimatedPrice;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông Tin Công Việc',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 16),

          // Species list
          ...request.details.map((detail) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildSnakeSpeciesRow(detail),
              )),

          const Divider(height: 24, color: Color(0xFFEEEEEE)),

          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Color(0xFFFF6B35), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  request.address,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          if (request.distanceKm != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.route, color: Color(0xFF2196F3), size: 18),
                const SizedBox(width: 8),
                Text(
                  '${request.distanceKm!.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
          ],

          if (price != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.payments, color: Color(0xFF28A745), size: 18),
                const SizedBox(width: 8),
                Text(
                  '${_formatCurrency(price)} VNĐ',
                  style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF28A745),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '(giá ước tính)',
                  style: TextStyle(fontSize: 11, color: Color(0xFF999999)),
                ),
              ],
            ),
          ],

          if (request.additionalDetails != null && request.additionalDetails!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFE5CC)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFFF6B35), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.additionalDetails!,
                      style: const TextStyle(
                        fontSize: 12, color: Color(0xFF666666),
                        fontStyle: FontStyle.italic, height: 1.4,
                      ),
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

  Widget _buildCustomerInformationCard(RequestUserInfo? user) {
    final name = user?.account?.fullName?.isNotEmpty == true
        ? user!.account!.fullName
        : (user?.userName.isNotEmpty == true
            ? user!.userName
            : (_fullRequest == null ? 'Đang tải...' : 'Khách hàng'));
    final phone = user?.phoneNumber.isNotEmpty == true ? user!.phoneNumber : null;
    final email = user?.email.isNotEmpty == true ? user!.email : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Thông Tin Khách Hàng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
              ),
              const Spacer(),
              if (user != null && user.ratingCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 13, color: Color(0xFFFFC107)),
                      const SizedBox(width: 3),
                      Text(
                        '${user.rating.toStringAsFixed(1)} (${user.ratingCount})',
                        style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFFC107),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(color: Color(0xFFE0E0E0), shape: BoxShape.circle),
                child: const Icon(Icons.person, color: Color(0xFF999999), size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Họ tên: $name',
                      style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (phone != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: url_launcher tel:$phone
                },
                icon: const Icon(Icons.call, size: 18),
                label: Text(
                  'GỌI KHÁCH HÀNG',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],

          if (user?.emergencyContacts != null && user!.emergencyContacts.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('Liên hệ khẩn cấp:', style: TextStyle(fontSize: 13, color: Color(0xFF999999))),
            const SizedBox(height: 6),
            ...user.emergencyContacts.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, size: 14, color: Color(0xFFFF6B35)),
                      const SizedBox(width: 6),
                      Text(c, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                    ],
                  ),
                )),
          ],

          if (user?.hasUnderlyingDisease == true) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFDC3545).withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFDC3545), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Khách hàng có bệnh nền — chú ý khi xử lý',
                      style: TextStyle(fontSize: 12, color: Color(0xFFDC3545), fontWeight: FontWeight.w600),
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

  Widget _buildEquipmentChecklistCard() {
    final equipmentList = [
      'Móc bắt rắn (1.2m+)',
      'Găng tay bảo hộ',
      'Túi vải dày / Hộp nhựa',
      'Đèn pin (nếu tối)',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thiết Bị Cần Mang',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 16),
          ...List.generate(equipmentList.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _equipmentChecked[index],
                      onChanged: (v) => setState(() => _equipmentChecked[index] = v ?? false),
                      activeColor: const Color(0xFFFF6B35),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(equipmentList[index],
                      style: const TextStyle(fontSize: 14, color: Color(0xFF666666))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSafetyWarningCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFFFF6B35), shape: BoxShape.circle),
            child: const Icon(Icons.shield, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đọc lại hướng dẫn an toàn trước khi xuất phát',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
                SizedBox(height: 2),
                Text(
                  'Giữ khoảng cách an toàn, mang đầy đủ bảo hộ',
                  style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter(SnakeCatchingRequestData request) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_paymentConfirmed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: _isCheckingPayment ? const Color(0xFF2196F3) : const Color(0xFFFFC107),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isCheckingPayment
                        ? 'Đang kiểm tra thanh toán...'
                        : 'Chờ khách hàng thanh toán đặt cọc',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isCheckingPayment ? const Color(0xFF2196F3) : const Color(0xFFFF8F00),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _paymentConfirmed && !_isStartingMission ? _startMission : null,
              icon: _isStartingMission
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.navigation, size: 20),
              label: Text(
                _isStartingMission ? 'Đang xử lý...' : 'BẮT ĐẦU DI CHUYỂN',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _paymentConfirmed && !_isStartingMission ? const Color(0xFFFF6B35) : const Color(0xFFCCCCCC),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFCCCCCC),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isCancelling ? null : () => _showCancelDialog(),
              icon: _isCancelling
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFDC3545)),
                    )
                  : const Icon(Icons.close, size: 16),
              label: Text(
                _isCancelling ? 'Đang hủy đơn...' : 'Hủy đơn',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC3545),
                side: const BorderSide(color: Color(0xFFDC3545)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isCancelling = false;

  void _showCancelDialog() {
    String? _selectedReason;
    final _otherController = TextEditingController();
    bool _showOtherField = false;

    const reasons = [
      'Khách hàng không phản hồi / không liên lạc được',
      'Phương tiện hoặc thiết bị gặp sự cố',
      'Không thể đến địa điểm (tắc đường, sự cố đường)',
      'Địa chỉ không rõ ràng hoặc không chính xác',
      'Có việc khẩn cấp cá nhân',
      'Lý do khác',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC3545).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cancel_outlined, color: Color(0xFFDC3545), size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hủy đơn',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            Text(
                              'Vui lòng chọn lý do hủy đơn',
                              style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Warning banner
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFE082)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Color(0xFFFF8F00), size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Hủy đơn nhiều lần có thể ảnh hưởng đến điểm uy tín của bạn.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF7B5800)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Reason list
                  ...reasons.map((reason) {
                    final isOther = reason == 'Lý do khác';
                    return InkWell(
                      onTap: () {
                        setSheetState(() {
                          _selectedReason = reason;
                          _showOtherField = isOther;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedReason == reason
                              ? const Color(0xFFDC3545).withOpacity(0.07)
                              : const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedReason == reason
                                ? const Color(0xFFDC3545)
                                : Colors.grey[200]!,
                            width: _selectedReason == reason ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _selectedReason == reason
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: _selectedReason == reason
                                  ? const Color(0xFFDC3545)
                                  : Colors.grey[400],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                reason,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _selectedReason == reason
                                      ? const Color(0xFFDC3545)
                                      : const Color(0xFF444444),
                                  fontWeight: _selectedReason == reason
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // "Lý do khác" free-text field
                  if (_showOtherField) ...[
                    const SizedBox(height: 4),
                    TextField(
                      controller: _otherController,
                      autofocus: true,
                      maxLines: 2,
                      maxLength: 200,
                      decoration: InputDecoration(
                        hintText: 'Nhập lý do cụ thể...',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFFF8F8F8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFDC3545)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        counterStyle: TextStyle(color: Colors.grey[400], fontSize: 11),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                  ],

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF666666),
                            side: BorderSide(color: Colors.grey[300]!),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Giữ đơn', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (_selectedReason == null || _isCancelling)
                              ? null
                              : () async {
                                  final reason = _selectedReason == 'Lý do khác'
                                      ? (_otherController.text.trim().isNotEmpty
                                          ? _otherController.text.trim()
                                          : 'Lý do khác')
                                      : _selectedReason!;

                                  Navigator.pop(sheetContext);
                                  await _cancelRequest(reason);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC3545),
                            disabledBackgroundColor: Colors.grey[300],
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Xác nhận hủy', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _cancelRequest(String reason) async {
    setState(() => _isCancelling = true);
    try {
      final repo = ref.read(snakeCatchingRepositoryProvider);

      // Get missionId from full request or widget data
      final request = _fullRequest ?? widget.requestData;
      String? missionId = request.mission?.id;
      if (missionId == null || missionId.isEmpty) {
        final response = await repo.getRequestById(widget.requestData.id);
        missionId = response.data?.mission?.id;
      }
      if (missionId == null || missionId.isEmpty) {
        throw Exception('Không tìm thấy nhiệm vụ để hủy. Vui lòng thử lại.');
      }

      await repo.abortMission(missionId, reason);
      _pollingTimer?.cancel();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã hủy đơn thành công'),
          backgroundColor: Color(0xFF28A745),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: const Color(0xFFDC3545),
        ),
      );
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }}