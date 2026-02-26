import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/snake_catching_request.dart';
import '../../repository/snake_catching_repository.dart';
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
  bool _bottomSheetExpanded = true;
  bool _routeLoading = false;
  bool _isArriving = false;

  StreamSubscription<Position>? _positionSub;
  Timer? _routeRefreshTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

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
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _routeRefreshTimer?.cancel();
    _pulseController.dispose();
    _dio.close(force: true);
    super.dispose();
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

  void _confirmArrived() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận đến nơi', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bạn đã đến vị trí của khách hàng?'),
            if (_directDistanceM != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF28A745), size: 16),
                    const SizedBox(width: 6),
                    Text('Cách điểm đến ${_fmtDist(_directDistanceM!)}',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF28A745), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Chưa đến')),
          StatefulBuilder(
            builder: (ctx2, setDialogState) => ElevatedButton(
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
                        // non-fatal — still navigate
                      } finally {
                        if (mounted) setState(() => _isArriving = false);
                      }
                      if (!mounted) return;
                      Navigator.pop(ctx);
                      _positionSub?.cancel();
                      _routeRefreshTimer?.cancel();
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (_) => RescuerTrackingScreen(
                          requestData: widget.requestData,
                          missionId: widget.missionId,
                        ),
                      ));
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF28A745),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isArriving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Đã đến nơi'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          _buildHeader(),
          _buildBottomSheet(),
          if (_canMarkArrived) _buildArrivedButton(),
        ],
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
                        () => Navigator.pop(context)),
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

  Widget _buildArrivedButton() {
    final double sheetApproxHeight = _bottomSheetExpanded ? 290 : 100;
    return Positioned(
      right: 16,
      bottom: sheetApproxHeight + 14,
      child: GestureDetector(
        onTap: _confirmArrived,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B8F3A), Color(0xFF28A745)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: const Color(0xFF28A745).withOpacity(0.55), blurRadius: 14, offset: const Offset(0, 5))],
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
                  if (_directDistanceM != null)
                    Text('Cách ${_fmtDist(_directDistanceM!)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => setState(() => _bottomSheetExpanded = !_bottomSheetExpanded),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      Container(width: 36, height: 4,
                          decoration: BoxDecoration(color: const Color(0xFFDDDDDD), borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 3),
                      Icon(_bottomSheetExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                          color: const Color(0xFFAAAAAA), size: 18),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: _buildSheetExpanded(),
                secondChild: _buildSheetCollapsed(),
                crossFadeState: _bottomSheetExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 220),
                sizeCurve: Curves.easeInOut,
              ),
            ],
          ),
        ),
      ),
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
          const CircleAvatar(backgroundColor: Color(0xFFE0E0E0), radius: 18,
              child: Icon(Icons.person, color: Color(0xFF999999), size: 20)),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
          if (_directDistanceM != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                _fmtDist(_directDistanceM!),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                    color: _canMarkArrived ? const Color(0xFF28A745) : const Color(0xFFFF6B35)),
              ),
            ),
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
    final totalSnakes = request.details.fold<int>(0, (s, d) => s + d.quantity);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(backgroundColor: Color(0xFFE0E0E0), radius: 23,
                  child: Icon(Icons.person, color: Color(0xFF999999), size: 26)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF222222))),
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(Icons.location_on, size: 12, color: Color(0xFFFF6B35)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(request.address,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
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
                    decoration: const BoxDecoration(color: Color(0xFF28A745), shape: BoxShape.circle),
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
                            : 'Còn cách ${_fmtDist(_directDistanceM!)}  nút "Đã đến nơi" hiện trong vòng 1 km',
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: _canMarkArrived ? const Color(0xFF28A745) : const Color(0xFFFF8F00),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (request.details.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.pest_control, size: 20, color: Color(0xFFFF6B35)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(request.details.first.snakeSpeciesName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                      if (request.details.first.snakeSpeciesScientificName.isNotEmpty)
                        Text(request.details.first.snakeSpeciesScientificName,
                            style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF888888))),
                      if (request.details.length > 1)
                        Text('+${request.details.length - 1} loài khác',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
                    ]),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFFF6B35), borderRadius: BorderRadius.circular(12)),
                    child: Text('x$totalSnakes', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _callCustomer,
                icon: const Icon(Icons.phone_in_talk, size: 15),
                label: const Text('Gọi khách', style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF6B35),
                  side: const BorderSide(color: Color(0xFFFF6B35)),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _openExternalNav,
                icon: const Icon(Icons.navigation, size: 15),
                label: const Text('Chỉ đường', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}