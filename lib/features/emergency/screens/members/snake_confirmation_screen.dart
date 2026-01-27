import 'package:flutter/material.dart';
import 'symptom_report_screen.dart';
import '../../../shared/widgets/custom_dialog.dart';
import 'first_aid_steps_screen.dart';
import 'snake_identification_questions_screen.dart';

/// Snake Confirmation Screen - Verify identified snake species
class SnakeConfirmationScreen extends StatefulWidget {
  final String snakeName;
  final String englishName;
  final String scientificName;
  final bool isPoisonous;
  final String? imageUrl;
  final List<IdentificationFeature> features;
  final int matchedFeaturesCount;

  const SnakeConfirmationScreen({
    super.key,
    required this.snakeName,
    required this.englishName,
    required this.scientificName,
    required this.isPoisonous,
    this.imageUrl,
    required this.features,
    required this.matchedFeaturesCount,
  });

  @override
  State<SnakeConfirmationScreen> createState() => _SnakeConfirmationScreenState();
}

class _SnakeConfirmationScreenState extends State<SnakeConfirmationScreen> {
  late List<bool> _selectedFeatures;

  @override
  void initState() {
    super.initState();
    // Initialize with matched features from widget
    _selectedFeatures = widget.features.map((f) => f.isMatched).toList();
  }

  int get _matchedCount => _selectedFeatures.where((selected) => selected).length;
  int get _totalFeatures => widget.features.length;
  
  String get _confidenceLevel {
    final percentage = (_matchedCount / _totalFeatures) * 100;
    if (percentage >= 80) return 'Độ tin cậy cao';
    if (percentage >= 60) return 'Độ tin cậy trung bình';
    return 'Độ tin cậy thấp';
  }

  Color get _confidenceColor {
    final percentage = (_matchedCount / _totalFeatures) * 100;
    if (percentage >= 80) return const Color(0xFF228B22);
    if (percentage >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFDC3545);
  }

  Color get _confidenceBgColor {
    final percentage = (_matchedCount / _totalFeatures) * 100;
    if (percentage >= 80) return const Color(0xFFDCFCE7);
    if (percentage >= 60) return const Color(0xFFFFF3E0);
    return const Color(0xFFFEF2F2);
  }

  Color get _confidenceBorderColor {
    final percentage = (_matchedCount / _totalFeatures) * 100;
    if (percentage >= 80) return const Color(0xFFBBF7D0);
    if (percentage >= 60) return const Color(0xFFFFE0B2);
    return const Color(0xFFFECDD3);
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF666666)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Xác nhận loài rắn',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Bước 1/2',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Snake Image & Info
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Image
                        Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F8F6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE0E0E0),
                              width: 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: widget.imageUrl != null
                              ? Image.network(
                                  widget.imageUrl!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.image,
                                      size: 80,
                                      color: Color(0xFFBDBDBD),
                                    );
                                  },
                                )
                              : const Icon(
                                  Icons.image,
                                  size: 80,
                                  color: Color(0xFFBDBDBD),
                                ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Snake Name
                        Text(
                          widget.snakeName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF333333),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        
                        // English Name
                        Text(
                          widget.englishName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        
                        // Scientific Name
                        Text(
                          widget.scientificName,
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        
                        // Poison Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.isPoisonous ? const Color(0xFFDC3545) : const Color(0xFF28A745),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: (widget.isPoisonous ? const Color(0xFFDC3545) : const Color(0xFF28A745))
                                    .withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.isPoisonous ? Icons.warning : Icons.shield,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.isPoisonous ? 'RẮN CỰC ĐỘC' : 'KHÔNG ĐỘC',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(
                    height: 1,
                    color: const Color(0xFFE0E0E0),
                  ),

                  // Features Section
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Đặc điểm nhận dạng chi tiết:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Features List
                        ...List.generate(widget.features.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildFeatureCard(widget.features[index], index),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Match Indicator
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _confidenceBgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _confidenceBorderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _confidenceColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_matchedCount/$_totalFeatures đặc điểm phù hợp',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _confidenceColor,
                                ),
                              ),
                              Text(
                                _confidenceLevel,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _confidenceColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Warning Box
                  if (widget.isPoisonous)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFECDD3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.warning,
                                color: Color(0xFFDC3545),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Nếu đây là ${widget.snakeName}:',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFDC3545),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildWarningItem('Nọc độc cực mạnh - có thể gây tử vong trong 30 phút'),
                          const SizedBox(height: 6),
                          _buildWarningItem('Cần băng ép NGAY và đến bệnh viện khẩn cấp'),
                          const SizedBox(height: 6),
                          _buildWarningItem('Huyết thanh kháng nọc có tại bệnh viện lớn'),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(16),
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
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _showConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: const Color(0xFF228B22).withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Xác nhận - Đây là con rắn tôi gặp',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Not Sure Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF666666),
                        side: const BorderSide(color: Color(0xFFBDBDBD), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Không chắc - Chọn loài khác',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Not Similar Button
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SnakeIdentificationQuestionsScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Không giống - Trả lời câu hỏi chi tiết',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
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

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomDialog(
        icon: Icons.priority_high,
        iconBackgroundColor: const Color(0xFFFFF3E0),
        iconColor: const Color(0xFFFF9800),
        title: 'Bắt đầu sơ cứu khẩn cấp?',
        description: widget.isPoisonous
            ? 'Bạn sẽ được hướng dẫn các bước sơ cứu khẩn cấp cho rắn độc. Vui lòng thực hiện ngay lập tức.'
            : 'Bạn sẽ được hướng dẫn các bước sơ cứu cơ bản. Vui lòng theo dõi kỹ từng bước.',
        extraContent: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.isPoisonous ? const Color(0xFFFEF2F2) : const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isPoisonous ? const Color(0xFFFECDD3) : const Color(0xFFBBF7D0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.isPoisonous ? Icons.emergency : Icons.medical_services,
                  color: widget.isPoisonous ? const Color(0xFFDC3545) : const Color(0xFF228B22),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isPoisonous ? 'CẢNH BÁO: RẮN ĐỘC' : 'Rắn không độc',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: widget.isPoisonous ? const Color(0xFFDC3545) : const Color(0xFF228B22),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.snakeName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        actions: [
          DialogAction(
            label: 'Quay lại',
            isOutlined: true,
            onPressed: () => Navigator.pop(context),
            textColor: const Color(0xFF666666),
            borderColor: const Color(0xFFBDBDBD),
          ),
          DialogAction(
            label: 'Bắt đầu sơ cứu',
            icon: Icons.arrow_forward,
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FirstAidStepsScreen(
                    snakeName: widget.englishName,
                    snakeNameVi: widget.snakeName,
                    venomType: widget.isPoisonous ? 'Độc' : 'Không độc',
                    snakeImageUrl: widget.imageUrl ?? '',
                  ),
                ),
              );
            },
            backgroundColor: const Color(0xFF228B22),
            textColor: Colors.white,
            isBold: true,
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IdentificationFeature feature, int index) {
    final isSelected = _selectedFeatures[index];
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFeatures[index] = !_selectedFeatures[index];
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF228B22) : const Color(0xFFE0E0E0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Icon(
                feature.icon,
                color: const Color(0xFF666666),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    feature.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            
            // Check Icon
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF228B22) : Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.circle,
            size: 6,
            color: Color(0xFFDC3545),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF991B1B),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

/// Identification Feature Model
class IdentificationFeature {
  final IconData icon;
  final String title;
  final String description;
  final bool isMatched;

  const IdentificationFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.isMatched,
  });
}
