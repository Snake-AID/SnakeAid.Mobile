import 'package:latlong2/latlong.dart';

/// Route step instruction
class RouteStep {
  final String instruction;
  final double distanceMeters;
  final double durationSeconds;
  final int type; // OpenRoute step type
  final String? roadName;
  final List<int> waypointIndices; // Indices in route polyline [start, end]
  final LatLng? maneuverLocation; // Location where turn happens

  const RouteStep({
    required this.instruction,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.type,
    this.roadName,
    this.waypointIndices = const [],
    this.maneuverLocation,
  });

  /// Get instruction icon based on OpenRouteService step type
  /// Type codes: https://openrouteservice.org/dev/#/api-docs/v2/directions/{profile}/post
  String get directionIcon {
    switch (type) {
      case 0:
        return '⬅️'; // Left
      case 1:
        return '➡️'; // Right
      case 2:
        return '↖️'; // Sharp left
      case 3:
        return '↗️'; // Sharp right
      case 4:
        return '↪️'; // Slight left
      case 5:
        return '↩️'; // Slight right
      case 6:
        return '⬆️'; // Straight / Continue
      case 7:
        return '🔄'; // Enter roundabout
      case 8:
        return '↗️'; // Exit roundabout
      case 9:
        return '↶'; // U-turn
      case 10:
        return '🎯'; // Goal / Arrive
      case 11:
        return '🚀'; // Depart / Start
      case 12:
        return '↰'; // Keep left
      case 13:
        return '↱'; // Keep right
      default:
        return '⬆️'; // Default: straight
    }
  }

  /// Formatted distance
  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '${distanceMeters.toStringAsFixed(0)}m';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(1)}km';
  }
}

/// Model for passing route data to navigation screen
/// Contains route polyline, metadata, and turn-by-turn instructions
class RouteNavigationData {
  final List<LatLng> points;
  final double distanceKm;
  final double durationMinutes;
  final List<RouteStep> steps; // Turn-by-turn instructions

  const RouteNavigationData({
    required this.points,
    required this.distanceKm,
    required this.durationMinutes,
    this.steps = const [],
  });

  /// Formatted distance string (e.g., "2.5km" or "850m")
  String get formattedDistance {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)}m';
    }
    return '${distanceKm.toStringAsFixed(1)}km';
  }

  /// Formatted duration string (e.g., "15 phút" or "1h 30p")
  String get formattedDuration {
    if (durationMinutes < 60) {
      return '${durationMinutes.toStringAsFixed(0)} phút';
    }
    final hours = durationMinutes ~/ 60;
    final mins = (durationMinutes % 60).toStringAsFixed(0);
    return '${hours}h ${mins}p';
  }

  /// Check if route is empty
  bool get isEmpty => points.isEmpty;

  /// Check if route is not empty
  bool get isNotEmpty => points.isNotEmpty;

  /// Get current instruction text (first step if available)
  String get currentInstruction {
    if (steps.isEmpty) return 'Vị trí nạn nhân';
    return steps.first.instruction;
  }

  /// Get current step distance
  String? get currentStepDistance {
    if (steps.isEmpty) return null;
    return steps.first.formattedDistance;
  }

  /// Convert to JSON for serialization (if needed)
  Map<String, dynamic> toJson() {
    return {
      'points': points
          .map((p) => {'lat': p.latitude, 'lng': p.longitude})
          .toList(),
      'distanceKm': distanceKm,
      'durationMinutes': durationMinutes,
      'steps': steps
          .map(
            (s) => {
              'instruction': s.instruction,
              'distanceMeters': s.distanceMeters,
              'durationSeconds': s.durationSeconds,
              'type': s.type,
              'roadName': s.roadName,
              'waypointIndices': s.waypointIndices,
              'maneuverLocation': s.maneuverLocation != null
                  ? {
                      'lat': s.maneuverLocation!.latitude,
                      'lng': s.maneuverLocation!.longitude,
                    }
                  : null,
            },
          )
          .toList(),
    };
  }

  /// Create from JSON (if needed)
  factory RouteNavigationData.fromJson(Map<String, dynamic> json) {
    final pointsList = json['points'] as List;
    final points = pointsList
        .map((p) => LatLng(p['lat'] as double, p['lng'] as double))
        .toList();

    final stepsList = json['steps'] as List? ?? [];
    final steps = stepsList
        .map(
          (s) => RouteStep(
            instruction: s['instruction'] as String,
            distanceMeters: (s['distanceMeters'] as num).toDouble(),
            durationSeconds: (s['durationSeconds'] as num).toDouble(),
            type: s['type'] as int,
            roadName: s['roadName'] as String?,
            waypointIndices:
                (s['waypointIndices'] as List?)
                    ?.map((i) => i as int)
                    .toList() ??
                [],
            maneuverLocation: s['maneuverLocation'] != null
                ? LatLng(
                    s['maneuverLocation']['lat'] as double,
                    s['maneuverLocation']['lng'] as double,
                  )
                : null,
          ),
        )
        .toList();

    return RouteNavigationData(
      points: points,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      durationMinutes: (json['durationMinutes'] as num).toDouble(),
      steps: steps,
    );
  }
}
