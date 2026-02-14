import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'rescuer_result_confirmation_screen.dart';

/// Màn hình quá trình cứu hộ - đang bắt rắn
class RescuerTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> requestData;
  
  const RescuerTrackingScreen({
    super.key,
    required this.requestData,
  });

  @override
  State<RescuerTrackingScreen> createState() => _RescuerTrackingScreenState();
}

class _RescuerTrackingScreenState extends State<RescuerTrackingScreen> {
  final List<File> _capturedPhotos = [];
  final TextEditingController _notesController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _hasUploadedPhoto = false;

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
      
      if (photo != null) {
        setState(() {
          _capturedPhotos.add(File(photo.path));
          _hasUploadedPhoto = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi chụp ảnh: $e')),
      );
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
                _buildEmergencySection(),
                
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
              child: Image.network(
                widget.requestData['image'] ?? 'https://picsum.photos/400/300',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image, size: 32, color: Color(0xFFCCCCCC));
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.requestData['title'] ?? 'Rắn Hổ Mang',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD90429),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Có độc',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Text(
                      'Cực kỳ nguy hiểm',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD90429),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                'Chụp Ảnh Quá Trình',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(width: 4),
              Text(
                '*Bắt buộc',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFDC3545),
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
              child: Column(
                children: const [
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
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 96,
            height: 96,
            color: const Color(0xFFE0E0E0),
            child: Image.file(
              imageFile,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: IconButton(
              icon: const Icon(Icons.close, size: 14, color: Colors.white),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              onPressed: () {
                setState(() {
                  _capturedPhotos.removeAt(index);
                  if (_capturedPhotos.isEmpty) {
                    _hasUploadedPhoto = false;
                  }
                });
              },
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

  Widget _buildEmergencySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Call emergency
              },
              icon: const Icon(Icons.call, size: 20),
              label: const Text(
                'Gọi Hỗ Trợ Khẩn Cấp',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC3545),
                side: const BorderSide(color: Color(0xFFDC3545), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              // TODO: Contact expert
            },
            child: const Text(
              'Liên hệ Expert',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2196F3),
              ),
            ),
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
                const Text(
                  'HOÀN THÀNH BẮT RẮN',
                  style: TextStyle(
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
