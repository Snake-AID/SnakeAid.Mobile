/// Refresh token request model
/// Model cho request làm mới access token
class RefreshTokenRequest {
  final String userId;
  final String refreshToken;

  RefreshTokenRequest({
    required this.userId,
    required this.refreshToken,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'refreshToken': refreshToken,
    };
  }

  @override
  String toString() => 'RefreshTokenRequest(userId: $userId)';
}
