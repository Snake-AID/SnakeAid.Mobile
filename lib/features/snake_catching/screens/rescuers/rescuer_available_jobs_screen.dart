import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snakeaid_mobile/features/snake_catching/screens/rescuers/rescuer_accept_request_screen.dart';
import 'package:snakeaid_mobile/features/snake_catching/screens/rescuers/rescuer_en_route_screen.dart';
import 'package:snakeaid_mobile/features/snake_catching/screens/rescuers/rescuer_mission_success_screen.dart';
import 'package:snakeaid_mobile/features/snake_catching/screens/rescuers/rescuer_request_detail_screen.dart';
import 'package:snakeaid_mobile/features/snake_catching/screens/rescuers/rescuer_tracking_screen.dart';
import '../../models/snake_catching_request.dart';
import '../../models/snake_species.dart';
import '../../repository/snake_catching_repository.dart';
import '../../repository/snake_species_repository.dart';
import '../../repository/transaction_repository.dart';
import '../../../emergency/providers/rescuer_emergency_provider.dart';

/// Màn hình hiển thị danh sách các đơn cứu hộ có thể nhận
class RescuerAvailableJobsScreen extends ConsumerStatefulWidget {
  const RescuerAvailableJobsScreen({super.key});

  @override
  ConsumerState<RescuerAvailableJobsScreen> createState() => _RescuerAvailableJobsScreenState();
}

class _RescuerAvailableJobsScreenState extends ConsumerState<RescuerAvailableJobsScreen> {
  // _isOnline is derived from rescueModeProvider in build() — not stored locally
  bool _isOnline = false;
  String _selectedFilter = 'Gần nhất'; // Gần nhất, Mới nhất
  String _selectedDistance = '10km'; // 10km, 20km, 30km
  
  bool _isLoading = true;
  String? _errorMessage;
  String? _locationErrorMessage;
  List<SnakeCatchingRequestData> _allRequests = [];
  Position? _currentPosition;
  Timer? _refreshTimer;
  String? _currentRescuerId;
  
  // Cache for snake species details
  final Map<int, SnakeSpecies> _speciesCache = {};

  // Cache for deposit transactions keyed by requestId
  final Map<String, TransactionInfo?> _transactionCache = {};

  // Cache for mission data keyed by requestId (refreshed on every load so status stays fresh)
  final Map<String, MissionData?> _missionCache = {};

  @override
  void initState() {
    super.initState();
    _initialize();
    // Auto-refresh every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _silentRefresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _loadRescuerId();
    await _getCurrentLocation();
    await _loadRequests();
  }

