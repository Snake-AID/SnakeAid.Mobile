import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Expert Specialties Screen - Manage expert specialties and treatment protocols
/// Màn hình chuyên môn & lĩnh vực của Chuyên gia
class ExpertSpecialtiesScreen extends StatefulWidget {
  const ExpertSpecialtiesScreen({super.key});

  @override
  State<ExpertSpecialtiesScreen> createState() =>
      _ExpertSpecialtiesScreenState();
}

class _ExpertSpecialtiesScreenState extends State<ExpertSpecialtiesScreen> {
  final Set<String> _selectedSnakes = {
    'Rắn Hổ Mang',
    'Rắn Lục Xanh',
    'Trăn Gấm',
  };
  final Set<String> _selectedRegions = {'Bắc', 'Nam'};
  final Set<String> _selectedProtocols = {
    'Sơ cứu tại chỗ',
    'Liều lượng huyết thanh',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F8),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 140),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoBanner(),
                  const SizedBox(height: 24),
                  _buildSnakesSection(),
                  const SizedBox(height: 24),
                  _buildRegionsSection(),
                  const SizedBox(height: 24),
                  _buildProtocolsSection(),
                  const SizedBox(height: 24),
                  _buildSummaryBox(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF7F6F8),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF131018)),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Chuyên Môn & Lĩnh Vực',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF131018),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saveChanges,
          child: const Text(
            'Lưu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6C47C2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF6C47C2).withOpacity(0.05),
        border: Border.all(color: const Color(0xFF6C47C2).withOpacity(0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: const Color(0xFF6C47C2), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Thông tin quan trọng',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF131018),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Cập nhật hồ sơ chuyên môn giúp hệ thống kết nối bạn với các ca cứu hộ phù hợp nhất trong khu vực của bạn.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnakesSection() {
    final snakes = [
      {
        'name': 'Rắn Hổ Mang',
        'latin': 'Naja naja',
        'level': 'Chuyên gia',
        'image': 'https://via.placeholder.com/40',
      },
      {
        'name': 'Rắn Lục Xanh',
        'latin': 'Trimeresurus',
        'level': 'Thành thạo',
        'image': 'https://via.placeholder.com/40',
      },
      {
        'name': 'Cặp Nong',
        'latin': 'Bungarus',
        'level': null,
        'image': 'https://via.placeholder.com/40',
      },
      {
        'name': 'Trăn Gấm',
        'latin': 'Reticulated Python',
        'level': 'Sơ cấp',
        'image': 'https://via.placeholder.com/40',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Các Loài Rắn Chuyên Môn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF131018),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6C47C2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Đã chọn ${_selectedSnakes.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6C47C2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: snakes.length,
          itemBuilder: (context, index) {
            final snake = snakes[index];
            final isSelected = _selectedSnakes.contains(snake['name']);
            return _buildSnakeCard(
              name: snake['name'] as String,
              latin: snake['latin'] as String,
              level: snake['level'] as String?,
              imageUrl: snake['image'] as String,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedSnakes.remove(snake['name']);
                  } else {
                    _selectedSnakes.add(snake['name'] as String);
                  }
                });
              },
            );
          },
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thêm loài khác - Đang phát triển')),
            );
          },
          icon: const Icon(Icons.add, color: Color(0xFF6C47C2)),
          label: const Text(
            'Thêm loài khác',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6C47C2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSnakeCard({
    required String name,
    required String latin,
    String? level,
    required String imageUrl,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6C47C2)
                : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6C47C2).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image,
                                color: Colors.grey,
                              );
                            },
                          ),
                        ),
                      ),
                      if (level != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C47C2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            level,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6C47C2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF131018),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    latin,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C47C2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFF7F6F8),
                      width: 2,
                    ),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionsSection() {
    final regions = [
      {
        'name': 'Bắc',
        'title': 'Khu Vực Miền Bắc',
        'subtitle': 'Hà Nội, Hải Phòng, Quảng Ninh...',
      },
      {
        'name': 'Trung',
        'title': 'Khu Vực Miền Trung',
        'subtitle': 'Đà Nẵng, Huế, Quảng Nam...',
      },
      {
        'name': 'Nam',
        'title': 'Khu Vực Miền Nam',
        'subtitle': 'TP.HCM, Cần Thơ, Bình Dương...',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Khu Vực Địa Lý',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF131018),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Column(
            children: regions.map((region) {
              final isSelected = _selectedRegions.contains(region['name']);
              final isLast = region == regions.last;

              return Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedRegions.remove(region['name']);
                          } else {
                            _selectedRegions.add(region['name'] as String);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    region['title'] as String,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF131018),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    region['subtitle'] as String,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF6C47C2)
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF6C47C2)
                                      : const Color(0xFFCCCCCC),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProtocolsSection() {
    final protocols = [
      {'name': 'Sơ cứu tại chỗ', 'icon': Icons.medical_services},
      {'name': 'Liều lượng huyết thanh', 'icon': Icons.vaccines},
      {'name': 'Xử lý triệu chứng', 'icon': Icons.monitor_heart},
      {'name': 'Chăm sóc hậu phẫu', 'icon': Icons.healing},
      {'name': 'Phục hồi chức năng', 'icon': Icons.accessibility_new},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Các Giao Thức Điều Trị',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF131018),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: protocols.map((protocol) {
            final isSelected = _selectedProtocols.contains(protocol['name']);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedProtocols.remove(protocol['name']);
                  } else {
                    _selectedProtocols.add(protocol['name'] as String);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6C47C2).withOpacity(0.05)
                      : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6C47C2)
                        : const Color(0xFFE0E0E0),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      protocol['icon'] as IconData,
                      size: 20,
                      color: isSelected
                          ? const Color(0xFF6C47C2)
                          : const Color(0xFF666666),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      protocol['name'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF6C47C2)
                            : const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSummaryBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Bạn đang chọn ${_selectedSnakes.length} loài rắn và ${_selectedRegions.length} khu vực hoạt động.',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF7F6F8),
          border: const Border(top: BorderSide(color: Color(0xFFE0E0E0))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C47C2),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0xFF6C47C2).withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Lưu Thay Đổi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text(
                  'Hủy bỏ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF666666),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu thay đổi thành công!')),
    );
    context.pop();
  }
}
