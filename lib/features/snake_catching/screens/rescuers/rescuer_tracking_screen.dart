import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/snake_catching_request.dart';
import '../../models/snake_species.dart';
import '../../repository/snake_catching_repository.dart';
import '../../repository/snake_species_repository.dart';
import 'rescuer_result_confirmation_screen.dart';

enum _UploadState { uploading, done, failed }

/// Màn hình quá trình cứu hộ - đang bắt rắn
class RescuerTrackingScreen extends ConsumerStatefulWidget {
  final SnakeCatchingRequestData requestData;
  final String missionId;
  
  const RescuerTrackingScreen({
    super.key,
    required this.requestData,
    required this.missionId,
  });

  @override
  ConsumerState<RescuerTrackingScreen> createState() => _RescuerTrackingScreenState();
}

class _RescuerTrackingScreenState extends ConsumerState<RescuerTrackingScreen> {
  final List<File> _capturedPhotos = [];
  // Upload state per photo index
  final Map<int, _UploadState> _uploadStates = {};
  final TextEditingController _notesController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // At least one photo successfully uploaded
  bool get _hasUploadedPhoto => _uploadStates.values.any((s) => s == _UploadState.done);

  SnakeSpecies? _species;
  bool _isLoadingSpecies = true;

  @override
  void initState() {
    super.initState();
    _loadSpecies();
  }

