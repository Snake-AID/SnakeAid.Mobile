import 'package:flutter/material.dart';
import 'emergency_tracking_screen.dart';

class SeverityAssessmentScreen extends StatefulWidget {
  final String snakeNameVi;
  final String englishName;
  final bool isPoisonous;
  final double painLevel;
  final List<String> symptoms;

  const SeverityAssessmentScreen({
    Key? key,
    required this.snakeNameVi,
    required this.englishName,
    required this.isPoisonous,
    required this.painLevel,
    required this.symptoms,
  }) : super(key: key);

  @override
  State<SeverityAssessmentScreen> createState() =>
      _SeverityAssessmentScreenState();
}

class _SeverityAssessmentScreenState extends State<SeverityAssessmentScreen>
    with SingleTickerProviderStateMixin {
  late String _severityLevel;
  late Color _severityColor;
  late IconData _severityIcon;
  late String _recommendation;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _calculateSeverity();
    _setupAnimation();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  void _calculateSeverity() {
    int score = 0;

    // Pain score (max 30 points)
    score += (widget.painLevel * 3).round();

    // Critical neurological symptoms (30 points each)
    if (widget.symptoms.contains('paralysis')) score += 30;
    if (widget.symptoms.contains('breathing')) score += 30;
    if (widget.symptoms.contains('difficulty_swallowing')) score += 25;

    // Serious symptoms (20 points each)
    if (widget.symptoms.contains('blurred')) score += 20;
    if (widget.symptoms.contains('confusion')) score += 20;
    if (widget.symptoms.contains('heartbeat')) score += 20;

    // Moderate symptoms (10 points each)
    if (widget.symptoms.contains('nausea')) score += 10;
    if (widget.symptoms.contains('dizziness')) score += 10;
    if (widget.symptoms.contains('weakness')) score += 10;
    if (widget.symptoms.contains('swelling')) score += 10;
    if (widget.symptoms.contains('bleeding')) score += 10;

    // Mild symptoms (5 points each)
    if (widget.symptoms.contains('redness')) score += 5;
    if (widget.symptoms.contains('numbness')) score += 5;
    if (widget.symptoms.contains('sweating')) score += 5;

    // Poisonous snake adds weight
    if (widget.isPoisonous) score += 15;

    // Determine severity level
    if (score >= 70) {
      _severityLevel = 'NGUY KỊCH';
      _severityColor = const Color(0xFFDC3545);
      _severityIcon = Icons.emergency;
      _recommendation =
          'Cần đến bệnh viện NGAY LẬP TỨC! Tình trạng rất nguy hiểm, có nguy cơ tử vong. Gọi xe cấp cứu 115.';
    } else if (score >= 40) {
      _severityLevel = 'NGHIÊM TRỌNG';
      _severityColor = Colors.orange;
      _severityIcon = Icons.warning_amber_rounded;
      _recommendation =
          'Cần chăm sóc y tế khẩn cấp trong vòng 1 giờ. Triệu chứng có thể nặng thêm. Đến bệnh viện ngay.';
    } else {
      _severityLevel = 'TRUNG BÌNH';
      _severityColor = Colors.amber;
      _severityIcon = Icons.info_outline;
      _recommendation =
          'Cần theo dõi chặt chẽ. Đến bệnh viện để kiểm tra và điều trị. Ghi nhận mọi thay đổi triệu chứng.';
    }
  }

  void _continueToTracking() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmergencyTrackingScreen(
          snakeNameVi: widget.snakeNameVi,
          severityLevel: _severityLevel,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          'Đánh giá mức độ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Severity badge with animation
            FadeTransition(
              opacity: _animation,
              child: ScaleTransition(
                scale: _animation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: _severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _severityColor,
                      width: 3,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _severityIcon,
                        size: 80,
                        color: _severityColor,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _severityLevel,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _severityColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Recommendation card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.medical_services,
                        color: _severityColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Khuyến nghị',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _recommendation,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[800],
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Assessment summary
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  const Text(
                    'Chi tiết đánh giá',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow('Loài rắn', widget.snakeNameVi),
                  _buildSummaryRow(
                    'Độc tính',
                    widget.isPoisonous ? 'Có độc' : 'Không độc',
                    valueColor: widget.isPoisonous
                        ? const Color(0xFFDC3545)
                        : const Color(0xFF228B22),
                  ),
                  _buildSummaryRow(
                    'Mức độ đau',
                    '${widget.painLevel.round()}/10',
                    valueColor: _getPainColor(widget.painLevel),
                  ),
                  _buildSummaryRow(
                    'Số triệu chứng',
                    '${widget.symptoms.length}',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Critical symptoms warning
            if (_severityLevel == 'NGUY KỊCH') ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC3545).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFDC3545),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.error_outline,
                          color: Color(0xFFDC3545),
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'CẢNH BÁO QUAN TRỌNG',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDC3545),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Gọi xe cấp cứu 115 NGAY\n'
                      '• KHÔNG tự lái xe đến bệnh viện\n'
                      '• Giữ bình tĩnh, hạn chế vận động\n'
                      '• Thông báo bệnh viện trước khi đến',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFDC3545),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Emergency buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  if (_severityLevel == 'NGUY KỊCH')
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement call 115
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đang gọi 115...')),
                          );
                        },
                        icon: const Icon(Icons.phone, size: 24),
                        label: const Text(
                          'GỌI CẤP CỨU 115 NGAY',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC3545),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  if (_severityLevel == 'NGUY KỊCH')
                    const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement find hospital
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đang tìm bệnh viện gần nhất...'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.local_hospital, size: 22),
                      label: const Text(
                        'Tìm bệnh viện gần nhất',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF228B22),
                        side: const BorderSide(
                          color: Color(0xFF228B22),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Continue tracking button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
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
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _continueToTracking,
                  icon: const Icon(Icons.navigation, size: 22),
                  label: const Text(
                    'Bắt đầu theo dõi cứu hộ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF228B22),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPainColor(double pain) {
    if (pain <= 3) return const Color(0xFF228B22);
    if (pain <= 6) return Colors.orange;
    return const Color(0xFFDC3545);
  }
}
