import 'package:flutter/material.dart';
import 'emergency_tracking_screen.dart';
import 'emergency_tracking_screen.dart';
import 'dart:math' as math;

class SeverityAssessmentScreen extends StatefulWidget {
  final int severityScore;
  final List<String> riskFactors;
  final String timeSinceBite;
  final int painLevel;

  const SeverityAssessmentScreen({
    super.key,
    this.severityScore = 85,
    this.riskFactors = const [],
    this.timeSinceBite = '15 phút',
    this.painLevel = 7,
  });

  @override
  State<SeverityAssessmentScreen> createState() => _SeverityAssessmentScreenState();
}

class _SeverityAssessmentScreenState extends State<SeverityAssessmentScreen> {
  late String _assessmentTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _assessmentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Color _getSeverityColor() {
    if (widget.severityScore >= 70) {
      return const Color(0xFFC0392B); // Critical red
    } else if (widget.severityScore >= 40) {
      return const Color(0xFFF59E0B); // Warning amber
    } else {
      return const Color(0xFF228B22); // Safe green
    }
  }

  String _getSeverityLevel() {
    if (widget.severityScore >= 70) {
      return '🚨 NGHIÊM TRỌNG - CẦN CẤP CỨU NGAY';
    } else if (widget.severityScore >= 40) {
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
          onPressed: () => Navigator.pop(context),
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
                progress: widget.severityScore / 100,
                color: _getSeverityColor(),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.severityScore}',
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
            'Điểm mức độ: ${widget.severityScore}/100',
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
    final defaultFactors = [
      'Phát hiện khó thở',
      'Mức độ đau cao (${widget.painLevel}/10)',
      'Sưng tấy và tê bỏi',
      'Xác nhận rắn độc',
    ];

    final factors = widget.riskFactors.isNotEmpty ? widget.riskFactors : defaultFactors;

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
            'Các yếu tố nguy cơ:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF191910),
            ),
          ),
          const SizedBox(height: 16),
          ...factors.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: entry.key < factors.length - 1 ? 12 : 0),
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
                        fontSize: 16,
                        color: Color(0xFF191910),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
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
            'Cần làm NGAY:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF191910),
            ),
          ),
          const SizedBox(height: 16),
          _buildActionItem(1, 'GỌI CẤP CỨU NGAY'),
          const SizedBox(height: 12),
          _buildActionItem(2, 'Đến bệnh viện gần nhất ngay lập tức'),
          const SizedBox(height: 12),
          _buildActionItem(3, 'Thông báo người thân khẩn cấp'),
          const SizedBox(height: 12),
          _buildActionItem(4, 'Tiếp tục sơ cứu trong khi chờ'),
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmergencyTrackingScreen(),
                ),
              );
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
                    onTap: () => Navigator.pop(context),
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
