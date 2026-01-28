import 'package:flutter/material.dart';
import 'dart:async';
import 'rescuer_sos_detail_screen.dart';
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
  bool _isExpanded = false;
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
          // Map Background with overlay gradient
          Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBLXTTBMslsflM1W9wf7x61aij5Sft34Xx8hJGwWASfVYWAiEO5VG8FlFs4PlCdc0jF5pFeMZBDxCk6WtiCzprlAri0zYmZB63jhZUfFx8k14Gq2SnswqFdB6SY_Mck623LS5OZoS1pWsXhoyiAvCXsyCW6a5p4C2ECoqNjhIFIWJZkxLQX9regEpnW6eoDj9aBUHazhUEYc7XW9cKDq7B7xftcae3UFAW5uo6vt2KNLBlx_3dmx4arOdOei29mEurn0yWv2N3HgTM',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                  stops: const [0.0, 0.15, 0.6, 1.0],
                ),
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

          // Top Status Bar - Modern Design
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  // Back button and SOS
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C100D), size: 20),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFDC3545), Color(0xFFC82333)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFDC3545).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'SOS',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Navigation status card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF8800), Color(0xFFFF6B35)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.navigation,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ĐANG TRÊN ĐƯỜNG',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1C100D),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '123 Nguyễn Huệ, Quận 1',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF666666),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Khoảng cách',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF999999),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_distance.toStringAsFixed(1)} km',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF8800),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 36,
                              color: const Color(0xFFE5E5E5),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Thời gian',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF999999),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$_estimatedTime phút',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1C100D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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

          // Right Side Controls - Modern floating style
          Positioned(
            right: 16,
            top: screenHeight * 0.5 - 80,
            child: Column(
              children: [
                // My Location Button
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {},
                      child: const Icon(
                        Icons.my_location,
                        color: Color(0xFF1C100D),
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Zoom Controls
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(28),
                              topRight: Radius.circular(28),
                            ),
                            onTap: () {},
                            child: const Icon(
                              Icons.add,
                              color: Color(0xFF1C100D),
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 1,
                        color: const Color(0xFFE5E5E5),
                      ),
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(28),
                              bottomRight: Radius.circular(28),
                            ),
                            onTap: () {},
                            child: const Icon(
                              Icons.remove,
                              color: Color(0xFF1C100D),
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Patient Info Sheet - Modern Card Design
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 24,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 14, bottom: 6),
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5E5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    child: Column(
                      children: [
                        // Patient Header
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF8800), Color(0xFFFF6B35)],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Nguyễn Văn A',
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1C100D),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDC3545),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.warning,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'NGUY KỊCH',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Action Buttons Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernActionButton(
                                Icons.call,
                                'Gọi',
                                const Color(0xFF28A745),
                                () {},
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildModernActionButton(
                                Icons.sms,
                                'Nhắn',
                                const Color(0xFF007AFF),
                                () {},
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildModernActionButton(
                                Icons.info_outline,
                                'Chi tiết',
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
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildModernActionButton(
                                Icons.close,
                                'Hủy',
                                const Color(0xFFDC3545),
                                () => _showCancelTripDialog(context),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Arrived Button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF28A745), Color(0xFF20C997)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF28A745).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _showArrivedConfirmation(context),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'ĐÃ ĐẾN NƠI',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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

  Widget _buildModernActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReasonOption(
                    'Không thể đến được địa điểm',
                    selectedReason,
                    (value) => setState(() => selectedReason = value),
                  ),
                  const SizedBox(height: 8),
                  _buildReasonOption(
                    'Bệnh nhân không liên lạc được',
                    selectedReason,
                    (value) => setState(() => selectedReason = value),
                  ),
                  const SizedBox(height: 8),
                  _buildReasonOption(
                    'Có việc khẩn cấp khác',
                    selectedReason,
                    (value) => setState(() => selectedReason = value),
                  ),
                  const SizedBox(height: 8),
                  _buildReasonOption(
                    'Tình trạng không nghiêm trọng',
                    selectedReason,
                    (value) => setState(() => selectedReason = value),
                  ),
                  const SizedBox(height: 8),
                  _buildReasonOption(
                    'Lý do khác',
                    selectedReason,
                    (value) => setState(() => selectedReason = value),
                  ),
                ],
              ),
            ),
          ],
          actions: [
            DialogAction(
              label: 'QUAY LẠI',
              onPressed: () => Navigator.pop(dialogContext),
              isOutlined: true,
              textColor: const Color(0xFF666666),
              borderColor: const Color(0xFFCCCCCC),
            ),
            DialogAction(
              label: 'XÁC NHẬN HỦY',
              onPressed: () {
                if (selectedReason != null) {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context); // Go back to previous screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã hủy chuyến: $selectedReason'),
                      backgroundColor: const Color(0xFFFF8800),
                    ),
                  );
                }
              },
              backgroundColor: selectedReason != null 
                  ? const Color(0xFFDC3545) 
                  : const Color(0xFFCCCCCC),
              icon: Icons.check,
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonOption(String reason, String? selectedReason, Function(String?) onChanged) {
    final isSelected = selectedReason == reason;
    return InkWell(
      onTap: () => onChanged(reason),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF8800).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF8800) : const Color(0xFFE5E5E5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? const Color(0xFFFF8800) : const Color(0xFFCCCCCC),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                reason,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? const Color(0xFF1C100D) : const Color(0xFF666666),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
      barrierDismissible: false,
      builder: (context) => CustomDialog(
        icon: Icons.check_circle_outline,
        iconBackgroundColor: const Color(0xFFE8F5E9),
        iconColor: const Color(0xFF28A745),
        title: 'Xác Nhận Đã Đến Nơi',
        description: 'Bạn đã đến vị trí của bệnh nhân và sẵn sàng hỗ trợ?',
        extraContent: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFFFF8800),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: const Text(
                    'Sau khi xác nhận, bệnh nhân sẽ nhận được thông báo',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        actions: [
          DialogAction(
            label: 'CHƯA ĐẾN',
            onPressed: () => Navigator.pop(context),
            isOutlined: true,
            textColor: const Color(0xFF666666),
            borderColor: const Color(0xFFCCCCCC),
          ),
          DialogAction(
            label: 'XÁC NHẬN',
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xác nhận đến nơi - Đang phát triển'),
                  backgroundColor: Color(0xFF28A745),
                ),
              );
            },
            backgroundColor: const Color(0xFF28A745),
            icon: Icons.check,
            flex: 2,
          ),
        ],
      ),
    );
  }
}
