import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../snake_catching/repository/snake_catching_repository.dart';
import '../../snake_catching/models/snake_catching_request.dart';
import '../../auth/providers/auth_provider.dart';

/// History Screen — shows only completed / paid / dispute requests
class MemberHistoryScreen extends ConsumerStatefulWidget {
  const MemberHistoryScreen({super.key});

  @override
  ConsumerState<MemberHistoryScreen> createState() =>
      _MemberHistoryScreenState();
}

class _MemberHistoryScreenState extends ConsumerState<MemberHistoryScreen> {
  bool _isLoading = true;
  List<SnakeCatchingRequestData> _requests = [];
  String? _errorMessage;

  static const _historyStatuses = {'completed', 'paid', 'dispute', 'cancelled', 'expired'};

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(snakeCatchingRepositoryProvider);
      final currentUser = ref.read(currentUserProvider);
      final response = await repo.getRequests();

      if (mounted) {
        setState(() {
          _requests = response.data
              .where((r) =>
                  (currentUser == null || r.userId == currentUser.id) &&
                  _historyStatuses.contains(r.status.toLowerCase()))
              .toList()
            ..sort((a, b) => b.requestDate.compareTo(a.requestDate));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF228B22);
      case 'paid':
        return const Color(0xFF17A2B8);
      case 'dispute':
        return const Color(0xFFDC3545);
      case 'cancelled':
      case 'expired':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'paid':
        return Icons.payments_rounded;
      case 'dispute':
        return Icons.gavel_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'expired':
        return Icons.timer_off_rounded;
      default:
        return Icons.help_outline;
    }
  }

  String _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Hoàn Thành';
      case 'paid':
        return 'Đã Thanh Toán';
      case 'dispute':
        return 'Tranh Chấp';
      case 'cancelled':
        return 'Đã Hủy';
      case 'expired':
        return 'Hết Hạn';
      default:
        return status;
    }
  }

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF228B22), size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Lịch Sử',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF228B22),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF228B22)),
            onPressed: _loadRequests,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF228B22)))
          : _errorMessage != null
              ? _buildError()
              : _requests.isEmpty
                  ? _buildEmpty()
                  : _buildList(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFDC3545)),
            const SizedBox(height: 16),
            Text(_errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRequests,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử Lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF228B22),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Chưa có lịch sử',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Các yêu cầu đã hoàn thành sẽ xuất hiện ở đây.',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    final fmt = DateFormat('dd/MM/yyyy, HH:mm');
    // Group by month
    final Map<String, List<SnakeCatchingRequestData>> grouped = {};
    for (final req in _requests) {
      final key = DateFormat('MM/yyyy').format(req.requestDate.toLocal());
      grouped.putIfAbsent(key, () => []).add(req);
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      color: const Color(0xFF228B22),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF228B22).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Tháng ${entry.key}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF228B22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.value.length} yêu cầu',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              ...entry.value.map((req) => _buildCard(req, fmt)),
              const SizedBox(height: 4),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCard(SnakeCatchingRequestData req, DateFormat fmt) {
    final color = _statusColor(req.status);
    final icon  = _statusIcon(req.status);
    final label = _statusText(req.status);

    return GestureDetector(
      onTap: () => context.push('/activity-detail/${req.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Colored top bar ──────────────────────────────────
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge + date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 12, color: color),
                            const SizedBox(width: 5),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        fmt.format(req.requestDate.toLocal()),
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 15, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          req.address,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Distance
                  if (req.distanceKm != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.route_rounded,
                            size: 14, color: Color(0xFF2196F3)),
                        const SizedBox(width: 5),
                        Text(
                          '${req.distanceKm!.toStringAsFixed(1)} km',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF2196F3),
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],

                  // Snake species chips
                  if (req.details.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: req.details.take(3).map((d) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F8F6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFFE0E0E0)),
                          ),
                          child: Text(
                            '${d.snakeSpeciesName} ×${d.quantity}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500),
                          ),
                        );
                      }).toList(),
                    ),
                    if (req.details.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '+${req.details.length - 3} loài khác',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                  ],

                  const SizedBox(height: 10),

                  // View detail row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Xem chi tiết',
                        style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 3),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 11, color: color),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
