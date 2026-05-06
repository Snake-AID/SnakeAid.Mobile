import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/snake_species_provider.dart';
import '../models/snake_species_model.dart';

class SnakeDetailScreen extends ConsumerWidget {
  final int snakeId;

  const SnakeDetailScreen({super.key, required this.snakeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(snakeSpeciesDetailProvider(snakeId));

    if (state.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
        ),
      );
    }

    if (state.error != null || state.species == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1B5E20),
          foregroundColor: Colors.white,
          title: const Text('Chi tiết loài rắn'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 12),
              Text(
                state.error ?? 'Không tìm thấy loài rắn.',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref
                    .read(snakeSpeciesDetailProvider(snakeId).notifier)
                    .load(snakeId),
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final snake = state.species!;
    return _SnakeDetailView(snake: snake);
  }
}

class _SnakeDetailView extends StatelessWidget {
  final SnakeSpeciesModel snake;

  const _SnakeDetailView({required this.snake});

  @override
  Widget build(BuildContext context) {
    final riskColor = _riskColor(snake.riskLevel);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // Hero image sliver app bar
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                snake.commonName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.black54,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
              background: snake.imageUrl != null && snake.imageUrl!.isNotEmpty
                  ? Image.network(
                      snake.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Identity card
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Scientific name
                        Text(
                          snake.scientificName,
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (snake.alternativeNames.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Tên khác: ${snake.alternativeNames.join(', ')}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        // Risk + venom row
                        Row(
                          children: [
                            _InfoChip(
                              icon: Icons.local_fire_department,
                              label: 'Mức độ nguy hiểm: ${snake.riskLevel}/10',
                              color: riskColor,
                            ),
                            const SizedBox(width: 8),
                            if (snake.isVenomous)
                              _InfoChip(
                                icon: Icons.warning_rounded,
                                label: 'Có độc',
                                color: Colors.red[600]!,
                              ),
                          ],
                        ),
                        if (snake.primaryVenomType != null) ...[
                          const SizedBox(height: 8),
                          _InfoChip(
                            icon: Icons.science,
                            label: 'Loại độc: ${snake.venomTypeDisplayName}',
                            color: Colors.orange[700]!,
                          ),
                        ],
                        if (snake.description != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            snake.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Identification
                  if (snake.identification != null) ...[
                    _SectionHeader(icon: Icons.search, title: 'Nhận dạng'),
                    const SizedBox(height: 8),
                    if (snake.identificationSummary != null)
                      _SectionCard(
                        child: Text(
                          snake.identificationSummary!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (snake.identification!.physicalTraits.isNotEmpty)
                      _BulletListCard(
                        title: 'Đặc điểm hình thái',
                        icon: Icons.visibility,
                        iconColor: const Color(0xFF1B5E20),
                        items: snake.identification!.physicalTraits,
                      ),
                    const SizedBox(height: 8),
                    if (snake.identification!.behaviors.isNotEmpty)
                      _BulletListCard(
                        title: 'Tập tính',
                        icon: Icons.directions_run,
                        iconColor: Colors.orange[700]!,
                        items: snake.identification!.behaviors,
                      ),
                    const SizedBox(height: 8),
                    if (snake.identification!.habitat != null)
                      _SectionCard(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.landscape,
                              size: 18,
                              color: Colors.green[700],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Môi trường sống',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    snake.identification!.habitat!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],

                  // Venoms
                  if (snake.venoms.isNotEmpty) ...[
                    _SectionHeader(
                      icon: Icons.science_outlined,
                      title: 'Thông tin nọc độc',
                    ),
                    const SizedBox(height: 8),
                    ...snake.venoms.map(
                      (v) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _SectionCard(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.science,
                                  size: 16,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      v.venomType,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (v.description != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        v.description!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Symptoms by time
                  if (snake.symptomsByTime.isNotEmpty) ...[
                    _SectionHeader(
                      icon: Icons.timeline,
                      title: 'Triệu chứng theo thời gian',
                    ),
                    const SizedBox(height: 8),
                    ...snake.symptomsByTime.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _SymptomTimeCard(symptom: s),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // CTA button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push(
                        '/snake-first-aid/${snake.id}',
                        extra: {'commonName': snake.commonName},
                      ),
                      icon: const Icon(Icons.medical_services_outlined),
                      label: const Text(
                        'Xem cách sơ cứu khi bị loài này cắn',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFF1B5E20).withOpacity(0.6),
      child: const Center(
        child: Icon(Icons.pets, size: 80, color: Colors.white54),
      ),
    );
  }

  Color _riskColor(int level) {
    if (level >= 8) return const Color(0xFFB71C1C);
    if (level >= 5) return const Color(0xFFE65100);
    return const Color(0xFF2E7D32);
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF1B5E20).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF1B5E20)),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1B2A1B),
          ),
        ),
      ],
    );
  }
}

class _BulletListCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<String> items;

  const _BulletListCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[800],
                        height: 1.4,
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
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SymptomTimeCard extends StatelessWidget {
  final SnakeSymptomsByTime symptom;

  const _SymptomTimeCard({required this.symptom});

  @override
  Widget build(BuildContext context) {
    final borderColor = symptom.isCritical
        ? Colors.red[400]!
        : const Color(0xFF2E7D32);
    final bgColor = symptom.isCritical
        ? Colors.red.withOpacity(0.05)
        : const Color(0xFF1B5E20).withOpacity(0.04);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.4)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                symptom.isCritical
                    ? Icons.warning_amber_rounded
                    : Icons.access_time,
                size: 16,
                color: borderColor,
              ),
              const SizedBox(width: 6),
              Text(
                symptom.timeRange,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: borderColor,
                ),
              ),
              if (symptom.isCritical) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'NGUY HIỂM',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          ...symptom.signs.map(
            (sign) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: borderColor.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sign,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[800],
                        height: 1.4,
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
}
