import 'package:flutter/material.dart';
import 'package:snakeaid_mobile/features/emergency/screens/members/snake_filtered_results_screen.dart';

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

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Hình dạng đầu của con rắn?',
      'subtitle': 'Quan sát kỹ phần đầu của con rắn',
      'options': [
        {
          'title': 'Đầu tròn',
          'subtitle': 'Đầu tròn, không phân biệt rõ với cổ',
          'image': 'assets/images/head_round.png',
          'value': 'round',
        },
        {
          'title': 'Đầu tam giác',
          'subtitle': 'Đầu rộng hình tam giác, cổ hẹp rõ rệt',
          'image': 'assets/images/head_triangle.png',
          'value': 'triangle',
        },
      ],
    },
    {
      'question': 'Hoa văn trên thân rắn?',
      'subtitle': 'Mô tả màu sắc và hoa văn',
      'options': [
        {
          'title': 'Có hoa văn',
          'subtitle': 'Có vằn, vệt, hoặc hình dạng trên thân',
          'image': 'assets/images/pattern_yes.png',
          'value': 'patterned',
        },
        {
          'title': 'Không hoa văn',
          'subtitle': 'Màu đồng nhất, không có vằn vệt',
          'image': 'assets/images/pattern_no.png',
          'value': 'solid',
        },
      ],
    },
    {
      'question': 'Kích thước con rắn?',
      'subtitle': 'Ước lượng chiều dài',
      'options': [
        {
          'title': 'Nhỏ',
          'subtitle': 'Dưới 50cm, mỏng như ngón tay',
          'image': 'assets/images/size_small.png',
          'value': 'small',
        },
        {
          'title': 'Trung bình',
          'subtitle': '50cm - 1.5m, to như cổ tay',
          'image': 'assets/images/size_medium.png',
          'value': 'medium',
        },
        {
          'title': 'Lớn',
          'subtitle': 'Trên 1.5m, to như cánh tay',
          'image': 'assets/images/size_large.png',
          'value': 'large',
        },
      ],
    },
    {
      'question': 'Môi trường gặp rắn?',
      'subtitle': 'Con rắn xuất hiện ở đâu?',
      'options': [
        {
          'title': 'Gần nước',
          'subtitle': 'Ao, hồ, sông, kênh rạch',
          'image': 'assets/images/env_water.png',
          'value': 'water',
        },
        {
          'title': 'Trên cây',
          'subtitle': 'Cây cối, bụi rậm cao',
          'image': 'assets/images/env_tree.png',
          'value': 'tree',
        },
        {
          'title': 'Mặt đất',
          'subtitle': 'Đất, cỏ, đá, nhà cửa',
          'image': 'assets/images/env_ground.png',
          'value': 'ground',
        },
      ],
    },
  ];

  void _selectOption(String value) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = value;
    });
  }

  void _nextQuestion() {
    if (_selectedAnswers.containsKey(_currentQuestionIndex)) {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
        });
      } else {
        _showResults();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn một đáp án'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
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
    Navigator.push(
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
    final options = currentQuestion['options'] as List<Map<String, dynamic>>;
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_currentQuestionIndex > 0) {
              setState(() {
                _currentQuestionIndex--;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Trả lời câu hỏi',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Câu ${_currentQuestionIndex + 1}/${_questions.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF228B22),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF228B22),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          // Question content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentQuestion['question'] as String,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentQuestion['subtitle'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Options grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: options.length == 2 ? 2 : 1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: options.length == 2 ? 0.9 : 2.5,
                    ),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final isSelected = _selectedAnswers[_currentQuestionIndex] ==
                          option['value'];

                      return GestureDetector(
                        onTap: () => _selectOption(option['value'] as String),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF228B22)
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF228B22)
                                          .withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Image placeholder
                                    if (options.length == 2) ...[
                                      Container(
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.image,
                                            size: 40,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    Text(
                                      option['title'] as String,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? const Color(0xFF228B22)
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      option['subtitle'] as String,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF228B22),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(16),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF228B22),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentQuestionIndex < _questions.length - 1
                            ? 'Tiếp theo'
                            : 'Hoàn thành',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _skipQuestion,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Không chắc / Bỏ qua',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
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
}
