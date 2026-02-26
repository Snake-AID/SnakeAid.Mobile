import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../models/snake_catching_request.dart';
import '../../models/snake_species.dart';
import '../../repository/snake_catching_repository.dart';
import '../../repository/snake_species_repository.dart';
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

  // Pending entry (not yet confirmed / submitted)
  SnakeSpecies? _pendingSpecies;
  int _pendingQuantity = 1;

  // Confirmed snakes (already submitted to backend)
  final List<_SnakeEntry> _confirmedSnakes = [];
  bool _isConfirmingSnake = false;
  bool _isSubmitting = false;

  // Optional detail fields
  double _snakeSize = 120;
  String _snakeStatus = 'healthy';
  final TextEditingController _releaseLocationController = TextEditingController();
  final TextEditingController _additionalNotesController = TextEditingController();

  bool get _isValid => _confirmedSnakes.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadAllSpecies();
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
      await repo.completeMission(widget.missionId);
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
    _releaseLocationController.dispose();
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
                          ? _confirmSnake
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
          // Size Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kích thước ước tính',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
              Text(
                '~${_snakeSize.toInt()} cm',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          Slider(
            value: _snakeSize,
            min: 0,
            max: 200,
            divisions: 200,
            activeColor: const Color(0xFF28A745),
            onChanged: (value) {
              setState(() {
                _snakeSize = value;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Status Radio Buttons
          const Text(
            'Tình trạng',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatusButton('healthy', 'Khỏe mạnh'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusButton('injured', 'Bị thương'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusButton('dead', 'Đã chết'),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Release Location
          const Text(
            'Địa điểm thả',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _releaseLocationController,
            decoration: InputDecoration(
              hintText: 'VD: Rừng xa dân cư',
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

  Widget _buildStatusButton(String value, String label) {
    final bool isSelected = _snakeStatus == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _snakeStatus = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF28A745) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF28A745) : const Color(0xFFDDDDDD),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Colors.white : const Color(0xFF333333),
          ),
        ),
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
              _isValid ? 'GỬI KẾT QUẢ CHO KHÁCH HÀNG' : 'CẦN XÁC NHẬN ÍT NHẤT 1 LOÀI RẮN',
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
