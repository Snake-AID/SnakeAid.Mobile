import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'dart:io';
import 'snake_identification_result_screen.dart';
import '../../../shared/widgets/custom_dialog.dart';
import '../../models/sos_incident_response.dart';
import '../../repository/snake_ai_repository.dart';

/// Snake Identification Screen - Camera and image upload for snake identification
class SnakeIdentificationScreen extends ConsumerStatefulWidget {
  final IncidentData? incident;

  const SnakeIdentificationScreen({super.key, this.incident});

  @override
  ConsumerState<SnakeIdentificationScreen> createState() =>
      _SnakeIdentificationScreenState();
}

class _SnakeIdentificationScreenState
    extends ConsumerState<SnakeIdentificationScreen> {
  bool _flashOn = false;
  File? _selectedImage;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();

    if (widget.incident != null) {
      debugPrint('📸 Snake ID Screen - Incident ID: ${widget.incident!.id}');
    } else {
      debugPrint('⚠️ Snake ID Screen - No incident data');
    }

    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();

      if (status.isDenied || status.isPermanentlyDenied) {
        return;
      }

      // Get available cameras
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        return;
      }

      // Initialize camera controller with rear camera
      _cameraController = CameraController(
        _cameras!.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _takePicture() async {
    try {
      if (_cameraController == null ||
          !_cameraController!.value.isInitialized) {
        _showError('Camera chưa sẵn sàng');
        return;
      }

      // Capture image from camera
      final XFile photo = await _cameraController!.takePicture();

      setState(() {
        _selectedImage = File(photo.path);
      });
      _processImage();
    } catch (e) {
      _showError('Không thể chụp ảnh: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      // Request photo permission
      final PermissionState permissionState =
          await PhotoManager.requestPermissionExtend();

      if (permissionState != PermissionState.authorized &&
          permissionState != PermissionState.limited) {
        _showPermissionModal();
        return;
      }

      // Show asset picker with custom UI (bottom sheet style)
      final List<AssetEntity>? assets = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: 1,
          requestType: RequestType.image,
          specialPickerType: SpecialPickerType.noPreview,
          themeColor: const Color(0xFF228B22),
          textDelegate: const AssetPickerTextDelegate(),
        ),
      );

      if (assets != null && assets.isNotEmpty) {
        // Convert AssetEntity to File
        final File? file = await assets.first.file;

        if (file != null) {
          setState(() {
            _selectedImage = file;
          });
          _processImage();
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error picking image: $e');
      // If permission is needed, show modal
      if (e.toString().contains('permission') ||
          e.toString().contains('denied')) {
        _showPermissionModal();
      } else {
        _showError('Không thể chọn ảnh: $e');
      }
    }
  }

  void _processImage() async {
    if (_selectedImage == null) return;

    // Check if we have incident data
    if (widget.incident == null) {
      _showError('Không tìm thấy thông tin yêu cầu SOS');
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AnalyzingLoadingDialog(),
    );

    try {
      // Step 1: Upload image
      final repository = ref.read(snakeAiRepositoryProvider);
      final uploadResponse = await repository.uploadSnakeImage(
        incidentId: widget.incident!.id,
        imageFile: _selectedImage!,
      );

      if (!uploadResponse.isSuccess || uploadResponse.data == null) {
        throw Exception(uploadResponse.message);
      }

      final mediaId = uploadResponse.data!.id;
      debugPrint('✅ Media ID: $mediaId');

      // Step 2: Detect snake
      final detectionResponse = await repository.detectSnake(
        reportMediaId: mediaId,
      );

      if (!detectionResponse.isSuccess || detectionResponse.data == null) {
        throw Exception(detectionResponse.message);
      }

      if (mounted) {
        // Close loading dialog
        Navigator.pop(context);

        // Wait for Navigator to unlock before pushing new route
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // Use push instead of pushReplacement for page-based routes
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SnakeIdentificationResultScreen(
                  snakeImage: _selectedImage!,
                  detectionData: detectionResponse.data!,
                  incident: widget.incident!,
                ),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      setState(() {
        _flashOn = !_flashOn;
      });

      await _cameraController!.setFlashMode(
        _flashOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFDC3545),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showPermissionModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                size: 36,
                color: Color(0xFFFF9800),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            const Text(
              'Cần quyền truy cập bộ nhớ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 10),
            // Description
            const Text(
              'Để chọn ảnh từ thư viện, ứng dụng cần được cấp quyền truy cập bộ nhớ. Nhấn "Mở Cài đặt" để cấp quyền ngay.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            // Open Settings button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                icon: const Icon(Icons.settings_outlined, size: 20),
                label: const Text(
                  'Mở Cài đặt',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF228B22),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Cancel button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
                child: const Text(
                  'Để sau',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF666666),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoImageDialog() {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        icon: Icons.photo_camera_outlined,
        iconBackgroundColor: const Color(0xFFFFF3E0),
        iconColor: const Color(0xFFFF9800),
        title: 'Không có ảnh rắn?',
        description:
            'Bạn có thể chọn rắn theo vị trí hoặc liên hệ với chuyên gia để được tư vấn trực tiếp.',
        actions: [
          DialogAction(
            label: 'Đóng',
            onPressed: () => context.pop(),
            isOutlined: true,
          ),
          DialogAction(
            label: 'Chọn theo vị trí',
            onPressed: () {
              context.pop();
              context.goNamed(
                'snake_selection_by_location',
                extra: {'incident': widget.incident},
              );
            },
            backgroundColor: const Color(0xFF228B22),
            icon: Icons.location_on,
            flex: 2,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Header
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.goNamed('emergency_alert');
                        }
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Nhận diện rắn',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.help_outline),
                      onPressed: () {
                        _showHelpDialog();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Camera Viewfinder Area (70%)
          Expanded(
            flex: 7,
            child: Container(
              color: const Color(0xFF2C2C2C),
              child: Column(
                children: [
                  // Warning Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: const Color(0xFFFFF3CD),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('⚠️ ', style: TextStyle(fontSize: 16)),
                        Text(
                          'Giữ khoảng cách an toàn - KHÔNG đến gần rắn',
                          style: TextStyle(
                            color: Color(0xFF664D03),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Viewfinder Frame
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Camera preview or captured image
                          if (_selectedImage != null)
                            Image.file(_selectedImage!, fit: BoxFit.cover)
                          else if (_isCameraInitialized &&
                              _cameraController != null)
                            CameraPreview(_cameraController!)
                          else
                            Container(
                              color: const Color(0xFF2C2C2C),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),

                          // Corner brackets overlay
                          ..._buildCornerBrackets(),

                          // Center guide text (only show when camera is active)
                          if (_selectedImage == null && _isCameraInitialized)
                            const Center(
                              child: Text(
                                'Đặt con rắn vào giữa khung hình',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  shadows: [
                                    Shadow(color: Colors.black, blurRadius: 8),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Tips Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mẹo để có kết quả tốt nhất:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTipItem('Chụp toàn thân nếu có thể'),
                        _buildTipItem('Tập trung vào đầu và hoa văn'),
                        _buildTipItem('Chụp từ khoảng cách an toàn'),
                        _buildTipItem('Sử dụng zoom nếu cần'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Controls (30%)
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.white,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Action Buttons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Upload Image Button
                          _buildActionButton(
                            icon: Icons.photo_library,
                            label: 'Tải ảnh lên',
                            onTap: _pickImage,
                          ),

                          // Camera Button (Large)
                          GestureDetector(
                            onTap: _takePicture,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFBDBDBD),
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE0E0E0),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),

                          // Flash Toggle Button
                          _buildActionButton(
                            icon: _flashOn ? Icons.flash_on : Icons.flash_off,
                            label: _flashOn ? 'Flash: Bật' : 'Flash: Tắt',
                            onTap: _toggleFlash,
                          ),
                        ],
                      ),

                      // No Image Link
                      TextButton(
                        onPressed: _showNoImageDialog,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Tôi không có ảnh rắn',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF666666),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: Color(0xFF666666),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCornerBrackets() {
    const bracketSize = 40.0;
    const bracketWidth = 4.0;
    const bracketColor = Colors.white;

    return [
      // Top-left
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: bracketSize,
          height: bracketSize,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: bracketColor, width: bracketWidth),
              left: BorderSide(color: bracketColor, width: bracketWidth),
            ),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(8)),
          ),
        ),
      ),
      // Top-right
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: bracketSize,
          height: bracketSize,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: bracketColor, width: bracketWidth),
              right: BorderSide(color: bracketColor, width: bracketWidth),
            ),
            borderRadius: BorderRadius.only(topRight: Radius.circular(8)),
          ),
        ),
      ),
      // Bottom-left
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: bracketSize,
          height: bracketSize,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: bracketColor, width: bracketWidth),
              left: BorderSide(color: bracketColor, width: bracketWidth),
            ),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8)),
          ),
        ),
      ),
      // Bottom-right
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: bracketSize,
          height: bracketSize,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: bracketColor, width: bracketWidth),
              right: BorderSide(color: bracketColor, width: bracketWidth),
            ),
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(8)),
          ),
        ),
      ),
    ];
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 13),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFBDBDBD), width: 2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF333333), size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Color(0xFF228B22)),
            SizedBox(width: 8),
            Text('Hướng dẫn sử dụng'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cách chụp ảnh tốt nhất:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text('1. Giữ khoảng cách an toàn (tối thiểu 2-3 mét)'),
              SizedBox(height: 4),
              Text('2. Đảm bảo ánh sáng đủ sáng'),
              SizedBox(height: 4),
              Text('3. Chụp rõ phần đầu và thân rắn'),
              SizedBox(height: 4),
              Text('4. Tránh rung lắc khi chụp'),
              SizedBox(height: 12),
              Text(
                'Lưu ý an toàn:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFFDC3545),
                ),
              ),
              SizedBox(height: 8),
              Text('⚠️ KHÔNG bao giờ tiếp cận gần rắn'),
              SizedBox(height: 4),
              Text('⚠️ KHÔNG cố gắng bắt hoặc làm phiền rắn'),
              SizedBox(height: 4),
              Text('⚠️ Gọi cứu hộ ngay nếu bị cắn'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }
}

class AnalyzingLoadingDialog extends StatefulWidget {
  const AnalyzingLoadingDialog({super.key});

  @override
  State<AnalyzingLoadingDialog> createState() => _AnalyzingLoadingDialogState();
}

class _AnalyzingLoadingDialogState extends State<AnalyzingLoadingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentStep = 0;

  final List<String> _steps = [
    'Đang phân tích ảnh...',
    'Nhận diện đặc điểm rắn...',
    'So sánh với cơ sở dữ liệu...',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Cycle through steps
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _currentStep = 1);
      }
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _currentStep = 2);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated loading indicator
            RotationTransition(
              turns: _controller,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 4),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFF228B22),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Processing text
            Text(
              _steps[_currentStep],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF191910),
              ),
            ),
            const SizedBox(height: 12),

            // Progress indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index <= _currentStep
                        ? const Color(0xFF228B22)
                        : const Color(0xFFE5E7EB),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
