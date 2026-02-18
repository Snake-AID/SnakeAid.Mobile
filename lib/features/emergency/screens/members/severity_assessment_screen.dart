import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../repository/snake_ai_repository.dart';
import '../../models/snake_detection_response.dart';

class SeverityAssessmentScreen extends ConsumerStatefulWidget {
  final int severityLevel;
  final List<String> symptomsReport;
  final String timeSinceBite;
  final String? recognitionResultId;

  const SeverityAssessmentScreen({
    super.key,
    this.severityLevel = 0,
    this.symptomsReport = const [],
    this.timeSinceBite = '15 phút',
    this.recognitionResultId,
  });

  @override
  ConsumerState<SeverityAssessmentScreen> createState() => _SeverityAssessmentScreenState();
}

class _SeverityAssessmentScreenState extends ConsumerState<SeverityAssessmentScreen> {
  late String _assessmentTime;
  List<FirstAidStep> _dosActions = [];
  bool _isLoadingDos = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _assessmentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📊 Severity Assessment Screen');
    debugPrint('Recognition Result ID: ${widget.recognitionResultId}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    // Load dos from API if recognitionResultId is provided
    if (widget.recognitionResultId != null) {
      _loadFirstAidDos();
    } else {
      debugPrint('⚠️ No recognitionResultId - using default dos');
    }
  }

  Future<void> _loadFirstAidDos() async {
    setState(() {
      _isLoadingDos = true;
    });

    try {
      debugPrint('🔍 Loading first aid dos from API...');
      final repository = ref.read(snakeAiRepositoryProvider);
      final response = await repository.getDetectionResult(
        recognitionResultId: widget.recognitionResultId!,
      );

      if (response.isSuccess && response.data != null) {
        final results = response.data!.results;
        if (results.isNotEmpty) {
          final snake = results.first.snake;
          final venoms = snake.speciesVenoms;
          
          debugPrint('✅ Found ${venoms.length} venom types');
          
          // Collect all dos from all venom types
          final allDos = <FirstAidStep>[];
          for (var venom in venoms) {
            final dos = venom.venomType.firstAidGuideline.content.dos;
            debugPrint('  - ${venom.venomType.name}: ${dos.length} dos items');
            allDos.addAll(dos);
                    }

          debugPrint('✅ Total dos loaded: ${allDos.length}');
          setState(() {
            _dosActions = allDos;
            _isLoadingDos = false;
          });
          return;
        }
      }
      
      debugPrint('⚠️ No data in response');
    } catch (e) {
      debugPrint('❌ Error loading dos: $e');
    }

    setState(() {
      _isLoadingDos = false;
    });
  }

  Color _getSeverityColor() {
    if (widget.severityLevel >= 70) {
      return const Color(0xFFC0392B); // Critical red
    } else if (widget.severityLevel >= 40) {
      return const Color(0xFFF59E0B); // Warning amber
    } else {
      return const Color(0xFF228B22); // Safe green
    }
  }

  String _getSeverityLevel() {
    if (widget.severityLevel >= 70) {
      return '🚨 NGHIÊM TRỌNG - CẦN CẤP CỨU NGAY';
    } else if (widget.severityLevel >= 40) {
      return '⚠️ TRUNG BÌNH - CẦN THEO DÕI';
    } else {
      return '✓ NHẸ - TIẾP TỤC SƠ CỨU';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF191910)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('emergency_alert');
            }
          },
        ),
        title: const Text(
          'Đánh giá mức độ nghiêm trọng',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191910),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Phân tích lúc $_assessmentTime',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE5E5E5),
          ),
        ),
      ),
      body: Column(
        children: [
          // Severity Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: _getSeverityColor(),
            child: Text(
              _getSeverityLevel(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Score Card
                    _buildScoreCard(),
                    const SizedBox(height: 16),

                    // Risk Factors Card
                    _buildRiskFactorsCard(),
                    const SizedBox(height: 16),

                    // Action Items Card
                    _buildActionItemsCard(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Actions
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular Progress
          SizedBox(
            width: 160,
            height: 160,
            child: CustomPaint(
              painter: CircularProgressPainter(
                progress: widget.severityLevel / 100,
                color: _getSeverityColor(),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.severityLevel}',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF191910),
                      ),
                    ),
                    const Text(
                      '/100',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Điểm mức độ: ${widget.severityLevel}/100',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF191910),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dựa trên triệu chứng và phân tích ảnh',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskFactorsCard() {
    final symptoms = widget.symptomsReport;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Text(
            'Các triệu chứng đã ghi nhận:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF191910),
            ),
          ),
          const SizedBox(height: 16),
          if (symptoms.isEmpty)
            Text(
              'Chưa có triệu chứng nào được ghi nhận',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            )
          else
            ...symptoms.asMap().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(bottom: entry.key < symptoms.length - 1 ? 12 : 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '❗',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF191910),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFE5E5E5)),
              ),
            ),
            child: Row(
              children: [
                const Text('⏱️', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  '${widget.timeSinceBite} kể từ khi bị cắn',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItemsCard() {
    // Use API dos if available, otherwise use default
    final defaultActions = [
      'GỌI CẤP CỨU NGAY',
      'Đến bệnh viện gần nhất ngay lập tức',
      'Thông báo người thân khẩn cấp',
      'Tiếp tục sơ cứu trong khi chờ',
    ];

    final actions = _dosActions.isNotEmpty
        ? _dosActions.map((d) => d.text).toList()
        : defaultActions;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              const Text(
                'Cần làm NGAY:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191910),
                ),
              ),
              if (_isLoadingDos) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF228B22),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(actions.length, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: index < actions.length - 1 ? 12 : 0),
              child: _buildActionItem(index + 1, actions[index]),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionItem(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF228B22),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF191910),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0xFFE5E5E5)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Back to Emergency Alert Button
          ElevatedButton(
            onPressed: () {
              // Navigate to emergency tracking screen
              context.goNamed('emergency_tracking');
            },
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
                Icon(Icons.crisis_alert, size: 20),
                SizedBox(width: 8),
                Text(
                  'Quay lại màn hình chờ cứu hộ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Update Symptoms Link
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
              children: [
                const TextSpan(text: 'Triệu chứng của bạn đang được theo dõi\n'),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: const Text(
                      'Cập nhật triệu chứng',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF228B22),
                        decoration: TextDecoration.underline,
                      ),
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
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius - 6, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
