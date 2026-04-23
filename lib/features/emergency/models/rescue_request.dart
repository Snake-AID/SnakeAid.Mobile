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

  /// Expiry time (60 seconds from sentAt) (UTC).
  ///
  /// Deprecated in backend payload. If the backend does not provide
  /// `expiredAt`, the client derives expiry as `requestSentAt + requestTimeoutSeconds`.
  @Deprecated(
    'Backend no longer sends expiredAt. This field is kept for legacy compatibility.',
  )
  @JsonKey(name: 'expiredAt', includeIfNull: false)
  final DateTime? expiredAt;

  static const int requestTimeoutSeconds = 60;

  RescueRequest({
    required this.requestId,
    required this.sessionId,
    required this.incidentId,
    required this.radiusKm,
    required this.requestSentAt,
    this.expiredAt,
  });

  factory RescueRequest.fromJson(Map<String, dynamic> json) =>
      _$RescueRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RescueRequestToJson(this);

  DateTime get effectiveExpiredAt {
    if (expiredAt != null) {
      return expiredAt!.toUtc();
    }
    return requestSentAt.toUtc().add(
      const Duration(seconds: requestTimeoutSeconds),
    );
  }

  /// Get remaining seconds until expiry (UTC-based calculation)
  int get remainingSeconds {
    final nowUtc = DateTime.now().toUtc();
    final expiredUtc = effectiveExpiredAt;

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
/// Matches backend RequestAccepted event structure
@JsonSerializable()
class AcceptRequestResponse {
  @JsonKey(name: 'isSuccess')
  final bool isSuccess;

  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'requestId')
  final String? requestId;

  @JsonKey(name: 'incidentId')
  final String? incidentId;

  @JsonKey(name: 'missionId')
  final String? missionId;

  @JsonKey(name: 'acceptedAt')
  final DateTime? acceptedAt;

  @JsonKey(name: 'error')
  final String? error;

  AcceptRequestResponse({
    required this.isSuccess,
    required this.message,
    this.requestId,
    this.incidentId,
    this.missionId,
    this.acceptedAt,
    this.error,
  });

  factory AcceptRequestResponse.fromJson(Map<String, dynamic> json) =>
      _$AcceptRequestResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AcceptRequestResponseToJson(this);
}
