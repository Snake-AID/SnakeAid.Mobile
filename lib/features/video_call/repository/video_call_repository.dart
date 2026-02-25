import '../../../core/services/http_service.dart';
import '../models/video_token_response.dart';

class VideoCallRepository {
  final HttpService _httpService;

  VideoCallRepository(this._httpService);

  /// [DEV] Fetch video token for testing with custom room name
  /// Bypasses consultation validation — accepts any room name string
  Future<VideoTokenResponse> getDemoVideoToken(String roomName) async {
    final response = await _httpService.post(
      '/api/videocall/livekit-token/demo/$roomName',
    );
    return VideoTokenResponse.fromJson(response.data['data']);
  }
}
