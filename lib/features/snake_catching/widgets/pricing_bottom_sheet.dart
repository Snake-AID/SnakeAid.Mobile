import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../repository/system_settings_repository.dart';
import '../repository/catching_environment_repository.dart';
import '../models/system_setting.dart';
import '../models/catching_environment.dart';

class PricingBottomSheet extends ConsumerStatefulWidget {
  final ScrollController? scrollController;
  
  const PricingBottomSheet({super.key, this.scrollController});

  @override
  ConsumerState<PricingBottomSheet> createState() => _PricingBottomSheetState();
}

class _PricingBottomSheetState extends ConsumerState<PricingBottomSheet> {
  bool _isLoading = true;
  String? _error;
  List<SystemSetting> _settings = [];
  List<CatchingEnvironment> _environments = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final settingsRepo = ref.read(systemSettingsRepositoryProvider);
      final envRepo = ref.read(catchingEnvironmentRepositoryProvider);

      final results = await Future.wait([
        settingsRepo.getSystemSettings(),
        envRepo.getCatchingEnvironments(),
      ]);

      if (mounted) {
        setState(() {
          _settings = results[0] as List<SystemSetting>;
          _environments = results[1] as List<CatchingEnvironment>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _formatCurrency(String? valueStr) {
    if (valueStr == null) return '0 đ';
    final value = double.tryParse(valueStr);
    if (value == null) return '0 đ';
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Tham khảo giá dịch vụ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F1F1F),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: _isLoading
                  ? const Center(
                      child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ))
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              'Đã xảy ra lỗi: $_error',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          controller: widget.scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPaymentProcessSection(),
                              const SizedBox(height: 24),
                              _buildBasePricingSection(),
                              const SizedBox(height: 24),
                              _buildEnvironmentPricingSection(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF228B22),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Đã hiểu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasePricingSection() {
    final basePrice = _settings.firstWhere(
        (s) => s.settingKey == 'Catching:BasePrice',
        orElse: () => const SystemSetting(settingKey: '', value: '0'));
    final venomPrice = _settings.firstWhere(
        (s) => s.settingKey == 'Catching:VenomSnakePrice',
        orElse: () => const SystemSetting(settingKey: '', value: '0'));
    final nonVenomPrice = _settings.firstWhere(
        (s) => s.settingKey == 'Catching:NonVenomSnakePrice',
        orElse: () => const SystemSetting(settingKey: '', value: '0'));
    final kmPrice = _settings.firstWhere(
        (s) => s.settingKey == 'Catching:PricePerKilomenter',
        orElse: () => const SystemSetting(settingKey: '', value: '0'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.monetization_on, color: Colors.green[600], size: 20),
            const SizedBox(width: 8),
            const Text(
              'Giá dịch vụ cơ bản',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _buildPriceRow('Phí dịch vụ cơ bản:', _formatCurrency(basePrice.value)),
              const Divider(height: 16, thickness: 1),
              _buildPriceRow('Phí di chuyển (mỗi km):', _formatCurrency(kmPrice.value)),
              const Divider(height: 16, thickness: 1),
              _buildPriceRow('Phụ phí rắn độc:', _formatCurrency(venomPrice.value),
                  isHighlight: true, highlightColor: Colors.red),
              const Divider(height: 16, thickness: 1),
              _buildPriceRow('Phụ phí rắn không độc:', _formatCurrency(nonVenomPrice.value)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnvironmentPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.home_work, color: Colors.blue[600], size: 20),
            const SizedBox(width: 8),
            const Text(
              'Phụ phí môi trường bắt rắn',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Tùy vào độ phức tạp của từng loại địa hình, môi trường, chuyên gia cần áp dụng các thiết bị và kỹ năng đặc biệt hơn, do đó sẽ có phụ phí môi trường tương ứng:',
          style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4),
        ),
        const SizedBox(height: 12),
        if (_environments.isEmpty)
          const Text('Không có dữ liệu phụ phí môi trường.',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _environments.length,
              separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1),
              itemBuilder: (context, index) {
                final env = _environments[index];
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              env.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF333333),
                              ),
                            ),
                            if (env.description != null && env.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                env.description!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatCurrency(env.price?.toString() ?? '0'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentProcessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.payments_outlined, color: Colors.orange[700], size: 22),
            const SizedBox(width: 8),
            const Text(
              'Quy trình thanh toán (2 đợt)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPaymentStep(
                step: 'Đợt 1',
                title: 'Thanh toán phí di chuyển',
                description: 'Thanh toán trước khi đội cứu hộ xuất phát. Chi phí dựa trên số km thực tế từ trạm cứu hộ đến hiện trường.',
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, thickness: 1, color: Colors.black12),
              ),
              _buildPaymentStep(
                step: 'Đợt 2',
                title: 'Thanh toán phí dịch vụ bắt rắn',
                description: 'Thanh toán sau khi nhiệm vụ hoàn thành. Bao gồm: Giá dịch vụ cơ bản + Phụ phí rắn (Loại rắn × Số lượng) + Phụ phí môi trường.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStep({required String step, required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange[700],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            step,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF666666),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value,
      {bool isHighlight = false, Color highlightColor = Colors.green}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isHighlight ? highlightColor : const Color(0xFF444444),
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isHighlight ? highlightColor : const Color(0xFF228B22),
          ),
        ),
      ],
    );
  }
}
