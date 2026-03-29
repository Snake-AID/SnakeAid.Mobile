import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/filter_question.dart';
import '../../repository/filter_question_repository.dart';

/// Snake Identification Questions Screen - Multi-step questionnaire for accurate identification
class SnakeIdentificationQuestionsScreen extends ConsumerStatefulWidget {
  final String? incidentId;

  const SnakeIdentificationQuestionsScreen({super.key, this.incidentId});

  @override
  ConsumerState<SnakeIdentificationQuestionsScreen> createState() =>
      _SnakeIdentificationQuestionsScreenState();
}

class _SnakeIdentificationQuestionsScreenState
    extends ConsumerState<SnakeIdentificationQuestionsScreen> {
  int _currentQuestionIndex = 0;
  final Map<int, int> _selectedAnswers = {}; // Map<questionIndex, optionId>
  List<FilterQuestion> _questions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final repository = ref.read(filterQuestionRepositoryProvider);
      final response = await repository.getFilterQuestions();

      if (response.isSuccess && response.data != null) {
        setState(() {
          _questions = response.data!;
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
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  double get _progress =>
      _questions.isEmpty ? 0 : (_currentQuestionIndex + 1) / _questions.length;

  void _selectOption(int optionId) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = optionId;
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

  void _showResults() async {
    // Check if user answered at least 3 questions
    if (_selectedAnswers.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng trả lời ít nhất 3 câu hỏi để xem kết quả'),
          backgroundColor: Color(0xFFFF9800),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF228B22)),
      ),
    );

    try {
      // Get selected option IDs
      final selectedOptionIds = _selectedAnswers.values.toList();

      // Call API to filter snakes
      final repository = ref.read(filterQuestionRepositoryProvider);
      final response = await repository.filterSnakesByAnswers(
        selectedOptionIds: selectedOptionIds,
      );

      if (mounted) {
        // Close loading dialog
        Navigator.pop(context);

        if (response.isSuccess && response.data != null) {
          // Navigate to filtered results screen with API data AND selectedOptionIds
          context.pushNamed(
            'snake_filtered_results',
            extra: {
              'filteredSnakes': response.data,
              'selectedOptionIds': selectedOptionIds,
              'incidentId': widget.incidentId,
            },
          );
        } else {
          _showError(response.message);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFDC3545),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F8F6),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF666666),
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                // Fallback: go to emergency tracking if no navigation stack
                context.goNamed(
                  'emergency_tracking',
                  extra: {'incidentId': widget.incidentId},
                );
              }
            },
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
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF228B22)),
        ),
      );
    }

    // Show error state
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F8F6),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF666666),
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                // Fallback: go to emergency tracking if no navigation stack
                context.goNamed(
                  'emergency_tracking',
                  extra: {'incidentId': widget.incidentId},
                );
              }
            },
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
        ),
        body: Center(
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
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadQuestions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF228B22),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show empty state
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F8F6),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF666666),
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                // Fallback: go to emergency tracking if no navigation stack
                context.goNamed(
                  'emergency_tracking',
                  extra: {'incidentId': widget.incidentId},
                );
              }
            },
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
        ),
        body: const Center(
          child: Text(
            'Không có câu hỏi nào',
            style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF666666)),
          onPressed: () {
            // Pop về tracking screen (bỏ qua location/camera filter)
            // Vì question filter được replace từ location hoặc camera
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
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
                  decoration: BoxDecoration(color: const Color(0xFFE0E0E0)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progress,
                    child: Container(
                      decoration: BoxDecoration(color: const Color(0xFF228B22)),
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
                    const SizedBox(height: 32),

                    // Options Grid - Always 2 columns for better image display
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: currentQuestion.options.length,
                      itemBuilder: (context, index) {
                        final option = currentQuestion.options[index];
                        final isSelected =
                            _selectedAnswers[_currentQuestionIndex] ==
                            option.id;

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
                        border: Border.all(color: const Color(0xFFBBDEFB)),
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
                top: BorderSide(color: Colors.grey[200]!, width: 1),
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

  Widget _buildOptionCard(FilterOption option, bool isSelected) {
    return InkWell(
      onTap: () => _selectOption(option.id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF228B22)
                : const Color(0xFFE0E0E0),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF228B22).withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image with selection indicator
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: option.optionImageUrl != null
                        ? Image.network(
                            option.optionImageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: Color(0xFFBDBDBD),
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: Color(0xFFBDBDBD),
                            ),
                          ),
                  ),

                  // Selection check badge (top-left)
                  if (isSelected)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF228B22),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Đã chọn',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Option text
                    Text(
                      option.optionText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? const Color(0xFF228B22)
                            : const Color(0xFF333333),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Select button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF228B22)
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isSelected ? 'Đã chọn' : 'Chọn phương án này',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF666666),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            isSelected ? Icons.check : Icons.arrow_forward,
                            size: 14,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF666666),
                          ),
                        ],
                      ),
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
}
