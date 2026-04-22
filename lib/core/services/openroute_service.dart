import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../../features/emergency/models/route_navigation_data.dart';

/// OpenRouteService API integration for routing
/// Free tier: 2000 requests/day, 40 requests/minute
///
/// Uses dedicated Dio instance (not shared with backend httpService)
/// to avoid conflicts with token refresh interceptor
class OpenRouteService {
  final Dio _dio;

  // API key from .env file (not committed to Git)
  late final String _apiKey;

  OpenRouteService(this._dio) {
    _apiKey = dotenv.get('OPENROUTE_API_KEY', fallback: '');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🔑 OpenRouteService Initialization:');
    if (_apiKey.isEmpty) {
      debugPrint('❌ OPENROUTE_API_KEY is EMPTY!');
    } else {
      // Show first 10 and last 4 characters for debugging
      final maskedKey = _apiKey.length > 14
          ? '${_apiKey.substring(0, 10)}...${_apiKey.substring(_apiKey.length - 4)}'
          : _apiKey;
      debugPrint('✅ OPENROUTE_API_KEY loaded: $maskedKey');
      debugPrint('📏 Key length: ${_apiKey.length} characters');
    }
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  /// Get route from start to end location
  /// Returns polyline points and route summary (distance, duration)
  Future<RouteData> getRoute({
    required LatLng start,
    required LatLng end,
    String profile =
        'driving-car', // driving-car, foot-walking, cycling-regular
  }) async {
    try {
      // Debug: Log API key status before request
      final maskedKey = _apiKey.isEmpty
          ? 'EMPTY'
          : (_apiKey.length > 14
                ? '${_apiKey.substring(0, 10)}...${_apiKey.substring(_apiKey.length - 4)}'
                : _apiKey);
      debugPrint('🗺️ OpenRoute API Request with key: $maskedKey');

      final response = await _dio.post(
        '/v2/directions/$profile',
        data: {
          'coordinates': [
            [start.longitude, start.latitude], // OpenRoute uses [lng, lat]
            [end.longitude, end.latitude],
          ],
          // No need for geometry_format - response includes coordinates by default
        },
        options: Options(
          headers: {
            'Authorization': _apiKey,
            'Content-Type': 'application/json',
            'Accept':
                'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
          },
        ),
      );

      return RouteData.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw OpenRouteException('Rate limit exceeded. Please wait a moment.');
      } else if (e.response?.statusCode == 403) {
        throw OpenRouteException(
          'Invalid API key. Please check configuration.',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw OpenRouteException(
          'Connection timeout. Please check your internet.',
        );
      }
      throw OpenRouteException('Failed to get route: ${e.message}');
    } catch (e) {
      throw OpenRouteException('Unexpected error: $e');
    }
  }

  /// Get route with alternative routes (max 3)
  Future<List<RouteData>> getRouteWithAlternatives({
    required LatLng start,
    required LatLng end,
    int alternativeRoutes = 2,
  }) async {
    try {
      final response = await _dio.post(
        '/v2/directions/driving-car',
        data: {
          'coordinates': [
            [start.longitude, start.latitude],
            [end.longitude, end.latitude],
          ],
          'alternative_routes': {
            'target_count': alternativeRoutes,
            'weight_factor': 1.4,
            'share_factor': 0.6,
          },
          // No need for geometry_format - response includes coordinates by default
        },
        options: Options(
          headers: {
            'Authorization': _apiKey,
            'Content-Type': 'application/json',
            'Accept':
                'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
          },
        ),
      );

      // Parse routes array from JSON response
      final routes = response.data['routes'] as List;
      final polylinePoints = PolylinePoints();

      return routes.map((route) {
        final summary = route['summary'] as Map<String, dynamic>;

        // Geometry is an ENCODED POLYLINE STRING
        final geometryEncoded = route['geometry'] as String;
        final decodedPoints = polylinePoints.decodePolyline(geometryEncoded);

        // Convert PointLatLng to LatLng
        final points = decodedPoints
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        final distanceMeters = (summary['distance'] as num);
        final durationSeconds = (summary['duration'] as num);

        // Parse steps for alternative routes too
        final List<RouteStep> steps = [];
        if (route.containsKey('segments')) {
          final segments = route['segments'] as List;
          for (final segment in segments) {
            if (segment is Map<String, dynamic> &&
                segment.containsKey('steps')) {
              final segmentSteps = segment['steps'] as List;
              for (final step in segmentSteps) {
                if (step is Map<String, dynamic>) {
                  // Parse waypoint indices
                  final waypointIndices = <int>[];
                  if (step.containsKey('way_points')) {
                    final wayPoints = step['way_points'] as List;
                    waypointIndices.addAll(wayPoints.map((wp) => wp as int));
                  }

                  // Get maneuver location
                  LatLng? maneuverLocation;
                  if (waypointIndices.isNotEmpty &&
                      waypointIndices[0] < points.length) {
                    maneuverLocation = points[waypointIndices[0]];
                  }

                  steps.add(
                    RouteStep(
                      instruction:
                          step['instruction'] as String? ??
                          'Tiếp tục di chuyển',
                      distanceMeters:
                          (step['distance'] as num?)?.toDouble() ?? 0.0,
                      durationSeconds:
                          (step['duration'] as num?)?.toDouble() ?? 0.0,
                      type: step['type'] as int? ?? 7,
                      roadName: step['name'] as String?,
                      waypointIndices: waypointIndices,
                      maneuverLocation: maneuverLocation,
                    ),
                  );
                }
              }
            }
          }
        }

        return RouteData(
          points: points,
          distanceKm: distanceMeters / 1000,
          durationMinutes: durationSeconds / 60,
          steps: steps,
        );
      }).toList();
    } catch (e) {
      throw OpenRouteException('Failed to get alternative routes: $e');
    }
  }
}

/// Route data model
class RouteData {
  final List<LatLng> points;
  final double distanceKm;
  final double durationMinutes;
  final List<RouteStep> steps; // Turn-by-turn instructions

