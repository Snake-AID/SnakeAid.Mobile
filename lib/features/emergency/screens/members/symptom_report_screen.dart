import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/symptom_config.dart';
import '../../repository/symptom_repository.dart';
import '../../providers/detailed_incident_provider.dart';

class SymptomReportScreen extends ConsumerStatefulWidget {
  final String incidentId;
  final String? recognitionResultId;
  final bool
  isDirectEntry; // true = from quick actions, false = from snake flow

  const SymptomReportScreen({
    super.key,
    required this.incidentId,
    this.recognitionResultId,
    this.isDirectEntry = false, // Default: from snake flow
  });

  @override
  ConsumerState<SymptomReportScreen> createState() =>
      _SymptomReportScreenState();
}

class _SymptomReportScreenState extends ConsumerState<SymptomReportScreen> {
  File? _biteImage;
  final ImagePicker _picker = ImagePicker();

  // Grouped symptom configs from API
  List<GroupedSymptomConfig> _symptomGroups = [];

  // Selected symptom IDs (can be from multiple groups)
  final Set<int> _selectedSymptomIds = {};

  // Track if symptoms were pre-loaded from previous submission
  bool _hasPreviousSymptoms = false;

  // Expansion state for collapsible sections
  final Map<String, bool> _expandedSections = {};

  bool _isLoading = true;
  String? _errorMessage;

  int _timeSinceBiteMinutes = 0; // Track in minutes (0 = at SOS time)
  final TextEditingController _otherInfoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Load both symptom configs and previously selected symptoms
  Future<void> _loadData() async {
    await _loadSymptomConfigs();
    await _loadPreviouslySelectedSymptoms();
  }

  /// Load previously selected symptoms from incident (if any)
  Future<void> _loadPreviouslySelectedSymptoms() async {
    try {
      // Load incident details
      final incidentProvider = ref.read(detailedIncidentProvider.notifier);
      await incidentProvider.loadDetailedIncident(widget.incidentId);

      // Read cached state
      final incidentState = ref.read(detailedIncidentProvider);
      final incidentData = incidentState.incident;

      if (incidentData != null && incidentData.symptomsReport != null) {
        final previousSymptomIds = incidentData.symptomsReport!
            .map((symptom) => symptom.symptomId)
            .toSet();

        if (previousSymptomIds.isNotEmpty) {
          setState(() {
            _selectedSymptomIds.addAll(previousSymptomIds);
            _hasPreviousSymptoms = true; // Mark that symptoms were pre-loaded
          });

          debugPrint(
            '✅ Loaded ${previousSymptomIds.length} previously selected symptoms: $previousSymptomIds',
          );

          // Show info to user
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Đã tải ${previousSymptomIds.length} triệu chứng đã chọn trước đó',
                ),
                backgroundColor: const Color(0xFF228B22),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        debugPrint(
          'ℹ️ No previous symptoms found for incident ${widget.incidentId}',
        );
      }
    } catch (e) {
      debugPrint('⚠️ Error loading previous symptoms: $e');
      // Non-critical error - continue without pre-filling
    }
  }

  @override
  void dispose() {
    _otherInfoController.dispose();
    super.dispose();
  }

  Future<void> _loadSymptomConfigs() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final repository = ref.read(symptomRepositoryProvider);
      final response = await repository.getSymptomConfigs();

