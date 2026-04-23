import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snakeaid_mobile/features/rescuer/models/rescuer_daily_stats.dart';
import 'package:snakeaid_mobile/features/rescuer/repository/rescuer_analytics_repository.dart';
import 'package:snakeaid_mobile/features/rescuer/screens/rescuer_catching_history_screen.dart';
import 'package:snakeaid_mobile/features/rescuer/screens/rescuer_mission_history_screen.dart';

enum RescuerHistoryViewMode { catchingRequest, rescueMission }

extension RescuerHistoryViewModeX on RescuerHistoryViewMode {
  String get label {
    switch (this) {
      case RescuerHistoryViewMode.catchingRequest:
        return 'Bắt rắn';
      case RescuerHistoryViewMode.rescueMission:
        return 'Cứu hộ';
    }
  }
}

class RescuerHistoryScreen extends ConsumerStatefulWidget {
  const RescuerHistoryScreen({super.key});

  @override
  ConsumerState<RescuerHistoryScreen> createState() =>
      _RescuerHistoryScreenState();
}

class _RescuerHistoryScreenState extends ConsumerState<RescuerHistoryScreen> {
  RescuerHistoryViewMode _selectedViewMode =
      RescuerHistoryViewMode.catchingRequest;
  String _selectedPeriod = 'month';
  bool _isAnalyticsLoading = false;
  RescuerDailyStats? _analyticsStats;

  final _catchingHistoryKey = GlobalKey<RescuerCatchingHistoryScreenState>();
  final _missionHistoryKey = GlobalKey<RescuerMissionHistoryScreenState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAnalytics());
  }

  void _switchViewMode(RescuerHistoryViewMode mode) {
    if (mode == _selectedViewMode) return;
    setState(() => _selectedViewMode = mode);
  }

  Future<void> _showViewModeSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(title: const Text('Chuyển danh sách'), dense: true),
              ListTile(
                title: const Text('Yêu cầu bắt rắn'),
                trailing:
                    _selectedViewMode == RescuerHistoryViewMode.catchingRequest
                    ? const Icon(Icons.check, color: Color(0xFFFF8800))
                    : null,
                onTap: () {
                  _switchViewMode(RescuerHistoryViewMode.catchingRequest);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Nhiệm vụ cứu hộ'),
                trailing:
                    _selectedViewMode == RescuerHistoryViewMode.rescueMission
                    ? const Icon(Icons.check, color: Color(0xFFFF8800))
                    : null,
                onTap: () {
                  _switchViewMode(RescuerHistoryViewMode.rescueMission);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadAnalytics() async {
    if (!mounted) return;
    setState(() => _isAnalyticsLoading = true);
    try {
      final repo = ref.read(rescuerAnalyticsRepositoryProvider);
      final stats = await repo.getStatistics(period: _selectedPeriod);
      if (!mounted) return;
      setState(() {
        _analyticsStats = stats;
        _isAnalyticsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isAnalyticsLoading = false);
    }
  }

  void _refreshCurrentView() {
    if (_selectedViewMode == RescuerHistoryViewMode.catchingRequest) {
      _catchingHistoryKey.currentState?.refresh();
    } else {
      _missionHistoryKey.currentState?.refresh();
    }
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

  @override
  Widget build(BuildContext context) {
    final child = _selectedViewMode == RescuerHistoryViewMode.catchingRequest
        ? RescuerCatchingHistoryScreen(key: _catchingHistoryKey)
        : RescuerMissionHistoryScreen(key: _missionHistoryKey);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F5),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1D150C)),
          onPressed: () => Navigator.of(context).pop(),
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
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              onTap: _showViewModeSheet,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E5E5)),
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedViewMode.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D150C),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF1D150C),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1D150C)),
            onPressed: _refreshCurrentView,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPeriodSelector(),
          _buildStatsSection(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
