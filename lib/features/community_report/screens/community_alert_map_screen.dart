import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/community_report.dart';
import '../repository/community_report_repository.dart';
import '../widgets/snake_warning_marker.dart';
import 'create_report_screen.dart';
import 'report_history_screen.dart';

class CommunityAlertMapScreen extends ConsumerStatefulWidget {
  const CommunityAlertMapScreen({super.key});

  @override
  ConsumerState<CommunityAlertMapScreen> createState() =>
      _CommunityAlertMapScreenState();
}

class _CommunityAlertMapScreenState
    extends ConsumerState<CommunityAlertMapScreen> {
  static const _defaultCenter = LatLng(16.047, 108.206); // Đà Nẵng
  static const _defaultZoom = 12.0;

  final MapController _mapController = MapController();
  LatLng _center = _defaultCenter;
  List<CommunityReport> _reports = [];
  bool _isLoading = true;
  String? _error;
  _VietnamProvince? _selectedProvince;
  String _riskFilter = 'All';

  List<CommunityReport> get _filteredReports {
    if (_riskFilter == 'All') return _reports;
    if (_riskFilter == 'Danger') {
      return _reports
          .where(
            (r) =>
                r.resolvedRiskLevel == 'Critical' ||
                r.resolvedRiskLevel == 'Extreme',
          )
          .toList();
    }
    return _reports.where((r) => r.resolvedRiskLevel == _riskFilter).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    // Fetch location and reports concurrently
    final results = await Future.wait([_tryGetLocation(), _fetchReports()]);
    final position = results[0] as Position?;
    if (position != null && mounted) {
      setState(() => _center = LatLng(position.latitude, position.longitude));
      _mapController.move(_center, _defaultZoom);
    }
  }

  Future<Position?> _tryGetLocation() async {
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever)
        return null;
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 6),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<Null> _fetchReports() async {
    try {
      final repo = ref.read(communityReportRepositoryProvider);
      final list = await repo.getAllReports();
      if (!mounted) return;
      setState(() {
        _reports = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
    return null;
  }

  void _showReportDetail(CommunityReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReportDetailSheet(report: report),
    );
  }

  Future<void> _openCreateReport() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateReportScreen(onReportCreated: _fetchReports),
      ),
    );
  }

  void _openHistory() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ReportHistoryScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Full-screen map ─────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: _defaultZoom,
              minZoom: 5.0,
              maxZoom: 18.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.snakeaid.mobile',
                maxZoom: 19,
              ),
              if (_filteredReports.isNotEmpty)
                MarkerLayer(
                  markers: _filteredReports.map((r) {
                    return Marker(
                      point: LatLng(r.latitude, r.longitude),
                      width: 50,
                      height: 50,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () => _showReportDetail(r),
                        child: SnakeWarningMarker(
                          riskLevel: r.resolvedRiskLevel,
                          isVenomous: r.isVenomous,
                          imageUrl: r.snakeSpecies?.imageUrl,
                          size: 48,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6, bottom: 6),
                  child: Text(
                    '© OpenStreetMap contributors',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.black.withOpacity(0.45),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Frosted top bar ─────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: EdgeInsets.only(
                    top: topPad + 8,
                    bottom: 10,
                    left: 4,
                    right: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20).withOpacity(0.82),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Cảnh báo khu vực',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (!_isLoading && _error == null)
                              Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _reports.isEmpty
                                          ? Colors.white24
                                          : const Color(0xFFDC3545),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _riskFilter == 'All'
                                          ? '${_reports.length} điểm cảnh báo'
                                          : '${_filteredReports.length}/${_reports.length} điểm hiển thị',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (_riskFilter != 'All') ...[
                                    const SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: () =>
                                          setState(() => _riskFilter = 'All'),
                                      child: Container(
                                        margin: const EdgeInsets.only(top: 2),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.22),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.filter_list_off_rounded,
                                              color: Colors.white,
                                              size: 10,
                                            ),
                                            SizedBox(width: 3),
                                            Text(
                                              'Xóa lọc',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                          ],
                        ),
                      ),
                      _TopBarBtn(
                        icon: Icons.history_outlined,
                        label: 'Của tôi',
                        onTap: _openHistory,
                      ),
                      const SizedBox(width: 4),
                      _TopBarBtn(
                        icon: Icons.refresh_rounded,
                        label: 'Làm mới',
                        onTap: _loadData,
                        spinning: _isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Loading shimmer ─────────────────────────────────────────────
          if (_isLoading)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(color: Colors.black.withOpacity(0.08)),
              ),
            ),

          // ── Error pill ──────────────────────────────────────────────────
          if (_error != null)
            Positioned(
              top: topPad + 70,
              left: 16,
              right: 16,
              child: _ErrorBanner(message: _error!, onRetry: _loadData),
            ),

          // ── Province selected chip ─────────────────────────────────────
          if (_selectedProvince != null && _error == null)
            Positioned(
              top: topPad + 72,
              left: 0,
              right: 0,
              child: IgnorePointer(
                ignoring: false,
                child: Center(
                  child: GestureDetector(
                    onTap: _showProvincePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.22),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_city_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _selectedProvince!.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() => _selectedProvince = null);
                              _mapController.move(
                                const LatLng(16.5, 106.0),
                                5.5,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Risk filter chips ──────────────────────────────────────────────
          if (!_isLoading && _reports.isNotEmpty)
            Positioned(
              top: topPad + 70 + (_selectedProvince != null ? 42 : 0),
              left: 0,
              right: 0,
              child: _RiskFilterBar(
                reports: _reports,
                selected: _riskFilter,
                onChanged: (v) => setState(() => _riskFilter = v),
              ),
            ),

          // ── Stats summary (bottom-left) ──────────────────────────────────
          if (!_isLoading && _reports.isNotEmpty)
            Positioned(
              bottom: 92,
              left: 14,
              child: _MapStatsBar(reports: _reports),
            ),

          // ── Right FABs: recenter + report ───────────────────────────────
          Positioned(
            bottom: 110,
            right: 14,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Province picker
                _MapFab(
                  icon: Icons.explore_outlined,
                  tooltip: 'Chọn tỉnh',
                  color: Colors.white,
                  iconColor: const Color(0xFF1B5E20),
                  onTap: _showProvincePicker,
                ),
                const SizedBox(height: 10),
                // Recenter
                _MapFab(
                  icon: Icons.my_location_rounded,
                  tooltip: 'Về vị trí của tôi',
                  color: Colors.white,
                  iconColor: const Color(0xFF1B5E20),
                  onTap: () async {
                    final pos = await _tryGetLocation();
                    if (pos != null) {
                      _mapController.move(
                        LatLng(pos.latitude, pos.longitude),
                        15,
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                // Legend toggle (small info button)
                _MapFab(
                  icon: Icons.info_outline_rounded,
                  tooltip: 'Chú thích',
                  color: Colors.white,
                  iconColor: const Color(0xFF555555),
                  onTap: () => _showLegend(context),
                ),
              ],
            ),
          ),

          // ── Report FAB ──────────────────────────────────────────────────
          Positioned(
            bottom: 28,
            left: 16,
            right: 16,
            child: SafeArea(
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openCreateReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC3545),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    shadowColor: const Color(0xFFDC3545).withOpacity(0.4),
                  ),
                  icon: const Icon(Icons.add_location_alt, size: 20),
                  label: const Text(
                    'Báo cáo phát hiện rắn',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProvincePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProvincePickerSheet(
        selected: _selectedProvince,
        onSelected: (province) {
          setState(() => _selectedProvince = province);
          if (province != null) {
            _mapController.move(LatLng(province.lat, province.lng), 11.0);
          } else {
            _mapController.move(const LatLng(16.5, 106.0), 5.5);
          }
        },
      ),
    );
  }

  void _showLegend(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LegendSheet(),
    );
  }
}

// ── Report detail bottom sheet ───────────────────────────────────────────────

class _ReportDetailSheet extends StatelessWidget {
  final CommunityReport report;

  const _ReportDetailSheet({required this.report});

  static Color riskColor(String level) {
    switch (level) {
      case 'Critical':
      case 'Extreme':
        return const Color(0xFFDC3545);
      case 'High':
        return const Color(0xFFF5A623);
      case 'Medium':
        return const Color(0xFFFFD700);
      default:
        return const Color(0xFF28A745);
    }
  }

  static String riskLabel(String level) {
    switch (level) {
      case 'Critical':
      case 'Extreme':
        return 'Cực kỳ nguy hiểm';
      case 'High':
        return 'Nguy hiểm cao';
      case 'Medium':
        return 'Trung bình';
      case 'Low':
        return 'Thấp';
      default:
        return level;
    }
  }

  @override
  Widget build(BuildContext context) {
    final level = report.resolvedRiskLevel;
    final color = riskColor(level);
    final dateStr = DateFormat(
      'dd/MM/yyyy • HH:mm',
    ).format(report.createdAt.toLocal());
    final species = report.snakeSpecies;

    return DraggableScrollableSheet(
      initialChildSize: 0.52,
      maxChildSize: 0.92,
      minChildSize: 0.32,
      builder: (_, scroll) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scroll,
          padding: EdgeInsets.zero,
          children: [
            // ── Handle ────────────────────────────────────────────────────
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Species photo header ───────────────────────────────────────
            if (species?.imageUrl != null)
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: species!.imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                  // gradient scrim
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Species name overlay
                  Positioned(
                    bottom: 10,
                    left: 14,
                    right: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          species.commonName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (species.scientificName != null)
                          Text(
                            species.scientificName!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

            // ── Risk / venomous badges ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                children: [
                  // Risk badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: color,
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          riskLabel(level),
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Venomous badge
                  if (report.isVenomous)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC3545).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFDC3545).withOpacity(0.5),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.dangerous,
                            color: Color(0xFFDC3545),
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Có nọc độc',
                            style: TextStyle(
                              color: Color(0xFFDC3545),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // ── Snake display name (if no photo) ──────────────────────────
            if (species?.imageUrl == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                child: Text(
                  report.snakeDisplayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),

            const SizedBox(height: 14),

            // ── Info rows ─────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7F5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Người báo cáo',
                    value: report.reporterName ?? 'Ẩn danh',
                  ),
                  _InfoRow(
                    icon: Icons.notes_outlined,
                    label: 'Ghi chú',
                    value: report.notes.isNotEmpty
                        ? report.notes
                        : 'Không có ghi chú',
                  ),
                  _InfoRow(
                    icon: Icons.access_time_outlined,
                    label: 'Thời gian',
                    value: dateStr,
                  ),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Tọa độ',
                    value:
                        '${report.latitude.toStringAsFixed(4)}°N, '
                        '${report.longitude.toStringAsFixed(4)}°E',
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Action buttons ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final coords =
                            '${report.latitude.toStringAsFixed(5)}, ${report.longitude.toStringAsFixed(5)}';
                        Clipboard.setData(ClipboardData(text: coords));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Tọa độ đã sao chép: $coords'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_all_rounded, size: 15),
                      label: const Text('Sao chép tọa độ'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1B5E20),
                        side: const BorderSide(
                          color: Color(0xFF1B5E20),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, size: 15),
                      label: const Text('Đóng'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: const Color(0xFF1B5E20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF999999),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 44, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}

// ── Top bar icon button ──────────────────────────────────────────────────────

class _TopBarBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool spinning;

  const _TopBarBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.spinning = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            spinning
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 9.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Map floating action button ───────────────────────────────────────────────

class _MapFab extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _MapFab({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(14),
        elevation: 4,
        shadowColor: Colors.black26,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ),
      ),
    );
  }
}

// ── Error banner ─────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFDC3545),
      borderRadius: BorderRadius.circular(14),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onRetry,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                ),
                child: const Text(
                  'Thử lại',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Legend sheet ─────────────────────────────────────────────────────────────

class _LegendSheet extends StatelessWidget {
  const _LegendSheet();

  static const _items = [
    (label: 'Cực kỳ nguy hiểm', color: Color(0xFFB71C1C), icon: '⚠️'),
    (label: 'Nguy hiểm cao', color: Color(0xFFE53935), icon: '🔴'),
    (label: 'Nguy hiểm trung bình', color: Color(0xFFF5A623), icon: '🟠'),
    (label: 'Nguy hiểm thấp', color: Color(0xFF28A745), icon: '🟢'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F7F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.map_outlined,
                  color: Color(0xFF1B5E20),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Âm hiu bản đồ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.6,
            children: const [
              _LegendCard(
                color: Color(0xFFB71C1C),
                label: 'Cực kỳ nguy hiểm',
                icon: Icons.crisis_alert_rounded,
              ),
              _LegendCard(
                color: Color(0xFFE53935),
                label: 'Nguy hiểm cao',
                icon: Icons.warning_amber_rounded,
              ),
              _LegendCard(
                color: Color(0xFFF5A623),
                label: 'Trung bình',
                icon: Icons.report_outlined,
              ),
              _LegendCard(
                color: Color(0xFF28A745),
                label: 'Nguy hiểm thấp',
                icon: Icons.info_outline_rounded,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20).withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  color: Color(0xFF1B5E20),
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Nhấn vào điểm đánh dấu trên bản đồ để xem chi tiết báo cáo',
                    style: TextStyle(fontSize: 12, color: Color(0xFF444444)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Vietnam province data ────────────────────────────────────────────────────

enum _VnRegion { north, central, south }

class _VietnamProvince {
  final String name;
  final double lat;
  final double lng;
  final _VnRegion region;

  const _VietnamProvince({
    required this.name,
    required this.lat,
    required this.lng,
    required this.region,
  });
}

const _vnProvinces = <_VietnamProvince>[
  // ── Miền Bắc ──────────────────────────────────────────────────────────────
  _VietnamProvince(
    name: 'Hà Nội',
    lat: 21.028,
    lng: 105.854,
    region: _VnRegion.north,
  ),
  _VietnamProvince(
    name: 'Hải Phòng',
    lat: 20.844,
    lng: 106.688,
    region: _VnRegion.north,
  ),
  _VietnamProvince(
    name: 'Quảng Ninh',
    lat: 21.006,
    lng: 107.292,
    region: _VnRegion.north,
  ),
  _VietnamProvince(
    name: 'Hà Giang',
    lat: 22.823,
    lng: 104.983,
    region: _VnRegion.north,
  ),
  _VietnamProvince(
    name: 'Cao Bằng',
    lat: 22.672,
    lng: 106.254,
    region: _VnRegion.north,
  ),
  _VietnamProvince(
    name: 'Lào Cai',
    lat: 22.485,
    lng: 103.976,
    region: _VnRegion.north,
  ),
  _VietnamProvince(
    name: 'Bắc Kạn',
    lat: 22.147,
    lng: 105.834,
    region: _VnRegion.north,
  ),
  _VietnamProvince(
    name: 'Lạng Sơn',
    lat: 21.853,
    lng: 106.761,
    region: _VnRegion.north,
  ),
  _VietnamProvince(
    name: 'Tuyên Quang',
    lat: 21.823,
    lng: 105.214,
    region: _VnRegion.north,
  ),
  _VietnamProvince(
    name: 'Yên Bái',
    lat: 21.720,
    lng: 104.911,
    region: _VnRegion.north,
  ),
  _VietnamProvince(
    name: 'Thái Nguyên',
    lat: 21.594,
    lng: 105.848,
    region: _VnRegion.north,
  ),
  _VietnamProvince(
    name: 'Phú Thọ',
    lat: 21.322,
    lng: 105.201,
    region: _VnRegion.north,
  ),
  _VietnamProvince(
    name: 'Vĩnh Phúc',
    lat: 21.360,
    lng: 105.597,
    region: _VnRegion.north,
  ),
  _VietnamProvince(
    name: 'Bắc Giang',
    lat: 21.282,
    lng: 106.197,
    region: _VnRegion.north,
  ),
  _VietnamProvince(
    name: 'Bắc Ninh',
    lat: 21.186,
    lng: 106.076,
    region: _VnRegion.north,
  ),
  _VietnamProvince(
    name: 'Hưng Yên',
    lat: 20.645,
    lng: 106.051,
    region: _VnRegion.north,
  ),
  _VietnamProvince(
    name: 'Hải Dương',
    lat: 20.940,
    lng: 106.331,
    region: _VnRegion.north,
  ),
  _VietnamProvince(
    name: 'Hà Nam',
    lat: 20.545,
    lng: 105.922,
    region: _VnRegion.north,
  ),
  _VietnamProvince(
    name: 'Nam Định',
    lat: 20.420,
    lng: 106.168,
    region: _VnRegion.north,
  ),
  _VietnamProvince(
    name: 'Thái Bình',
    lat: 20.446,
    lng: 106.342,
    region: _VnRegion.north,
  ),
  _VietnamProvince(
    name: 'Ninh Bình',
    lat: 20.254,
    lng: 105.975,
    region: _VnRegion.north,
  ),
  _VietnamProvince(
    name: 'Hòa Bình',
    lat: 20.813,
    lng: 105.338,
    region: _VnRegion.north,
  ),
  _VietnamProvince(
    name: 'Sơn La',
    lat: 21.326,
    lng: 103.919,
    region: _VnRegion.north,
  ),
  _VietnamProvince(
    name: 'Điện Biên',
    lat: 21.386,
    lng: 103.013,
    region: _VnRegion.north,
  ),
  _VietnamProvince(
    name: 'Lai Châu',
    lat: 22.386,
    lng: 103.472,
    region: _VnRegion.north,
  ),
  // ── Miền Trung ────────────────────────────────────────────────────────────
  _VietnamProvince(
    name: 'Thanh Hóa',
    lat: 19.807,
    lng: 105.776,
    region: _VnRegion.central,
  ),
  _VietnamProvince(
    name: 'Nghệ An',
    lat: 18.666,
    lng: 105.681,
    region: _VnRegion.central,
  ),
  _VietnamProvince(
    name: 'Hà Tĩnh',
    lat: 18.355,
    lng: 105.887,
    region: _VnRegion.central,
  ),
  _VietnamProvince(
    name: 'Quảng Bình',
    lat: 17.467,
    lng: 106.622,
    region: _VnRegion.central,
  ),
  _VietnamProvince(
    name: 'Quảng Trị',
    lat: 16.746,
    lng: 107.185,
    region: _VnRegion.central,
  ),
  _VietnamProvince(
    name: 'Thừa Thiên Huế',
    lat: 16.462,
    lng: 107.590,
    region: _VnRegion.central,
  ),
  _VietnamProvince(
    name: 'Đà Nẵng',
    lat: 16.047,
    lng: 108.206,
    region: _VnRegion.central,
  ),
  _VietnamProvince(
    name: 'Quảng Nam',
    lat: 15.540,
    lng: 108.019,
    region: _VnRegion.central,
  ),
  _VietnamProvince(
    name: 'Quảng Ngãi',
    lat: 15.120,
    lng: 108.792,
    region: _VnRegion.central,
  ),
  _VietnamProvince(
    name: 'Bình Định',
    lat: 13.782,
    lng: 109.219,
    region: _VnRegion.central,
  ),
  _VietnamProvince(
    name: 'Phú Yên',
    lat: 13.088,
    lng: 109.093,
    region: _VnRegion.central,
  ),
  _VietnamProvince(
    name: 'Khánh Hòa',
    lat: 12.238,
    lng: 109.090,
    region: _VnRegion.central,
  ),
  _VietnamProvince(
    name: 'Ninh Thuận',
    lat: 11.565,
    lng: 108.988,
    region: _VnRegion.central,
  ),
  _VietnamProvince(
    name: 'Bình Thuận',
    lat: 11.090,
    lng: 108.072,
    region: _VnRegion.central,
  ),
  _VietnamProvince(
    name: 'Kon Tum',
    lat: 14.349,
    lng: 107.969,
    region: _VnRegion.central,
  ),
  _VietnamProvince(
    name: 'Gia Lai',
    lat: 13.983,
    lng: 108.237,
    region: _VnRegion.central,
  ),
  _VietnamProvince(
    name: 'Đắk Lắk',
    lat: 12.710,
    lng: 108.237,
    region: _VnRegion.central,
  ),
  _VietnamProvince(
    name: 'Đắk Nông',
    lat: 12.264,
    lng: 107.609,
    region: _VnRegion.central,
  ),
  _VietnamProvince(
    name: 'Lâm Đồng',
    lat: 11.575,
    lng: 108.145,
    region: _VnRegion.central,
  ),
  // ── Miền Nam ──────────────────────────────────────────────────────────────
  _VietnamProvince(
    name: 'TP. Hồ Chí Minh',
    lat: 10.762,
    lng: 106.660,
    region: _VnRegion.south,
  ),
  _VietnamProvince(
    name: 'Bình Phước',
    lat: 11.752,
    lng: 106.723,
    region: _VnRegion.south,
  ),
  _VietnamProvince(
    name: 'Tây Ninh',
    lat: 11.310,
    lng: 106.098,
    region: _VnRegion.south,
  ),
  _VietnamProvince(
    name: 'Bình Dương',
    lat: 10.980,
    lng: 106.652,
    region: _VnRegion.south,
  ),
  _VietnamProvince(
    name: 'Đồng Nai',
    lat: 10.945,
    lng: 107.241,
    region: _VnRegion.south,
  ),
  _VietnamProvince(
    name: 'Bà Rịa - Vũng Tàu',
    lat: 10.582,
    lng: 107.241,
    region: _VnRegion.south,
  ),
  _VietnamProvince(
    name: 'Long An',
    lat: 10.694,
    lng: 106.241,
    region: _VnRegion.south,
  ),
  _VietnamProvince(
    name: 'Tiền Giang',
    lat: 10.449,
    lng: 106.342,
    region: _VnRegion.south,
  ),
  _VietnamProvince(
    name: 'Bến Tre',
    lat: 10.241,
    lng: 106.376,
    region: _VnRegion.south,
  ),
  _VietnamProvince(
    name: 'Trà Vinh',
    lat: 9.934,
    lng: 106.345,
    region: _VnRegion.south,
  ),
  _VietnamProvince(
    name: 'Vĩnh Long',
    lat: 10.240,
    lng: 105.972,
    region: _VnRegion.south,
  ),
  _VietnamProvince(
    name: 'Đồng Tháp',
    lat: 10.493,
    lng: 105.688,
    region: _VnRegion.south,
  ),
  _VietnamProvince(
    name: 'An Giang',
    lat: 10.380,
    lng: 105.435,
    region: _VnRegion.south,
  ),
  _VietnamProvince(
    name: 'Kiên Giang',
    lat: 10.012,
    lng: 105.080,
    region: _VnRegion.south,
  ),
  _VietnamProvince(
    name: 'Cần Thơ',
    lat: 10.046,
    lng: 105.748,
    region: _VnRegion.south,
  ),
  _VietnamProvince(
    name: 'Hậu Giang',
    lat: 9.757,
    lng: 105.641,
    region: _VnRegion.south,
  ),
  _VietnamProvince(
    name: 'Sóc Trăng',
    lat: 9.602,
    lng: 105.974,
    region: _VnRegion.south,
  ),
  _VietnamProvince(
    name: 'Bạc Liêu',
    lat: 9.294,
    lng: 105.727,
    region: _VnRegion.south,
  ),
  _VietnamProvince(
    name: 'Cà Mau',
    lat: 9.177,
    lng: 105.150,
    region: _VnRegion.south,
  ),
];

// ── Province picker sheet ────────────────────────────────────────────────────

class _ProvincePickerSheet extends StatefulWidget {
  final _VietnamProvince? selected;
  final ValueChanged<_VietnamProvince?> onSelected;

  const _ProvincePickerSheet({
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_ProvincePickerSheet> createState() => _ProvincePickerSheetState();
}

class _ProvincePickerSheetState extends State<_ProvincePickerSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_VietnamProvince> get _filtered {
    if (_query.isEmpty) return _vnProvinces;
    final q = _query.toLowerCase();
    return _vnProvinces.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final north = filtered.where((p) => p.region == _VnRegion.north).toList();
    final central = filtered
        .where((p) => p.region == _VnRegion.central)
        .toList();
    final south = filtered.where((p) => p.region == _VnRegion.south).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scroll) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ── Handle ────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // ── Header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.explore_outlined,
                      color: Color(0xFF1B5E20),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chọn tỉnh / thành phố',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Di chuyển bản đồ đến khu vực bạn muốn xem',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ── Search bar ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Tìm tỉnh, thành phố...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF1B5E20),
                    size: 20,
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            // ── Province list ─────────────────────────────────────────
            Expanded(
              child: ListView(
                controller: scroll,
                children: [
                  // Toàn quốc
                  _ProvinceItem(
                    name: 'Toàn quốc',
                    subtitle: 'Xem tất cả các tỉnh thành',
                    icon: Icons.public_rounded,
                    isSelected: widget.selected == null,
                    isAllVietnam: true,
                    onTap: () {
                      widget.onSelected(null);
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(height: 1, indent: 16),
                  if (north.isNotEmpty) ...[
                    _RegionHeader(
                      label: 'Miền Bắc',
                      color: const Color(0xFF1565C0),
                    ),
                    ...north.map(
                      (p) => _ProvinceItem(
                        name: p.name,
                        isSelected: widget.selected?.name == p.name,
                        onTap: () {
                          widget.onSelected(p);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                  if (central.isNotEmpty) ...[
                    _RegionHeader(
                      label: 'Miền Trung',
                      color: const Color(0xFF2E7D32),
                    ),
                    ...central.map(
                      (p) => _ProvinceItem(
                        name: p.name,
                        isSelected: widget.selected?.name == p.name,
                        onTap: () {
                          widget.onSelected(p);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                  if (south.isNotEmpty) ...[
                    _RegionHeader(
                      label: 'Miền Nam',
                      color: const Color(0xFFE65100),
                    ),
                    ...south.map(
                      (p) => _ProvinceItem(
                        name: p.name,
                        isSelected: widget.selected?.name == p.name,
                        onTap: () {
                          widget.onSelected(p);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionHeader extends StatelessWidget {
  final String label;
  final Color color;

  const _RegionHeader({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 11, 16, 6),
      color: color.withOpacity(0.06),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProvinceItem extends StatelessWidget {
  final String name;
  final String? subtitle;
  final IconData? icon;
  final bool isSelected;
  final bool isAllVietnam;
  final VoidCallback onTap;

  const _ProvinceItem({
    required this.name,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
    this.icon,
    this.isAllVietnam = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: isSelected
            ? const Color(0xFF1B5E20).withOpacity(0.07)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isAllVietnam
                      ? const Color(0xFF1B5E20).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon!, size: 18, color: const Color(0xFF1B5E20)),
              ),
              const SizedBox(width: 12),
            ] else ...[
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(left: 5, right: 19),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1B5E20)
                      : const Color(0xFFCCCCCC),
                  shape: BoxShape.circle,
                ),
              ),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? const Color(0xFF1B5E20)
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF1B5E20),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Legend card ──────────────────────────────────────────────────────────────

class _LegendCard extends StatelessWidget {
  final Color color;
  final String label;
  final IconData icon;

  const _LegendCard({
    required this.color,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Risk filter bar ───────────────────────────────────────────────────────────

class _RiskFilterBar extends StatelessWidget {
  final List<CommunityReport> reports;
  final String selected;
  final ValueChanged<String> onChanged;

  const _RiskFilterBar({
    required this.reports,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dangerCount = reports
        .where(
          (r) =>
              r.resolvedRiskLevel == 'Critical' ||
              r.resolvedRiskLevel == 'Extreme',
        )
        .length;
    final highCount = reports
        .where((r) => r.resolvedRiskLevel == 'High')
        .length;
    final medCount = reports
        .where((r) => r.resolvedRiskLevel == 'Medium')
        .length;
    final lowCount = reports.where((r) => r.resolvedRiskLevel == 'Low').length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Row(
        children: [
          _FilterChipBtn(
            label: 'Tất cả',
            count: reports.length,
            color: const Color(0xFF1B5E20),
            active: selected == 'All',
            onTap: () => onChanged('All'),
          ),
          const SizedBox(width: 6),
          _FilterChipBtn(
            label: '🔴 Cực kỳ',
            count: dangerCount,
            color: const Color(0xFFB71C1C),
            active: selected == 'Danger',
            onTap: () => onChanged('Danger'),
          ),
          const SizedBox(width: 6),
          _FilterChipBtn(
            label: '🟠 Cao',
            count: highCount,
            color: const Color(0xFFF5A623),
            active: selected == 'High',
            onTap: () => onChanged('High'),
          ),
          const SizedBox(width: 6),
          _FilterChipBtn(
            label: '🟡 Trung bình',
            count: medCount,
            color: const Color(0xFFE6A817),
            active: selected == 'Medium',
            onTap: () => onChanged('Medium'),
          ),
          const SizedBox(width: 6),
          _FilterChipBtn(
            label: '🟢 Thấp',
            count: lowCount,
            color: const Color(0xFF28A745),
            active: selected == 'Low',
            onTap: () => onChanged('Low'),
          ),
        ],
      ),
    );
  }
}

class _FilterChipBtn extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const _FilterChipBtn({
    required this.label,
    required this.count,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? color : Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: (active ? color : Colors.black).withOpacity(0.20),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : const Color(0xFF333333),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: active
                    ? Colors.white.withOpacity(0.25)
                    : color.withOpacity(0.13),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: active ? Colors.white : color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Map stats bar ─────────────────────────────────────────────────────────────

class _MapStatsBar extends StatelessWidget {
  final List<CommunityReport> reports;

  const _MapStatsBar({required this.reports});

  @override
  Widget build(BuildContext context) {
    final danger = reports
        .where(
          (r) =>
              r.resolvedRiskLevel == 'Critical' ||
              r.resolvedRiskLevel == 'Extreme',
        )
        .length;
    final high = reports.where((r) => r.resolvedRiskLevel == 'High').length;
    final safe = reports
        .where(
          (r) =>
              r.resolvedRiskLevel == 'Medium' || r.resolvedRiskLevel == 'Low',
        )
        .length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StatPill(
                color: const Color(0xFFDC3545),
                count: danger,
                label: 'Cực kỳ',
              ),
              const SizedBox(width: 10),
              _StatPill(
                color: const Color(0xFFF5A623),
                count: high,
                label: 'Cao',
              ),
              const SizedBox(width: 10),
              _StatPill(
                color: const Color(0xFF28A745),
                count: safe,
                label: 'Thấp',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final Color color;
  final int count;
  final String label;

  const _StatPill({
    required this.color,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$count $label',
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF333333),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
