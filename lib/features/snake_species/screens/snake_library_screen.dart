import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/snake_species_provider.dart';
import '../models/snake_species_model.dart';

class SnakeLibraryScreen extends ConsumerStatefulWidget {
  const SnakeLibraryScreen({super.key});

  @override
  ConsumerState<SnakeLibraryScreen> createState() =>
      _SnakeLibraryScreenState();
}

class _SnakeLibraryScreenState
    extends ConsumerState<SnakeLibraryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(snakeSpeciesListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        title: const Text(
          'Thư viện loài rắn',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: const Color(0xFF1B5E20),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (v) =>
                  ref.read(snakeSpeciesListProvider.notifier).search(v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm tên loài rắn...',
                hintStyle:
                    TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: Icon(Icons.search,
                    color: Colors.white.withOpacity(0.8)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(snakeSpeciesListProvider.notifier)
                              .search('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Count bar
          if (!state.isLoading && state.error == null)
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.pets,
                      size: 16,
                      color: const Color(0xFF1B5E20).withOpacity(0.7)),
                  const SizedBox(width: 6),
                  Text(
                    '${state.filtered.length} loài',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

          // Body
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildBody(SnakeSpeciesListState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 12),
            Text(
              state.error!,
              style: const TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(snakeSpeciesListProvider.notifier).loadSpecies(),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (state.filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Không tìm thấy loài rắn nào.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _SnakeCard(snake: state.filtered[index]),
    );
  }
}

class _SnakeCard extends StatelessWidget {
  final SnakeSpeciesModel snake;

  const _SnakeCard({required this.snake});

  @override
  Widget build(BuildContext context) {
    final riskColor = _riskColor(snake.riskLevel);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/snake-species/${snake.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Snake image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: snake.imageUrl != null && snake.imageUrl!.isNotEmpty
                    ? Image.network(
                        snake.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _placeholderImage(),
                      )
                    : _placeholderImage(),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Common name + risk badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            snake.commonName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1B2A1B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _RiskBadge(
                            riskLevel: snake.riskLevel,
                            color: riskColor),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      snake.scientificName,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (snake.identificationSummary != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        snake.identificationSummary!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Tags
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (snake.isVenomous)
                          _Tag(
                            label: 'Độc',
                            color: Colors.red[600]!,
                            icon: Icons.warning_rounded,
                          ),
                        if (snake.primaryVenomType != null)
                          _Tag(
                            label: snake.primaryVenomType!,
                            color: Colors.orange[700]!,
                            icon: Icons.science,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Color(0xFF1B5E20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.pets,
          size: 36, color: Color(0xFF1B5E20)),
    );
  }

  Color _riskColor(int level) {
    if (level >= 8) return const Color(0xFFB71C1C);
    if (level >= 5) return const Color(0xFFE65100);
    return const Color(0xFF2E7D32);
  }
}

class _RiskBadge extends StatelessWidget {
  final int riskLevel;
  final Color color;

  const _RiskBadge({required this.riskLevel, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            '$riskLevel/10',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _Tag(
      {required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
