import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/sos_button.dart';
import '../widgets/quick_action_buttons.dart';
import '../../emergency/screens/members/emergency_alert_screen.dart';
import '../widgets/quick_action_cards.dart';
import '../widgets/secondary_menu_grid.dart';
import '../widgets/notification_bar.dart';
import '../widgets/education_section.dart';
import '../../shared/widgets/custom_dialog.dart';
import '../../emergency/repository/incident_repository.dart';
import '../../emergency/models/sos_incident_request.dart';
import '../../emergency/models/sos_incident_response.dart';
import '../../emergency/providers/incident_provider.dart';

/// Member Home Screen - Entry point with emergency-first design
/// This is a content-only widget, Scaffold is provided by MainScaffold
class MemberHomeScreen extends ConsumerWidget {
  const MemberHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch active incident state
    final activeIncidentState = ref.watch(activeIncidentProvider);
    final hasActiveIncident = activeIncidentState.hasActiveIncident;

    return Column(
      children: [
        // App Bar
        Container(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Text(
                    'SnakeAid',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF228B22),
                    ),
                  ),
                  const Spacer(),
                  
                  // Active SOS Indicator (if has active incident)
                  if (hasActiveIncident)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToActiveIncident(context, ref),
                        icon: const Icon(Icons.emergency, size: 16),
                        label: const Text(
                          'SOS Đang Hoạt Động',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC3545),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(0, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Thông báo - Đang phát triển'),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC3545),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // Content
        Expanded(
          child: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Emergency Area - SOS Button
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    child: SosButton(
                      onActivate: () {
                        final hasActiveIncident = ref.read(activeIncidentProvider).hasActiveIncident;
                        if (hasActiveIncident) {
                          _navigateToActiveIncident(context, ref);
                        } else {
                          _handleSosActivation(context, ref);
                        }
                      },
                    ),
                  ),

                  // Quick Action Buttons
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: QuickActionButtons(
                      onCameraPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Camera AI - Đang phát triển'),
                          ),
                        );
                      },
                      onCall115Pressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đang gọi 115 - Đang phát triển'),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Alert notification bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: NotificationBar(
                    message: 'Cảnh báo: Có 3 người gặp rắn độc trong khu vực của bạn trong 24h qua',
                    onViewDetails: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Chi tiết cảnh báo - Đang phát triển'),
                        ),
                      );
                    },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Quick Action Cards
                  QuickActionCards(
                    onFirstAidPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sơ cứu - Đang phát triển'),
                        ),
                      );
                    },
                    onHospitalPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng dùng tab Bệnh viện ở thanh điều hướng'),
                        ),
                      );
                    },
                    onTrackRescuerPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cứu hộ - Đang phát triển'),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Secondary Menu Grid
                  const SecondaryMenuGrid(),

                  const SizedBox(height: 24),

                  // Education Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: EducationSection(),
                  ),

                  const SizedBox(height: 24),

                  // Developer Tools Section (for testing)
                  Container(
                    color: Colors.grey[50],
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🛠️ Developer Tools',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => context.go('/signalr-test'),
                                icon: const Icon(Icons.chat),
                                label: const Text('SignalR Test'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => context.go('/location-tracker'),
                                icon: const Icon(Icons.location_on),
                                label: const Text('Location Tracker'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 90), // Space for bottom nav
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== HELPER FUNCTIONS ====================

/// Navigate to active incident screen
Future<void> _navigateToActiveIncident(BuildContext context, WidgetRef ref) async {
  final incident = ref.read(activeIncidentProvider).incident;
  
  if (incident == null) {
    _showErrorDialog(context, 'Không tìm thấy thông tin yêu cầu SOS');
    return;
  }

  // Show loading dialog while fetching latest incident data
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang tải thông tin SOS...'),
            ],
          ),
        ),
      ),
    ),
  );

  try {
    // Fetch latest incident data from server
    final repository = ref.read(incidentRepositoryProvider);
    final response = await repository.getIncident(incident.id);

    if (context.mounted) {
      context.pop(); // Close loading dialog
    }

    if (response.isSuccess && response.data != null) {
      // Update incident in provider with latest data
      await ref.read(activeIncidentProvider.notifier).saveActiveIncident(response.data!);

      if (context.mounted) {
        context.pushNamed(
          'emergency_alert',
          extra: {'incident': response.data!},
        );
      }
    } else {
      if (context.mounted) {
        _showErrorDialog(context, response.message);
      }
    }
  } catch (e) {
    if (context.mounted) {
      context.pop(); // Close loading dialog
      _showErrorDialog(context, 'Không thể tải thông tin SOS. ${e.toString().replaceAll('Exception: ', '')}');
    }
  }
}

