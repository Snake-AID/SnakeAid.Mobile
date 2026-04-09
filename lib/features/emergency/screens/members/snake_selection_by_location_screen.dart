import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/sos_incident_response.dart';
import '../../models/snakes_by_location_response.dart';
import '../../providers/snake_location_provider.dart';
import '../../repository/incident_repository.dart';

/// Snake Selection by Location Screen - Location-based snake filtering with API
class SnakeSelectionByLocationScreen extends ConsumerStatefulWidget {
  final IncidentData? incident;

  const SnakeSelectionByLocationScreen({super.key, this.incident});

  @override
  ConsumerState<SnakeSelectionByLocationScreen> createState() =>
      _SnakeSelectionByLocationScreenState();
}

class _SnakeSelectionByLocationScreenState
    extends ConsumerState<SnakeSelectionByLocationScreen> {
  @override
  void initState() {
    super.initState();
    _fetchLocationAndSnakes();
  }

  Future<void> _fetchLocationAndSnakes() async {
    try {
      // Get current GPS location
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Fetch snakes by location from API
      await ref
          .read(snakeLocationProvider.notifier)
          .fetchSnakesByLocation(
            latitude: position.latitude,
            longitude: position.longitude,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể lấy vị trí: ${e.toString()}'),
            backgroundColor: const Color(0xFFDC3545),
          ),
        );
      }
    }
  }

  /// Get current location using Geolocator
  Future<Position?> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ Location services are disabled');
        return null;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('❌ Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ Location permissions are permanently denied');
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      debugPrint('✅ Location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
      return null;
    }
  }

  /// Reverse geocode coordinates to human-readable address using OSM Nominatim
  Future<String?> _reverseGeocodeAddress(double lat, double lng) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': lat.toString(),
          'lon': lng.toString(),
          'addressdetails': '1',
          'accept-language': 'vi',
        },
        options: Options(
          headers: {'User-Agent': 'SnakeAid Mobile App'},
          connectTimeout: Duration(milliseconds: 7000),
          sendTimeout: Duration(milliseconds: 7000),
          receiveTimeout: Duration(milliseconds: 7000),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final displayName = response.data['display_name'] as String?;
        if (displayName != null && displayName.isNotEmpty) {
          return displayName;
        }
      }
      return null;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        debugPrint(
          '⏱️ OSM reverse geocode timed out (7s). Returning null address',
        );
      } else {
        debugPrint('❌ Failed to reverse geocode: $e');
      }
      return null;
    } catch (e) {
      debugPrint('❌ Failed to reverse geocode: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(snakeLocationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: _buildAppBar(locationState),
      body: _buildBody(locationState),
    );
  }

  PreferredSizeWidget _buildAppBar(SnakeLocationState locationState) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF333333)),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.goNamed(
              'emergency_tracking',
              extra: {'incidentId': widget.incident?.id},
            );
          }
        },
      ),
      title: const Text(
        'Rắn thường gặp ở khu vực bạn',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
      ),
      actions: [
        if (locationState.data != null)
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFFDC3545),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  locationState.placeName ?? locationState.data!.region.name,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBody(SnakeLocationState locationState) {
    if (locationState.isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF228B22)),
            SizedBox(height: 16),
            Text(
              'Đang tải danh sách rắn...',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
          ],
        ),
      );
    }

    if (locationState.error != null) {
      return _buildErrorState(locationState.error!);
    }

    if (locationState.data == null) {
      return const Center(child: Text('Không có dữ liệu'));
    }

    return _buildSnakeList(locationState.data!);
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFDC3545)),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchLocationAndSnakes,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF228B22),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSnakeList(dynamic data) {
    // Cast to proper type
    final locationData = data as SnakesByLocationResponse;
    final snakes = locationData.snakes;

    return Column(
      children: [
        // Warning Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          color: const Color(0xFFFFFACD),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFDAA520),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Chọn con giống nhất — không cần chính xác 100%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7F6000),
                  ),
                ),
              ),
              Text(
                '${snakes.length} loài',
                style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
              ),
            ],
          ),
        ),

        // Snake Grid
        Expanded(
          child: snakes.isEmpty
              ? const Center(
                  child: Text(
                    'Không tìm thấy rắn nào trong khu vực này',
                    style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: snakes.length,
                  itemBuilder: (context, index) {
                    final snake = snakes[index];
                    return _buildSnakeCard(context, snake: snake);
                  },
                ),
        ),

        // Footer
        _buildFooter(),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tiếp tục báo cáo triệu chứng (Primary action)
            ElevatedButton.icon(
              onPressed: () {
                if (widget.incident != null) {
                  // Use push instead of goNamed to maintain navigation stack
                  context.push(
                    '/symptom-report',
                    extra: {
                      'incidentId': widget.incident!.id,
                      'isDirectEntry': false, // From snake verification flow
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Không tìm thấy thông tin sự cố'),
                      backgroundColor: Color(0xFFDC3545),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.assignment, size: 20),
              label: const Text('Tiếp tục báo cáo triệu chứng'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF228B22),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle snake selection with auto-confirm
  Future<void> _onSnakeSelected(
    BuildContext context,
    SnakeInRegionDto snake,
  ) async {
    final name = snake.commonName;
    final scientificName = snake.scientificName;
    final isPoisonous = snake.isVenomous;
    final snakeId = snake.id;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF228B22)),
      ),
    );

    try {
      // Call confirm API (simple confirm by location - no filter data needed)
      if (widget.incident != null) {
        final repository = ref.read(incidentRepositoryProvider);

        // For location-based selection, we use simplified confirm
        // No selectedOptionIds (no questions), just the snake species
        await repository.confirmSnakeIdentificationByFilter(
          incidentId: widget.incident!.id,
          selectedOptionIds: [], // Empty for location-based selection
          selectedSnakeSpeciesId: snakeId,
          matchScore: 0, // Not applicable for location selection
          matchPercentage: 0.0, // Not applicable for location selection
        );
      }

      if (!mounted) return;

      // Close loading
      Navigator.pop(context);

      // Show success dialog with 2 options
      _showSuccessDialog(context, name, scientificName, isPoisonous);
    } catch (e) {
      if (!mounted) return;

      // Close loading
      Navigator.pop(context);

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: const Color(0xFFDC3545),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// Show success dialog with 2 action options
  void _showSuccessDialog(
    BuildContext context,
    String snakeName,
    String scientificName,
    bool isPoisonous,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF228B22).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF228B22),
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Đã xác nhận loài rắn',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              snakeName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              scientificName,
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPoisonous
                    ? const Color(0xFFFEF2F2)
                    : const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isPoisonous
                      ? const Color(0xFFFECDD3)
                      : const Color(0xFFBBF7D0),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isPoisonous ? Icons.warning : Icons.shield,
                    color: isPoisonous
                        ? const Color(0xFFDC3545)
                        : const Color(0xFF228B22),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isPoisonous ? 'RẮN ĐỘC' : 'KHÔNG ĐỘC',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isPoisonous
                            ? const Color(0xFFDC3545)
                            : const Color(0xFF228B22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Thông tin đã được cập nhật vào yêu cầu SOS của bạn.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          // Primary: Go to Symptom Report
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                if (widget.incident != null) {
                  context.push(
                    '/symptom-report',
                    extra: {
                      'incidentId': widget.incident!.id,
                      'isDirectEntry': false, // From snake verification flow
                    },
                  );
                }
              },
              icon: const Icon(Icons.assignment, size: 18),
              label: const Text(
                'Tiếp theo: Báo cáo triệu chứng',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF228B22),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Secondary: Back to Tracking
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Close dialog, then pop back to emergency tracking (2 levels total)
                Navigator.of(context)
                  ..pop()
                  ..pop();
              },
              icon: const Icon(Icons.crisis_alert, size: 18),
              label: const Text(
                'Về theo dõi cứu hộ',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF228B22),
                side: const BorderSide(color: Color(0xFF228B22), width: 2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnakeCard(
    BuildContext context, {
    required SnakeInRegionDto snake,
  }) {
    final name = snake.commonName;
    final scientificName = snake.scientificName;
    final isPoisonous = snake.isVenomous;
    final imageUrl = snake.imageUrl;
    final identificationSummary = snake.identificationSummary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Snake Image with Badge
          Stack(
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  image: imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                          onError: (_, __) {},
                        )
                      : null,
                ),
                child: imageUrl.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: Color(0xFFBDBDBD),
                        ),
                      )
                    : null,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPoisonous
                        ? const Color(0xFFDC3545)
                        : const Color(0xFF28A745),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPoisonous ? Icons.warning : Icons.shield,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPoisonous ? 'RẮN ĐỘC' : 'KHÔNG ĐỘC',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Snake Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Scientific Name
                  Text(
                    scientificName,
                    style: TextStyle(
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Identification Summary
                  Expanded(
                    child: Text(
                      identificationSummary,
                      style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Select Button
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _onSnakeSelected(context, snake),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Chọn loài này',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 13),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
