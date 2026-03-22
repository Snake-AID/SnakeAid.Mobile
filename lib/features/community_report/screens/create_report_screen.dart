import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snakeaid_mobile/features/snake_catching/models/snake_species.dart' as sc;
import 'package:snakeaid_mobile/features/snake_catching/repository/snake_species_repository.dart';
import 'package:snakeaid_mobile/features/snake_catching/widgets/location_picker_dialog.dart';
import 'package:snakeaid_mobile/features/emergency/repository/snake_ai_repository.dart';
import 'package:snakeaid_mobile/features/emergency/models/snake_detection_response.dart';
import '../repository/community_report_repository.dart';

class CreateReportScreen extends ConsumerStatefulWidget {
  /// Called after a report is successfully created so the caller can refresh.
  final VoidCallback? onReportCreated;

  const CreateReportScreen({super.key, this.onReportCreated});

  @override
  ConsumerState<CreateReportScreen> createState() =>
      _CreateReportScreenState();
}

class _CreateReportScreenState extends ConsumerState<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  LocationResult? _selectedLocation;
  sc.SnakeSpecies? _selectedSpecies;
  List<sc.SnakeSpecies> _speciesList = [];
  bool _isLoadingSpecies = true;
  bool _isSubmitting = false;
  bool _isAiDetecting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _loadSpecies();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSpecies() async {
    try {
      final repo = ref.read(snakeSpeciesRepositoryProvider);
      final list = await repo.getSnakeSpecies();
      if (!mounted) return;
      setState(() {
        _speciesList = list;
        _isLoadingSpecies = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingSpecies = false);
    }
  }

  Future<void> _pickLocation() async {
    final result = await showDialog<LocationResult>(
      context: context,
      builder: (_) => const LocationPickerDialog(),
    );
    if (result != null && mounted) {
      setState(() => _selectedLocation = result);
    }
  }

  Future<void> _openSpeciesPicker() async {
    if (_isLoadingSpecies) return;
    final picked = await showModalBottomSheet<sc.SnakeSpecies>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SpeciesPickerSheet(
        speciesList: _speciesList,
        selected: _selectedSpecies,
      ),
    );
    if (picked != null && mounted) {
      setState(() => _selectedSpecies = picked);
    }
  }

  void _clearSpecies() => setState(() => _selectedSpecies = null);

  Future<void> _pickAndDetect(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final xFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1280,
      );
      if (xFile == null || !mounted) return;

      setState(() => _isAiDetecting = true);

      final aiRepo = ref.read(snakeAiRepositoryProvider);
      final imageFile = File(xFile.path);

      final uploadResponse =
          await aiRepo.uploadImageForCommunityDetection(imageFile: imageFile);
      if (!mounted) return;

      final mediaId = uploadResponse.data?.id;
      if (mediaId == null || mediaId.isEmpty) {
        setState(() => _isAiDetecting = false);
        _showAiError('Không thể tải ảnh lên máy chủ');
        return;
      }

      final detectionResponse =
          await aiRepo.detectSnake(reportMediaId: mediaId);
      if (!mounted) return;

      setState(() => _isAiDetecting = false);

      if (!detectionResponse.isSuccess ||
          detectionResponse.data == null ||
          detectionResponse.data!.results.isEmpty) {
        _showAiError('Không phát hiện được loài rắn trong ảnh này');
        return;
      }

      final results = List<DetectionResult>.from(detectionResponse.data!.results)
        ..sort((a, b) =>
            b.aiDetection.confidence.compareTo(a.aiDetection.confidence));

      if (!mounted) return;
      final picked = await showModalBottomSheet<sc.SnakeSpecies>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _AiDetectionResultSheet(
          results: results,
          speciesList: _speciesList,
          imagePath: xFile.path,
        ),
      );
      if (picked != null && mounted) {
        setState(() => _selectedSpecies = picked);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAiDetecting = false);
      _showAiError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _showAiError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFDC3545),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      setState(() =>
          _submitError = 'Vui lòng chọn vị trí phát hiện rắn');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      final repo = ref.read(communityReportRepositoryProvider);
      await repo.createReport(
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        notes: _notesController.text.trim(),
        snakeSpeciesId: _selectedSpecies?.id,
      );
      widget.onReportCreated?.call();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ReportSuccessScreen(
              speciesName: _selectedSpecies?.commonName,
              speciesImageUrl: _selectedSpecies?.imageUrl,
            ),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitError = e.toString().replaceAll('Exception: ', '');
        _isSubmitting = false;
      });
    }
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
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Báo cáo phát hiện rắn',
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Location ──────────────────────────────────────────────────
            _SectionCard(
              title: 'Vị trí phát hiện *',
              icon: Icons.location_on_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedLocation != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF228B22).withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Color(0xFF228B22), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedLocation!.fullAddress,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF1A5C1A)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: _pickLocation,
                    icon: const Icon(Icons.map_outlined,
                        color: Color(0xFF228B22)),
                    label: Text(
                      _selectedLocation == null
                          ? 'Chọn vị trí trên bản đồ'
                          : 'Thay đổi vị trí',
                      style: const TextStyle(color: Color(0xFF228B22)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF228B22)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Snake species ─────────────────────────────────────────────
            _SectionCard(
              title: 'Loài rắn',
              icon: Icons.pest_control_outlined,
              child: _isLoadingSpecies
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                            color: Color(0xFF228B22), strokeWidth: 2),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── AI detect row ──────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B5E20).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF228B22).withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.auto_awesome,
                                      size: 13, color: Color(0xFF228B22)),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'Nhận diện bằng AI',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF228B22),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (_isAiDetecting)
                                const Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              color: Color(0xFF228B22),
                                              strokeWidth: 2),
                                        ),
                                        SizedBox(width: 10),
                                        Text('Đang phân tích ảnh...',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF228B22))),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                Row(
                                  children: [
                                    Expanded(
                                      child: _AiButton(
                                        icon: Icons.camera_alt_outlined,
                                        label: 'Chụp ảnh',
                                        onTap: () => _pickAndDetect(
                                            ImageSource.camera),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _AiButton(
                                        icon: Icons.photo_library_outlined,
                                        label: 'Thư viện',
                                        onTap: () => _pickAndDetect(
                                            ImageSource.gallery),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // ── Manual picker or selected card ─────────────
                        if (_selectedSpecies == null)
                          OutlinedButton.icon(
                            onPressed: _openSpeciesPicker,
                            icon: const Icon(Icons.search,
                                color: Color(0xFF228B22), size: 18),
                            label: const Text(
                              'Chọn loài rắn thủ công (tùy chọn)',
                              style: TextStyle(color: Color(0xFF228B22)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xFF228B22)),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 14),
                            ),
                          )
                        else
                          _SelectedSpeciesCard(
                            species: _selectedSpecies!,
                            onTap: _openSpeciesPicker,
                            onClear: _clearSpecies,
                          ),
                      ],
                    ),
            ),

            const SizedBox(height: 12),

            // ── Notes ─────────────────────────────────────────────────────
            _SectionCard(
              title: 'Ghi chú *',
              icon: Icons.notes_outlined,
              child: TextFormField(
                controller: _notesController,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText:
                      'Mô tả tình huống, hành vi của rắn, nơi ẩn nấp...',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFF228B22)),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Vui lòng nhập ghi chú';
                  }
                  return null;
                },
              ),
            ),

            const SizedBox(height: 16),

            // ── Error ─────────────────────────────────────────────────────
            if (_submitError != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEF9A9A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Color(0xFFDC3545), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _submitError!,
                        style: const TextStyle(
                            color: Color(0xFFDC3545), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Submit ────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF228B22),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _isSubmitting ? 'Đang gửi...' : 'Gửi báo cáo',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard(
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
              offset: const Offset(0, 2))
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

// ── Selected species preview card ────────────────────────────────────────────

class _SelectedSpeciesCard extends StatelessWidget {
  final sc.SnakeSpecies species;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _SelectedSpeciesCard({
    required this.species,
    required this.onTap,
    required this.onClear,
  });

  Color get _riskColor {
    final r = species.riskLevel;
    if (r >= 8) return const Color(0xFFB71C1C);
    if (r >= 6) return const Color(0xFFE53935);
    if (r >= 5) return const Color(0xFFF57F17);
    if (r >= 4) return const Color(0xFFF5A623);
    return const Color(0xFF28A745);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0FAF0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF228B22).withOpacity(0.4)),
        ),
        child: Row(
          children: [
            // Photo
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                bottomLeft: Radius.circular(11),
              ),
              child: species.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: species.imageUrl!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          _PlaceholderIcon(size: 72),
                    )
                  : _PlaceholderIcon(size: 72),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(species.commonName,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A))),
                  if (species.scientificName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(species.scientificName,
                        style: const TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF888888))),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: _riskColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _riskColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          'Rủi ro: ${species.riskLevel.toStringAsFixed(1)}/10',
                          style: TextStyle(
                              fontSize: 10,
                              color: _riskColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (species.isVenomous) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC3545).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '⚠️ Độc',
                            style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFFDC3545),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Clear
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close, size: 18, color: Color(0xFF999999)),
              tooltip: 'Bỏ chọn',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Placeholder icon for missing image ───────────────────────────────────────

