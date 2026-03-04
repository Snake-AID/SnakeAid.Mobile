import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../models/snake_catching_request.dart';
import '../../models/snake_species.dart';
import '../../models/catching_environment.dart';
import '../../repository/snake_catching_repository.dart';
import '../../repository/snake_species_repository.dart';
import '../../repository/catching_environment_repository.dart';
import 'rescuer_mission_success_screen.dart';

/// A confirmed snake entry (species + quantity) — submitted to backend
class _SnakeEntry {
  final SnakeSpecies species;
  final int quantity;
  const _SnakeEntry({required this.species, required this.quantity});
}

/// Màn hình xác nhận kết quả sau khi bắt rắn thành công
class RescuerResultConfirmationScreen extends ConsumerStatefulWidget {
  final SnakeCatchingRequestData requestData;
  final String missionId;
  final List<File> capturedPhotos;
  final String notes;
  
  const RescuerResultConfirmationScreen({
    super.key,
    required this.requestData,
    required this.missionId,
    required this.capturedPhotos,
    required this.notes,
  });

  @override
  ConsumerState<RescuerResultConfirmationScreen> createState() => _RescuerResultConfirmationScreenState();
}

class _RescuerResultConfirmationScreenState extends ConsumerState<RescuerResultConfirmationScreen> {
  // Snake species loaded from API
  List<SnakeSpecies> _allSpecies = [];
  bool _isLoadingSpecies = true;

  // Catching environments loaded from API
  List<CatchingEnvironment> _allEnvironments = [];
  bool _isLoadingEnvironments = true;
  String? _catchingEnvironmentId;

  // Pending entry (not yet confirmed / submitted)
  SnakeSpecies? _pendingSpecies;
  int _pendingQuantity = 1;

  // Confirmed snakes (already submitted to backend)
  final List<_SnakeEntry> _confirmedSnakes = [];
  bool _isConfirmingSnake = false;
  bool _isSubmitting = false;

  // Additional notes
  final TextEditingController _additionalNotesController = TextEditingController();

  bool get _isValid => _confirmedSnakes.isNotEmpty && _catchingEnvironmentId != null;

  @override
  void initState() {
    super.initState();
    _loadAllSpecies();
    _loadAllEnvironments();
  }

  Future<void> _loadAllSpecies() async {
    try {
      final repo = ref.read(snakeSpeciesRepositoryProvider);
      final list = await repo.getSnakeSpecies();
      if (mounted) setState(() { _allSpecies = list; _isLoadingSpecies = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoadingSpecies = false);
    }
  }

  Future<void> _loadAllEnvironments() async {
    try {
      final repo = ref.read(catchingEnvironmentRepositoryProvider);
      final list = await repo.getCatchingEnvironments();
      if (mounted) setState(() { _allEnvironments = list; _isLoadingEnvironments = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoadingEnvironments = false);
    }
  }

  Future<void> _showConfirmSnakeDialog() async {
    if (_pendingSpecies == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Color(0xFFFF6B35)),
            SizedBox(width: 8),
            Text('Xác nhận loài rắn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bạn muốn thêm:', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3EE),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFF6B35).withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.pest_control, color: Color(0xFFFF6B35), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _pendingSpecies!.commonName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '× $_pendingQuantity',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text('Sau khi xác nhận sẽ được ghi nhận vào hệ thống.', style: TextStyle(fontSize: 12, color: Color(0xFF999999))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF999999))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xác nhận', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true) _confirmSnake();
  }

  Future<void> _confirmSnake() async {
    if (_pendingSpecies == null || _isConfirmingSnake) return;
    setState(() => _isConfirmingSnake = true);
    try {
      final repo = ref.read(snakeCatchingRepositoryProvider);
      await repo.addMissionDetail(widget.missionId, _pendingSpecies!.id, _pendingQuantity);
      setState(() {
        _confirmedSnakes.add(_SnakeEntry(species: _pendingSpecies!, quantity: _pendingQuantity));
        _pendingSpecies = null;
        _pendingQuantity = 1;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isConfirmingSnake = false);
    }
  }

  Future<void> _submitResult() async {
    if (!_isValid || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(snakeCatchingRepositoryProvider);
      await repo.completeMission(widget.missionId, catchingEnvironmentId: _catchingEnvironmentId!);
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => RescuerMissionSuccessScreen(
          requestData: widget.requestData,
          missionId: widget.missionId,
          photoCount: widget.capturedPhotos.length,
        ),
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _additionalNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F4F4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Xác Nhận Hoàn Thành',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Success Section
                _buildSuccessSection(),
                
                // Summary Card
                _buildSummaryCard(),
                
                // Snake Confirmation Card
                _buildSnakeConfirmationCard(),
                
                // Details Section
                _buildDetailsSection(),
                
                // Fee Reminder Card
                _buildFeeReminderCard(),
                
                const SizedBox(height: 100),
              ],
            ),
          ),
          
