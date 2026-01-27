import 'package:flutter/material.dart';
import 'dart:io';
import 'first_aid_steps_screen.dart';

/// Snake Identification Result Screen
/// Shows AI identification results with danger level and first aid instructions
class SnakeIdentificationResultScreen extends StatefulWidget {
  final File snakeImage;
  
  const SnakeIdentificationResultScreen({
    super.key,
    required this.snakeImage,
  });

  @override
  State<SnakeIdentificationResultScreen> createState() =>
      _SnakeIdentificationResultScreenState();
}

class _SnakeIdentificationResultScreenState
    extends State<SnakeIdentificationResultScreen> {
  bool _showDetails = false;

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
            color: const Color(0xFFDC3545),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Text(
              '⚠️ PHÁT HIỆN RẮN ĐỘC',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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
                  const SizedBox(height: 16),

                  // Report Button
                  OutlinedButton(
                    onPressed: () {
                      // Navigate to first aid steps screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FirstAidStepsScreen(
                            snakeName: 'King Cobra',
                            snakeNameVi: 'Rắn hổ mang chúa',
                            venomType: 'Neurotoxic Venom',
                            snakeImageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA78Q8Y8rrYS37mi18pzkQVzGEl0d72xj2AxkV1aNGYBu2B8rXtRzDuDH7NE2et3ULymRNMXCcyPdV8sMLmx0h100VT8euLm3iFSVEbT-PhRTzqxr6vZy-i3VQ7hdm-qa9DxcZ338h1khIQYLraBX5Ohxb0xpfrpnLJ-xgdMaGVqvuShxfnjZLH0b1QSvuy_AIv12qVfUYwQDGNPwxbTb85vh4VlDreXGjzK65b2shRP5PFOZWIk-gi2BOIjFF8gMULJLuGjP6mRlqQ',
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF666666),
                      side: const BorderSide(
                        color: Color(0xFF999999),
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text(
                      'Báo cáo lần nhìn thấy này',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Retake Link
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Không đúng? Chụp lại',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF888888),
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
              child: Image.file(
                widget.snakeImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // English Name
          const Text(
            'King Cobra',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 4),

          // Scientific Name
          const Text(
            'Ophiophagus hannah',
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 4),

          // Vietnamese Name
          const Text(
            'Rắn hổ mang chúa',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),

          // Confidence Level
          const Text(
            'Độ tin cậy AI: 94%',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF999999),
            ),
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
          // Gradient Bar
          SizedBox(
            height: 50,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Gradient bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
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
                // Marker
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.68,
                  bottom: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC3545),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'CAO',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 3,
                        height: 8,
                        color: const Color(0xFFDC3545),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Danger Level Text
          const Text(
            'Mức độ nguy hiểm: CAO',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFDC3545),
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Có độc rất cao - Cần chăm sóc y tế ngay lập tức',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF664D03),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstAidCard() {
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

          _buildInstructionItem(
            1,
            'Gọi cấp cứu ngay lập tức',
            Icons.phone_in_talk,
          ),
          const SizedBox(height: 16),
          _buildInstructionItem(
            2,
            'Băng ép vết cắn',
            Icons.healing,
          ),
          const SizedBox(height: 16),
          _buildInstructionItem(
            3,
            'Đến bệnh viện có huyết thanh gần nhất',
            Icons.local_hospital,
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
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
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
          Icon(
            icon,
            color: const Color(0xFF228B22),
            size: 24,
          ),
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
