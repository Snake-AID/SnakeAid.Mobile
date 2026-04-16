import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/snake_species_provider.dart';
import '../models/snake_first_aid_model.dart';

class SnakeFirstAidScreen extends ConsumerWidget {
  final int snakeSpeciesId;
  final String? commonName;

  const SnakeFirstAidScreen({
    super.key,
    required this.snakeSpeciesId,
    this.commonName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(snakeFirstAidProvider(snakeSpeciesId));

    if (state.isLoading) {
      return Scaffold(
        appBar: _buildAppBar(commonName ?? 'Sơ cứu rắn cắn'),
        body: const Center(
            child: CircularProgressIndicator(color: Color(0xFF1B5E20))),
      );
    }

    if (state.error != null || state.guideline == null) {
      return Scaffold(
        appBar: _buildAppBar(commonName ?? 'Sơ cứu rắn cắn'),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 12),
              Text(state.error ?? 'Không tải được hướng dẫn sơ cứu.',
                  style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref
                    .read(snakeFirstAidProvider(snakeSpeciesId).notifier)
                    .load(snakeSpeciesId),
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

    final guideline = state.guideline!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(
          commonName != null ? 'Sơ cứu: $commonName' : guideline.guidelineName),
      body: _FirstAidBody(guideline: guideline),
    );
  }

  AppBar _buildAppBar(String title) {
    return AppBar(
      backgroundColor: const Color(0xFFB71C1C),
      foregroundColor: Colors.white,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      elevation: 0,
    );
  }
}

class _FirstAidBody extends StatelessWidget {
  final SnakeFirstAidModel guideline;

  const _FirstAidBody({required this.guideline});

  @override
  Widget build(BuildContext context) {
    final content = guideline.content;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Emergency banner
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.emergency, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Khẩn cấp !',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Đây là hướng dẫn sơ cứu BAN ĐẦU. Luôn đến cơ sở y tế ngay lập tức.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Warnings
        if (guideline.warnings.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...guideline.warnings.map(
            (w) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: Colors.orange.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        w,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],

        // Steps
        if (content.steps.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionHeader(
              icon: Icons.format_list_numbered,
              title: 'Các bước sơ cứu',
              color: const Color(0xFF1565C0)),
          const SizedBox(height: 10),
          ...content.steps.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _StepCard(
                  stepNumber: e.key + 1, step: e.value),
            ),
          ),
        ],

        // Dos
        if (content.dos.isNotEmpty) ...[
          const SizedBox(height: 8),
          _SectionHeader(
              icon: Icons.check_circle_outline,
              title: 'Nên làm',
              color: const Color(0xFF2E7D32)),
          const SizedBox(height: 10),
          ...content.dos.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _MediaCard(step: d, accent: const Color(0xFF2E7D32)),
            ),
          ),
        ],

        // Don'ts
        if (content.donts.isNotEmpty) ...[
          const SizedBox(height: 8),
          _SectionHeader(
              icon: Icons.cancel_outlined,
              title: 'Không nên làm',
              color: const Color(0xFFB71C1C)),
          const SizedBox(height: 10),
          ...content.donts.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _MediaCard(step: d, accent: const Color(0xFFB71C1C)),
            ),
          ),
        ],

        // Notes
        if (content.notes.isNotEmpty) ...[
          const SizedBox(height: 8),
          _SectionHeader(
              icon: Icons.info_outline,
              title: 'Lưu ý',
              color: Colors.orange[800]!),
          const SizedBox(height: 10),
          ...content.notes.map(
            (n) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline,
                        size: 16, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        n,
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
          ),
        ],

        const SizedBox(height: 32),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader(
      {required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final int stepNumber;
  final FirstAidStep step;

  const _StepCard({required this.stepNumber, required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image (if available)
          if (step.mediaUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12)),
              child: Image.network(
                step.mediaUrl!,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step number circle
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1565C0),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$stepNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    step.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaCard extends StatelessWidget {
  final FirstAidStep step;
  final Color accent;

  const _MediaCard({required this.step, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (step.mediaUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12)),
              child: Image.network(
                step.mediaUrl!,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.circle, size: 8, color: accent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    step.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
