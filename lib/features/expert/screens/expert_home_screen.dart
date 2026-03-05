import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'expert_profile_screen.dart';

/// Expert Home Screen - Dashboard for snake experts
class ExpertHomeScreen extends StatefulWidget {
  final int initialTab;
  const ExpertHomeScreen({super.key, this.initialTab = 0});

  @override
  State<ExpertHomeScreen> createState() => _ExpertHomeScreenState();
}

class _ExpertHomeScreenState extends State<ExpertHomeScreen> {
  late int _selectedIndex;
  final _consultationsKey = GlobalKey<_ConsultationsTabState>();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
  }

  void _goToConsultationHistory() {
    setState(() => _selectedIndex = 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _consultationsKey.currentState?._tabController.animateTo(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _HomeTab(onSeeAll: () => setState(() => _selectedIndex = 1)),
      _ConsultationsTab(key: _consultationsKey),
      const _IncomeTab(),
      _ProfileTab(onGoToHistory: _goToConsultationHistory),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home, 'Trang Chủ'),
                _buildNavItem(1, Icons.medical_services, 'Tư Vấn'),
                _buildNavItem(2, Icons.account_balance_wallet, 'Thu Nhập'),
                _buildNavItem(3, Icons.person, 'Cá Nhân'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? const Color(0xFF6C47C2) : const Color(0xFF999999);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
              weight: isSelected ? 700 : 400,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Home Tab
class _HomeTab extends StatefulWidget {
  final VoidCallback onSeeAll;
  const _HomeTab({required this.onSeeAll});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> with SingleTickerProviderStateMixin {
  bool _isAvailable = true;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // Instant consultation request popup
  bool _showInstantRequest = true;
  bool _isInstantMinimized = true;
  int _countdownSeconds = 120;
  Timer? _countdownTimer;

  static const _mockInstant = (
    patientName: 'Nguyễn Văn A',
    consultationType: 'Khẩn Cấp',
    durationMinutes: 45,
    consultationMethod: 'video',
    feeCost: 750000,
    snakeSuspect: 'Rắn Hổ Mang',
    id: 'instant-01',
  );

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _pulseController.repeat(reverse: true);
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_countdownSeconds <= 1) {
        _countdownTimer?.cancel();
        setState(() => _showInstantRequest = false);
      } else {
        setState(() => _countdownSeconds--);
      }
    });
  }

  void _acceptInstant() {
    _countdownTimer?.cancel();
    setState(() => _showInstantRequest = false);
    context.push(
      '/expert-video-waiting/${_mockInstant.id}',
      extra: {
        'patientName': _mockInstant.patientName,
        'consultationType': _mockInstant.consultationType,
        'feeCost': _mockInstant.feeCost,
      },
    );
  }

  void _declineInstant() {
    _countdownTimer?.cancel();
    setState(() => _showInstantRequest = false);
  }

  void _openDetailFromHome(BuildContext context, _ExpertConsultation c) {
    context.push('/expert-consultation-detail', extra: {
      'id': c.id,
      'patientName': c.patientName,
      'patientPhone': c.patientPhone,
      'consultationType': c.consultationType,
      'snakeSuspect': c.snakeSuspect,
      'scheduledTime': c.scheduledTime.millisecondsSinceEpoch,
      'statusIndex': c.status.index,
      'feeCost': c.feeCost,
      'rating': c.rating,
      'durationSeconds': c.durationSeconds,
      'durationMinutes': c.durationMinutes,
      'consultationMethod': c.consultationMethod,
      'problemDescription': c.problemDescription,
      'questions': c.questions,
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _showUrgentRequestBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _UrgentRequestSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: Row(
                children: [
                  Icon(Icons.pets, color: const Color(0xFF6C47C2), size: 32),
                  const SizedBox(width: 8),
                  const Text(
                    'SnakeAid Expert',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C47C2),
                    ),
                  ),
                ],
              ),
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications, color: Color(0xFF2D2D2D)),
                      onPressed: () {},
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFDC3545),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: const Text(
                          '3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF6C47C2).withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Container(
                        color: const Color(0xFF6C47C2).withOpacity(0.1),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF6C47C2),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Availability Toggle Card
                  _buildAvailabilityCard(),
                  const SizedBox(height: 20),

                  // Hero Earnings Card
                  _buildEarningsCard(),
                  const SizedBox(height: 20),

                  // Quick Stats Grid
                  _buildStatsGrid(),
                  const SizedBox(height: 24),

                  // Upcoming Consultations
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Lịch Tư Vấn Sắp Tới',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C47C2),
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onSeeAll,
                        child: const Text(
                          'Xem Tất Cả',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ..._upcomingConsultations.take(3).expand((c) {
                    final dt = c.scheduledTime;
                    final dateStr =
                        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} - ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                    return [
                      _buildConsultationCard(
                        name: c.patientName,
                        type: c.consultationType,
                        date: dateStr,
                        snake: c.snakeSuspect,
                        hasImage: c.hasSnakeImage,
                        onDetailTap: () => _openDetailFromHome(context, c),
                      ),
                      const SizedBox(height: 12),
                    ];
                  }),
                  const SizedBox(height: 88),
                ]),
              ),
            ),
          ],
        ),

        // Instant Consultation Minimized Bubble
        if (_showInstantRequest && _isInstantMinimized)
          Positioned(
            left: 16,
            bottom: 100,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: GestureDetector(
                    onTap: () => setState(() => _isInstantMinimized = false),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C47C2).withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 3,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C47C2), Color(0xFF9F7AEA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.video_call, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Người Dùng',
                                  style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Cần Tư Vấn Ngay  ${(_countdownSeconds ~/ 60).toString().padLeft(2, '0')}:${(_countdownSeconds % 60).toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.3),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        // Instant Consultation Full Popup (covers SOS button too)
        if (_showInstantRequest && !_isInstantMinimized)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF160D1B).withOpacity(0.8),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 40,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                            child: Column(
                              children: [
                                Container(
                                  width: 64, height: 64,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C47C2).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check_circle, size: 40, color: Color(0xFF6C47C2)),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Xác Nhận Bắt Đầu Tư Vấn',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6C47C2)),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF3CD),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.timer, size: 16, color: Color(0xFFD97706)),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Tự từ chối sau ${(_countdownSeconds ~/ 60).toString().padLeft(2, '0')}:${(_countdownSeconds % 60).toString().padLeft(2, '0')}',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                // Patient Info Card
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAF8FC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48, height: 48,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6C47C2).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.grey.shade200),
                                        ),
                                        child: const Icon(Icons.person, color: Color(0xFF6C47C2)),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(_mockInstant.patientName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF160D1B))),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Tư vấn ${_mockInstant.durationMinutes} phút · ${_mockInstant.consultationMethod == 'video' ? 'Video Call' : 'Nhắn Tin'}',
                                              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                                            ),
                                            Text(_mockInstant.snakeSuspect, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Payment Card
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFD1FAE5)),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Phí tư vấn', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF160D1B))),
                                          Text(
                                            '${(_mockInstant.feeCost ~/ 1000).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}K VNĐ',
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF160D1B)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF10B981),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.check, size: 12, color: Colors.white),
                                                SizedBox(width: 4),
                                                Text('Đã thanh toán', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(color: Color(0xFFD1FAE5), height: 20),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Bạn sẽ nhận', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF047857))),
                                              Text('(sau phí nền tảng 10%)', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                                            ],
                                          ),
                                          Text(
                                            '${((_mockInstant.feeCost * 0.9) ~/ 1000).toString()}K VNĐ',
                                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Action Buttons
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _acceptInstant,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6C47C2),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 4,
                                      shadowColor: const Color(0xFF6C47C2).withOpacity(0.4),
                                    ),
                                    child: const Text('Bắt Đầu Ngay', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: OutlinedButton(
                                    onPressed: () => setState(() => _isInstantMinimized = true),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.grey.shade300),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      foregroundColor: Colors.grey.shade600,
                                    ),
                                    child: const Text('Thu Nhỏ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: _declineInstant,
                                  child: const Text('Từ Chối', style: TextStyle(fontSize: 13, color: Color(0xFF999999))),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Floating SOS Alert Button (rendered before popups so popups can cover it)
        Positioned(
          right: 16,
          bottom: 100,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: GestureDetector(
                  onTap: () => _showUrgentRequestBottomSheet(context),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDC3545).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 3,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFDC3545), Color(0xFFC82333)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.sos,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Người Cứu Hộ',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Cần Hỗ Trợ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6C47C2).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _isAvailable ? const Color(0xFF28A745) : Colors.grey,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isAvailable ? const Color(0xFF28A745) : Colors.grey).withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TRẠNG THÁI',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF999999),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isAvailable ? 'Sẵn Sàng Nhận Tư Vấn' : 'Không Khả Dụng',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6C47C2),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch(
                value: _isAvailable,
                onChanged: (value) {
                  setState(() {
                    _isAvailable = value;
                  });
                },
                activeColor: const Color(0xFF6C47C2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(left: 12),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Color(0xFFF0F0F0),
                  width: 2,
                ),
              ),
            ),
            child: const Text(
              'Bạn sẽ nhận thông báo khi có yêu cầu khẩn cấp từ Rescuer',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_ExpertConsultation> get _upcomingConsultations {
    final now = DateTime.now();
    return _ConsultationsTabState._consultations.where((c) {
      return (c.status == _ExpertConsultationStatus.upcoming ||
              c.status == _ExpertConsultationStatus.waiting) &&
          !now.isAfter(c.scheduledTime.add(const Duration(minutes: 5)));
    }).toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  Widget _buildEarningsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C47C2), Color(0xFF9F7AEA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C47C2).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thu Nhập Tháng Này',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '12.5M',
                style: TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  'VNĐ',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white24,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.medical_services,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 6),
                const Text(
                  '18 Tư Vấn',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 1,
                  height: 16,
                  color: Colors.white30,
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.star,
                  color: Color(0xFFFFC107),
                  size: 18,
                ),
                const SizedBox(width: 6),
                const Text(
                  '4.8',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: Color(0xFF28A745),
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '+15%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF28A745),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildStatCard('Đang Chờ', '5', Icons.hourglass_top, const Color(0xFFFFC107)),
        _buildStatCard('Hoàn Thành', '3', Icons.check_circle, const Color(0xFF28A745)),
        _buildStatCard('Lịch Hẹn', '12', Icons.calendar_month, const Color(0xFF6C47C2)),
        _buildStatCard('Phản Hồi', '95%', Icons.thumb_up, const Color(0xFF6C47C2)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF999999),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationCard({
    required String name,
    required String type,
    required String date,
    required String snake,
    required bool hasImage,
    VoidCallback? onDetailTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(
            color: Color(0xFF6C47C2),
            width: 6,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C47C2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            type.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6C47C2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 14, color: Color(0xFF999999)),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Color(0xFF999999)),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F6F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: hasImage ? Colors.grey[200] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: hasImage
                      ? const Icon(Icons.dangerous, color: Color(0xFFDC3545), size: 24)
                      : const Icon(Icons.image_not_supported, color: Color(0xFF999999), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NGHI VẤN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF999999),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        snake,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton(
              onPressed: onDetailTap,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF6C47C2), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: const Color(0xFF6C47C2),
                overlayColor: const Color(0xFF6C47C2).withOpacity(0.1),
              ),
              child: const Text(
                'Xem Chi Tiết',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Consultations Tab ────────────────────────────────────────────────────────

enum _ExpertConsultationStatus { waiting, upcoming, completed, cancelled }

class _ExpertConsultation {
  final String id;
  final String patientName;
  final String patientPhone;
  final String consultationType;
  final String snakeSuspect;
  final bool hasSnakeImage;
  final DateTime scheduledTime;
  final _ExpertConsultationStatus status;
  final int feeCost;
  final double? rating;
  final int? durationSeconds;
  final int durationMinutes;
  final String consultationMethod; // 'video' | 'chat'
  final String? problemDescription;
  final String? questions;

  const _ExpertConsultation({
    required this.id,
    required this.patientName,
    this.patientPhone = '',
    required this.consultationType,
    required this.snakeSuspect,
    this.hasSnakeImage = false,
    required this.scheduledTime,
    required this.status,
    required this.feeCost,
    this.rating,
    this.durationSeconds,
    this.durationMinutes = 45,
    this.consultationMethod = 'video',
    this.problemDescription,
    this.questions,
  });
}

class _ConsultationsTab extends StatefulWidget {
  const _ConsultationsTab({super.key});

  @override
  State<_ConsultationsTab> createState() => _ConsultationsTabState();
}

class _ConsultationsTabState extends State<_ConsultationsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _selectedDay;
  late DateTime _weekStart; // Monday

  static const Color _purple = Color(0xFF6C47C2);

  static final _consultations = <_ExpertConsultation>[
    // ── Today ──
    _ExpertConsultation(
      id: 'c1',
      patientName: 'Trần Văn C',
      patientPhone: '0901 234 567',
      consultationType: 'Đặt Lịch',
      snakeSuspect: 'Rắn Hổ Mang Chúa',
      hasSnakeImage: true,
      scheduledTime: DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 9, 0),
      status: _ExpertConsultationStatus.upcoming,
      feeCost: 350000,
      durationMinutes: 45,
      consultationMethod: 'video',
      problemDescription:
          'Con rắn xuất hiện trong vườn nhà tôi, dài khoảng 1.5m, có phần cổ phồng to khi bị đe dọa. Tôi lo ngại đây là rắn cực độc.',
      questions: 'Tôi cần làm gì để đuổi rắn ra khỏi vườn an toàn? Có cần gọi đội chuyên nghiệp không?',
    ),
    _ExpertConsultation(
      id: 'c2',
      patientName: 'Nguyễn Thị D',
      patientPhone: '0912 345 678',
      consultationType: 'Tái Khám',
      snakeSuspect: 'Rắn Ráo Trâu',
      hasSnakeImage: true,
      scheduledTime: DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 11, 0),
      status: _ExpertConsultationStatus.upcoming,
      feeCost: 180000,
      durationMinutes: 30,
      consultationMethod: 'video',
      problemDescription:
          'Tôi thấy con rắn này bò qua sân nhà khoảng 3 lần trong tuần qua. Muốn xác định loài và mức độ nguy hiểm.',
      questions: 'Rắn này có độc không? Nó có xu hướng tấn công người không?',
    ),
    _ExpertConsultation(
      id: 'c3',
      patientName: 'Lê Văn E',
      patientPhone: '0923 456 789',
      consultationType: 'Khẩn Cấp',
      snakeSuspect: 'Rắn Lục',
      hasSnakeImage: true,
      scheduledTime: DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 14, 0),
      status: _ExpertConsultationStatus.waiting,
      feeCost: 350000,
      durationMinutes: 30,
      consultationMethod: 'chat',
      problemDescription:
          'Bị rắn cắn vào tay trái khoảng 15 phút trước. Có hai vết răng rõ ràng, vùng xung quanh đang sưng và đau nhức.',
    ),
    _ExpertConsultation(
      id: 'c4',
      patientName: 'Phạm Thị F',
      patientPhone: '0934 567 890',
      consultationType: 'Đặt Lịch',
      snakeSuspect: 'Rắn Hổ Mang',
      hasSnakeImage: false,
      scheduledTime: DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 16, 30),
      status: _ExpertConsultationStatus.upcoming,
      feeCost: 200000,
      durationMinutes: 45,
      consultationMethod: 'video',
      problemDescription:
          'Có rắn trong nhà tắm, không dám vào. Rắn màu đen, dài tầm 80cm.',
      questions: 'Làm sao để đuổi rắn ra khỏi nhà một cách an toàn?',
    ),
    _ExpertConsultation(
      id: 'c5',
      patientName: 'Hoàng Văn G',
      patientPhone: '0945 678 901',
      consultationType: 'Đặt Lịch',
      snakeSuspect: 'Rắn Đất',
      hasSnakeImage: true,
      scheduledTime: DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 19, 0),
      status: _ExpertConsultationStatus.upcoming,
      feeCost: 150000,
      durationMinutes: 30,
      consultationMethod: 'video',
      problemDescription:
          'Tìm thấy con rắn này dưới đống gạch trong vườn. Muốn biết loài và có nên giữ lại nuôi không.',
    ),
    // ── Tomorrow ──
    _ExpertConsultation(
      id: 'c6',
      patientName: 'Vũ Thị H',
      patientPhone: '0956 789 012',
      consultationType: 'Đặt Lịch',
      snakeSuspect: 'Rắn Lục Tre',
      hasSnakeImage: true,
      scheduledTime: DateTime.now().add(const Duration(days: 1))
          .copyWith(hour: 10, minute: 0, second: 0, millisecond: 0),
      status: _ExpertConsultationStatus.upcoming,
      feeCost: 200000,
      durationMinutes: 45,
      consultationMethod: 'video',
      problemDescription:
          'Con rắn xanh lá cây bắt được trong vườn, dài 60cm, đang nhốt trong hộp.',
      questions: 'Có nên thả ra hay liên hệ cơ quan nào để xử lý?',
    ),
    _ExpertConsultation(
      id: 'c7',
      patientName: 'Đỗ Văn I',
      patientPhone: '0967 890 123',
      consultationType: 'Tái Khám',
      snakeSuspect: 'Rắn Hổ Đất',
      hasSnakeImage: false,
      scheduledTime: DateTime.now().add(const Duration(days: 1))
          .copyWith(hour: 15, minute: 30, second: 0, millisecond: 0),
      status: _ExpertConsultationStatus.upcoming,
      feeCost: 180000,
      durationMinutes: 30,
      consultationMethod: 'video',
      problemDescription: 'Tái khám sau khi bị rắn cắn tuần trước, vết thương hồi phục chậm.',
    ),
    // ── Day after tomorrow ──
    _ExpertConsultation(
      id: 'c8',
      patientName: 'Bùi Thị K',
      patientPhone: '0978 901 234',
      consultationType: 'Đặt Lịch',
      snakeSuspect: 'Rắn Cạp Nong',
      hasSnakeImage: true,
      scheduledTime: DateTime.now().add(const Duration(days: 2))
          .copyWith(hour: 9, minute: 30, second: 0, millisecond: 0),
      status: _ExpertConsultationStatus.upcoming,
      feeCost: 350000,
      durationMinutes: 60,
      consultationMethod: 'video',
      problemDescription:
          'Phát hiện rắn sọc đen vàng trong nhà kho. Rất lo lắng vì có trẻ em trong nhà.',
      questions: 'Rắn cạp nong có độc mạnh không? Triệu chứng cắn thế nào?',
    ),
    // ── History ──
    _ExpertConsultation(
      id: 'h1',
      patientName: 'Phạm Đức D',
      patientPhone: '0901 111 222',
      consultationType: 'Đặt Lịch',
      snakeSuspect: 'Rắn Hổ Mang Thường',
      hasSnakeImage: true,
      scheduledTime: DateTime.now().subtract(const Duration(days: 1)),
      status: _ExpertConsultationStatus.completed,
      feeCost: 200000,
      durationSeconds: 2340,
      durationMinutes: 45,
      consultationMethod: 'video',
      rating: 5.0,
      problemDescription: 'Rắn trong sân vườn, chiều dài 1.2m.',
    ),
    _ExpertConsultation(
      id: 'h2',
      patientName: 'Hoàng Thị E',
      patientPhone: '0912 222 333',
      consultationType: 'Khẩn Cấp',
      snakeSuspect: 'Rắn Lục Tre',
      hasSnakeImage: true,
      scheduledTime: DateTime.now().subtract(const Duration(days: 3)),
      status: _ExpertConsultationStatus.completed,
      feeCost: 350000,
      durationSeconds: 1800,
      durationMinutes: 30,
      consultationMethod: 'video',
      rating: 4.5,
      problemDescription: 'Bị cắn vào ngón tay trong lúc làm vườn.',
    ),
    _ExpertConsultation(
      id: 'h3',
      patientName: 'Vũ Văn F',
      patientPhone: '0923 333 444',
      consultationType: 'Đặt Lịch',
      snakeSuspect: 'Chưa xác định',
      hasSnakeImage: false,
      scheduledTime: DateTime.now().subtract(const Duration(days: 5)),
      status: _ExpertConsultationStatus.cancelled,
      feeCost: 150000,
      durationMinutes: 30,
      consultationMethod: 'video',
    ),
  ];

  List<_ExpertConsultation> _consultationsForDay(DateTime day) {
    final now = DateTime.now();
    return _consultations.where((c) {
      final d = c.scheduledTime;
      if (!(d.year == day.year && d.month == day.month && d.day == day.day)) {
        return false;
      }
      if (c.status != _ExpertConsultationStatus.waiting &&
          c.status != _ExpertConsultationStatus.upcoming) {
        return false;
      }
      // Hide consultations whose time has passed by more than 5 minutes
      // (unless they are actively waiting)
      if (c.status != _ExpertConsultationStatus.waiting &&
          now.isAfter(c.scheduledTime.add(const Duration(minutes: 5)))) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  List<_ExpertConsultation> get _historyList => _consultations
      .where((c) =>
          c.status == _ExpertConsultationStatus.completed ||
          c.status == _ExpertConsultationStatus.cancelled)
      .toList()
    ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final today = DateTime.now();
    _selectedDay = DateTime(today.year, today.month, today.day);
    // Monday of current week
    final weekday = today.weekday; // 1=Mon
    _weekStart = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: weekday - 1));
    // Rebuild every minute so time-based logic stays current
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  // Navigate to detail screen
  void _openDetail(BuildContext context, _ExpertConsultation c) {
    context.push('/expert-consultation-detail', extra: {
      'id': c.id,
      'patientName': c.patientName,
      'patientPhone': c.patientPhone,
      'consultationType': c.consultationType,
      'snakeSuspect': c.snakeSuspect,
      'scheduledTime': c.scheduledTime.millisecondsSinceEpoch,
      'statusIndex': c.status.index,
      'feeCost': c.feeCost,
      'rating': c.rating,
      'durationSeconds': c.durationSeconds,
      'durationMinutes': c.durationMinutes,
      'consultationMethod': c.consultationMethod,
      'problemDescription': c.problemDescription,
      'questions': c.questions,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Lịch Tư Vấn',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF553C9A),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Color(0xFF553C9A)),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDay,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 60)),
                builder: (ctx, child) => Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: const ColorScheme.light(
                        primary: Color(0xFF6C47C2)),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                final day = DateTime(picked.year, picked.month, picked.day);
                setState(() {
                  _selectedDay = day;
                  final weekday = day.weekday;
                  _weekStart = day.subtract(Duration(days: weekday - 1));
                });
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: _purple,
          unselectedLabelColor: const Color(0xFF999999),
          indicatorColor: _purple,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [Tab(text: 'Lịch Tư Vấn'), Tab(text: 'Lịch Sử')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildScheduleTab(context), _buildHistoryTab(context)],
      ),
    );
  }

  // ── Schedule tab ──────────────────────────────────────────────────────────

  Widget _buildScheduleTab(BuildContext context) {
    final dayConsultations = _consultationsForDay(_selectedDay);
    final weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final today = DateTime.now();
    final todayNorm =
        DateTime(today.year, today.month, today.day);

    return Column(
      children: [
        // Week calendar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final day = _weekStart.add(Duration(days: i));
                final isSelected = day == _selectedDay;
                final isToday = day == todayNorm;
                final count = _consultationsForDay(day).length;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _purple
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? _purple : (isToday ? _purple.withOpacity(0.4) : const Color(0xFFE8E8E8)),
                        width: isToday && !isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _purple.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weekDays[i],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white70
                                : const Color(0xFF999999),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 8,
                          child: count > 0
                              ? Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? Colors.white
                                        : _purple,
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected
                                            ? Colors.white.withOpacity(0.8)
                                            : _purple.withOpacity(0.55),
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Date header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Row(
            children: [
              Text(
                _formatFullDate(_selectedDay),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF553C9A),
                ),
              ),
              const SizedBox(width: 10),
              if (dayConsultations.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.assignment,
                        size: 16, color: Color(0xFF6C47C2)),
                    const SizedBox(width: 4),
                    Text(
                      '${dayConsultations.length} Tư Vấn',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6C47C2),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // Consultation list
        Expanded(
          child: dayConsultations.isEmpty
              ? _buildEmptyDay()
              : _buildDayList(context, dayConsultations),
        ),
      ],
    );
  }

  Widget _buildEmptyDay() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_available,
              size: 56,
              color: _purple.withOpacity(0.25)),
          const SizedBox(height: 14),
          const Text(
            'Không có lịch tư vấn',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF999999),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayList(BuildContext context, List<_ExpertConsultation> list) {
    // Group by time of day
    final morning = list.where((c) => c.scheduledTime.hour < 12).toList();
    final afternoon = list.where((c) => c.scheduledTime.hour >= 12 && c.scheduledTime.hour < 17).toList();
    final evening = list.where((c) => c.scheduledTime.hour >= 17).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (morning.isNotEmpty) ...[
          _buildSectionHeader('BUỔI SÁNG'),
          ...morning.map((c) => _buildScheduleCard(context, c)),
        ],
        if (afternoon.isNotEmpty) ...[
          _buildSectionHeader('BUỔI CHIỀU'),
          ...afternoon.map((c) => _buildScheduleCard(context, c)),
        ],
        if (evening.isNotEmpty) ...[
          _buildSectionHeader('BUỔI TỐI'),
          ...evening.map((c) => _buildScheduleCard(context, c)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF999999),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, _ExpertConsultation c) {
    final now = DateTime.now();
    final isWaiting = c.status == _ExpertConsultationStatus.waiting;
    // Allow starting 2 minutes before the scheduled time
    final canStart = isWaiting ||
        !now.isBefore(c.scheduledTime.subtract(const Duration(minutes: 2)));
    final hour = c.scheduledTime.hour;
    final minute = c.scheduledTime.minute.toString().padLeft(2, '0');
    final amPm = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour.toString().padLeft(2, '0');

    // Status badge
    String statusLabel;
    Color statusBg;
    Color statusText;
    if (isWaiting) {
      statusLabel = 'ĐẾN GIỜ';
      statusBg = const Color(0xFFDC3545).withOpacity(0.1);
      statusText = const Color(0xFFDC3545);
    } else if (!canStart) {
      statusLabel = 'CHƯA ĐẾN GIỜ';
      statusBg = const Color(0xFFAAAAAA).withOpacity(0.12);
      statusText = const Color(0xFF999999);
    } else {
      statusLabel = 'SẮP TỚI';
      statusBg = _purple.withOpacity(0.1);
      statusText = _purple;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWaiting
              ? const Color(0xFFDC3545).withOpacity(0.25)
              : const Color(0xFFEEEEEE),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Time column
            Container(
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: const Color(0xFFF0F0F0), width: 1),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '$displayHour:$minute',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isWaiting ? const Color(0xFFDC3545) : _purple,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    amPm,
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF999999)),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: statusText,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                c.patientName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.pest_control,
                                      size: 14, color: Color(0xFF999999)),
                                  const SizedBox(width: 4),
                                  Text(
                                    c.snakeSuspect,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF555555),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Snake image placeholder
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: c.hasSnakeImage
                                ? const Color(0xFFDC3545).withOpacity(0.08)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: c.hasSnakeImage
                              ? const Icon(Icons.dangerous,
                                  color: Color(0xFFDC3545), size: 28)
                              : const Icon(Icons.image_not_supported,
                                  color: Color(0xFFCCCCCC), size: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Method + duration
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: c.consultationMethod == 'video'
                                ? _purple.withOpacity(0.08)
                                : Colors.green.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                c.consultationMethod == 'video'
                                    ? Icons.videocam
                                    : Icons.chat,
                                size: 14,
                                color: c.consultationMethod == 'video'
                                    ? _purple
                                    : Colors.green[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                c.consultationMethod == 'video'
                                    ? 'Video Call'
                                    : 'Chat',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: c.consultationMethod == 'video'
                                      ? _purple
                                      : Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${c.durationMinutes} phút',
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF999999),
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _openDetail(context, c),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xFF6C47C2), width: 1.2),
                              foregroundColor: _purple,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Chi Tiết',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: canStart
                                ? () {
                                    context.push(
                                      '/expert-video-waiting/${c.id}',
                                      extra: {
                                        'patientName': c.patientName,
                                        'consultationType': c.consultationType,
                                        'feeCost': c.feeCost,
                                      },
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isWaiting
                                  ? const Color(0xFFDC3545)
                                  : (canStart ? _purple : const Color(0xFFE0E0E0)),
                              foregroundColor:
                                  canStart ? Colors.white : const Color(0xFF999999),
                              disabledBackgroundColor: const Color(0xFFE8E8E8),
                              disabledForegroundColor: const Color(0xFF999999),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              isWaiting
                                  ? 'Vào Ngay'
                                  : (canStart ? 'Bắt Đầu' : 'Chưa Đến Giờ'),
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
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

  // ── History tab ───────────────────────────────────────────────────────────

  Widget _buildHistoryTab(BuildContext context) {
    final list = _historyList;
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history,
                size: 56, color: _purple.withOpacity(0.25)),
            const SizedBox(height: 14),
            const Text('Chưa có lịch sử tư vấn',
                style: TextStyle(fontSize: 15, color: Color(0xFF999999))),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _buildHistoryCard(context, list[i]),
    );
  }

  Widget _buildHistoryCard(BuildContext context, _ExpertConsultation item) {
    final isDone = item.status == _ExpertConsultationStatus.completed;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: isDone ? const Color(0xFF28A745) : const Color(0xFFAAAAAA),
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _purple.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Color(0xFF6C47C2), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.patientName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDone
                                ? const Color(0xFF28A745).withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isDone ? 'HOÀN THÀNH' : 'ĐÃ HỦY',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isDone
                                  ? const Color(0xFF28A745)
                                  : const Color(0xFF999999),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatFullDateTime(item.scheduledTime),
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF999999)),
                    ),
                  ],
                ),
              ),
              if (isDone)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '+${_formatFee(item.feeCost)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF28A745),
                      ),
                    ),
                    if (item.durationSeconds != null)
                      Text(
                        _formatDuration(item.durationSeconds!),
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF999999)),
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.pest_control, size: 13, color: Color(0xFF999999)),
              const SizedBox(width: 4),
              Text(
                item.snakeSuspect,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF666666)),
              ),
            ],
          ),
          if (isDone && item.rating != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(5, (i) {
                  final full = i < item.rating!.floor();
                  final half = !full && i < item.rating!;
                  return Icon(
                    full ? Icons.star : (half ? Icons.star_half : Icons.star_border),
                    size: 15,
                    color: const Color(0xFFFFC107),
                  );
                }),
                const SizedBox(width: 5),
                Text(
                  '${item.rating!.toStringAsFixed(1)} / 5.0',
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF999999)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton(
              onPressed: () => _openDetail(context, item),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF6C47C2), width: 1.2),
                foregroundColor: _purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Xem Chi Tiết',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatFullDate(DateTime d) {
    const months = [
      '', 'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    const days = ['', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'];
    return '${days[d.weekday]}, ${d.day} ${months[d.month]}, ${d.year}';
  }

  String _formatFullDateTime(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}'
      ' lúc ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _formatFee(int fee) {
    if (fee >= 1000000) return '${(fee / 1000000).toStringAsFixed(1)}M ₫';
    return '${(fee / 1000).toStringAsFixed(0)}K ₫';
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// ── Income Tab ────────────────────────────────────────────────────────────────

