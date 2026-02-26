import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LocationPickerDialog extends StatefulWidget {
  final String? initialLocation;

  const LocationPickerDialog({
    super.key,
    this.initialLocation,
  });

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  final _searchController = TextEditingController();
  final _dio = Dio();
  
  List<LocationResult> _searchResults = [];
  bool _isSearching = false;
  bool _isGettingLocation = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _searchController.text = widget.initialLocation!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      List<LocationResult> results = [];
      
      // Try providers in priority order:
      // 1. Goong.io (Vietnamese service - best for VN addresses)
      // 2. Nominatim (OpenStreetMap - free, good crowdsourced data)
      // 3. MapTiler (fallback)
      
      // Try Goong.io first if API key is available
      final goongKey = dotenv.env['GOONG_API_KEY'];
      if (goongKey != null && goongKey.isNotEmpty) {
        try {
          results = await _searchGoong(query, goongKey);
          if (results.isNotEmpty) {
            print('✓ Using Goong.io results (${results.length} found)');
          }
        } catch (e) {
          print('Goong.io failed: $e');
        }
      }
      
      // If Goong didn't work or not configured, try Nominatim (OSM)
      if (results.isEmpty) {
        try {
          results = await _searchNominatim(query);
          if (results.isNotEmpty) {
            print('✓ Using Nominatim (OSM) results (${results.length} found)');
          }
        } catch (e) {
          print('Nominatim failed: $e');
        }
      }
      
      // If still no results, try MapTiler as fallback
      if (results.isEmpty) {
        final maptilerKey = dotenv.env['MAPTILER_API_KEY'];
        if (maptilerKey != null && maptilerKey.isNotEmpty) {
          try {
            results = await _searchMapTiler(query, maptilerKey);
            if (results.isNotEmpty) {
              print('✓ Using MapTiler results (${results.length} found)');
            }
          } catch (e) {
            print('MapTiler failed: $e');
          }
        }
      }
      
      // If user typed an address with house number but no exact matches found,
      // create a custom result
      if (results.isEmpty || !_hasHouseNumber(results.first)) {
        final customResult = _createCustomResultFromQuery(query);
        if (customResult != null) {
          results.insert(0, customResult);
          print('✓ Added custom result from user input');
        }
      }
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
        if (results.isEmpty) {
          _errorMessage = 'Không tìm thấy địa chỉ. Vui lòng thử lại với địa chỉ khác.';
        }
      });
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tìm kiếm địa chỉ: ${e.toString()}';
        _isSearching = false;
      });
    }
  }

  /// Search using Goong.io API (Vietnamese map service)
  Future<List<LocationResult>> _searchGoong(String query, String apiKey) async {
    final response = await _dio.get(
      'https://rsapi.goong.io/geocode',
      queryParameters: {
        'address': query,
        'api_key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final results = response.data['results'] as List? ?? [];
      
      if (results.isNotEmpty) {
        print('Goong.io response sample:');
        print('  formatted_address: ${results[0]['formatted_address']}');
        print('  compound: ${results[0]['compound']}');
      }
      
      return results.take(10).map<LocationResult>((result) {
        final compound = result['compound'] as Map<String, dynamic>? ?? {};
        final geometry = result['geometry'] as Map<String, dynamic>? ?? {};
        final location = geometry['location'] as Map<String, dynamic>? ?? {};
        final addressComponents = result['address_components'] as List? ?? [];
        
        // Extract house number from address components
        String? houseNumber;
        for (final component in addressComponents) {
          final types = component['types'] as List? ?? [];
          if (types.contains('street_number')) {
            houseNumber = component['long_name'] as String?;
            break;
          }
        }
        
        return LocationResult(
          houseNumber: houseNumber,
          streetName: compound['street'] as String? ?? '',
          district: compound['district'] as String? ?? '',
          city: compound['province'] as String? ?? '',
          region: null,
          country: 'Việt Nam',
          fullAddress: result['formatted_address'] as String? ?? '',
          latitude: location['lat'] as double? ?? 0.0,
          longitude: location['lng'] as double? ?? 0.0,
        );
      }).toList();
    }
    
    return [];
  }

  /// Search using Nominatim (OpenStreetMap)
  Future<List<LocationResult>> _searchNominatim(String query) async {
    final response = await _dio.get(
      'https://nominatim.openstreetmap.org/search',
      queryParameters: {
        'q': query,
        'format': 'json',
        'addressdetails': '1',
        'countrycodes': 'vn',
        'limit': '10',
        'accept-language': 'vi',
      },
      options: Options(
        headers: {
          'User-Agent': 'SnakeAid Mobile App', // Required by Nominatim
        },
      ),
    );

    if (response.statusCode == 200) {
      final results = response.data as List;
      
      if (results.isNotEmpty) {
        print('Nominatim response sample:');
        print('  display_name: ${results[0]['display_name']}');
        print('  house_number: ${results[0]['address']?['house_number']}');
        print('  road: ${results[0]['address']?['road']}');
      }
      
      return results.take(10).map<LocationResult>((result) {
        final address = result['address'] as Map<String, dynamic>? ?? {};
        
        return LocationResult(
          houseNumber: address['house_number'] as String?,
          streetName: address['road'] as String? ?? '',
          district: address['suburb'] as String? ?? address['municipality'] as String?,
          city: address['city'] as String? ?? address['province'] as String?,
          region: address['state'] as String?,
          country: address['country'] as String? ?? 'Việt Nam',
          fullAddress: result['display_name'] as String? ?? '',
          latitude: double.tryParse(result['lat'].toString()) ?? 0.0,
          longitude: double.tryParse(result['lon'].toString()) ?? 0.0,
        );
      }).toList();
    }
    
    return [];
  }

  /// Search using MapTiler (fallback)
  Future<List<LocationResult>> _searchMapTiler(String query, String apiKey) async {
    final response = await _dio.get(
      'https://api.maptiler.com/geocoding/$query.json',
      queryParameters: {
        'key': apiKey,
        'language': 'vi',
        'country': 'vn',
        'limit': 10,
        'types': 'address,street,place',
      },
    );

    if (response.statusCode == 200) {
      final features = response.data['features'] as List;
      
      if (features.isNotEmpty) {
        print('MapTiler response sample:');
        print('  place_name: ${features[0]['place_name']}');
        print('  address: ${features[0]['address']}');
      }
      
      return features.map<LocationResult>((feature) {
        return _parseMapTilerResult(feature);
      }).toList();
    }
    
    return [];
  }

  bool _hasHouseNumber(LocationResult result) {
    return result.houseNumber != null && result.houseNumber!.isNotEmpty;
  }

  LocationResult? _createCustomResultFromQuery(String query) {
    // Try to extract house number from query
    final numberMatch = RegExp(r'^(\d+[A-Za-z]?)\s+(.+)').firstMatch(query);
    if (numberMatch != null) {
      final houseNum = numberMatch.group(1)!;
      final streetPart = numberMatch.group(2)!;
      
      return LocationResult(
        houseNumber: houseNum,
        streetName: streetPart,
        district: null,
        city: 'Thành phố Hồ Chí Minh',
        region: null,
        country: 'Việt Nam',
        fullAddress: query,
        latitude: 10.7769, // Default to HCMC center
        longitude: 106.7009,
      );
    }
    
    return null;
  }

  LocationResult _parseMapTilerResult(Map<String, dynamic> feature) {
    // Extract basic info
    final text = feature['text'] as String? ?? '';
    final placeName = feature['place_name'] as String? ?? '';
    
    // Extract house number if available
    final houseNumber = feature['address'] as String? ?? '';
    
    // Extract context components (district, city, region, country)
    final context = feature['context'] as List? ?? [];
    String? district;
    String? city;
    String? region;
    String? country;
    
    for (final item in context) {
      final id = item['id'] as String? ?? '';
      final itemText = item['text'] as String? ?? '';
      
      if (id.startsWith('district')) {
        district = itemText;
      } else if (id.startsWith('place')) {
        city = itemText;
      } else if (id.startsWith('region')) {
        region = itemText;
      } else if (id.startsWith('country')) {
        country = itemText;
      }
    }
    
    return LocationResult(
      houseNumber: houseNumber.isEmpty ? null : houseNumber,
      streetName: text,
      district: district,
      city: city,
      region: region,
      country: country,
      fullAddress: placeName,
      latitude: feature['geometry']['coordinates'][1],
      longitude: feature['geometry']['coordinates'][0],
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _errorMessage = null;
    });

    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Quyền truy cập vị trí bị từ chối');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Quyền truy cập vị trí bị từ chối vĩnh viễn');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocoding with MapTiler
      await _reverseGeocode(position.latitude, position.longitude);

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isGettingLocation = false;
      });
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      LocationResult? locationResult;
      
      // Try providers in priority order for reverse geocoding
      
      // Try Goong.io first
      final goongKey = dotenv.env['GOONG_API_KEY'];
      if (goongKey != null && goongKey.isNotEmpty) {
        try {
          locationResult = await _reverseGeocodeGoong(lat, lng, goongKey);
          if (locationResult != null) {
            print('✓ Using Goong.io for reverse geocode');
          }
        } catch (e) {
          print('Goong.io reverse geocode failed: $e');
        }
      }
      
      // Try Nominatim if Goong failed
      if (locationResult == null) {
        try {
          locationResult = await _reverseGeocodeNominatim(lat, lng);
          if (locationResult != null) {
            print('✓ Using Nominatim for reverse geocode');
          }
        } catch (e) {
          print('Nominatim reverse geocode failed: $e');
        }
      }
      
      // Try MapTiler as fallback
      if (locationResult == null) {
        final maptilerKey = dotenv.env['MAPTILER_API_KEY'];
        if (maptilerKey != null && maptilerKey.isNotEmpty) {
          try {
            locationResult = await _reverseGeocodeMapTiler(lat, lng, maptilerKey);
            if (locationResult != null) {
              print('✓ Using MapTiler for reverse geocode');
            }
          } catch (e) {
            print('MapTiler reverse geocode failed: $e');
          }
        }
      }

      if (locationResult != null) {
        setState(() {
          _searchController.text = locationResult!.getFullAddress();
          _searchResults = [locationResult];
          _isGettingLocation = false;
        });
      } else {
        throw Exception('Không thể xác định địa chỉ');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi lấy địa chỉ: ${e.toString()}';
        _isGettingLocation = false;
      });
    }
  }

  Future<LocationResult?> _reverseGeocodeGoong(double lat, double lng, String apiKey) async {
    final response = await _dio.get(
      'https://rsapi.goong.io/geocode',
      queryParameters: {
        'latlng': '$lat,$lng',
        'api_key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final results = response.data['results'] as List? ?? [];
      if (results.isNotEmpty) {
        final result = results[0];
        final compound = result['compound'] as Map<String, dynamic>? ?? {};
        final geometry = result['geometry'] as Map<String, dynamic>? ?? {};
        final location = geometry['location'] as Map<String, dynamic>? ?? {};
        final addressComponents = result['address_components'] as List? ?? [];
        
        String? houseNumber;
        for (final component in addressComponents) {
          final types = component['types'] as List? ?? [];
          if (types.contains('street_number')) {
            houseNumber = component['long_name'] as String?;
            break;
          }
        }
        
        return LocationResult(
          houseNumber: houseNumber,
          streetName: compound['street'] as String? ?? '',
          district: compound['district'] as String? ?? '',
          city: compound['province'] as String? ?? '',
          region: null,
          country: 'Việt Nam',
          fullAddress: result['formatted_address'] as String? ?? '',
          latitude: location['lat'] as double? ?? lat,
          longitude: location['lng'] as double? ?? lng,
        );
      }
    }
    return null;
  }

  Future<LocationResult?> _reverseGeocodeNominatim(double lat, double lng) async {
    final response = await _dio.get(
      'https://nominatim.openstreetmap.org/reverse',
      queryParameters: {
        'lat': lat.toString(),
        'lon': lng.toString(),
        'format': 'json',
        'addressdetails': '1',
        'accept-language': 'vi',
      },
      options: Options(
        headers: {
          'User-Agent': 'SnakeAid Mobile App',
        },
      ),
    );

    if (response.statusCode == 200) {
      final address = response.data['address'] as Map<String, dynamic>? ?? {};
      
      return LocationResult(
        houseNumber: address['house_number'] as String?,
        streetName: address['road'] as String? ?? '',
        district: address['suburb'] as String? ?? address['municipality'] as String?,
        city: address['city'] as String? ?? address['province'] as String?,
        region: address['state'] as String?,
        country: address['country'] as String? ?? 'Việt Nam',
        fullAddress: response.data['display_name'] as String? ?? '',
        latitude: lat,
        longitude: lng,
      );
    }
    return null;
  }

  Future<LocationResult?> _reverseGeocodeMapTiler(double lat, double lng, String apiKey) async {
    final response = await _dio.get(
      'https://api.maptiler.com/geocoding/$lng,$lat.json',
      queryParameters: {
        'key': apiKey,
        'language': 'vi',
      },
    );

    if (response.statusCode == 200) {
      final features = response.data['features'] as List;
      if (features.isNotEmpty) {
        return _parseMapTilerResult(features[0]);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF228B22),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Chọn vị trí',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm địa chỉ...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchResults = [];
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      // Debounce search
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (_searchController.text == value) {
                          _searchLocation(value);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Get current location button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isGettingLocation ? null : _getCurrentLocation,
                      icon: _isGettingLocation
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.my_location),
                      label: Text(
                        _isGettingLocation
                            ? 'Đang lấy vị trí...'
                            : 'Lấy vị trí hiện tại',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Error message
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Results
            Expanded(
              child: _isSearching
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _searchResults.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_searching,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nhập địa chỉ cần tìm\nhoặc lấy vị trí hiện tại',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final result = _searchResults[index];
                            return ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Color(0xFF228B22),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                result.getPrimaryAddress(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                result.getSecondaryAddress(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                Navigator.of(context).pop(result);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationResult {
  final String? houseNumber;
  final String streetName;
  final String? district;
  final String? city;
  final String? region;
  final String? country;
  final String fullAddress;
  final double latitude;
  final double longitude;

  LocationResult({
    this.houseNumber,
    required this.streetName,
    this.district,
    this.city,
    this.region,
    this.country,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
  });

  // Get primary address line (house number + street + district)
  String getPrimaryAddress() {
    final parts = <String>[];
    
    if (houseNumber != null && houseNumber!.isNotEmpty) {
      parts.add(houseNumber!);
    }
    
    if (streetName.isNotEmpty) {
      parts.add(streetName);
    }
    
    return parts.isNotEmpty ? parts.join(' ') : fullAddress;
  }

  // Get secondary address line (district, city, region)
  String getSecondaryAddress() {
    final parts = <String>[];
    
    if (district != null && district!.isNotEmpty) {
      parts.add(district!);
    }
    
    if (city != null && city!.isNotEmpty) {
      parts.add(city!);
    }
    
    if (region != null && region!.isNotEmpty && region != city) {
      parts.add(region!);
    }
    
    return parts.isNotEmpty ? parts.join(', ') : fullAddress;
  }

  // Get full formatted address for display
  String getFullAddress() {
    final parts = <String>[];
    
    if (houseNumber != null && houseNumber!.isNotEmpty) {
      parts.add(houseNumber!);
    }
    
    if (streetName.isNotEmpty) {
      parts.add(streetName);
    }
    
    if (district != null && district!.isNotEmpty) {
      parts.add(district!);
    }
    
    if (city != null && city!.isNotEmpty) {
      parts.add(city!);
    }
    
    return parts.isNotEmpty ? parts.join(', ') : fullAddress;
  }

  @override
  String toString() => getFullAddress();
}
