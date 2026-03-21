/// SOS Incident Request Model
/// Request model for creating emergency SOS incident
class SosIncidentRequest {
  final double lng; // Longitude (kinh độ)
  final double lat; // Latitude (vĩ độ)
  final String? address; // Địa chỉ đã reverse-geocode được

  SosIncidentRequest({required this.lng, required this.lat, this.address});

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() => {
    'lng': lng,
    'lat': lat,
    if (address != null) 'address': address,
  };

  @override
  String toString() =>
      'SosIncidentRequest(lng: $lng, lat: $lat, address: ${address ?? 'n/a'})';
}
