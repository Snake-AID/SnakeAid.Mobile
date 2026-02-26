import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/http_provider.dart';
import '../../../core/services/livekit_service.dart';
import '../repository/video_call_repository.dart';

/// LiveKit service provider (singleton — manages room connection)
final liveKitServiceProvider = Provider<LiveKitService>((ref) {
  return LiveKitService();
});

/// Video call repository provider
final videoCallRepositoryProvider = Provider<VideoCallRepository>((ref) {
  return VideoCallRepository(ref.read(httpServiceProvider));
});
