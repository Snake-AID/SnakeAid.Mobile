import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'snake_confirmation_screen.dart';

/// Snake Filtered Results Screen - Shows filtered snake results based on questionnaire answers
class SnakeFilteredResultsScreen extends StatelessWidget {
  final Map<int, String> answers;

  const SnakeFilteredResultsScreen({
    super.key,
    required this.answers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8F6),
        surfaceTintColor: const Color(0xFFF6F8F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF333333)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('snake_identification_questions');
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
        centerTitle: false,
        actions: [
          // Location Badge
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFFDC3545),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Quận 1, TP.HCM',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Info Banner (Blue - Based on answers)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFBBDEFB),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF1976D2),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dựa trên câu trả lời của bạn, hãy chọn loài rắn mà bạn đã bắt gặp',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chọn con giống với rắn bạn gặp nhất',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Warning Banner (Yellow)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFACD),
              border: Border(
                top: BorderSide(color: Colors.yellow[200]!),
                bottom: BorderSide(color: Colors.yellow[200]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '💡',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.yellow[900],
                        height: 1.3,
                      ),
                      children: const [
                        TextSpan(text: 'Lưu ý: Chọn con '),
                        TextSpan(
                          text: 'GIỐNG NHẤT',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ', không cần chính xác 100%'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Snake Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.65,
              children: [
                _buildSnakeCard(
                  context: context,
                  name: 'Rắn hổ mang chúa',
                  englishName: 'King Cobra',
                  scientificName: 'Ophiophagus hannah',
                  isPoisonous: true,
                  imageUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuB3iYF_YxR9JjZdQAqYN_emcm0lPiZbfDNnJkxmrHLoDnRNscK6NA2d4PUYAWZb-yv8x_jQOEv-wQcgUDdV0xdY-Byr1sorfuAue6p9u0m00PP-PGI03E3JGrpxVJFY5a4Q6iyhGmYCvdiktmFb5EcS3Z9Ux_QBzvG_NtFDFOgHVvT6MOecXyjPPUKkqf-kATR8s7XtQrAVdIe14ZYAzsTB36bh_h9EQqKR4mXDQWadTnXpgpELtqc7UZJkAppGYSdz8Yqwr5_UM_NS',
                  features: [
                    'Đầu dẹt hình thìa',
                    'Màu nâu vàng, có vân',
                    'Dài 1-3m',
                  ],
                ),
                _buildSnakeCard(
                  context: context,
                  name: 'Rắn ráo trâu',
                  englishName: 'Oriental Rat Snake',
                  scientificName: 'Ptyas mucosa',
                  isPoisonous: false,
                  imageUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuA5kmOdxTyFaUJGPVwydfBlLJoO76xVwYQQit-lpI1pyS36awh_Ijncxm9zBnibCLaxlYEVq4W_Ydz0IMGg_9YIkydep3TYaZmMhOoVtnux9So5lafYmx16jHTMts-UXAAuW-2vqqaAU-FCCdEY942JL10pRgFT0Qq05YrZVBrqbJuV0Aeb4LgmfJSRDh629id6ABr5iUhDIOgtjRH864OvGBdfE6oJ1CMDVH-8zXuG1jYx6LH_Rdq2g4wU0D0D8LAfAR_0FHRCNAGy',
                  features: [
                    'Mắt to, màu đen',
                    'Màu nâu hoặc xám',
                    'Di chuyển rất nhanh',
                  ],
                ),
                _buildSnakeCard(
                  context: context,
                  name: 'Rắn lục đuôi đỏ',
                  englishName: 'White-lipped Pit Viper',
                  scientificName: 'Trimeresurus albolabris',
                  isPoisonous: true,
                  imageUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuB8Yj6XnclUL6RhGokpHsxe2vT9C5TQK5lHl2goyZNQXxzFGEd4x69PJHFIJ8n6wheu7EiWh4UwLW574TvQ48jI1yDWELygeN41iDhL89B3rG29s0LOS53hdw7zIPw58601qLHymXrW9lXumTOGsbo3fjl9u4_Lz-2nZPJ5ir_DPaTtY2vTSW152gQuYT_6JrLpGmFAHRqPEvjK3CIy22qvLCX1aL94WtxMz4NWtvYSkYfel_3zgQUqFyNOSMu94e4zzY2e7BfDXL20',
                  features: [
                    'Đầu hình tam giác',
                    'Xanh lá cây, đuôi đỏ',
                  ],
                ),
                _buildSnakeCard(
                  context: context,
                  name: 'Rắn cạp nia',
                  englishName: 'Malayan Krait',
                  scientificName: 'Bungarus candidus',
                  isPoisonous: true,
                  imageUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAKdTkiMiOs78CAHPcR7fi9kHDRb35zTvfoSJLPr9CvA9zzOwYLy3zsTSGvx5djM1H1SkIV2UxMFq584jrqqzCHk2325U9gSo3FOjopw4U7bDkAJHcm6lOUiTesAXu4zsBve5_VvEUW3q1JBUShiWXWnxTOYFQpnM0yA8vpwFXcCpOKfqkVn8yu4F3jsV14rpHszZgyrpuU5FV8K966jtHY4y7anagioZJ7DVXfswVCI_7NgSHr5xjw2FM8MYShL7ShDSuhtQNkPkWx',
                  features: [
                    'Khoang đen trắng',
                    'Hoạt động về đêm',
                  ],
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
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
              child: OutlinedButton.icon(
                onPressed: () {
                  // Go to generic first aid screen
                  context.pushNamed('generic_first_aid');
                },
                icon: const Icon(Icons.search_off, size: 20),
                label: const Text(
                  'Vẫn không tìm thấy loại rắn phù hợp? -> Nhấn để tiếp tục sơ cứu',
                  textAlign: TextAlign.center,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF666666),
                  side: const BorderSide(color: Color(0xFFBDBDBD)),
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnakeCard({
    required BuildContext context,
    required String name,
    required String englishName,
    required String scientificName,
    required bool isPoisonous,
    required String imageUrl,
    required List<String> features,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image with poison badge
          Stack(
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.image,
                        size: 50,
                        color: Color(0xFFBDBDBD),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPoisonous ? const Color(0xFFDC3545) : const Color(0xFF28A745),
                    borderRadius: BorderRadius.circular(4),
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
                        isPoisonous ? Icons.dangerous : Icons.shield,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPoisonous ? 'RẮN ĐỘC' : 'KHÔNG ĐỘC',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Content
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Scientific name
                  Text(
                    scientificName,
                    style: TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[500],
                      fontFamily: 'serif',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Features
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: features.length > 3 ? 3 : features.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
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
                              Flexible(
                                child: Text(
                                  features[index],
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
                      },
                    ),
                  ),

                  // Select Button
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final confirmationFeatures = _getConfirmationFeatures(name);
                        context.pushNamed(
                          'snake_confirmation',
                          extra: {
                            'snakeName': name,
                            'englishName': englishName,
                            'scientificName': scientificName,
                            'isPoisonous': isPoisonous,
                            'imageUrl': imageUrl,
                            'features': confirmationFeatures,
                            'matchedFeaturesCount': confirmationFeatures.where((f) => f.isMatched).length,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Chọn loài này',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 14),
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
    // Return features based on snake name
    switch (snakeName) {
      case 'Rắn hổ mang chúa':
        return [
          IdentificationFeature(
            icon: Icons.psychology,
            title: 'Hình dạng đầu',
            description: 'Đầu dẹt hình thìa, rõ ràng so với cổ',
            isMatched: true,
          ),
          IdentificationFeature(
            icon: Icons.texture,
            title: 'Màu sắc & vân',
            description: 'Màu nâu vàng với vân đen rõ ràng',
            isMatched: true,
          ),
          IdentificationFeature(
            icon: Icons.straighten,
            title: 'Kích thước',
            description: 'Dài từ 1-3m, có thể lớn hơn',
            isMatched: true,
          ),
        ];
      case 'Rắn ráo trâu':
        return [
          IdentificationFeature(
            icon: Icons.remove_red_eye,
            title: 'Đặc điểm mắt',
            description: 'Mắt to, màu đen bóng',
            isMatched: true,
          ),
          IdentificationFeature(
            icon: Icons.palette,
            title: 'Màu sắc',
            description: 'Màu nâu hoặc xám đồng nhất',
            isMatched: true,
          ),
          IdentificationFeature(
            icon: Icons.speed,
            title: 'Hành vi',
            description: 'Di chuyển rất nhanh, hay trèo cây',
            isMatched: true,
          ),
        ];
      default:
        return [
          IdentificationFeature(
            icon: Icons.psychology,
            title: 'Hình dạng đầu',
            description: 'Đầu tam giác, rõ ràng so với cổ',
            isMatched: true,
          ),
          IdentificationFeature(
            icon: Icons.texture,
            title: 'Màu sắc & vân',
            description: 'Có đặc điểm màu sắc rõ ràng',
            isMatched: true,
          ),
          IdentificationFeature(
            icon: Icons.forest,
            title: 'Môi trường sống',
            description: 'Thường gặp ở khu vực này',
            isMatched: true,
          ),
        ];
    }
  }
}
