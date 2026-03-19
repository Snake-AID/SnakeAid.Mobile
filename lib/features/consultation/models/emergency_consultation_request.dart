class EmergencyConsultationRequest {
  final String requestId;
  final String requesterId;
  final String expertId;
  final String status;
  final DateTime? requestedAt;
  final DateTime? expiresAt;
  final DateTime? respondedAt;
  final String? consultationId;
  final String? roomId;

  const EmergencyConsultationRequest({
    required this.requestId,
    required this.requesterId,
    required this.expertId,
    required this.status,
    this.requestedAt,
    this.expiresAt,
    this.respondedAt,
    this.consultationId,
    this.roomId,
  });

  factory EmergencyConsultationRequest.fromJson(Map<String, dynamic> json) {
    return EmergencyConsultationRequest(
      requestId: (json['requestId'] ?? '').toString(),
      requesterId: (json['requesterId'] ?? '').toString(),
      expertId: (json['expertId'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      requestedAt: json['requestedAt'] != null
          ? DateTime.tryParse(json['requestedAt'].toString())
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
      respondedAt: json['respondedAt'] != null
          ? DateTime.tryParse(json['respondedAt'].toString())
          : null,
      consultationId: json['consultationId']?.toString(),
      roomId: json['roomId']?.toString(),
    );
  }
}
