import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/ai_recognition_review_models.dart';
import '../providers/ai_recognition_review_provider.dart';
import '../repository/ai_recognition_review_repository.dart';
import '../../snake_species/models/snake_species_model.dart';

/// Expert AI Recognition Review — Detail & Action Screen
class AiRecognitionReviewScreen extends ConsumerStatefulWidget {
  final String recognitionResultId;

  const AiRecognitionReviewScreen({
    super.key,
    required this.recognitionResultId,
  });

  @override
  ConsumerState<AiRecognitionReviewScreen> createState() =>
      _AiRecognitionReviewScreenState();
}

class _AiRecognitionReviewScreenState
    extends ConsumerState<AiRecognitionReviewScreen> {
  final _notesController = TextEditingController();
  SnakeSpeciesModel? _selectedSpecies;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _handleVerify() async {
    if (_selectedSpecies == null) {
      _showSnackBar('Vui lòng chọn loài rắn chính xác để xác nhận.', isError: true);
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await ref.read(aiRecognitionReviewRepositoryProvider).verify(
            recognitionResultId: widget.recognitionResultId,
            correctedSpeciesId: _selectedSpecies!.id,
            expertNotes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );
      // Refresh queue to remove processed item
      ref.read(aiReviewQueueProvider.notifier).removeItem(
            widget.recognitionResultId,
          );
      ref.read(aiReviewHistoryProvider.notifier).load(refresh: true);
      if (mounted) {
        _showSnackBar('Đã xác nhận loài rắn thành công!');
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) context.pop();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          e.toString().replaceFirst('Exception: ', ''),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleReject() async {
    final confirmed = await _showRejectConfirmDialog();
    if (!confirmed) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(aiRecognitionReviewRepositoryProvider).reject(
            recognitionResultId: widget.recognitionResultId,
            expertNotes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );
      ref.read(aiReviewQueueProvider.notifier).removeItem(
            widget.recognitionResultId,
          );
      ref.read(aiReviewHistoryProvider.notifier).load(refresh: true);
      if (mounted) {
        _showSnackBar('Đã từ chối ảnh.');
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) context.pop();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          e.toString().replaceFirst('Exception: ', ''),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<bool> _showRejectConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Từ chối ảnh?',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            content: const Text(
              'Ảnh này sẽ không được dùng để huấn luyện model AI. '
              'Bạn có chắc chắn muốn từ chối?',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Huỷ',
                    style: TextStyle(color: Color(0xFF6B7280))),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Từ chối'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Species Picker ─────────────────────────────────────────────────────────

  void _openSpeciesPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SpeciesPickerSheet(
        initialSelected: _selectedSpecies,
        onSelected: (species) {
          setState(() => _selectedSpecies = species);
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final detailAsync =
        ref.watch(aiReviewDetailProvider(widget.recognitionResultId));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF131018)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Xem Xét Nhận Diện',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF131018),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
      ),
      body: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF10B981)),
        ),
        error: (err, _) => _buildErrorBody(err.toString()),
        data: (detail) => _buildBody(context, detail),
      ),
    );
  }

  Widget _buildErrorBody(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 56),
            const SizedBox(height: 16),
            Text(
              error.replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(
                  aiReviewDetailProvider(widget.recognitionResultId)),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AIRecognitionReviewDetailResponse detail) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero image
              _buildHeroImage(detail.media.mediaUrl),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI Result card
                    _buildAiResultCard(detail.aiResult),
                    const SizedBox(height: 16),
                    // Species detail (if mapped)
                    if (detail.aiResult.detectedSpecies != null)
                      _buildDetectedSpeciesCard(
                          detail.aiResult.detectedSpecies!),
                    if (detail.aiResult.detectedSpecies != null)
                      const SizedBox(height: 16),
                    // Expert action section
                    _buildExpertActionSection(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Bottom action bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildActionBar(),
        ),
      ],
    );
  }

  // ── Hero Image ──────────────────────────────────────────────────────────

  Widget _buildHeroImage(String url) {
    return Container(
      width: double.infinity,
      height: 260,
      color: const Color(0xFF1F2937),
      child: url.isEmpty
          ? const Center(
              child: Icon(Icons.image_outlined,
                  color: Color(0xFF4B5563), size: 56))
          : Image.network(
              url,
              width: double.infinity,
              height: 260,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: const Color(0xFF1F2937),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image,
                    color: Color(0xFF4B5563), size: 56),
              ),
            ),
    );
  }

  // ── AI Result Card ──────────────────────────────────────────────────────

  Widget _buildAiResultCard(SnakeAIRecognitionResultResponse ai) {
    final confPct = (ai.confidence * 100).round();
    final confColor = _confidenceColor(ai.confidence);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.precision_manufacturing,
                    color: Color(0xFF10B981), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Kết quả nhận diện AI',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF131018),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // YOLO class name
          _buildInfoRow('Lớp phân loại (YOLO)',
              ai.yoloClassName.isEmpty ? '—' : ai.yoloClassName),
          const SizedBox(height: 12),
          // Confidence
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Độ tin cậy',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280))),
              Text(
                '$confPct%',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: confColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ai.confidence.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(confColor),
            ),
          ),
          const SizedBox(height: 8),
          // Confidence label
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: confColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _confidenceLabel(ai.confidence),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: confColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Mapped status
          _buildInfoRow(
            'Đã ánh xạ loài',
            ai.isMapped ? 'Có' : 'Chưa ánh xạ',
          ),
        ],
      ),
    );
  }

  // ── Detected Species Card ───────────────────────────────────────────────

  Widget _buildDetectedSpeciesCard(DetectedSpeciesResponse species) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.info_outline,
                    color: Color(0xFFF59E0B), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Loài rắn AI phát hiện',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF131018),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (species.imageUrl != null && species.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                species.imageUrl!,
                width: double.infinity,
                height: 140,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          if (species.imageUrl != null && species.imageUrl!.isNotEmpty)
            const SizedBox(height: 12),
          _buildInfoRow('Tên thường gọi', species.commonName),
          const SizedBox(height: 8),
          _buildInfoRow('Tên khoa học', species.scientificName),
          if (species.primaryVenomType != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Loại độc tố',
                _venomTypeLabel(species.primaryVenomType!)),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Mức độ nguy hiểm',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280))),
              const Spacer(),
              _RiskLevelBadge(riskLevel: species.riskLevel),
            ],
          ),
          if (species.identificationSummary != null &&
              species.identificationSummary!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 12),
            Text(
              species.identificationSummary!,
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  // ── Expert Action Section ───────────────────────────────────────────────

  Widget _buildExpertActionSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C47C2).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_note,
                    color: Color(0xFF6C47C2), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Đánh giá của chuyên gia',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF131018),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Species selector
          const Text(
            'Loài rắn chính xác *',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _openSpeciesPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedSpecies != null
                      ? const Color(0xFF10B981)
                      : const Color(0xFFD1D5DB),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  if (_selectedSpecies != null &&
                      _selectedSpecies!.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        _selectedSpecies!.imageUrl!,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_outlined,
                                color: Color(0xFF9CA3AF), size: 20),
                      ),
                    )
                  else
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.pets,
                          color: Color(0xFF9CA3AF), size: 20),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedSpecies?.commonName ??
                          'Chọn loài rắn chính xác...',
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedSpecies != null
                            ? const Color(0xFF131018)
                            : const Color(0xFF9CA3AF),
                        fontWeight: _selectedSpecies != null
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down,
                      color: Color(0xFF6B7280)),
                ],
              ),
            ),
          ),
          if (_selectedSpecies != null) ...[
            const SizedBox(height: 6),
            Text(
              _selectedSpecies!.scientificName,
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF10B981),
                  fontStyle: FontStyle.italic),
            ),
          ],

          const SizedBox(height: 16),

          // Notes field
          const Text(
            'Ghi chú (tuỳ chọn)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            style: const TextStyle(fontSize: 14, color: Color(0xFF131018)),
            decoration: InputDecoration(
              hintText:
                  'Ví dụ: Đặc điểm nhận dạng phù hợp với loài...',
              hintStyle: const TextStyle(
                  fontSize: 13, color: Color(0xFFBBBBC0)),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFF10B981), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Info note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFFF59E0B).withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    color: Color(0xFFF59E0B), size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Ảnh được AI đánh dấu có độ tin cậy thấp. '
                    'Chọn "Xác nhận" nếu bạn xác định được loài, '
                    'hoặc "Từ chối" nếu ảnh không đủ chất lượng.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF92400E),
                      height: 1.5,
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

  // ── Bottom Action Bar ───────────────────────────────────────────────────

  Widget _buildActionBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Reject button
          Expanded(
            flex: 2,
            child: OutlinedButton.icon(
              onPressed: _isSubmitting ? null : _handleReject,
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Từ chối'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFEF4444)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Verify button
          Expanded(
            flex: 3,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _handleVerify,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check, size: 18),
              label: Text(_isSubmitting ? 'Đang gửi...' : 'Xác nhận loài'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
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
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280)),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF131018)),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Species Picker Bottom Sheet
// ---------------------------------------------------------------------------