class _PlaceholderIcon extends StatelessWidget {
  final double size;
  const _PlaceholderIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFFE8F5E9),
      child: const Icon(Icons.pest_control,
          color: Color(0xFF228B22), size: 30),
    );
  }
}

// ── Species picker bottom sheet ───────────────────────────────────────────────

class _SpeciesPickerSheet extends StatefulWidget {
  final List<sc.SnakeSpecies> speciesList;
  final sc.SnakeSpecies? selected;

  const _SpeciesPickerSheet({required this.speciesList, this.selected});

  @override
  State<_SpeciesPickerSheet> createState() => _SpeciesPickerSheetState();
}

class _SpeciesPickerSheetState extends State<_SpeciesPickerSheet> {
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
            // Handle
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
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Chọn loài rắn',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // Search field
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            // Grid
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(
                      child: Text('Không tìm thấy loài rắn nào',
                          style: TextStyle(color: Color(0xFF888888))),
                    )
                  : GridView.builder(
                      controller: scroll,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, i) {
                        final s = _filtered[i];
                        return _SpeciesGridItem(
                          species: s,
                          isSelected: widget.selected?.id == s.id,
                          onTap: () => Navigator.of(context).pop(s),
                          onLongPress: () =>
                              _showDetail(context, s),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, sc.SnakeSpecies s) {
    showDialog(
      context: context,
      builder: (_) => _SpeciesDetailDialog(species: s),
    );
  }
}

// ── Grid item ────────────────────────────────────────────────────────────────

class _SpeciesGridItem extends StatelessWidget {
  final sc.SnakeSpecies species;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _SpeciesGridItem({
    required this.species,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  Color get _riskColor {
    final r = species.riskLevel;
    if (r >= 8) return const Color(0xFFB71C1C);
    if (r >= 6) return const Color(0xFFE53935);
    if (r >= 5) return const Color(0xFFF57F17);
    if (r >= 4) return const Color(0xFFF5A623);
    return const Color(0xFF28A745);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF228B22) : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF228B22).withOpacity(0.18)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    species.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: species.imageUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                const ColoredBox(
                              color: Color(0xFFE8F5E9),
                              child: Icon(Icons.pest_control,
                                  color: Color(0xFF228B22)),
                            ),
                          )
                        : const ColoredBox(
                            color: Color(0xFFE8F5E9),
                            child: Icon(Icons.pest_control,
                                color: Color(0xFF228B22)),
                          ),
                    // risk dot
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _riskColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                    // long-press hint
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.info_outline,
                            color: Colors.white, size: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Name
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 5, 6, 6),
              child: Text(
                species.commonName,
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
  }
}

