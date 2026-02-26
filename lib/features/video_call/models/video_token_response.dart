/// DTO for video token response from backend
/// Maps to backend's VideoTokenResponse
class VideoTokenResponse {
  final String token;
  final String wsUrl;
  final String roomName;

  VideoTokenResponse({
    required this.token,
    required this.wsUrl,
    required this.roomName,
  });

  factory VideoTokenResponse.fromJson(Map<String, dynamic> json) {
    return VideoTokenResponse(
      token: json['token'] as String,
      wsUrl: json['wsUrl'] as String,
      roomName: json['roomName'] as String,
    );
  }
}
