import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../models/snake_detection_response.dart';
import '../../models/sos_incident_response.dart';

/// Snake Identification Result Screen
/// Shows AI identification results with danger level and first aid instructions
class SnakeIdentificationResultScreen extends StatefulWidget {
  final File snakeImage;
  final DetectionData detectionData;
  final IncidentData incident;
  
  const SnakeIdentificationResultScreen({
    super.key,
    required this.snakeImage,
    required this.detectionData,
    required this.incident,
  });

  @override
  State<SnakeIdentificationResultScreen> createState() =>
      _SnakeIdentificationResultScreenState();
}

class _SnakeIdentificationResultScreenState
    extends State<SnakeIdentificationResultScreen> {
  bool _showDetails = false;
  
  @override
  void initState() {
    super.initState();
    _saveRecognitionResultId();
  }

  Future<void> _saveRecognitionResultId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final incidentId = widget.incident.id;
      final recognitionResultId = widget.detectionData.recognitionResultId;
      
      await prefs.setString('recognition_result_$incidentId', recognitionResultId);
      debugPrint('✅ Saved recognition result ID: $recognitionResultId for incident: $incidentId');
    } catch (e) {
      debugPrint('❌ Error saving recognition result ID: $e');
    }
  }
  
  // Get first detection result
  DetectionResult? get _result => widget.detectionData.results.isNotEmpty 
      ? widget.detectionData.results.first 
      : null;
  
  SnakeInfo? get _snake => _result?.snake;
  AiDetection? get _aiDetection => _result?.aiDetection;
  
  // Calculate risk level text
  String get _riskLevelText {
    if (_snake == null) return 'TRUNG BÌNH';
    if (_snake!.riskLevel >= 8) return 'CAO';
    if (_snake!.riskLevel >= 5) return 'TRUNG BÌNH';
    return 'THẤP';
  }
  
  // Calculate risk color
  Color get _riskColor {
    if (_snake == null) return const Color(0xFFFFC107);
    if (_snake!.riskLevel >= 8) return const Color(0xFFDC3545);
    if (_snake!.riskLevel >= 5) return const Color(0xFFFFC107);
    return const Color(0xFF28A745);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
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
                        'Kết quả nhận diện',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        // TODO: Share functionality
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Warning Banner
          Container(
            width: double.infinity,
            color: _snake?.isVenomous == true 
                ? const Color(0xFFDC3545) 
                : const Color(0xFF228B22),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              _snake?.isVenomous == true 
                  ? '⚠️ PHÁT HIỆN RẮN ĐỘC' 
                  : '✓ RẮN KHÔNG ĐỘC',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Snake Info Card
                  _buildSnakeInfoCard(),
                  const SizedBox(height: 16),

                  // Danger Level Card
                  _buildDangerLevelCard(),
                  const SizedBox(height: 16),

                  // First Aid Instructions
                  _buildFirstAidCard(),
                  const SizedBox(height: 16),

                  // Details Section
                  _buildDetailsSection(),
                  const SizedBox(height: 16),

                  // Report Button
                  OutlinedButton(
                    onPressed: () {
                      // Navigate to first aid steps screen
                      if (_result != null) {
                        context.pushNamed(
                          'first_aid_steps',
                          extra: {
                            'detectionResult': _result,
                            'incident': widget.incident,
                            'recognitionResultId': widget.detectionData.recognitionResultId,
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Không có kết quả nhận diện')),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF666666),
                      side: const BorderSide(
                        color: Color(0xFF999999),
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text(
                      'Báo cáo lần nhìn thấy này',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Retake Link
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text(
                      'Không đúng? Chụp lại',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnakeInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Snake Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.file(
                widget.snakeImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // English Name
          Text(
            _snake?.commonName ?? 'Đang xác định...',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 4),

          // Scientific Name
          Text(
            _snake?.scientificName ?? '',
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 4),

          // Vietnamese Name  
          if (_snake != null)
            Text(
              _snake!.commonName,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF333333),
              ),
            ),
          const SizedBox(height: 12),

          // Confidence Level
          Text(
            'Độ tin cậy AI: ${((_aiDetection?.confidence ?? 0) * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerLevelCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Risk Level Badge at top
         
          const SizedBox(height: 20),
          
          // Gradient Progress Bar
          LayoutBuilder(
            builder: (context, constraints) {
              final riskLevel = _snake?.riskLevel ?? 5;
              // Calculate position (0-10 scale), clamp between 0 and 1
              final progress = (riskLevel / 10).clamp(0.0, 1.0);
              
              return Column(
                children: [
                  // Progress bar with marker
                  SizedBox(
                    height: 32,
                    child: Stack(
                      children: [
                        // Background gradient bar
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 10,
                          child: Container(
                            height: 12,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF28A745), // Green
                                  Color(0xFFFFC107), // Yellow  
                                  Color(0xFFDC3545), // Red
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Marker indicator
                        Positioned(
                          left: (constraints.maxWidth - 16) * progress,
                          top: 0,
                          child: Container(
                            width: 16,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _riskColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Labels below bar
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'THẤP',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF28A745),
                        ),
                      ),
                      Text(
                        'TRUNG BÌNH',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFC107),
                        ),
                      ),
                      Text(
                        'CAO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFDC3545),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Danger Level Text
          Text(
            'Mức độ nguy hiểm: $_riskLevelText',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _riskColor,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _snake?.isVenomous == true 
                      ? Icons.warning_amber_rounded 
                      : Icons.info_outline,
                  color: const Color(0xFF664D03),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _snake?.isVenomous == true 
                        ? '${_snake!.primaryVenomType} - Cần chăm sóc y tế ngay lập tức'
                        : 'Không độc - Vẫn cần quan sát triệu chứng',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF664D03),
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstAidCard() {
    // Get first aid steps from venom type
    final firstVenom = _snake?.speciesVenoms.isNotEmpty == true 
        ? _snake!.speciesVenoms.first.venomType 
        : null;
    final firstAidSteps = firstVenom?.firstAidGuideline.content.steps ?? [];
    
    // Use up to 3 steps or default steps
    final stepsToShow = firstAidSteps.take(3).toList();
    final defaultSteps = [
      ('Gọi cấp cứu ngay lập tức', Icons.phone_in_talk),
      ('Băng ép vết cắn', Icons.healing),
      ('Đến bệnh viện có huyết thanh gần nhất', Icons.local_hospital),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFDC3545),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Cần làm NGAY:',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Show steps from API or default
          if (stepsToShow.isNotEmpty) ...[
            for (int i = 0; i < stepsToShow.length; i++) ...[
              _buildInstructionItem(
                i + 1,
                stepsToShow[i].text,
                i == 0 ? Icons.phone_in_talk : 
                i == 1 ? Icons.healing : 
                Icons.local_hospital,
              ),
              if (i < stepsToShow.length - 1) const SizedBox(height: 16),
            ],
          ] else ...[
            for (int i = 0; i < defaultSteps.length; i++) ...[
              _buildInstructionItem(
                i + 1,
                defaultSteps[i].$1,
                defaultSteps[i].$2,
              ),
              if (i < defaultSteps.length - 1) const SizedBox(height: 16),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildInstructionItem(int number, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF228B22),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF228B22).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            icon,
            color: const Color(0xFF228B22),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showDetails = !_showDetails;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF228B22),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Xem chi tiết rắn',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Icon(
              _showDetails ? Icons.expand_less : Icons.expand_more,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
