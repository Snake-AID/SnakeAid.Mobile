import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'snake_selection_by_location_screen.dart';
import 'snake_identification_questions_screen.dart';
import '../../../shared/widgets/custom_dialog.dart';

class SnakeIdentificationScreen extends StatefulWidget {
  const SnakeIdentificationScreen({Key? key}) : super(key: key);

  @override
  State<SnakeIdentificationScreen> createState() =>
      _SnakeIdentificationScreenState();
}

class _SnakeIdentificationScreenState extends State<SnakeIdentificationScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isFlashOn = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      _processImage(image.path);
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _processImage(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _processImage(String imagePath) {
    // TODO: Implement AI recognition when ready
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng AI đang phát triển. Vui lòng chọn cách khác.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;

    try {
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  void _showNoImageDialog() {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        icon: Icons.info_outline,
        iconColor: Colors.blue,
        title: 'Không thể chụp ảnh?',
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bạn có thể nhận diện rắn bằng cách:',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            SizedBox(height: 16),
            Text(
              '• Chọn theo vị trí (các loài phổ biến)\n'
              '• Trả lời câu hỏi về đặc điểm rắn',
              style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            ),
          ],
        ),
        actions: [
          DialogAction(
            label: 'Đóng',
            onPressed: () => Navigator.pop(context),
            isPrimary: false,
          ),
          DialogAction(
            label: 'Chọn theo vị trí',
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SnakeSelectionByLocationScreen(),
                ),
              );
            },
            isPrimary: true,
            icon: Icons.location_on,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Preview
            if (_isInitialized && _cameraController != null)
              Positioned.fill(
                child: CameraPreview(_cameraController!),
              )
            else
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),

            // Corner brackets for framing
            if (_isInitialized) ...[
              // Top-left bracket
              Positioned(
                top: 100,
                left: 40,
                child: _buildCornerBracket(),
              ),
              // Top-right bracket
              Positioned(
                top: 100,
                right: 40,
                child: Transform.rotate(
                  angle: 1.5708, // 90 degrees
                  child: _buildCornerBracket(),
                ),
              ),
              // Bottom-left bracket
              Positioned(
                bottom: 200,
                left: 40,
                child: Transform.rotate(
                  angle: -1.5708, // -90 degrees
                  child: _buildCornerBracket(),
                ),
              ),
              // Bottom-right bracket
              Positioned(
                bottom: 200,
                right: 40,
                child: Transform.rotate(
                  angle: 3.1416, // 180 degrees
                  child: _buildCornerBracket(),
                ),
              ),
            ],

            // Top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Nhận diện rắn',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                      ),
                      onPressed: _toggleFlash,
                    ),
                  ],
                ),
              ),
            ),

            // Guide text
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Đưa camera vào khung để chụp ảnh rắn',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Main action buttons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Gallery button
                        _buildActionButton(
                          icon: Icons.photo_library,
                          label: 'Thư viện',
                          onPressed: _pickImage,
                        ),

                        // Capture button
                        GestureDetector(
                          onTap: _takePicture,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),

                        // No image button
                        _buildActionButton(
                          icon: Icons.help_outline,
                          label: 'Không có ảnh',
                          onPressed: _showNoImageDialog,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Alternative identification methods
                    const Text(
                      'HOẶC CHỌN CÁCH KHÁC',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildMethodButton(
                            icon: Icons.location_on,
                            label: 'Chọn theo vị trí',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SnakeSelectionByLocationScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMethodButton(
                            icon: Icons.quiz,
                            label: 'Trả lời câu hỏi',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SnakeIdentificationQuestionsScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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

  Widget _buildCornerBracket() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white, width: 3),
          left: BorderSide(color: Colors.white, width: 3),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white, size: 28),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMethodButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
