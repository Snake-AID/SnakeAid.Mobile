import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../models/snake_detection_response.dart';
import '../../models/sos_incident_response.dart';
import '../../repository/snake_ai_repository.dart';

/// Snake Identification Result Screen
/// Shows AI identification results with danger level and first aid instructions
class SnakeIdentificationResultScreen extends ConsumerStatefulWidget {
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
  ConsumerState<SnakeIdentificationResultScreen> createState() =>
      _SnakeIdentificationResultScreenState();
}

class _SnakeIdentificationResultScreenState
    extends ConsumerState<SnakeIdentificationResultScreen> {
  bool _showDetails = false;
  bool _isConfirming = false;
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    // ⚡ FAST TRACK: Auto-confirm for high confidence AI results (>=85%)
    if (_isHighConfidence) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _confirmIdentification();
        }
      });
    }
  }

  Future<void> _saveRecognitionResultId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final incidentId = widget.incident.id;
      final recognitionResultId = widget.detectionData.recognitionResultId;

      await prefs.setString(
        'recognition_result_$incidentId',
        recognitionResultId,
      );
      debugPrint(
        '✅ Saved recognition result ID: $recognitionResultId for incident: $incidentId',
      );
    } catch (e) {
      debugPrint('❌ Error saving recognition result ID: $e');
    }
  }

  void _showSuccessNotification() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '✓ Đã cập nhật thông tin nhận diện vào SOS',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF228B22),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Confirm AI identification and save to incident
  Future<void> _confirmIdentification() async {
    if (_result == null || _snake == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có kết quả nhận diện')),
      );
      return;
    }

    setState(() => _isConfirming = true);

    try {
      final repository = ref.read(snakeAiRepositoryProvider);

      // Call confirm API with recognition result ID
      await repository.confirmAIIdentification(
        incidentId: widget.incident.id,
        recognitionResultId: widget.detectionData.recognitionResultId,
      );

      // Save recognition result ID to SharedPreferences
      await _saveRecognitionResultId();

      // Update state
      setState(() {
        _isConfirming = false;
        _isConfirmed = true;
      });

      // Show success notification
      if (mounted) {
        _showSuccessNotification();
      }
    } catch (e) {
      setState(() => _isConfirming = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: const Color(0xFFDC3545),
          ),
        );
      }
    }
  }

  // Get first detection result
  DetectionResult? get _result => widget.detectionData.results.isNotEmpty
      ? widget.detectionData.results.first
      : null;

  SnakeInfo? get _snake => _result?.snake;
  AiDetection? get _aiDetection => _result?.aiDetection;

  // Check if AI confidence is high enough for fast track (>=85%)
  bool get _isHighConfidence => (_aiDetection?.confidence ?? 0) >= 0.85;

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
                      onPressed: () => Navigator.pop(context),
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

          // AI Confidence Banner (High Confidence)
          if (_isHighConfidence)
            Container(
              width: double.infinity,
              color: const Color(0xFF4CAF50),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'AI tin cậy cao: ${((_aiDetection?.confidence ?? 0) * 100).toStringAsFixed(0)}%',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
                  const SizedBox(height: 24),

                  // ⭐ CONDITIONAL BUTTONS BASED ON CONFIDENCE & CONFIRMATION STATE
                  if (!_isConfirmed) ...[
                    // Low confidence: Show manual confirm button
                    if (!_isHighConfidence) ...[
                      ElevatedButton.icon(
                        onPressed: _isConfirming
                            ? null
                            : _confirmIdentification,
                        icon: _isConfirming
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.check_circle_outline, size: 20),
                        label: Text(
                          _isConfirming
                              ? 'Đang lưu...'
                              : 'Tôi chọn kết quả này',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF228B22),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 52),
                          elevation: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // High confidence: Show loading during auto-confirm
                    if (_isHighConfidence && _isConfirming) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF228B22),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              'Đang lưu kết quả...',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF228B22),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Retake Link (for both high and low confidence)
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text(
                        'Không đúng? Chụp lại',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF888888),
                      ),
                    ),
                  ] else ...[
                    // After confirmation: Show action buttons
                    // Primary Action: Report Symptoms
                    ElevatedButton.icon(
                      onPressed: () {
                        // Use push to keep tracking screen alive
                        // Mark as NOT direct entry (from snake flow)
                        context.push(
                          '/symptom-report',
                          extra: {
                            'incidentId': widget.incident.id,
                            'recognitionResultId':
                                widget.detectionData.recognitionResultId,
                            'isDirectEntry':
                                false, // From snake verification flow
                          },
                        );
                      },
                      icon: const Icon(Icons.assignment, size: 20),
                      label: const Text(
                        'Tiếp theo: Báo cáo triệu chứng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 52),
                        elevation: 2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Secondary Action: Skip to Tracking
                    OutlinedButton.icon(
                      onPressed: () {
                        // Pop all sub-screens back to tracking
                        // This preserves tracking screen state
                        Navigator.of(context).popUntil((route) {
                          return route.settings.name == 'emergency_tracking' ||
                              route.isFirst;
                        });
                      },
                      icon: const Icon(Icons.skip_next, size: 20),
                      label: const Text(
                        'Bỏ qua - Về theo dõi',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF228B22),
                        side: const BorderSide(
                          color: Color(0xFF228B22),
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
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
              child: Image.file(widget.snakeImage, fit: BoxFit.cover),
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
              style: const TextStyle(fontSize: 16, color: Color(0xFF333333)),
            ),
          const SizedBox(height: 12),

          // Confidence Level
          Text(
            'Độ tin cậy AI: ${((_aiDetection?.confidence ?? 0) * 100).toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
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
                              border: Border.all(color: Colors.white, width: 2),
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
    final firstAidDonts = firstVenom?.firstAidGuideline.content.donts ?? [];

    // Use up to 3 steps or default steps
    final stepsToShow = firstAidSteps.take(3).toList();
    // Show up to 2 critical donts
    final dontsToShow = firstAidDonts.take(2).toList();
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
                i == 0
                    ? Icons.phone_in_talk
                    : i == 1
                    ? Icons.healing
                    : Icons.local_hospital,
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

          // ⚠️ CRITICAL DON'TS SECTION (if available)
          if (dontsToShow.isNotEmpty) ...[
            const SizedBox(height: 24),
            // Divider
            Container(height: 1, color: const Color(0xFFE0E0E0)),
            const SizedBox(height: 20),

            // Don'ts Header
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
                  '⚠️ TUYỆT ĐỐI KHÔNG:',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC3545),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Critical Don'ts List
            for (int i = 0; i < dontsToShow.length; i++) ...[
              _buildWarningItem(dontsToShow[i].text),
              if (i < dontsToShow.length - 1) const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCDD2), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cancel, color: Color(0xFFDC3545), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFFDC3545),
                height: 1.4,
              ),
            ),
          ),
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
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
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
          Icon(icon, color: const Color(0xFF228B22), size: 24),
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
