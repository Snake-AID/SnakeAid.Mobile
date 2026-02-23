import 'package:flutter/material.dart';
import 'dart:io';
import 'rescuer_mission_success_screen.dart';

/// Màn hình xác nhận kết quả sau khi bắt rắn thành công
class RescuerResultConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> requestData;
  final List<File> capturedPhotos;
  final String notes;
  
  const RescuerResultConfirmationScreen({
    super.key,
    required this.requestData,
    required this.capturedPhotos,
    required this.notes,
  });

  @override
  State<RescuerResultConfirmationScreen> createState() => _RescuerResultConfirmationScreenState();
}

class _RescuerResultConfirmationScreenState extends State<RescuerResultConfirmationScreen> {
  String? _selectedSnake;
  final TextEditingController _scientificNameController = TextEditingController();
  double _snakeSize = 120;
  String _snakeStatus = 'healthy';
  final TextEditingController _releaseLocationController = TextEditingController();
  final TextEditingController _additionalNotesController = TextEditingController();
  
  bool get _isValid => _selectedSnake != null;

  @override
  void dispose() {
    _scientificNameController.dispose();
    _releaseLocationController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F4F4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Xác Nhận Hoàn Thành',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Success Section
                _buildSuccessSection(),
                
                // Summary Card
                _buildSummaryCard(),
                
                // Snake Confirmation Card
                _buildSnakeConfirmationCard(),
                
                // Details Section
                _buildDetailsSection(),
                
                // Fee Reminder Card
                _buildFeeReminderCard(),
                
                const SizedBox(height: 100),
              ],
            ),
          ),
          
          // Fixed Bottom Button
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildSuccessSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      color: const Color(0xFFF4F4F4),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF28A745).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF28A745),
                size: 50,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Đã bắt rắn thành công!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF28A745),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow(Icons.location_on, widget.requestData['address'] ?? '123 Nguyễn Văn Linh'),
          const SizedBox(height: 12),
          _buildSummaryRow(Icons.calendar_today, '8/12/2025, 14:30'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
          ),
          child: Icon(icon, color: const Color(0xFF666666), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSnakeConfirmationCard() {
    final aiSnakeName = widget.requestData['title'] ?? 'Rắn Hổ Mang';
    final bool isDifferentFromAI = _selectedSnake != null && _selectedSnake != aiSnakeName;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                'Xác Nhận Loài Rắn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFFFF6B35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Photo Grid
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.capturedPhotos.map((photo) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFE0E0E0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      photo,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFFF6B35), width: 1.5),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedSnake,
                hint: const Text(
                  'Chọn loài rắn',
                  style: TextStyle(color: Color(0xFF999999)),
                ),
                items: [
                  'Rắn Hổ Mang',
                  'Rắn Lục',
                  'Rắn Cạp Nong',
                  'Rắn Hổ Lục',
                  'Rắn Ri Cá',
                ].map((snake) {
                  return DropdownMenuItem(
                    value: snake,
                    child: Text(snake),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSnake = value;
                  });
                },
              ),
            ),
          ),
          
          if (isDifferentFromAI) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Color(0xFF856404), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Khác với kết quả AI ($aiSnakeName)',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF856404),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          TextField(
            controller: _scientificNameController,
            decoration: InputDecoration(
              hintText: 'Tên khoa học (tùy chọn)',
              hintStyle: const TextStyle(color: Color(0xFF999999)),
              filled: true,
              fillColor: const Color(0xFFF4F4F4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF28A745)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Size Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kích thước ước tính',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
              Text(
                '~${_snakeSize.toInt()} cm',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          Slider(
            value: _snakeSize,
            min: 0,
            max: 200,
            divisions: 200,
            activeColor: const Color(0xFF28A745),
            onChanged: (value) {
              setState(() {
                _snakeSize = value;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Status Radio Buttons
          const Text(
            'Tình trạng',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatusButton('healthy', 'Khỏe mạnh'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusButton('injured', 'Bị thương'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusButton('dead', 'Đã chết'),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Release Location
          const Text(
            'Địa điểm thả',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _releaseLocationController,
            decoration: InputDecoration(
              hintText: 'VD: Rừng xa dân cư',
              hintStyle: const TextStyle(color: Color(0xFF999999)),
              filled: true,
              fillColor: const Color(0xFFF4F4F4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF28A745)),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Additional Notes
          const Text(
            'Ghi chú bổ sung',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _additionalNotesController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Thông tin bổ sung...',
              hintStyle: const TextStyle(color: Color(0xFF999999)),
              filled: true,
              fillColor: const Color(0xFFF4F4F4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF28A745)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String value, String label) {
    final bool isSelected = _snakeStatus == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _snakeStatus = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF28A745) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF28A745) : const Color(0xFFDDDDDD),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Colors.white : const Color(0xFF333333),
          ),
        ),
      ),
    );
  }

  Widget _buildFeeReminderCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF28A745).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bạn sẽ nhận: ${widget.requestData['price'] ?? '170,000'} VNĐ',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF28A745),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Khách hàng thanh toán sau',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          border: const Border(
            top: BorderSide(color: Color(0xFFE0E0E0)),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: _isValid
                ? () {
                    _showSuccessDialog();
                  }
                : null,
            icon: const Icon(Icons.send, size: 20),
            label: const Text(
              'GỬI KẾT QUẢ CHO KHÁCH HÀNG',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isValid ? const Color(0xFF28A745) : const Color(0xFFDDDDDD),
              foregroundColor: _isValid ? Colors.white : const Color(0xFF999999),
              elevation: 0,
              disabledBackgroundColor: const Color(0xFFDDDDDD),
              disabledForegroundColor: const Color(0xFF999999),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RescuerMissionSuccessScreen(
          requestData: widget.requestData,
          photoCount: widget.capturedPhotos.length,
        ),
      ),
    );
  }
}
