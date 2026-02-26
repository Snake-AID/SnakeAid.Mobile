import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

/// Reusable video tile widget — wraps VideoTrackRenderer with participant info
/// Designed to be reused in Operation 2's InCallScreen
class VideoTile extends StatelessWidget {
  final Participant participant;
  final bool isMirrored;
  final bool showInfo;

  const VideoTile({
    super.key,
    required this.participant,
    this.isMirrored = false,
    this.showInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    // Find the first video track (non-screen-share)
    final videoPublication = participant.videoTrackPublications
        .where((pub) => pub.source == TrackSource.camera && pub.subscribed)
        .firstOrNull;

    final videoTrack = videoPublication?.track as VideoTrack?;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: Colors.grey[900],
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video or placeholder
            if (videoTrack != null)
              IgnorePointer(
                child: VideoTrackRenderer(
                  videoTrack,
                  fit: VideoViewFit.cover,
                  mirrorMode: isMirrored
                      ? VideoViewMirrorMode.mirror
                      : VideoViewMirrorMode.off,
                ),
              )
            else
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam_off, color: Colors.white54, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      participant.identity.isNotEmpty
                          ? participant.identity
                          : 'Unknown',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

            // Participant info overlay
            if (showInfo)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        participant.identity.isNotEmpty
                            ? participant.identity
                            : 'Unknown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      if (participant.isMuted)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.mic_off,
                            color: Colors.redAccent,
                            size: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
