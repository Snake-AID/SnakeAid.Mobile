import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/expert_detail_provider.dart';

// Primary color constant
const Color _primaryColor = Color(0xFF228B22);

/// Expert Profile Detail Screen
/// Displays comprehensive expert information including profile, experience,
/// statistics, consultation fees, availability, and patient reviews
class ExpertProfileDetailScreen extends ConsumerStatefulWidget {
  final String expertId;

  const ExpertProfileDetailScreen({
    super.key,
    required this.expertId,
  });

  @override
  ConsumerState<ExpertProfileDetailScreen> createState() =>
      _ExpertProfileDetailScreenState();
}

class _ExpertProfileDetailScreenState
    extends ConsumerState<ExpertProfileDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Invalidate mỗi lần mở screen — đảm bảo lịch trống luôn là data mới nhất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(expertDetailProvider(widget.expertId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expertDetailProvider(widget.expertId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Lỗi: ${state.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(expertDetailProvider(widget.expertId).notifier).refresh();
                        },
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : state.expert == null
                  ? const Center(child: Text('Không tìm thấy chuyên gia'))
                  : Stack(
                      children: [
                        // Main scrollable content
                        CustomScrollView(
                          slivers: [
                            // Top App Bar
                            SliverAppBar(
                              pinned: true,
                              backgroundColor: theme.colorScheme.surface,
                              leading: IconButton(
                                icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
                                onPressed: () => context.pop(),
                              ),
                              title: Text(
                                state.expert!.displayName,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              actions: [
                                IconButton(
                                  icon: const Icon(Icons.share, color: Color(0xFF1F2937)),
                                  onPressed: () {
                                    // TODO: Implement share functionality
                                  },
                                ),
                              ],
                            ),

                            // Content
                            SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  // Profile Header
                                  _buildProfileHeader(context, state.expert!),

                                  // Verified Badge & Specialties
                                  _buildSpecialties(context, state.expert!),

                                  // Main content sections
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Introduction
                                        _buildIntroductionSection(context, state.expert!),
                                        const SizedBox(height: 24),

                                        // Experience
                                        _buildExperienceSection(context, state.expert!),
                                        const SizedBox(height: 24),

                                        // Statistics
                                        _buildStatisticsSection(context, state.expert!),
                                        const SizedBox(height: 24),

                                        // Consultation Fees
                                        _buildFeesSection(context, state.expert!),
                                        const SizedBox(height: 24),

                                        // Availability
                                        _buildAvailabilitySection(context, state.expert!),
                                        const SizedBox(height: 24),

                                        // Reviews
                                        _buildReviewsSection(context, state.expert!),

                                        // Bottom padding for sticky footer
                                        const SizedBox(height: 160),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Sticky Footer with CTAs
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: _buildStickyFooter(context, state.expert!),
                        ),
                      ],
                    ),
    );
  }

  /// Build profile header section
  Widget _buildProfileHeader(BuildContext context, expert) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: expert.avatarUrl != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(expert.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: expert.avatarUrl == null ? Colors.grey[300] : null,
            ),
            child: expert.avatarUrl == null
                ? Icon(Icons.person, size: 64, color: Colors.grey[600])
                : null,
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            expert.displayName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Online Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: expert.isOnline
                  ? _primaryColor.withOpacity(0.1)
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: expert.isOnline ? _primaryColor : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  expert.isOnline ? 'Đang Online' : 'Offline',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: expert.isOnline ? _primaryColor : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                '${expert.rating} (${expert.reviewCount} đánh giá)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build specialties section with verified badge
  Widget _buildSpecialties(BuildContext context, expert) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Verified Badge
          if (expert.isVerified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, color: Colors.indigo[600], size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Chuyên gia đã xác minh',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.indigo[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),

          // Specialties Chips
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: expert.specialties.map<Widget>((specialty) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.indigo[600],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  specialty,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Build introduction section
  Widget _buildIntroductionSection(BuildContext context, expert) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Giới Thiệu',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                expert.bio ?? 'Chưa có thông tin giới thiệu',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Show full bio
                  },
                  child: const Text('Xem thêm'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build experience section
  Widget _buildExperienceSection(BuildContext context, expert) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kinh Nghiệm',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: expert.experienceList.map<Widget>((experience) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurfaceVariant,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        experience,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Build statistics section
  Widget _buildStatisticsSection(BuildContext context, expert) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thống Kê',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Total Consultations
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${expert.totalConsultations}+',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ca tư vấn',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Response Time
              Expanded(
                child: Column(
                  children: [
                    Text(
                      expert.averageResponseTime,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Thời gian phản hồi',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Success Rate
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${expert.successRate.toInt()}%',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tỷ lệ thành công',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build consultation fees section
  Widget _buildFeesSection(BuildContext context, expert) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ');

    String formatFee(double fee) =>
        fee <= 0 ? 'Miễn phí' : currencyFormat.format(fee);

    final fees = [
      ('Đặt lịch tư vấn', expert.scheduledConsultationFee as double),
      ('Tư vấn khẩn cấp', expert.emergencyConsultationFee as double),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phí Tư Vấn',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: fees.asMap().entries.map<Widget>((entry) {
              final index = entry.key;
              final label = entry.value.$1;
              final fee = entry.value.$2;
              final isLast = index == fees.length - 1;
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        formatFee(fee),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: _primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (!isLast) ...[
                    const SizedBox(height: 12),
                    Divider(color: theme.colorScheme.outline.withOpacity(0.3)),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Build availability section
  Widget _buildAvailabilitySection(BuildContext context, expert) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lịch Trống',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: expert.availability.length,
            itemBuilder: (context, index) {
              final day = expert.availability[index];

              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day.dayOfWeek,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day.day}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'tháng ${day.date.month}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build reviews section
  Widget _buildReviewsSection(BuildContext context, expert) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Đánh Giá Từ Bệnh Nhân',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Show all reviews
              },
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurfaceVariant,
              ),
              child: const Text('Xem tất cả'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...expert.reviews.take(2).map<Widget>((review) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reviewer info
                Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: review.patientAvatarUrl != null
                          ? CachedNetworkImageProvider(review.patientAvatarUrl!)
                          : null,
                      child: review.patientAvatarUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.patientName,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: List.generate(
                              5,
                              (index) => Icon(
                                index < review.rating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Review comment
                Text(
                  review.comment,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  /// Build sticky footer with action button
  Widget _buildStickyFooter(BuildContext context, expert) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: () {
              context.push('/service-selection/${expert.id}');
            },
            style: FilledButton.styleFrom(
              backgroundColor: _primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Đặt Tư Vấn',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
