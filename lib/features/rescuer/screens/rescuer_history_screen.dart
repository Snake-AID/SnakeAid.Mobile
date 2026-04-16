import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../snake_catching/models/snake_catching_request.dart';
import '../../snake_catching/repository/snake_catching_repository.dart';
import '../../snake_catching/screens/rescuers/rescuer_mission_success_screen.dart';
import '../../snake_catching/screens/rescuers/rescuer_accept_request_screen.dart';
import '../repository/rescuer_analytics_repository.dart';
import '../models/rescuer_daily_stats.dart';

class RescuerHistoryScreen extends ConsumerStatefulWidget {
  const RescuerHistoryScreen({super.key});

  @override
  ConsumerState<RescuerHistoryScreen> createState() =>
      _RescuerHistoryScreenState();
}

class _RescuerHistoryScreenState extends ConsumerState<RescuerHistoryScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Tất cả', 'Hoàn thành', 'Đã hủy'];

  bool _isLoading = false;
  bool _isAnalyticsLoading = false;
  String? _errorMessage;
  List<SnakeCatchingRequestData> _allHistory = [];
  String? _currentRescuerId;

  String _selectedPeriod = 'month';
  RescuerDailyStats? _analyticsStats;

  static const _completedStatuses = {
    'Completed',
    'Paid',
    'Finished',
    'MissionCompleted',
  };

  List<SnakeCatchingRequestData> get _filtered {
    switch (_selectedTabIndex) {
      case 1:
        return _allHistory
            .where((r) => _completedStatuses.contains(r.status))
            .toList();
      case 2:
        return _allHistory.where((r) => r.status == 'Cancelled').toList();
      default:
        return _allHistory;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentRescuerId =
        prefs.getString('userId') ?? prefs.getString('rescuerId');
    await _loadHistory();
  }

  Future<void> _loadAnalytics() async {
    if (mounted) {
      setState(() => _isAnalyticsLoading = true);
    }
    try {
      final repo = ref.read(rescuerAnalyticsRepositoryProvider);
      final stats = await repo.getStatistics(period: _selectedPeriod);
      if (mounted) {
        setState(() {
          _analyticsStats = stats;
          _isAnalyticsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isAnalyticsLoading = false);
      }
    }
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _loadAnalytics();
      final repo = ref.read(snakeCatchingRepositoryProvider);
      final response = await repo.getRequests(
        assignedRescuerId: _currentRescuerId,
      );
      if (!mounted) return;
      if (response.isSuccess) {
        setState(() {
          _allHistory = response.data.where((r) {
            return _completedStatuses.contains(r.status) ||
                r.status == 'Cancelled';
          }).toList()..sort((a, b) => b.requestDate.compareTo(a.requestDate));
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

  String _formatDate(DateTime dt) => DateFormat('dd/MM/yyyy').format(dt);
  String _formatTime(DateTime dt) => DateFormat('HH:mm').format(dt);

  String _formatCurrency(double? amount) {
    if (amount == null) return '--';
    if (amount == 0) return '0 VNĐ';

    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M VNĐ';
    }
    return '${NumberFormat('#,###').format(amount.toInt())} VNĐ';
  }

  String _snakeLabel(SnakeCatchingRequestData r) {
    final mds = r.mission?.missionDetails ?? [];
    if (mds.isNotEmpty) {
      if (mds.length == 1) {
        return '${mds.first.snakeSpeciesName} ×${mds.first.quantity}';
      }
      return '${mds.first.snakeSpeciesName} +${mds.length - 1} loài';
    }
    final ds = r.details;
    if (ds.isNotEmpty) {
      if (ds.length == 1) {
        return '${ds.first.snakeSpeciesName} ×${ds.first.quantity}';
      }
      return '${ds.first.snakeSpeciesName} +${ds.length - 1} loài';
    }
    return 'Không rõ loài rắn';
  }

  bool _isCompleted(SnakeCatchingRequestData r) =>
      _completedStatuses.contains(r.status);

  void _openDetail(SnakeCatchingRequestData r) {
    final mission = r.mission;
    if (_isCompleted(r)) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RescuerMissionSuccessScreen(
            requestData: r,
            missionId: mission?.id ?? r.id,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RescuerAcceptRequestScreen(requestData: r),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: _buildAppBar(),
      body: _isLoading
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
                  SliverToBoxAdapter(child: _buildPeriodSelector()),
                  SliverToBoxAdapter(child: _buildStatsSection()),
                  SliverToBoxAdapter(child: _buildTabsSection()),
                  if (_filtered.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmpty(),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _buildCard(_filtered[i]),
                        childCount: _filtered.length,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F7F5),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1D150C)),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Lịch Sử Cứu Hộ',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1D150C),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Color(0xFF1D150C)),
          onPressed: _loadHistory,
          tooltip: 'Làm mới',
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    final periods = {'day': 'Hôm nay', 'month': 'Tháng này', 'year': 'Năm nay'};

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: periods.entries.map((entry) {
          final isSelected = _selectedPeriod == entry.key;
          return GestureDetector(
            onTap: () {
              if (!isSelected) {
                setState(() => _selectedPeriod = entry.key);
                _loadAnalytics();
              }
            },
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF8800) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF8800)
                      : const Color(0xFFE5E5E5),
                ),
              ),
              child: Text(
                entry.value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF666666),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            _statCell(
              _analyticsStats?.totalRequests.toString() ?? '-',
              'Tổng Đơn',
              const Color(0xFF1D150C),
            ),
            Container(width: 1, height: 60, color: const Color(0xFFE5E5E5)),
            _statCell(
              _analyticsStats?.totalCompleted.toString() ?? '-',
              'Hoàn thành',
              const Color(0xFF10B981),
            ),
            Container(width: 1, height: 60, color: const Color(0xFFE5E5E5)),
            _statCell(
              _analyticsStats?.snakebiteCompleted.toString() ?? '-',
              'Đơn rắn cắn',
              const Color(0xFF3B82F6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCell(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        color: Colors.white,
        child: _isAnalyticsLoading
            ? const SizedBox(
                height: 44,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFF8800),
                    ),
                  ),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTabsSection() {
    final labels = ['Tất cả', 'Hoàn thành', 'Đã hủy'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
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
                labels[i],
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

  Widget _buildCard(SnakeCatchingRequestData r) {
    final completed = _isCompleted(r);
    final cancelled = r.status == 'Cancelled';

    return GestureDetector(
      onTap: () => _openDetail(r),
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
                    '#${r.id.length >= 8 ? r.id.substring(0, 8).toUpperCase() : r.id.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF999999),
                      fontFamily: 'monospace',
                    ),
                  ),
                  _statusBadge(r.status),
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
                    '${_formatDate(r.requestDate)}  ${_formatTime(r.requestDate)}',
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
                      r.address,
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
                    Icons.pest_control,
                    size: 13,
                    color: Color(0xFF999999),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      _snakeLabel(r),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1D150C),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (r.distanceKm != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${r.distanceKm!.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ],
              ),
              if (cancelled && r.cancellationReason != null) ...[
                const SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 13,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Lý do: ${r.cancellationReason}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFEF4444),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 38,
                child: ElevatedButton.icon(
                  onPressed: () => _openDetail(r),
                  icon: const Icon(Icons.visibility, size: 15),
                  label: const Text(
                    'Xem Chi Tiết',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: completed
                        ? const Color(0xFF10B981)
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
    final cancelled = status == 'Cancelled';
    final bg = completed
        ? const Color(0xFF10B981).withOpacity(0.1)
        : cancelled
        ? const Color(0xFFEF4444).withOpacity(0.1)
        : const Color(0xFFF59E0B).withOpacity(0.1);
    final fg = completed
        ? const Color(0xFF10B981)
        : cancelled
        ? const Color(0xFFEF4444)
        : const Color(0xFFF59E0B);
    final label = completed
        ? 'HOÀN THÀNH'
        : cancelled
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
            'Chưa có lịch sử',
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
