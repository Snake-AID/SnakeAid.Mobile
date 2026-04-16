import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import '../../../../core/providers/http_provider.dart';
import '../../../../core/services/emergency_consultation_signalr_service.dart';
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
  EmergencyConsultationSignalRService? _presenceService;
  StreamSubscription<Set<String>>? _snapshotSub;
  StreamSubscription<ExpertPresenceChangedEvent>? _presenceChangedSub;

  @override
  void initState() {
    super.initState();
    // Reload data mỗi khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(expertListProvider.notifier).resetForMemberListUi();
      _initPresenceRealtime();
    });
  }

  Future<void> _initPresenceRealtime() async {
    try {
      final baseUrl = ref.read(httpServiceProvider).baseUrl;
      _presenceService = EmergencyConsultationSignalRService(baseUrl: baseUrl);

      _snapshotSub = _presenceService!.onlineExpertsSnapshotStream.listen((ids) {
        if (!mounted) return;
        ref.read(expertListProvider.notifier).applyOnlineExpertsSnapshot(ids);
      });

      _presenceChangedSub =
          _presenceService!.expertPresenceChangedStream.listen((event) {
        if (!mounted) return;
        ref.read(expertListProvider.notifier).applyExpertPresenceChanged(
              expertId: event.expertId,
              isOnline: event.isOnline,
            );
      });

      await _presenceService!.connectAsMember();
    } catch (e) {
      debugPrint('Khong the ket noi presence SignalR o expert list: $e');
    }
  }

  @override
  void dispose() {
    _snapshotSub?.cancel();
    _presenceChangedSub?.cancel();
    _presenceService?.dispose();
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

            // Inline Search
            _buildSearchSection(expertState),

            // Filter Section
            _buildFilterSection(context, expertState),

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

          const SizedBox(
            width: 40,
            height: 40,
          ),
        ],
      ),
    );
  }

  /// Build inline search section (search by expert name)
  Widget _buildSearchSection(ExpertListState state) {
    if (_searchController.text != state.searchQuery) {
      _searchController.text = state.searchQuery;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          ref.read(expertListProvider.notifier).setSearchQuery(value);
        },
        decoration: InputDecoration(
          hintText: 'Tìm theo tên chuyên gia...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: state.searchQuery.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(expertListProvider.notifier).setSearchQuery('');
                  },
                ),
          filled: true,
          fillColor: const Color(0xFFF6F8F6),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
        ),
      ),
    );
  }

  /// Build filter section with only sort dropdown
  Widget _buildFilterSection(BuildContext context, ExpertListState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: _buildDropdownField(
        label: 'Sắp xếp theo',
        value: _getSortByLabel(state.sortBy),
        onTap: () => _showSortByPicker(context, state),
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
        state.searchQuery.isEmpty
            ? '$totalCount chuyên gia - $onlineCount đang online'
            : '$totalCount kết quả cho "${state.searchQuery}" - $onlineCount đang online',
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      Expanded(
                        child: Text(
                          expert.reviewCount > 0
                              ? '(${expert.reviewCount} đánh giá)'
                              : 'đánh giá',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Fee
                  Text(
                    expert.formattedFee,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

  /// Show sort by picker
  void _showSortByPicker(BuildContext context, ExpertListState state) {
    const sortOptions = {
      'online': 'Đang Online',
      'Rating': 'Đánh giá cao nhất',
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
