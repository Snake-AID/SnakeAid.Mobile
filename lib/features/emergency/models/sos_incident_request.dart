/// SOS Incident Request Model
/// Request model for creating emergency SOS incident
class SosIncidentRequest {
  final double lng; // Longitude (kinh độ)
  final double lat; // Latitude (vĩ độ)

  SosIncidentRequest({
    required this.lng,
    required this.lat,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() => {
    'lng': lng,
    'lat': lat,
  };

  @override
  String toString() => 'SosIncidentRequest(lng: $lng, lat: $lat)';
}