          // Fixed Bottom Button
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildSuccessSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      color: const Color(0xFFF4F4F4),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF28A745).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF28A745),
                size: 50,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Đã bắt rắn thành công!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF28A745),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow(Icons.location_on, widget.requestData.address),
          const SizedBox(height: 12),
          _buildSummaryRow(Icons.calendar_today, '8/12/2025, 14:30'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
          ),
          child: Icon(icon, color: const Color(0xFF666666), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSnakeConfirmationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: const [
              Text('Xác Nhận Loài Rắn',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
              Text(' *', style: TextStyle(fontSize: 18, color: Color(0xFFFF6B35))),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Thêm từng loài rắn đã bắt được',
              style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
          const SizedBox(height: 16),

          // List of confirmed snakes
          if (_confirmedSnakes.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Text('Chưa có loài rắn nào được xác nhận',
                  style: TextStyle(fontSize: 14, color: Color(0xFF999999), fontStyle: FontStyle.italic)),
            )
          else
            ...List.generate(_confirmedSnakes.length, (i) {
              final entry = _confirmedSnakes[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FFF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF28A745).withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF28A745), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('${entry.species.commonName} × ${entry.quantity}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                              color: Color(0xFF333333))),
                    ),
                    InkWell(
                      onTap: () => setState(() => _confirmedSnakes.removeAt(i)),
                      child: const Icon(Icons.close, size: 18, color: Color(0xFF999999)),
                    ),
                  ],
                ),
              );
            }),

          const Divider(height: 24),

          // Add snake row
          const Text('Thêm rắn', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
          const SizedBox(height: 10),

          // Species dropdown
          if (_isLoadingSpecies)
            const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF6B35))))
          else if (_allSpecies.isEmpty)
            const Text('Không thể tải danh sách loài rắn',
                style: TextStyle(color: Color(0xFF999999), fontStyle: FontStyle.italic))
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFF6B35), width: 1.5),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<SnakeSpecies>(
                  isExpanded: true,
                  value: _pendingSpecies,
                  hint: const Text('Chọn loài rắn', style: TextStyle(color: Color(0xFF999999))),
                  items: _allSpecies.map((s) {
                    return DropdownMenuItem<SnakeSpecies>(
                      value: s,
                      child: Text(s.commonName, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (s) => setState(() => _pendingSpecies = s),
                ),
              ),
            ),

          if (!_isLoadingSpecies && _allSpecies.isNotEmpty) ...[
            const SizedBox(height: 12),
            // Quantity row + confirm button
            Row(
              children: [
                // Quantity selector
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFDDDDDD)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 16),
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        onPressed: _pendingQuantity > 1
                            ? () => setState(() => _pendingQuantity--)
                            : null,
                      ),
                      Text('$_pendingQuantity',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                              color: Color(0xFF333333))),
                      IconButton(
                        icon: const Icon(Icons.add, size: 16),
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        onPressed: () => setState(() => _pendingQuantity++),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Confirm button
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: (_pendingSpecies != null && !_isConfirmingSnake)
                          ? _showConfirmSnakeDialog
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFDDDDDD),
                        disabledForegroundColor: const Color(0xFF999999),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isConfirmingSnake
                          ? const SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('XÁC NHẬN',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Catching Environment
          Row(
            children: const [
              Text(
                'Nơi bắt rắn',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
              Text(' *', style: TextStyle(fontSize: 14, color: Color(0xFFFF6B35))),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Chọn môi trường để hệ thống tính giá chính xác',
            style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 10),
          if (_isLoadingEnvironments)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF6B35)),
              ),
            )
          else if (_allEnvironments.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFFF8F00), size: 16),
                  SizedBox(width: 8),
                  Text('Không thể tải danh sách môi trường',
                      style: TextStyle(fontSize: 13, color: Color(0xFF7B5800))),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _catchingEnvironmentId == null
                      ? const Color(0xFFFF6B35)
                      : const Color(0xFF28A745),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _catchingEnvironmentId,
                  hint: const Text('Chọn nơi bắt rắn', style: TextStyle(color: Color(0xFF999999))),
                  items: _allEnvironments.map((env) {
                    return DropdownMenuItem<String>(
                      value: env.id,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(env.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333))),
                          if (env.description != null && env.description!.isNotEmpty)
                            Text(env.description!,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                                overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _catchingEnvironmentId = val),
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Additional Notes
          const Text(
            'Ghi chú bổ sung',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _additionalNotesController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Thông tin bổ sung...',
              hintStyle: const TextStyle(color: Color(0xFF999999)),
              filled: true,
              fillColor: const Color(0xFFF4F4F4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF28A745)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeReminderCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF28A745).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.requestData.estimatedPrice != null)
              Text(
                'Bạn sẽ nhận: ${widget.requestData.estimatedPrice!.toStringAsFixed(0)} VNĐ',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF28A745),
                ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Khách hàng thanh toán sau',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          border: const Border(
            top: BorderSide(color: Color(0xFFE0E0E0)),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: (_isValid && !_isSubmitting) ? _submitResult : null,
            icon: _isSubmitting
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send, size: 20),
            label: Text(
              _isValid
                  ? 'GỬI KẾT QUẢ CHO KHÁCH HÀNG'
                  : (_confirmedSnakes.isEmpty
                      ? 'CẦN XÁC NHẬN ÍT NHẤT 1 LOÀI RẮN'
                      : 'CẦN CHỌN NƠI BẮT RẮN'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: (_isValid && !_isSubmitting) ? const Color(0xFF28A745) : const Color(0xFFDDDDDD),
              foregroundColor: (_isValid && !_isSubmitting) ? Colors.white : const Color(0xFF999999),
              elevation: 0,
              disabledBackgroundColor: const Color(0xFFDDDDDD),
              disabledForegroundColor: const Color(0xFF999999),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ),
    );
  }
}