class _IncomeTransaction {
  final String id;
  final String patientName;
  final String consultationType;
  final DateTime date;
  final int amount;
  final bool isPending;

  const _IncomeTransaction({
    required this.id,
    required this.patientName,
    required this.consultationType,
    required this.date,
    required this.amount,
    this.isPending = false,
  });
}

class _IncomeTab extends StatefulWidget {
  const _IncomeTab();

  @override
  State<_IncomeTab> createState() => _IncomeTabState();
}

class _IncomeTabState extends State<_IncomeTab> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  final _transactions = [
    _IncomeTransaction(
      id: 't1',
      patientName: 'Phạm Đức D',
      consultationType: 'Đặt Lịch',
      date: DateTime(2025, 12, 10),
      amount: 200000,
    ),
    _IncomeTransaction(
      id: 't2',
      patientName: 'Hoàng Thị E',
      consultationType: 'Khẩn Cấp',
      date: DateTime(2025, 12, 8),
      amount: 350000,
    ),
    _IncomeTransaction(
      id: 't3',
      patientName: 'Lê Văn G',
      consultationType: 'Tái Khám',
      date: DateTime(2025, 12, 5),
      amount: 180000,
    ),
    _IncomeTransaction(
      id: 't4',
      patientName: 'Nguyễn Thị H',
      consultationType: 'Đặt Lịch',
      date: DateTime(2025, 12, 3),
      amount: 200000,
    ),
    _IncomeTransaction(
      id: 't5',
      patientName: 'Trần Văn I',
      consultationType: 'Khẩn Cấp',
      date: DateTime(2025, 12, 1),
      amount: 350000,
      isPending: true,
    ),
  ];

  int get _totalIncome => _transactions
      .where((t) => !t.isPending)
      .fold(0, (sum, t) => sum + t.amount);

  int get _pendingIncome => _transactions
      .where((t) => t.isPending)
      .fold(0, (sum, t) => sum + t.amount);

  String _formatAmount(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }
    return '${(amount / 1000).toStringAsFixed(0)}K';
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    const months = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
      'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
      'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Thu Nhập',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Monthly Summary Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C47C2), Color(0xFF9F7AEA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C47C2).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thu Nhập Đã Nhận',
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatAmount(_totalIncome),
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 6, left: 8),
                            child: Text('VNĐ',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white70)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.only(top: 16),
                        decoration: const BoxDecoration(
                          border: Border(
                              top: BorderSide(color: Colors.white24)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${_transactions.where((t) => !t.isPending).length} tư vấn hoàn thành',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.white),
                            ),
                            const Spacer(),
                            if (_pendingIncome > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.hourglass_top,
                                        color: Colors.white70, size: 13),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Chờ: ${_formatAmount(_pendingIncome)} ₫',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Month / Year filter
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month,
                          size: 18, color: Color(0xFF6C47C2)),
                      const SizedBox(width: 8),
                      const Text('Lọc theo tháng:',
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF666666))),
                      const Spacer(),
                      DropdownButton<int>(
                        value: _selectedMonth,
                        underline: const SizedBox(),
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6C47C2)),
                        items: List.generate(
                          12,
                          (i) => DropdownMenuItem(
                              value: i + 1, child: Text(months[i])),
                        ),
                        onChanged: (v) =>
                            setState(() => _selectedMonth = v!),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: _selectedYear,
                        underline: const SizedBox(),
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6C47C2)),
                        items: [2024, 2025, 2026]
                            .map((y) => DropdownMenuItem(
                                value: y, child: Text('$y')))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedYear = v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Transactions
                const Text(
                  'Lịch Sử Giao Dịch',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 10),
                ..._transactions.map(_buildTransactionItem),
                const SizedBox(height: 80),
              ],
            ),
          ),

          // Withdraw button
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Yêu cầu rút tiền - Đang phát triển')),
                  );
                },
                icon: const Icon(Icons.account_balance_wallet, size: 20),
                label: const Text(
                  'Yêu Cầu Rút Tiền',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C47C2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(_IncomeTransaction t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: t.isPending
                  ? const Color(0xFFFFC107).withOpacity(0.1)
                  : const Color(0xFF28A745).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              t.isPending ? Icons.hourglass_top : Icons.check_circle,
              size: 20,
              color: t.isPending
                  ? const Color(0xFFFFC107)
                  : const Color(0xFF28A745),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.patientName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C47C2).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        t.consultationType,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6C47C2),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(t.date),
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF999999)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${_formatAmount(t.amount)} ₫',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: t.isPending
                      ? const Color(0xFFFFC107)
                      : const Color(0xFF28A745),
                ),
              ),
              if (t.isPending)
                const Text('Đang xử lý',
                    style:
                        TextStyle(fontSize: 10, color: Color(0xFF999999))),
            ],
          ),
        ],
      ),
    );
  }
}

