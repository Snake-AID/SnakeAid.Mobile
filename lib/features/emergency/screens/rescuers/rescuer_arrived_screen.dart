import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/first_aid_recommendation_response.dart';
import '../../models/detailed_incident_response.dart';
import '../../repository/snake_ai_repository.dart';
import '../../providers/mission_detail_provider.dart';
import '../../widgets/snake_risk_badges.dart';

class RescuerArrivedScreen extends ConsumerStatefulWidget {
  const RescuerArrivedScreen({super.key});

  @override
  ConsumerState<RescuerArrivedScreen> createState() =>
      _RescuerArrivedScreenState();
}

class _RescuerArrivedScreenState extends ConsumerState<RescuerArrivedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<bool> _checklist = [false, false, false, false];

  FirstAidRecommendationResponse? _firstAidRecommendation;
  bool _isLoadingFirstAid = true;
  String? _firstAidError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFirstAidGuideline();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFirstAidGuideline() async {
    // Get mission data first
    final missionData = ref.read(missionDetailProvider).mission;
    if (missionData == null) {
      setState(() {
        _isLoadingFirstAid = false;
        _firstAidError = 'Không tìm thấy thông tin nhiệm vụ';
      });
      return;
    }

    try {
      final repository = ref.read(snakeAiRepositoryProvider);
      final response = await repository.getFirstAidRecommendation(
        incidentId: missionData.incidentId,
      );

      setState(() {
        _firstAidRecommendation = response;
        _isLoadingFirstAid = false;
        _firstAidError = null;
      });
    } catch (e) {
      debugPrint('❌ Error loading first aid: $e');
      setState(() {
        _isLoadingFirstAid = false;
        _firstAidError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get mission data from provider
    final missionState = ref.watch(missionDetailProvider);
    final missionData = missionState.mission;

    // Show loading or error if no mission data
    if (missionData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F7F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F7F5),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1C100D)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Đã Đến Nơi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C100D),
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(child: Text('Không tìm thấy thông tin nhiệm vụ')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C100D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Đã Đến Nơi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C100D),
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFF8800),
          unselectedLabelColor: const Color(0xFF666666),
          indicatorColor: const Color(0xFFFF8800),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Tổng Quan'),
            Tab(text: 'Sơ Cứu'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOverviewTab(), _buildFirstAidTab()],
      ),
    );
  }

  // ─── OVERVIEW TAB ─────────────────────────────────────────────────────────

  Widget _buildOverviewTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Proximity Confirmation
                _buildProximityConfirmation(),
                const SizedBox(height: 16),

                // Contact Patient Card
                _buildContactPatientCard(),
                const SizedBox(height: 16),

                // Preparation Checklist
                _buildPreparationChecklist(),
                const SizedBox(height: 16),

                // Snake Info Reminder
                _buildSnakeInfoReminder(),
                const SizedBox(height: 16),

                // Expert Support Card
                _buildExpertSupportCard(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),

        // Bottom Action Button
        _buildBottomActionButton(),
      ],
    );
  }

  Widget _buildProximityConfirmation() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFF8800).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF8800).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: Color(0xFFFF8800), size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bạn đã xác nhận đến nơi thành công',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF8800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactPatientCard() {
    final missionData = ref.watch(missionDetailProvider).mission;
    if (missionData == null) return const SizedBox.shrink();

    final memberName =
        missionData.user.account?.fullName ??
        missionData.user.userName ??
        'Bệnh nhân';
    final memberPhone =
        missionData.user.account?.phoneNumber ??
        missionData.user.phoneNumber ??
        '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Liên Hệ Bệnh Nhân',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C100D),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Cho bệnh nhân biết bạn đã đến',
            style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                memberName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          if (memberPhone.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  memberPhone,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: memberPhone.isNotEmpty
                      ? () {
                          // TODO: Implement call functionality
                          debugPrint('Calling member: $memberPhone');
                        }
                      : null,
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text('Gọi Điện'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8800),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement chat functionality
                  },
                  icon: const Icon(Icons.sms, size: 18),
                  label: const Text('Nhắn Tin'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF007AFF),
                    side: const BorderSide(color: Color(0xFF007AFF), width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _buildPreparationChecklist() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chuẩn Bị',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C100D),
            ),
          ),
          const SizedBox(height: 14),
          _buildChecklistItem('Đã liên hệ với bệnh nhân', 0),
          const SizedBox(height: 12),
          _buildChecklistItem('Đã mang đủ thiết bị bảo hộ', 1),
          const SizedBox(height: 12),
          _buildChecklistItem('Đã đọc hướng dẫn sơ cứu', 2),
          const SizedBox(height: 12),
          _buildChecklistItem('Sẵn sàng hỗ trợ', 3),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String text, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _checklist[index] = !_checklist[index];
        });
      },
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _checklist[index]
                  ? const Color(0xFFFF8800)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _checklist[index]
                    ? const Color(0xFFFF8800)
                    : const Color(0xFFCCCCCC),
                width: 2,
              ),
            ),
            child: _checklist[index]
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: _checklist[index]
                    ? const Color(0xFF1C100D)
                    : const Color(0xFF999999),
                fontWeight: _checklist[index]
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnakeInfoReminder() {
    final snake = _firstAidRecommendation?.snake;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông Tin Rắn',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C100D),
            ),
          ),
          const SizedBox(height: 14),
          if (snake != null) ...[
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: snake.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            snake.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image,
                                color: Colors.grey,
                              );
                            },
                          ),
                        )
                      : const Icon(Icons.image, color: Colors.grey),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snake.commonName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C100D),
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (snake.isVenomous)
                        SnakeRiskBadges.buildVenomTypeBadge(
                          VenomType.values.firstWhere(
                            (e) => e.displayText == snake.primaryVenomType,
                            orElse: () => VenomType.neurotoxic,
                          ),
                          compact: true,
                        )
                      else
                        SnakeRiskBadges.buildVenomousStatusBadge(
                          false,
                          compact: true,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            const Text(
              'Chưa có thông tin nhận diện rắn',
              style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
            ),
          ],
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              _tabController.animateTo(1); // Switch to First Aid tab
            },
            child: const Row(
              children: [
                Text(
                  'Xem Hướng Dẫn Sơ Cứu',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF007AFF),
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 16, color: Color(0xFF007AFF)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertSupportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF8A2BE2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8A2BE2).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF8A2BE2).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.support_agent,
                  color: Color(0xFF8A2BE2),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Cần Hỗ Trợ Chuyên Gia?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8A2BE2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Miễn phí tư vấn cho rescuer trong tình huống khẩn cấp',
            style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // TODO: Implement expert consultation
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF8A2BE2),
                side: const BorderSide(color: Color(0xFF8A2BE2), width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Gọi Chuyên Gia Rắn',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F5),
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Find Hospital Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  final missionData = ref.read(missionDetailProvider).mission;
                  if (missionData != null) {
                    context.pushNamed(
                      'rescuer_find_hospital',
                      extra: {
                        'missionId': missionData.id,
                        'incidentId': missionData.incidentId,
                      },
                    );
                  }
                },
                icon: const Icon(Icons.local_hospital, size: 20),
                label: const Text('Tìm Bệnh Viện Gần Nhất'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF007AFF),
                  side: const BorderSide(color: Color(0xFF007AFF), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Start Support Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final missionData = ref.read(missionDetailProvider).mission;
                  if (missionData != null) {
                    context.pushNamed(
                      'rescuer_support',
                      extra: {
                        'missionId': missionData.id,
                        'incidentId': missionData.incidentId,
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8800),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadowColor: const Color(0xFFFF8800).withOpacity(0.3),
                ),
                child: const Text(
                  'BẮT ĐẦU HỖ TRỢ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── FIRST AID TAB ────────────────────────────────────────────────────────

  Widget _buildFirstAidTab() {
    if (_isLoadingFirstAid) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF8800)),
      );
    }

    if (_firstAidError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFDC3545),
              ),
              const SizedBox(height: 16),
              const Text(
                'Không thể tải hướng dẫn sơ cứu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _firstAidError!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadFirstAidGuideline,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử Lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8800),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_firstAidRecommendation == null) {
      return const Center(child: Text('Chưa có hướng dẫn sơ cứu'));
    }

    final guideline = _firstAidRecommendation!.firstAidGuideline;
    final snake = _firstAidRecommendation!.snake;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Snake Info Header
          if (snake != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: snake.isVenomous
                    ? const Color(0xFFDC3545).withOpacity(0.1)
                    : const Color(0xFF228B22).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: snake.isVenomous
                      ? const Color(0xFFDC3545).withOpacity(0.3)
                      : const Color(0xFF228B22).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    snake.isVenomous ? Icons.warning_amber : Icons.check_circle,
                    color: snake.isVenomous
                        ? const Color(0xFFDC3545)
                        : const Color(0xFF228B22),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snake.commonName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C100D),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          snake.isVenomous
                              ? '${snake.primaryVenomType} - ĐỘC'
                              : 'Không độc - An toàn',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: snake.isVenomous
                                ? const Color(0xFFDC3545)
                                : const Color(0xFF228B22),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Steps Section
          const Text(
            '📋 CÁC BƯỚC SƠ CỨU',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C100D),
            ),
          ),
          const SizedBox(height: 12),
          ...guideline.steps.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildFirstAidStepItem(
                entry.key + 1,
                entry.value.text,
                entry.value.mediaUrl,
              ),
            );
          }),

          // Dos Section
          if (guideline.dos.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              '✅ NÊN LÀM',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF228B22),
              ),
            ),
            const SizedBox(height: 12),
            ...guideline.dos.map((doItem) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildDoItem(doItem.text, doItem.mediaUrl),
              );
            }),
          ],

          // Don'ts Section
          if (guideline.donts.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              '❌ TUYỆT ĐỐI KHÔNG',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDC3545),
              ),
            ),
            const SizedBox(height: 12),
            ...guideline.donts.map((dontItem) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildDontItem(dontItem.text, dontItem.mediaUrl),
              );
            }),
          ],

          // Notes Section
          if (guideline.notes.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF856404).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF856404),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'LƯU Ý QUAN TRỌNG',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF856404),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...guideline.notes.map((note) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '• $note',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF856404),
                          height: 1.4,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFirstAidStepItem(int number, String text, String? mediaUrl) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFFF8800),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1C100D),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoItem(String text, String? mediaUrl) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF228B22).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF228B22).withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF228B22), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1C100D),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDontItem(String text, String? mediaUrl) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDC3545).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDC3545).withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cancel, color: Color(0xFFDC3545), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFDC3545),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
