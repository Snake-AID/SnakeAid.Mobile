import 'package:flutter/material.dart';

/// Medical Records Screen - Manage medical information
class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  String _bloodType = 'O+';
  String _drugAllergies = 'Penicillin, Aspirin';
  String _foodAllergies = 'Hải sản';
  String _otherAllergies = 'Phấn hoa';
  String _chronicDiseases = 'Cao huyết áp';
  String _surgeries = 'Phẫu thuật ruột thừa (2020)';
  String _familyHistory = 'Đái tháo đường (Cha)';
  String _emergencyNotes = '⚠️ Dị ứng nghiêm trọng với Penicillin\n⚠️ Đang dùng thuốc chống đông máu';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top App Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFFDDDDDD),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 56,
                child: Stack(
                  children: [
                    // Back button
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFF333333),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    // Title - centered
                    Center(
                      child: const Text(
                        'Hồ Sơ Y Tế',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    // Edit button
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Color(0xFF228B22),
                        ),
                        onPressed: () {
                          _showEditDialog();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Blood Type Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD32F2F), Color(0xFFC62828)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.bloodtype,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nhóm Máu',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _bloodType,
                                  style: const TextStyle(
                                    fontSize: 36,
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
                  ),
                  const SizedBox(height: 16),
                  // Allergies Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SectionCard(
                      title: 'Dị Ứng',
                      icon: Icons.warning_amber_rounded,
                      iconColor: const Color(0xFFFF9800),
                      children: [
                        _InfoRow(
                          label: 'Thuốc',
                          value: _drugAllergies,
                          icon: Icons.medication,
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          label: 'Thực phẩm',
                          value: _foodAllergies,
                          icon: Icons.restaurant,
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          label: 'Khác',
                          value: _otherAllergies,
                          icon: Icons.local_florist,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Medical Conditions Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SectionCard(
                      title: 'Tiền Sử Bệnh',
                      icon: Icons.medical_information,
                      iconColor: const Color(0xFF1E88E5),
                      children: [
                        _InfoRow(
                          label: 'Bệnh mãn tính',
                          value: _chronicDiseases,
                          icon: Icons.favorite,
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          label: 'Phẫu thuật',
                          value: _surgeries,
                          icon: Icons.local_hospital,
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          label: 'Gia đình',
                          value: _familyHistory,
                          icon: Icons.people,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Current Medications Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SectionCard(
                      title: 'Thuốc Đang Dùng',
                      icon: Icons.medical_services,
                      iconColor: const Color(0xFF228B22),
                      children: [
                        _MedicationItem(
                          name: 'Amlodipine 5mg',
                          dosage: '1 viên/ngày',
                          time: 'Buổi sáng',
                        ),
                        const SizedBox(height: 12),
                        _MedicationItem(
                          name: 'Metformin 500mg',
                          dosage: '2 viên/ngày',
                          time: 'Sáng & Tối',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Insurance Information
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SectionCard(
                      title: 'Thông Tin Bảo Hiểm',
                      icon: Icons.card_membership,
                      iconColor: const Color(0xFF7B1FA2),
                      children: [
                        _InfoRow(
                          label: 'Loại BH',
                          value: 'BHYT Bắt buộc',
                          icon: Icons.verified_user,
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          label: 'Số thẻ',
                          value: 'VN0123456789',
                          icon: Icons.credit_card,
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          label: 'Hiệu lực',
                          value: 'Đến 31/12/2026',
                          icon: Icons.calendar_today,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Emergency Notes
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SectionCard(
                      title: 'Ghi Chú Khẩn Cấp',
                      icon: Icons.emergency,
                      iconColor: const Color(0xFFD32F2F),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _emergencyNotes,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF333333),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => _EditMedicalRecordsDialog(
        bloodType: _bloodType,
        drugAllergies: _drugAllergies,
        foodAllergies: _foodAllergies,
        otherAllergies: _otherAllergies,
        chronicDiseases: _chronicDiseases,
        surgeries: _surgeries,
        familyHistory: _familyHistory,
        emergencyNotes: _emergencyNotes,
        onSave: (data) {
          setState(() {
            _bloodType = data['bloodType']!;
            _drugAllergies = data['drugAllergies']!;
            _foodAllergies = data['foodAllergies']!;
            _otherAllergies = data['otherAllergies']!;
            _chronicDiseases = data['chronicDiseases']!;
            _surgeries = data['surgeries']!;
            _familyHistory = data['familyHistory']!;
            _emergencyNotes = data['emergencyNotes']!;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã cập nhật hồ sơ y tế')),
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF888888),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MedicationItem extends StatelessWidget {
  final String name;
  final String dosage;
  final String time;

  const _MedicationItem({
    required this.name,
    required this.dosage,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF228B22).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.medication,
              color: Color(0xFF228B22),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$dosage • $time',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
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

class _EditMedicalRecordsDialog extends StatefulWidget {
  final String bloodType;
  final String drugAllergies;
  final String foodAllergies;
  final String otherAllergies;
  final String chronicDiseases;
  final String surgeries;
  final String familyHistory;
  final String emergencyNotes;
  final Function(Map<String, String>) onSave;

  const _EditMedicalRecordsDialog({
    required this.bloodType,
    required this.drugAllergies,
    required this.foodAllergies,
    required this.otherAllergies,
    required this.chronicDiseases,
    required this.surgeries,
    required this.familyHistory,
    required this.emergencyNotes,
    required this.onSave,
  });

  @override
  State<_EditMedicalRecordsDialog> createState() => _EditMedicalRecordsDialogState();
}

class _EditMedicalRecordsDialogState extends State<_EditMedicalRecordsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _drugAllergiesController;
  late final TextEditingController _foodAllergiesController;
  late final TextEditingController _otherAllergiesController;
  late final TextEditingController _chronicDiseasesController;
  late final TextEditingController _surgeriesController;
  late final TextEditingController _familyHistoryController;
  late final TextEditingController _emergencyNotesController;
  late String _selectedBloodType;

  final List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Không rõ'
  ];

  @override
  void initState() {
    super.initState();
    _selectedBloodType = widget.bloodType;
    _drugAllergiesController = TextEditingController(text: widget.drugAllergies);
    _foodAllergiesController = TextEditingController(text: widget.foodAllergies);
    _otherAllergiesController = TextEditingController(text: widget.otherAllergies);
    _chronicDiseasesController = TextEditingController(text: widget.chronicDiseases);
    _surgeriesController = TextEditingController(text: widget.surgeries);
    _familyHistoryController = TextEditingController(text: widget.familyHistory);
    _emergencyNotesController = TextEditingController(text: widget.emergencyNotes);
  }

  @override
  void dispose() {
    _drugAllergiesController.dispose();
    _foodAllergiesController.dispose();
    _otherAllergiesController.dispose();
    _chronicDiseasesController.dispose();
    _surgeriesController.dispose();
    _familyHistoryController.dispose();
    _emergencyNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Chỉnh Sửa Hồ Sơ Y Tế',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 24),
                // Blood Type
                DropdownButtonFormField<String>(
                  value: _selectedBloodType,
                  decoration: InputDecoration(
                    labelText: 'Nhóm máu',
                    prefixIcon: const Icon(Icons.bloodtype),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF228B22)),
                    ),
                  ),
                  items: _bloodTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedBloodType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Section: Allergies
                const Text(
                  'Dị Ứng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _drugAllergiesController,
                  decoration: InputDecoration(
                    labelText: 'Dị ứng thuốc',
                    hintText: 'Penicillin, Aspirin',
                    prefixIcon: const Icon(Icons.medication),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF228B22)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _foodAllergiesController,
                  decoration: InputDecoration(
                    labelText: 'Dị ứng thực phẩm',
                    hintText: 'Hải sản, trứng',
                    prefixIcon: const Icon(Icons.restaurant),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF228B22)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _otherAllergiesController,
                  decoration: InputDecoration(
                    labelText: 'Dị ứng khác',
                    hintText: 'Phấn hoa, bụi',
                    prefixIcon: const Icon(Icons.local_florist),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF228B22)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Section: Medical History
                const Text(
                  'Tiền Sử Bệnh',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _chronicDiseasesController,
                  decoration: InputDecoration(
                    labelText: 'Bệnh mãn tính',
                    hintText: 'Cao huyết áp, tiểu đường',
                    prefixIcon: const Icon(Icons.favorite),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF228B22)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _surgeriesController,
                  decoration: InputDecoration(
                    labelText: 'Lịch sử phẫu thuật',
                    hintText: 'Phẫu thuật ruột thừa (2020)',
                    prefixIcon: const Icon(Icons.local_hospital),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF228B22)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _familyHistoryController,
                  decoration: InputDecoration(
                    labelText: 'Tiền sử gia đình',
                    hintText: 'Đái tháo đường (Cha)',
                    prefixIcon: const Icon(Icons.people),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF228B22)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Emergency Notes
                const Text(
                  'Ghi Chú Khẩn Cấp',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emergencyNotesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Thông tin quan trọng',
                    hintText: 'Các thông tin cần lưu ý khi cấp cứu',
                    prefixIcon: const Icon(Icons.emergency),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF228B22)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(
                          color: Color(0xFF888888),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _saveMedicalRecords,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Lưu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
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
    );
  }

  void _saveMedicalRecords() {
    if (_formKey.currentState!.validate()) {
      widget.onSave({
        'bloodType': _selectedBloodType,
        'drugAllergies': _drugAllergiesController.text.trim(),
        'foodAllergies': _foodAllergiesController.text.trim(),
        'otherAllergies': _otherAllergiesController.text.trim(),
        'chronicDiseases': _chronicDiseasesController.text.trim(),
        'surgeries': _surgeriesController.text.trim(),
        'familyHistory': _familyHistoryController.text.trim(),
        'emergencyNotes': _emergencyNotesController.text.trim(),
      });
      Navigator.of(context).pop();
    }
  }
}
