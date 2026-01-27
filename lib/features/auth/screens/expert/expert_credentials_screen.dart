import 'package:flutter/material.dart';

class ExpertCredentialsScreen extends StatefulWidget {
  final Map<String, String> registrationData;

  const ExpertCredentialsScreen({
    super.key,
    required this.registrationData,
  });

  @override
  State<ExpertCredentialsScreen> createState() =>
      _ExpertCredentialsScreenState();
}

class _ExpertCredentialsScreenState extends State<ExpertCredentialsScreen> {
  final List<Map<String, dynamic>> _selectedFiles = [];
  bool _isLoading = false;

  void _pickFiles() async {
    // TODO: Implement file picker
    // For now, we'll simulate file selection
    setState(() {
      _selectedFiles.add({
        'name': 'certificate_${_selectedFiles.length + 1}.pdf',
        'size': '2.5 MB',
        'type': 'PDF',
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chứng chỉ đã được thêm'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _handleContinue() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Upload files and registration data to API
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Navigate to OTP verification first
      final result = await Navigator.pushNamed(
        context,
        '/otp-verification',
        arguments: widget.registrationData['email']!,
      );

      // After OTP verification, navigate to pending screen
      if (mounted && result == null) {
        // OTP verified successfully, go to pending screen
        Navigator.pushReplacementNamed(
          context,
          '/registration-pending',
          arguments: widget.registrationData['email']!,
        );
      }
    }
  }

  void _handleSkip() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bỏ qua nộp chứng chỉ?'),
        content: const Text(
          'Bạn có thể nộp chứng chỉ sau trong phần hồ sơ. Tuy nhiên, việc có chứng chỉ sẽ giúp quá trình phê duyệt nhanh hơn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleContinue();
            },
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nộp Chứng Chỉ',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.verified_outlined,
                    size: 48,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nộp Chứng Chỉ Chuyên Môn',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chứng chỉ sẽ giúp quá trình phê duyệt nhanh hơn. Bạn có thể bỏ qua và nộp sau.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Accepted file types
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Chấp nhận: PDF, JPG, PNG (tối đa 5MB)',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Upload button
            OutlinedButton.icon(
              onPressed: _pickFiles,
              icon: const Icon(Icons.upload_file),
              label: const Text('Chọn File Chứng Chỉ'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Files list
            if (_selectedFiles.isNotEmpty) ...[
              const Text(
                'Chứng chỉ đã chọn:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
            ],

            Expanded(
              child: _selectedFiles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có file nào được chọn',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _selectedFiles.length,
                      itemBuilder: (context, index) {
                        final file = _selectedFiles[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                              child: Icon(
                                Icons.description,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            title: Text(
                              file['name'],
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text('${file['type']} • ${file['size']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _removeFile(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 24),

            // Continue button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Tiếp Tục',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Skip button
            TextButton(
              onPressed: _isLoading ? null : _handleSkip,
              child: const Text(
                'Bỏ qua, nộp sau',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
