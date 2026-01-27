import 'package:flutter/material.dart';
import 'snake_confirmation_screen.dart';

class SnakeSelectionByLocationScreen extends StatelessWidget {
  const SnakeSelectionByLocationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF228B22),
        foregroundColor: Colors.white,
        title: const Text(
          'Chọn loài rắn',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Location badge
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFF228B22),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Vị trí hiện tại: ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    'Quận 1, TP.HCM',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // Info banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Các loài rắn phổ biến trong khu vực của bạn',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Warning banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hãy chọn loài giống nhất với con rắn bạn gặp',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Snake grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
                children: [
                  _buildSnakeCard(
                    context,
                    name: 'Rắn hổ mang chúa',
                    englishName: 'King Cobra',
                    isPoisonous: true,
                    features: 'Đầu tam giác, có mũ, da sọc',
                    imageUrl: 'https://picsum.photos/seed/kingcobra/400/300',
                  ),
                  _buildSnakeCard(
                    context,
                    name: 'Rắn lục đuôi đỏ',
                    englishName: 'Red-tailed Green Ratsnake',
                    isPoisonous: false,
                    features: 'Màu xanh lá, đuôi đỏ',
                    imageUrl: 'https://picsum.photos/seed/greensnake/400/300',
                  ),
                  _buildSnakeCard(
                    context,
                    name: 'Rắn cạp nong',
                    englishName: 'Banded Krait',
                    isPoisonous: true,
                    features: 'Sọc đen trắng, đầu nhỏ',
                    imageUrl: 'https://picsum.photos/seed/krait/400/300',
                  ),
                  _buildSnakeCard(
                    context,
                    name: 'Rắn ráo trâu',
                    englishName: 'Indochinese Ratsnake',
                    isPoisonous: false,
                    features: 'Màu nâu đất, không độc',
                    imageUrl: 'https://picsum.photos/seed/ratsnake/400/300',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Footer actions
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
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SnakeIdentificationQuestionsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.quiz),
                      label: const Text('Không thấy trong danh sách'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF228B22),
                        side: const BorderSide(color: Color(0xFF228B22)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
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
                      icon: const Icon(Icons.medical_services_outlined),
                      label: const Text('Bỏ qua - Xem sơ cứu chung'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSnakeCard(
    BuildContext context, {
    required String name,
    required String englishName,
    required bool isPoisonous,
    required String features,
    required String imageUrl,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SnakeConfirmationScreen(
                snakeNameVi: name,
                englishName: englishName,
                isPoisonous: isPoisonous,
                features: [
                  'Đầu hình tam giác',
                  'Có hoa văn đặc trưng',
                  'Kích thước phù hợp',
                  'Môi trường sống đúng',
                  'Thời gian hoạt động',
                ],
                snakeImageUrl: imageUrl,
                venomType: isPoisonous ? 'Neurotoxic' : 'Non-venomous',
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Snake image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    color: const Color(0xFFF8F8F6),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                  // Poison badge
                  if (isPoisonous)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC3545),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.dangerous,
                              size: 12,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'CÓ ĐỘC',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Snake info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      englishName,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      features,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SnakeConfirmationScreen(
                                snakeNameVi: name,
                                englishName: englishName,
                                isPoisonous: isPoisonous,
                                features: [
                                  'Đầu hình tam giác',
                                  'Có hoa văn đặc trưng',
                                  'Kích thước phù hợp',
                                  'Môi trường sống đúng',
                                  'Thời gian hoạt động',
                                ],
                                snakeImageUrl: imageUrl,
                                venomType: isPoisonous ? 'Neurotoxic' : 'Non-venomous',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF228B22),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Chọn',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Import for GenericFirstAidScreen
import 'generic_first_aid_screen.dart';
import 'snake_identification_questions_screen.dart';
