import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Nominatim Service - FREE OpenStreetMap Geocoding
class NominatimService {
  final Dio _dio;

  // Rate limiting: Track last request time
  static DateTime? _lastRequestTime;
  static const _minInterval = Duration(seconds: 1);

  NominatimService({Dio? dio}) : _dio = dio ?? Dio();

  /// Reverse geocoding: Convert coordinates to human-readable address
  Future<String?> reverseGeocode(double lat, double lon) async {
    try {
      await _enforceRateLimit();

      debugPrint('🗺️ Nominatim: Fetching address for ($lat, $lon)');

      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': lat.toStringAsFixed(6),
          'lon': lon.toStringAsFixed(6),
          'format': 'json',
          'addressdetails': 1,
          'accept-language': 'vi',
        },
        options: Options(
          headers: {
            'User-Agent':
                'SnakeAid/1.0 (Emergency Response App; Contact: admin@snakeaid.com)',
          },
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        // Option 1: Use display_name (full formatted address)
        if (data['display_name'] != null) {
          final displayName = data['display_name'] as String;
          debugPrint('✅ Nominatim: $displayName');
          return displayName;
        }

        // Option 2: Build custom format from address components
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final formatted = _formatAddress(address);
          debugPrint('✅ Nominatim: $formatted');
          return formatted;
        }

        debugPrint('⚠️ Nominatim: No address found');
        return null;
      }

      debugPrint('⚠️ Nominatim: Invalid response (${response.statusCode})');
      return null;
    } on DioException catch (e) {
      debugPrint('❌ Nominatim DioException: ${e.type}');
      debugPrint('   Message: ${e.message}');

      if (e.response?.statusCode == 429) {
        debugPrint('   ⚠️ Rate limit exceeded! Wait before retry.');
      }

      return null;
    } catch (e) {
      debugPrint('❌ Nominatim error: $e');
      return null;
    }
  }

  /// Format address from Nominatim components
  /// Priority: road → suburb → city → state → country
  String _formatAddress(Map<String, dynamic> address) {
    final parts = <String>[];

    // Street/Road level
    if (address['road'] != null) {
      parts.add(address['road'] as String);
    } else if (address['pedestrian'] != null) {
      parts.add(address['pedestrian'] as String);
    }

    // Neighborhood/Suburb
    if (address['suburb'] != null) {
      parts.add(address['suburb'] as String);
    } else if (address['neighbourhood'] != null) {
      parts.add(address['neighbourhood'] as String);
    } else if (address['quarter'] != null) {
      parts.add(address['quarter'] as String);
    }

    // District (Vietnam specific)
    if (address['city_district'] != null) {
      parts.add(address['city_district'] as String);
    }

    // City/Town
    if (address['city'] != null) {
      parts.add(address['city'] as String);
    } else if (address['town'] != null) {
      parts.add(address['town'] as String);
    } else if (address['municipality'] != null) {
      parts.add(address['municipality'] as String);
    }

    // State/Province
    if (address['state'] != null) {
      parts.add(address['state'] as String);
    } else if (address['province'] != null) {
      parts.add(address['province'] as String);
    }

    // Country
    if (address['country'] != null) {
      parts.add(address['country'] as String);
    }

    return parts.isNotEmpty ? parts.join(', ') : 'Địa chỉ không xác định';
  }

  /// Enforce rate limit: 1 request per second
  /// Waits if needed to respect Nominatim usage policy
  Future<void> _enforceRateLimit() async {
    if (_lastRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastRequestTime!);

      if (elapsed < _minInterval) {
        final waitTime = _minInterval - elapsed;
        debugPrint('⏳ Rate limit: Waiting ${waitTime.inMilliseconds}ms...');
        await Future.delayed(waitTime);
      }
    }

    _lastRequestTime = DateTime.now();
  }

  Future<List<NominatimPlace>> search(String query) async {
    try {
      await _enforceRateLimit();

      debugPrint('🔍 Nominatim: Searching for "$query"');

      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'addressdetails': 1,
          'limit': 5,
          'accept-language': 'vi',
        },
        options: Options(
          headers: {'User-Agent': 'SnakeAid/1.0 (Emergency Response App)'},
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        final results = (response.data as List)
            .map(
              (item) => NominatimPlace.fromJson(item as Map<String, dynamic>),
            )
            .toList();

        debugPrint('✅ Found ${results.length} results');
        return results;
      }

      return [];
    } catch (e) {
      debugPrint('❌ Search error: $e');
      return [];
    }
  }
}

/// Nominatim place result model
class NominatimPlace {
  final String displayName;
  final double lat;
  final double lon;
  final String? type;

  NominatimPlace({
    required this.displayName,
    required this.lat,
    required this.lon,
    this.type,
  });

  factory NominatimPlace.fromJson(Map<String, dynamic> json) {
    return NominatimPlace(
      displayName: json['display_name'] as String? ?? '',
      lat: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      lon: double.tryParse(json['lon']?.toString() ?? '0') ?? 0.0,
      type: json['type'] as String?,
    );
  }
}
