import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/snake_detection_response.dart';
import '../../models/sos_incident_response.dart';
import '../../repository/snake_ai_repository.dart';

class FirstAidStepsScreen extends ConsumerStatefulWidget {
  final DetectionResult? detectionResult;
  final IncidentData incident;
  final String recognitionResultId;

  const FirstAidStepsScreen({
    super.key,
    this.detectionResult,
    required this.incident,
    required this.recognitionResultId,
  });

  @override
  ConsumerState<FirstAidStepsScreen> createState() => _FirstAidStepsScreenState();
}

class _FirstAidStepsScreenState extends ConsumerState<FirstAidStepsScreen> {
  int _currentStep = 0;
  int _remainingSeconds = 135; // 2:15
  Timer? _timer;
  final PageController _pageController = PageController(initialPage: 0);
  
  late List<StepData> _steps;
  DetectionResult? _detectionResult;
  bool _isLoading = true;
  String? _errorMessage;
  
  SnakeInfo? get _snake => _detectionResult?.snake;
  
  // Get first aid guideline from venom type
  FirstAidGuideline? get _firstAidGuideline {
    if (_snake == null || _snake!.speciesVenoms.isEmpty) return null;
    return _snake!.speciesVenoms.first.venomType.firstAidGuideline;
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (widget.detectionResult != null) {
      // Already have detection result
      _detectionResult = widget.detectionResult;
      _buildStepsFromApi();
      _startTimer();
      setState(() => _isLoading = false);
    } else {
      // Load from API using recognitionResultId
      await _loadDetectionData();
    }
  }