// Profile Tab - Wrapper for ExpertProfileScreen
class _ProfileTab extends StatelessWidget {
  final VoidCallback onGoToHistory;
  const _ProfileTab({required this.onGoToHistory});

  @override
  Widget build(BuildContext context) {
    return ExpertProfileScreen(onGoToHistory: onGoToHistory);
  }
}

// Urgent Request Bottom Sheet
class _UrgentRequestSheet extends StatelessWidget {
  const _UrgentRequestSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Urgent Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFDC3545),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                     child: Center(
                      child: Text(
                        'YÊU CẦU KHẨN CẤP',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Còn 2:45 phút',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRescuerCard(),
                  const SizedBox(height: 20),
                  _buildSnakeImageSection(),
                  const SizedBox(height: 20),
                  _buildMessageCard(),
                ],
              ),
            ),
          ),

          _buildFooterActions(context),
        ],
      ),
    );
  }

  Widget _buildRescuerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Đội Cứu Hộ Sài Gòn',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.verified,
                      color: Colors.blue[500],
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text(
                      '4.9',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFA500),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.star,
                      color: Color(0xFFFFA500),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '(234 đánh giá)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.only(left: 8),
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Color(0xFFDC3545),
                        width: 2,
                      ),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Color(0xFFDC3545)),
                          SizedBox(width: 4),
                          Text(
                            'Quận 1, TP.HCM',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Cách vị trí rắn 2.3 km',
                        style: TextStyle(
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
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFDC3545).withOpacity(0.2),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Container(
                color: const Color(0xFFDC3545).withOpacity(0.1),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFFDC3545),
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnakeImageSection() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(
                Icons.dangerous,
                size: 100,
                color: Color(0xFFDC3545),
              ),
            ),
          ),
          
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA500),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'AI: Rắn độc không xác định (45%)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.home_work, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Vườn nhà',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.nightlight, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Ban đêm',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
    );
  }

  Widget _buildMessageCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(
            color: Color(0xFFDC3545),
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.format_quote,
                color: const Color(0xFFDC3545).withOpacity(0.3),
                size: 32,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '"Rắn có vằn đen-vàng, đầu to hình tam giác. Tôi không chắc đây là loài gì. Cần xác nhận ngay!"',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F6F8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF0F0F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC3545),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(12, (index) {
                          final heights = [8.0, 16.0, 12.0, 20.0, 24.0, 12.0, 16.0, 8.0, 12.0, 8.0, 8.0, 8.0];
                          final isPlayed = index < 8;
                          return Container(
                            width: 3,
                            height: heights[index],
                            margin: const EdgeInsets.only(right: 2),
                            decoration: BoxDecoration(
                              color: isPlayed 
                                  ? const Color(0xFFDC3545) 
                                  : const Color(0xFFCCCCCC),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '0:12 • Tin nhắn thoại',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF999999),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.photo_library, size: 20),
                  label: const Text(
                    'Ảnh Khác (3)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF6C47C2)),
                    foregroundColor: const Color(0xFF6C47C2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.map, size: 20),
                  label: const Text(
                    'Bản Đồ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF6C47C2)),
                    foregroundColor: const Color(0xFF6C47C2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF28A745).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF28A745).withOpacity(0.2),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.monetization_on,
                  color: Color(0xFF28A745),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Bạn sẽ nhận 500K VNĐ cho tư vấn này',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF28A745),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF999999)),
                    foregroundColor: const Color(0xFF999999),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Từ Chối',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle, size: 22),
                  label: const Text(
                    'Chấp Nhận Ngay',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC3545),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