      if (response.isSuccess && response.data != null) {
        setState(() {
          // Data is already sorted in model, no need to sort again
          _symptomGroups = response.data!;

          // Debug: Log grouped structure
          debugPrint('📊 Total groups: ${_symptomGroups.length}');
          for (var group in _symptomGroups) {
            debugPrint(
              '  ├─ ${group.attributeKey} (${group.groupName}): ${group.options.length} options',
            );
            debugPrint('  │  Label: "${group.attributeLabel}"');
            debugPrint('  │  DisplayOrder: ${group.displayOrder}');
            for (var i = 0; i < group.options.length; i++) {
              final opt = group.options[i];
              debugPrint('  │  └─ [${i + 1}] ${opt.name} (ID: ${opt.id})');
            }
            debugPrint('  │');
          }

          // Initialize expansion state
          for (var group in _symptomGroups) {
            // Emergency-optimized expansion:
            // - CRITICAL (CORE_SIGNS) = always expanded
            // - LOCAL (SYMPTOM_LOCAL) = expanded (wound assessment)
            // - BITE_LOCATION = expanded (important context)
            // - BACKGROUND (AGE_GROUP, MEDICAL_HISTORY) = collapsed (optional)
            final shouldExpand =
                group.groupName == 'CRITICAL' ||
                group.groupName == 'LOCAL' ||
                group.attributeKey == 'BITE_LOCATION';

            _expandedSections[group.attributeKey] = shouldExpand;

            debugPrint('  📌 ${group.attributeKey} expansion: $shouldExpand');
          }

          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải danh sách triệu chứng: $e';
        _isLoading = false;
      });
    }
  }

  void _showCriticalAlert(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFDC3545),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _biteImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi chọn ảnh: $e')));
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF228B22)),
              title: const Text('Chụp ảnh'),
              onTap: () {
                context.pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF228B22),
              ),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                context.pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _analyzeSymptoms() async {
    // Validate at least one symptom selected
    if (_selectedSymptomIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một triệu chứng'),
          backgroundColor: Color(0xFFDC3545),
        ),
      );
      return;
    }

    // Show loading dialog
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
                CircularProgressIndicator(color: Color(0xFF228B22)),
                SizedBox(height: 16),
                Text('Đang phân tích triệu chứng...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Convert selected IDs to list
      final symptomIdList = _selectedSymptomIds.toList();

      // Call API to update symptoms tracking
      final repository = ref.read(symptomRepositoryProvider);
      final response = await repository.updateSymptomsTracking(
        incidentId: widget.incidentId,
        symptomIdList: symptomIdList,
        timeSinceBiteMinutes: _timeSinceBiteMinutes,
      );

      // Close loading dialog
      if (mounted) {
        context.pop();

        if (response.isSuccess && response.data != null) {
          // Save symptoms report status to SharedPreferences
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('has_symptoms_${widget.incidentId}', true);
            debugPrint(
              '✅ Saved symptoms report status for incident: ${widget.incidentId}',
            );
          } catch (e) {
            debugPrint('❌ Error saving symptoms status: $e');
          }

          // Invalidate detailed incident cache - symptoms updated, severity may change
          try {
            ref.read(detailedIncidentProvider.notifier).invalidateCache();
            debugPrint('🔄 Invalidated incident cache after symptom update');
          } catch (e) {
            debugPrint('⚠️ Could not invalidate cache: $e');
          }

          // Navigate to severity assessment using push
          // Pass isDirectEntry flag to maintain context
          context.push(
            '/severity-assessment',
            extra: {
              'incidentId': widget.incidentId,
              'recognitionResultId': widget.recognitionResultId,
              'isDirectEntry': widget.isDirectEntry, // Propagate context
              'cameFromSymptomReport': true,
            },
          );
        } else {
          // Show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: const Color(0xFFDC3545),
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        context.pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi phân tích triệu chứng: $e'),
            backgroundColor: const Color(0xFFDC3545),
          ),
        );
      }
    }
  }

  String _formatTimeSinceBite(int minutes) {
    if (minutes == 0) {
      return 'Tại thời điểm SOS';
    } else if (minutes < 60) {
      return '$minutes phút trước';
    } else {
      final hours = minutes ~/ 60;
      return '$hours giờ trước';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF191910)),
          onPressed: () {
            // Always allow back navigation
            context.pop();
          },
        ),
        title: const Text(
          'Báo cáo triệu chứng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191910),
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E5E5)),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF228B22)),
            )
          : _errorMessage != null
          ? _buildErrorView()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Banner
                    _buildInfoBanner(),
                    const SizedBox(height: 16),

                    // Time Since Bite (MOVED TO TOP - Critical context)
                    _buildTimeSinceBiteSection(),
                    const SizedBox(height: 16),

                    // Selected Count Indicator
                    if (_selectedSymptomIds.isNotEmpty)
                      _buildSelectedCountBanner(),
                    if (_selectedSymptomIds.isNotEmpty)
                      const SizedBox(height: 16),

                    // Render symptom groups
                    ..._symptomGroups.map(
                      (group) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildSymptomGroup(group),
                      ),
                    ),

                    // Bite Image Upload (moved down - optional)
                    _buildBiteImageSection(),
                    const SizedBox(height: 24),

                    // Other Info
                    _buildOtherInfoSection(),
                    const SizedBox(height: 32),

                    // Submit Button
                    _buildSubmitButton(),
                    const SizedBox(height: 16),

                    // Skip to tracking - context aware
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          // Pop back based on entry context
                          if (widget.isDirectEntry) {
                            // Direct entry: just pop once to tracking
                            Navigator.of(context).pop();
                          } else {
                            // From snake flow: pop twice (symptom + snake location)
                            Navigator.of(context)
                              ..pop()
                              ..pop();
                          }
                        },
                        icon: const Icon(Icons.crisis_alert, size: 18),
                        label: const Text('Quay về theo dõi cứu hộ'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF228B22),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFDC3545)),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Đã xảy ra lỗi',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF228B22),
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _hasPreviousSymptoms
            ? const Color(0xFFE3F2FD) // Blue tint for update mode
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _hasPreviousSymptoms
              ? const Color(0xFF2196F3)
              : const Color(0xFFE0E0E0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _hasPreviousSymptoms ? Icons.update : Icons.info_outline,
            color: _hasPreviousSymptoms
                ? const Color(0xFF2196F3)
                : const Color(0xFF666666),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _hasPreviousSymptoms
                  ? 'Bạn đã báo cáo triệu chứng trước đó. Có thể chọn thêm hoặc bỏ chọn để cập nhật.'
                  : 'Thông tin này giúp đội cứu hộ đánh giá mức độ nguy hiểm và chuẩn bị tốt hơn',
              style: TextStyle(
                fontSize: 13,
                color: _hasPreviousSymptoms
                    ? const Color(0xFF1565C0)
                    : Colors.brown[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedCountBanner() {
    final criticalCount = _selectedSymptomIds.where((id) {
      for (var group in _symptomGroups) {
        final option = group.options.firstWhere(
          (opt) => opt.id == id,
          orElse: () => group.options.first,
        );
        if (option.id == id && option.isCritical) {
          return true;
        }
      }
      return false;
    }).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: criticalCount > 0
            ? const Color(0xFFFFEBEE)
            : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: criticalCount > 0
              ? const Color(0xFFDC3545)
              : const Color(0xFF228B22),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            criticalCount > 0 ? Icons.warning_amber : Icons.check_circle,
            color: criticalCount > 0
                ? const Color(0xFFDC3545)
                : const Color(0xFF228B22),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đã chọn: ${_selectedSymptomIds.length} triệu chứng',
                  style: TextStyle(
                    color: criticalCount > 0
                        ? const Color(0xFFDC3545)
                        : const Color(0xFF228B22),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (criticalCount > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '⚠️ Có $criticalCount triệu chứng nguy hiểm',
                    style: const TextStyle(
                      color: Color(0xFFDC3545),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_selectedSymptomIds.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedSymptomIds.clear();
                });
              },
              child: const Text(
                'Xóa hết',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSymptomGroup(GroupedSymptomConfig group) {
    final isExpanded = _expandedSections[group.attributeKey] ?? false;
    final isCritical = group.groupName == 'CRITICAL';
    final isRadioGroup =
        group.attributeKey == 'AGE_GROUP' ||
        group.attributeKey == 'BITE_LOCATION';

    // Debug render state
    debugPrint(
      '🎨 Rendering ${group.attributeKey}: expanded=$isExpanded, options=${group.options.length}',
    );

    // Color coding based on group priority
    Color headerColor;
    Color bgColor;
    IconData icon;

    if (isCritical) {
      headerColor = const Color(0xFFDC3545); // Red
      bgColor = const Color(0xFFFEF2F2);
      icon = Icons.warning_amber;
    } else if (group.attributeKey == 'BITE_LOCATION') {
      headerColor = const Color(0xFFF59E0B); // Orange
      bgColor = const Color(0xFFFFFBEB);
      icon = Icons.location_on;
    } else if (group.groupName == 'LOCAL') {
      headerColor = const Color(0xFF228B22); // Green
      bgColor = const Color(0xFFF0F9FF);
      icon = Icons.healing;
    } else {
      headerColor = const Color(0xFF666666); // Grey
      bgColor = const Color(0xFFF9FAFB);
      icon = Icons.info_outline;
    }

    return Card(
      elevation: isCritical ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCritical ? headerColor : Colors.transparent,
          width: isCritical ? 2 : 0,
        ),
      ),
      child: Column(
        children: [
          // Section Header
          InkWell(
            onTap: () {
              if (!isCritical && group.attributeKey != 'BITE_LOCATION') {
                setState(() {
                  _expandedSections[group.attributeKey] = !isExpanded;
                });
              }
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(12),
                  bottom: isExpanded ? Radius.zero : const Radius.circular(12),
                ),
                border: Border(left: BorderSide(color: headerColor, width: 4)),
              ),
              child: Row(
                children: [
                  Icon(icon, color: headerColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      group.attributeLabel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: headerColor,
                      ),
                    ),
                  ),
                  if (!isCritical && group.attributeKey != 'BITE_LOCATION')
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: headerColor,
                    ),
                ],
              ),
            ),
          ),

          // Section Content
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: group.options
                    .where((option) => option.isActive)
                    .map(
                      (option) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildSymptomOption(
                          option,
                          isRadioGroup,
                          group.attributeKey,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSymptomOption(
    SymptomOption option,
    bool isRadioGroup,
    String attributeKey,
  ) {
    final isSelected = _selectedSymptomIds.contains(option.id);

    return InkWell(
      onTap: () {
        setState(() {
          if (isRadioGroup) {
            // Radio behavior: deselect all options in this group first
            final groupOptions = _symptomGroups
                .firstWhere((g) => g.attributeKey == attributeKey)
                .options;
            for (var opt in groupOptions) {
              _selectedSymptomIds.remove(opt.id);
            }
            // Then select this option
            _selectedSymptomIds.add(option.id);
          } else {
            // Checkbox behavior: toggle selection
            if (isSelected) {
              _selectedSymptomIds.remove(option.id);
            } else {
              _selectedSymptomIds.add(option.id);
            }
          }
        });

        // Show critical alert if needed
        if (!isSelected && option.isCritical && option.alertMessage != null) {
          _showCriticalAlert(option.alertMessage!);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF228B22)
                : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isRadioGroup
                  ? (isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked)
                  : (isSelected
                        ? Icons.check_box
                        : Icons.check_box_outline_blank),
              color: isSelected
                  ? const Color(0xFF228B22)
                  : const Color(0xFF999999),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: const Color(0xFF191910),
                    ),
                  ),
                  if (option.description != null &&
                      option.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      option.description!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
            if (option.isCritical)
              const Icon(
                Icons.warning_amber,
                color: Color(0xFFDC3545),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSinceBiteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thời gian từ khi bị cắn',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191910),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _timeSinceBiteMinutes,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF228B22)),
              items: [0, 10, 15, 30, 45, 60, 90, 120, 180, 240].map((minutes) {
                return DropdownMenuItem<int>(
                  value: minutes,
                  child: Text(_formatTimeSinceBite(minutes)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _timeSinceBiteMinutes = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBiteImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hình ảnh vết cắn (không bắt buộc)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191910),
          ),
        ),
        const SizedBox(height: 12),
        if (_biteImage != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _biteImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  radius: 16,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _biteImage = null;
                      });
                    },
                  ),
                ),
              ),
            ],
          )
        else
          InkWell(
            onTap: _showImageSourceDialog,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  style: BorderStyle.solid,
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 48,
                      color: Color(0xFF999999),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Thêm ảnh vết cắn',
                      style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOtherInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin bổ sung (không bắt buộc)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191910),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _otherInfoController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Mô tả các triệu chứng khác hoặc thông tin quan trọng...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF228B22), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _analyzeSymptoms,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF228B22),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_hasPreviousSymptoms ? Icons.update : Icons.analytics),
            const SizedBox(width: 8),
            Text(
              _hasPreviousSymptoms
                  ? 'Cập nhật triệu chứng'
                  : 'Phân tích triệu chứng',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