  Future<void> _loadSpecies() async {
    final speciesDetail = widget.requestData.details.isNotEmpty
        ? widget.requestData.details.first
        : null;
    if (speciesDetail == null) {
      if (mounted) setState(() => _isLoadingSpecies = false);
      return;
    }
    try {
      final repo = ref.read(snakeSpeciesRepositoryProvider);
      final species = await repo.getSnakeSpeciesById(speciesDetail.snakeSpeciesId);
      if (mounted) setState(() { _species = species; _isLoadingSpecies = false; });
    } catch (e) {
      debugPrint('⚠️ Failed to load species: $e');
      if (mounted) setState(() => _isLoadingSpecies = false);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo == null) return;

      final file = File(photo.path);
      final index = _capturedPhotos.length;
      setState(() {
        _capturedPhotos.add(file);
        _uploadStates[index] = _UploadState.uploading;
      });

      try {
        final repo = ref.read(snakeCatchingRepositoryProvider);
        await repo.uploadMissionEvidence(widget.missionId, file);
        if (mounted) setState(() => _uploadStates[index] = _UploadState.done);
      } catch (e) {
        debugPrint('⚠️ Upload failed for photo $index: $e');
        if (mounted) {
          setState(() => _uploadStates[index] = _UploadState.failed);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Tải ảnh thất bại. Nhấn ’Thử lại’ trên ảnh để upload lại.'),
              backgroundColor: const Color(0xFFDC3545),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi chụp ảnh: $e')),
        );
      }
    }
  }

  /// Retry upload for a failed photo
  Future<void> _retryUpload(int index) async {
    if (index >= _capturedPhotos.length) return;
    setState(() => _uploadStates[index] = _UploadState.uploading);
    try {
      final repo = ref.read(snakeCatchingRepositoryProvider);
      await repo.uploadMissionEvidence(widget.missionId, _capturedPhotos[index]);
      if (mounted) setState(() => _uploadStates[index] = _UploadState.done);
    } catch (e) {
      if (mounted) setState(() => _uploadStates[index] = _UploadState.failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6F5).withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Đang Bắt Rắn',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B35),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'ĐANG XỬ LÝ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B35),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                
                // Snake Info Banner
                _buildSnakeInfoBanner(),
                
                // Safety Reminders
                _buildSafetyReminders(),
                
                // Photo Documentation
                _buildPhotoDocumentation(),
                
                // Notes Section
                _buildNotesSection(),
                
                // Emergency Section                
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

  Widget _buildSnakeInfoBanner() {
    final speciesDetail = widget.requestData.details.isNotEmpty
        ? widget.requestData.details.first
        : null;

    // Image: prefer species imageUrl, fall back to request media
    String? imageUrl = _species?.imageUrl;
    if (imageUrl == null && widget.requestData.media.isNotEmpty) {
      imageUrl = widget.requestData.media.first.url;
    }

    // Danger label from real species data
    String dangerLabel = 'Chưa rõ';
    Color dangerColor = const Color(0xFF999999);
    String dangerDetail = '';
    if (_isLoadingSpecies) {
      dangerLabel = 'Đang tải...';
    } else if (_species != null) {
      if (_species!.isVenomous) {
        if (_species!.riskLevel >= 8.0) {
          dangerLabel = 'Cực độc';
          dangerDetail = 'Cực kỳ nguy hiểm';
          dangerColor = const Color(0xFFD90429);
        } else if (_species!.riskLevel >= 6.0) {
          dangerLabel = 'Độc mạnh';
          dangerDetail = 'Rất nguy hiểm';
          dangerColor = const Color(0xFFFF6B35);
        } else if (_species!.riskLevel >= 4.0) {
          dangerLabel = 'Có độc';
          dangerDetail = 'Nguy hiểm';
          dangerColor = const Color(0xFFFFA500);
        } else {
          dangerLabel = 'Ít độc';
          dangerDetail = 'Ít nguy hiểm';
          dangerColor = const Color(0xFFFFC107);
        }
      } else {
        dangerLabel = 'Không độc';
        dangerDetail = 'An toàn hơn';
        dangerColor = const Color(0xFF28A745);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2D8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 64,
              height: 64,
              color: const Color(0xFFE0E0E0),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image, size: 32, color: Color(0xFFCCCCCC)),
                    )
                  : const Icon(Icons.image, size: 32, color: Color(0xFFCCCCCC)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _species?.commonName ??
                      speciesDetail?.snakeSpeciesName ??
                      'Rắn chưa xác định',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                if (speciesDetail?.snakeSpeciesScientificName != null &&
                    speciesDetail!.snakeSpeciesScientificName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    speciesDetail.snakeSpeciesScientificName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: dangerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        dangerLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (dangerDetail.isNotEmpty)
                      Text(
                        dangerDetail,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: dangerColor,
                        ),
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

  Widget _buildSafetyReminders() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.gpp_maybe,
              color: Color(0xFFFF6B35),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'An Toàn Trong Quá Trình Bắt',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 12),
                ...[
                  'Giữ khoảng cách an toàn tối thiểu.',
                  'Sử dụng dụng cụ bắt rắn chuyên dụng.',
                  'Luôn di chuyển chậm và nhẹ nhàng.',
                  'Không bao giờ quay lưng về phía rắn.',
                ].map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Color(0xFF666666))),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoDocumentation() {
    final uploadedCount = _uploadStates.values.where((s) => s == _UploadState.done).length;
    final uploadingCount = _uploadStates.values.where((s) => s == _UploadState.uploading).length;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Chụp Ảnh Quá Trình',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '*Bắt buộc',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFDC3545),
                ),
              ),
              const Spacer(),
              if (_capturedPhotos.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: uploadedCount > 0
                        ? const Color(0xFF28A745).withOpacity(0.12)
                        : const Color(0xFFFF6B35).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    uploadingCount > 0
                        ? 'Đang tải $uploadingCount...'
                        : 'Đã tải $uploadedCount/${_capturedPhotos.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: uploadedCount > 0
                          ? const Color(0xFF28A745)
                          : const Color(0xFFFF6B35),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Camera Button
          InkWell(
            onTap: _capturePhoto,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFDDDDDD),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.photo_camera,
                    size: 36,
                    color: Color(0xFF999999),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Chụp ảnh rắn sau khi bắt',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Photo Grid
          if (_capturedPhotos.isNotEmpty) ...[
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _capturedPhotos.asMap().entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(right: entry.key < _capturedPhotos.length - 1 ? 12 : 0),
                    child: _buildPhotoThumbnail(entry.value, entry.key),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoThumbnail(File imageFile, int index) {
    final uploadState = _uploadStates[index] ?? _UploadState.uploading;
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 96,
            height: 96,
            color: const Color(0xFFE0E0E0),
            child: Image.file(imageFile, fit: BoxFit.cover),
          ),
        ),

        // Upload state overlay
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: uploadState == _UploadState.uploading
                  ? Container(
                      key: const ValueKey('uploading'),
                      color: Colors.black45,
                      child: const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : uploadState == _UploadState.failed
                      ? GestureDetector(
                          key: const ValueKey('failed'),
                          onTap: () => _retryUpload(index),
                          child: Container(
                            color: Colors.black54,
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.refresh, color: Colors.white, size: 22),
                                  SizedBox(height: 2),
                                  Text(
                                    'Thử lại',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : // done — small green tick in corner
                      Align(
                          key: const ValueKey('done'),
                          alignment: Alignment.bottomRight,
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Color(0xFF28A745),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 13),
                          ),
                        ),
            ),
          ),
        ),

        // Delete button (top-right)
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _capturedPhotos.removeAt(index);
                // Rebuild uploadStates with shifted indices
                final newStates = <int, _UploadState>{};
                _uploadStates.forEach((k, v) {
                  if (k < index) newStates[k] = v;
                  else if (k > index) newStates[k - 1] = v;
                });
                _uploadStates
                  ..clear()
                  ..addAll(newStates);
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              width: 22,
              height: 22,
              child: const Icon(Icons.close, size: 13, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ghi Chú',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'VD: Rắn trong bụi rậm, khó tiếp cận...',
                  hintStyle: const TextStyle(color: Color(0xFF999999)),
                  filled: true,
                  fillColor: Colors.white,
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
                    borderSide: const BorderSide(color: Color(0xFFFF6B35)),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2196F3),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: const Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
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
          color: const Color(0xFFF8F6F5).withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _hasUploadedPhoto
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RescuerResultConfirmationScreen(
                          requestData: widget.requestData,
                          missionId: widget.missionId,
                          capturedPhotos: _capturedPhotos,
                          notes: _notesController.text,
                        ),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _hasUploadedPhoto ? const Color(0xFFFF6B35) : const Color(0xFFDDDDDD),
              foregroundColor: _hasUploadedPhoto ? Colors.white : const Color(0xFF999999),
              elevation: 0,
              disabledBackgroundColor: const Color(0xFFDDDDDD),
              disabledForegroundColor: const Color(0xFF999999),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_hasUploadedPhoto)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.lock, size: 20),
                  ),
                Text(
                  _hasUploadedPhoto ? 'HOÀN THÀNH BẮT RẮN' : 'CẦN ÍT NHẤT 1 ẢNH',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
