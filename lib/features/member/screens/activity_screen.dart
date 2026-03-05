import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../snake_catching/repository/snake_catching_repository.dart';
import 'member_history_screen.dart';
import '../../snake_catching/models/snake_catching_request.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:intl/intl.dart';

/// Activity Screen - Shows user's snake catching requests
class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  bool _isLoading = true;
  List<SnakeCatchingRequestData> _requests = [];
  String? _errorMessage;
  Timer? _refreshTimer;

  // Statuses considered "history" — excluded from the active list
  static const _historyStatuses = {'completed', 'paid', 'dispute', 'cancelled', 'expired'};

  @override
  void initState() {
    super.initState();
    _loadRequests();
    // Auto-refresh every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _silentRefresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(snakeCatchingRepositoryProvider);
      final response = await repository.getRequests();
      final currentUser = ref.read(currentUserProvider);

      if (mounted) {
        setState(() {
          // Active requests only (history has its own screen)
          if (currentUser != null) {
            _requests = response.data
                .where((r) =>
                    r.userId == currentUser.id &&
                    !_historyStatuses.contains(r.status.toLowerCase()))
                .toList();
          } else {
            _requests = [];
          }
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

  /// Silent refresh without showing loading indicator
  Future<void> _silentRefresh() async {
    try {
      final repository = ref.read(snakeCatchingRepositoryProvider);
      final response = await repository.getRequests();
      final currentUser = ref.read(currentUserProvider);

      if (mounted) {
        setState(() {
          // Active requests only (history has its own screen)
          if (currentUser != null) {
            _requests = response.data
                .where((r) =>
                    r.userId == currentUser.id &&
                    !_historyStatuses.contains(r.status.toLowerCase()))
                .toList();
          } else {
            _requests = [];
          }
          _errorMessage = null;
        });
      }
    } catch (e) {
      // Silently fail - don't show error on background refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Bar
        Container(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Text(
                    'Hoạt Động',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF228B22),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadRequests,
                    tooltip: 'Làm mới',
                  ),
                  TextButton.icon(
                    onPressed: () => context.push('/member-history'),
                    icon: const Icon(Icons.history_rounded,
                        size: 18, color: Color(0xFF228B22)),
                    label: const Text(
                      'Lịch sử',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF228B22),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? _buildErrorView()
                  : _requests.isEmpty
                      ? _buildEmptyView()
                      : _buildRequestsList(),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFDC3545),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
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

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa Có Hoạt Động',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn chưa gửi yêu cầu bắt rắn nào.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/snake-quantity-selection');
              },
              icon: const Icon(Icons.add),
              label: const Text('Báo Cáo Rắn'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF228B22),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList() {
    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          return _buildRequestCard(request);
        },
      ),
    );
  }

  Widget _buildRequestCard(SnakeCatchingRequestData request) {
    final statusColor = _getStatusColor(request.status);
    final statusText = _getStatusText(request.status);
    final dateFormat = DateFormat('dd/MM/yyyy, HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          context.push('/activity-detail/${request.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status and Date Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    dateFormat.format(request.requestDate.toLocal()),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.address,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if (request.distanceKm != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.route, size: 16, color: Color(0xFF2196F3)),
                    const SizedBox(width: 6),
                    Text(
                      '${request.distanceKm!.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
              ],

              if (request.details.isNotEmpty) ...[
                const SizedBox(height: 12),
                // Snake Species
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: request.details.take(3).map((detail) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F8F6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 14,
                            color: Color(0xFFFF9800),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${detail.snakeSpeciesName} (${detail.quantity})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                if (request.details.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '+${request.details.length - 3} loài khác',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
              
              // Priority if high
              if (request.priority != 'Normal') ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.priority_high,
                      size: 16,
                      color: _getPriorityColor(request.priority),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Ưu tiên: ${request.priority}',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getPriorityColor(request.priority),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              // Payment hint for Assigned orders
              if (request.status == 'Assigned') ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFCC02)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.payments_outlined, size: 14, color: Color(0xFFFF8F00)),
                      SizedBox(width: 6),
                      Text(
                        'Nhấn để xem chi tiết & thanh toán phí di chuyển',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFFF8F00),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFA500);
      case 'assigned':
        return const Color(0xFF2196F3);
      case 'finished':
        return const Color(0xFFFF6B35);
      case 'paid':
        return const Color(0xFF17A2B8);
      case 'completed':
        return const Color(0xFF228B22);
      case 'dispute':
        return const Color(0xFFDC3545);
      case 'cancelled':
      case 'expired':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ Xử Lý';
      case 'assigned':
        return 'Đã Phân Công';
      case 'finished':
        return 'Cần Thanh Toán';
      case 'paid':
        return 'Đã Thanh Toán';
      case 'completed':
        return 'Hoàn Thành';
      case 'dispute':
        return 'Đang Tranh Chấp';
      case 'cancelled':
        return 'Đã Hủy';
      case 'expired':
        return 'Hết Hạn';
      default:
        return status;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFDC3545);
      case 'medium':
        return const Color(0xFFFFA500);
      default:
        return const Color(0xFF228B22);
    }
  }
}