// ── Species detail dialog (long-press) ───────────────────────────────────────

class _SpeciesDetailDialog extends StatelessWidget {
  final sc.SnakeSpecies species;

  const _SpeciesDetailDialog({required this.species});

  Color get _riskColor {
    final r = species.riskLevel;
    if (r >= 8) return const Color(0xFFB71C1C);
    if (r >= 6) return const Color(0xFFE53935);
    if (r >= 5) return const Color(0xFFF57F17);
    if (r >= 4) return const Color(0xFFF5A623);
    return const Color(0xFF28A745);
  }

  String get _riskLabel {
    final r = species.riskLevel;
    if (r >= 9) return 'Cực kỳ nguy hiểm';
    if (r >= 7) return 'Nguy hiểm rất cao';
    if (r >= 5) return 'Nguy hiểm cao';
    if (r >= 3) return 'Trung bình';
    return 'Thấp';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.hardEdge,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo header
            if (species.imageUrl != null)
              CachedNetworkImage(
                imageUrl: species.imageUrl!,
                height: 180,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  height: 100,
                  color: const Color(0xFFE8F5E9),
                  child: const Icon(Icons.pest_control,
                      color: Color(0xFF228B22), size: 40),
                ),
              )
            else
              Container(
                height: 100,
                color: const Color(0xFFE8F5E9),
                child: const Icon(Icons.pest_control,
                    color: Color(0xFF228B22), size: 40),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Names + close row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(species.commonName,
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold)),
                            if (species.scientificName.isNotEmpty)
                              Text(
                                species.scientificName,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF888888)),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Badges row
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      // Risk badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _riskColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: _riskColor.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: _riskColor, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              '$_riskLabel (${species.riskLevel.toStringAsFixed(1)}/10)',
                              style: TextStyle(
                                  color: _riskColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      // Venomous badge
                      if (species.isVenomous)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC3545).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFDC3545)
                                    .withOpacity(0.4)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.dangerous,
                                  color: Color(0xFFDC3545), size: 12),
                              SizedBox(width: 4),
                              Text('Có nọc độc',
                                  style: TextStyle(
                                      color: Color(0xFFDC3545),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      // Venom type
                      if (species.primaryVenomType != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.purple.withOpacity(0.3)),
                          ),
                          child: Text(
                            species.primaryVenomType!,
                            style: const TextStyle(
                                color: Colors.purple,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),

                  // Description
                  if (species.description != null) ...[
                    const SizedBox(height: 12),
                    const Text('Mô tả',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF555555))),
                    const SizedBox(height: 4),
                    Text(species.description!,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF333333),
                            height: 1.5)),
                  ],

                  // Identification summary
                  if (species.identificationSummary != null) ...[
                    const SizedBox(height: 12),
                    const Text('Nhận dạng',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF555555))),
                    const SizedBox(height: 4),
                    Text(species.identificationSummary!,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF333333),
                            height: 1.5)),
                  ],

                  // Physical traits
                  if (species.identification?.physicalTraits.isNotEmpty ==
                      true) ...[
                    const SizedBox(height: 12),
                    _DetailSubHeader(
                        icon: Icons.visibility_outlined,
                        label: 'Đặc điểm hình thái'),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: species.identification!.physicalTraits
                          .map((t) => _InfoChip(text: t))
                          .toList(),
                    ),
                  ],

                  // Behaviors
                  if (species.identification?.behaviors.isNotEmpty ==
                      true) ...[
                    const SizedBox(height: 12),
                    _DetailSubHeader(
                        icon: Icons.psychology_outlined,
                        label: 'Hành vi'),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: species.identification!.behaviors
                          .map((b) => _InfoChip(text: b))
                          .toList(),
                    ),
                  ],

                  // Habitat
                  if ((species.identification?.habitat ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _DetailSubHeader(
                        icon: Icons.forest_outlined, label: 'Môi trường sống'),
                    const SizedBox(height: 4),
                    Text(
                      species.identification!.habitat,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF333333),
                          height: 1.5),
                    ),
                  ],

                  // Symptoms (first time-range entry as a preview)
                  if (species.symptomsByTime?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    _DetailSubHeader(
                        icon: Icons.medical_services_outlined,
                        label: 'Triệu chứng sau khi bị cắn'),
                    const SizedBox(height: 6),
                    ...species.symptomsByTime!
                        .take(2)
                        .map((s) => _SymptomRow(symptom: s)),
                  ],

                  const SizedBox(height: 16),

                  // Select button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Đóng',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Detail sub-header ─────────────────────────────────────────────────────────

