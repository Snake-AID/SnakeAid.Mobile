import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/snake_catching_request.dart';
import '../../models/snake_species.dart';
import '../../repository/snake_catching_repository.dart';
import '../../repository/snake_species_repository.dart';
import 'rescuer_tracking_screen.dart';

/// Màn hình di chuyển đến khách hàng  bản đồ thực với OSRM routing
class RescuerEnRouteScreen extends ConsumerStatefulWidget {
  final SnakeCatchingRequestData requestData;
  final String missionId;

  const RescuerEnRouteScreen({
    super.key,
    required this.requestData,
    required this.missionId,
  });

  @override
  ConsumerState<RescuerEnRouteScreen> createState() => _RescuerEnRouteScreenState();
}

class _RescuerEnRouteScreenState extends ConsumerState<RescuerEnRouteScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  LatLng? _rescuerPos;
  List<LatLng> _routePoints = [];
  double? _routeDistanceM;
  double? _routeDurationS;
  double? _directDistanceM;

  bool _isLocating = true;
  bool _hasLocationError = false;
  bool _routeLoading = false;
  bool _isArriving = false;
  bool _isCancelling = false;

  final Map<int, SnakeSpecies> _speciesCache = {};
  bool _speciesLoading = false;

  StreamSubscription<Position>? _positionSub;
  Timer? _routeRefreshTimer;
  Timer? _statusRefreshTimer;
  bool _hasHandledCancellation = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  Future<void> _loadSpecies() async {
    final details = widget.requestData.details;
    if (details.isEmpty) return;
    if (mounted) setState(() => _speciesLoading = true);
    try {
      final repo = ref.read(snakeSpeciesRepositoryProvider);
      for (final d in details) {
        if (!_speciesCache.containsKey(d.snakeSpeciesId)) {
          final s = await repo.getSnakeSpeciesById(d.snakeSpeciesId);
          if (s != null && mounted) setState(() => _speciesCache[d.snakeSpeciesId] = s);
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _speciesLoading = false);
  }

  LatLng get _destination => LatLng(
        widget.requestData.locationCoordinates.latitude,
        widget.requestData.locationCoordinates.longitude,
      );

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _initLocation();
    _startStatusRefresh();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSpecies());
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _routeRefreshTimer?.cancel();
    _statusRefreshTimer?.cancel();
    _pulseController.dispose();
    _dio.close(force: true);
    super.dispose();
  }

  void _navigateBackToJobs() {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop(); // pop RescuerEnRouteScreen
      if (nav.canPop()) {
        nav.pop(); // pop RescuerAcceptRequestScreen if it's in the stack
      }
    }
  }

  Future<void> _initLocation() async {
    setState(() { _isLocating = true; _hasLocationError = false; });
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        if (mounted) setState(() { _hasLocationError = true; _isLocating = false; });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _onNewPosition(pos);

      _positionSub?.cancel();
      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 25),
      ).listen(_onNewPosition);

      _routeRefreshTimer = Timer.periodic(const Duration(seconds: 35), (_) {
        if (_rescuerPos != null && mounted) _fetchRoute(_rescuerPos!);
      });
    } catch (_) {
      if (mounted) setState(() { _hasLocationError = true; _isLocating = false; });
    }
  }

  void _onNewPosition(Position pos) {
    final ll = LatLng(pos.latitude, pos.longitude);
    final dist = Geolocator.distanceBetween(pos.latitude, pos.longitude, _destination.latitude, _destination.longitude);
    if (!mounted) return;
    setState(() { _rescuerPos = ll; _isLocating = false; _directDistanceM = dist; });
    _fetchRoute(ll);
    try {
      final z = _mapController.camera.zoom;
      _mapController.move(ll, z < 14 ? 15.0 : z);
    } catch (_) {}
  }

  Future<void> _fetchRoute(LatLng from) async {
    if (_routeLoading) return;
    if (mounted) setState(() => _routeLoading = true);
    try {
      final url =
          'https://router.project-osrm.org/route/v1/driving/'
          '${from.longitude},${from.latitude};'
          '${_destination.longitude},${_destination.latitude}'
          '?overview=full&geometries=geojson';

      final resp = await _dio.get(url);
      if (resp.statusCode == 200) {
        final routes = resp.data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final route = routes[0];
          final coords = (route['geometry']['coordinates'] as List)
              .map<LatLng>((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
              .toList();
          if (mounted) {
            setState(() {
              _routePoints = coords;
              _routeDistanceM = (route['distance'] as num).toDouble();
              _routeDurationS = (route['duration'] as num).toDouble();
            });
          }
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _routeLoading = false);
    }
  }

  bool get _canMarkArrived => _directDistanceM != null && _directDistanceM! <= 1000;

  String _fmtDist(double m) =>
      m >= 1000 ? '${(m / 1000).toStringAsFixed(1)} km' : '${m.toInt()} m';

  String _fmtDur(double s) {
    final min = (s / 60).round();
    if (min == 0) return '< 1 phút';
    if (min < 60) return '$min phút';
    return '${min ~/ 60} giờ ${min % 60} phút';
  }

  Future<void> _openExternalNav() async {
    final lat = _destination.latitude;
    final lng = _destination.longitude;
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _callCustomer() async {
    final phone = widget.requestData.user?.phoneNumber ?? '';
    if (phone.isNotEmpty) {
      final uri = Uri.parse('tel:$phone');
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    }
  }

  String? get _customerAvatarUrl => widget.requestData.user?.account?.avatarUrl;

  void _startStatusRefresh() {
    _statusRefreshTimer?.cancel();
    _refreshRequestStatus();
    _statusRefreshTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      _refreshRequestStatus();
    });
  }

  Future<void> _refreshRequestStatus() async {
    if (_hasHandledCancellation) return;
    try {
      final repo = ref.read(snakeCatchingRepositoryProvider);
      final response = await repo.getRequestById(widget.requestData.id);
      if (!mounted || response.data == null) return;

      final status = response.data!.status.toLowerCase();
      if ((status == 'cancelled' || status == 'canceled') && !_hasHandledCancellation) {
        _hasHandledCancellation = true;
        _positionSub?.cancel();
        _routeRefreshTimer?.cancel();
        _statusRefreshTimer?.cancel();
        _showRequestCancelledDialog(response.data!.cancellationReason);
      }
    } catch (_) {}
  }

  void _showRequestCancelledDialog(String? reason) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFDC3545).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cancel, color: Color(0xFFDC3545), size: 38),
            ),
            const SizedBox(height: 16),
            const Text(
              'Đơn đã bị hủy',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Khách hàng đã hủy đơn này. Bạn sẽ được đưa về danh sách công việc.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4),
            ),
            if (reason != null && reason.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lý do hủy:',
                      style: TextStyle(fontSize: 11, color: Color(0xFF999999)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reason,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF444444), fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              child: const Text(
                'Về Danh Sách Công Việc',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmArrived() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: StatefulBuilder(
              builder: (ctx2, setDialogState) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.place_rounded,
                        color: Color(0xFFFF6B35),
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Xác nhận đã đến nơi?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Chỉ xác nhận khi bạn đã đến đúng vị trí của khách hàng để tiếp tục xử lý đơn.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF666666),
                            side: const BorderSide(color: Color(0xFFE2E2E2)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Chưa đến',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isArriving
                              ? null
                              : () async {
                                  setDialogState(() {});
                                  setState(() => _isArriving = true);
                                  try {
                                    final repo = ref.read(snakeCatchingRepositoryProvider);
                                    await repo.arrivedMission(widget.missionId);
                                  } catch (e) {
                                    debugPrint('⚠️ arrivedMission error: $e');
                                  } finally {
                                    if (mounted) setState(() => _isArriving = false);
                                  }
                                  if (!mounted) return;
                                  Navigator.pop(ctx);
                                  _positionSub?.cancel();
                                  _routeRefreshTimer?.cancel();
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => RescuerTrackingScreen(
                                        requestData: widget.requestData,
                                        missionId: widget.missionId,
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isArriving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Đã đến nơi',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _navigateBackToJobs();
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildMap(),
            _buildHeader(),
            Positioned.fill(child: _buildBottomSheet()),
            if (_canMarkArrived) _buildArrivedButton(screenH),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    if (_isLocating && _rescuerPos == null) {
      return Container(
        color: const Color(0xFFF0F7F0),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFFFF6B35)),
              SizedBox(height: 16),
              Text('Đang lấy vị trí GPS', style: TextStyle(color: Color(0xFF666666), fontSize: 14)),
            ],
          ),
        ),
      );
    }

    if (_hasLocationError || _rescuerPos == null) {
      return Container(
        color: const Color(0xFFF0F7F0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, size: 52, color: Color(0xFFFF6B35)),
              const SizedBox(height: 12),
              const Text('Không thể lấy vị trí GPS', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Vui lòng bật GPS và cấp quyền vị trí', style: TextStyle(color: Color(0xFF666666), fontSize: 13)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _initLocation,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35), foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _rescuerPos!,
        initialZoom: 15.0,
        minZoom: 8.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.snakeaid.mobile',
          maxZoom: 18,
        ),
        if (_routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(points: _routePoints, strokeWidth: 9, color: Colors.white.withOpacity(0.8)),
              Polyline(points: _routePoints, strokeWidth: 5.5, color: const Color(0xFFFF6B35)),
            ],
          ),
        MarkerLayer(
          markers: [
            Marker(
              point: _rescuerPos!,
              width: 56,
              height: 56,
              child: AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, __) => Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 56 * _pulseAnim.value,
                      height: 56 * _pulseAnim.value,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withOpacity(0.18 * _pulseAnim.value),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [BoxShadow(color: const Color(0xFF2196F3).withOpacity(0.55), blurRadius: 8)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Marker(
              point: _destination,
              width: 50,
              height: 60,
              alignment: Alignment.topCenter,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: Color(0xFFDC3545), size: 50,
                      shadows: [Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 6)]),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12)],
                ),
                child: Row(
                  children: [
                    _mapBtn(Icons.arrow_back_ios_new, const Color(0xFF555555), const Color(0xFFF5F5F5),
                        _navigateBackToJobs),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ĐANG DI CHUYỂN',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35), letterSpacing: 0.8)),
                          Text(widget.requestData.address,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_routeLoading)
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF6B35))),
                    const SizedBox(width: 6),
                    _mapBtn(Icons.my_location, const Color(0xFF2196F3), const Color(0xFFEFF6FF), () {
                      if (_rescuerPos != null) _mapController.move(_rescuerPos!, 15.0);
                    }),
                    const SizedBox(width: 6),
                    _mapBtn(Icons.navigation, Colors.white, const Color(0xFF2196F3), _openExternalNav),
                  ],
                ),
              ),
              if (_routeDistanceM != null) ...[
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: const Color(0xFFFF6B35).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule, color: Colors.white, size: 15),
                        const SizedBox(width: 5),
                        Text(_fmtDur(_routeDurationS!), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        Container(margin: const EdgeInsets.symmetric(horizontal: 10), width: 1, height: 13, color: Colors.white38),
                        const Icon(Icons.straighten, color: Colors.white, size: 15),
                        const SizedBox(width: 5),
                        Text(_fmtDist(_routeDistanceM!), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _mapBtn(IconData icon, Color iconColor, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9)),
        child: Icon(icon, size: 16, color: iconColor),
      ),
    );
  }

  Widget _buildArrivedButton(double screenH) {
    return Positioned(
      right: 16,
      bottom: screenH * 0.30 + 14,
      child: GestureDetector(
        onTap: _confirmArrived,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF6B35)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: const Color(0xFFFF6B35).withOpacity(0.55), blurRadius: 14, offset: const Offset(0, 5))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.task_alt, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ĐÃ ĐẾN NƠI',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),   
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelDialog() {
    String? _selectedReason;
    final _otherController = TextEditingController();
    bool _showOtherField = false;

    const reasons = [
      'Khách hàng không phản hồi / không liên lạc được',
      'Phương tiện hoặc thiết bị gặp sự cố',
      'Không thể đến địa điểm (tắc đường, sự cố đường)',
      'Địa chỉ không rõ ràng hoặc không chính xác',
      'Có việc khẩn cấp cá nhân',
      'Lý do khác',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
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
                          color: const Color(0xFFDC3545).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cancel_outlined, color: Color(0xFFDC3545), size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hủy đơn',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            Text(
                              'Vui lòng chọn lý do hủy đơn',
                              style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFE082)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Color(0xFFFF8F00), size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Hủy đơn nhiều lần có thể ảnh hưởng đến điểm uy tín của bạn.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF7B5800)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...reasons.map((reason) {
                    final isOther = reason == 'Lý do khác';
                    return InkWell(
                      onTap: () {
                        setSheetState(() {
                          _selectedReason = reason;
                          _showOtherField = isOther;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedReason == reason
                              ? const Color(0xFFDC3545).withOpacity(0.07)
                              : const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedReason == reason
                                ? const Color(0xFFDC3545)
                                : Colors.grey[200]!,
                            width: _selectedReason == reason ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _selectedReason == reason
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: _selectedReason == reason
                                  ? const Color(0xFFDC3545)
                                  : Colors.grey[400],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                reason,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _selectedReason == reason
                                      ? const Color(0xFFDC3545)
                                      : const Color(0xFF444444),
                                  fontWeight: _selectedReason == reason
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (_showOtherField) ...[
                    const SizedBox(height: 4),
                    TextField(
                      controller: _otherController,
                      autofocus: true,
                      maxLines: 2,
                      maxLength: 200,
                      decoration: InputDecoration(
                        hintText: 'Nhập lý do cụ thể...',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFFF8F8F8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFDC3545)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        counterStyle: TextStyle(color: Colors.grey[400], fontSize: 11),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF666666),
                            side: BorderSide(color: Colors.grey[300]!),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Giữ đơn', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (_selectedReason == null || _isCancelling)
                              ? null
                              : () async {
                                  final reason = _selectedReason == 'Lý do khác'
                                      ? (_otherController.text.trim().isNotEmpty
                                          ? _otherController.text.trim()
                                          : 'Lý do khác')
                                      : _selectedReason!;

                                  Navigator.pop(sheetContext);
                                  await _cancelMission(reason);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC3545),
                            disabledBackgroundColor: Colors.grey[300],
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Xác nhận hủy', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _cancelMission(String reason) async {
    setState(() => _isCancelling = true);
    try {
      final repo = ref.read(snakeCatchingRepositoryProvider);
      await repo.abortMission(widget.missionId, reason);
      _positionSub?.cancel();
      _routeRefreshTimer?.cancel();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã hủy đơn thành công'),
          backgroundColor: Color(0xFF28A745),
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: const Color(0xFFDC3545),
        ),
      );
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  ({String badge, Color color}) _dangerInfo(SnakeSpecies? species) {
    if (species == null) return (badge: 'CHƯA RÕ', color: const Color(0xFF999999));
    if (!species.isVenomous) return (badge: 'KHÔNG ĐỘC', color: const Color(0xFF28A745));
    if (species.riskLevel >= 8.0) return (badge: 'CỰC ĐỘC', color: const Color(0xFFDC3545));
    if (species.riskLevel >= 6.0) return (badge: 'ĐỘC MẠNH', color: const Color(0xFFFF6B35));
    if (species.riskLevel >= 4.0) return (badge: 'CÓ ĐỘC', color: const Color(0xFFFFA500));
    return (badge: 'ÍT ĐỘC', color: const Color(0xFFFFC107));
  }

  Widget _buildSnakeSection() {
    final details = widget.requestData.details;
    if (details.isEmpty) return const SizedBox.shrink();
    final totalSnakes = details.fold<int>(0, (s, d) => s + d.quantity);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              '${details.length} loài rắn trong đơn',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFFFF6B35), borderRadius: BorderRadius.circular(10)),
              child: Text('Tổng x$totalSnakes', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_speciesLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF6B35))),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: details.asMap().entries.map((e) {
                final idx = e.key;
                final detail = e.value;
                final species = _speciesCache[detail.snakeSpeciesId];
                final danger = _dangerInfo(species);
                return GestureDetector(
                  onLongPress: species != null ? () => _showSnakeDetail(species, detail) : null,
                  child: Container(
                    width: 130,
                    margin: EdgeInsets.only(right: idx < details.length - 1 ? 10 : 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          child: SizedBox(
                            height: 90, width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  color: const Color(0xFF1A1A2E),
                                  child: species?.imageUrl != null
                                      ? Image.network(species!.imageUrl!, fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.pest_control, size: 32, color: Colors.white24)))
                                      : const Center(child: Icon(Icons.pest_control, size: 32, color: Colors.white24)),
                                ),
                                Positioned(
                                  top: 6, right: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: danger.color,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)],
                                    ),
                                    child: Text(danger.badge, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ),
                                if (species != null)
                                  const Positioned(
                                    bottom: 5, right: 6,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.touch_app, size: 12, color: Colors.white60),
                                        SizedBox(width: 3),
                                        Text('Giữ để xem', style: TextStyle(fontSize: 9, color: Colors.white60)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                species?.commonName ?? detail.snakeSpeciesName,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                              ),
                              if (detail.snakeSpeciesScientificName.isNotEmpty) ...[

                                const SizedBox(height: 2),
                                Text(
                                  detail.snakeSpeciesScientificName,
                                  style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Color(0xFF999999)),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B35).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('x${detail.quantity} con', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35))),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  void _showSnakeDetail(SnakeSpecies species, SnakeSpeciesDetail detail) {
    final danger = _dangerInfo(species);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (ctx, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollCtrl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hero image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: SizedBox(
                    height: 220, width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          color: const Color(0xFF1A1A2E),
                          child: species.imageUrl != null
                              ? Image.network(species.imageUrl!, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.pest_control, size: 64, color: Colors.white24)))
                              : const Center(child: Icon(Icons.pest_control, size: 64, color: Colors.white24)),
                        ),
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10, left: 0, right: 0,
                          child: Center(
                            child: Container(width: 36, height: 4,
                                decoration: BoxDecoration(color: Colors.white38, borderRadius: BorderRadius.circular(2))),
                          ),
                        ),
                        Positioned(
                          bottom: 14, left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: danger.color, borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.warning_rounded, size: 14, color: Colors.white),
                                const SizedBox(width: 5),
                                Text(danger.badge, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 14, right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: const Color(0xFFFF6B35), borderRadius: BorderRadius.circular(6)),
                            child: Text('x${detail.quantity} con', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(species.commonName,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                      if (detail.snakeSpeciesScientificName.isNotEmpty) ...[

                        const SizedBox(height: 4),
                        Text(detail.snakeSpeciesScientificName,
                            style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Color(0xFF888888))),
                      ],
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: [
                          _detailChip(
                            icon: species.isVenomous ? Icons.coronavirus : Icons.check_circle_outline,
                            label: species.isVenomous ? 'Có nọc độc' : 'Không độc',
                            color: species.isVenomous ? const Color(0xFFDC3545) : const Color(0xFF28A745),
                          ),
                          _detailChip(
                            icon: Icons.bar_chart,
                            label: 'Cấp độ: ${species.riskLevel.toStringAsFixed(1)}',
                            color: danger.color,
                          ),
                          if (species.primaryVenomType != null)
                            _detailChip(
                              icon: Icons.science_outlined,
                              label: species.primaryVenomType!,
                              color: const Color(0xFF6C757D),
                            ),
                        ],
                      ),
                      if (species.description != null && species.description!.isNotEmpty) ...[

                        const SizedBox(height: 16),
                        _sectionTitle('Mô tả'),
                        const SizedBox(height: 6),
                        Text(species.description!, style: const TextStyle(fontSize: 13, color: Color(0xFF444444), height: 1.5)),
                      ],
                      if (species.identificationSummary != null && species.identificationSummary!.isNotEmpty) ...[

                        const SizedBox(height: 16),
                        _sectionTitle('Nhận dạng'),
                        const SizedBox(height: 6),
                        Text(species.identificationSummary!, style: const TextStyle(fontSize: 13, color: Color(0xFF444444), height: 1.5)),
                      ],
                      if (species.identification?.physicalTraits.isNotEmpty == true) ...[

                        const SizedBox(height: 16),
                        _sectionTitle('Đặc điểm hình thái'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8, runSpacing: 6,
                          children: species.identification!.physicalTraits.map((t) => _traitChip(t)).toList(),
                        ),
                      ],
                      if (species.identification?.behaviors.isNotEmpty == true) ...[

                        const SizedBox(height: 16),
                        _sectionTitle('Hành vi'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8, runSpacing: 6,
                          children: species.identification!.behaviors.map((b) => _traitChip(b, color: const Color(0xFF2196F3))).toList(),
                        ),
                      ],
                      if (species.identification?.habitat.isNotEmpty == true) ...[

                        const SizedBox(height: 16),
                        _sectionTitle('Môi trường sống'),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.forest_outlined, size: 16, color: Color(0xFF28A745)),
                            const SizedBox(width: 6),
                            Expanded(child: Text(species.identification!.habitat,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF444444)))),
                          ],
                        ),
                      ],
                      if (species.symptomsByTime != null && species.symptomsByTime!.isNotEmpty) ...[

                        const SizedBox(height: 16),
                        _sectionTitle('Triệu chứng khi bị cắn'),
                        const SizedBox(height: 8),
                        ...species.symptomsByTime!.map((sym) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: sym.isCritical ? const Color(0xFFFFF3F3) : const Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: sym.isCritical ? const Color(0xFFFFCDD2) : const Color(0xFFEEEEEE)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Icon(sym.isCritical ? Icons.priority_high : Icons.access_time,
                                        size: 14, color: sym.isCritical ? const Color(0xFFDC3545) : const Color(0xFF666666)),
                                    const SizedBox(width: 5),
                                    Text(sym.timeRange, style: TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.bold,
                                      color: sym.isCritical ? const Color(0xFFDC3545) : const Color(0xFF555555),
                                    )),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ...sym.signs.map((sign) => Padding(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('• ', style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
                                      Expanded(child: Text(sign, style: const TextStyle(fontSize: 12, color: Color(0xFF444444)))),
                                    ],
                                  ),
                                )),
                              ],
                            ),
                          ),
                        )),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) =>
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)));

  Widget _traitChip(String label, {Color color = const Color(0xFF555555)}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color)),
    );
  }

  Widget _buildBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.30,
      minChildSize: 0.12,
      maxChildSize: 0.56,
      snap: true,
      snapSizes: const [0.12, 0.30, 0.56],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, -4))],
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      width: 36, height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  _buildSheetExpanded(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetCollapsed() {
    final user = widget.requestData.user;
    final name = user?.account?.fullName ?? user?.userName ?? 'Khách hàng';
    final phone = user?.phoneNumber ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: [
          _buildCustomerAvatar(radius: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
          if (phone.isNotEmpty)
            GestureDetector(
              onTap: _callCustomer,
              child: Container(
                width: 36, height: 36,
                decoration: const BoxDecoration(color: Color(0xFF28A745), shape: BoxShape.circle),
                child: const Icon(Icons.call, color: Colors.white, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSheetExpanded() {
    final request = widget.requestData;
    final user = request.user;
    final name = user?.account?.fullName ?? user?.userName ?? 'Khách hàng';
    final phone = user?.phoneNumber ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildCustomerAvatar(radius: 23),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
                    const SizedBox(height: 2),
                    Row(children: [
                      Expanded(
                        child: Text('Địa chỉ: ${request.address}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF666666), height: 1.35),
                            maxLines: 2, softWrap: true, overflow: TextOverflow.visible),
                      ),
                    ]),
                  ],
                ),
              ),
              if (phone.isNotEmpty)
                GestureDetector(
                  onTap: _callCustomer,
                  child: Container(
                    width: 42, height: 42,
                    decoration: const BoxDecoration(color: Color(0xFFFF6B35), shape: BoxShape.circle),
                    child: const Icon(Icons.call, color: Colors.white, size: 20),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _canMarkArrived ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _canMarkArrived ? const Color(0xFF28A745) : const Color(0xFFFFE082)),
            ),
            child: Row(
              children: [
                Icon(
                  _canMarkArrived ? Icons.check_circle_outline : Icons.directions_car,
                  size: 18,
                  color: _canMarkArrived ? const Color(0xFF28A745) : const Color(0xFFFF8F00),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _directDistanceM == null
                      ? 'Đang lấy vị trí'
                      : _canMarkArrived
                        ? 'Bạn đã gần đến nơi! Bấm "ĐÃ ĐẾN NƠI" ở phía trên'
                        : 'Nút "Đã đến nơi" sẽ hiện khi bạn vào trong phạm vi 1 km',
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: _canMarkArrived ? const Color(0xFF28A745) : const Color(0xFFFF8F00),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.requestData.details.isNotEmpty) ...[

            const SizedBox(height: 12),
            _buildSnakeSection(),
          ],
         
          const SizedBox(height: 100),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isCancelling ? null : _showCancelDialog,
              icon: _isCancelling
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFDC3545)),
                    )
                  : const Icon(Icons.close, size: 16),
              label: Text(
                _isCancelling ? 'Đang hủy đơn...' : 'Hủy đơn',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC3545),
                side: const BorderSide(color: Color(0xFFDC3545)),
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerAvatar({required double radius}) {
    final avatarUrl = _customerAvatarUrl;
    final size = radius * 2;

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: const Color(0xFFE0E0E0),
        child: avatarUrl != null && avatarUrl.isNotEmpty
            ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.person,
                  color: const Color(0xFF999999),
                  size: radius * 1.1,
                ),
              )
            : Icon(
                Icons.person,
                color: const Color(0xFF999999),
                size: radius * 1.1,
              ),
      ),
    );
  }
}