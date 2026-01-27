import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';import 'package:go_router/go_router.dart';import 'dart:io';
import 'snake_identification_result_screen.dart';
import 'snake_selection_by_location_screen.dart';
import '../../../shared/widgets/custom_dialog.dart';

/// Snake Identification Screen - Camera and image upload for snake identification
class SnakeIdentificationScreen extends StatefulWidget {
  const SnakeIdentificationScreen({super.key});

  @override
  State<SnakeIdentificationScreen> createState() =>
      _SnakeIdentificationScreenState();
}

class _SnakeIdentificationScreenState extends State<SnakeIdentificationScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _flashOn = false;
  File? _selectedImage;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
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
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
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
      // Request storage permission
      final status = await Permission.photos.request();
      
      if (status.isDenied) {
        _showError('Cần cấp quyền truy cập ảnh');
        return;
      }
      
      if (status.isPermanentlyDenied) {
        _showPermissionDialog();
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        _processImage();
      }
    } catch (e) {
      _showError('Không thể chọn ảnh: $e');
    }
  }

  void _processImage() {
    if (_selectedImage == null) return;

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang phân tích ảnh bằng AI...'),
        backgroundColor: Color(0xFF228B22),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Simulate AI processing then navigate to results
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.push(
          '/emergency/snake-identification-result',
          extra: _selectedImage!,
        );
      }
    });
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

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cần cấp quyền'),
        content: const Text(
          'Ứng dụng cần quyền truy cập camera và ảnh để nhận diện rắn. Vui lòng cấp quyền trong Cài đặt.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF228B22),
            ),
            child: const Text('Mở Cài đặt'),
          ),
        ],
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
        description: 'Bạn có thể chọn rắn theo vị trí hoặc liên hệ với chuyên gia để được tư vấn trực tiếp.',
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
              context.push('/emergency/snake-selection-location');
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
                      onPressed: () => context.pop(),
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
                        Text(
                          '⚠️ ',
                          style: TextStyle(fontSize: 16),
                        ),
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
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Camera preview or captured image
                          if (_selectedImage != null)
                            Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            )
                          else if (_isCameraInitialized && _cameraController != null)
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
                                    Shadow(
                                      color: Colors.black,
                                      blurRadius: 8,
                                    ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
            ),
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
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(8),
            ),
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
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8),
            ),
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
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(8),
            ),
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
            style: TextStyle(
              color: Color(0xFFE0E0E0),
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFE0E0E0),
                fontSize: 13,
              ),
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
              border: Border.all(
                color: const Color(0xFFBDBDBD),
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF333333),
              size: 24,
            ),
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
