import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../models/snake_species.dart';
import '../../models/snake_catching_request.dart';
import '../../repository/snake_species_repository.dart';
import '../../repository/snake_catching_repository.dart';
import '../../widgets/location_picker_dialog.dart';

/// Screen for members to submit detailed snake report with photos
class SnakeReportDetailScreen extends ConsumerStatefulWidget {
  final String quantity; // 'single', 'few', 'many'

  const SnakeReportDetailScreen({
    super.key,
    required this.quantity,
  });

  @override
  ConsumerState<SnakeReportDetailScreen> createState() =>
      _SnakeReportDetailScreenState();
}

class _SnakeReportDetailScreenState extends ConsumerState<SnakeReportDetailScreen> {
  bool _isPhotoTab = true; // true = Chụp Ảnh, false = Chọn Loài Rắn
  File? _mainPhoto;
  File? _photo2;
  File? _photo3;
  final _addressDetailController = TextEditingController(); // Ghi chú địa chỉ chi tiết
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
  
  // Multi-species state (for few/many snakes)
  // Map<SnakeSpecies, int> - species to quantity mapping
  Map<SnakeSpecies, int> _selectedSpeciesMap = {};

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
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSpecies = _allSpecies;
      } else {
        _filteredSpecies = _allSpecies.where((species) {
          return species.commonName.toLowerCase().contains(query) ||
              species.scientificName.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  String get _titleText {
    switch (widget.quantity) {
      case 'single':
        return 'Báo Cáo: 1 Con Rắn';
      case 'few':
        return 'Báo Cáo: 2-5 Con Rắn';
      case 'many':
        return 'Báo Cáo: Nhiều Con / Ổ Rắn';
      default:
        return 'Báo Cáo Phát Hiện Rắn';
    }
  }

  String get _photoSectionTitle {
    switch (widget.quantity) {
      case 'single':
        return 'Chụp ảnh con rắn (1-3 góc độ)';
      case 'few':
        return 'Chụp ảnh các con rắn (1-3 góc độ)';
      case 'many':
        return 'Chụp ảnh khu vực/ổ rắn (1-3 góc độ)';
      default:
        return 'Chụp ảnh (1-3 góc độ)';
    }
  }

  bool get _canSubmit {
    // Must have location
    if (_selectedAddress == null || _selectedLatitude == null || _selectedLongitude == null) {
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
      return _mainPhoto != null;
    } else {
      if (widget.quantity == 'single') {
        return _selectedSpecies != null;
      } else {
        return _selectedSpeciesMap.isNotEmpty;
      }
    }
  }

  Future<void> _pickImage(int slot) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          switch (slot) {
            case 1:
              _mainPhoto = File(image.path);
              break;
            case 2:
              _photo2 = File(image.path);
              break;
            case 3:
              _photo3 = File(image.path);
              break;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _openLocationPicker() async {
    final result = await showDialog<LocationResult>(
      context: context,
      builder: (context) => LocationPickerDialog(
        initialLocation: _selectedAddress,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedAddress = result.getFullAddress();
        _selectedLatitude = result.latitude;
        _selectedLongitude = result.longitude;
      });
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
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
          border: Border(
            top: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: (_canSubmit && !_isSubmitting) ? _handleSubmit : null,
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
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      else
                        Text(
                          _isPhotoTab ? 'Gửi Báo Cáo' : 'Gửi Báo Cáo',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (!_isSubmitting) const SizedBox(width: 8),
                      if (!_isSubmitting) const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.smart_toy, size: 16, color: Colors.grey[400]),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photo Section
        Text(
          _photoSectionTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        // Photo Grid
        Column(
          children: [
            // Main photo (Required)
            _buildPhotoSlot(
              slot: 1,
              label: 'Ảnh chính (bắt buộc)',
              badgeText: 'REQUIRED',
              badgeColor: Colors.red,
              aspectRatio: 4 / 3,
              photo: _mainPhoto,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPhotoSlot(
                    slot: 2,
                    label: 'Góc độ 2\n(khuyến nghị)',
                    badgeText: 'Recommended',
                    badgeColor: Colors.orange,
                    aspectRatio: 1,
                    photo: _photo2,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPhotoSlot(
                    slot: 3,
                    label: 'Góc độ 3\n(tùy chọn)',
                    badgeText: 'Optional',
                    badgeColor: Colors.grey,
                    aspectRatio: 1,
                    photo: _photo3,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Add photo button (disabled if all slots filled)
        OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.add_a_photo, size: 20),
          label: const Text('Thêm ảnh +'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF228B22).withOpacity(0.5),
            side: BorderSide(
              color: const Color(0xFF228B22).withOpacity(0.3),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
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

  Widget _buildPhotoSlot({
    required int slot,
    required String label,
    required String badgeText,
    required Color badgeColor,
    required double aspectRatio,
    File? photo,
  }) {
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
              width: photo != null ? 2 : 2,
              style: photo != null ? BorderStyle.solid : BorderStyle.solid,
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
              // Badge
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
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
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
                color: hasLocation 
                    ? const Color(0xFFDCFCE7) 
                    : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasLocation ? Icons.check_circle : Icons.location_on,
                color: hasLocation 
                    ? const Color(0xFF228B22) 
                    : Colors.grey[400],
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
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
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
          color: isFilled
              ? const Color(0xFF228B22)
              : const Color(0xFFE53935),
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
                color: isFilled ? const Color(0xFF228B22) : const Color(0xFFE53935),
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
                const Icon(Icons.check_circle, size: 16, color: Color(0xFF228B22))
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                  color: isFilled
                      ? const Color(0xFF228B22)
                      : Colors.grey[300]!,
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
                color: isFilled ? const Color(0xFF228B22) : const Color(0xFFE53935),
              ),
              const SizedBox(width: 4),
              Text(
                isFilled
                    ? 'Đội cứu hộ sẽ dễ tìm hơn với thông tin này'
                    : 'Vui lòng điền để đội cứu hộ xác định đúng vị trí',
                style: TextStyle(
                  fontSize: 12,
                  color: isFilled ? const Color(0xFF228B22) : const Color(0xFFE53935),
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
                      color: item == items[0] ? Colors.grey[400] : Colors.black87,
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

  Widget _buildSpeciesTab() {
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
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
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
                  borderSide: const BorderSide(color: Color(0xFF228B22), width: 2),
                ),
              ),
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
        if (_isLoadingSpecies)
          const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF228B22),
              ),
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
        else if (_filteredSpecies.isEmpty)
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
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final species = _filteredSpecies[index];
                  final isSelected = _selectedSpecies?.id == species.id;
                  return _buildSpeciesCard(species, isSelected);
                },
                childCount: _filteredSpecies.length,
              ),
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
            color: actuallySelected ? const Color(0xFF228B22) : Colors.grey[300]!,
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
          Icon(
            icon,
            size: 10,
            color: Colors.grey[500],
          ),
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
    final regex = RegExp(r'(\d+\.?\d*)\s*-?\s*(\d+\.?\d*)\s*(m|cm)', caseSensitive: false);
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
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: species.isVenomous ? Colors.red : Colors.green,
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
                    if (species.identification?.physicalTraits.isNotEmpty ?? false) ...[
                      _buildListSection(
                        'Đặc điểm vật lý',
                        Icons.visibility,
                        species.identification!.physicalTraits,
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Behaviors
                    if (species.identification?.behaviors.isNotEmpty ?? false) ...[
                      _buildListSection(
                        'Hành vi',
                        Icons.pets,
                        species.identification!.behaviors,
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Habitat
                    if (species.identification?.habitat.isNotEmpty ?? false) ...[
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
                    if (species.isVenomous && (species.primaryVenomType?.isNotEmpty ?? false)) ...[
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
  
  Widget _buildDetailSection(String title, IconData icon, String content, {Color? color}) {
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
            border: Border.all(
              color: const Color(0xFF228B22).withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) => Padding(
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
            )).toList(),
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
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    if (_selectedAddress == null || _selectedLatitude == null || _selectedLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn vị trí trước khi gửi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate species selection
    List<SnakeSpeciesItem> snakeSpeciesList = [];
    
    if (widget.quantity == 'single') {
      // Single snake
      if (_selectedSpecies == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn loài rắn'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      snakeSpeciesList.add(SnakeSpeciesItem(
        snakeSpeciesId: _selectedSpecies!.id,
        quantity: 1,
      ));
    } else {
      // Few or many snakes
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
          .map((entry) => SnakeSpeciesItem(
                snakeSpeciesId: entry.key.id,
                quantity: entry.value,
              ))
          .toList();
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
    
    final notes = notesParts.isNotEmpty 
        ? notesParts.join(', ')
        : null;

    // Create request
    final request = SnakeCatchingRequest(
      address: _selectedAddress!,
      lng: _selectedLongitude!,
      lat: _selectedLatitude!,
      additionalDetails: additionalDetails,
      notes: notes,
      snakeSpeciesList: snakeSpeciesList,
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
}
