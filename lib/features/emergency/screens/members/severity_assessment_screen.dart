import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../repository/snake_ai_repository.dart';
import '../../models/snake_detection_response.dart';
import '../../models/detailed_incident_response.dart';
import '../../providers/detailed_incident_provider.dart';
import '../../providers/incident_provider.dart';

class SeverityAssessmentScreen extends ConsumerStatefulWidget {
  final String incidentId;
  final String? recognitionResultId;
  final bool
  isDirectEntry; // true = from quick actions, false = from symptom flow

  const SeverityAssessmentScreen({
    super.key,
    required this.incidentId,
    this.recognitionResultId,
    this.isDirectEntry = false, // Default: from symptom flow
  });

  @override
  ConsumerState<SeverityAssessmentScreen> createState() =>
      _SeverityAssessmentScreenState();
}

class _SeverityAssessmentScreenState
    extends ConsumerState<SeverityAssessmentScreen> {
  late String _assessmentTime;
  List<FirstAidStep> _dosActions = [];
  bool _isLoadingDos = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _assessmentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📊 Severity Assessment Screen');
    debugPrint('Incident ID (from params): ${widget.incidentId}');
    debugPrint('Recognition Result ID: ${widget.recognitionResultId}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // Load incident data via provider (uses smart caching)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get incident ID - prefer from active incident provider if widget.incidentId is empty
      final activeIncidentId = ref
          .read(activeIncidentProvider)
          .activeIncidentId;
      final incidentId = widget.incidentId.isNotEmpty
          ? widget.incidentId
          : (activeIncidentId ?? '');

      debugPrint('🔍 Using incident ID: $incidentId');
      debugPrint('   From widget: ${widget.incidentId}');
      debugPrint('   From active incident: $activeIncidentId');

      if (incidentId.isEmpty) {
        debugPrint('❌ No incident ID available!');
        return;
      }

      // Check if we already have cached data in DetailedIncidentProvider
      final detailedIncidentState = ref.read(detailedIncidentProvider);
      final hasValidCache =
          detailedIncidentState.incident?.id == incidentId &&
          detailedIncidentState.isCacheFresh;

      if (hasValidCache) {
        debugPrint('✅ Using cached incident data (fresh)');
        return; // Use cached data, no need to fetch
      }

      // Otherwise, load from API (will use smart caching)
      ref.read(detailedIncidentProvider.notifier).loadIfStale(incidentId);
    });

    // Load dos from API if recognitionResultId is provided
    if (widget.recognitionResultId != null) {
      _loadFirstAidDos();
    } else {
      debugPrint('⚠️ No recognitionResultId - using default dos');
    }
  }

  Future<void> _loadFirstAidDos() async {
    setState(() {
      _isLoadingDos = true;
    });

    try {
      debugPrint('🔍 Loading first aid dos from API...');
      final repository = ref.read(snakeAiRepositoryProvider);
      final response = await repository.getDetectionResult(
        recognitionResultId: widget.recognitionResultId!,
      );

      if (response.isSuccess && response.data != null) {
        final results = response.data!.results;
        if (results.isNotEmpty) {
          final snake = results.first.snake;
          final venoms = snake.speciesVenoms;

          debugPrint('✅ Found ${venoms.length} venom types');

          // Collect all dos from all venom types
          final allDos = <FirstAidStep>[];
          for (var venom in venoms) {
            try {
              final dos = venom.venomType.firstAidGuideline.content.dos;
              // ignore: unnecessary_null_comparison
              if (dos != null) {
                debugPrint(
                  '  - ${venom.venomType.name}: ${dos.length} dos items',
                );
                allDos.addAll(dos);
              }
            } catch (e) {
              debugPrint('⚠️ Missing dos data for ${venom.venomType.name}');
            }
          }

          debugPrint('✅ Total dos loaded: ${allDos.length}');
          setState(() {
            _dosActions = allDos;
            _isLoadingDos = false;
          });
          return;
        }
      }

      debugPrint('⚠️ No data in response');
    } catch (e) {
      debugPrint('❌ Error loading dos: $e');
    }

    setState(() {
      _isLoadingDos = false;
    });
  }

  Color _getSeverityColor(DetailedIncidentData? incident) {
    final level = incident?.severityLevel ?? 0;
    if (level >= 70) {
      return const Color(0xFFC0392B); // Critical red
    } else if (level >= 40) {
      return const Color(0xFFF59E0B); // Warning amber
    } else {
      return const Color(0xFF228B22); // Safe green
    }
  }

  String _getSeverityLevel(DetailedIncidentData? incident) {
    final level = incident?.severityLevel ?? 0;
    if (level >= 70) {
      return '🚨 NGHIÊM TRỌNG - CẦN CẤP CỨU NGAY';
    } else if (level >= 40) {
      return '⚠️ TRUNG BÌNH - CẦN THEO DÕI';
    } else {
      return '✓ NHẸ - TIẾP TỤC SƠ CỨU';
    }
  }

  String _getTimeSinceBite(DetailedIncidentData? incident) {
    if (incident?.incidentOccurredAt == null) return 'Chưa xác định';

    final elapsed = DateTime.now().difference(incident!.incidentOccurredAt!);
    final minutes = elapsed.inMinutes;

    if (minutes == 0) {
      return 'Tại thời điểm SOS';
    } else if (minutes < 60) {
      return '$minutes phút trước';
    } else {
      final hours = minutes ~/ 60;
      return '$hours giờ trước';
    }
  }

  List<String> _getSymptomsList(DetailedIncidentData? incident) {
    if (incident?.symptomsReport == null || incident!.symptomsReport!.isEmpty) {
      return [];
    }
    // Return symptom names from ReportSymptom list
    return incident.symptomsReport!
        .map((symptom) => symptom.symptomName)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final detailedIncidentState = ref.watch(detailedIncidentProvider);
    final incident = detailedIncidentState.incident;

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF191910),
            ),
            onPressed: _returnToEmergencyTracking,
          ),
          title: const Text(
            'Đánh giá mức độ nghiêm trọng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF191910),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF228B22)),
              onPressed: () {
                ref
                    .read(detailedIncidentProvider.notifier)
                    .refreshDetailedIncident();
              },
              tooltip: 'Làm mới dữ liệu',
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  'Phân tích lúc $_assessmentTime',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: const Color(0xFFE5E5E5)),
          ),
        ),
        body: detailedIncidentState.isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF228B22)),
                    SizedBox(height: 16),
                    Text('Đang tải thông tin đánh giá...'),
                  ],
                ),
              )
            : detailedIncidentState.error != null || incident == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Color(0xFFDC3545),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        detailedIncidentState.error ??
                            'Không tải được thông tin sự cố',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(detailedIncidentProvider.notifier)
                              .loadDetailedIncident(
                                widget.incidentId,
                                forceRefresh: true,
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF228B22),
                        ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  // Severity Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: _getSeverityColor(incident),
                    child: Text(
                      _getSeverityLevel(incident),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Scrollable Content
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await ref
                            .read(detailedIncidentProvider.notifier)
                            .refreshDetailedIncident();
                      },
                      color: const Color(0xFF228B22),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Score Card
                              _buildScoreCard(incident),
                              const SizedBox(height: 16),

                              // Risk Factors Card
                              _buildRiskFactorsCard(incident),
                              const SizedBox(height: 16),

                              // Action Items Card
                              _buildActionItemsCard(),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Actions
                  _buildBottomActions(),
                ],
              ),
      ),
    );
  }

  Widget _buildScoreCard(DetailedIncidentData? incident) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular Progress
          SizedBox(
            width: 160,
            height: 160,
            child: CustomPaint(
              painter: CircularProgressPainter(
                progress: (incident?.severityLevel ?? 0) / 100,
                color: _getSeverityColor(incident),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${incident?.severityLevel ?? 0}',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF191910),
                      ),
                    ),
                    const Text(
                      '/100',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Điểm mức độ: ${incident?.severityLevel ?? 0}/100',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF191910),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dựa trên triệu chứng và phân tích ảnh',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskFactorsCard(DetailedIncidentData? incident) {
    final symptoms = _getSymptomsList(incident);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Các triệu chứng đã ghi nhận:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF191910),
            ),
          ),
          const SizedBox(height: 16),
          if (symptoms.isEmpty)
            Text(
              'Chưa có triệu chứng nào được ghi nhận',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            )
          else
            ...symptoms.asMap().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key < symptoms.length - 1 ? 12 : 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('❗', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF191910),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE5E5E5))),
            ),
            child: Row(
              children: [
                const Text('⏱️', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  '${_getTimeSinceBite(incident)} kể từ khi bị cắn',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItemsCard() {
    // Use API dos if available, otherwise use default
    final defaultActions = [
      'GỌI CẤP CỨU NGAY',
      'Đến bệnh viện gần nhất ngay lập tức',
      'Thông báo người thân khẩn cấp',
      'Tiếp tục sơ cứu trong khi chờ',
    ];

    final actions = _dosActions.isNotEmpty
        ? _dosActions.map((d) => d.text).toList()
        : defaultActions;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Cần làm NGAY:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191910),
                ),
              ),
              if (_isLoadingDos) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF228B22),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(actions.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < actions.length - 1 ? 12 : 0,
              ),
              child: _buildActionItem(index + 1, actions[index]),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionItem(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF228B22),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF191910),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _returnToEmergencyTracking() {
    Navigator.of(context).popUntil((route) {
      return route.settings.name == 'emergency_tracking' || route.isFirst;
    });
  }

  Future<bool> _handleWillPop() async {
    _returnToEmergencyTracking();
    return false;
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(top: BorderSide(color: Color(0xFFE5E5E5))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Back to Emergency Tracking Button
          ElevatedButton(
            onPressed: _returnToEmergencyTracking,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF228B22),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 56),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.crisis_alert, size: 20),
                SizedBox(width: 8),
                Text(
                  'Về màn hình theo dõi cứu hộ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Update Symptoms Link - context aware
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              children: [
                const TextSpan(
                  text: 'Triệu chứng của bạn đang được theo dõi\n',
                ),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {
                      // Pop back to symptom report (works for both flows)
                      context.pop();
                    },
                    child: const Text(
                      'Cập nhật triệu chứng',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF228B22),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius - 6, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
