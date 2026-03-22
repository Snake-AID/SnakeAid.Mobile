import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:snakeaid_mobile/features/auth/providers/auth_provider.dart';
import 'package:snakeaid_mobile/features/snake_catching/models/snake_species.dart' as sc;
import 'package:snakeaid_mobile/features/snake_catching/repository/snake_species_repository.dart';
import '../models/community_report.dart';
import '../repository/community_report_repository.dart';

class ReportHistoryScreen extends ConsumerStatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  ConsumerState<ReportHistoryScreen> createState() =>
      _ReportHistoryScreenState();
}

class _ReportHistoryScreenState
    extends ConsumerState<ReportHistoryScreen> {
  List<CommunityReport> _reports = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMyReports();
  }

  Future<void> _loadMyReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = ref.read(communityReportRepositoryProvider);
      final all = await repo.getReports();
      if (!mounted) return;
      final userId = ref.read(currentUserProvider)?.id;
      final fullName = ref.read(currentUserProvider)?.fullName;
      setState(() {
        _reports = (userId != null || fullName != null)
            ? all
                .where((r) =>
                    (userId != null && r.reporterId == userId) ||
                    (fullName != null && r.reporterName == fullName))
                .toList()
            : all;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteReport(CommunityReport report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa báo cáo'),
        content:
            const Text('Bạn có chắc chắn muốn xóa báo cáo này không?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFDC3545)),
              child: const Text('Xóa')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(communityReportRepositoryProvider).deleteReport(report.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Đã xóa báo cáo'),
            backgroundColor: Color(0xFF28A745)),
      );
      _loadMyReports();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: const Color(0xFFDC3545)));
    }
  }

  void _editReport(CommunityReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _EditReportSheet(report: report, onUpdated: _loadMyReports),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF228B22),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Lịch sử báo cáo của tôi',
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMyReports,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF228B22)))
          : _error != null
              ? _buildError()
              : _reports.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      color: const Color(0xFF228B22),
                      onRefresh: _loadMyReports,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _reports.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) =>
                            _buildCard(_reports[i]),
                      ),
                    ),
    );
  }

  Widget _buildCard(CommunityReport report) {
    final riskColor = _riskColor(report.resolvedRiskLevel);
    final dateStr = DateFormat('dd/MM/yyyy HH:mm')
        .format(report.createdAt.toLocal());
    final imageUrl = report.snakeSpecies?.imageUrl;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header strip
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                // Species thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              _SpeciesIconBox(color: riskColor),
                        )
                      : _SpeciesIconBox(color: riskColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.snakeDisplayName,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A))),
                      Text(dateStr,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _riskLabel(report.resolvedRiskLevel),
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: riskColor),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (report.notes.isNotEmpty)
                  Text(
                    report.notes,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF555555)),
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: Color(0xFF999999)),
                    const SizedBox(width: 4),
                    Text(
                      '${report.latitude.toStringAsFixed(4)}, '
                      '${report.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF999999)),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _editReport(report),
                      icon: const Icon(Icons.edit_outlined,
                          size: 14, color: Color(0xFF228B22)),
                      label: const Text('Sửa',
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF228B22))),
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize:
                              MaterialTapTargetSize.shrinkWrap),
                    ),
                    const SizedBox(width: 4),
                    TextButton.icon(
                      onPressed: () => _deleteReport(report),
                      icon: const Icon(Icons.delete_outline,
                          size: 14, color: Color(0xFFDC3545)),
                      label: const Text('Xóa',
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFFDC3545))),
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize:
                              MaterialTapTargetSize.shrinkWrap),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _riskColor(String level) {
    switch (level) {
      case 'Critical':
      case 'Extreme':
        return const Color(0xFFDC3545);
      case 'High':
        return const Color(0xFFF5A623);
      case 'Medium':
        return const Color(0xFFFFD700);
      default:
        return const Color(0xFF28A745);
    }
  }

  String _riskLabel(String level) {
    switch (level) {
      case 'Critical':
      case 'Extreme':
        return 'Cực nguy hiểm';
      case 'High':
        return 'Nguy hiểm';
      case 'Medium':
        return 'Trung bình';
      case 'Low':
        return 'Thấp';
      default:
        return level;
    }
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('Chưa có báo cáo nào',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500)),
          const SizedBox(height: 6),
          Text('Các báo cáo của bạn sẽ hiển thị ở đây',
              style:
                  TextStyle(fontSize: 13, color: Colors.grey.shade400)),
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
            const Icon(Icons.error_outline,
                size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 12),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF666666))),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadMyReports,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF228B22),
                  foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Edit report bottom sheet ─────────────────────────────────────────────────

class _EditReportSheet extends ConsumerStatefulWidget {
  final CommunityReport report;
  final VoidCallback onUpdated;

  const _EditReportSheet(
      {required this.report, required this.onUpdated});

