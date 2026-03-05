import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:snakeaid_mobile/features/snake_catching/screens/rescuers/rescuer_accept_request_screen.dart';
import '../../models/snake_catching_request.dart';
import '../../repository/snake_catching_repository.dart';
import '../../repository/snake_species_repository.dart';
import '../../models/snake_species.dart';

/// Màn hình hiển thị chi tiết một yêu cầu cứu hộ
class RescuerRequestDetailScreen extends ConsumerStatefulWidget {
  final String requestId;
  final SnakeCatchingRequestData? requestData;
  
  const RescuerRequestDetailScreen({
    super.key,
    required this.requestId,
    this.requestData,
  });

  @override
  ConsumerState<RescuerRequestDetailScreen> createState() => _RescuerRequestDetailScreenState();
}

class _RescuerRequestDetailScreenState extends ConsumerState<RescuerRequestDetailScreen> {
  int _currentImageIndex = 0;
  final List<bool> _equipmentChecked = [false, false, false, false, false];
  
  bool _isLoading = false;
  String? _errorMessage;
  SnakeCatchingRequestData? _requestData;
  Position? _currentPosition;
  final Map<int, SnakeSpecies> _speciesCache = {};

  @override
  void initState() {
    super.initState();
    _requestData = widget.requestData;
    if (_requestData == null) {
      _loadRequestDetail();
    } else {
      _loadSnakeSpeciesDetails();
    }
    _getCurrentLocation();
  }

  Future<void> _loadRequestDetail() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(snakeCatchingRepositoryProvider);
      final response = await repository.getRequestById(widget.requestId);
      
      if (!mounted) return;
      
