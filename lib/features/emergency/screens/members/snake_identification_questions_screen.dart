import 'package:flutter/material.dart';
import 'snake_filtered_results_screen.dart';

/// Snake Identification Questions Screen - Multi-step questionnaire for accurate identification
class SnakeIdentificationQuestionsScreen extends StatefulWidget {
  const SnakeIdentificationQuestionsScreen({super.key});

  @override
  State<SnakeIdentificationQuestionsScreen> createState() =>
      _SnakeIdentificationQuestionsScreenState();
}

class _SnakeIdentificationQuestionsScreenState
    extends State<SnakeIdentificationQuestionsScreen> {
  int _currentQuestionIndex = 0;
  final Map<int, String> _selectedAnswers = {};

  final List<QuestionData> _questions = [
    QuestionData(
      question: 'Hình dạng đầu rắn?',
      helper: 'Nhìn từ phía trên xuống',
      options: [
        QuestionOption(
          title: 'Đầu tròn / Oval',
          subtitle: '(Thường không độc)',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBA--AwuLRvg2fpNWhUrNeq3tLuvZx3EITq0ZxzTNVXP1lel-p0C2N5J518obzn-wyKTEVrnJU4dUgdSqrhRWD9K3i98DeZ6UoUqMptk_BTiBZBtdvJYyLtroNtwjk7NIl69EW9z7OuoworYokUy9gX2-rPsHxWQ-poysja2B4l_5KMG-0ZgCgGhERGH-mqMvWJvr2xa2eKA2g-y585tJZvTeS6hAQZx-_EQ7SqBXTThykrL7fmXk9UrQ9ZC76ZwBdDXFzTP5MjPoqa',
          value: 'round',
        ),
        QuestionOption(
          title: 'Đầu tam giác / Dẹt',
          subtitle: '(Thường có độc)',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAHMOyKBW_MwEiBoKUjQBxQ_GlKs7mo4flnZICvtlan1AWKZuKhn3iesdQtc2b5OzpZSHhLthB2_iMapyYEmSKITrHJBPcGIKKf_ZqHtnvq-nAOnY-XGm-qW1qBmFKtIlvQCGyMqIvQmG8OwC65I9rL_ltWj7d6hrpEz389BKvBxzFa2zqLGG73OzzvmL0s2-0eRfzBBADTvllmPQ3jIWzaKejVKrSDAy6VKw8paTep-0JCw3kvz30yBW5SmndwwcDe4e3AxjA0GQRw',
          value: 'triangle',
        ),
      ],
    ),
    QuestionData(
      question: 'Hoa văn trên thân?',
      helper: 'Quan sát kỹ các chi tiết',
      options: [
        QuestionOption(
          title: 'Có vân / Hoa văn rõ',
          subtitle: '(Sọc, đốm, vân phức tạp)',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDXKRqvmxA8NnH7sL0hRLhJLOLl5cPVMBqXqOFc3e2d4h3p8b5m2g9r1j4n',
          value: 'patterned',
        ),
        QuestionOption(
          title: 'Màu đơn sắc / Trơn',
          subtitle: '(Không có hoa văn rõ)',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCYMRqvmxA8NnH7sL0hRLhJLOLl5cPVMBqXqOFc3e2d4h3p8b5m2g9r1j4n',
          value: 'solid',
        ),
      ],
    ),
    QuestionData(
      question: 'Kích thước con rắn?',
      helper: 'Ước lượng chiều dài',
      options: [
        QuestionOption(
          title: 'Nhỏ (< 50cm)',
          subtitle: '(Khoảng bằng cánh tay)',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDXKRqvmxA8NnH7sL0hRLhJLOLl5cPVMBqXqOFc3e2d4h3p8b5m2g9r1j4n',
          value: 'small',
        ),
        QuestionOption(
          title: 'Trung bình (50cm - 1.5m)',
          subtitle: '(Dài ngang người)',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCYMRqvmxA8NnH7sL0hRLhJLOLl5cPVMBqXqOFc3e2d4h3p8b5m2g9r1j4n',
          value: 'medium',
        ),
        QuestionOption(
          title: 'Lớn (> 1.5m)',
          subtitle: '(Dài hơn người)',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDXKRqvmxA8NnH7sL0hRLhJLOLl5cPVMBqXqOFc3e2d4h3p8b5m2g9r1j4n',
          value: 'large',
        ),
      ],
    ),
    QuestionData(
      question: 'Môi trường bắt gặp?',
      helper: 'Nơi bạn nhìn thấy rắn',
      options: [
        QuestionOption(
          title: 'Gần nguồn nước',
          subtitle: '(Sông, hồ, ao, ruộng)',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDXKRqvmxA8NnH7sL0hRLhJLOLl5cPVMBqXqOFc3e2d4h3p8b5m2g9r1j4n',
          value: 'water',
        ),
        QuestionOption(
          title: 'Trên cây / Bụi rậm',
          subtitle: '(Rừng, vườn cây)',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCYMRqvmxA8NnH7sL0hRLhJLOLl5cPVMBqXqOFc3e2d4h3p8b5m2g9r1j4n',
          value: 'tree',
        ),
        QuestionOption(
          title: 'Mặt đất / Trong nhà',
          subtitle: '(Sân, đường, trong phòng)',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDXKRqvmxA8NnH7sL0hRLhJLOLl5cPVMBqXqOFc3e2d4h3p8b5m2g9r1j4n',
          value: 'ground',
        ),
      ],
    ),
  ];

  double get _progress =>
      (_currentQuestionIndex + 1) / _questions.length;

  void _selectOption(String value) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = value;
    });
  }

  void _nextQuestion() {
    if (!_selectedAnswers.containsKey(_currentQuestionIndex)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn một đáp án'),
          backgroundColor: Color(0xFFFF9800),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _showResults();
    }
  }

  void _skipQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    // Navigate to filtered results screen with answers
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SnakeFilteredResultsScreen(
          answers: _selectedAnswers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF666666)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nhận dạng qua câu hỏi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentQuestionIndex + 1} / ${_questions.length}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF999999),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
            child: Column(
              children: [
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF228B22),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Title
                    Text(
                      currentQuestion.question,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Helper Text
                    Text(
                      currentQuestion.helper,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Options Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: currentQuestion.options.length > 2 ? 1 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: currentQuestion.options.length > 2 ? 3.5 : 0.85,
                      ),
                      itemCount: currentQuestion.options.length,
                      itemBuilder: (context, index) {
                        final option = currentQuestion.options[index];
                        final isSelected = _selectedAnswers[_currentQuestionIndex] == option.value;

                        return _buildOptionCard(option, isSelected);
                      },
                    ),
                    const SizedBox(height: 32),

                    // Info Note
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFBBDEFB),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF1976D2),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Nếu không nhìn rõ, hãy giữ khoảng cách an toàn và chọn "Không chắc". An toàn là trên hết.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[800],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),

          // Footer Actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Next Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: const Color(0xFF228B22).withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentQuestionIndex < _questions.length - 1
                                ? 'Tiếp theo'
                                : 'Xem kết quả',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Skip Button
                  TextButton(
                    onPressed: _skipQuestion,
                    child: Text(
                      'Không chắc / Bỏ qua',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
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

  Widget _buildOptionCard(QuestionOption option, bool isSelected) {
    return InkWell(
      onTap: () => _selectOption(option.value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF0) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF228B22) : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF228B22).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      option.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: Color(0xFFBDBDBD),
                          ),
                        );
                      },
                    ),
                  ),
                  // Selection Indicator
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Color(0xFF228B22),
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              option.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 4),

            // Subtitle
            Text(
              option.subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionData {
  final String question;
  final String helper;
  final List<QuestionOption> options;

  QuestionData({
    required this.question,
    required this.helper,
    required this.options,
  });
}

class QuestionOption {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String value;

  QuestionOption({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.value,
  });
}
