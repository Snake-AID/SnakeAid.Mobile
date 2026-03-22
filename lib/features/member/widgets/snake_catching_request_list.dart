import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../snake_catching/models/snake_catching_request.dart';
import '../../snake_catching/repository/snake_catching_repository.dart';

class SnakeCatchingRequestList extends ConsumerStatefulWidget {
  final String userId;
  final bool showHistory;

  const SnakeCatchingRequestList({
    super.key,
    required this.userId,
    this.showHistory = false,
  });

  @override
  ConsumerState<SnakeCatchingRequestList> createState() =>
      _SnakeCatchingRequestListState();
}

class _SnakeCatchingRequestListState
    extends ConsumerState<SnakeCatchingRequestList> {
  List<SnakeCatchingRequestData> _requests = [];
  bool _isLoading = true;
  String? _errorMessage;

  static const _historyStatuses = {
    'completed',
    'paid',
    'dispute',
    'cancelled',
    'expired',
  };

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
      final repository = ref.read(snakeCatchingRepositoryProvider);
      final response = await repository.getRequests();
      final list =
          response.data
              .where(
                (r) =>
                    r.userId == widget.userId &&
                    (widget.showHistory
                        ? _historyStatuses.contains(r.status.toLowerCase())
                        : !_historyStatuses.contains(r.status.toLowerCase())),
              )
              .toList()
            ..sort((a, b) => b.requestDate.compareTo(a.requestDate));

      setState(() {
        _requests = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF228B22)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadRequests,
              child: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF228B22),
              ),
            ),
          ],
        ),
      );
    }

    if (_requests.isEmpty) {
      return Center(
        child: Text(
          widget.showHistory
              ? 'Không có lịch sử bắt rắn'
              : 'Chưa có hoạt động bắt rắn',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFF228B22),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          return _buildRequestCard(context, request);
        },
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    SnakeCatchingRequestData request,
  ) {
    final statusColor = _getStatusColor(request.status);
    final statusText = _getStatusText(request.status);
    final dateFormat = DateFormat('dd/MM/yyyy, HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/activity-detail/${request.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
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
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: request.details.take(3).map((detail) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
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
              if (request.status == 'Assigned') ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFCC02)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        size: 14,
                        color: Color(0xFFFF8F00),
                      ),
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
      case 'confirmed':
        return const Color(0xFF4CAF50);
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
      case 'confirmed':
        return 'Đã Xác Nhận';
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
