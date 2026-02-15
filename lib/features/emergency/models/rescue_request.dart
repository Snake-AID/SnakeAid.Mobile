import 'package:json_annotation/json_annotation.dart';

part 'rescue_request.g.dart';

/// Model for incoming rescue request from SignalR
/// Represents a mission opportunity for rescuer
/// Data received: RequestId, SessionId, IncidentId, RadiusKm, ExpiredAt, RequestSentAt
@JsonSerializable()
class RescueRequest {
  /// Request ID (from RescuerRequest table)
  @JsonKey(name: 'requestId')
  final String requestId;

  /// Session ID
  @JsonKey(name: 'sessionId')
  final String sessionId;

  /// Incident ID (SOS incident)
  @JsonKey(name: 'incidentId')
  final String incidentId;

  /// Current radius in km (10, 20, or 30)
  @JsonKey(name: 'radiusKm')
  final double radiusKm;

  /// Time when request was sent (UTC)
  @JsonKey(name: 'requestSentAt')
  final DateTime requestSentAt;

  /// Expiry time (60 seconds from sentAt) (UTC)
  @JsonKey(name: 'expiredAt')
  final DateTime expiredAt;

  RescueRequest({
    required this.requestId,
    required this.sessionId,
    required this.incidentId,
    required this.radiusKm,
    required this.requestSentAt,
    required this.expiredAt,
  });

  factory RescueRequest.fromJson(Map<String, dynamic> json) =>
      _$RescueRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RescueRequestToJson(this);

  /// Get remaining seconds until expiry (UTC-based calculation)
  int get remainingSeconds {
    final nowUtc = DateTime.now().toUtc(); // ✅ Convert to UTC

    // Ensure expiredAt is in UTC (should be from backend)
    final expiredUtc = expiredAt.isUtc ? expiredAt : expiredAt.toUtc();

    if (nowUtc.isAfter(expiredUtc)) return 0;

    final remaining = expiredUtc.difference(nowUtc).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// Check if request is still valid
  bool get isValid {
    return remainingSeconds > 0;
  }

  /// Format radius for display
  String get formattedRadius {
    return '${radiusKm.toInt()}km';
  }

  @override
  String toString() =>
      'RescueRequest(requestId: $requestId, incidentId: $incidentId, radius: $radiusKm)';
}

/// Response from accepting a rescue request
@JsonSerializable()
class AcceptRequestResponse {
  @JsonKey(name: 'isSuccess')
  final bool isSuccess;

  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'missionId')
  final String? missionId;

  @JsonKey(name: 'error')
  final String? error;

  AcceptRequestResponse({
    required this.isSuccess,
    required this.message,
    this.missionId,
    this.error,
  });

  factory AcceptRequestResponse.fromJson(Map<String, dynamic> json) =>
      _$AcceptRequestResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AcceptRequestResponseToJson(this);
}
