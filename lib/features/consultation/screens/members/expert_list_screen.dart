import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/expert_list_provider.dart';
import '../../models/expert_model.dart';

/// Expert List Screen for Members
/// Displays list of snake experts for consultation
class ExpertListScreen extends ConsumerStatefulWidget {
  const ExpertListScreen({super.key});

  @override
  ConsumerState<ExpertListScreen> createState() => _ExpertListScreenState();
}

class _ExpertListScreenState extends ConsumerState<ExpertListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reload data mỗi khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(expertListProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expertState = ref.watch(expertListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildAppBar(context),

            // Filter Section
            _buildFilterSection(context, expertState),

            // Active Filter Chips
            if (expertState.selectedSpecialty != null ||
                expertState.isOnlineFilter != null)
              _buildFilterChips(context, expertState),

            // Stats
            _buildStatsSection(expertState),

            // Expert List
            Expanded(
              child: _buildExpertList(context, expertState),
            ),
          ],
        ),
      ),
    );
  }

  /// Build top app bar
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back Button
          InkWell(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF1F2937),
              ),
            ),
          ),

          // Title
          const Expanded(
            child: Text(
              'Chuyên Gia Rắn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Search Button
          InkWell(
            onTap: () => _showSearchDialog(context),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: const Icon(
                Icons.search,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build filter section with dropdowns
  Widget _buildFilterSection(BuildContext context, ExpertListState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Specialty Filter
          Expanded(
            child: _buildDropdownField(
              label: 'Chuyên môn',
              value: state.selectedSpecialty ?? 'Tất cả chuyên môn',
              onTap: () => _showSpecialtyPicker(context, state),
            ),
          ),
          const SizedBox(width: 12),

          // Sort By Filter
          Expanded(
            child: _buildDropdownField(
              label: 'Sắp xếp theo',
              value: _getSortByLabel(state.sortBy),
              onTap: () => _showSortByPicker(context, state),
            ),
          ),
        ],
      ),
    );
  }

  /// Build dropdown field widget
  Widget _buildDropdownField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F8F6),
              border: Border.all(color: const Color(0xFFD1D5DB)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1F2937),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build filter chips
  Widget _buildFilterChips(BuildContext context, ExpertListState state) {
    return Container(
      color: const Color(0xFFF6F8F6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Specialty Chip
            if (state.selectedSpecialty != null &&
                state.selectedSpecialty != 'Tất cả chuyên môn')
              _buildFilterChip(
                label: state.selectedSpecialty!,
                onRemove: () {
                  ref
                      .read(expertListProvider.notifier)
                      .filterBySpecialty(null);
                },
              ),

            // IsOnline Filter Chip
            if (state.isOnlineFilter != null)
              Padding(
                padding: EdgeInsets.only(
                    left: state.selectedSpecialty != null ? 8 : 0),
                child: _buildFilterChip(
                  label: state.isOnlineFilter == true
                      ? 'Chỉ Online'
                      : 'Chỉ Offline',
                  onRemove: () {
                    ref
                        .read(expertListProvider.notifier)
                        .setIsOnlineFilter(null);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build single filter chip
  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      height: 32,
      padding: const EdgeInsets.only(left: 16, right: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF228B22).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF228B22),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 16,
              color: Color(0xFF228B22),
            ),
          ),
        ],
      ),
    );
  }

  /// Build stats section
  Widget _buildStatsSection(ExpertListState state) {
    final totalCount = state.filteredExperts.length;
    final onlineCount =
        state.filteredExperts.where((e) => e.isOnline).length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      alignment: Alignment.centerLeft,
      child: Text(
        '$totalCount chuyên gia - $onlineCount đang online',
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  /// Build expert list
  Widget _buildExpertList(BuildContext context, ExpertListState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF228B22),
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(height: 16),
              Text(
                state.error!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(expertListProvider.notifier).refresh();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF228B22),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.filteredExperts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Không tìm thấy chuyên gia phù hợp',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(expertListProvider.notifier).refresh(),
      color: const Color(0xFF228B22),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.filteredExperts.length,
        itemBuilder: (context, index) {
          final expert = state.filteredExperts[index];
          return _buildExpertCard(context, expert);
        },
      ),
    );
  }

  /// Build expert card
  Widget _buildExpertCard(BuildContext context, ExpertModel expert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: () => _navigateToExpertDetail(context, expert),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE5E7EB),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: expert.avatarUrl != null
                      ? CachedNetworkImage(
                          imageUrl: expert.avatarUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.person, size: 32),
                        )
                      : const Icon(Icons.person, size: 32),
                ),
                // Online indicator
                if (expert.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // Expert Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    expert.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Specialty Tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildSpecialtyTag(expert.primarySpecialty),
                      if (expert.isVerified) _buildVerifiedBadge(),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Rating
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Color(0xFFFBBF24),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        expert.reviewCount > 0
                            ? expert.rating.toStringAsFixed(1)
                            : 'Chưa có',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        expert.reviewCount > 0
                            ? '(${expert.reviewCount} đánh giá)'
                            : 'đánh giá',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Fee
                  Text(
                    expert.formattedFee,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF228B22),
                    ),
                  ),
                ],
              ),
            ),

            // Chevron
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF9CA3AF),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  /// Build specialty tag
  Widget _buildSpecialtyTag(String specialty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        specialty,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6366F1),
        ),
      ),
    );
  }

  /// Build verified badge
  Widget _buildVerifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            size: 12,
            color: Color(0xFF3B82F6),
          ),
          SizedBox(width: 4),
          Text(
            'Đã xác minh',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3B82F6),
            ),
          ),
        ],
      ),
    );
  }

  /// Show search dialog
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tìm kiếm chuyên gia'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Nhập tên chuyên gia...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement search
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng tìm kiếm đang phát triển'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF228B22),
            ),
            child: const Text('Tìm'),
          ),
        ],
      ),
    );
  }

  /// Show specialty picker
  void _showSpecialtyPicker(BuildContext context, ExpertListState state) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chọn chuyên môn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...state.specialties.map((specialty) {
                final isSelected = state.selectedSpecialty == specialty;
                return ListTile(
                  title: Text(specialty),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Color(0xFF228B22))
                      : null,
                  onTap: () {
                    ref
                        .read(expertListProvider.notifier)
                        .filterBySpecialty(specialty);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  /// Show sort by picker
  void _showSortByPicker(BuildContext context, ExpertListState state) {
    final sortOptions = {
      'online': 'Đang Online',
      'Rating': 'Đánh giá cao nhất',
      'ConsultationFee': 'Phí thấp nhất',
      'ReviewCount': 'Nhiều đánh giá nhất',
    };

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sắp xếp theo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...sortOptions.entries.map((entry) {
                final isSelected = state.sortBy == entry.key;
                return ListTile(
                  title: Text(entry.value),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Color(0xFF228B22))
                      : null,
                  onTap: () {
                    ref
                        .read(expertListProvider.notifier)
                        .changeSortOrder(entry.key);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  /// Get sort by label
  String _getSortByLabel(String sortBy) {
    switch (sortBy) {
      case 'Rating':
        return 'Đánh giá cao nhất';
      case 'ConsultationFee':
        return 'Phí thấp nhất';
      case 'ReviewCount':
        return 'Nhiều đánh giá nhất';
      case 'online':
      default:
        return 'Đang Online';
    }
  }

  /// Navigate to expert detail (placeholder)
  void _navigateToExpertDetail(BuildContext context, ExpertModel expert) {
    context.push('/expert-detail/${expert.id}');
  }
}
