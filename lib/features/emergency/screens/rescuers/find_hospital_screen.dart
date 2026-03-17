import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/hospital_provider.dart';
import '../../repository/rescue_mission_repository.dart';
import '../../models/hospital_response.dart';
import '../../../../core/providers/openroute_provider.dart';

class FindHospitalScreen extends ConsumerStatefulWidget {
  final String missionId;
  final String incidentId;

  const FindHospitalScreen({
    super.key,
    required this.missionId,
    required this.incidentId,
  });

  @override
  ConsumerState<FindHospitalScreen> createState() => _FindHospitalScreenState();
}

class _FindHospitalScreenState extends ConsumerState<FindHospitalScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // controller that allows programmatic expansion/collapse of the bottom sheet
  final DraggableScrollableController _draggableSheetController =
      DraggableScrollableController();

  // map from hospital id to the GlobalKey of its card in the sheet
  final Map<int, GlobalKey> _hospitalKeys = {};

  // currently highlighted/tapped marker id (or selected hospital id)
  int? _highlightedHospitalId;

  @override
  void initState() {
    super.initState();
    // Load hospitals on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hospitalProvider.notifier).getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _openGoogleMaps(
    double latitude,
    double longitude,
    String hospitalName,
  ) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&destination_place_id=$hospitalName',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở Google Maps')),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể thực hiện cuộc gọi')),
        );
      }
    }
  }

  /// Select hospital and report transfer to backend
  Future<void> _selectAndReportHospital(HospitalResponse hospital) async {
    try {
      // highlight marker for selected hospital
      setState(() {
        _highlightedHospitalId = hospital.id;
      });
      // Check if we have current location
      final hospitalState = ref.read(hospitalProvider);
      if (!hospitalState.hasLocation) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể lấy vị trí hiện tại'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Show loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFFFF8800)),
                SizedBox(height: 16),
                Text(
                  'Đang tính khoảng cách...',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        );
      }

      // Get actual route distance from OpenRouteService
      final openRoute = ref.read(openRouteServiceProvider);
      final currentPos = hospitalState.currentPosition!;

      final routeData = await openRoute.getRoute(
        start: LatLng(currentPos.latitude, currentPos.longitude),
        end: LatLng(hospital.latitude, hospital.longitude),
      );

      final actualDistanceKm = routeData.distanceKm;
      debugPrint(
        '📏 Route distance: ${actualDistanceKm.toStringAsFixed(2)} km',
      );
      debugPrint(
        '   (Straight-line was: ${hospital.distanceKm.toStringAsFixed(2)} km)',
      );

      // Call API to report hospital transfer with actual route distance
      final repository = ref.read(rescueMissionRepositoryProvider);
      final pricingResponse = await repository.reportTranferToHospital(
        missionId: widget.missionId,
        hospitalId: hospital.id,
        distanceToHospitalKm: actualDistanceKm,
        note: null,
      );

      // Save to provider
      ref
          .read(hospitalProvider.notifier)
          .setSelectedHospitalPricing(pricingResponse);

      // Close loading
      if (mounted) Navigator.pop(context);

      // Show success and pricing info
      if (mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF28A745).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF28A745),
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Đã chọn bệnh viện',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C100D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    pricingResponse.hospitalName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F7F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildPricingRow(
                          'Phí cứu hộ',
                          pricingResponse.baseMissionPrice,
                        ),
                        const Divider(height: 16),
                        _buildPricingRow(
                          'Phí chuyển viện',
                          pricingResponse.hospitalTransferPrice,
                          subtitle:
                              '${pricingResponse.distanceKm.toStringAsFixed(1)} km × ${pricingResponse.pricePerKm.toStringAsFixed(0)}đ/km',
                        ),
                        const Divider(height: 16),
                        _buildPricingRow(
                          'Tổng cộng',
                          pricingResponse.totalPrice,
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        // Open Google Maps
                        _openGoogleMaps(
                          hospital.latitude,
                          hospital.longitude,
                          hospital.name,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8800),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Bắt đầu chỉ đường',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
    } catch (e) {
      // Close loading if open
      if (mounted) Navigator.pop(context);

      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPricingRow(
    String label,
    double amount, {
    String? subtitle,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isBold ? 16 : 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: const Color(0xFF1C100D),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
            ],
          ],
        ),
        Text(
          '${amount.toStringAsFixed(0)}đ',
          style: TextStyle(
            fontSize: isBold ? 18 : 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? const Color(0xFFFF8800) : const Color(0xFF1C100D),
          ),
        ),
      ],
    );
  }

  void _showCompletionDialog() {
    final hospitalState = ref.read(hospitalProvider);
    final pricing = hospitalState.selectedHospitalPricing;

    if (!hospitalState.hasSelectedHospital || pricing == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn bệnh viện trước'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF28A745).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF28A745),
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hoàn thành hỗ trợ?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C100D),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Bệnh nhân đang được đưa đến ${pricing.hospitalName}. Xác nhận hoàn thành nhiệm vụ?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF666666),
                        side: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        context.push(
                          '/rescuer/mission-completion',
                          extra: {
                            'missionId': widget.missionId,
                            'needHospital': true,
                            'hospitalName': pricing.hospitalName,
                            'hospitalId': pricing.hospitalId,
                            'totalPrice': pricing.totalPrice,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF28A745),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Xác nhận'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      body: Column(
        children: [
          // Header
          SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFF1C100D),
                    ),
                    onPressed: () => context.pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Expanded(
                    child: Text(
                      'Tìm bệnh viện',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C100D),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.filter_list,
                      color: Color(0xFF1C100D),
                    ),
                    onPressed: () {
                      // TODO: Show filter options
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Tìm theo tên hoặc vị trí...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF999999),
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color(0xFF999999),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(hospitalProvider.notifier)
                            .getCurrentLocation();
                      },
                      child: const Text(
                        'Dùng vị trí của tôi',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF8800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Map + Bottom Sheet Container
          Expanded(
            child: Stack(
              children: [
                // map should take full space
                _buildMapView(),

                // draggable hospital list
                _buildHospitalSheet(),
              ],
            ),
          ),

          // Bottom Action Bar
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    final hospitalState = ref.watch(hospitalProvider);

    // map is intended to fill whatever space is given by its parent (Stack/Expanded)
    return Positioned.fill(
      child: Container(
        color: const Color(0xFFE5E5E5),
        child: Stack(
          children: [
            // Map
            if (hospitalState.hasLocation)
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(
                    hospitalState.currentPosition!.latitude,
                    hospitalState.currentPosition!.longitude,
                  ),
                  initialZoom: 13.0,
                  minZoom: 10.0,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.snakeaid.mobile',
                  ),
                  MarkerLayer(
                    markers: [
                      // Current location marker
                      Marker(
                        point: LatLng(
                          hospitalState.currentPosition!.latitude,
                          hospitalState.currentPosition!.longitude,
                        ),
                        width: 40,
                        height: 40,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF007AFF),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Hospital markers
                      ...hospitalState.hospitals.map((hospital) {
                        final isHighlighted =
                            hospital.id == _highlightedHospitalId ||
                            (hospitalState.hasSelectedHospital &&
                                hospitalState
                                        .selectedHospitalPricing
                                        ?.hospitalId ==
                                    hospital.id);

                        return Marker(
                          point: LatLng(hospital.latitude, hospital.longitude),
                          width: isHighlighted ? 48 : 40,
                          height: isHighlighted ? 48 : 40,
                          child: GestureDetector(
                            onTap: () => _onHospitalMarkerTap(hospital),
                            child: Icon(
                              Icons.local_hospital,
                              color: isHighlighted
                                  ? const Color(0xFF007AFF)
                                  : const Color(0xFFDC3545),
                              size: isHighlighted ? 48 : 40,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hospitalState.isLoadingLocation)
                      const CircularProgressIndicator(color: Color(0xFFFF8800))
                    else if (hospitalState.error != null)
                      Column(
                        children: [
                          const Icon(
                            Icons.location_off,
                            size: 48,
                            color: Color(0xFF999999),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            hospitalState.error!,
                            style: const TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(hospitalProvider.notifier)
                                  .getCurrentLocation();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8800),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            // Loading overlay
            if (hospitalState.isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF8800)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// A draggable bottom sheet containing the hospital list.
  Widget _buildHospitalSheet() {
    final hospitalState = ref.watch(hospitalProvider);

    return DraggableScrollableSheet(
      controller: _draggableSheetController,
      initialChildSize: 0.35,
      minChildSize: 0.15,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        // keep a reference to the passed controller (used when scrolling to an item)
        // not strictly needed for ensureVisible, but useful if we want to programmatically
        // adjust offset in future
        // ignore: unnecessary_null_comparison
        if (scrollController != null && _hospitalKeys.isEmpty) {
          // nothing for now
        }

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F7F5),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
            ],
          ),
          child: hospitalState.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF8800)),
                )
              : hospitalState.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Color(0xFF999999),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          hospitalState.error!,
                          style: const TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(hospitalProvider.notifier).refresh();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8800),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                )
              : hospitalState.hasHospitals
              ? ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: hospitalState.hospitals.length + 1,
                  itemBuilder: (context, index) {
                    if (index == hospitalState.hospitals.length) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFF8800).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFFFF8800),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Danh sách các bệnh viện gần bạn. Kéo xuống để làm mới.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final hospital = hospitalState.hospitals[index];
                    final key = _hospitalKeys.putIfAbsent(
                      hospital.id,
                      () => GlobalKey(),
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: KeyedSubtree(
                        key: key,
                        child: _buildHospitalCard(hospital, index == 0),
                      ),
                    );
                  },
                )
              : const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_searching,
                          size: 64,
                          color: Color(0xFF999999),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Đang tìm bệnh viện gần bạn...',
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  // called when tapping on a hospital marker in the map
  void _onHospitalMarkerTap(HospitalResponse hospital) {
    setState(() {
      _highlightedHospitalId = hospital.id;
    });

    // ensure sheet is visible and scroll to item
    _draggableSheetController.animateTo(
      0.5,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _hospitalKeys[hospital.id];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 300),
          alignment: 0.1,
        );
      }
    });
  }

  Widget _buildHospitalCard(HospitalResponse hospital, bool isHighlighted) {
    final hospitalState = ref.watch(hospitalProvider);
    final isSelected =
        hospitalState.hasSelectedHospital &&
        hospitalState.selectedHospitalPricing!.hospitalId == hospital.id;
    final isAnotherSelected =
        hospitalState.hasSelectedHospital &&
        hospitalState.selectedHospitalPricing!.hospitalId != hospital.id;

    // Calculate estimated duration (rough estimate: 30 km/h average)
    final durationMinutes = (hospital.distanceKm * 2).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: const Color(0xFF28A745), width: 2)
            : (isHighlighted && !isAnotherSelected)
            ? Border.all(color: const Color(0xFFFF8800), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              isSelected ? 0.12 : (isHighlighted ? 0.1 : 0.05),
            ),
            blurRadius: isSelected ? 12 : (isHighlighted ? 12 : 8),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C100D),
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF28A745).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Color(0xFF28A745),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Đã chọn',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF28A745),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${hospital.distanceKm.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF8800),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '~$durationMinutes phút lái xe',
            style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Color(0xFF666666)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hospital.address,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1C100D),
                  ),
                ),
              ),
            ],
          ),
          if (hospital.contactNumber != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Color(0xFF666666)),
                const SizedBox(width: 8),
                Text(
                  hospital.contactNumber!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1C100D),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isAnotherSelected
                      ? null
                      : isSelected
                      ? () => _openGoogleMaps(
                          hospital.latitude,
                          hospital.longitude,
                          hospital.name,
                        )
                      : () => _selectAndReportHospital(hospital),
                  icon: Icon(
                    isSelected ? Icons.directions : Icons.check,
                    size: 18,
                  ),
                  label: Text(isSelected ? 'Chỉ đường' : 'Chọn bệnh viện'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAnotherSelected
                        ? Colors.grey.shade300
                        : (isSelected
                              ? const Color(0xFFFF8800)
                              : const Color(0xFF28A745)),
                    foregroundColor: isAnotherSelected
                        ? Colors.grey.shade500
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (hospital.contactNumber != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _makePhoneCall(hospital.contactNumber!),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF8800),
                      side: const BorderSide(
                        color: Color(0xFFFF8800),
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Gọi BV',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    final hospitalState = ref.watch(hospitalProvider);
    final hasSelected = hospitalState.hasSelectedHospital;
    final pricing = hospitalState.selectedHospitalPricing;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasSelected ? const Color(0xFFF0FFF4) : const Color(0xFFF0F8FF),
        border: Border(
          top: BorderSide(
            color: hasSelected
                ? const Color(0xFF28A745).withOpacity(0.3)
                : const Color(0xFF007AFF).withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasSelected && pricing != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF28A745),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pricing.hospitalName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1C100D),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng chi phí:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                        Text(
                          '${pricing.totalPrice.toStringAsFixed(0)}đ',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF8800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Phí cứu hộ: ${pricing.baseMissionPrice.toStringAsFixed(0)}đ + '
                      'Phí chuyển viện: ${pricing.hospitalTransferPrice.toStringAsFixed(0)}đ',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Text('💡', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mẹo: Gọi trước để xác nhận có huyết thanh.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1C100D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: hasSelected ? _showCompletionDialog : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasSelected
                      ? const Color(0xFFFF8800)
                      : Colors.grey.shade300,
                  foregroundColor: hasSelected
                      ? Colors.white
                      : Colors.grey.shade500,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  hasSelected
                      ? 'HOÀN THÀNH HỖ TRỢ'
                      : 'CHỌN BỆNH VIỆN ĐỂ TIẾP TỤC',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
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
