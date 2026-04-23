import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:snakeaid_mobile/features/emergency/models/rescue_mission_response.dart';
import 'package:snakeaid_mobile/features/emergency/repository/rescue_mission_repository.dart';
import 'package:snakeaid_mobile/features/emergency/screens/rescuers/rescuer_mission_detail_screen.dart';
import 'package:snakeaid_mobile/features/emergency/screens/rescuers/rescuer_mission_history_detail_screen.dart';

class RescuerMissionHistoryScreen extends ConsumerStatefulWidget {
  const RescuerMissionHistoryScreen({super.key});

  @override
  ConsumerState<RescuerMissionHistoryScreen> createState() =>
      RescuerMissionHistoryScreenState();
}

class RescuerMissionHistoryScreenState
    extends ConsumerState<RescuerMissionHistoryScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Tất cả', 'Hoàn thành', 'Đã hủy'];

  bool _isLoading = false;
  String? _errorMessage;
  List<RescueMissionListItem> _allHistory = [];

  static const _completedStatuses = {
    'MissionCompleted',
    'Completed',
    'Finished',
  };

  static const _abortedStatuses = {'MissionAborted', 'Cancelled', 'Aborted'};

  List<RescueMissionListItem> get _filtered {
    switch (_selectedTabIndex) {
      case 1:
        return _allHistory
            .where((r) => _completedStatuses.contains(r.status))
            .toList();
      case 2:
        return _allHistory
            .where((r) => _abortedStatuses.contains(r.status))
            .toList();
      default:
        return _allHistory;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(rescueMissionRepositoryProvider);
      final response = await repo.getRescuerMissionList();
      if (!mounted) return;

      if (response.isSuccess) {
        setState(() {
          _allHistory = response.data
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void refresh() => _loadHistory();

  String _formatDate(DateTime? dt) {
    if (dt == null) return '--';
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--';
    return DateFormat('HH:mm').format(dt);
  }

  String _formatCurrency(double? amount) {
    if (amount == null) return '--';
    if (amount == 0) return '0 VNĐ';

    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M VNĐ';
    }
    return '${NumberFormat('#,###').format(amount.toInt())} VNĐ';
  }

  void _openDetail(RescueMissionListItem mission) {
    if (_completedStatuses.contains(mission.status) ||
        _abortedStatuses.contains(mission.status)) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              RescuerMissionHistoryDetailScreen(missionId: mission.id),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RescuerMissionDetailScreen(missionId: mission.id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF8800)),
          )
        : _errorMessage != null
        ? _buildError()
        : RefreshIndicator(
            color: const Color(0xFFFF8800),
            onRefresh: _loadHistory,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildTabsSection()),
                if (_filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmpty(),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, index) => _buildCard(_filtered[index]),
                      childCount: _filtered.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
  }

  Widget _buildTabsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final selected = _selectedTabIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = i),
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              padding: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: selected
                        ? const Color(0xFFFF8800)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                _tabs[i],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: selected
                      ? const Color(0xFF1D150C)
                      : const Color(0xFF999999),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCard(RescueMissionListItem mission) {
    final completed = _completedStatuses.contains(mission.status);
    final aborted = _abortedStatuses.contains(mission.status);

    return GestureDetector(
      onTap: () => _openDetail(mission),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${mission.id.length >= 8 ? mission.id.substring(0, 8).toUpperCase() : mission.id.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF999999),
                      fontFamily: 'monospace',
                    ),
                  ),
                  _statusBadge(mission.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 13,
                    color: Color(0xFF999999),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${_formatDate(mission.createdAt)}  ${_formatTime(mission.createdAt)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D150C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 13,
                    color: Color(0xFF999999),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      mission.incidentAddress,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(
                    Icons.attach_money,
                    size: 13,
                    color: Color(0xFF999999),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _formatCurrency(mission.actualCost ?? mission.price),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1D150C),
                    ),
                  ),
                  if (mission.distanceFromCenterKm != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${mission.distanceFromCenterKm!.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ],
              ),
              if (mission.notes != null && mission.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  mission.notes!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 38,
                child: ElevatedButton.icon(
                  onPressed: () => _openDetail(mission),
                  icon: const Icon(Icons.visibility, size: 15),
                  label: const Text(
                    'Xem Chi Tiết',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: completed
                        ? const Color(0xFF10B981)
                        : aborted
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF6B7280),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final completed = _completedStatuses.contains(status);
    final aborted = _abortedStatuses.contains(status);
    final bg = completed
        ? const Color(0xFF10B981).withOpacity(0.1)
        : aborted
        ? const Color(0xFFEF4444).withOpacity(0.1)
        : const Color(0xFFF59E0B).withOpacity(0.1);
    final fg = completed
        ? const Color(0xFF10B981)
        : aborted
        ? const Color(0xFFEF4444)
        : const Color(0xFFF59E0B);
    final label = completed
        ? 'HOÀN THÀNH'
        : aborted
        ? 'ĐÃ HỦY'
        : status.toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_toggle_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Chưa có lịch sử cứu hộ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Đã xảy ra lỗi',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF666666)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadHistory,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8800),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
