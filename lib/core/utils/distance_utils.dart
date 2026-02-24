import 'package:geolocator/geolocator.dart';

/// Utility functions for distance and ETA calculations
class DistanceUtils {
  /// Calculate distance between two coordinates using Haversine formula
  ///
  /// Returns distance in kilometers
  static double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    // Geolocator returns distance in meters
    final distanceInMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    return distanceInMeters / 1000; // Convert to kilometers
  }

  /// Estimate ETA (Estimated Time of Arrival) in minutes
  ///
  /// Uses rough estimation:
  /// - Urban area: ~20 km/h average (traffic, stops)
  /// - < 5km: 3 min/km
  /// - 5-15km: 2.5 min/km
  /// - > 15km: 2 min/km
  static int estimateETA(double distanceKm) {
    if (distanceKm < 0) return 0;

    if (distanceKm <= 5) {
      return (distanceKm * 3).ceil(); // 3 min/km for short distance
    } else if (distanceKm <= 15) {
      return (distanceKm * 2.5).ceil(); // 2.5 min/km for medium distance
    } else {
      return (distanceKm * 2).ceil(); // 2 min/km for long distance
    }
  }

  /// Format distance for display
  ///
  /// Examples:
  /// - "1.2 km"
  /// - "500 m" (if < 1km)
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      final meters = (distanceKm * 1000).round();
      return '$meters m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  /// Format ETA for display
  ///
  /// Examples:
  /// - "~5 phút"
  /// - "~1 giờ 15 phút"
  static String formatETA(int minutes) {
    if (minutes < 60) {
      return '~$minutes phút';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '~$hours giờ';
    }
    return '~$hours giờ $remainingMinutes phút';
  }

  /// Get color based on distance (for UI)
  ///
  /// - Green: < 5km (very close)
  /// - Blue: 5-10km (moderate)
  /// - Orange: 10-20km (far)
  /// - Red: > 20km (very far)
  static String getDistanceColorHex(double distanceKm) {
    if (distanceKm < 5) return '4CAF50'; // Green
    if (distanceKm < 10) return '2196F3'; // Blue
    if (distanceKm < 20) return 'FF9800'; // Orange
    return 'F44336'; // Red
  }
}
