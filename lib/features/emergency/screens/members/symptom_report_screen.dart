import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'severity_assessment_screen.dart';

class SymptomReportScreen extends StatefulWidget {
  const SymptomReportScreen({super.key});

  @override
  State<SymptomReportScreen> createState() => _SymptomReportScreenState();
}

class _SymptomReportScreenState extends State<SymptomReportScreen> {
  File? _biteImage;
  final ImagePicker _picker = ImagePicker();
  
  // Symptom checkboxes
  final Map<String, bool> _symptoms = {
    'Đau tại chỗ bị cắn': false,
    'Sưng tấy': false,
    'Tê/Ngứa ran': false,
    'Buồn nôn/Nôn': false,
    'Khó thở': false,
    'Mờ mắt': false,
    'Đổ mồ hôi nhiều': false,
    'Chảy máu từ vết thương': false,
    'Triệu chứng khác': false,
  };

  double _painLevel = 5.0;
  String _timeSinceBite = '15 phút trước';
  final TextEditingController _otherInfoController = TextEditingController();

  @override
  void dispose() {
    _otherInfoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _biteImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi chọn ảnh: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF228B22)),
              title: const Text('Chụp ảnh'),
              onTap: () {
                context.pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF228B22)),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                context.pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _analyzeSymptoms() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AnalyzingLoadingDialog(),
    );

    // Simulate backend processing
    await Future.delayed(const Duration(seconds: 3));

    // Collect selected symptoms
    final selectedSymptoms = _symptoms.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    // Calculate severity score based on symptoms (MOCK - should come from backend)
    int severityScore = 50; // Base score
    
    // High risk symptoms increase score
    if (selectedSymptoms.contains('Khó thở')) severityScore += 20;
    if (selectedSymptoms.contains('Mờ mắt')) severityScore += 15;
    if (selectedSymptoms.contains('Buồn nôn/Nôn')) severityScore += 10;
    if (selectedSymptoms.contains('Sưng tấy')) severityScore += 10;
    if (selectedSymptoms.contains('Tê/Ngứa ran')) severityScore += 10;
    
    // Pain level affects severity
    severityScore += (_painLevel * 2).toInt();
    
    // Time since bite affects severity (earlier = more critical)
    if (_timeSinceBite == '15 phút trước') severityScore += 5;
    
    // Cap at 100
    severityScore = severityScore.clamp(0, 100);

    // Build risk factors list (MOCK - should come from backend)
    final riskFactors = <String>[];
    if (selectedSymptoms.contains('Khó thở')) {
      riskFactors.add('Phát hiện khó thở');
    }
    if (_painLevel >= 6) {
      riskFactors.add('Mức độ đau cao ($_painLevel/10)');
    }
    if (selectedSymptoms.contains('Sưng tấy') || selectedSymptoms.contains('Tê/Ngứa ran')) {
      riskFactors.add('Sưng tấy và tê bỏi');
    }
    riskFactors.add('Xác nhận rắn độc');

    // Close loading dialog
    if (mounted) {
      context.pop();
      
      // Navigate to severity assessment screen
      context.pushNamed(
        'severity_assessment',
        extra: {
          'severityScore': severityScore,
          'riskFactors': riskFactors,
          'timeSinceBite': _timeSinceBite,
          'painLevel': _painLevel.round(),
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF191910)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('snake_selection_by_location');
            }
          },
        ),
        title: const Text(
          'Báo cáo triệu chứng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191910),
          ),
        ),
        centerTitle: true,
       
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE5E5E5),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bite Image Upload
              _buildBiteImageSection(),
              const SizedBox(height: 24),

              // Symptoms Checklist
              _buildSymptomsSection(),
              const SizedBox(height: 24),

              // Pain Level Slider
              _buildPainLevelSection(),
              const SizedBox(height: 24),

              // Time Since Bite
              _buildTimeSinceBiteSection(),
              const SizedBox(height: 24),

              // Other Info
              _buildOtherInfoSection(),
              const SizedBox(height: 32),

              // Submit Button
              _buildSubmitButton(),
              
              // Skip Link
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Bỏ qua bước này',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBiteImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ảnh chụp vết cắn',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191910),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: Container(
            width: double.infinity,
            height: _biteImage != null ? 250 : 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD1D5DB),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: _biteImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _biteImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_camera,
                        size: 48,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Chạm để chụp hoặc tải ảnh lên',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Điều này giúp đánh giá mức độ nghiêm trọng.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn các triệu chứng bạn đang gặp phải:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191910),
          ),
        ),
        const SizedBox(height: 16),
        ..._symptoms.keys.map((symptom) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _symptoms[symptom],
                    onChanged: (value) {
                      setState(() {
                        _symptoms[symptom] = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF228B22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    symptom,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF191910),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPainLevelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bạn đánh giá cơn đau như thế nào? (1-10)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191910),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            _painLevel.round().toString(),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF191910),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            activeTrackColor: const Color(0xFF228B22),
            inactiveTrackColor: const Color(0xFFE5E7EB),
            thumbColor: Colors.white,
            overlayColor: const Color(0xFF228B22).withOpacity(0.2),
          ),
          child: Slider(
            value: _painLevel,
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                _painLevel = value;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '1 Nhẹ',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              '10 Nặng',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeSinceBiteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thời gian kể từ khi bị cắn:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191910),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD1D5DB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _timeSinceBite,
              isExpanded: true,
              icon: const Icon(Icons.expand_more, color: Color(0xFF6B7280)),
              items: [
                '15 phút trước',
                '30 phút trước',
                '1 giờ trước',
                'Hơn 1 giờ trước',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF191910),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _timeSinceBite = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtherInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin khác? (tùy chọn)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191910),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _otherInfoController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Mô tả bất kỳ triệu chứng nào khác...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF228B22), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _analyzeSymptoms,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF228B22),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(double.infinity, 56),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Phân tích triệu chứng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward, size: 20),
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
    'Đang phân tích triệu chứng...',
    'Đánh giá mức độ nguy hiểm...',
    'Xác định yếu tố rủi ro...',
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
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 4,
                  ),
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