  @override
  ConsumerState<_EditReportSheet> createState() =>
      _EditReportSheetState();
}

class _EditReportSheetState extends ConsumerState<_EditReportSheet> {
  late final TextEditingController _notesController;
  sc.SnakeSpecies? _selectedSpecies;
  List<sc.SnakeSpecies> _speciesList = [];
  bool _isLoadingSpecies = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _notesController =
        TextEditingController(text: widget.report.notes);
    _loadSpecies();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSpecies() async {
    try {
      final list =
          await ref.read(snakeSpeciesRepositoryProvider).getSnakeSpecies();
      if (!mounted) return;
      setState(() {
        _speciesList = list;
        _isLoadingSpecies = false;
        if (widget.report.snakeSpeciesId != null) {
          _selectedSpecies = list
              .where((s) => s.id == widget.report.snakeSpeciesId)
              .firstOrNull;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingSpecies = false);
    }
  }

  Future<void> _openSpeciesPicker() async {
    if (_isLoadingSpecies) return;
    final picked = await showModalBottomSheet<sc.SnakeSpecies>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditSpeciesPickerSheet(
        speciesList: _speciesList,
        selected: _selectedSpecies,
      ),
    );
    if (picked != null && mounted) {
      setState(() => _selectedSpecies = picked);
    }
  }

  Future<void> _save() async {
    final notes = _notesController.text.trim();
    if (notes.isEmpty) {
      setState(() => _error = 'Ghi chú không được để trống');
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await ref.read(communityReportRepositoryProvider).updateReport(
            widget.report.id,
            notes: notes,
            snakeSpeciesId: _selectedSpecies?.id,
          );
      widget.onUpdated();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Đã cập nhật báo cáo'),
              backgroundColor: Color(0xFF28A745)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isSaving = false;
      });
    }
  }

  Color _riskColor(sc.SnakeSpecies s) {
    final r = s.riskLevel;
    if (r >= 8) return const Color(0xFFB71C1C);
    if (r >= 6) return const Color(0xFFE53935);
    if (r >= 5) return const Color(0xFFF57F17);
    if (r >= 4) return const Color(0xFFF5A623);
    return const Color(0xFF28A745);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.70,
      maxChildSize: 0.92,
      minChildSize: 0.45,
      builder: (_, scroll) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8F7F5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_outlined,
                        color: Color(0xFF228B22), size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Chỉnh sửa báo cáo',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Scrollable content
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Species section ──────────────────────────────────
                  _EditSectionCard(
                    title: 'Loài rắn',
                    icon: Icons.pest_control_outlined,
                    child: _isLoadingSpecies
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(
                                  color: Color(0xFF228B22),
                                  strokeWidth: 2),
                            ),
                          )
                        : Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              if (_selectedSpecies != null) ...[
                                // Selected species card
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0FAF0),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFF228B22)
                                            .withOpacity(0.35)),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.only(
                                          topLeft: Radius.circular(11),
                                          bottomLeft:
                                              Radius.circular(11),
                                        ),
                                        child: _selectedSpecies!
                                                    .imageUrl !=
                                                null
                                            ? CachedNetworkImage(
                                                imageUrl: _selectedSpecies!
                                                    .imageUrl!,
                                                width: 64,
                                                height: 64,
                                                fit: BoxFit.cover,
                                                errorWidget: (_, __,
                                                        ___) =>
                                                    _EditSpeciesIcon(
                                                        size: 64),
                                              )
                                            : _EditSpeciesIcon(size: 64),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                _selectedSpecies!
                                                    .commonName,
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            if (_selectedSpecies!
                                                .scientificName
                                                .isNotEmpty)
                                              Text(
                                                _selectedSpecies!
                                                    .scientificName,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    fontStyle:
                                                        FontStyle.italic,
                                                    color: Color(0xFF888888)),
                                              ),
                                            const SizedBox(height: 4),
                                            Row(children: [
                                              Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 7,
                                                    vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: _riskColor(
                                                          _selectedSpecies!)
                                                      .withOpacity(0.12),
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(8),
                                                ),
                                                child: Text(
                                                  'Rủi ro: ${_selectedSpecies!.riskLevel.toStringAsFixed(1)}/10',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: _riskColor(
                                                          _selectedSpecies!),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              if (_selectedSpecies!
                                                  .isVenomous) ...[
                                                const SizedBox(width: 4),
                                                Container(
                                                  padding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 6,
                                                          vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                            0xFFDC3545)
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(8),
                                                  ),
                                                  child: const Text(
                                                    '⚠️ Độc',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Color(
                                                            0xFFDC3545),
                                                        fontWeight:
                                                            FontWeight
                                                                .bold),
                                                  ),
                                                ),
                                              ],
                                            ]),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close,
                                            size: 18,
                                            color: Color(0xFF999999)),
                                        onPressed: () => setState(
                                            () => _selectedSpecies = null),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              OutlinedButton.icon(
                                onPressed: _openSpeciesPicker,
                                icon: const Icon(Icons.search,
                                    color: Color(0xFF228B22), size: 16),
                                label: Text(
                                  _selectedSpecies == null
                                      ? 'Chọn loài rắn (tùy chọn)'
                                      : 'Thay đổi loài rắn',
                                  style: const TextStyle(
                                      color: Color(0xFF228B22),
                                      fontSize: 13),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color(0xFF228B22)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 14),
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 12),

                  // ── Notes section ────────────────────────────────────
                  _EditSectionCard(
                    title: 'Ghi chú *',
                    icon: Icons.notes_outlined,
                    child: TextFormField(
                      controller: _notesController,
                      maxLines: 4,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText:
                            'Mô tả tình huống, hành vi của rắn...',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 13),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF228B22)),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Error ────────────────────────────────────────────
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: const Color(0xFFEF9A9A)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Color(0xFFDC3545), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_error!,
                                style: const TextStyle(
                                    color: Color(0xFFDC3545),
                                    fontSize: 12)),
                          ),
                        ],
                      ),
                    ),

                  // ── Save button ──────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        _isSaving ? 'Đang lưu...' : 'Lưu thay đổi',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Edit screen section card ──────────────────────────────────────────────────

