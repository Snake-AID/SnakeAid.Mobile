import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:snakeaid_mobile/features/emergency/models/detailed_incident_response.dart';
import 'package:snakeaid_mobile/features/emergency/providers/incident_provider.dart';
import 'package:snakeaid_mobile/features/emergency/providers/mission_hub_provider.dart';
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
  bool _isTrackingDialogVisible = false;
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

  bool _shouldOpenTracking(IncidentStatus status) {
    return status == IncidentStatus.pending ||
        status == IncidentStatus.verified ||
        status == IncidentStatus.searching ||
        status == IncidentStatus.assigned ||
        status == IncidentStatus.inProgress;
  }

  void _showTrackingLoadingDialog() {
    _isTrackingDialogVisible = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF228B22)),
                SizedBox(height: 16),
                Text('Đang tải theo dõi sự cố...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _hideTrackingLoadingDialog() {
    if (!mounted || !_isTrackingDialogVisible) return;
    _isTrackingDialogVisible = false;
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  Future<void> _handleIncidentTap(ListIncidentData incident) async {
    final shouldShowLoading = _shouldOpenTracking(incident.status);

    if (shouldShowLoading) {
      _showTrackingLoadingDialog();
    }

    try {
      final repository = ref.read(incidentRepositoryProvider);
      final response = await repository.getIncident(incident.id);

      if (!mounted) return;

      if (!response.isSuccess || response.data == null) {
        if (shouldShowLoading) {
          _hideTrackingLoadingDialog();
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message)));
        return;
      }

      final latestIncident = response.data!;
      final latestStatus = IncidentStatus.fromString(latestIncident.status);

      if (_shouldOpenTracking(latestStatus)) {
        await ref
            .read(activeIncidentProvider.notifier)
            .saveActiveIncident(latestIncident);

        if (!mounted) return;

        final stillActive = ref.read(activeIncidentProvider).hasActiveIncident;
        if (!stillActive) {
          if (shouldShowLoading) {
            _hideTrackingLoadingDialog();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Yêu cầu SOS này đã kết thúc (${latestStatus.displayText}).',
              ),
            ),
          );
          return;
        }

        final status = ref.read(missionStatusProvider);
        if (shouldShowLoading) {
          _hideTrackingLoadingDialog();
        }
        context.pushNamed(
          'emergency_tracking',
          extra: {
            'incidentId': latestIncident.id,
            if (status.hasRescuer) 'missionId': status.missionId!,
            if (status.hasRescuer) 'rescuerId': status.rescuerId!,
          },
        );
        return;
      }

      if (shouldShowLoading) {
        _hideTrackingLoadingDialog();
      }
      context.push(
        '/member-incident-finished-detail',
        extra: {'incidentId': latestIncident.id},
      );
    } catch (e) {
      if (!mounted) return;
      if (shouldShowLoading) {
        _hideTrackingLoadingDialog();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể tải thông tin sự cố. ${e.toString().replaceAll('Exception: ', '')}',
          ),
        ),
      );
    }
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
    final statusText = incident.status.displayText;
    final fmt = DateFormat('dd/MM/yyyy, HH:mm');
    final date = incident.incidentOccurredAt ?? DateTime.now();
    final mission = incident.activeMission;
    final canPay = incident.status == IncidentStatus.finished;
    final fmt2 = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () => _handleIncidentTap(incident),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Status badge + Date ──────────────────────────────
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
                  Icon(Icons.access_time, size: 13, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    fmt.format(date.toLocal()),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ─── Address ──────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      incident.address ?? 'Vị trí chưa xác định',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ─── Severity ─────────────────────────────────────────
              Row(
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Mức độ: ${incident.severityText}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),

              // ─── Mission cost ─────────────────────────────────────
              if (mission != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 15, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      'Chi phí: ${fmt2.format(mission.actualCost ?? mission.price ?? 0)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    if (mission.actualCost != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Thực tế',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              // ─── Payment-needed banner ────────────────────────────
              if (canPay) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFFD600).withOpacity(0.7),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.payment, size: 16, color: Color(0xFFF57F17)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cần thanh toán · Nhấn để xem và thanh toán',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF57F17),
                          ),
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
}
