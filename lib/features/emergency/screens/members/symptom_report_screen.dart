import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/symptom_config.dart';
import '../../repository/symptom_repository.dart';

class SymptomReportScreen extends ConsumerStatefulWidget {
  final String incidentId;
  final String? recognitionResultId;
  
  const SymptomReportScreen({
    super.key,
    required this.incidentId,
    this.recognitionResultId,
  });

  @override
  ConsumerState<SymptomReportScreen> createState() => _SymptomReportScreenState();
}

class _SymptomReportScreenState extends ConsumerState<SymptomReportScreen> {
  File? _biteImage;
  final ImagePicker _picker = ImagePicker();
  
  // Symptom configs from API
  List<SymptomConfig> _allSymptoms = [];
  final Set<int> _selectedSymptomIds = {};
  bool _isLoading = true;
  String? _errorMessage;
  
  // Bite location (from BITE_LOCATION_CORE)
  int? _selectedBiteLocationId;
  
  int _timeSinceBiteMinutes = 15; // Track in minutes
  final TextEditingController _otherInfoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSymptomConfigs();
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
          _allSymptoms = response.data!
              .where((s) => s.isActive)
              .toList()
            ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
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

  // Get symptoms by attribute key
  List<SymptomConfig> _getSymptomsByKey(String attributeKey) {
    return _allSymptoms
        .where((s) => s.attributeKey == attributeKey)
        .toList();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi chọn ảnh: $e')),
        );
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
              leading: const Icon(Icons.photo_library, color: Color(0xFF228B22)),
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
    // Validate at least one symptom or bite location selected
    if (_selectedSymptomIds.isEmpty && _selectedBiteLocationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một triệu chứng hoặc vị trí bị cắn'),
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
      // Combine selected symptom IDs and bite location ID
      final symptomIdList = <int>[
        ..._selectedSymptomIds,
        if (_selectedBiteLocationId != null) _selectedBiteLocationId!,
      ];

      // Call API to update symptoms tracking
      final repository = ref.read(symptomRepositoryProvider);
      final response = await repository.updateSymptomsTracking(
        incidentId: widget.incidentId,
        symptomIdList: symptomIdList,
      );

      // Close loading dialog
      if (mounted) {
        context.pop();

        if (response.isSuccess && response.data != null) {
          // Save symptoms report status to SharedPreferences
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('has_symptoms_${widget.incidentId}', true);
            debugPrint('✅ Saved symptoms report status for incident: ${widget.incidentId}');
          } catch (e) {
            debugPrint('❌ Error saving symptoms status: $e');
          }

          // Navigate to severity assessment screen with API response
          context.pushNamed(
            'severity_assessment',
            extra: {
              'severityLevel': response.data!.severityLevel,
              'symptomsReport': response.data!.symptomsReport,
              'timeSinceBite': _formatTimeSinceBite(_timeSinceBiteMinutes),
              'recognitionResultId': widget.recognitionResultId,
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
    if (minutes < 60) {
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
          onPressed: () => context.pop(),
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
          child: Container(
            height: 1,
            color: const Color(0xFFE5E5E5),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF228B22)))
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
                        const SizedBox(height: 20),

                        // Bite Location Section
                        _buildBiteLocationSection(),
                        const SizedBox(height: 24),

                        // Time Since Bite
                        _buildTimeSinceBiteSection(),
                        const SizedBox(height: 24),

                        // Core Symptoms Section
                        _buildCoreSymptomsSection(),
                        const SizedBox(height: 24),

                        // Bite Image Upload
                        _buildBiteImageSection(),
                        const SizedBox(height: 24),

                        // Other Info
                        _buildOtherInfoSection(),
                        const SizedBox(height: 32),

                        // Submit Button
                        _buildSubmitButton(),
                        
                        // Skip Link
                        Center(
                          child: TextButton(
                            onPressed: () => context.pop(),
                            child: Text(
                              'Bỏ qua bước này',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
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
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFDC3545),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Đã xảy ra lỗi',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadSymptomConfigs,
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
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF666666), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Thông tin này giúp đội cứu hộ đánh giá mức độ nguy hiểm và chuẩn bị tốt hơn',
              style: TextStyle(
                fontSize: 13,
                color: Colors.brown[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiteLocationSection() {
    final locations = _getSymptomsByKey('BITE_LOCATION_CORE');
    
    if (locations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vị trí bị cắn',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191910),
          ),
        ),
        const SizedBox(height: 12),
        ...locations.map((location) {
          final isSelected = _selectedBiteLocationId == location.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedBiteLocationId = isSelected ? null : location.id;
                });
                if (!isSelected && location.isCritical && location.alertMessage != null) {
                  _showCriticalAlert(location.alertMessage!);
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
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: isSelected ? const Color(0xFF228B22) : const Color(0xFF999999),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: const Color(0xFF191910),
                            ),
                          ),
                          if (location.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              location.description!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (location.isCritical)
                      const Icon(
                        Icons.warning_amber,
                        color: Color(0xFFDC3545),
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
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
              items: [
                10, 15, 30, 45, 60, 90, 120, 180, 240
              ].map((minutes) {
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

  Widget _buildCoreSymptomsSection() {
    final symptoms = _getSymptomsByKey('CORE_SIGNS');
    
    if (symptoms.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Triệu chứng hiện tại',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191910),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Chọn tất cả triệu chứng bạn đang gặp phải',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        ...symptoms.map((symptom) {
          final isSelected = _selectedSymptomIds.contains(symptom.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedSymptomIds.remove(symptom.id);
                  } else {
                    _selectedSymptomIds.add(symptom.id);
                    if (symptom.isCritical && symptom.alertMessage != null) {
                      _showCriticalAlert(symptom.alertMessage!);
                    }
                  }
                });
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
                      isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                      color: isSelected ? const Color(0xFF228B22) : const Color(0xFF999999),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            symptom.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: const Color(0xFF191910),
                            ),
                          ),
                          if (symptom.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              symptom.description!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (symptom.isCritical)
                      const Icon(
                        Icons.warning_amber,
                        color: Color(0xFFDC3545),
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
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
                    icon: const Icon(Icons.close, size: 18, color: Colors.white),
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
                border: Border.all(color: const Color(0xFFE0E0E0), style: BorderStyle.solid),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, size: 48, color: Color(0xFF999999)),
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
        child: const Text(
          'Phân tích triệu chứng',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
