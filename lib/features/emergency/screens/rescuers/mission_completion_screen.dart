import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../repository/media_repository.dart';
import '../../providers/mission_detail_provider.dart';
import '../../providers/mission_hub_provider.dart';
import '../../providers/active_mission_provider.dart';
import '../../providers/rescuer_emergency_provider.dart';
import '../../providers/hospital_provider.dart';
import '../../../rescuer/providers/tracking_provider.dart';

class MissionCompletionScreen extends ConsumerStatefulWidget {
  final String missionId;
  final String incidentId;

  const MissionCompletionScreen({
    super.key,
    required this.missionId,
    required this.incidentId,
  });

  @override
  ConsumerState<MissionCompletionScreen> createState() =>
      _MissionCompletionScreenState();
}

enum _EvidenceUploadStatus { pending, uploading, success, failed }

class _EvidencePhoto {
  final File file;
  String? mediaId;
  _EvidenceUploadStatus status;
  String? errorMessage;

  _EvidencePhoto({required this.file, _EvidenceUploadStatus? status})
    : status = status ?? _EvidenceUploadStatus.pending;
}

class _MissionCompletionScreenState
    extends ConsumerState<MissionCompletionScreen> {
  final TextEditingController _notesController = TextEditingController();
  final List<_EvidencePhoto> _evidencePhotos = [];
  final ImagePicker _picker = ImagePicker();

  bool _isCompleting = false;

  static const int minEvidencePhotos = 1;
  static const int maxEvidencePhotos = 3;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Check max limit
    if (_evidencePhotos.length >= maxEvidencePhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Chỉ có thể upload tối đa $maxEvidencePhotos ảnh bằng chứng',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Request camera permission
    final status = await Permission.camera.request();

    if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cần quyền truy cập camera để chụp ảnh'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Vui lòng bật quyền camera trong Cài đặt'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Cài đặt',
              textColor: Colors.white,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85, // Compress to reduce size
    );

    if (image != null) {
      final file = File(image.path);
      setState(() {
        _evidencePhotos.add(
          _EvidencePhoto(file: file, status: _EvidenceUploadStatus.uploading),
        );
      });
      _uploadEvidencePhoto(_evidencePhotos.length - 1);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _evidencePhotos.removeAt(index);
    });
  }

  bool get _hasUploadedMedia =>
      _evidencePhotos.any((photo) => photo.mediaId != null);

  bool get _isAnyUploading => _evidencePhotos.any(
    (photo) => photo.status == _EvidenceUploadStatus.uploading,
  );

  bool get _canComplete =>
      _hasUploadedMedia && !_isAnyUploading && !_isCompleting;

  Future<void> _handleComplete() async {
    if (_evidencePhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chụp ít nhất 1 ảnh bằng chứng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_hasUploadedMedia) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng upload ít nhất 1 ảnh thành công trước khi hoàn thành',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isAnyUploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng chờ upload ảnh hoàn tất trước khi hoàn thành',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _showConfirmationDialog();
  }

  Future<void> _uploadEvidencePhoto(int index) async {
    if (index < 0 || index >= _evidencePhotos.length) return;

    final photo = _evidencePhotos[index];
    setState(() {
      photo.status = _EvidenceUploadStatus.uploading;
      photo.errorMessage = null;
    });

    try {
      final mediaRepository = ref.read(mediaRepositoryProvider);
      final mediaId = await mediaRepository.uploadEvidencePhoto(
        imageFile: photo.file,
        missionId: widget.missionId,
      );

      if (!mounted) return;
      setState(() {
        photo.status = _EvidenceUploadStatus.success;
        photo.mediaId = mediaId;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        photo.status = _EvidenceUploadStatus.failed;
        photo.errorMessage = e.toString().replaceAll('Exception: ', '');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Upload ảnh thất bại: ${photo.errorMessage ?? 'Vui lòng thử lại'}',
          ),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Thử lại',
            textColor: Colors.white,
            onPressed: () => _retryUpload(index),
          ),
        ),
      );
    }
  }

  Future<void> _retryUpload(int index) async {
    if (index < 0 || index >= _evidencePhotos.length) return;
    await _uploadEvidencePhoto(index);
  }

  Future<void> _completeMission() async {
    setState(() => _isCompleting = true);

    final evidenceMediaIds = _evidencePhotos
        .where((photo) => photo.mediaId != null)
        .map((photo) => photo.mediaId!)
        .toList();

    try {
      final success = await ref
          .read(missionDetailProvider.notifier)
          .completeMission(
            evidenceMediaIds: evidenceMediaIds,
            completionNotes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );

      if (!mounted) return;

      setState(() => _isCompleting = false);

      if (success) {
        ref.read(locationManagerProvider).stopMissionTracking();
        await ref.read(missionHubConnectionProvider.notifier).disconnect();

        await ref.read(activeMissionProvider.notifier).clearActiveMission();
        debugPrint('✅ Active mission cleared after completion');

        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('🔄 Reconnecting to RescuerHub...');
        debugPrint('   Reason: Mission completed, ready for new requests');
        try {
          final prefs = await SharedPreferences.getInstance();
          final rescuerId = prefs.getString('user_id');
          if (rescuerId != null) {
            await ref.read(locationManagerProvider).startTracking(rescuerId);
            debugPrint('✅ Restarted idle tracking after mission completion');
            await ref
                .read(rescueModeProvider.notifier)
                .startRescueMode(rescuerId);
            debugPrint('✅ Reconnected to RescuerHub successfully');
          }
        } catch (e) {
          debugPrint('⚠️ Failed to reconnect RescuerHub: $e');
        }
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        if (!mounted) return;
        context.go('/rescuer/mission-success');
      } else {
        final error = ref.read(missionDetailProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Lỗi khi hoàn thành nhiệm vụ'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCompleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8800).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Color(0xFFFF8800),
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Xác nhận hoàn thành?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C100D),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Bạn đã upload ${_evidencePhotos.where((p) => p.mediaId != null).length} ảnh bằng chứng thành công. Sau khi xác nhận, nhiệm vụ sẽ được hoàn thành và không thể chỉnh sửa.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF666666),
                        side: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        _completeMission();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8800),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Xác nhận'),
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

  @override
  Widget build(BuildContext context) {
    final missionState = ref.watch(missionDetailProvider);
    final mission = missionState.mission;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      body: Column(
        children: [
          // Header
          SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7F5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Color(0xFF1C100D),
                    ),
                    onPressed: () => context.pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Expanded(
                    child: Text(
                      'Hoàn Thành Nhiệm Vụ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C100D),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFFFF8800),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Success Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4EDDA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.task_alt,
                          color: Color(0xFF155724),
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Nhiệm Vụ Hoàn Thành Thành Công',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF155724),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Mission Summary Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tóm Tắt Nhiệm Vụ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C100D),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 40,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Color(0xFF155724),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildCleanInfoRow(
                                label: 'Thời gian',
                                value: mission?.formattedElapsedTime ?? '-',
                                valueColor: const Color(0xFFFF8800),
                                icon: Icons.access_time_rounded,
                              ),
                              const SizedBox(height: 14),
                              _buildCleanInfoRow(
                                label: 'Bệnh nhân',
                                value: mission?.user.account?.fullName ?? '-',
                                valueColor: const Color(0xFF1C100D),
                                icon: Icons.person_outline_rounded,
                              ),
                              const SizedBox(height: 14),
                              _buildCleanInfoRow(
                                label: 'Địa điểm',
                                value: mission?.incident.address ?? '-',
                                valueColor: const Color(0xFF1C100D),
                                icon: Icons.location_on_outlined,
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.pest_control_outlined,
                                      size: 18,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Loài rắn',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF666666),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        mission
                                                ?.incident
                                                .identifiedSnakeSpecies
                                                ?.commonName ??
                                            '-',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1C100D),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (mission
                                              ?.incident
                                              .identifiedSnakeSpecies
                                              ?.riskLevel !=
                                          null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getRiskLevelColor(
                                              mission!
                                                  .incident
                                                  .identifiedSnakeSpecies!
                                                  .riskLevel,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            _getRiskLevelText(
                                              mission
                                                  .incident
                                                  .identifiedSnakeSpecies!
                                                  .riskLevel,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8800).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFFF8800).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.camera_alt_rounded,
                                size: 16,
                                color: Color(0xFFFF8800),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'CHỜ XÁC NHẬN',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF8800),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Patient Outcome Card (read-only)
                  _buildPatientOutcomeReadOnly(),

                  const SizedBox(height: 16),

                  // Evidence Photos (Required)
                  Row(
                    children: [
                      const Text(
                        'Ảnh Bằng Chứng',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C100D),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Bắt buộc',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tối thiểu $minEvidencePhotos ảnh, tối đa $maxEvidencePhotos ảnh (${_evidencePhotos.length}/$maxEvidencePhotos)',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _evidencePhotos.isEmpty
                            ? Colors.red.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    child: SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ..._evidencePhotos.asMap().entries.map((entry) {
                            final index = entry.key;
                            final photo = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      photo.file,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  if (photo.status ==
                                      _EvidenceUploadStatus.uploading)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.35),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Center(
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            photo.status ==
                                                _EvidenceUploadStatus.success
                                            ? Colors.green.withOpacity(0.9)
                                            : photo.status ==
                                                  _EvidenceUploadStatus.failed
                                            ? Colors.red.withOpacity(0.9)
                                            : Colors.black.withOpacity(0.55),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            photo.status ==
                                                    _EvidenceUploadStatus
                                                        .success
                                                ? Icons.check_circle
                                                : photo.status ==
                                                      _EvidenceUploadStatus
                                                          .failed
                                                ? Icons.error
                                                : Icons.cloud_upload,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            photo.status ==
                                                    _EvidenceUploadStatus
                                                        .success
                                                ? 'Đã upload'
                                                : photo.status ==
                                                      _EvidenceUploadStatus
                                                          .failed
                                                ? 'Thất bại'
                                                : 'Đang upload',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (photo.status ==
                                      _EvidenceUploadStatus.failed)
                                    Positioned(
                                      bottom: 8,
                                      left: 8,
                                      right: 8,
                                      child: ElevatedButton(
                                        onPressed: () => _retryUpload(index),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white
                                              .withOpacity(0.9),
                                          foregroundColor: Colors.red,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6,
                                          ),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Thử lại',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                          if (_evidencePhotos.length < maxEvidencePhotos)
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F0F0),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                    width: 2,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      color: Color(0xFF999999),
                                      size: 32,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Chụp ảnh',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF999999),
                                        fontWeight: FontWeight.w600,
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

                  const SizedBox(height: 16),

                  // Payment Information Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thông Tin Thanh Toán',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C100D),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 40,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Color(0xFFFF8800),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFFFF8800).withOpacity(0.08),
                                const Color(0xFFFF8800).withOpacity(0.03),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFF8800).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Tổng cộng',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF666666),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    mission?.formattedActualCost ?? '-',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF8800),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.grey.withOpacity(0.1),
                                      Colors.grey.withOpacity(0.3),
                                      Colors.grey.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Phí dịch vụ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF666666),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    mission?.formattedPrice ?? '-',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 0, 151, 88),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.grey.withOpacity(0.1),
                                      Colors.grey.withOpacity(0.3),
                                      Colors.grey.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Phí di chuyển',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF666666),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    mission?.formattedCostFromCenter ?? "-",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 0, 151, 88),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.grey.withOpacity(0.1),
                                      Colors.grey.withOpacity(0.3),
                                      Colors.grey.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Thời gian thực hiện',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF666666),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    mission?.formattedElapsedTime ?? '-',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1C100D),
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

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Bottom Action Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7F5),
              border: Border(
                top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _canComplete ? _handleComplete : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8800),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: _isCompleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'XÁC NHẬN HOÀN THÀNH',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientOutcomeReadOnly() {
    final hospitalState = ref.watch(hospitalProvider);
    final needsHospital = hospitalState.hasSelectedHospital;
    final hospitalName = hospitalState.selectedHospitalPricing?.hospitalName;

    final outcomeLabel = needsHospital
        ? 'Cần đưa đến bệnh viện'
        : 'Ổn định - Không cần cấp cứu';
    final outcomeColor = needsHospital
        ? const Color(0xFFDC3545)
        : const Color(0xFF28A745);
    final outcomeIcon = needsHospital
        ? Icons.local_hospital_rounded
        : Icons.check_circle_rounded;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kết Quả Hỗ Trợ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C100D),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: outcomeColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: outcomeColor.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Icon(outcomeIcon, color: outcomeColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        outcomeLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: outcomeColor,
                        ),
                      ),
                      if (hospitalName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          hospitalName,
                          style: TextStyle(
                            fontSize: 12,
                            color: outcomeColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Tự động',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF999999),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ghi chú bổ sung (không bắt buộc)',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFFF8800),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanInfoRow({
    required String label,
    required String value,
    required Color valueColor,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF666666)),
        ),
        const SizedBox(width: 12),

        Expanded(
          flex: 3,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          flex: 5,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            textAlign: TextAlign.right,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Color _getRiskLevelColor(int riskLevel) {
    if (riskLevel >= 7) {
      return const Color(0xFFDC3545); // High risk - red
    } else if (riskLevel >= 4) {
      return const Color(0xFFFF8800); // Medium risk - orange
    } else {
      return const Color(0xFF28A745); // Low risk - green
    }
  }

  String _getRiskLevelText(int riskLevel) {
    if (riskLevel >= 7) {
      return 'CỰC ĐỘC';
    } else if (riskLevel >= 3) {
      return 'TRUNG BÌNH';
    } else {
      return 'THẤP';
    }
  }
}