class _DetailSubHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DetailSubHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF555555)),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF555555))),
      ],
    );
  }
}

// ── Info chip ─────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final String text;
  const _InfoChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF228B22).withOpacity(0.25)),
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 11, color: Color(0xFF1A5C1A))),
    );
  }
}

// ── Symptom row ───────────────────────────────────────────────────────────────

class _SymptomRow extends StatelessWidget {
  final sc.SymptomByTime symptom;
  const _SymptomRow({required this.symptom});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: symptom.isCritical
            ? const Color(0xFFFFEBEE)
            : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: symptom.isCritical
              ? const Color(0xFFEF9A9A)
              : const Color(0xFFFFD54F),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                symptom.isCritical
                    ? Icons.warning_amber_rounded
                    : Icons.schedule,
                size: 12,
                color: symptom.isCritical
                    ? const Color(0xFFDC3545)
                    : const Color(0xFFF57F17),
              ),
              const SizedBox(width: 4),
              Text(
                symptom.timeRange,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: symptom.isCritical
                      ? const Color(0xFFDC3545)
                      : const Color(0xFFF57F17),
                ),
              ),
            ],
          ),
          if (symptom.signs.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...symptom.signs.map((s) => Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(
                              fontSize: 11, color: Color(0xFF555555))),
                      Expanded(
                        child: Text(s,
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF333333))),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

// ── AI detect button ──────────────────────────────────────────────────────────

class _AiButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _AiButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF228B22),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── AI detection result sheet ─────────────────────────────────────────────────

