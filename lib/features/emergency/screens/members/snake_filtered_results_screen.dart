import 'package:flutter/material.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/snake_confirmation_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/generic_first_aid_screen.dart';

class SnakeFilteredResultsScreen extends StatelessWidget {
  final Map<int, String> answers;

  const SnakeFilteredResultsScreen({
    super.key,
    required this.answers,
  });

  @override
  Widget build(BuildContext context) {
    // In the future, use answers to filter the snake list
    // For now, showing static results

    final snakes = [
      {
        'name': 'King Cobra',
        'nameVi': 'Rắn Hổ Mang Chúa',
        'isPoisonous': true,
        'confidence': 95,
        'imageUrl':
            'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Ophiophagus_hannah_2.jpg/800px-Ophiophagus_hannah_2.jpg',
      },
      {
        'name': 'Rat Snake',
        'nameVi': 'Rắn Nhà',
        'isPoisonous': false,
        'confidence': 85,
        'imageUrl':
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Rat_snake.jpg/800px-Rat_snake.jpg',
      },
      {
        'name': 'White-lipped Pit Viper',
        'nameVi': 'Rắn Lục Đuôi Đỏ',
        'isPoisonous': true,
        'confidence': 78,
        'imageUrl':
            'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/Trimeresurus_albolabris_McM.jpg/800px-Trimeresurus_albolabris_McM.jpg',
      },
      {
        'name': 'Banded Krait',
        'nameVi': 'Rắn Cạp Nia',
        'isPoisonous': true,
        'confidence': 72,
        'imageUrl':
            'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Bungarus_fasciatus.jpg/800px-Bungarus_fasciatus.jpg',
      },
    ];

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
          'Kết quả tìm kiếm',
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
          // Info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[700],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Dựa trên câu trả lời của bạn, hãy chọn loài rắn phù hợp nhất',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[900],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Warning banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.yellow[50],
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.orange[700],
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '💡 Lưu ý: Chọn con GIỐNG NHẤT với những gì bạn quan sát được',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange[900],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Location badge
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.red[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Quận 1, TP.HCM',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Snake grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: snakes.length,
              itemBuilder: (context, index) {
                final snake = snakes[index];
                final isPoisonous = snake['isPoisonous'] as bool;
                final confidence = snake['confidence'] as int;

                Color confidenceColor;
                if (confidence >= 85) {
                  confidenceColor = const Color(0xFF228B22);
                } else if (confidence >= 70) {
                  confidenceColor = const Color(0xFFFF9800);
                } else {
                  confidenceColor = const Color(0xFFDC3545);
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SnakeConfirmationScreen(
                          snakeName: snake['nameVi'] as String,
                          englishName: snake['name'] as String,
                          isPoisonous: isPoisonous,
                          imageUrl: snake['imageUrl'] as String,
                          confidence: confidence,
                        ),
                      ),
                    );
                  },
                  child: Container(
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
                        // Image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Container(
                            height: 120,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Snake name
                              Text(
                                snake['nameVi'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),

                              // English name
                              Text(
                                snake['name'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),

                              // Confidence badge
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: confidenceColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 12,
                                          color: confidenceColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$confidence%',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: confidenceColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // Poisonous badge
                              Row(
                                children: [
                                  Icon(
                                    isPoisonous
                                        ? Icons.dangerous
                                        : Icons.check_circle,
                                    size: 14,
                                    color: isPoisonous
                                        ? const Color(0xFFDC3545)
                                        : const Color(0xFF228B22),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isPoisonous ? 'Độc' : 'Không độc',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isPoisonous
                                          ? const Color(0xFFDC3545)
                                          : const Color(0xFF228B22),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer button
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
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GenericFirstAidScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[400]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(Icons.help_outline, color: Colors.grey[700]),
                  label: const Text(
                    'Vẫn không tìm thấy loại rắn phù hợp?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
}