class _SpeciesPickerSheet extends ConsumerStatefulWidget {
  final SnakeSpeciesModel? initialSelected;
  final ValueChanged<SnakeSpeciesModel> onSelected;

  const _SpeciesPickerSheet({
    required this.initialSelected,
    required this.onSelected,
  });

  @override
  ConsumerState<_SpeciesPickerSheet> createState() =>
      _SpeciesPickerSheetState();
}

class _SpeciesPickerSheetState extends ConsumerState<_SpeciesPickerSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speciesAsync = ref.watch(allSpeciesForPickerProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Chọn loài rắn chính xác',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF131018),
                  ),
                ),
              ],
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                prefixIcon:
                    const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                hintText: 'Tìm theo tên thường gọi hoặc tên khoa học...',
                hintStyle: const TextStyle(
                    fontSize: 13, color: Color(0xFFBBBBC0)),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          // List
          Expanded(
            child: speciesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF10B981)),
              ),
              error: (err, _) => Center(
                child: Text(
                  err.toString().replaceFirst('Exception: ', ''),
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
              data: (species) {
                final q = _searchQuery.trim().toLowerCase();
                final filtered = q.isEmpty
                    ? species
                    : species.where((s) {
                        return s.commonName.toLowerCase().contains(q) ||
                            s.scientificName.toLowerCase().contains(q) ||
                            s.alternativeNames
                                .any((n) => n.toLowerCase().contains(q));
                      }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'Không tìm thấy loài nào cho "$_searchQuery"',
                      style: const TextStyle(
                          color: Color(0xFF6B7280), fontSize: 13),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  itemBuilder: (ctx, i) {
                    final s = filtered[i];
                    final isSelected =
                        widget.initialSelected?.id == s.id;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: s.imageUrl != null && s.imageUrl!.isNotEmpty
                            ? Image.network(
                                s.imageUrl!,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _speciesIconPlaceholder(),
                              )
                            : _speciesIconPlaceholder(),
                      ),
                      title: Text(
                        s.commonName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF10B981)
                              : const Color(0xFF131018),
                        ),
                      ),
                      subtitle: Text(
                        s.scientificName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: Color(0xFF10B981), size: 22)
                          : _venomBadge(s.isVenomous),
                      onTap: () {
                        widget.onSelected(s);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _speciesIconPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      color: const Color(0xFFF3F4F6),
      child: const Icon(Icons.pets,
          color: Color(0xFFD1D5DB), size: 24),
    );
  }

  Widget _venomBadge(bool isVenomous) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isVenomous
            ? const Color(0xFFEF4444).withOpacity(0.1)
            : const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isVenomous ? 'Độc' : 'Không độc',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isVenomous
              ? const Color(0xFFEF4444)
              : const Color(0xFF10B981),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

class _RiskLevelBadge extends StatelessWidget {
  const _RiskLevelBadge({required this.riskLevel});
  final double riskLevel;

  @override
  Widget build(BuildContext context) {
    final color = riskLevel >= 8
        ? const Color(0xFFEF4444)
        : riskLevel >= 5
            ? const Color(0xFFF59E0B)
            : const Color(0xFF10B981);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${riskLevel.toStringAsFixed(1)} / 10',
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

Color _confidenceColor(double confidence) {
  if (confidence >= 0.7) return const Color(0xFF10B981);
  if (confidence >= 0.5) return const Color(0xFFF59E0B);
  return const Color(0xFFEF4444);
}

String _confidenceLabel(double confidence) {
  if (confidence >= 0.7) return 'Độ tin cậy cao';
  if (confidence >= 0.5) return 'Độ tin cậy trung bình';
  return 'Độ tin cậy thấp — cần xem xét';
}

String _venomTypeLabel(String venomType) {
  switch (venomType.toLowerCase()) {
    case 'neurotoxic':
      return 'Độc thần kinh (Neurotoxic)';
    case 'hemotoxic':
      return 'Độc máu (Hemotoxic)';
    case 'cytotoxic':
      return 'Độc tế bào (Cytotoxic)';
    case 'myotoxic':
      return 'Độc cơ (Myotoxic)';
    default:
      return venomType;
  }
}
