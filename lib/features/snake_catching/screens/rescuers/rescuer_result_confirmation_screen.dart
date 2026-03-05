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

  // Species picker search
  final TextEditingController _speciesSearchController = TextEditingController();

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
    _speciesSearchController.dispose();
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

  // ── helpers ───────────────────────────────────────────────────────
  Color _dangerColor(SnakeSpecies s) {
    if (!s.isVenomous) return const Color(0xFF28A745);
    if (s.riskLevel >= 8) return const Color(0xFFDC3545);
    if (s.riskLevel >= 6) return const Color(0xFFFF6B35);
    if (s.riskLevel >= 4) return const Color(0xFFFFC107);
    return const Color(0xFFFFC107);
  }

  String _dangerLabel(SnakeSpecies s) {
    if (!s.isVenomous) return 'Không độc';
    if (s.riskLevel >= 8) return 'Cực độc';
    if (s.riskLevel >= 6) return 'Độc mạnh';
    if (s.riskLevel >= 4) return 'Có độc';
    return 'Độc nhẹ';
  }

  IconData _dangerIcon(SnakeSpecies s) {
    if (!s.isVenomous) return Icons.check_circle;
    if (s.riskLevel >= 8) return Icons.dangerous;
    return Icons.warning_amber_rounded;
  }

  void _openSpeciesPicker() {
    _speciesSearchController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final query = _speciesSearchController.text.toLowerCase();
          final filtered = _allSpecies
              .where((s) =>
                  s.commonName.toLowerCase().contains(query) ||
                  s.scientificName.toLowerCase().contains(query))
              .toList();
          return DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (ctx, scrollCtrl) => Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F8F8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // ── handle ────────────────────────────────────────
                  const SizedBox(height: 10),
                  Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── title ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.pest_control, color: Color(0xFFFF6B35), size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Chọn Loài Rắn',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                                    color: Color(0xFF333333))),
                            Text('Chọn loài rắn đã bắt được',
                                style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── search ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _speciesSearchController,
                      onChanged: (_) => setSheet(() {}),
                      decoration: InputDecoration(
                        hintText: 'Tìm theo tên hoặc tên khoa học...',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFFAAAAAA), size: 20),
                        suffixIcon: _speciesSearchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18, color: Color(0xFFAAAAAA)),
                                onPressed: () {
                                  _speciesSearchController.clear();
                                  setSheet(() {});
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // ── divider ───────────────────────────────────────
                  const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

                  // ── species list ──────────────────────────────────
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text('Không tìm thấy loài rắn',
                                style: TextStyle(color: Color(0xFF999999), fontSize: 14)))
                        : ListView.separated(
                            controller: scrollCtrl,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final s = filtered[i];
                              final isSelected = _pendingSpecies?.id == s.id;
                              final dc = _dangerColor(s);
                              return GestureDetector(
                                onTap: () {
                                  setState(() => _pendingSpecies = s);
                                  Navigator.pop(ctx);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFFFF3EE)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFFF6B35)
                                          : const Color(0xFFEEEEEE),
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      // ── image ─────────────────────
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                        child: s.imageUrl != null && s.imageUrl!.isNotEmpty
                                            ? Image.network(
                                                s.imageUrl!,
                                                width: 80, height: 80,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    _speciesImagePlaceholder(),
                                              )
                                            : _speciesImagePlaceholder(),
                                      ),
                                      const SizedBox(width: 12),
                                      // ── info ──────────────────────
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(s.commonName,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF222222),
                                                  ),
                                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                                              const SizedBox(height: 2),
                                              Text(s.scientificName,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontStyle: FontStyle.italic,
                                                    color: Color(0xFF888888),
                                                  ),
                                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 7, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: dc.withOpacity(0.12),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(_dangerIcon(s), size: 11, color: dc),
                                                        const SizedBox(width: 4),
                                                        Text(_dangerLabel(s),
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.bold,
                                                              color: dc,
                                                            )),
                                                      ],
                                                    ),
                                                  ),
                                                  if (s.primaryVenomType != null &&
                                                      s.primaryVenomType!.isNotEmpty) ...[
                                                    const SizedBox(width: 6),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 7, vertical: 3),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFF0F0F0),
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      child: Text(
                                                        s.primaryVenomType!,
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          color: Color(0xFF666666),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // ── selected indicator ────────
                                      if (isSelected)
                                        const Padding(
                                          padding: EdgeInsets.only(right: 12),
                                          child: Icon(Icons.check_circle,
                                              color: Color(0xFFFF6B35), size: 20),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _speciesImagePlaceholder() {
    return Container(
      width: 80, height: 80,
      color: const Color(0xFFF0EDE8),
      child: const Icon(Icons.pest_control,
          color: Color(0xFFCCBBAA), size: 32),
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
          // ── Section header ─────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.pest_control, color: Color(0xFFFF6B35), size: 18),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Xác Nhận Loài Rắn',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                              color: Color(0xFF333333))),
                      Text(' *', style: TextStyle(fontSize: 16, color: Color(0xFFFF6B35))),
                    ],
                  ),
                  Text('Thêm từng loài rắn đã bắt được',
                      style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Confirmed snakes list ──────────────────────────────────
          if (_confirmedSnakes.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Color(0xFFAAAAAA)),
                  SizedBox(width: 8),
                  Text('Chưa có loài rắn nào được xác nhận',
                      style: TextStyle(fontSize: 13, color: Color(0xFF999999),
                          fontStyle: FontStyle.italic)),
                ],
              ),
            )
          else
            ...List.generate(_confirmedSnakes.length, (i) {
              final entry = _confirmedSnakes[i];
              final dc = _dangerColor(entry.species);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FFF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF28A745).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    // mini image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                      child: entry.species.imageUrl != null && entry.species.imageUrl!.isNotEmpty
                          ? Image.network(
                              entry.species.imageUrl!,
                              width: 56, height: 56, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _confirmedImageFallback(),
                            )
                          : _confirmedImageFallback(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.species.commonName,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                                  color: Color(0xFF222222)),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: dc.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(_dangerLabel(entry.species),
                                    style: TextStyle(fontSize: 10, color: dc,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF28A745).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('× ${entry.quantity}',
                                    style: const TextStyle(fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF28A745))),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 18, color: Color(0xFFCC3333)),
                      onPressed: () => setState(() => _confirmedSnakes.removeAt(i)),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 14),

          // ── Add new snake ──────────────────────────────────────────
          const Text('Thêm rắn',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: Color(0xFF555555))),
          const SizedBox(height: 10),

          if (_isLoadingSpecies)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF6B35)),
              ),
            )
          else if (_allSpecies.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3EE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6B35), size: 16),
                SizedBox(width: 8),
                Text('Không thể tải danh sách loài rắn',
                    style: TextStyle(fontSize: 13, color: Color(0xFF7B3A00))),
              ]),
            )
          else ...[
            // Species selector button / selected card
            GestureDetector(
              onTap: _openSpeciesPicker,
              child: _pendingSpecies == null
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8F6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFFF6B35),
                          width: 1.5,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Color(0xFFFF6B35), size: 20),
                          SizedBox(width: 10),
                          Text('Chọn loài rắn đã bắt...',
                              style: TextStyle(fontSize: 14, color: Color(0xFFBB7055))),
                          Spacer(),
                          Icon(Icons.keyboard_arrow_down,
                              color: Color(0xFFFF6B35), size: 22),
                        ],
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3EE),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFFF6B35), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          // Snake image
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(9),
                              bottomLeft: Radius.circular(9),
                            ),
                            child: _pendingSpecies!.imageUrl != null &&
                                    _pendingSpecies!.imageUrl!.isNotEmpty
                                ? Image.network(
                                    _pendingSpecies!.imageUrl!,
                                    width: 70, height: 70, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _speciesImagePlaceholder(),
                                  )
                                : Container(
                                    width: 70, height: 70,
                                    color: const Color(0xFFF0EDE8),
                                    child: const Icon(Icons.pest_control,
                                        color: Color(0xFFCCBBAA), size: 28),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_pendingSpecies!.commonName,
                                    style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.bold,
                                      color: Color(0xFF222222),
                                    ),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text(_pendingSpecies!.scientificName,
                                    style: const TextStyle(
                                      fontSize: 11, fontStyle: FontStyle.italic,
                                      color: Color(0xFF888888),
                                    ),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _dangerColor(_pendingSpecies!).withOpacity(0.14),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(_dangerIcon(_pendingSpecies!),
                                              size: 11,
                                              color: _dangerColor(_pendingSpecies!)),
                                          const SizedBox(width: 3),
                                          Text(_dangerLabel(_pendingSpecies!),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: _dangerColor(_pendingSpecies!),
                                              )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // change arrow
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                const Icon(Icons.swap_vert,
                                    color: Color(0xFFFF6B35), size: 18),
                                const SizedBox(height: 2),
                                Text('Đổi',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[500],
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 12),

            // ── Quantity + confirm ─────────────────────────────────
            Row(
              children: [
                // Label
                const Text('Số lượng:',
                    style: TextStyle(fontSize: 13, color: Color(0xFF666666))),
                const SizedBox(width: 10),
                // Quantity stepper
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFDDDDDD)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 32, height: 36,
                        child: IconButton(
                          icon: const Icon(Icons.remove, size: 14),
                          padding: EdgeInsets.zero,
                          onPressed: _pendingQuantity > 1
                              ? () => setState(() => _pendingQuantity--)
                              : null,
                        ),
                      ),
                      Container(
                        width: 34,
                        alignment: Alignment.center,
                        child: Text('$_pendingQuantity',
                            style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            )),
                      ),
                      SizedBox(
                        width: 32, height: 36,
                        child: IconButton(
                          icon: const Icon(Icons.add, size: 14),
                          padding: EdgeInsets.zero,
                          onPressed: () => setState(() => _pendingQuantity++),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Confirm button
                Expanded(
                  child: SizedBox(
                    height: 42,
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isConfirmingSnake
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline, size: 16),
                                SizedBox(width: 6),
                                Text('THÊM RẮN',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            ),
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

  Widget _confirmedImageFallback() {
    return Container(
      width: 56, height: 56,
      color: const Color(0xFFF0EDE8),
      child: const Icon(Icons.pest_control, color: Color(0xFFCCBBAA), size: 24),
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
