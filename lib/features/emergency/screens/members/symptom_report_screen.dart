import 'package:flutter/material.dart';
import 'severity_assessment_screen.dart';

class SymptomReportScreen extends StatefulWidget {
  final String snakeNameVi;
  final String englishName;
  final bool isPoisonous;

  const SymptomReportScreen({
    Key? key,
    required this.snakeNameVi,
    required this.englishName,
    required this.isPoisonous,
  }) : super(key: key);

  @override
  State<SymptomReportScreen> createState() => _SymptomReportScreenState();
}

class _SymptomReportScreenState extends State<SymptomReportScreen> {
  double _painLevel = 5.0;
  final Set<String> _selectedSymptoms = {};

  final List<Map<String, dynamic>> _localSymptoms = [
    {'id': 'swelling', 'label': 'Sưng phồng vùng cắn', 'icon': Icons.warning_amber},
    {'id': 'redness', 'label': 'Đỏ da, nóng rát', 'icon': Icons.local_fire_department},
    {'id': 'bleeding', 'label': 'Chảy máu vết thương', 'icon': Icons.bloodtype},
    {'id': 'bruising', 'label': 'Bầm tím xung quanh', 'icon': Icons.circle},
    {'id': 'numbness', 'label': 'Tê liệt vùng cắn', 'icon': Icons.touch_app},
  ];

  final List<Map<String, dynamic>> _systemicSymptoms = [
    {'id': 'nausea', 'label': 'Buồn nôn, nôn mửa', 'icon': Icons.sick},
    {'id': 'dizziness', 'label': 'Chóng mặt, choáng váng', 'icon': Icons.rotate_left},
    {'id': 'breathing', 'label': 'Khó thở, thở nông', 'icon': Icons.air},
    {'id': 'heartbeat', 'label': 'Tim đập nhanh bất thường', 'icon': Icons.favorite},
    {'id': 'sweating', 'label': 'Đổ mồ hôi nhiều', 'icon': Icons.water_drop},
    {'id': 'weakness', 'label': 'Yếu cơ, mệt mỏi', 'icon': Icons.battery_0_bar},
  ];

  final List<Map<String, dynamic>> _neurologicalSymptoms = [
    {'id': 'blurred', 'label': 'Mờ mắt, nhìn đôi', 'icon': Icons.visibility_off},
    {'id': 'drooping', 'label': 'Sụp mi mắt', 'icon': Icons.remove_red_eye},
    {'id': 'difficulty_swallowing', 'label': 'Khó nuốt', 'icon': Icons.restaurant},
    {'id': 'slurred', 'label': 'Nói khó, lưỡi nặng', 'icon': Icons.record_voice_over},
    {'id': 'paralysis', 'label': 'Tê liệt chân tay', 'icon': Icons.accessible},
    {'id': 'confusion', 'label': 'Lú lẫn, mất định hướng', 'icon': Icons.psychology},
  ];

  void _toggleSymptom(String symptomId) {
    setState(() {
      if (_selectedSymptoms.contains(symptomId)) {
        _selectedSymptoms.remove(symptomId);
      } else {
        _selectedSymptoms.add(symptomId);
      }
    });
  }

  void _continueToAssessment() {
    if (_selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất 1 triệu chứng'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeverityAssessmentScreen(
          snakeNameVi: widget.snakeNameVi,
          englishName: widget.englishName,
          isPoisonous: widget.isPoisonous,
          painLevel: _painLevel,
          symptoms: _selectedSymptoms.toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF228B22),
        foregroundColor: Colors.white,
        title: const Text(
          'Báo cáo triệu chứng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chọn tất cả triệu chứng bạn đang gặp',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Thông tin này giúp cứu hộ viên và bác sĩ đánh giá mức độ nghiêm trọng',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Pain level slider
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                    'Mức độ đau (1-10)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.sentiment_satisfied, color: Color(0xFF228B22)),
                      Expanded(
                        child: Slider(
                          value: _painLevel,
                          min: 1,
                          max: 10,
                          divisions: 9,
                          activeColor: _getPainColor(_painLevel),
                          label: _painLevel.round().toString(),
                          onChanged: (value) {
                            setState(() {
                              _painLevel = value;
                            });
                          },
                        ),
                      ),
                      const Icon(Icons.sentiment_very_dissatisfied,
                          color: Color(0xFFDC3545)),
                    ],
                  ),
                  Center(
                    child: Text(
                      _getPainLabel(_painLevel),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getPainColor(_painLevel),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Local symptoms
            _buildSymptomCategory(
              'Triệu chứng tại chỗ',
              _localSymptoms,
              Colors.orange,
            ),

            const SizedBox(height: 20),

            // Systemic symptoms
            _buildSymptomCategory(
              'Triệu chứng toàn thân',
              _systemicSymptoms,
              Colors.red,
            ),

            const SizedBox(height: 20),

            // Neurological symptoms
            _buildSymptomCategory(
              'Triệu chứng thần kinh',
              _neurologicalSymptoms,
              Colors.purple,
            ),

            const SizedBox(height: 24),

            // Summary
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF228B22).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF228B22)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF228B22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Đã chọn: ${_selectedSymptoms.length} triệu chứng',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF228B22),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Continue button
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
                  onPressed: _continueToAssessment,
                  icon: const Icon(Icons.navigate_next, size: 24),
                  label: const Text(
                    'Tiếp tục',
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

  Widget _buildSymptomCategory(
    String title,
    List<Map<String, dynamic>> symptoms,
    Color categoryColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: symptoms.length,
          itemBuilder: (context, index) {
            final symptom = symptoms[index];
            final isSelected = _selectedSymptoms.contains(symptom['id']);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: isSelected
                    ? categoryColor.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => _toggleSymptom(symptom['id']),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? categoryColor
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          symptom['icon'],
                          color: isSelected ? categoryColor : Colors.grey,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            symptom['label'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.black87
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: categoryColor,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getPainColor(double pain) {
    if (pain <= 3) return const Color(0xFF228B22);
    if (pain <= 6) return Colors.orange;
    return const Color(0xFFDC3545);
  }

  String _getPainLabel(double pain) {
    final level = pain.round();
    if (level <= 3) return 'Đau nhẹ ($level/10)';
    if (level <= 6) return 'Đau vừa ($level/10)';
    return 'Đau nhiều ($level/10)';
  }
}