/// Handle SOS button activation
Future<void> _handleSosActivation(BuildContext context, WidgetRef ref) async {
  // Show loading dialog while processing
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang kích hoạt SOS...'),
            ],
          ),
        ),
      ),
    ),
  );

  try {
    // 1. Get current location
    final position = await _getCurrentLocation();
    
    if (position == null) {
      if (context.mounted) {
        context.pop(); // Close loading dialog
        _showErrorDialog(context, 'Không thể lấy vị trí hiện tại. Vui lòng kiểm tra GPS.');
      }
      return;
    }

    // 2. Create SOS incident request
    final request = SosIncidentRequest(
      lng: position.longitude,
      lat: position.latitude,
    );

    // 3. Call API to create SOS incident
    final repository = ref.read(incidentRepositoryProvider);
    final response = await repository.createSosIncident(request);

    if (context.mounted) {
      context.pop(); // Close loading dialog
    }

    // 4. Check response
    if (response.isSuccess && response.data != null) {
      // Save incident to provider (auto saves to local storage)
      await ref.read(activeIncidentProvider.notifier).saveActiveIncident(response.data!);

      if (context.mounted) {
        // Show success dialog and navigate
        _showSosActivatedDialog(context, ref, response.data!);
      }
    } else {
      if (context.mounted) {
        _showErrorDialog(context, response.message);
      }
    }
  } catch (e) {
    if (context.mounted) {
      context.pop(); // Close loading dialog
      _showErrorDialog(context, e.toString().replaceAll('Exception: ', ''));
    }
  }
}

/// Get current location using Geolocator
Future<Position?> _getCurrentLocation() async {
  try {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('❌ Location services are disabled');
      return null;
    }

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('❌ Location permissions are denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('❌ Location permissions are permanently denied');
      return null;
    }

    // Get current position
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    debugPrint('✅ Location: ${position.latitude}, ${position.longitude}');
    return position;
  } catch (e) {
    debugPrint('❌ Error getting location: $e');
    return null;
  }
}

/// Show error dialog
void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.error_outline, color: Color(0xFFDC3545)),
          SizedBox(width: 8),
          Text('Lỗi'),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Đóng'),
        ),
      ],
    ),
  );
}

/// Show SOS activated dialog
void _showSosActivatedDialog(BuildContext context, WidgetRef ref, IncidentData incident) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => CustomDialog(
      icon: Icons.emergency,
      iconBackgroundColor: const Color(0xFFFFEBEE),
      iconColor: const Color(0xFFDC3545),
      title: 'SOS Đã Kích Hoạt!',
      description: 'Đang gửi cảnh báo khẩn cấp và tìm kiếm hỗ trợ gần bạn...',
      extraContent: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusItem(Icons.location_on, 'Đang xác định vị trí của bạn'),
              const SizedBox(height: 8),
              _buildStatusItem(Icons.local_hospital, 'Đang tìm kiếm cứu hộ gần nhất'),
              const SizedBox(height: 8),
              _buildStatusItem(Icons.contact_phone, 'Đang thông báo cho liên hệ khẩn cấp'),
            ],
          ),
        ),
      ],
      actions: [
        DialogAction(
          label: 'HỦY SOS',
          onPressed: () {
            if (Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
            }
          },
          isOutlined: true,
          textColor: const Color(0xFFDC3545),
          borderColor: const Color(0xFFDC3545),
        ),
        DialogAction(
          label: 'XEM CHI TIẾT',
          onPressed: () async {
            // Close dialog first
            if (Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
            }
            
            // Small delay to ensure dialog is closed
            await Future.delayed(const Duration(milliseconds: 100));
            
            // Navigate to emergency alert with incident data
            if (context.mounted) {
              context.pushNamed(
                'emergency_alert',
                extra: {'incident': incident},
              );
            }
          },
          backgroundColor: const Color(0xFF228B22),
          icon: Icons.arrow_forward,
          flex: 2,
        ),
      ],
    ),
  );
}

/// Build status item widget
Widget _buildStatusItem(IconData icon, String text) {
  return Row(
    children: [
      Icon(
        icon,
        size: 16,
        color: const Color(0xFF228B22),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF666666),
          ),
        ),
      ),
    ],
  );
}
