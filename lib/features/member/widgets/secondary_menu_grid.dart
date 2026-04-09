import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../snake_species/providers/snake_species_provider.dart';
import '../../community_report/repository/community_report_repository.dart';
import '../screens/payment_history_screen.dart';

final _alertCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(communityReportRepositoryProvider);
  final reports = await repo.getReports(pageSize: 100);
  return reports.length;
});

/// Secondary menu grid - 5 action items
class SecondaryMenuGrid extends ConsumerWidget {
  const SecondaryMenuGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snakeState = ref.watch(snakeSpeciesListProvider);
    final alertCount = ref.watch(_alertCountProvider);

    final snakeCountBadge = snakeState.species.isEmpty
        ? null
        : '${snakeState.species.length}';
    final alertBadge = alertCount.maybeWhen(
      data: (c) => c > 0 ? '$c' : null,
      orElse: () => null,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              _MenuItem(
                icon: Icons.support_agent,
                label: 'Tư vấn\nchuyên gia',
                hasStatusDot: true,
                onTap: () => context.push('/consultation-home'),
              ),
              const SizedBox(width: 12),
              _MenuItem(
                icon: Icons.health_and_safety_outlined,
                label: 'Hướng dẫn\nsơ cứu',
                onTap: () => context.push('/snake-first-aid-guide'),
              ),
              const SizedBox(width: 12),
              _MenuItem(
                icon: Icons.menu_book_outlined,
                label: 'Thư viện\nloài rắn',
                badge: snakeCountBadge,
                onTap: () => context.push('/snake-species'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MenuItem(
                icon: Icons.warning_amber_rounded,
                label: 'Cảnh báo\nkhu vực',
                badge: alertBadge,
                badgeColor: const Color(0xFFDC3545),
                onTap: () => context.pushNamed('community_alert_map'),
              ),
              const SizedBox(width: 12),
              _MenuItem(
                icon: Icons.receipt_long_outlined,
                label: 'Thanh toán\n& lịch sử',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PaymentHistoryScreen(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final Color? badgeColor;
  final bool hasStatusDot;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.badge,
    this.badgeColor,
    this.hasStatusDot = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 360;

    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: compact ? 100 : 110,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 6 : 8,
              vertical: compact ? 8 : 10,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF228B22).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(
                            icon,
                            size: compact ? 20 : 22,
                            color: const Color(0xFF228B22),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: compact ? 10 : 10.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (badge != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor ?? const Color(0xFF6C757D),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(minWidth: 20, minHeight: 16),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (hasStatusDot)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF228B22),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
