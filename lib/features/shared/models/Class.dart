// Location data model matching backend
class UserLocationData {
  final String userId;
  final String userName;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  UserLocationData({
    required this.userId,
    required this.userName,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory UserLocationData.fromJson(Map<String, dynamic> json) {
    return UserLocationData(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

// Message data model
class MessageData {
  final String userId;
  final String userName;
  final String message;
  final DateTime timestamp;
  final String messageId;
  final bool isPrivate;

  MessageData({
    required this.userId,
    required this.userName,
    required this.message,
    required this.timestamp,
    required this.messageId,
    this.isPrivate = false,
  });

  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      messageId: json['messageId'] ?? '',
      isPrivate: json['isPrivate'] ?? false,
    );
  }
}

// SignalR connection state
enum UserConnectionState { disconnected, connecting, connected, reconnecting }