  RouteData({
    required this.points,
    required this.distanceKm,
    required this.durationMinutes,
    this.steps = const [],
  });

  factory RouteData.fromJson(Map<String, dynamic> json) {
    // OpenRouteService V2 JSON format
    // Response: { "routes": [ { "summary": {...}, "geometry": "encoded_string", "segments": [...] } ] }
    if (json.containsKey('routes')) {
      final routes = json['routes'] as List;
      if (routes.isEmpty) {
        throw Exception('No route found');
      }

      final route = routes[0] as Map<String, dynamic>;
      final summary = route['summary'] as Map<String, dynamic>;

      // Geometry is an ENCODED POLYLINE STRING, not coordinates array
      final geometryEncoded = route['geometry'] as String;

      // Decode polyline to list of points
      final polylinePoints = PolylinePoints();
      final decodedPoints = polylinePoints.decodePolyline(geometryEncoded);

      // Convert PointLatLng to LatLng
      final points = decodedPoints
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      final distanceMeters = (summary['distance'] as num?) ?? 0.0;
      final durationSeconds = (summary['duration'] as num?) ?? 0.0;

      debugPrint('✅ Decoded ${points.length} points from polyline');

      // Parse turn-by-turn instructions from segments/steps
      final List<RouteStep> steps = [];
      if (route.containsKey('segments')) {
        final segments = route['segments'] as List;
        for (final segment in segments) {
          if (segment is Map<String, dynamic> && segment.containsKey('steps')) {
            final segmentSteps = segment['steps'] as List;
            for (final step in segmentSteps) {
              if (step is Map<String, dynamic>) {
                // Parse waypoint indices [start_index, end_index] in polyline
                final waypointIndices = <int>[];
                if (step.containsKey('way_points')) {
                  final wayPoints = step['way_points'] as List;
                  waypointIndices.addAll(wayPoints.map((wp) => wp as int));
                }

                // Get maneuver location (first waypoint of this step)
                LatLng? maneuverLocation;
                if (waypointIndices.isNotEmpty &&
                    waypointIndices[0] < points.length) {
                  maneuverLocation = points[waypointIndices[0]];
                }

                steps.add(
                  RouteStep(
                    instruction:
                        step['instruction'] as String? ?? 'Tiếp tục di chuyển',
                    distanceMeters:
                        (step['distance'] as num?)?.toDouble() ?? 0.0,
                    durationSeconds:
                        (step['duration'] as num?)?.toDouble() ?? 0.0,
                    type: step['type'] as int? ?? 7, // Default: straight
                    roadName: step['name'] as String?,
                    waypointIndices: waypointIndices,
                    maneuverLocation: maneuverLocation,
                  ),
                );
              }
            }
          }
        }
      }

      debugPrint('✅ Parsed ${steps.length} turn-by-turn instructions');
      if (steps.isNotEmpty) {
        debugPrint('   First instruction: ${steps.first.instruction}');
      }

      return RouteData(
        points: points,
        distanceKm: distanceMeters / 1000,
        durationMinutes: durationSeconds / 60,
        steps: steps,
      );
    }

    // GeoJSON format (backward compatibility)
    // Response: { "features": [ { "geometry": {...}, "properties": {...} } ] }
    final features = json['features'] as List;
    if (features.isEmpty) {
      throw Exception('No route found');
    }

    final feature = features[0] as Map<String, dynamic>;
    return RouteData.fromFeatureJson(feature);
  }

  factory RouteData.fromFeatureJson(Map<String, dynamic> feature) {
    final geometry = feature['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List;

    // Convert [lng, lat] to LatLng
    final points = coordinates.map((coord) {
      final lng = coord[0] as double;
      final lat = coord[1] as double;
      return LatLng(lat, lng);
    }).toList();

    final properties = feature['properties'] as Map<String, dynamic>;
    final summary = properties['summary'] as Map<String, dynamic>;

    final distanceMeters = summary['distance'] as num;
    final durationSeconds = summary['duration'] as num;

    return RouteData(
      points: points,
      distanceKm: distanceMeters / 1000,
      durationMinutes: durationSeconds / 60,
      steps: const [], // GeoJSON format doesn't include steps
    );
  }

  String get formattedDistance {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)}m';
    }
    return '${distanceKm.toStringAsFixed(1)}km';
  }

  String get formattedDuration {
    if (durationMinutes < 60) {
      return '${durationMinutes.toStringAsFixed(0)} phút';
    }
    final hours = durationMinutes ~/ 60;
    final mins = (durationMinutes % 60).toStringAsFixed(0);
    return '${hours}h ${mins}p';
  }
}

/// Custom exception for OpenRouteService errors
class OpenRouteException implements Exception {
  final String message;
  OpenRouteException(this.message);

  @override
  String toString() => message;
}
