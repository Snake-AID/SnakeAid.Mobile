import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'snake_confirmation_screen.dart';
import '../../models/sos_incident_response.dart';

/// Snake Selection by Location Screen - Manual snake selection when no image available
class SnakeSelectionByLocationScreen extends StatelessWidget {
  final IncidentData? incident;
  
  const SnakeSelectionByLocationScreen({super.key, this.incident});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF333333)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('snake_identification');
            }
          },
        ),
        title: const Text(
          'Rắn thường gặp ở khu vực bạn',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, color: Color(0xFFDC3545), size: 16),
                SizedBox(width: 4),
                Text(
                  'Quận 1, TP.HCM',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Info Banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBBDEFB)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF2196F3),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dựa trên vị trí của bạn, đây là các loài rắn thường gặp nhất',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chọn con giống với rắn bạn gặp nhất',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Warning Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: const Color(0xFFFFFACD),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('💡', style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Lưu ý: Chọn con GIỐNG NHẤT, không cần chính xác 100%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7F6000),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Snake Grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.65,
                children: [
                  _buildSnakeCard(
                    context,
                    name: 'Rắn hổ mang chúa',
                    scientificName: 'Ophiophagus hannah',
                    englishName: 'King Cobra',
                    isPoisonous: true,
                    features: [
                      'Đầu dẹt hình thìa',
                      'Màu nâu vàng, có vân',
                      'Dài 1-3m',
                    ],
                    imageUrl: 'https://images.unsplash.com/photo-1531386151447-fd76ad50012f?w=400',
                  ),
                  _buildSnakeCard(
                    context,
                    name: 'Rắn ráo trâu',
                    scientificName: 'Ptyas mucosa',
                    englishName: 'Oriental Rat Snake',
                    isPoisonous: false,
                    features: [
                      'Mắt to, màu đen',
                      'Màu nâu hoặc xám',
                      'Di chuyển rất nhanh',
                    ],
                    imageUrl: 'https://images.unsplash.com/photo-1516426122078-c23e76319801?w=400',
                  ),
                  _buildSnakeCard(
                    context,
                    name: 'Rắn lục đuôi đỏ',
                    scientificName: 'Trimeresurus albolabris',
                    englishName: 'White-lipped Pit Viper',
                    isPoisonous: true,
                    features: [
                      'Đầu hình tam giác',
                      'Xanh lá cây, đuôi đỏ',
                    ],
                    imageUrl: 'https://images.unsplash.com/photo-1547656584-f8a3649e2e3c?w=400',
                  ),
                  _buildSnakeCard(
                    context,
                    name: 'Rắn cạp nia',
                    scientificName: 'Bungarus candidus',
                    englishName: 'Malayan Krait',
                    isPoisonous: true,
                    features: [
                      'Khoang đen trắng',
                      'Hoạt động về đêm',
                    ],
                    imageUrl: 'https://images.unsplash.com/photo-1494548162494-384bba4ab999?w=400',
                  ),
                ],
              ),
            ),
          ),

          // Footer
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
                  // Không thấy trong danh sách
                  OutlinedButton.icon(
                    onPressed: () {
                      context.goNamed('snake_identification_questions');
                    },
                    icon: const Icon(Icons.search_off, size: 20),
                    label: const Text('Không thấy trong danh sách này'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF333333),
                      side: const BorderSide(color: Color(0xFFBDBDBD)),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Bỏ qua nhận định
                  OutlinedButton.icon(
                    onPressed: () {
                      if (incident != null) {
                        context.goNamed(
                          'symptom_report',
                          extra: {
                            'incidentId': incident!.id,
                          },
                        );
                      } else {
                        // Fallback if no incident
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Không tìm thấy thông tin sự cố'),
                            backgroundColor: Color(0xFFDC3545),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.skip_next, size: 20),
                    label: const Text('Bỏ qua nhận định rắn'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF333333),
                      side: const BorderSide(color: Color(0xFFBDBDBD)),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Quay lại chụp ảnh
                  TextButton.icon(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.goNamed('snake_identification');
                      }
                    },
                    icon: const Icon(Icons.camera_alt, size: 16),
                    label: const Text('Quay lại chụp ảnh'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF228B22),
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

  Widget _buildSnakeCard(
    BuildContext context, {
    required String name,
    required String scientificName,
    required String englishName,
    required bool isPoisonous,
    required List<String> features,
    required String imageUrl,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Snake Image with Badge
          Stack(
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                    onError: (_, __) {},
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPoisonous ? const Color(0xFFDC3545) : const Color(0xFF28A745),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPoisonous ? Icons.warning : Icons.shield,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPoisonous ? 'RẮN ĐỘC' : 'KHÔNG ĐỘC',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Snake Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  
                  // Scientific Name
                  Text(
                    scientificName,
                    style: TextStyle(
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  
                  // Features
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: features.map((feature) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• ',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[400],
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[700],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  // Select Button
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.pushNamed(
                          'snake_confirmation',
                          extra: {
                            'snakeName': name,
                            'englishName': englishName,
                            'scientificName': scientificName,
                            'isPoisonous': isPoisonous,
                            'imageUrl': imageUrl,
                            'features': _getConfirmationFeatures(name),
                            'matchedFeaturesCount': _getConfirmationFeatures(name).where((f) => f.isMatched).length,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Chọn loài này',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 13),
                        ],
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

  List<IdentificationFeature> _getConfirmationFeatures(String snakeName) {
    if (snakeName == 'Rắn hổ mang chúa') {
      return [
        const IdentificationFeature(
          icon: Icons.psychology,
          title: 'Hình dạng đầu',
          description: 'Đầu dẹt hình thìa, rõ ràng so với cổ',
          isMatched: true,
        ),
        const IdentificationFeature(
          icon: Icons.texture,
          title: 'Màu sắc & hoa văn',
          description: 'Màu nâu vàng với vân đen chạy dọc',
          isMatched: true,
        ),
        const IdentificationFeature(
          icon: Icons.straighten,
          title: 'Kích thước',
          description: 'Thường 1.5-3m, có thể lên đến 5m',
          isMatched: true,
        ),
        const IdentificationFeature(
          icon: Icons.sentiment_very_dissatisfied,
          title: 'Hành vi',
          description: 'Có thể dựng cổ lên khi bị đe dọa',
          isMatched: true,
        ),
        const IdentificationFeature(
          icon: Icons.forest,
          title: 'Môi trường sống',
          description: 'Thường ở rừng, gần nước, núi đá',
          isMatched: false,
        ),
      ];
    } else {
      return [
        const IdentificationFeature(
          icon: Icons.psychology,
          title: 'Hình dạng đầu',
          description: 'Đặc điểm về hình dạng đầu',
          isMatched: true,
        ),
        const IdentificationFeature(
          icon: Icons.texture,
          title: 'Màu sắc & hoa văn',
          description: 'Đặc điểm về màu sắc',
          isMatched: true,
        ),
        const IdentificationFeature(
          icon: Icons.straighten,
          title: 'Kích thước',
          description: 'Đặc điểm về kích thước',
          isMatched: true,
        ),
      ];
    }
  }
}
