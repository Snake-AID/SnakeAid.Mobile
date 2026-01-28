import 'package:flutter/material.dart';
import 'dart:async';
import 'rescuer_sos_detail_screen.dart';
import 'rescuer_arrived_screen.dart';
import '../../shared/widgets/custom_dialog.dart';

class RescuerNavigationScreen extends StatefulWidget {
  const RescuerNavigationScreen({super.key});

  @override
  State<RescuerNavigationScreen> createState() => _RescuerNavigationScreenState();
}

class _RescuerNavigationScreenState extends State<RescuerNavigationScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bluePulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bluePulseAnimation;
  double _distance = 1.8;
  int _estimatedTime = 6;

  @override
  void initState() {
    super.initState();
    
    // Red pin pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Blue dot pulse animation
    _bluePulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _bluePulseAnimation = Tween<double>(begin: 1.0, end: 3.0).animate(
      CurvedAnimation(parent: _bluePulseController, curve: Curves.easeOut),
    );

    // Simulate distance and time updates
    _startSimulation();
  }

  void _startSimulation() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _distance > 0) {
        setState(() {
          _distance = (_distance - 0.1).clamp(0, 2.1);
          _estimatedTime = (_distance * 3.33).round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bluePulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: Stack(
        children: [
          // Map Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBLXTTBMslsflM1W9wf7x61aij5Sft34Xx8hJGwWASfVYWAiEO5VG8FlFs4PlCdc0jF5pFeMZBDxCk6WtiCzprlAri0zYmZB63jhZUfFx8k14Gq2SnswqFdB6SY_Mck623LS5OZoS1pWsXhoyiAvCXsyCW6a5p4C2ECoqNjhIFIWJZkxLQX9regEpnW6eoDj9aBUHazhUEYc7XW9cKDq7B7xftcae3UFAW5uo6vt2KNLBlx_3dmx4arOdOei29mEurn0yWv2N3HgTM',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Patient Location Marker (Red Pin with Pulse)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: MediaQuery.of(context).size.width * 0.5 - 24,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulse effect
                    Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC3545).withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Pin icon
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFFDC3545),
                      size: 48,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),

          // Rescuer Current Location (Blue Dot with Pulse)
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.35,
            left: MediaQuery.of(context).size.width * 0.5 - 8,
            child: AnimatedBuilder(
              animation: _bluePulseAnimation,
              builder: (context, child) {
                final scale = _bluePulseAnimation.value;
                final opacity = 1.0 - (_bluePulseAnimation.value - 1.0) / 2.0;
                
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulse
                    Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF007AFF).withOpacity(opacity.clamp(0.0, 1.0)),
                            width: 2,
                          ),
                          color: const Color(0xFF007AFF).withOpacity((0.3 * opacity).clamp(0.0, 1.0)),
                        ),
                      ),
                    ),
                    // Inner dot
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Top Bar - Simple Back and SOS
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        customBorder: const CircleBorder(),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC3545),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'SOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Info Bar - Minimal
          Positioned(
            top: 80,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.navigation,
                    color: Color(0xFFFF8800),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '123 Nguyễn Huệ, Quận 1',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C100D),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_distance.toStringAsFixed(1)} km • $_estimatedTime phút',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Side Controls
          Positioned(
            right: 16,
            top: screenHeight * 0.5 - 60,
            child: Column(
              children: [
                Container(
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
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      customBorder: const CircleBorder(),
                      child: const Icon(
                        Icons.my_location,
                        size: 20,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
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
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      customBorder: const CircleBorder(),
                      child: const Icon(
                        Icons.add,
                        size: 20,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Sheet - Compact Design
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 12),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        // Patient Info - One Line
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF8800),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nguyễn Văn A',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1C100D),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '⚠️ NGUY KỊCH • Rắn hổ mang',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFDC3545),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF28A745).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {},
                                  customBorder: const CircleBorder(),
                                  child: const Icon(
                                    Icons.call,
                                    color: Color(0xFF28A745),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 16),
                        
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF28A745),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF28A745).withOpacity(0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => _showArrivedConfirmation(context),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Đã đến nơi',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildCompactButton(
                              Icons.info_outline,
                              const Color(0xFF666666),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RescuerSosDetailScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildCompactButton(
                              Icons.close,
                              const Color(0xFFDC3545),
                              () => _showCancelTripDialog(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactButton(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),
      ),
    );
  }

  void _showCancelTripDialog(BuildContext context) {
    String? selectedReason;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (context, setState) => CustomDialog(
          icon: Icons.cancel_outlined,
          iconBackgroundColor: const Color(0xFFFFEBEE),
          iconColor: const Color(0xFFDC3545),
          title: 'Hủy Chuyến Cứu Hộ?',
          description: 'Vui lòng chọn lý do hủy chuyến để chúng tôi cải thiện dịch vụ',
          extraContent: [
            _buildReasonOption('Không thể đến địa điểm', 'location', selectedReason, setState),
            _buildReasonOption('Bệnh nhân không liên lạc được', 'contact', selectedReason, setState),
            _buildReasonOption('Có việc khẩn cấp khác', 'urgent', selectedReason, setState),
            _buildReasonOption('Tình trạng không nghiêm trọng', 'not_serious', selectedReason, setState),
            _buildReasonOption('Lý do khác', 'other', selectedReason, setState),
          ],
          actions: [
            DialogAction(
              label: 'Quay lại',
              isOutlined: true,
              onPressed: () => Navigator.pop(dialogContext),
            ),
            DialogAction(
              label: 'Xác nhận hủy',
              backgroundColor: selectedReason != null ? const Color(0xFFDC3545) : const Color(0xFFCCCCCC),
              onPressed: () {
                if (selectedReason != null) {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(this.context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonOption(String label, String value, String? selectedReason, StateSetter setState) {
    final isSelected = selectedReason == value;
    return InkWell(
      onTap: () => setState(() => selectedReason = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF8800).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF8800) : const Color(0xFFE5E5E5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF8800) : const Color(0xFFCCCCCC),
                  width: 2,
                ),
                color: isSelected ? const Color(0xFFFF8800) : Colors.white,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: const Color(0xFF1C100D),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showArrivedConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => CustomDialog(
        icon: Icons.check_circle,
        iconBackgroundColor: const Color(0xFFD4EDDA),
        iconColor: const Color(0xFF28A745),
        title: 'Xác Nhận Đã Đến Nơi?',
        description: 'Sau khi xác nhận, bệnh nhân sẽ được thông báo và bạn có thể bắt đầu hỗ trợ.',
        extraContent: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFE69C)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF856404), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Đảm bảo bạn đã ở đúng vị trí trước khi xác nhận',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF856404),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        actions: [
          DialogAction(
            label: 'Chưa đến',
            isOutlined: true,
            onPressed: () => Navigator.pop(dialogContext),
          ),
          DialogAction(
            label: 'Xác nhận',
            backgroundColor: const Color(0xFF28A745),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const RescuerArrivedScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
