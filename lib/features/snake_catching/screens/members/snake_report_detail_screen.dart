import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../models/snake_species.dart';
import '../../models/snake_catching_request.dart';
import '../../providers/snake_location_provider.dart'
    hide snakeSpeciesRepositoryProvider;
import '../../repository/snake_species_repository.dart';
import '../../repository/snake_catching_repository.dart';
import '../../widgets/location_picker_dialog.dart';
import '../../widgets/pricing_bottom_sheet.dart';
import '../../../emergency/models/snake_detection_response.dart';

/// Screen for members to submit detailed snake report with photos
class SnakeReportDetailScreen extends ConsumerStatefulWidget {
  final String quantity; // 'single', 'few', 'many'

  const SnakeReportDetailScreen({super.key, required this.quantity});

  @override
  ConsumerState<SnakeReportDetailScreen> createState() =>
      _SnakeReportDetailScreenState();
}

class _SnakeReportDetailScreenState
    extends ConsumerState<SnakeReportDetailScreen> {
  bool _isPhotoTab = true; // true = Chụp Ảnh, false = Chọn Loài Rắn

  // Photo slots: slot 1 = main (required), 2-5 = additional
  // 'single'/'many': max 3   |   'few': max 5
  final Map<int, File> _photos = {};

  final _addressDetailController =
      TextEditingController(); // Ghi chú địa chỉ chi tiết
  final _specificLocationController = TextEditingController();
  final _behaviorController = TextEditingController();
  final _searchController = TextEditingController();
  String? _selectedSize;
  bool _isSubmitting = false;

  // Location state
  String? _selectedAddress;
  double? _selectedLatitude;
  double? _selectedLongitude;

  // Snake species state (for single snake)
  List<SnakeSpecies> _allSpecies = [];
  List<SnakeSpecies> _filteredSpecies = [];
  SnakeSpecies? _selectedSpecies;
  bool _isLoadingSpecies = false;
  String? _speciesError;
  bool _showLocationFiltered = false;

  // Multi-species state (for few/many snakes)
  // Map<SnakeSpecies, int> - species to quantity mapping
  Map<SnakeSpecies, int> _selectedSpeciesMap = {};

  // AI detection state (per photo slot: 1=main, 2, 3)
  final Map<int, String> _mediaIds = {};
  final Map<int, DetectionResult?> _detectionResults = {};
  final Map<int, bool> _isAnalyzingSlot = {};

  // AI card carousel
  final PageController _aiCardPageController = PageController();
  int _aiCardPage = 0;

  // Per-species quantity for photo-tab: snakeId -> count (only for few/many)
  final Map<int, int> _speciesQuantityMap = {};

  // Quantity for single-mode (how many individuals of this 1 species)
  int _singleQuantity = 1;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Load species on first build through ref
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSnakeSpecies();
    });
    _searchController.addListener(_onSearchChanged);
    _addressDetailController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _addressDetailController.dispose();
    _specificLocationController.dispose();
    _behaviorController.dispose();
    _searchController.dispose();
    _aiCardPageController.dispose();
    super.dispose();
  }

  Future<void> _loadSnakeSpecies() async {
    setState(() {
      _isLoadingSpecies = true;
      _speciesError = null;
    });

    try {
      final repository = ref.read(snakeSpeciesRepositoryProvider);
      final species = await repository.getSnakeSpecies();
      if (mounted) {
        setState(() {
          _allSpecies = species;
          _filteredSpecies = species;
          _isLoadingSpecies = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _speciesError = e.toString();
          _isLoadingSpecies = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    setState(
      () {},
    ); // triggers rebuild; displaySpecies computed inline in _buildSpeciesTab
  }

  String get _titleText {
    switch (widget.quantity) {
      case 'single':
        return 'Báo Cáo: 1 Loài Rắn';
      case 'few':
        return 'Báo Cáo: 2-5 Loài Rắn';
      case 'many':
        return 'Báo Cáo: Ổ Rắn';
      default:
        return 'Báo Cáo Phát Hiện Rắn';
    }
  }

  String get _photoSectionTitle {
    switch (widget.quantity) {
      case 'single':
        return 'Chụp ảnh loài rắn (1-3 góc độ)';
      case 'few':
        return 'Chụp ảnh các loài rắn (1-3 ảnh)';
      case 'many':
        return 'Chụp ảnh khu vực ổ rắn (1-3 ảnh)';
      default:
        return 'Chụp ảnh (1-3 góc độ)';
    }
  }

  bool get _canSubmit {
    // Must have location
    if (_selectedAddress == null ||
        _selectedLatitude == null ||
        _selectedLongitude == null) {
      return false;
    }

    // Must have address detail (BE does not allow null)
    if (_addressDetailController.text.trim().isEmpty) {
      return false;
    }

    // Can submit if either:
    // 1. Photo tab: has main photo
    // 2. Species tab:
    //    - For single: has selected species
    //    - For few/many: has at least one species in map
    if (_isPhotoTab) {
      if (!_photos.containsKey(1)) return false;
      // Block while upload/AI detection is still running — mediaIds not ready yet
      if (_isAnalyzingSlot.values.any((analyzing) => analyzing == true))
        return false;
      // We no longer block if AI fails to detect, just warn on submit.
      return true;
    } else {
      if (widget.quantity == 'single') {
        return _selectedSpecies != null;
      } else {
        return _selectedSpeciesMap.isNotEmpty;
      }
    }
  }

  void _clearSlot(int slot) {
    setState(() {
      _photos.remove(slot);
      _detectionResults.remove(slot);
      _mediaIds.remove(slot);
      _isAnalyzingSlot.remove(slot);
      // Prune species no longer detected in any remaining slot
      final remainingIds = _detectionResults.values
          .whereType<DetectionResult>()
          .map((r) => r.snake.id)
          .toSet();
      _speciesQuantityMap.removeWhere((id, _) => !remainingIds.contains(id));
    });
  }

  Future<void> _pickImage(int slot) async {
    // Show source picker
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Chọn nguồn ảnh',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSourceOption(
                      icon: Icons.camera_alt,
                      label: 'Chụp ảnh',
                      color: const Color(0xFF228B22),
                      onTap: () => Navigator.pop(context, ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSourceOption(
                      icon: Icons.photo_library,
                      label: 'Album ảnh',
                      color: const Color(0xFF1565C0),
                      onTap: () => Navigator.pop(context, ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (image != null) {
        final file = File(image.path);
        setState(() {
          _photos[slot] = file;
          // Reset detection state for this slot
          _detectionResults.remove(slot);
          _mediaIds.remove(slot);
          _isAnalyzingSlot[slot] = true;
          // Prune species no longer detected in any remaining slot
          final remainingIds = _detectionResults.values
              .whereType<DetectionResult>()
              .map((r) => r.snake.id)
              .toSet();
          _speciesQuantityMap.removeWhere(
            (id, _) => !remainingIds.contains(id),
          );
        });
        // Upload + AI detection in background (non-blocking)
        _uploadAndDetect(slot, file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
      }
    }
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadAndDetect(int slot, File imageFile) async {
    try {
      final repository = ref.read(snakeCatchingRepositoryProvider);

      // Step 1: Upload image to media service
      final uploadResponse = await repository.uploadSnakeReportImage(imageFile);
      if (!uploadResponse.isSuccess || uploadResponse.data == null) {
        if (mounted) setState(() => _isAnalyzingSlot[slot] = false);
        return;
      }
      final mediaId = uploadResponse.data!.id;
      if (mounted) setState(() => _mediaIds[slot] = mediaId);

      // Step 2: AI snake detection
      final detectResponse = await repository.detectSnakeFromMedia(mediaId);
      if (mounted) {
        setState(() {
          _isAnalyzingSlot[slot] = false;
          if (detectResponse.isSuccess &&
              detectResponse.data != null &&
              detectResponse.data!.results.isNotEmpty) {
            final detected = detectResponse.data!.results.first;
            _detectionResults[slot] = detected;
            // Register this species with default quantity=1 if not already set
            _speciesQuantityMap.putIfAbsent(detected.snake.id, () => 1);
          }
        });
      }
    } catch (e) {
      // Detection failure is non-blocking — user can still submit without AI result
      if (mounted) setState(() => _isAnalyzingSlot[slot] = false);
    }
  }

  Future<void> _openLocationPicker() async {
    final result = await showDialog<LocationResult>(
      context: context,
      builder: (context) =>
          LocationPickerDialog(initialLocation: _selectedAddress),
    );

    if (result != null) {
      setState(() {
        _selectedAddress = result.getFullAddress();
        _selectedLatitude = result.latitude;
        _selectedLongitude = result.longitude;
        _showLocationFiltered = true;
      });
      ref
          .read(snakeLocationProvider.notifier)
          .fetchSnakesByLocation(
            latitude: result.latitude,
            longitude: result.longitude,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _titleText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black87),
            onPressed: () {
              _showInfoDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented Control
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5E5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isPhotoTab = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _isPhotoTab
                                  ? const Color(0xFF228B22)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Chụp Ảnh',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _isPhotoTab
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isPhotoTab = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_isPhotoTab
                                  ? const Color(0xFF228B22)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Chọn Loài Rắn',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: !_isPhotoTab
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chọn cách bạn muốn báo cáo',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Content
          Expanded(
            child: _isPhotoTab
                ? SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildPhotoTab(),
                  )
                : _buildSpeciesTab(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nút Tham khảo giá
              GestureDetector(
                onTap: _showPricingBottomSheet,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.blue[700]),
                      const SizedBox(width: 6),
                      Text(
                        'Tham khảo bảng giá dịch vụ bắt rắn',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: (_canSubmit && !_isSubmitting)
                      ? _handleSubmit
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF228B22),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[500],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: _canSubmit ? 4 : 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isSubmitting)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      else if (_isPhotoTab &&
                          _isAnalyzingSlot.values.any((v) => v == true))
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Đang tải ảnh...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          'Gửi Báo Cáo',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (!_isSubmitting &&
                          !(_isPhotoTab &&
                              _isAnalyzingSlot.values.any((v) => v == true)))
                        const SizedBox(width: 8),
                      if (!_isSubmitting &&
                          !(_isPhotoTab &&
                              _isAnalyzingSlot.values.any((v) => v == true)))
                        const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Builder(
                    builder: (_) {
                      // Contextual hint below submit button
                      final isAnalyzing =
                          _isPhotoTab &&
                          _isAnalyzingSlot.values.any((v) => v == true);
                      final hasPhoto = _photos.containsKey(1);
                      final hasDetection = _detectionResults.values.any(
                        (r) => r != null,
                      );
                      final showNoDetectionHint =
                          _isPhotoTab &&
                          hasPhoto &&
                          !isAnalyzing &&
                          !hasDetection;

                      if (showNoDetectionHint) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 18,
                                color: Colors.orange[700],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'AI không nhận diện được — hãy chọn loài thủ công\nhoặc chụp lại để nhận diện rắn rõ hơn',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.smart_toy,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isPhotoTab
                                ? 'AI sẽ phân tích loài rắn'
                                : 'Thông tin giúp cứu hộ nhanh hơn',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoTab() {
    final isSingle = widget.quantity == 'single';
    final isMany = widget.quantity == 'many';
    final isFew = widget.quantity == 'few';
    final isMultiple = !isSingle;
    final int maxSlots = isFew ? 5 : 3;

    // Compute how many slots to render:
    // last filled slot + 1 (shows one empty "add" placeholder), min 3, capped at maxSlots.
    // For single/many always 3 fixed.
    final int lastFilled = [
      1,
      2,
      3,
      4,
      5,
    ].lastWhere((s) => _photos.containsKey(s), orElse: () => 0);
    final int actualVisible = isFew ? (lastFilled + 1).clamp(3, maxSlots) : 3;

    // Slot label helpers
    String slotLabel(int slot) {
      if (slot == 1) {
        return isSingle
            ? 'Ảnh rắn (bắt buộc)'
            : isMany
            ? 'Ảnh khu vực (bắt buộc)'
            : 'Ảnh tổng quát (bắt buộc)';
      }
      if (isSingle) {
        return slot == 2 ? 'Góc khác\n(khuyến nghị)' : 'Góc phụ\n(tùy chọn)';
      }
      if (isMany) {
        return slot == 2 ? 'Góc rộng\n(khuyến nghị)' : 'Chi tiết ổ\n(tùy chọn)';
      }
      // few
      const labels = {
        2: 'Loài 2\n(khuyến nghị)',
        3: 'Loài 3\n(tùy chọn)',
        4: 'Loài 4\n(tùy chọn)',
        5: 'Loài 5\n(tùy chọn)',
      };
      return labels[slot] ?? 'Tùy chọn';
    }

    Color badgeColorFor(int slot) {
      if (slot == 1) return Colors.red;
      if (slot == 2) return Colors.orange;
      return Colors.grey;
    }

    String badgeTextFor(int slot) {
      if (slot == 1) return 'Bắt buộc';
      if (slot == 2) return 'Khuyến nghị';
      return 'Tùy chọn';
    }

    // Build the photo grid
    final List<Widget> gridRows = [
      _buildPhotoSlot(
        slot: 1,
        label: slotLabel(1),
        badgeText: badgeTextFor(1),
        badgeColor: badgeColorFor(1),
        aspectRatio: 4 / 3,
        photo: _photos[1],
      ),
    ];

    for (int i = 2; i <= actualVisible; i += 2) {
      final int slotA = i;
      final int slotB = i + 1;
      gridRows.add(const SizedBox(height: 12));
      gridRows.add(
        Row(
          children: [
            Expanded(
              child: _buildPhotoSlot(
                slot: slotA,
                label: slotLabel(slotA),
                badgeText: badgeTextFor(slotA),
                badgeColor: badgeColorFor(slotA),
                aspectRatio: 1,
                photo: _photos[slotA],
              ),
            ),
            if (slotB <= actualVisible) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _buildPhotoSlot(
                  slot: slotB,
                  label: slotLabel(slotB),
                  badgeText: badgeTextFor(slotB),
                  badgeColor: badgeColorFor(slotB),
                  aspectRatio: 1,
                  photo: _photos[slotB],
                ),
              ),
            ] else
              const Expanded(child: SizedBox()),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          _photoSectionTitle,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isSingle
              ? 'Chụp ảnh rõ nét từ khoảng cách an toàn'
              : isMany
              ? 'Chụp cảnh khu vực, không cần lại gần ổ rắn'
              : 'Mỗi ảnh nên thể hiện một loài rắn khác nhau (tối đa $maxSlots ảnh)',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        // Photo grid
        Column(children: gridRows),
        // "Add photo" button for 'few' when more slots are available
        if (isFew && actualVisible < maxSlots) ...[
          const SizedBox(height: 12),
          _buildAddPhotoButton(nextSlot: actualVisible + 1),
        ],
        const SizedBox(height: 12),
        // Single mode: always-visible quantity stepper
        if (isSingle) _buildSingleQuantityRow(),
        // AI Detection carousel
        if (_detectionResults.values.any((r) => r != null)) ...[
          const SizedBox(height: 12),
          _buildAiDetectionCarousel(),
          const SizedBox(height: 12),
        ],
        // Per-species quantity selectors (few/many: after AI detects)
        if (isMultiple && _speciesQuantityMap.isNotEmpty)
          _buildSpeciesQuantitySection(),
        const SizedBox(height: 24),
        // Tips Section
        _buildTipsSection(),
        const SizedBox(height: 24),
        // Location Section
        _buildLocationSection(),
        const SizedBox(height: 16),
        // Address Detail Field
        _buildAddressDetailField(),
        const SizedBox(height: 24),
        // Additional Info Form
        _buildAdditionalInfoForm(),
        const SizedBox(height: 100),
      ],
    );
  }

  /// "Add another species photo" button for 'few' mode
  Widget _buildAddPhotoButton({required int nextSlot}) {
    return GestureDetector(
      onTap: () => _pickImage(nextSlot),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF228B22).withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFF228B22),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text(
              'Thêm ảnh loài rắn khác',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF166534),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Always-visible quantity row for single-mode (how many individuals)
  Widget _buildSingleQuantityRow() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF228B22).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.format_list_numbered,
            size: 16,
            color: Color(0xFF228B22),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Số lượng cá thể',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF166534),
                  ),
                ),
                Text(
                  'Báo cáo có bao nhiêu con rắn loài này',
                  style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          _buildInlineStepper(
            value: _singleQuantity,
            min: 1,
            max: 99,
            onChanged: (v) => setState(() => _singleQuantity = v),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeciesQuantitySection() {
    // Build list of unique detected species preserving insertion order
    final seen = <int>{};
    final uniqueSpecies = <DetectionResult>[];
    for (final slot in [1, 2, 3]) {
      final r = _detectionResults[slot];
      if (r != null && seen.add(r.snake.id)) {
        uniqueSpecies.add(r);
      }
    }
    if (uniqueSpecies.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF228B22).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.format_list_numbered,
                size: 16,
                color: Color(0xFF228B22),
              ),
              const SizedBox(width: 6),
              const Text(
                'Số lượng theo loài',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF166534),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...uniqueSpecies.map((r) => _buildSpeciesQtyRow(r)),
        ],
      ),
    );
  }

  Widget _buildSpeciesQtyRow(DetectionResult r) {
    final snakeId = r.snake.id;
    final qty = _speciesQuantityMap[snakeId] ?? 1;
    final isVenomous = r.snake.isVenomous;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: r.snake.imageUrl.isNotEmpty
                ? Image.network(
                    r.snake.imageUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _snakeIconBox(),
                  )
                : _snakeIconBox(),
          ),
          const SizedBox(width: 10),
          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.snake.commonName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isVenomous)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      'Có độc',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Stepper
          _buildInlineStepper(
            value: qty,
            min: 1,
            max: widget.quantity == 'few' ? 5 : 99,
            onChanged: (v) => setState(() => _speciesQuantityMap[snakeId] = v),
          ),
        ],
      ),
    );
  }

  Widget _snakeIconBox() => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: const Color(0xFFDCFCE7),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.pest_control, size: 22, color: Color(0xFF228B22)),
  );

  Widget _buildInlineStepper({
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepperBtn(
          icon: Icons.remove,
          enabled: value > min,
          onTap: () => onChanged(value - 1),
        ),
        SizedBox(
          width: 34,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF166534),
            ),
          ),
        ),
        _stepperBtn(
          icon: Icons.add,
          enabled: value < max,
          onTap: () => onChanged(value + 1),
        ),
      ],
    );
  }

  Widget _stepperBtn({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF228B22) : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildPhotoSlot({
    required int slot,
    required String label,
    required String badgeText,
    required Color badgeColor,
    required double aspectRatio,
    File? photo,
  }) {
    final isAnalyzing = _isAnalyzingSlot[slot] == true;
    final hasDetection =
        _detectionResults.containsKey(slot) && _detectionResults[slot] != null;

    return GestureDetector(
      onTap: () => _pickImage(slot),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          decoration: BoxDecoration(
            color: photo != null ? Colors.black : const Color(0xFFF5F5F5),
            border: Border.all(
              color: photo != null
                  ? const Color(0xFF228B22)
                  : Colors.grey[300]!,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              // Photo or placeholder
              if (photo != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    photo,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                )
              else
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_camera,
                        size: aspectRatio == 1 ? 32 : 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: aspectRatio == 1 ? 11 : 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // Badge (only when no photo)
              if (photo == null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              // Delete button (top-right, when photo is set and not uploading)
              if (photo != null && !isAnalyzing)
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => _clearSlot(slot),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              // Analyzing overlay
              if (isAnalyzing)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF4CAF50),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'AI đang\nnhận diện...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: aspectRatio == 1 ? 10 : 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              // Detection success badge (bottom-left)
              if (!isAnalyzing && hasDetection)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF228B22),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.smart_toy,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'AI ✓',
                          style: TextStyle(
                            fontSize: aspectRatio == 1 ? 9 : 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiDetectionCarousel() {
    // Build ordered list of available results
    const slotLabels = {1: 'Ảnh chính', 2: 'Góc độ 2', 3: 'Góc độ 3'};
    final entries = [1, 2, 3]
        .where((s) => _detectionResults[s] != null)
        .map((s) => (slot: s, result: _detectionResults[s]!))
        .toList();

    if (entries.isEmpty) return const SizedBox.shrink();

    final total = entries.length;

    return Column(
      children: [
        SizedBox(
          // Fixed height so the Column parent doesn't need to measure
          height: 230,
          child: PageView.builder(
            controller: _aiCardPageController,
            itemCount: total,
            onPageChanged: (i) => setState(() => _aiCardPage = i),
            itemBuilder: (context, i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _buildAiDetectionCard(
                  entries[i].result,
                  slotLabel: slotLabels[entries[i].slot]!,
                ),
              );
            },
          ),
        ),
        // Dot indicators — only if more than 1 card
        if (total > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(total, (i) {
              final active = _aiCardPage == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF228B22)
                      : const Color(0xFF228B22).withOpacity(0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildAiDetectionCard(
    DetectionResult result, {
    String slotLabel = 'Ảnh chính',
  }) {
    final ai = result.aiDetection;
    final snake = result.snake;
    final confidencePct = (ai.confidence * 100).toStringAsFixed(0);
    final isHighConfidence = ai.confidence >= 0.7;
    final isMediumConfidence = ai.confidence >= 0.4;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF228B22).withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF228B22).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF228B22),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI nhận diện · $slotLabel',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF166534),
                        ),
                      ),
                      const Text(
                        'Kết quả phân tích từ ảnh chụp',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                ),
                // Confidence badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isHighConfidence
                        ? const Color(0xFF228B22)
                        : isMediumConfidence
                        ? Colors.orange
                        : Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$confidencePct%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Snake thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: snake.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: snake.imageUrl,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 72,
                            height: 72,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 72,
                            height: 72,
                            color: const Color(0xFFF0FDF4),
                            child: const Icon(
                              Icons.pets,
                              color: Color(0xFF228B22),
                              size: 30,
                            ),
                          ),
                        )
                      : Container(
                          width: 72,
                          height: 72,
                          color: const Color(0xFFF0FDF4),
                          child: const Icon(
                            Icons.pets,
                            color: Color(0xFF228B22),
                            size: 30,
                          ),
                        ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              snake.commonName.isNotEmpty
                                  ? snake.commonName
                                  : ai.className,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (snake.isVenomous)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.red[200]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    size: 12,
                                    color: Colors.red[700],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Độc',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      if (snake.scientificName.isNotEmpty)
                        Text(
                          snake.scientificName,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Confidence bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Độ tin cậy',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                isHighConfidence
                                    ? 'Cao'
                                    : isMediumConfidence
                                    ? 'Trung bình'
                                    : 'Thấp',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isHighConfidence
                                      ? const Color(0xFF228B22)
                                      : isMediumConfidence
                                      ? Colors.orange
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: ai.confidence,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isHighConfidence
                                    ? const Color(0xFF228B22)
                                    : isMediumConfidence
                                    ? Colors.orange
                                    : Colors.red,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Footer note
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Text(
              isHighConfidence
                  ? '✓ AI nhận diện với độ tin cậy cao. Thông tin đã được lưu vào yêu cầu.'
                  : '⚠ Độ tin cậy thấp. Bạn có thể chụp lại hoặc chọn loài từ tab "Chọn Loài Rắn".',
              style: TextStyle(
                fontSize: 11,
                color: isHighConfidence
                    ? const Color(0xFF15803D)
                    : Colors.orange[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          border: Border.all(color: const Color(0xFFFEF3C7)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: const Icon(
            Icons.tips_and_updates,
            color: Color(0xFF228B22),
            size: 20,
          ),
          title: const Text(
            'Mẹo chụp ảnh rắn',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF228B22),
            ),
          ),
          iconColor: Colors.grey[400],
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTipItem('Chụp từ xa an toàn (2-3 mét)'),
                _buildTipItem('Chụp rõ đầu và thân rắn'),
                _buildTipItem('Tránh dùng flash nếu rắn đang hung dữ'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF228B22),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    final hasLocation = _selectedAddress != null;

    return GestureDetector(
      onTap: _openLocationPicker,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasLocation ? const Color(0xFF228B22) : Colors.grey[300]!,
            width: hasLocation ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasLocation ? const Color(0xFFDCFCE7) : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasLocation ? Icons.check_circle : Icons.location_on,
                color: hasLocation ? const Color(0xFF228B22) : Colors.grey[400],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasLocation ? 'Vị trí đã xác định' : 'Chọn vị trí',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: hasLocation ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasLocation
                        ? _selectedAddress!
                        : 'Nhấn để chọn vị trí hoặc lấy vị trí hiện tại',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressDetailField() {
    final isFilled = _addressDetailController.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFilled ? const Color(0xFF228B22) : const Color(0xFFE53935),
          width: isFilled ? 2 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 18,
                color: isFilled
                    ? const Color(0xFF228B22)
                    : const Color(0xFFE53935),
              ),
              const SizedBox(width: 8),
              Text(
                'GHI CHÚ ĐỊA CHỈ CHI TIẾT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE53935),
                ),
              ),
              const Spacer(),
              if (isFilled)
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Color(0xFF228B22),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Bắt buộc',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE53935),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressDetailController,
            decoration: InputDecoration(
              hintText: 'Ví dụ: gần chùa, gần hẻm 123, gần công viên...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              filled: true,
              fillColor: isFilled
                  ? const Color(0xFFF0FDF4)
                  : const Color(0xFFFFF8F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isFilled ? const Color(0xFF228B22) : Colors.grey[300]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isFilled
                      ? const Color(0xFF228B22)
                      : const Color(0xFFE53935),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isFilled ? Icons.check_circle_outline : Icons.info_outline,
                size: 13,
                color: isFilled
                    ? const Color(0xFF228B22)
                    : const Color(0xFFE53935),
              ),
              const SizedBox(width: 4),
              Text(
                isFilled
                    ? 'Đội cứu hộ sẽ dễ tìm hơn với thông tin này'
                    : 'Vui lòng điền để đội cứu hộ xác định đúng vị trí',
                style: TextStyle(
                  fontSize: 12,
                  color: isFilled
                      ? const Color(0xFF228B22)
                      : const Color(0xFFE53935),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THÔNG TIN BỔ SUNG (TÙY CHỌN)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          // Specific Location
          _buildTextField(
            label: 'Vị trí cụ thể',
            controller: _specificLocationController,
            hint: 'trong nhà/vườn/đường phố',
          ),
          const SizedBox(height: 20),
          // Size
          _buildDropdown(
            label: 'Kích thước ước tính',
            value: _selectedSize,
            items: const [
              'Chọn kích thước',
              'Nhỏ (< 30cm)',
              'Trung bình (30cm - 1m)',
              'Lớn (> 1m)',
            ],
            onChanged: (value) => setState(() => _selectedSize = value),
          ),
          const SizedBox(height: 20),
          // Behavior
          _buildTextField(
            label: 'Hành vi của rắn',
            controller: _behaviorController,
            hint: 'đang di chuyển/đứng yên/hung dữ',
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
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
              borderSide: const BorderSide(color: Color(0xFF228B22)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.expand_more, color: Colors.grey),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item == items[0] ? null : item,
                  child: Text(
                    item,
                    style: TextStyle(
                      color: item == items[0]
                          ? Colors.grey[400]
                          : Colors.black87,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    bool loading = false,
    int? count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF228B22) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF228B22) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading && selected) ...[
              const SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey[700],
              ),
            ),
            if (count != null && !loading) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withOpacity(0.25)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpeciesTab() {
    final locationState = ref.watch(snakeLocationProvider);

    // Compute display list: location-filtered (sorted by priority) or all
    List<SnakeSpecies> displaySpecies;
    if (_showLocationFiltered && locationState.data != null) {
      final regionIds = {for (final s in locationState.data!.snakes) s.id};
      final priorityMap = {
        for (final s in locationState.data!.snakes) s.id: s.priority,
      };
      displaySpecies =
          _allSpecies.where((s) => regionIds.contains(s.id)).toList()..sort(
            (a, b) =>
                (priorityMap[a.id] ?? 99).compareTo(priorityMap[b.id] ?? 99),
          );
    } else {
      displaySpecies = List.from(_allSpecies);
    }

    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      displaySpecies = displaySpecies
          .where(
            (s) =>
                s.commonName.toLowerCase().contains(query) ||
                s.scientificName.toLowerCase().contains(query),
          )
          .toList();
    }

    return CustomScrollView(
      slivers: [
        // Info Banner
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF), // blue-50
              border: Border.all(color: const Color(0xFFDBEAFE)), // blue-100
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBFDBFE), // blue-200
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.list_alt,
                    color: Color(0xFF1E40AF), // blue-800
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chọn loài rắn bạn gặp từ danh sách phổ biến ở khu vực',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E3A8A), // blue-900
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (locationState.isLoading)
                        Row(
                          children: [
                            SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: Colors.blue[600],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Đang tải rắn theo vùng...',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        )
                      else if (locationState.data != null)
                        Text(
                          'Khu vực: ${locationState.data!.region.name}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue[700],
                          ),
                        )
                      else
                        Text(
                          'Dựa trên vị trí GPS của bạn',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue[700],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Location Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildLocationSection(),
          ),
        ),

        // Address Detail Field
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _buildAddressDetailField(),
          ),
        ),

        // Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm loài rắn khác...',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: Color(0xFF228B22),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Location filter toggle (shown only once location is selected)
        if (_selectedLatitude != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'Gần tôi',
                    selected: _showLocationFiltered,
                    loading: locationState.isLoading,
                    count: locationState.data?.snakes.length,
                    onTap: () => setState(() => _showLocationFiltered = true),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Tất cả loài',
                    selected: !_showLocationFiltered,
                    onTap: () => setState(() => _showLocationFiltered = false),
                  ),
                ],
              ),
            ),
          ),

        // Selected Species List (for few/many)
        if (widget.quantity != 'single' && _selectedSpeciesMap.isNotEmpty)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF228B22), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF228B22),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Đã chọn ${_selectedSpeciesMap.length} loài rắn',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF228B22),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._selectedSpeciesMap.entries.map((entry) {
                    return _buildSelectedSpeciesItem(entry.key, entry.value);
                  }).toList(),
                ],
              ),
            ),
          ),

        // Yellow Tip Box
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9C3), // yellow-100
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFFCA8A04), // yellow-700
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Chọn con GIỐNG NHẤT, không cần chính xác 100%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.yellow[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Snake Species Grid
        if (_isLoadingSpecies ||
            (_showLocationFiltered && locationState.isLoading))
          const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF228B22)),
            ),
          )
        else if (_speciesError != null)
          SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Không thể tải danh sách loài rắn',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _speciesError!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadSnakeSpecies,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (displaySpecies.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Không tìm thấy loài rắn',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Thử tìm kiếm với từ khóa khác',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.78,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final species = displaySpecies[index];
                final isSelected = _selectedSpecies?.id == species.id;
                return _buildSpeciesCard(species, isSelected);
              }, childCount: displaySpecies.length),
            ),
          ),

        // Additional Info Form (always shown)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: _buildAdditionalInfoForm(),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedSpeciesItem(SnakeSpecies species, int quantity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Species image
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 50,
              height: 50,
              child: species.imageUrl != null
                  ? Image.network(
                      species.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image_not_supported,
                            size: 20,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.pets,
                        size: 20,
                        color: Colors.grey[400],
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Species info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  species.commonName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  species.scientificName,
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Quantity controls
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    if (quantity > 1) {
                      _selectedSpeciesMap[species] = quantity - 1;
                    }
                  });
                },
                icon: const Icon(Icons.remove_circle_outline),
                color: const Color(0xFF228B22),
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  quantity.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF228B22),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    if (quantity < 100) {
                      _selectedSpeciesMap[species] = quantity + 1;
                    }
                  });
                },
                icon: const Icon(Icons.add_circle_outline),
                color: const Color(0xFF228B22),
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(width: 4),
          // Remove button
          IconButton(
            onPressed: () {
              setState(() {
                _selectedSpeciesMap.remove(species);
              });
            },
            icon: const Icon(Icons.close),
            color: Colors.red,
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeciesCard(SnakeSpecies species, bool isSelected) {
    // For few/many, check if species is in map
    final isInMap = _selectedSpeciesMap.containsKey(species);
    final actuallySelected = widget.quantity == 'single' ? isSelected : isInMap;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (widget.quantity == 'single') {
            // Single selection
            _selectedSpecies = isSelected ? null : species;
          } else {
            // Multi selection (few/many)
            if (isInMap) {
              _selectedSpeciesMap.remove(species);
            } else {
              // Add with default quantity based on type
              final defaultQty = widget.quantity == 'few' ? 2 : 10;
              _selectedSpeciesMap[species] = defaultQty;
            }
          }
        });
      },
      onLongPress: () => _showSpeciesDetail(species),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: actuallySelected
                ? const Color(0xFF228B22)
                : Colors.grey[300]!,
            width: actuallySelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: actuallySelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF228B22).withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : [
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
            // Image with badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(11),
                    topRight: Radius.circular(11),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: species.imageUrl != null
                        ? Image.network(
                            species.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.pets,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                          ),
                  ),
                ),
                // Venomous badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: species.isVenomous
                          ? const Color(0xFFDC3545)
                          : const Color(0xFF228B22),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      species.isVenomous ? 'RẮN ĐỘC' : 'KHÔNG ĐỘC',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Species info
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      species.commonName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      species.scientificName,
                      style: TextStyle(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTraitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 10, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey[600],
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _extractSize(String summary) {
    // Try to extract size from identification summary
    final regex = RegExp(
      r'(\d+\.?\d*)\s*-?\s*(\d+\.?\d*)\s*(m|cm)',
      caseSensitive: false,
    );
    final match = regex.firstMatch(summary);
    if (match != null) {
      return match.group(0) ?? 'Unknown';
    }

    // If no size found, return first part of summary
    final parts = summary.split('.');
    return parts.isNotEmpty ? parts[0] : summary;
  }

  void _showSpeciesDetail(SnakeSpecies species) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Hero image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: species.imageUrl ?? '',
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 250,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 250,
                              color: Colors.grey[200],
                              child: const Icon(Icons.error, size: 48),
                            ),
                          ),

                          // Venomous badge
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: species.isVenomous
                                    ? Colors.red
                                    : Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                species.isVenomous ? 'RẮN ĐỘC' : 'KHÔNG ĐỘC',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Common name
                    Text(
                      species.commonName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Scientific name
                    Text(
                      species.scientificName,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Description
                    if (species.description?.isNotEmpty ?? false) ...[
                      _buildDetailSection(
                        'Mô tả',
                        Icons.description,
                        species.description!,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Identification summary
                    if (species.identificationSummary?.isNotEmpty ?? false) ...[
                      _buildDetailSection(
                        'Nhận dạng',
                        Icons.fingerprint,
                        species.identificationSummary!,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Physical traits
                    if (species.identification?.physicalTraits.isNotEmpty ??
                        false) ...[
                      _buildListSection(
                        'Đặc điểm vật lý',
                        Icons.visibility,
                        species.identification!.physicalTraits,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Behaviors
                    if (species.identification?.behaviors.isNotEmpty ??
                        false) ...[
                      _buildListSection(
                        'Hành vi',
                        Icons.pets,
                        species.identification!.behaviors,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Habitat
                    if (species.identification?.habitat.isNotEmpty ??
                        false) ...[
                      _buildDetailSection(
                        'Môi trường sống',
                        Icons.terrain,
                        species.identification!.habitat,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Risk level
                    if (species.riskLevel > 0) ...[
                      _buildRiskLevel(species.riskLevel, species.isVenomous),
                      const SizedBox(height: 20),
                    ],

                    // Venom type
                    if (species.isVenomous &&
                        (species.primaryVenomType?.isNotEmpty ?? false)) ...[
                      _buildDetailSection(
                        'Loại độc',
                        Icons.warning,
                        species.primaryVenomType!,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 20),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    IconData icon,
    String content, {
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color ?? const Color(0xFF228B22)),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (color ?? const Color(0xFF228B22)).withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (color ?? const Color(0xFF228B22)).withOpacity(0.2),
            ),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListSection(String title, IconData icon, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF228B22)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF228B22).withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF228B22).withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF228B22),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRiskLevel(double riskLevel, bool isVenomous) {
    Color getRiskColor() {
      if (riskLevel >= 7.0) {
        return Colors.red;
      } else if (riskLevel >= 4.0) {
        return Colors.orange;
      } else {
        return Colors.green;
      }
    }

    String getRiskLabel() {
      if (riskLevel >= 7.0) {
        return 'Cao';
      } else if (riskLevel >= 4.0) {
        return 'Trung bình';
      } else {
        return 'Thấp';
      }
    }

    String getRiskScore() {
      return '${riskLevel.toStringAsFixed(1)}/10';
    }

    final color = getRiskColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.shield, size: 20, color: color),
            const SizedBox(width: 8),
            const Text(
              'Mức độ nguy hiểm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${getRiskLabel()} - ${getRiskScore()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (isVenomous)
                const Expanded(
                  child: Text(
                    'Rắn độc - Cần thận trọng',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    // Validate location
    if (_selectedAddress == null ||
        _selectedLatitude == null ||
        _selectedLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn vị trí trước khi gửi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isPhotoTab && !_detectionResults.values.any((r) => r != null)) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Không nhận diện được rắn',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: const Text(
            'Hệ thống AI chưa tìm thấy rắn trong ảnh của bạn. Bạn có muốn chuyển sang "Chọn Loài Rắn" để các chuyên gia cứu hộ dễ chuẩn bị công cụ xử lý không?\n\nBạn vẫn có thể tiếp tục gửi yêu cầu này nếu chắc chắn trong ảnh có rắn cần được bắt.',
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text(
                'Tiếp tục gửi',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => context.pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF228B22),
              ),
              child: const Text('Chọn loài rắn thủ công'),
            ),
          ],
        ),
      );

      if (confirm == null) return;
      if (confirm == true) {
        setState(() {
          _isPhotoTab = false;
        });
        return;
      }
    }

    // Build species list
    List<SnakeSpeciesItem> snakeSpeciesList = [];

    if (_isPhotoTab) {
      // Photo tab: collect uniquely detected species with user-set quantities
      final seen = <int>{};
      for (final slot in [1, 2, 3]) {
        final r = _detectionResults[slot];
        if (r != null && r.snake.id > 0 && seen.add(r.snake.id)) {
          snakeSpeciesList.add(
            SnakeSpeciesItem(
              snakeSpeciesId: r.snake.id,
              quantity: widget.quantity == 'single'
                  ? _singleQuantity
                  : (_speciesQuantityMap[r.snake.id] ?? 1),
            ),
          );
        }
      }
      // No detection → empty list is fine; BE records the media for manual review
    } else {
      // Species tab: require manual selection
      if (widget.quantity == 'single') {
        if (_selectedSpecies == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vui lòng chọn loài rắn'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        snakeSpeciesList.add(
          SnakeSpeciesItem(
            snakeSpeciesId: _selectedSpecies!.id,
            quantity: _singleQuantity,
          ),
        );
      } else {
        if (_selectedSpeciesMap.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vui lòng chọn ít nhất 1 loài rắn'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        snakeSpeciesList = _selectedSpeciesMap.entries
            .map(
              (entry) => SnakeSpeciesItem(
                snakeSpeciesId: entry.key.id,
                quantity: entry.value,
              ),
            )
            .toList();
      }
    }

    // additionalDetails = Ghi chú địa chỉ chi tiết (gần chùa, gần hẻm, etc.) — required by BE
    final additionalDetails = _addressDetailController.text.trim();

    // notes = Các thông tin bổ sung khác (vị trí cụ thể, kích thước, hành vi)
    final notesParts = <String>[];

    if (_specificLocationController.text.isNotEmpty) {
      notesParts.add('Vị trí cụ thể: ${_specificLocationController.text}');
    }

    if (_selectedSize != null && _selectedSize != 'Chọn kích thước') {
      notesParts.add('Kích thước ước tính: $_selectedSize');
    }

    if (_behaviorController.text.isNotEmpty) {
      notesParts.add('Hành vi của rắn: ${_behaviorController.text}');
    }

    final notes = notesParts.isNotEmpty ? notesParts.join(', ') : null;

    // Create request
    final mediaIdList = _mediaIds.values.toList();
    final request = SnakeCatchingRequest(
      address: _selectedAddress!,
      lng: _selectedLongitude!,
      lat: _selectedLatitude!,
      additionalDetails: additionalDetails,
      notes: notes,
      snakeSpeciesList: snakeSpeciesList,
      mediaIdList: mediaIdList.isNotEmpty ? mediaIdList : null,
    );

    // Show loading
    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = ref.read(snakeCatchingRepositoryProvider);
      final response = await repository.createRequest(request);

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        // Check if response has data
        if (response.data == null) {
          throw Exception('Không nhận được dữ liệu từ server');
        }

        // Navigate to success screen with request data
        context.pushReplacement(
          '/snake-catching-success',
          extra: response.data!,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Color(0xFF228B22)),
            SizedBox(width: 8),
            Text('Hướng dẫn báo cáo'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Báo cáo với ảnh:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Chụp ít nhất 1 ảnh rõ ràng'),
            Text('• AI sẽ tự động nhận diện loài rắn'),
            Text('• Thông tin chi tiết giúp cứu hộ nhanh hơn'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              'Đã hiểu',
              style: TextStyle(color: Color(0xFF228B22)),
            ),
          ),
        ],
      ),
    );
  }

  void _showPricingBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => PricingBottomSheet(scrollController: controller),
      ),
    );
  }
}
