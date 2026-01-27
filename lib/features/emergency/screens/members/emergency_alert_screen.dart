import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'snake_identification_screen.dart';

/// Emergency Alert Screen - Shows when user presses SOS button
/// Displays map, searching for rescuers, and safety instructions
class EmergencyAlertScreen extends StatefulWidget {
  const EmergencyAlertScreen({super.key});

  @override
  State<EmergencyAlertScreen> createState() => _EmergencyAlertScreenState();
}

class _EmergencyAlertScreenState extends State<EmergencyAlertScreen>
    with TickerProviderStateMixin {
  late AnimationController _radarController;
  late AnimationController _pulseController;
  int _countdown = 60;
  Timer? _countdownTimer;

  final List<RescuerMarker> _rescuers = [
    RescuerMarker(top: 0.30, left: 0.20),
    RescuerMarker(top: 0.60, right: 0.25),
    RescuerMarker(top: 0.15, right: 0.15, opacity: 0.7),
  ];

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _radarController.dispose();
    _pulseController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      body: Stack(
        children: [
          // Background Map
          Column(
            children: [
              // Top Navigation Bar
              Container(
                color: Colors.white,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.goNamed('member_home');
                            }
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'Cảnh báo khẩn cấp',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.goNamed('member_home');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Emergency Status Banner
              Container(
                color: const Color(0xFFDC3545),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Pulsing dot
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ScaleTransition(
                            scale: Tween<double>(begin: 1.0, end: 2.0).animate(
                              CurvedAnimation(
                                parent: _pulseController,
                                curve: Curves.easeOut,
                              ),
                            ),
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đang tìm đội cứu hộ gần bạn...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'GPS đã kích hoạt',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 14,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Map Section
              Expanded(
            child: Stack(
              children: [
                // Map Background
                Container(
                  color: const Color(0xFFE8F5E9),
                  child: Center(
                    child: Icon(
                      Icons.map,
                      size: 80,
                      color: const Color(0xFF228B22).withOpacity(0.2),
                    ),
                  ),
                ),

                // Radar circles
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF228B22).withOpacity(0.2),
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF228B22).withOpacity(0.3),
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Radar sweep
                      RotationTransition(
                        turns: _radarController,
                        child: CustomPaint(
                          size: const Size(250, 250),
                          painter: RadarSweepPainter(),
                        ),
                      ),
                      // User location
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ScaleTransition(
                            scale: Tween<double>(begin: 1.0, end: 1.5).animate(
                              CurvedAnimation(
                                parent: _pulseController,
                                curve: Curves.easeOut,
                              ),
                            ),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3).withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Rescuer pins
                ..._rescuers.map((rescuer) => _buildRescuerPin(rescuer)),

                // Map overlay info
                Positioned(
                  bottom: 70,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RotationTransition(
                            turns: _radarController,
                            child: const Icon(
                              Icons.sync,
                              color: Color(0xFF228B22),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Đang quét: 3 đội | Cách: 2.1 km',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Recenter button
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.my_location, size: 20),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
          ),
            ],
          ),

          // Bottom Sheet - Draggable
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.35,
            maxChildSize: 0.9,
            snap: true,
            snapSizes: const [0.35, 0.55, 0.9],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 24,
                      offset: const Offset(0, -8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Scrollable content with drag handle
                    ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.only(
                        top: 40,
                        left: 20,
                        right: 20,
                        bottom: 200,
                      ),
                      physics: const ClampingScrollPhysics(),
                      children: [
                        // Quick stats
                        _buildQuickStats(),
                        const SizedBox(height: 24),

                        // Rescuer status card
                        _buildRescuerStatusCard(),
                        const SizedBox(height: 24),

                        // Safety warnings
                        _buildSafetyWarnings(),
                        const SizedBox(height: 16),

                        // Success actions
                        _buildSuccessActions(),
                      ],
                    ),

                    // Drag handle at top
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Container(
                            width: 48,
                            height: 5,
                            decoration: BoxDecoration(
                              color: const Color(0xFFBDBDBD),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Sticky footer at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildStickyFooter(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRescuerPin(RescuerMarker rescuer) {
    return Positioned(
      top: rescuer.top != null
          ? MediaQuery.of(context).size.height * 0.4 * rescuer.top!
          : null,
      bottom: rescuer.bottom != null
          ? MediaQuery.of(context).size.height * 0.4 * rescuer.bottom!
          : null,
      left: rescuer.left != null
          ? MediaQuery.of(context).size.width * rescuer.left!
          : null,
      right: rescuer.right != null
          ? MediaQuery.of(context).size.width * rescuer.right!
          : null,
      child: Opacity(
        opacity: rescuer.opacity,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFFF9800),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.medical_services,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      child: const Row(
        children: [
          Text(
            '3 đội cứu hộ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(width: 12),
          CircleAvatar(
            radius: 2,
            backgroundColor: Color(0xFFBDBDBD),
          ),
          SizedBox(width: 12),
          Text(
            'Gần nhất: ',
            style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
          Text(
            '2.1km',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF228B22),
            ),
          ),
          SizedBox(width: 12),
          CircleAvatar(
            radius: 2,
            backgroundColor: Color(0xFFBDBDBD),
          ),
          SizedBox(width: 12),
          Text(
            'ETA: ',
            style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
          Text(
            '8 phút',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF9800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRescuerStatusCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TRẠNG THÁI KẾT NỐI',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF888888),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Progress bar
              Container(
                height: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(
                  value: _countdown / 60,
                  backgroundColor: const Color(0xFFE0E0E0),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFFC107),
                  ),
                ),
              ),

              // Rescuer info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF888888),
                          size: 28,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Text(
                            'WAIT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nguyễn Văn A',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Color(0xFFFFC107),
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '4.9',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '(156 đánh giá)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFFFFECB3),
                                ),
                              ),
                              child: const Text(
                                'Đang chờ phản hồi...',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFE65100),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '00:${_countdown.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF9800),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Đội cứu hộ có 60 giây để phản hồi yêu cầu của bạn',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF999999),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyWarnings() {
    final warnings = [
      {'icon': Icons.content_cut, 'text': 'Cắt\nvết thương'},
      {'icon': Icons.water_drop, 'text': 'Hút\nnọc độc'},
      {'icon': Icons.healing, 'text': 'Đắp\nbăng garo'},
      {'icon': Icons.local_bar, 'text': 'Uống\nrượu bia'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFECB3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning, color: Color(0xFFE65100), size: 20),
              SizedBox(width: 8),
              Text(
                'TUYỆT ĐỐI KHÔNG:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE65100),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: warnings.map((warning) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFECB3)),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              warning['icon'] as IconData,
                              color: const Color(0xFFDC3545),
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              warning['text'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: Text(
                          '✕',
                          style: TextStyle(
                            color: Color(0xFFDC3545),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessActions() {
    final actions = [
      {
        'number': '1',
        'title': 'Giữ bình tĩnh',
        'description': ' và hạn chế vận động tối đa.',
      },
      {
        'number': '2',
        'title': 'Cởi bỏ trang sức',
        'description': ', đồng hồ ở vùng bị cắn.',
      },
      {
        'number': '3',
        'title': 'Giữ vết cắn',
        'description': ' ở vị trí thấp hơn tim.',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified, color: Color(0xFF228B22), size: 20),
              SizedBox(width: 8),
              Text(
                'LÀM NGAY (TRONG LÚC CHỜ):',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF228B22),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...actions.map((action) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFC8E6C9),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        action['number']!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF228B22),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF333333),
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(
                            text: action['title'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: action['description']),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStickyFooter() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE0E0E0)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Waiting button (disabled)
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RotationTransition(
                        turns: _radarController,
                        child: const Icon(
                          Icons.refresh,
                          color: Color(0xFF999999),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Đang chờ phản hồi...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Instructions button
              OutlinedButton.icon(
                onPressed: () {
                  context.goNamed('snake_identification');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF228B22),
                  side: const BorderSide(
                    color: Color(0xFF228B22),
                    width: 2,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                icon: const Icon(Icons.camera_alt),
                label: const Text(
                  'Cung cấp ảnh rắn để xem hướng dẫn sơ cứu chi tiết',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),

              // Cancel button
              TextButton(
                onPressed: () {
                  _showCancelDialog();
                },
                child: const Text(
                  'Hủy yêu cầu',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF888888),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy yêu cầu cứu hộ?'),
        content: const Text(
          'Bạn có chắc muốn hủy yêu cầu cứu hộ khẩn cấp này không?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Tiếp tục chờ'),
          ),
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.goNamed('member_home'); // Go to member_home
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFDC3545),
            ),
            child: const Text('Hủy yêu cầu'),
          ),
        ],
      ),
    );
  }
}

// Radar sweep painter
class RadarSweepPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xFF228B22).withOpacity(0.0),
          const Color(0xFF228B22).withOpacity(0.1),
          const Color(0xFF228B22).withOpacity(0.4),
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2,
      ));

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Rescuer marker model
class RescuerMarker {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double opacity;

  RescuerMarker({
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.opacity = 1.0,
  });
}
