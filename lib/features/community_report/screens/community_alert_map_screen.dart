import 'dart:ui';
import 'package:flutter/material.dart';
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
    final results = await Future.wait([
      _tryGetLocation(),
      _fetchReports(),
    ]);
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
          perm == LocationPermission.deniedForever) return null;
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
      final list = await repo.getReports();
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
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CreateReportScreen(onReportCreated: _fetchReports),
    ));
  }

  void _openHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ReportHistoryScreen()),
    );
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
              if (_reports.isNotEmpty)
                MarkerLayer(
                  markers: _reports.map((r) {
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
                        color: Colors.black.withOpacity(0.45)),
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
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 20),
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
                                  fontWeight: FontWeight.bold),
                            ),
                            if (!_isLoading && _error == null)
                              Row(children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _reports.isEmpty
                                        ? Colors.white24
                                        : const Color(0xFFDC3545),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${_reports.length} điểm cảnh báo',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ]),
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
              child: _ErrorBanner(
                message: _error!,
                onRetry: _loadData,
              ),
            ),

          // ── Right FABs: recenter + report ───────────────────────────────
          Positioned(
            bottom: 110,
            right: 14,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                          LatLng(pos.latitude, pos.longitude), 15);
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
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                    shadowColor: const Color(0xFFDC3545).withOpacity(0.4),
                  ),
                  icon: const Icon(Icons.add_location_alt,
                      size: 20),
                  label: const Text(
                    'Báo cáo phát hiện rắn',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
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
    final dateStr =
        DateFormat('dd/MM/yyyy • HH:mm').format(report.createdAt.toLocal());
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
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: color, size: 15),
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
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC3545).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFDC3545).withOpacity(0.5)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.dangerous,
                              color: Color(0xFFDC3545), size: 14),
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
                      color: Color(0xFF1A1A1A)),
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
                      value: report.reporterName ?? 'Ẩn danh'),
                  _InfoRow(
                      icon: Icons.notes_outlined,
                      label: 'Ghi chú',
                      value: report.notes.isNotEmpty
                          ? report.notes
                          : 'Không có ghi chú'),
                  _InfoRow(
                      icon: Icons.access_time_outlined,
                      label: 'Thời gian',
                      value: dateStr),
                  _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'Tọa độ',
                      value: '${report.latitude.toStringAsFixed(4)}°N, '
                          '${report.longitude.toStringAsFixed(4)}°E',
                      isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
                    Text(label,
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF999999),
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF1A1A1A))),
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
                        color: Colors.white, strokeWidth: 2),
                  )
                : Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 9.5)),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: Colors.white.withOpacity(0.4)),
                ),
                child: const Text('Thử lại',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
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
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const Text('Chú thích bản đồ',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ..._items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(item.label,
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
          const Divider(height: 24),
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Color(0xFF228B22), size: 18),
              SizedBox(width: 8),
              Text('Điểm đánh dấu cảnh báo rắn',
                  style: TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