class _EditSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _EditSectionCard(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20).withOpacity(0.08),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, size: 14, color: const Color(0xFF1B5E20)),
            ),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333))),
          ]),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ── Placeholder icon for edit sheet ──────────────────────────────────────────

class _EditSpeciesIcon extends StatelessWidget {
  final double size;
  const _EditSpeciesIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFFE8F5E9),
      child: const Icon(Icons.pest_control,
          color: Color(0xFF228B22), size: 28),
    );
  }
}

// ── Species picker sheet for edit ────────────────────────────────────────────

class _EditSpeciesPickerSheet extends StatefulWidget {
  final List<sc.SnakeSpecies> speciesList;
  final sc.SnakeSpecies? selected;

  const _EditSpeciesPickerSheet(
      {required this.speciesList, this.selected});

  @override
  State<_EditSpeciesPickerSheet> createState() =>
      _EditSpeciesPickerSheetState();
}

class _EditSpeciesPickerSheetState
    extends State<_EditSpeciesPickerSheet> {
  final _searchCtrl = TextEditingController();
  List<sc.SnakeSpecies> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.speciesList;
    _searchCtrl.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.speciesList
          : widget.speciesList
              .where((s) =>
                  s.commonName.toLowerCase().contains(q) ||
                  s.scientificName.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _riskColor(sc.SnakeSpecies s) {
    final r = s.riskLevel;
    if (r >= 8) return const Color(0xFFB71C1C);
    if (r >= 6) return const Color(0xFFE53935);
    if (r >= 5) return const Color(0xFFF57F17);
    if (r >= 4) return const Color(0xFFF5A623);
    return const Color(0xFF28A745);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.96,
      minChildSize: 0.5,
      builder: (_, scroll) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8F7F5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Chọn loài rắn',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm loài rắn...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(
                      child: Text('Không tìm thấy loài rắn nào',
                          style: TextStyle(color: Color(0xFF888888))))
                  : GridView.builder(
                      controller: scroll,
                      padding:
                          const EdgeInsets.fromLTRB(12, 0, 12, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final s = _filtered[i];
                        final isSelected =
                            widget.selected?.id == s.id;
                        final riskC = _riskColor(s);
                        return GestureDetector(
                          onTap: () =>
                              Navigator.of(context).pop(s),
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF228B22)
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? const Color(0xFF228B22)
                                          .withOpacity(0.18)
                                      : Colors.black
                                          .withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius:
                                        const BorderRadius.vertical(
                                            top: Radius.circular(12)),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        s.imageUrl != null
                                            ? CachedNetworkImage(
                                                imageUrl: s.imageUrl!,
                                                fit: BoxFit.cover,
                                                errorWidget: (_, __,
                                                        ___) =>
                                                    const ColoredBox(
                                                  color:
                                                      Color(0xFFE8F5E9),
                                                  child: Icon(
                                                      Icons
                                                          .pest_control,
                                                      color: Color(
                                                          0xFF228B22)),
                                                ),
                                              )
                                            : const ColoredBox(
                                                color: Color(0xFFE8F5E9),
                                                child: Icon(
                                                    Icons.pest_control,
                                                    color: Color(
                                                        0xFF228B22)),
                                              ),
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: riskC,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 1.5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      6, 5, 6, 6),
                                  child: Text(
                                    s.commonName,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? const Color(0xFF1B5E20)
                                          : const Color(0xFF1A1A1A),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
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
  }
}

// ── Species icon fallback for cards ──────────────────────────────────────────

class _SpeciesIconBox extends StatelessWidget {
  final Color color;
  const _SpeciesIconBox({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.pest_control, color: color, size: 22),
    );
  }
}
