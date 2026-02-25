import 'package:flutter/material.dart';

/// Reusable call controls bar — bottom bar with mute/camera/end buttons
/// Designed to be reused in Operation 2's InCallScreen
class CallControls extends StatelessWidget {
  final bool isMicEnabled;
  final bool isCameraEnabled;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCamera;
  final VoidCallback onFlipCamera;
  final VoidCallback onEndCall;

  const CallControls({
    super.key,
    required this.isMicEnabled,
    required this.isCameraEnabled,
    required this.onToggleMic,
    required this.onToggleCamera,
    required this.onFlipCamera,
    required this.onEndCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Toggle microphone
            _ControlButton(
              icon: isMicEnabled ? Icons.mic : Icons.mic_off,
              label: isMicEnabled ? 'Mute' : 'Unmute',
              isActive: isMicEnabled,
              onPressed: onToggleMic,
            ),

            // Toggle camera
            _ControlButton(
              icon: isCameraEnabled ? Icons.videocam : Icons.videocam_off,
              label: isCameraEnabled ? 'Cam Off' : 'Cam On',
              isActive: isCameraEnabled,
              onPressed: onToggleCamera,
            ),

            // Flip camera
            _ControlButton(
              icon: Icons.flip_camera_ios,
              label: 'Flip',
              isActive: true,
              onPressed: onFlipCamera,
            ),

            // End call
            _ControlButton(
              icon: Icons.call_end,
              label: 'End',
              isActive: true,
              isDestructive: true,
              onPressed: onEndCall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDestructive;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.isActive,
    this.isDestructive = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDestructive
        ? Colors.red
        : isActive
        ? Colors.white24
        : Colors.red.withValues(alpha: 0.6);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: bgColor,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
