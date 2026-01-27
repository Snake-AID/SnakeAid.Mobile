import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/sos_button.dart';
import '../widgets/quick_action_buttons.dart';
import '../widgets/quick_action_cards.dart';
import '../widgets/secondary_menu_grid.dart';
import '../widgets/notification_bar.dart';
import '../widgets/education_section.dart';

/// Member Home Screen - Entry point with emergency-first design
/// This is a content-only widget, Scaffold is provided by MainScaffold
class MemberHomeScreen extends StatelessWidget {
  const MemberHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    child: SosButton(
                      onActivate: () => _showSosActivatedDialog(context),
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

  void _showSosActivatedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emergency, color: Color(0xFFDC3545), size: 32),
            SizedBox(width: 12),
            Text('SOS Đã Kích Hoạt!'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đang gửi cảnh báo khẩn cấp...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('• Đang xác định vị trí của bạn'),
            Text('• Đang tìm kiếm cứu hộ gần nhất'),
            Text('• Đang thông báo cho liên hệ khẩn cấp'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'HỦY SOS',
              style: TextStyle(
                color: Color(0xFFDC3545),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cứu hộ đang trên đường đến!'),
                  backgroundColor: Color(0xFF228B22),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF228B22),
            ),
            child: const Text('XEM CHI TIẾT'),
          ),
        ],
      ),
    );
  }
}