      if (response.isSuccess && response.data != null) {
        setState(() {
          _requestData = response.data;
          _isLoading = false;
        });
        _loadSnakeSpeciesDetails();
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

  List<String> _getImageUrls() {
    if (_requestData == null) return [];
    return _requestData!.media.map((m) => m.url).toList();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  bool _isValidCoordinate(LocationCoordinates location) {
    if (location.latitude < -90 || location.latitude > 90) return false;
    if (location.longitude < -180 || location.longitude > 180) return false;
    if (location.latitude < 5 || location.latitude > 30) return false;
    if (location.longitude < 95 || location.longitude > 115) return false;
    return true;
  }

  double _calculateDistance() {
    if (_requestData == null || _currentPosition == null) return 0.0;
    if (!_isValidCoordinate(_requestData!.locationCoordinates)) return 0.0;
    
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _requestData!.locationCoordinates.latitude,
      _requestData!.locationCoordinates.longitude,
    ) / 1000; // Convert to km
  }

  Future<void> _loadSnakeSpeciesDetails() async {
    if (_requestData == null || _requestData!.details.isEmpty) return;
    
    try {
      final repository = ref.read(snakeSpeciesRepositoryProvider);
      
      for (final detail in _requestData!.details) {
        if (!_speciesCache.containsKey(detail.snakeSpeciesId)) {
          try {
            final species = await repository.getSnakeSpeciesById(detail.snakeSpeciesId);
            if (species != null && mounted) {
              setState(() {
                _speciesCache[detail.snakeSpeciesId] = species;
              });
            }
          } catch (e) {
            debugPrint('Failed to load species ${detail.snakeSpeciesId}: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading snake species details: $e');
    }
  }

  Map<String, String?> _parseNotes() {
    if (_requestData?.notes == null) return {};
    
    final notes = _requestData!.notes!;
    final result = <String, String?>{};
    
    // Parse different patterns from notes
    final locationMatch = RegExp(r'Vị trí cụ thể:\s*(.+?)(?:,|$)', caseSensitive: false).firstMatch(notes);
    if (locationMatch != null) {
      result['location'] = locationMatch.group(1)?.trim();
    }
    
    final sizeMatch = RegExp(r'Kích thước ước tính:\s*(.+?)(?:,|$)', caseSensitive: false).firstMatch(notes);
    if (sizeMatch != null) {
      result['size'] = sizeMatch.group(1)?.trim();
    }
    
    final behaviorMatch = RegExp(r'Hành vi của rắn:\s*(.+?)(?:,|$)', caseSensitive: false).firstMatch(notes);
    if (behaviorMatch != null) {
      result['behavior'] = behaviorMatch.group(1)?.trim();
    }
    
    return result;
  }

  Color _getPriorityColor() {
    switch (_requestData?.priority.toLowerCase()) {
      case 'high':
      case 'urgent':
        return const Color(0xFFDC3545);
      case 'normal':
        return const Color(0xFFFFC107);
      case 'low':
        return const Color(0xFF28A745);
      default:
        return const Color(0xFF999999);
    }
  }

  String _getPriorityText() {
    switch (_requestData?.priority.toLowerCase()) {
      case 'high':
        return 'Cao';
      case 'urgent':
        return 'Khẩn cấp';
      case 'normal':
        return 'Bình thường';
      case 'low':
        return 'Thấp';
      default:
        return _requestData?.priority ?? 'Bình thường';
    }
  }

  Color _getStatusColor() {
    switch (_requestData?.status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFC107);
      case 'assigned':
        return const Color(0xFF2196F3);
      case 'finished':
        return const Color(0xFFFF6B35);
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

  String _getStatusText() {
    switch (_requestData?.status.toLowerCase()) {
      case 'pending':
        return 'Chờ xử lý';
      case 'assigned':
        return 'Đã phân công';
      case 'finished':
        return 'Đã bắt xong';
      case 'paid':
        return 'Đã thanh toán';
      case 'completed':
        return 'Hoàn thành';
      case 'dispute':
        return 'Đang tranh chấp';
      case 'cancelled':
        return 'Đã hủy';
      case 'expired':
        return 'Hết hạn';
      default:
        return _requestData?.status ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF6B35),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          title: const Text('Lỗi'),
          backgroundColor: const Color(0xFFF9F9F9),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: Color(0xFFDC3545),
              ),
              const SizedBox(height: 16),
              const Text(
                'Không thể tải chi tiết yêu cầu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                ),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_requestData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          title: const Text('Lỗi'),
          backgroundColor: const Color(0xFFF9F9F9),
        ),
        body: const Center(
          child: Text('Không có dữ liệu'),
        ),
      );
    }

    final images = _getImageUrls();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopBar(),
            
            // Main Content (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Priority and Distance Badges
                    _buildBadgesRow(),
                    
                    // Image Gallery
                    if (images.isNotEmpty) _buildImageGallery(images),
                    
                    // Snake Species Card (NEW)
                    if (_requestData!.details.isNotEmpty)
                      _buildSnakeSpeciesCard(),
                    
                    // Request Info Card (Enhanced)
                    _buildRequestInfoCard(),
                    
                    // Location Card
                    _buildLocationCard(),
                    
                    // User Info Card (Enhanced with rating)
                    _buildUserInfoCard(),
                    
                    // Parsed Notes Info (NEW)
                    if (_parseNotes().isNotEmpty)
                      _buildParsedNotesCard(),
                    
                    // Equipment Checklist Card
                    _buildEquipmentChecklistCard(),
                    
                    // Safety Guidelines
                    _buildSafetyGuidelinesCard(),
                    
                    // Raw Notes (if any additional info)
                    if (_requestData!.notes != null && _requestData!.notes!.isNotEmpty)
                      _buildNotesCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Sticky Footer Actions
      bottomSheet: _buildStickyFooter(),
    );
  }

  Widget _buildTopBar() {
    final timeAgo = _requestData != null 
        ? _getTimeAgo(_requestData!.requestDate)
        : '';
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFF9F9F9),
      child: Row(
        children: [
          // Back Button
          InkWell(
            onTap: () => context.pop(),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.arrow_back_ios_new, color: Color(0xFF333333)),
            ),
          ),
          
          // Title
          const Expanded(
            child: Text(
              'Chi Tiết Yêu Cầu',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ),
          
          // Time Ago
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFDC3545).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Color(0xFFDC3545), size: 16),
                const SizedBox(width: 4),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC3545),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}p trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h trước';
    } else {
      return '${difference.inDays}d trước';
    }
  }

  Widget _buildBadgesRow() {
    final distance = _calculateDistance();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Priority Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getPriorityColor().withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getPriorityColor(), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: _getPriorityColor(),
                ),
                const SizedBox(width: 4),
                Text(
                  _getPriorityText(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _getPriorityColor(),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getStatusColor(), width: 1.5),
            ),
            child: Text(
              _getStatusText(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(),
              ),
            ),
          ),
          
          const Spacer(),
          
          // Distance Badge
          if (_currentPosition != null && distance > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2196F3), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: Color(0xFF2196F3),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${distance.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSnakeSpeciesCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            const Text(
              'Thông Tin Rắn',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),
            
            ..._requestData!.details.map((detail) {
              final species = _speciesCache[detail.snakeSpeciesId];
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFBE0B)),
                ),
                child: Row(
                  children: [
                    // Snake Avatar
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFDDDDDD)),
                      ),
                      child: species?.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                species!.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported, color: Color(0xFF999999)),
                              ),
                            )
                          : const Icon(Icons.pets, color: Color(0xFF999999)),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Species Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail.snakeSpeciesName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            detail.snakeSpeciesScientificName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF666666),
                            ),
                          ),
                          if (species != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  species.isVenomous 
                                      ? Icons.warning_amber_rounded
                                      : Icons.info_outline,
                                  size: 16,
                                  color: species.isVenomous
                                      ? const Color(0xFFDC3545)
                                      : const Color(0xFF28A745),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  species.isVenomous ? 'Độc' : 'Không độc',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: species.isVenomous
                                        ? const Color(0xFFDC3545)
                                        : const Color(0xFF28A745),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Quantity
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'x${detail.quantity}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildParsedNotesCard() {
    final parsedNotes = _parseNotes();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            const Text(
              'Thông Tin Bổ Sung',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),
            
            if (parsedNotes['location'] != null)
              _buildInfoRow('Vị trí cụ thể', parsedNotes['location']!),
            
            if (parsedNotes['location'] != null && parsedNotes['size'] != null)
              const SizedBox(height: 12),
            
            if (parsedNotes['size'] != null)
              _buildInfoRow('Kích thước', parsedNotes['size']!),
            
            if (parsedNotes['size'] != null && parsedNotes['behavior'] != null)
              const SizedBox(height: 12),
            
            if (parsedNotes['behavior'] != null)
              _buildInfoRow('Hành vi', parsedNotes['behavior']!),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(List<String> images) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Image Gallery with PageView
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: double.infinity,
              height: 250,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.4),
                            ],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                        child: Image.network(
                          images[index],
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFF0F0F0),
                              child: const Center(
                                child: Icon(Icons.image, size: 60, color: Color(0xFFCCCCCC)),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  // Dots Indicator
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentImageIndex == index
                                ? const Color(0xFFFF6B35)
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
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

  Widget _buildRequestInfoCard() {
    final request = _requestData!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            const Text(
              'Thông Tin Yêu Cầu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),
            
            // Request Date
            _buildInfoRow(
              'Thời gian yêu cầu',
              DateFormat('dd/MM/yyyy HH:mm').format(request.requestDate),
            ),
            const SizedBox(height: 12),
            
            // Preferred Time
            if (request.preferredTime != null) ...[
              _buildInfoRow(
                'Thời gian',
                DateFormat('HH:mm').format(request.preferredTime!),
              ),
              const SizedBox(height: 12),
            ],
            
            // Estimated Price
            if (request.estimatedPrice != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 120,
                    child: Text(
                      'Chi phí ước tính',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${_formatCurrency(request.estimatedPrice!.toInt())} VNĐ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            
            // Request ID (for reference)
            _buildInfoRow('Mã yêu cầu', '#${request.id.substring(0, 8).toUpperCase()}'),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    final request = _requestData!;
    final user = request.user;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
                const Text(
                  'Thông Tin Khách Hàng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                // User Rating
                if (user != null && user.ratingCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Color(0xFFFFC107),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${user.rating.toStringAsFixed(1)} (${user.ratingCount})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFC107),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Name
            if (user?.account?.fullName != null) ...[
              _buildInfoRow('Họ tên', user!.account!.fullName!),
              const SizedBox(height: 12),
            ],
            
            // Emergency Contacts
            if (user?.emergencyContacts != null && user!.emergencyContacts.isNotEmpty) ...[
              const Text(
                'Liên hệ khẩn cấp',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                ),
              ),
              const SizedBox(height: 8),
              ...user.emergencyContacts.map((contact) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      size: 16,
                      color: Color(0xFFFF6B35),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      contact,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 12),
            ],
            
            // Health Warning
            if (user?.hasUnderlyingDisease == true)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC3545).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFDC3545),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Người dùng có bệnh nền, cần hỗ trợ khẩn cấp',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFDC3545),
                          fontWeight: FontWeight.w600,
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

  Widget _buildNotesCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9E6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFFBE0B),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.info_outline,
                  color: Color(0xFFFF6B35),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Ghi Chú Thêm',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _requestData!.notes!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF999999),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    final request = _requestData!;
    final address = request.address ?? 'Địa chỉ không xác định';
    final additionalDetails = request.additionalDetails;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vị Trí',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),
              
              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFFFF6B35),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF333333),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Additional Location Details
              if (additionalDetails != null && additionalDetails.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFFBE0B),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFFFF6B35),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          additionalDetails,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Directions Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Open map directions
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text(
                    'Chỉ Đường',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF6B35),
                    side: const BorderSide(color: Color(0xFFFF6B35), width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildSafetyGuidelinesCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    color: Color(0xFFFF6B35),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Hướng Dẫn An Toàn',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Checklist
            _buildSafetyItem('Mang găng tay dày'),
            _buildSafetyItem('Sử dụng móc bắt rắn chuyên dụng'),
            _buildSafetyItem('Giữ khoảng cách an toàn 2m'),
            _buildSafetyItem('Chuẩn bị túi vải dày'),
            
            const SizedBox(height: 12),
            
            // Full Guide Link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Show full guide
                },
                child: const Text(
                  'Xem hướng dẫn đầy đủ',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFFFF6B35),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentChecklistCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            const Text(
              'Thiết Bị Cần Thiết',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),
            _buildEquipmentItem(0, 'Móc bắt rắn (snake hook)'),
            _buildEquipmentItem(1, 'Găng tay bảo hộ'),
            _buildEquipmentItem(2, 'Túi vải/hộp đựng'),
            _buildEquipmentItem(3, 'Đèn pin'),
            _buildEquipmentItem(4, 'Phun nước (nếu cần)'),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentItem(int index, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: _equipmentChecked[index],
              onChanged: (value) {
                setState(() {
                  _equipmentChecked[index] = value ?? false;
                });
              },
              activeColor: const Color(0xFFFF6B35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Accept Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Accept request
                _showAcceptDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'CHẤP NHẬN YÊU CẦU',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAcceptDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn chấp nhận yêu cầu này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close confirmation dialog

              if (!mounted) return;

              // Capture navigator & messenger before any async gap
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              // Show loading dialog using the screen's context
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => const PopScope(
                  canPop: false,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
                  ),
                ),
              );

              try {
                final lat = _currentPosition?.latitude ?? 0.0;
                final lng = _currentPosition?.longitude ?? 0.0;

                final repository = ref.read(snakeCatchingRepositoryProvider);
                final response = await repository.acceptRequest(
                  _requestData!.id,
                  lat,
                  lng,
                );

                navigator.pop(); // Close loading dialog

                if (response.isSuccess && response.data != null) {
                  navigator.pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => RescuerAcceptRequestScreen(
                        requestData: response.data!,
                      ),
                    ),
                  );
                } else {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(response.message.isNotEmpty
                          ? response.message
                          : 'Không thể chấp nhận yêu cầu. Vui lòng thử lại.'),
                      backgroundColor: const Color(0xFFDC3545),
                    ),
                  );
                }
              } catch (e) {
                navigator.pop(); // Close loading dialog
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceFirst('Exception: ', '')),
                    backgroundColor: const Color(0xFFDC3545),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