  Future<void> _loadDetectionData() async {
    try {
      final repository = ref.read(snakeAiRepositoryProvider);
      final response = await repository.getDetectionResult(
        recognitionResultId: widget.recognitionResultId,
      );
      
      if (response.isSuccess && response.data != null && response.data!.results.isNotEmpty) {
        _detectionResult = response.data!.results.first;
        _buildStepsFromApi();
        _startTimer();
        setState(() {
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Không thể tải thông tin rắn. ${response.message}';
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading detection data: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi khi tải dữ liệu: $e';
      });
    }
  }
  
  void _buildStepsFromApi() {
    final guideline = _firstAidGuideline;
    final override = _snake?.firstAidGuidelineOverride;
    
    // Handle Replace mode - completely replace with override steps
    if (override != null && override.mode.toLowerCase() == 'replace') {
      _steps = [];
      for (int i = 0; i < override.steps.length; i++) {
        final step = override.steps[i];
        _steps.add(StepData(
          stepNumber: i + 1,
          title: 'SƠ CỨU KHẨN CẤP',
          subtitle: _snake?.primaryVenomType ?? 'Nọc rắn',
          illustrationUrl: null,
          illustrationIcon: Icons.warning,
          instructions: [step],
          tipTitle: 'QUAN TRỌNG:',
          tipDescription: 'Đây là hướng dẫn đặc biệt cho loài rắn này.',
          tipImageUrl: null,
          isOverrideStep: true,
        ));
      }
      return;
    }
    
    if (guideline == null || guideline.content.steps.isEmpty) {
      // Fallback to default steps
      _steps = _buildDefaultSteps();
      return;
    }
    
    // Build steps from API data
    _steps = [];
    
    // Handle Append mode - add highlight note before step 1
    if (override != null && override.mode.toLowerCase() == 'append' && override.steps.isNotEmpty) {
      _steps.add(StepData(
        stepNumber: 0, // Special step number for highlight note
        title: 'LƯU Ý QUAN TRỌNG',
        subtitle: _snake?.primaryVenomType ?? 'Nọc rắn',
        illustrationUrl: null,
        illustrationIcon: Icons.priority_high,
        instructions: override.steps,
        tipTitle: 'CẢNH BÁO:',
        tipDescription: 'Vui lòng đọc kỹ trước khi thực hiện các bước sơ cứu.',
        tipImageUrl: null,
        isHighlightNote: true,
      ));
    }
    
    final apiSteps = guideline.content.steps;
    
    for (int i = 0; i < apiSteps.length; i++) {
      final step = apiSteps[i];
      _steps.add(StepData(
        stepNumber: i + 1,
        title: _extractTitle(step.text),
        subtitle: _snake?.primaryVenomType ?? 'Nọc rắn',
        illustrationUrl: step.mediaUrl.isNotEmpty ? step.mediaUrl : null,
        illustrationIcon: _getIconForStep(i),
        instructions: [step.text],
        tipTitle: 'Lưu ý quan trọng:',
        tipDescription: guideline.summary,
        tipImageUrl: null,
      ));
    }
    
    // Add "Dos" as additional steps
    if (guideline.content.dos.isNotEmpty) {
      for (int i = 0; i < guideline.content.dos.length; i++) {
        final doItem = guideline.content.dos[i];
        _steps.add(StepData(
          stepNumber: i + 1,
          title: 'Nên làm',
          subtitle: _snake?.primaryVenomType ?? 'Nọc rắn',
          illustrationUrl: doItem.mediaUrl.isNotEmpty ? doItem.mediaUrl : null,
          illustrationIcon: Icons.check_circle,
          instructions: [doItem.text],
          tipTitle: 'Khuyến cáo:',
          tipDescription: 'Thực hiện đúng để tăng hiệu quả sơ cứu',
          tipImageUrl: null,
          isRecommendation: true,
        ));
      }
    }
  }
  
  String _extractTitle(String text) {
    // Extract first sentence or first 50 chars as title
    final firstSentence = text.split('.').first;
    if (firstSentence.length <= 50) return firstSentence;
    return text.substring(0, 50) + '...';
  }
  
  IconData _getIconForStep(int index) {
    switch (index) {
      case 0: return Icons.healing;
      case 1: return Icons.airline_seat_flat;
      case 2: return Icons.phone_in_talk;
      case 3: return Icons.local_hospital;
      default: return Icons.medical_services;
    }
  }
  
  List<StepData> _buildDefaultSteps() {
    return [
      StepData(
        stepNumber: 1,
        title: 'Băng ép vết cắn',
        subtitle: _snake?.primaryVenomType ?? 'Nọc rắn',
        illustrationUrl: null,
        illustrationIcon: Icons.healing,
        instructions: [
          'Bắt đầu băng từ vị trí vết cắn',
          'Băng chặt vừa phải, không quá chặt',
          'Băng toàn bộ chi bị cắn',
        ],
        tipTitle: 'Kỹ thuật băng ép:',
        tipDescription: 'Đảm bảo mạch đập vẫn cảm nhận được.',
        tipImageUrl: null,
      ),
      StepData(
        stepNumber: 2,
        title: 'Giữ nạn nhân bất động',
        subtitle: _snake?.primaryVenomType ?? 'Nọc rắn',
        illustrationUrl: null,
        illustrationIcon: Icons.airline_seat_flat,
        instructions: [
          'Giữ cho nạn nhân nằm yên',
          'Đặt chi bị cắn thấp hơn tim',
          'Tránh căng thẳng',
        ],
        tipTitle: 'Lưu ý:',
        tipDescription: 'Di chuyển làm nọc độc lan nhanh.',
        tipImageUrl: null,
      ),
      StepData(
        stepNumber: 3,
        title: 'Gọi cấp cứu ngay',
        subtitle: _snake?.primaryVenomType ?? 'Nọc rắn',
        illustrationUrl: null,
        illustrationIcon: Icons.phone_in_talk,
        instructions: [
          'Gọi 115 hoặc số cấp cứu',
          'Báo vị trí và tình trạng',
          'Mô tả con rắn',
        ],
        tipTitle: 'Quan trọng:',
        tipDescription: 'Cung cấp ảnh rắn giúp xác định huyết thanh.',
        tipImageUrl: null,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      _pageController.animateToPage(
        _currentStep + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to hospital finder or complete
      context.pop();
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F8F6),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF191910)),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Hướng dẫn sơ cứu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF191910),
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF228B22),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F8F6),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF191910)),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Hướng dẫn sơ cứu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF191910),
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Color(0xFFDC3545),
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });
                    _loadDetectionData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF228B22),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation
            _buildTopNavigation(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Snake ID Card
                    _buildSnakeIdCard(),

                    // Progress Stepper
                    _buildProgressStepper(),

                    // Swipeable Instruction Cards
                    SizedBox(
                      height: 600,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentStep = index;
                          });
                        },
                        itemCount: _steps.length,
                        itemBuilder: (context, index) {
                          final stepData = _steps[index];
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                // Main Instruction Card
                                _buildMainInstructionCard(stepData),

                                // Supplemental Visual (if available)
                                if (stepData.tipImageUrl != null)
                                  _buildSupplementalVisual(stepData),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),

            // Bottom Action Button
            _buildBottomAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F6).withOpacity(0.95),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed('snake_confirmation');
              }
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFF191910)),
            ),
          ),

          // Step Indicator
          Expanded(
            child: Text(
              'Hướng dẫn sơ cứu',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF191910),
              ),
            ),
          ),

          // Timer
          SizedBox(
            width: 48,
            child: Text(
              _formatTime(_remainingSeconds),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnakeIdCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5)),
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
          // Snake Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFE5E7EB),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: (_snake?.imageUrl.isNotEmpty ?? false)
                  ? Image.network(
                      _snake!.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: const Color(0xFF9CA3AF),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF228B22),
                            ),
                          ),
                        );
                      },
                    )
                  : Icon(
                      Icons.healing,
                      size: 40,
                      color: const Color(0xFF228B22),
                    ),
            ),
          ),
          const SizedBox(width: 16),

          // Snake Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _snake?.commonName ?? 'Rắn độc',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF191910),
                  ),
                ),
                Text(
                  _snake?.scientificName ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Text(
                    _snake?.primaryVenomType ?? 'Nọc rắn',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB91C1C),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Hướng dẫn sơ cứu chuyên biệt cho loài này',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Stack(
        children: [
          // Connecting Line
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              color: const Color(0xFFE5E7EB),
            ),
          ),

          // Steps
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_steps.length, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;

              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF8F8F6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(1),
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted || isCurrent
                        ? const Color(0xFF228B22)
                        : Colors.white,
                    border: Border.all(
                      color: isCompleted || isCurrent
                          ? const Color(0xFF228B22)
                          : const Color(0xFFD1D5DB),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isCompleted || isCurrent
                            ? Colors.white
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInstructionCard(StepData stepData) {
    // Special styling for highlight note (Append mode)
    final isHighlight = stepData.isHighlightNote;
    final isOverride = stepData.isOverrideStep;
    
    final Color bgColor = isHighlight 
        ? const Color(0xFFFFF3E0) 
        : isOverride 
            ? const Color(0xFFFEE2E2)
            : Colors.white;
    
    final Color borderColor = isHighlight 
        ? const Color(0xFFFFE0B2) 
        : isOverride 
            ? const Color(0xFFFECACA)
            : const Color(0xFFE5E5E5);
    
    final Color badgeColor = isHighlight 
        ? const Color(0xFFE65100) 
        : isOverride 
            ? const Color(0xFFDC3545)
            : const Color(0xFF228B22);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isHighlight || isOverride ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: badgeColor.withOpacity(0.2),
              ),
            ),
            child: Text(
              isHighlight 
                  ? 'LƯU Ý QUAN TRỌNG' 
                  : isOverride 
                      ? 'SƠ CỨU ĐẶC BIỆT'
                      : stepData.isRecommendation
                          ? 'KHUYẾN CÁO ${stepData.stepNumber}'
                          : 'BƯỚC ${stepData.stepNumber}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: badgeColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Heading
          Text(
            stepData.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isHighlight || isOverride ? badgeColor : const Color(0xFF191910),
            ),
          ),
          Text(
            '(${stepData.subtitle})',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF9CA3AF),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Illustration
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: isHighlight 
                  ? const Color(0xFFFFE0B2).withOpacity(0.3)
                  : isOverride 
                      ? const Color(0xFFFECACA).withOpacity(0.3)
                      : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
              image: stepData.illustrationUrl != null
                  ? DecorationImage(
                      image: NetworkImage(stepData.illustrationUrl!),
                      fit: BoxFit.cover,
                      opacity: 0.8,
                    )
                  : null,
            ),
            child: Center(
              child: stepData.illustrationIcon != null
                  ? Icon(
                      stepData.illustrationIcon,
                      size: 80,
                      color: badgeColor.withOpacity(0.4),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Khu vực minh họa',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),

          // Instructions List
          ...stepData.instructions.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: entry.key < stepData.instructions.length - 1 ? 16 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 16,
                        color: isHighlight || isOverride ? badgeColor : const Color(0xFF191910),
                        height: 1.5,
                        fontWeight: isHighlight || isOverride ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSupplementalVisual(StepData stepData) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Color(0xFF228B22), width: 4),
        ),
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
          if (stepData.tipImageUrl != null)
            Container(
              width: 64,
              height: 64,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(stepData.tipImageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stepData.tipTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF191910),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stepData.tipDescription,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    final isLastStep = _currentStep >= _steps.length - 1;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main Action Button
          ElevatedButton(
            onPressed: isLastStep 
                ? () {
                    // Navigate to symptom report
                    context.pushNamed(
                      'symptom_report',
                      extra: {
                        'incidentId': widget.incident.id,
                        'recognitionResultId': widget.recognitionResultId,
                      },
                    );
                  }
                : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF228B22),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 56),
              elevation: 4,
              shadowColor: const Color(0xFF228B22).withOpacity(0.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLastStep ? 'Cung cấp triệu chứng cho cứu hộ' : 'Bước tiếp theo',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
          
          // Back to Emergency Alert Button (only on last step)
          if (isLastStep) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                // Navigate to emergency tracking screen
                context.goNamed('emergency_tracking');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF228B22),
                side: const BorderSide(color: Color(0xFF228B22), width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 52),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.crisis_alert, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Quay lại màn hình chờ cứu hộ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class StepData {
  final int stepNumber;
  final String title;
  final String subtitle;
  final String? illustrationUrl;
  final IconData? illustrationIcon;
  final List<String> instructions;
  final String tipTitle;
  final String tipDescription;
  final String? tipImageUrl;
  final bool isHighlightNote;
  final bool isOverrideStep;
  final bool isRecommendation;

  StepData({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    this.illustrationUrl,
    this.illustrationIcon,
    required this.instructions,
    required this.tipTitle,
    required this.tipDescription,
    this.tipImageUrl,
    this.isHighlightNote = false,
    this.isOverrideStep = false,
    this.isRecommendation = false,
  });
}
