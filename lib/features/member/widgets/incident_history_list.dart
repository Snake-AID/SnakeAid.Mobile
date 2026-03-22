import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:snakeaid_mobile/features/emergency/models/detailed_incident_response.dart';
import '../../emergency/models/list_incident_response.dart';
import '../../emergency/repository/incident_repository.dart';

class IncidentHistoryList extends ConsumerStatefulWidget {
  final String userId;
  final bool showHistory;

  const IncidentHistoryList({
    super.key,
    required this.userId,
    this.showHistory = true,
  });

  @override
  ConsumerState<IncidentHistoryList> createState() =>
      _IncidentHistoryListState();
}

class _IncidentHistoryListState extends ConsumerState<IncidentHistoryList> {
  final _scrollController = ScrollController();
  final List<ListIncidentData> _items = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _page = 1;
  int _pageSize = 20;
  int _totalPages = 1;

  static const _historyStatuses = {
    IncidentStatus.completed,
    IncidentStatus.cancelled,
    IncidentStatus.falseAlarm,
    IncidentStatus.noRescuerFound,
    IncidentStatus.disputed,
  };

  static const _activeStatuses = {
    IncidentStatus.pending,
    IncidentStatus.verified,
    IncidentStatus.searching,
    IncidentStatus.assigned,
    IncidentStatus.inProgress,
    IncidentStatus.finished,
  };

  @override
  void initState() {
    super.initState();
    _loadPage(clear: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels + 200 >=
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore &&
        !_isLoading &&
        _page < _totalPages) {
      _loadPage();
    }
  }

  Future<void> _loadPage({bool clear = false}) async {
    if (!mounted) return;

    if (clear) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _page = 1;
        _items.clear();
      });
    } else {
      setState(() {
        _isLoadingMore = true;
        _errorMessage = null;
      });
    }

    try {
      final repository = ref.read(incidentRepositoryProvider);
      final response = await repository.getUserIncidentList(
        widget.userId,
        page: _page,
        pageSize: _pageSize,
      );

      final statuses = widget.showHistory ? _historyStatuses : _activeStatuses;
      final fetched = response.items
          .where((i) => statuses.contains(i.status))
          .toList();

      setState(() {
        _items.addAll(fetched);
        _totalPages = response.meta.totalPages;
        _page += 1;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadPage(clear: true);
  }

  Color _statusColor(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.pending:
      case IncidentStatus.verified:
      case IncidentStatus.searching:
        return const Color(0xFFFFA500);
      case IncidentStatus.assigned:
      case IncidentStatus.inProgress:
        return const Color(0xFF2196F3);
      case IncidentStatus.finished:
      case IncidentStatus.completed:
        return const Color(0xFF228B22);
      case IncidentStatus.disputed:
        return const Color(0xFFDC3545);
      case IncidentStatus.cancelled:
      case IncidentStatus.falseAlarm:
      case IncidentStatus.noRescuerFound:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF228B22)),
      );
    }

    if (_errorMessage != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 54, color: Color(0xFFDC3545)),
            const SizedBox(height: 8),
            Text(_errorMessage!),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _loadPage(clear: true),
              child: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF228B22),
              ),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Text(
          'Không tìm thấy lịch sử sự cố',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF228B22),
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _items.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF228B22)),
              ),
            );
          }

          final incident = _items[index];
          return _buildIncidentCard(context, incident);
        },
      ),
    );
  }

  Widget _buildIncidentCard(BuildContext context, ListIncidentData incident) {
    final statusColor = _statusColor(incident.status);
    final fmt = DateFormat('dd/MM/yyyy • HH:mm');
    final date = incident.incidentOccurredAt ?? DateTime.now();
    final mission = incident.activeMission;

    return Card(
      color: const Color(0xFFF8FAFF),
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () {
          context.push(
            '/member-incident-finished-detail',
            extra: {'incidentId': incident.id},
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      incident.address ?? 'Vị trí chưa xác định',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor, width: 0.8),
                    ),
                    child: Text(
                      incident.status.displayText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    fmt.format(date.toLocal()),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Text(
                    'Muc do: ${incident.severityText}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              if (mission != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.payment,
                      size: 14,
                      color: Color(0xFF2E7D32),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Giá dịch vụ: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(mission.price ?? 0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (mission.actualCost != null) ...[
                      const Spacer(),
                      Text(
                        'Thực tế: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(mission.actualCost)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