  Future<void> _toggleRescueMode() async {
    if (_currentRescuerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy thông tin cứu hộ viên'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final rescueModeState = ref.read(rescueModeProvider);
    if (rescueModeState.isActive) {
      await ref.read(rescueModeProvider.notifier).stopRescueMode();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã tắt chế độ cứu hộ — bạn sẽ không nhận được đơn mới'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    } else {
      try {
        await ref.read(rescueModeProvider.notifier).startRescueMode(_currentRescuerId!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🟢 Đã bật chế độ cứu hộ — sẵn sàng nhận đơn'),
              backgroundColor: Color(0xFF28A745),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể bật chế độ cứu hộ: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _loadRescuerId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId != null && mounted) {
        setState(() {
          _currentRescuerId = userId;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading rescuer ID: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      debugPrint('🌍 Starting location acquisition...');
      
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ Location service is disabled');
        if (mounted) {
          setState(() {
            _locationErrorMessage = 'Vui lòng bật dịch vụ định vị để tính khoảng cách';
          });
        }
        return;
      }
      
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('📍 Location permission status: $permission');
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('❌ Location permission denied');
          if (mounted) {
            setState(() {
              _locationErrorMessage = 'Cần quyền truy cập vị trí để tính khoảng cách';
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ Location permission denied forever');
        if (mounted) {
          setState(() {
            _locationErrorMessage = 'Vui lòng cấp quyền vị trí trong cài đặt để tính khoảng cách';
          });
        }
        return;
      }

      // Get current position with timeout
      debugPrint('🔍 Requesting current position...');
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      debugPrint('✓ Got current location: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}');
      
      // Trigger UI update with new location
      if (mounted) {
        setState(() {
          // Clear location error message if we successfully got location
          _locationErrorMessage = null;
        });
      }
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
      if (mounted) {
        setState(() {
          _locationErrorMessage = 'Không thể lấy vị trí hiện tại. Khoảng cách sẽ không chính xác.';
        });
      }
    }
  }

  Future<void> _loadRequests() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final repository = ref.read(snakeCatchingRepositoryProvider);
      final response = await repository.getRequests();
      if (!mounted) return;
      if (response.isSuccess) {
        setState(() {
          _allRequests = response.data;
          _isLoading = false;
        });
        await _loadSnakeSpeciesDetails();
        await _loadTransactionsForAssigned();
        await _loadMissionStatusForAssigned();
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

  Future<void> _silentRefresh() async {
    if (!mounted) return;
    try {
      final repository = ref.read(snakeCatchingRepositoryProvider);
      final response = await repository.getRequests();
      if (!mounted) return;
      if (response.isSuccess) {
        setState(() {
          _allRequests = response.data;
        });
        await _loadTransactionsForAssigned();
        await _loadMissionStatusForAssigned();
      }
    } catch (e) {
      debugPrint('Silent refresh error: $e');
    }
  }

  /// Fetch mission status for all active requests (re-fetches each refresh so status stays fresh)
  Future<void> _loadMissionStatusForAssigned() async {
    final repo = ref.read(snakeCatchingRepositoryProvider);
    const activeStatuses = {'Assigned', 'Finished', 'Paid', 'Completed', 'Dispute'};
    final assignedRequests = _allRequests
        .where((r) => activeStatuses.contains(r.status))
        .toList();
    if (assignedRequests.isEmpty) return;

    await Future.wait(
      assignedRequests.map((request) async {
        try {
          final detail = await repo.getRequestById(request.id);
          if (mounted) {
            setState(() {
              _missionCache[request.id] = detail.data?.mission;
            });
          }
        } catch (e) {
          debugPrint('⚠️ Could not fetch mission status for ${request.id}: $e');
        }
      }),
    );
  }

  /// Fetch deposit transaction for every Assigned request (if not cached)
  Future<void> _loadTransactionsForAssigned() async {
    final repo = ref.read(transactionRepositoryProvider);
    final assignedRequests = _allRequests
        .where((r) => r.status == 'Assigned' && !_transactionCache.containsKey(r.id))
        .toList();
    if (assignedRequests.isEmpty) return;

    await Future.wait(
      assignedRequests.map((request) async {
        try {
          final tx = await repo.getTransactionByRequestId(request.id);
          if (mounted) setState(() => _transactionCache[request.id] = tx);
        } catch (_) {
          // Cache null so we don't retry on every refresh
          if (mounted) setState(() => _transactionCache[request.id] = null);
        }
      }),
    );
  }

  Future<void> _loadSnakeSpeciesDetails() async {
    try {
      final repository = ref.read(snakeSpeciesRepositoryProvider);
      
      // Get all unique species IDs from all requests
      final Set<int> speciesIds = {};
      for (final request in _allRequests) {
        for (final detail in request.details) {
          speciesIds.add(detail.snakeSpeciesId);
        }
      }
      
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🐍 Loading Snake Species Details');
      debugPrint('📊 Total unique species: ${speciesIds.length}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      // Load details for each species that's not in cache
      for (final speciesId in speciesIds) {
        if (!_speciesCache.containsKey(speciesId)) {
          try {
            final species = await repository.getSnakeSpeciesById(speciesId);
            if (species != null) {
              _speciesCache[speciesId] = species;
              debugPrint('✓ Loaded species $speciesId: ${species.commonName}');
            }
          } catch (e) {
            debugPrint('❌ Failed to load species $speciesId: $e');
          }
        }
      }
      
      if (mounted) {
        setState(() {}); // Trigger rebuild with loaded species data
      }
    } catch (e) {
      debugPrint('Error loading snake species details: $e');
    }
  }

  // Validate if coordinates are reasonable for Vietnam region
  bool _isValidCoordinate(LocationCoordinates location) {
    // Check if coordinates are within valid range
    if (location.latitude < -90 || location.latitude > 90) return false;
    if (location.longitude < -180 || location.longitude > 180) return false;
    
    // Filter out obvious placeholder/invalid values
    // Vietnam + nearby region: lat ~8-24, lng ~102-110
    // Allow broader range for neighboring countries
    if (location.latitude < 5 || location.latitude > 30) return false;
    if (location.longitude < 95 || location.longitude > 115) return false;
    
    return true;
  }

  double _calculateDistance(LocationCoordinates requestLocation) {
    if (_currentPosition == null) {
      debugPrint('⚠️ Cannot calculate distance: Current position is null');
      return 0.0;
    }
    
    // Validate coordinates before calculating
    if (!_isValidCoordinate(requestLocation)) {
      debugPrint('⚠️ Invalid coordinates: (${requestLocation.latitude}, ${requestLocation.longitude})');
      return double.infinity; // Return infinity for invalid coordinates
    }
    
    final distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      requestLocation.latitude,
      requestLocation.longitude,
    ) / 1000; // Convert to km
    
    return distance;
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }

  List<SnakeCatchingRequestData> _getFilteredRequests({String? statusFilter}) {
    List<SnakeCatchingRequestData> filtered = List.from(_allRequests);
    
    // Filter by status (tab)
    if (statusFilter == 'Pending') {
      // "Đơn có thể nhận": only Pending orders (not yet assigned)
      filtered = filtered.where((request) => request.status == 'Pending').toList();

      // Filter out requests with invalid coordinates
      filtered = filtered.where((request) =>
        _isValidCoordinate(request.locationCoordinates)
      ).toList();

      // Filter by distance for Pending tab
      double maxDistance = _selectedDistance == '10km' ? 10.0
          : _selectedDistance == '20km' ? 20.0
          : 30.0;

      if (_currentPosition != null) {
        filtered = filtered.where((request) {
          final distance = _calculateDistance(request.locationCoordinates);
          return distance <= maxDistance;
        }).toList();
      }

      // Sort
      switch (_selectedFilter) {
        case 'Gần nhất':
          if (_currentPosition != null) {
            filtered.sort((a, b) {
              final distanceA = _calculateDistance(a.locationCoordinates);
              final distanceB = _calculateDistance(b.locationCoordinates);
              return distanceA.compareTo(distanceB);
            });
          }
          break;
        case 'Mới nhất':
          filtered.sort((a, b) => b.requestDate.compareTo(a.requestDate));
          break;
      }
    } else if (statusFilter == 'Accepted') {
      // "Đơn đã nhận": filter from _allRequests by assignedRescuerId
      // (works once BE adds assignedRescuerId to the list endpoint)
      const activeStatuses = {'Assigned', 'Finished', 'Paid', 'Dispute', 'Completed'};
      filtered = filtered.where((request) =>
        activeStatuses.contains(request.status) &&
        request.assignedRescuerId != null &&
        request.assignedRescuerId == _currentRescuerId
      ).toList();
      filtered.sort((a, b) => b.requestDate.compareTo(a.requestDate));
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    // Sync _isOnline with real rescue mode state so _buildHeader() can read it
    final rescueModeState = ref.watch(rescueModeProvider);
    _isOnline = rescueModeState.isActive && rescueModeState.isConnected;

    return DefaultTabController(
      length: 2,
      child: Container(
        color: const Color(0xFFFFFBF5),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Tabs
              _buildTabBar(),

              // Filter Sort Options
              _buildFilterSortRow(),

              // Job List with TabBarView
              Expanded(
                child: TabBarView(
                  children: [
                    _buildAvailableJobsContent(statusFilter: 'Pending', isOnline: _isOnline),
                    _buildAvailableJobsContent(statusFilter: 'Accepted', isOnline: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        labelColor: const Color(0xFFFF6B35),
        unselectedLabelColor: const Color(0xFF666666),
        indicatorColor: const Color(0xFFFF6B35),
        indicatorWeight: 3,
        labelPadding: const EdgeInsets.symmetric(vertical: 12),
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Đơn có thể nhận'),
          Tab(text: 'Đơn đã nhận'),
        ],
      ),
    );
  }

  Widget _buildAvailableJobsContent({required String statusFilter, required bool isOnline}) {
    // Gate "Đơn có thể nhận" behind online status
    if (statusFilter == 'Pending' && !isOnline) {
      return _buildOfflineWall();
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF6B35),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Color(0xFFDC3545),
            ),
            const SizedBox(height: 16),
            Text(
              'Lỗi tải dữ liệu',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRequests,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final filteredRequests = _getFilteredRequests(statusFilter: statusFilter);
    
    if (filteredRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              statusFilter == 'Pending' 
                ? 'Không có đơn nào trong khu vực $_selectedDistance'
                : 'Bạn chưa nhận đơn nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return _buildJobListByDistance(filteredRequests);
  }

  Widget _buildOfflineWall() {
    final rescueModeState = ref.read(rescueModeProvider);
    final isConnecting = rescueModeState.isConnecting;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, size: 44, color: Color(0xFFFF6B35)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Bạn đang ngoại tuyến',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bật chế độ cứu hộ để xem và nhận các đơn trong khu vực của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isConnecting ? null : _toggleRescueMode,
                icon: isConnecting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.power_settings_new, size: 20),
                label: Text(
                  isConnecting ? 'Đang kết nối...' : 'Bật chế độ cứu hộ',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      color: Colors.white,
      child: Row(
        children: [
          const Text(
            'Nhiệm Vụ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          
          // Online Status Toggle - Compact
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: _isOnline ? const Color(0xFFFF6B35).withOpacity(0.1) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _isOnline ? const Color(0xFFFF6B35) : const Color(0xFF999999),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isOnline ? 'Trực tuyến' : 'Ngoại tuyến',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isOnline ? const Color(0xFFFF6B35) : const Color(0xFF999999),
                  ),
                ),
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: _isOnline,
                    onChanged: (_) => _toggleRescueMode(),
                    activeColor: const Color(0xFFFF6B35),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          
          // Menu Icon
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF666666), size: 20),
            onPressed: () {
              // TODO: Show menu
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSortRow() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE0E0E0).withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Distance filters
          Row(
            children: [
              const Text(
                'Khoảng cách:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(width: 12),
              ...[' 10km', '20km', '30km'].map((distance) {
                final isSelected = _selectedDistance == distance.trim();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDistance = distance.trim();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF28A745) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF28A745) : const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        distance.trim(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF666666),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: 8),
          // Sort filters
          Row(
            children: [
              const Text(
                'Sắp xếp:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(width: 12),
              ...['Gần nhất', 'Mới nhất'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFF6B35) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFF6B35) : const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF666666),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  
  Widget _buildJobListByDistance(List<SnakeCatchingRequestData> requests) {
    // Group by distance ranges
    Map<String, List<SnakeCatchingRequestData>> groupedRequests = {
      'GẦN BẠN (0-10KM)': [],
      'KHU VỰC (10-20KM)': [],
      'RỘNG (20-30KM)': [],
    };

    for (var request in requests) {
      final distance = _calculateDistance(request.locationCoordinates);
      if (distance <= 10) {
        groupedRequests['GẦN BẠN (0-10KM)']!.add(request);
      } else if (distance <= 20) {
        groupedRequests['KHU VỰC (10-20KM)']!.add(request);
      } else {
        groupedRequests['RỘNG (20-30KM)']!.add(request);
      }
    }

    // Remove empty groups
    groupedRequests.removeWhere((key, value) => value.isEmpty);

    return Column(
      children: [
        // Location error banner
        if (_locationErrorMessage != null)
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              border: Border.all(color: const Color(0xFFFFECB5)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_off,
                  color: Color(0xFF856404),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _locationErrorMessage!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF856404),
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Job list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: groupedRequests.keys.length,
            itemBuilder: (context, index) {
              final areaName = groupedRequests.keys.elementAt(index);
              final areaRequests = groupedRequests[areaName]!;
              final count = areaRequests.length;
              
              // Xác định màu cho từng khu vực
              Color areaColor;
              if (areaName.contains('GẦN BẠN')) {
                areaColor = const Color(0xFF28A745); // Xanh lá
              } else if (areaName.contains('KHU VỰC')) {
                areaColor = const Color(0xFFFFC107); // Vàng
              } else {
                areaColor = const Color(0xFFFF6B35); // Cam
              }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Area Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFFFFFBF5),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: areaColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: areaColor, width: 1.5),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: areaColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    areaName.split('(')[0].trim(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${areaName.split('(')[1]}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$count yêu cầu',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: areaColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // Job Cards
            ...areaRequests.map((request) => _buildJobCard(request)).toList(),
          ],
        );
      },
          ),
        ),
      ],
    );
  }
  
  // Helper function không cần nữa vì dùng DateTime từ API
  // int _parseTimeAgo(String timeAgo) {...}

  String _formatCurrency(double value) {
    final formatted = value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$formatted VNĐ';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFC107);
      case 'assigned':
        return const Color(0xFF2196F3);
      case 'preparing':
        return const Color(0xFFFFC107);
      case 'enroute':
        return const Color(0xFF9C27B0);
      case 'arrived':
        return const Color(0xFF00BCD4);
      case 'finished':
        return const Color(0xFF17A2B8);
      case 'missioncompleted':
        return const Color(0xFF17A2B8);
      case 'paid':
        return const Color(0xFF17A2B8);
      case 'completed':
        return const Color(0xFF28A745);
      case 'dispute':
        return const Color(0xFFDC3545);
      case 'cancelled':
      case 'expired':
        return const Color(0xFF999999);
      default:
        return const Color(0xFF999999);
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ xử lý';
      case 'assigned':
        return 'Đã nhận';
      case 'preparing':
        return 'Đang chuẩn bị';
      case 'enroute':
        return 'Đang di chuyển';
      case 'arrived':
        return 'Đã đến nơi';
      case 'finished':
        return 'Đã hoàn thành';
      case 'missioncompleted':
        return 'Đã hoàn thành';
      case 'paid':
        return 'Đã thanh toán';
      case 'completed':
        return 'Hoàn thành';
      case 'dispute':
        return 'Tranh chấp';
      case 'cancelled':
        return 'Đã hủy';
      case 'expired':
        return 'Hết hạn';
      default:
        return status;
    }
  }

  String _resolveDisplayStatus(SnakeCatchingRequestData request) {
    // Prefer cached mission data (fetched via detail API, since list API omits mission)
    final cachedMission = _missionCache[request.id];
    if (cachedMission != null && cachedMission.status.isNotEmpty) {
      return cachedMission.status;
    }
    // Fallback: mission embedded in list response (if BE ever includes it)
    final missionStatus = request.mission?.status;
    if (missionStatus != null && missionStatus.isNotEmpty) {
      return missionStatus;
    }
    return request.status;
  }

  Widget _buildJobCard(SnakeCatchingRequestData request) {
    final distance = _calculateDistance(request.locationCoordinates);
    final timeAgo = _getTimeAgo(request.requestDate);
    final speciesDetail = request.details.isNotEmpty ? request.details.first : null;
    final totalQuantity = request.details.fold<int>(0, (sum, detail) => sum + detail.quantity);
    
    // Get snake species details from cache
    SnakeSpecies? species;
    if (speciesDetail != null && _speciesCache.containsKey(speciesDetail.snakeSpeciesId)) {
      species = _speciesCache[speciesDetail.snakeSpeciesId];
    }
    
    final snakeTitle = species?.commonName ?? speciesDetail?.snakeSpeciesName ?? 'Rắn chưa xác định';
    
    // Get image from species (preferred) or user media
    String? imageUrl = species?.imageUrl;
    if (imageUrl == null && request.media.isNotEmpty) {
      imageUrl = request.media.first.url;
    }
    
    // Get danger level from species info
    String dangerBadge = 'CHƯA RÕ';
    Color dangerColor = const Color(0xFF999999);
    
    if (species != null) {
      if (species.isVenomous) {
        if (species.riskLevel >= 8.0) {
          dangerBadge = 'CỰC ĐỘC';
          dangerColor = const Color(0xFFDC3545); // Bright red
        } else if (species.riskLevel >= 6.0) {
          dangerBadge = 'ĐỘC MẠNH';
          dangerColor = const Color(0xFFFF6B35); // Orange red
        } else if (species.riskLevel >= 4.0) {
          dangerBadge = 'CÓ ĐỘC';
          dangerColor = const Color(0xFFFFA500); // Orange
        } else {
          dangerBadge = 'ÍT ĐỘC';
          dangerColor = const Color(0xFFFFC107); // Yellow
        }
      } else {
        dangerBadge = 'KHÔNG ĐỘC';
        dangerColor = const Color(0xFF28A745); // Green
      }
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với badges
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Distance Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF28A745),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.near_me, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '${distance.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                
                // Time Badge
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Color(0xFF999999)),
                    const SizedBox(width: 4),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                
                // Status Badge (for accepted orders)
                if (request.status != 'Pending') ...[
                  Builder(builder: (_) {
                    final displayStatus = _resolveDisplayStatus(request);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(displayStatus).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getStatusColor(displayStatus), width: 1),
                      ),
                      child: Text(
                        _getStatusText(displayStatus),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(displayStatus),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 4),
                ],

                // Priority Badge
                if (request.priority == 'High')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC3545).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.priority_high, size: 12, color: Color(0xFFDC3545)),
                        SizedBox(width: 2),
                        Text(
                          'KHẨN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDC3545),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Snake Image
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    color: const Color(0xFFF0F0F0),
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.image, size: 60, color: Color(0xFFCCCCCC)),
                              );
                            },
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported, size: 60, color: Color(0xFFCCCCCC)),
                                SizedBox(height: 8),
                                Text(
                                  'Chưa có ảnh',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF999999),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                
                // Danger Badge (show when we have species info)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: dangerColor,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          dangerBadge,
                          style: const TextStyle(
                            fontSize: 11,
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
          ),
          
          const SizedBox(height: 12),
          
          // Title & Quantity
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with Quantity
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        snakeTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'SL: ${totalQuantity.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Scientific name if available
                if (speciesDetail != null)
                  Text(
                    speciesDetail.snakeSpeciesScientificName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF999999),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Address
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.location_on, size: 18, color: Color(0xFFFF6B35)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request.address,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Additional Details (if any)
          if (request.additionalDetails != null && request.additionalDetails!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Color(0xFFFF6B35)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.additionalDetails!,
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
              ),
            ),
          
          const SizedBox(height: 12),
          
          // ── Deposit-paid banner (Assigned + CatchingDeposit) ──
          if (request.status == 'Assigned') ...[
            Builder(builder: (_) {
              final tx = _transactionCache[request.id];
              final depositPaid = tx != null && tx.isDeposited;
              if (!depositPaid) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B8F3A), Color(0xFF28A745)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF28A745).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Đã thanh toán phí di chuyển',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Sẵn sàng xuất phát · ${_formatCurrency(tx!.amount)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'SẴN SÀNG',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          // View Detail Button
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final missionStatus = _resolveDisplayStatus(request);
                  final mission = _missionCache[request.id] ?? request.mission;
                  if (missionStatus == 'EnRoute' && mission != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RescuerEnRouteScreen(
                          requestData: request,
                          missionId: mission.id,
                        ),
                      ),
                    );
                  } else if (missionStatus == 'Arrived' && mission != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RescuerTrackingScreen(
                          requestData: request,
                          missionId: mission.id,
                        ),
                      ),
                    );
                  } else if (missionStatus == 'Finished' || missionStatus == 'MissionCompleted' ||
                      missionStatus == 'Paid' || missionStatus == 'Completed' ||
                      request.status == 'Paid' || request.status == 'Completed' ||
                      request.status == 'Finished') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RescuerMissionSuccessScreen(
                          requestData: request,
                          missionId: mission?.id ?? request.id,
                        ),
                      ),
                    );
                  } else if (request.status == 'Assigned') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RescuerAcceptRequestScreen(
                          requestData: request,
                        ),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RescuerRequestDetailScreen(
                          requestId: request.id,
                          requestData: request,
                        ),
                        fullscreenDialog: false,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'XEM CHI TIẾT',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
