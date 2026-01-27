import 'package:flutter/material.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/first_aid_steps_screen.dart';
import 'package:snakeaid_mobile/features/shared/widgets/custom_dialog.dart';

class SnakeConfirmationScreen extends StatefulWidget {
  final String snakeName;
  final String englishName;
  final bool isPoisonous;
  final String imageUrl;
  final int confidence;

  const SnakeConfirmationScreen({
    super.key,
    required this.snakeName,
    required this.englishName,
    required this.isPoisonous,
    required this.imageUrl,
    this.confidence = 85,
  });

  @override
  State<SnakeConfirmationScreen> createState() =>
      _SnakeConfirmationScreenState();
}

class _SnakeConfirmationScreenState extends State<SnakeConfirmationScreen> {
  final List<bool> _selectedFeatures = List.filled(5, false);

  int get _currentConfidence {
    int base = widget.confidence;
    int selected = _selectedFeatures.where((f) => f).length;

    if (selected >= 4) return 95;
    if (selected == 3) return 85;
    if (selected == 2) return 75;
    if (selected == 1) return 65;
    return base;
  }

  Color get _confidenceColor {
    int confidence = _currentConfidence;
    if (confidence >= 85) return const Color(0xFF228B22);
    if (confidence >= 70) return const Color(0xFFFF9800);
    return const Color(0xFFDC3545);
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomDialog(
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orange,
          title: 'Xác nhận loài rắn',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Bạn có chắc chắn đây là loài rắn bạn gặp phải không?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.isPoisonous
                      ? Colors.red[50]
                      : Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.isPoisonous
                        ? Colors.red[300]!
                        : Colors.green[300]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.isPoisonous
                          ? Icons.dangerous
                          : Icons.check_circle,
                      color: widget.isPoisonous
                          ? const Color(0xFFDC3545)
                          : const Color(0xFF228B22),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.snakeName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: widget.isPoisonous
                                  ? Colors.red[900]
                                  : Colors.green[900],
                            ),
                          ),
                          Text(
                            widget.isPoisonous ? 'RẮN ĐỘC' : 'Không độc',
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.isPoisonous
                                  ? Colors.red[700]
                                  : Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            DialogAction(
              label: 'Không, chọn lại',
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              isPrimary: false,
            ),
            DialogAction(
              label: 'Đúng, tiếp tục',
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FirstAidStepsScreen(
                      snakeName: widget.englishName,
                      snakeNameVi: widget.snakeName,
                      venomType: widget.isPoisonous ? 'Độc' : 'Không độc',
                      snakeImageUrl: widget.imageUrl,
                    ),
                  ),
                );
              },
              isPrimary: true,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Xác nhận loài rắn',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Snake image
                  Container(
                    width: double.infinity,
                    height: 250,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Snake info card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
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
                        Text(
                          widget.snakeName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.englishName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Poisonous status
                        Row(
                          children: [
                            Icon(
                              widget.isPoisonous
                                  ? Icons.dangerous
                                  : Icons.check_circle,
                              size: 20,
                              color: widget.isPoisonous
                                  ? const Color(0xFFDC3545)
                                  : const Color(0xFF228B22),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.isPoisonous ? 'RẮN ĐỘC' : 'Không độc',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: widget.isPoisonous
                                    ? const Color(0xFFDC3545)
                                    : const Color(0xFF228B22),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Confidence level
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Độ chính xác',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: _currentConfidence / 100,
                                            backgroundColor: Colors.grey[200],
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    _confidenceColor),
                                            minHeight: 8,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '$_currentConfidence%',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _confidenceColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Feature selection section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Đặc điểm quan sát được',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Chọn các đặc điểm bạn nhìn thấy để tăng độ chính xác',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildFeatureItem(
                          index: 0,
                          icon: Icons.visibility,
                          title: 'Hình dạng đầu tam giác',
                          subtitle: 'Đầu rộng, cổ hẹp rõ rệt',
                        ),
                        _buildFeatureItem(
                          index: 1,
                          icon: Icons.palette,
                          title: 'Có hoa văn đặc trưng',
                          subtitle: 'Vằn, vệt màu theo mô tả',
                        ),
                        _buildFeatureItem(
                          index: 2,
                          icon: Icons.straighten,
                          title: 'Kích thước phù hợp',
                          subtitle: 'Chiều dài và độ to như mô tả',
                        ),
                        _buildFeatureItem(
                          index: 3,
                          icon: Icons.terrain,
                          title: 'Môi trường sống đúng',
                          subtitle: 'Xuất hiện đúng nơi loài này sống',
                        ),
                        _buildFeatureItem(
                          index: 4,
                          icon: Icons.access_time,
                          title: 'Thời gian hoạt động',
                          subtitle: 'Ban ngày/đêm theo đặc tính loài',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Bottom button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _showConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF228B22),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Xác nhận đây là loài rắn tôi gặp',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFeatures[index] = !_selectedFeatures[index];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedFeatures[index]
                ? const Color(0xFF228B22)
                : Colors.grey[300]!,
            width: _selectedFeatures[index] ? 2 : 1,
          ),
          boxShadow: _selectedFeatures[index]
              ? [
                  BoxShadow(
                    color: const Color(0xFF228B22).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _selectedFeatures[index]
                    ? const Color(0xFF228B22).withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: _selectedFeatures[index]
                    ? const Color(0xFF228B22)
                    : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _selectedFeatures[index]
                          ? const Color(0xFF228B22)
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _selectedFeatures[index]
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              color: _selectedFeatures[index]
                  ? const Color(0xFF228B22)
                  : Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
