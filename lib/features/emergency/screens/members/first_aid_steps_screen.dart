import 'dart:async';
import 'package:flutter/material.dart';
import 'symptom_report_screen.dart';
import 'emergency_tracking_screen.dart';

class FirstAidStepsScreen extends StatefulWidget {
  final String snakeName;
  final String snakeNameVi;
  final String venomType;
  final String snakeImageUrl;

  const FirstAidStepsScreen({
    super.key,
    required this.snakeName,
    required this.snakeNameVi,
    required this.venomType,
    required this.snakeImageUrl,
  });

  @override
  State<FirstAidStepsScreen> createState() => _FirstAidStepsScreenState();
}

class _FirstAidStepsScreenState extends State<FirstAidStepsScreen> {
  int _currentStep = 0;
  int _remainingSeconds = 135; // 2:15
  Timer? _timer;
  final PageController _pageController = PageController(initialPage: 0);

  final List<StepData> _steps = [
    StepData(
      stepNumber: 1,
      title: 'Băng ép vết cắn',
      subtitle: 'Neurotoxic Snake',
      illustrationUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC0O-KUSpq7ElMxfC64QGPeiesPxl453WnUVQvMLn3-p3eNF-PK62D37eJDB5EZZctVcgEiofiRIni_FsWdYmuWEdmS98oWuPwnbmNCugoomQLz1gUaizQPNNhlgbvD678U0vEGluqSZ_2CT1I9PaiPHF5qyoCQpL24j1KURymCr3zmVULTRaeNrdxNT9PKuRoLT6bVAzcvpN32IrQiIAAc7kGgeG50WVcG0OkdvqMLwkIS-DGxdgCDODZ-EOp5_JufZw0gj8H9GQKX',
      instructions: [
        'Bắt đầu băng từ vị trí vết cắn',
        'Băng chặt vừa phải, không quá chặt',
        'Băng toàn bộ chi bị cắn',
        'Kiểm tra tuần hoàn - ngón chân/tay vẫn hồng',
      ],
      tipTitle: 'Kỹ thuật băng ép đúng cách:',
      tipDescription: 'Đảm bảo mạch đập vẫn cảm nhận được.',
      tipImageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCrYdGZdiKWowzB9BK94YCmiQWw3FLDpcHWiKhv83f5D4JIstOymxaIW3f6uFICT5ijq4yNSU1hFI9AjG8Bf54tbeAJPKIBXpu0h6jQoJBLoqrhKXOgbQQkuEPa7o6BUgrLAHgWq9NBWID3JEGEPOQ5vC82nhnjp80KHpps8MO3cZpZvyOLQEfG7sSYcf9law7FwUECIfuBtRN_YnhAwZuxIWIgp1tAcdg5sXQ0djVs65sjmmKKVdGWFrt5QiEtpRG92YRJmWmznQPX',
    ),
    StepData(
      stepNumber: 2,
      title: 'Giữ nạn nhân bất động',
      subtitle: 'Neurotoxic Snake',
      illustrationUrl: null,
      illustrationIcon: Icons.airline_seat_flat,
      instructions: [
        'Giữ cho nạn nhân nằm yên, không di chuyển',
        'Đặt chi bị cắn thấp hơn tim',
        'Tránh căng thẳng và hoảng loạn',
        'Không cho ăn uống gì',
      ],
      tipTitle: 'Lưu ý quan trọng:',
      tipDescription: 'Di chuyển sẽ làm nọc độc lan nhanh hơn trong cơ thể.',
      tipImageUrl: null,
    ),
    StepData(
      stepNumber: 3,
      title: 'Gọi cấp cứu ngay',
      subtitle: 'Neurotoxic Snake',
      illustrationUrl: null,
      illustrationIcon: Icons.phone_in_talk,
      instructions: [
        'Gọi 115 hoặc số cấp cứu địa phương',
        'Báo rõ vị trí và tình trạng nạn nhân',
        'Mô tả con rắn (nếu có thể)',
        'Không cắt vết cắn hoặc hút nọc độc',
      ],
      tipTitle: 'Điều quan trọng:',
      tipDescription: 'Cung cấp ảnh rắn (nếu có) giúp xác định loài và huyết thanh phù hợp.',
      tipImageUrl: null,
    ),
    StepData(
      stepNumber: 4,
      title: 'Đưa đến bệnh viện',
      subtitle: 'Neurotoxic Snake',
      illustrationUrl: null,
      illustrationIcon: Icons.local_hospital,
      instructions: [
        'Di chuyển nạn nhân đến bệnh viện có huyết thanh',
        'Giữ nạn nhân nằm yên trong quá trình vận chuyển',
        'Theo dõi dấu hiệu sinh tồn',
        'Mang theo ảnh rắn (nếu đã chụp)',
      ],
      tipTitle: 'Thời gian vàng:',
      tipDescription: 'Cần tiêm huyết thanh trong vòng 2-4 giờ sau khi bị cắn.',
      tipImageUrl: null,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
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
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStepData = _steps[_currentStep];
    
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
            onTap: () => Navigator.pop(context),
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
              image: DecorationImage(
                image: NetworkImage(widget.snakeImageUrl),
                fit: BoxFit.cover,
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
                  '${widget.snakeNameVi} (${widget.snakeName})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF191910),
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
                    widget.venomType,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
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
              color: const Color(0xFF228B22).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF228B22).withOpacity(0.2),
              ),
            ),
            child: Text(
              'BƯỚC ${stepData.stepNumber}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF228B22),
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Heading
          Text(
            stepData.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF191910),
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
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
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
                      color: const Color(0xFF228B22).withOpacity(0.3),
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
                    decoration: const BoxDecoration(
                      color: Color(0xFF228B22),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF191910),
                        height: 1.5,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SymptomReportScreen(),
                      ),
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyTrackingScreen(),
                  ),
                );
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
  });
}
