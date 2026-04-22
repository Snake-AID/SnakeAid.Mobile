import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/snake_detection_response.dart';
import '../../models/sos_incident_response.dart';
import '../../models/first_aid_recommendation_response.dart';
import '../../repository/snake_ai_repository.dart';

class FirstAidStepsScreen extends ConsumerStatefulWidget {
  final IncidentData incident;

  const FirstAidStepsScreen({super.key, required this.incident});

  @override
  ConsumerState<FirstAidStepsScreen> createState() =>
      _FirstAidStepsScreenState();
}

class _FirstAidStepsScreenState extends ConsumerState<FirstAidStepsScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController(initialPage: 0);

  late List<StepData> _steps;
  List<FirstAidStep> _dos = [];
  List<FirstAidStep> _donts = [];
  List<String> _notes = [];
  FirstAidRecommendationResponse? _recommendation;
  bool _isLoading = true;
  String? _errorMessage;

  SnakeInfo? get _snake => _recommendation?.snake;

  @override
  void initState() {
    super.initState();
    _loadFirstAidRecommendation();
  }

  /// Load first aid recommendation from new endpoint
  Future<void> _loadFirstAidRecommendation() async {
    try {
      final repository = ref.read(snakeAiRepositoryProvider);
      final response = await repository.getFirstAidRecommendation(
        incidentId: widget.incident.id,
      );

      _recommendation = response;
      _buildStepsFromRecommendation();
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      debugPrint('❌ Error loading first aid recommendation: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi khi tải hướng dẫn sơ cứu: $e';
      });
    }
  }

  /// Build steps from recommendation response
  void _buildStepsFromRecommendation() {
    if (_recommendation == null) {
      _steps = _buildDefaultSteps();
      return;
    }

    final guideline = _recommendation!.firstAidGuideline;
    final override = _recommendation!.snake?.firstAidGuidelineOverride;
    final venomType =
        _recommendation!.snake?.primaryVenomType ?? 'Sơ cứu chung';

    // Extract dos, donts, notes separately
    _dos = guideline.dos;
    _donts = guideline.donts;
    _notes = guideline.notes;

    // Handle Replace mode - completely replace with override steps
    if (override != null && override.mode.toLowerCase() == 'replace') {
      _steps = [];
      for (int i = 0; i < override.steps.length; i++) {
        final step = override.steps[i];
        _steps.add(
          StepData(
            stepNumber: i + 1,
            title: 'SƠ CỨU KHẨN CẤP',
            subtitle: venomType,
            illustrationUrl: null,
            illustrationIcon: Icons.warning,
            instructions: [step],
            tipTitle: 'QUAN TRỌNG:',
            tipDescription: 'Đây là hướng dẫn đặc biệt cho loài rắn này.',
            tipImageUrl: null,
            isOverrideStep: true,
          ),
        );
      }
      return;
    }

    if (guideline.steps.isEmpty) {
      _steps = _buildDefaultSteps();
      return;
    }

    // Build steps from API data
    _steps = [];

    // Handle Append mode - add highlight note before step 1
    if (override != null &&
        override.mode.toLowerCase() == 'append' &&
        override.steps.isNotEmpty) {
      _steps.add(
        StepData(
          stepNumber: 0,
          title: 'LƯU Ý QUAN TRỌNG',
          subtitle: venomType,
          illustrationUrl: null,
          illustrationIcon: Icons.priority_high,
          instructions: override.steps,
          tipTitle: 'CẢNH BÁO:',
          tipDescription:
              'Vui lòng đọc kỹ trước khi thực hiện các bước sơ cứu.',
          tipImageUrl: null,
          isHighlightNote: true,
        ),
      );
    }

    final apiSteps = guideline.steps;

    // Only add core steps to PageView (exclude dos/donts/notes)
    for (int i = 0; i < apiSteps.length; i++) {
      final step = apiSteps[i];
      _steps.add(
        StepData(
          stepNumber: i + 1,
          title: _extractTitle(step.text),
          subtitle: venomType,
          illustrationUrl: step.mediaUrl.isNotEmpty ? step.mediaUrl : null,
          illustrationIcon: _getIconForStep(i),
          instructions: [step.text],
          tipTitle: 'Lưu ý quan trọng:',
          tipDescription: 'Thực hiện đúng các bước để đảm bảo an toàn',
          tipImageUrl: null,
        ),
      );
    }
  }

  String _extractTitle(String text) {
    // Extract first sentence or first 50 chars as title
    final firstSentence = text.split('.').first;
    if (firstSentence.length <= 50) return firstSentence;
    return '${text.substring(0, 50)}...';
  }

  IconData _getIconForStep(int index) {
    switch (index) {
      case 0:
        return Icons.healing;
      case 1:
        return Icons.airline_seat_flat;
      case 2:
        return Icons.phone_in_talk;
      case 3:
        return Icons.local_hospital;
      default:
        return Icons.medical_services;
    }
  }

  List<StepData> _buildDefaultSteps() {
    return [
      StepData(
        stepNumber: 1,
        title: 'Băng ép vết cắn',
        subtitle: 'Hướng dẫn sơ cứu chung',
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
        subtitle: 'Hướng dẫn sơ cứu chung',
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
        subtitle: 'Hướng dẫn sơ cứu chung',
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
    super.dispose();
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
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF191910),
            ),
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
          child: CircularProgressIndicator(color: Color(0xFF228B22)),
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
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF191910),
            ),
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
                    _loadFirstAidRecommendation();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF228B22),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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

                    // Important Notes (always visible below snake info)
                    if (_notes.isNotEmpty) _buildNotesCard(),

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

          // Title
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

          // Step Counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF228B22).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentStep + 1}/${_steps.length}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF228B22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnakeIdCard() {
    final isCommonGuide = _snake == null;

    if (isCommonGuide) {
      // Common first aid guide layout - simplified with clear title
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF228B22).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.healing,
                    size: 32,
                    color: Color(0xFF228B22),
                  ),
                ),
                const SizedBox(width: 16),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hướng dẫn sơ cứu chung',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF191910),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hướng dẫn an toàn cho mọi vết cắn rắn độc',
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
          ],
        ),
      );
    }

    // Species-specific first aid guide layout
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
                  _snake?.commonName ?? 'Rắn',
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
                Text(
                  'Hướng dẫn sơ cứu chuyên biệt cho loài này',
                  style: const TextStyle(
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
            child: Container(height: 2, color: const Color(0xFFE5E7EB)),
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
    final isWarning = stepData.isWarning;

    final Color bgColor = isHighlight
        ? const Color(0xFFFFF3E0)
        : isOverride
        ? const Color(0xFFFEE2E2)
        : isWarning
        ? const Color(0xFFFFEBEE)
        : Colors.white;

    final Color borderColor = isHighlight
        ? const Color(0xFFFFE0B2)
        : isOverride
        ? const Color(0xFFFECACA)
        : isWarning
        ? const Color(0xFFFFCDD2)
        : const Color(0xFFE5E5E5);

    final Color badgeColor = isHighlight
        ? const Color(0xFFE65100)
        : isOverride
        ? const Color(0xFFDC3545)
        : isWarning
        ? const Color(0xFFDC3545) // Red for warnings/don'ts
        : const Color(0xFF228B22);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: isHighlight || isOverride ? 2 : 1,
        ),
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
              border: Border.all(color: badgeColor.withOpacity(0.2)),
            ),
            child: Text(
              isHighlight
                  ? 'LƯU Ý QUAN TRỌNG'
                  : isOverride
                  ? 'SƠ CỨU ĐẶC BIỆT'
                  : isWarning
                  ? 'CẢNH BÁO ${stepData.stepNumber}'
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
              color: isHighlight || isOverride || isWarning
                  ? badgeColor
                  : const Color(0xFF191910),
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
                  : isWarning
                  ? const Color(0xFFFFEBEE).withOpacity(0.5)
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
              padding: EdgeInsets.only(
                bottom: entry.key < stepData.instructions.length - 1 ? 16 : 0,
              ),
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
                        color: isHighlight || isOverride || isWarning
                            ? badgeColor
                            : const Color(0xFF191910),
                        height: 1.5,
                        fontWeight: isHighlight || isOverride || isWarning
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
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
        border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reference Buttons Row
          Row(
            children: [
              // "Nên làm" button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _dos.isEmpty ? null : () => _showDosBottomSheet(),
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: Text('Nên làm (${_dos.length})'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF228B22),
                    side: BorderSide(
                      color: _dos.isEmpty
                          ? Colors.grey.shade300
                          : const Color(0xFF228B22),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // "Không nên làm" button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _donts.isEmpty
                      ? null
                      : () => _showDontsBottomSheet(),
                  icon: const Icon(Icons.cancel, size: 18),
                  label: Text('Không nên (${_donts.length})'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC3545),
                    side: BorderSide(
                      color: _donts.isEmpty
                          ? Colors.grey.shade300
                          : const Color(0xFFDC3545),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Action Button
          ElevatedButton(
            onPressed: isLastStep
                ? () {
                    // Navigate to symptom report
                    context.pushNamed(
                      'symptom_report',
                      extra: {'incidentId': widget.incident.id},
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
                  isLastStep
                      ? 'Cung cấp triệu chứng cho cứu hộ'
                      : 'Bước tiếp theo',
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
                context.pop();
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Show "Notes" Card below snake info
  Widget _buildNotesCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFF3E0),
            const Color(0xFFFFF3E0).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0B2), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE65100).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFFE65100),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Lưu ý quan trọng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._notes.map((note) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF856404),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      note,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF856404),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Show "Dos" bottom sheet
  void _showDosBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF228B22).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Color(0xFF228B22),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Những điều NÊN làm',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF191910),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _dos.length,
                    itemBuilder: (context, index) {
                      final doItem = _dos[index];
                      final hasMedia = doItem.mediaUrl.isNotEmpty;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF228B22).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF228B22).withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF228B22),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    doItem.text,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF1C100D),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (hasMedia) ...[
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () => _showImagePreview(doItem.mediaUrl),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    doItem.mediaUrl,
                                    width: double.infinity,
                                    height: 140,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: double.infinity,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey,
                                            size: 32,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.zoom_in,
                                    size: 12,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Nhấn để xem rõ',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Show "Donts" bottom sheet
  void _showDontsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC3545).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cancel,
                          color: Color(0xFFDC3545),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Những điều TUYỆT ĐỐI KHÔNG làm',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF191910),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _donts.length,
                    itemBuilder: (context, index) {
                      final dontItem = _donts[index];
                      final hasMedia = dontItem.mediaUrl.isNotEmpty;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC3545).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFDC3545).withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFDC3545),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    dontItem.text,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF1C100D),
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (hasMedia) ...[
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () =>
                                    _showImagePreview(dontItem.mediaUrl),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    dontItem.mediaUrl,
                                    width: double.infinity,
                                    height: 140,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: double.infinity,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey,
                                            size: 32,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.zoom_in,
                                    size: 12,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Nhấn để xem rõ',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Show Image Preview (Full Screen)
  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            // Full screen image
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.white,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Không thể tải ảnh',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
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
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Hint text
            const Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Pinch để zoom, kéo để di chuyển',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
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
  final bool isWarning; // For Don'ts - red theme

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
    this.isWarning = false,
  });
}