class _AiDetectionResultSheet extends StatelessWidget {
  final List<DetectionResult> results;
  final List<sc.SnakeSpecies> speciesList;
  final String imagePath;

  const _AiDetectionResultSheet({
    required this.results,
    required this.speciesList,
    required this.imagePath,
  });

  sc.SnakeSpecies? _matchSpecies(SnakeInfo info) {
    // Match by id first, then by commonName
    final byId = speciesList.where((s) => s.id == info.id).firstOrNull;
    if (byId != null) return byId;
    final byName = speciesList
        .where((s) =>
            s.commonName.toLowerCase() == info.commonName.toLowerCase())
        .firstOrNull;
    return byName;
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
            // Handle
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
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome,
                      color: Color(0xFF228B22), size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Kết quả nhận diện AI',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // Captured photo preview
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(imagePath),
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Text(
                'Chạm vào kết quả để chọn loài rắn cho báo cáo',
                style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
              ),
            ),
            // Results list
            Expanded(
              child: ListView.separated(
                controller: scroll,
                padding:
                    const EdgeInsets.fromLTRB(16, 0, 16, 24),
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: results.length,
                itemBuilder: (_, i) {
                  final r = results[i];
                  final matched = _matchSpecies(r.snake);
                  final pct =
                      (r.aiDetection.confidence * 100).toStringAsFixed(1);
                  final isTop = i == 0;
                  return GestureDetector(
                    onTap: matched != null
                        ? () => Navigator.of(context).pop(matched)
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: isTop
                            ? Border.all(
                                color: const Color(0xFF228B22), width: 2)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Snake photo
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            child: r.snake.imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: r.snake.imageUrl,
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) =>
                                        _PlaceholderIcon(size: 72),
                                  )
                                : _PlaceholderIcon(size: 72),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 4),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          r.snake.commonName,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      if (isTop)
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF228B22),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'Tốt nhất',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight:
                                                    FontWeight.bold),
                                          ),
                                        ),
                                    ],
                                  ),
                                  Text(
                                    r.snake.scientificName,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                        color: Color(0xFF888888)),
                                  ),
                                  const SizedBox(height: 6),
                                  // Confidence bar
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value:
                                                r.aiDetection.confidence,
                                            backgroundColor:
                                                Colors.grey.shade200,
                                            color: isTop
                                                ? const Color(0xFF228B22)
                                                : const Color(0xFF66BB6A),
                                            minHeight: 5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$pct%',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isTop
                                              ? const Color(0xFF228B22)
                                              : const Color(0xFF555555),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (matched == null)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Không tìm thấy trong danh sách',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF999999)),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right,
                            color: matched != null
                                ? const Color(0xFF228B22)
                                : Colors.grey.shade300,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
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

// ── Thank-you screen shown after successful report submission ─────────────────

class ReportSuccessScreen extends StatefulWidget {
  final String? speciesName;
  final String? speciesImageUrl;

  const ReportSuccessScreen({
    super.key,
    this.speciesName,
    this.speciesImageUrl,
  });

  @override
  State<ReportSuccessScreen> createState() => _ReportSuccessScreenState();
}

class _ReportSuccessScreenState extends State<ReportSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Animated check circle ────────────────────────────────
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF228B22).withOpacity(0.10),
                    border: Border.all(
                        color: const Color(0xFF228B22).withOpacity(0.30),
                        width: 2),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF228B22),
                    size: 64,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Headline ─────────────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: const Text(
                  'Cảm ơn bạn!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 12),

              FadeTransition(
                opacity: _fadeAnim,
                child: const Text(
                  'Báo cáo của bạn đã được ghi nhận.\nMỗi thông tin bạn chia sẻ giúp cộng đồng phòng tránh nguy hiểm từ rắn hiệu quả hơn.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF555555),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // ── Species card (optional) ───────────────────────────────
              if (widget.speciesName != null) ...[
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: widget.speciesImageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: widget.speciesImageUrl!,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) =>
                                      _SuccessSpeciesIcon(),
                                )
                              : _SuccessSpeciesIcon(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Loài rắn đã báo cáo',
                                style: TextStyle(
                                    fontSize: 11, color: Color(0xFF888888)),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                widget.speciesName!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.pest_control,
                            color: Color(0xFF228B22), size: 22),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // ── Contribution banner ───────────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.people_alt_outlined,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Bạn đã đóng góp vào bản đồ cảnh báo rắn cộng đồng SnakeAid!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // ── Primary action ────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF228B22),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Về trang chủ',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessSpeciesIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.pest_control,
          color: Color(0xFF228B22), size: 28),
    );
  }
}

